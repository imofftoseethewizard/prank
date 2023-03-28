import argparse
import contextlib
import os
import re
import sys
import textwrap

from pathlib import Path

parser = argparse.ArgumentParser(
    prog='wam',
    description='Extension to WAT to support debug and include forms.')

parser.add_argument('filename')
parser.add_argument('-d', '--debug', action='store_true', default=os.environ.get('WAM_DEBUG'))

class WamException(Exception):
    ...

class UndefinedMacro(WamException):
    def __init__(self, name, expr):
        self.name = name
        self.expr = expr

    def __str__(self):
        line_no = self.expr[0][2]
        line_text = '\n'.join(self.expr[0][4].split('\n')[line_no-1:line_no+2])
        path = self.expr[0][5]
        return f'error: undefined macro: {self.name} at line {line_no} of {path}:\n{line_text}'

class DefineMacroNameMissing(WamException):
    def __init__(self, expr):
        self.expr = expr

    def __str__(self):
        line_no = self.expr[0][2]
        line_text = '\n'.join(self.expr[0][4].split('\n')[line_no-1:line_no+2])
        path = self.expr[0][5]
        return f'error: name expected in macro definition at line {line_no} of {path}:\n{line_text}'

class MacroArgumentCountMismatchError(WamException):
    def __init__(self, name, expr):
        self.name = name
        self.expr = expr

    def __str__(self):
        line_no = self.expr[0][2]
        line_text = '\n'.join(self.expr[0][4].split('\n')[line_no-1:line_no+2])
        path = self.expr[0][5]
        return f'error: argument count mismatch: {self.name} at line {line_no} of {path}:\n{line_text}'

class Redefinition(WamException):
    def __init__(self, name, expr):
        self.name = name
        self.expr = expr

    def __str__(self):
        line_no = self.expr[0][2]
        line_text = '\n'.join(self.expr[0][4].split('\n')[line_no-1:line_no+2])
        path = self.expr[0][5]
        return f'error: redefinition: {self.name} at line {line_no} of {path}:\n{line_text}'

class UnrecognizedToken(WamException):
    def __init__(self, line, column, src, path):
        self.line = line
        self.column = column
        self.src = src
        self.path = path

    def __str__(self):
        lines = self.src.split('\n')[self.line-3:self.line]
        caret = ' ' * self.column + '^'
        detail = '\n'.join(lines + [caret])
        return f'error: unrecognized token: at line {self.line} of {self.path}:\n{detail}'

class DefineDefinitionNameExpected(WamException):
    def __init__(self, expr):
        self.expr = expr

    def __str__(self):
        line_no = self.expr[0][2]
        line_text = '\n'.join(self.expr[0][4].split('\n')[line_no-1:line_no+2])
        path = self.expr[0][5]
        return f'error: name expected in definition at line {line_no} of {path}:\n{line_text}'

lexemes = {
    'open-paren': re.compile(r'\('),
    'close-paren': re.compile(r'\)'),
    'comment': re.compile(';;[^\n]*'),
    'whitespace': re.compile('[ \t]+'),
    'newline': re.compile('\n'),
    'label': re.compile(r'[_A-Z$%,#+][-+a-zA-Z0-9._/?!]+'),
    'string': re.compile(r'"([^"\\]|\\.)*"'),
    'token': re.compile(r'[-a-z0-9._]+!?'),
}

@contextlib.contextmanager
def current_directory(path):
    old_cwd = os.getcwd()
    os.chdir(path)
    yield
    os.chdir(old_cwd)

def next_token(src, pos):
    for name, regexp in lexemes.items():
        match = regexp.match(src, pos)
        if match:
            return (name, match)

    return (None, None)

def tokens(src, path):

    pos = 0
    column = 0
    line = 1

    while True:
        name, match = next_token(src, pos)

        if name is None:
            break

        yield (name, match, line, column, src, path)

        if name == 'newline':
            column = 0
            line += 1
        else:
            column += match.end() - match.start()

        pos = match.end()

    if pos != len(src):
        raise UnrecognizedToken(line, column, src, path)


def parse(src, path):

    exprs = [[]]

    for name, match, line, column, src, path in tokens(src, path):

        if name == 'open-paren':
            new_expr = []
            exprs[-1].append(new_expr)
            exprs.append(new_expr)

        elif name == 'close-paren':
            if len(exprs) == 1:
                raise Exception(f'unmatched close paren: {match}', match)
            exprs.pop()

        else:
            exprs[-1].append((name, match.group(), line, column, src, path))

    if len(exprs) > 1:
        print(exprs[-1][:4])
        if line == len(src.split('\n'))+1:
            raise Exception('unmatched open paren at end of file')
        else:
            raise Exception(f'tokenization failure at line {line} column {column}')

    return exprs[0]

def translate(expr, env):

    if type(expr) == tuple:
        if expr[0] == 'label':

            if expr[1] in env['constants']:
                return ('label', env['constants'][expr[1]], *expr[2:])

            if expr[1] in env['defs']:
                return ('splice', env['defs'][expr[1]], -1)

            if expr[1].startswith('$'):
                return [
                    ('token', 'local.get', expr[2:]),
                    ('whitespace', ' ', expr[2:]),
                    expr
                ]

        return expr

    op = None

    if type(expr[0]) == tuple:
        op = expr[0][1]

    if op and op.startswith('%'):
        return expand_macro(expr, env)

    if op and op.startswith('+'):
        return translate_serial(expr, env)

    if op and op.startswith('$'):
        return translate_call(expr, env)

    if op == 'set!':
        return translate_set(expr, env)

    if op == 'local.get':
        return expr

    if op in ('br', 'br_if', 'call', 'call_indirect', 'func', 'global', 'global.get',
              'global.set', 'local', 'local.get', 'local.set', 'loop', 'memory',
              'param', 'ref.func', 'start', 'table', 'table.set', 'type'):
        return translate_labeled_expr(expr, env)

    if op == 'debug':

        if not env['debug']:
            return None

        else:
            return translate_debug(expr[1:], env)

    if op == 'release':

        if env['debug']:
            return None

        else:
            return translate_release(expr[1:], env)

    if op == 'string':
        return translate_string(expr, env)

    if op == 'test':
        return define_test(expr, env)

    if op == 'macro':
        return define_macro(expr, env)

    if op == 'include':
        return include_file(expr, env)

    if op == 'const':
        return define_constant(expr, env)

    if op == 'define':
        return define_definition(expr, env)

    return [
        e1
        for e1 in (translate(e0, env) for e0 in expr)
        if e1 is not None
    ]

def translate_labeled_expr(expr, env):

    label = False
    head = []
    rest = []

    for e in expr:

        if rest or label or type(e) != tuple:
            rest.append(e)

        elif type(e) == tuple and e[0] == 'label':
            label = True
            head.append(e)

        else:
            head.append(e)

    return [
        *head,
        *[
            e1
            for e1 in (translate(e0, env) for e0 in rest)
            if e1 is not None
        ]
    ]

def translate_set(expr, env):

    return [
        ('token', 'local.set', *expr[0][2:]),
        expr[1], # whitespace
        expr[2], # target label
        *[
            e1
            for e1 in (translate(e0, env) for e0 in expr[3:])
            if e1 is not None
        ]
    ]

def translate_call(expr, env):

    return [
        ('token', 'call', *expr[0][2:]),
        ('whitespace', ' ', *expr[0][2:]),
        expr[0], #func label
        *[
            e1
            for e1 in (translate(e0, env) for e0 in expr[1:])
            if e1 is not None
        ]
    ]

def translate_string(expr, env):

    body = []
    value = None
    offset = env['data-offset']
    ctx = expr[0][2:]
    column = ctx[1]

    for e in expr[1:]:

        if e[0] == 'string':

            assert value is None
            value = e[1].strip('"')

        else:
            body.append(e)

    assert value is not None

    length = wat_string_len(value)

    env['data-offset'] = offset + length + 1

    const_expr = [
        ('token', 'i32.const', *ctx),
        ('whitespace', ' ', *ctx),
        ('token', str(offset), *ctx),
    ]

    data_expr = [
        ('token', 'data', *ctx),
        ('whitespace', ' ', *ctx),
        [
            ('token', 'offset', *ctx),
            ('whitespace', ' ', *ctx),
            const_expr,
        ],
        ('string', f'"\\{length:02x}{value}"', *ctx),
    ]

    line_break = ('whitespace', '\n' + ' ' * (column-1), *ctx,)

    global_expr = [
        ('token', 'global', *ctx),
        *body,
        ('token', 'i32', *ctx),
        ('whitespace', ' ', *ctx),
        const_expr,
    ]

    return ('splice', [data_expr, line_break, global_expr], -1)

def wat_string_len(s):

    if '\\' not in s:
        return len(s.encode())

    # replace simple backslash escapes with 'a', which has the same length.
    parts = re.sub(r'''\\([tnr"'\\]|\d\d)''', 'a', s).split('\\')
    length = len(parts[0].encode())

    for part in parts[1:]:
        if part[0] == 'u':
            # part should be of the form 'u{x..x}...' where x is a hex digit
            hex_digits, rest = '}'.split(part[2:], 1)
            length += len(chr(int(hex_digits, 16)).encode()) + len(rest.encode())

    return length

def translate_serial(expr, env):

    name = None
    value = None
    step = None

    for e in expr:

        if e[0] in ('whitespace', 'comment'):
            continue

        if name is None:

            assert e[0] == 'label'
            name = e[1]

        elif value is None:

            assert e[0] == 'token'
            value = int(e[1])

        elif step is None:

            assert e[0] == 'token'
            step = int(e[1])

        else:
            print(e)
            assert False

    if value is None:
        value = env['sequences'].get(name, (0, 1))[0]

    if step is None:
        step = env['sequences'].get(name, (0, 1))[1]

    env['sequences'][name] = (value + step, step)

    ctx = expr[0][2:]
    return [
        ('token', 'i32.const', *ctx),
        ('whitespace', ' ', *ctx),
        ('token', str(value), *ctx),
    ]

def define_test(expr, env):

    if not env['debug']:
        return None

    op = None
    name = None
    result = []

    for e in expr:
        if op is None:
            op = e
            result.append(('token', 'func', *op[2:]))

        elif name is None and e[0] == 'label':

            name = e[1]
            bare_name = name.strip('$')

            result.append(e)
            result.extend(
                [
                    ('whitespace', ' ', *e[2:]),
                    [
                        ('token', 'export', *e[2:]),
                        ('whitespace', ' ', *e[2:]),
                        ('string', f'"!{bare_name}"', *e[2:]),
                    ],
                ])

        else:
            result.append(e)

    return result

def translate_debug(expr, env):

    debug_exprs = []

    for e in expr[1:]:

        if not debug_exprs and type(e) == tuple and e[0] in ('comment', 'newline', 'whitespace'):
            continue

        else:
            debug_exprs.append(e)

    return ('splice', [translate(e, env) for e in debug_exprs], -1)

def translate_release(expr, env):

    exprs = []

    for e in expr[1:]:

        if not exprs and type(e) == tuple and e[0] in ('comment', 'newline', 'whitespace'):
            continue

        else:
            exprs.append(e)

    return ('splice', [translate(e, env) for e in exprs], -1)

def expand_macro(expr, env):

    name = None
    arg_exprs = []

    for e in expr:

        if type(e) == tuple and e[0] in ('comment', 'newline', 'whitespace'):
            continue

        if name is None and type(e) == tuple and e[0] == 'label':
            name = e[1]

        elif name:
            arg_exprs.append(e)

        else:
            # The context in which this is called should ensure that this never gets
            # here.
            assert False, (expr, e)

    if name not in env['macros']:
        raise UndefinedMacro(name, expr)

    macro = env['macros'][name]

    if len(arg_exprs) != len(macro['params']):
        raise MacroArgumentCountMismatchError(name, expr)

    subst_env = {
        **env,
        'params': {
            param_name: e
            for (param_type, param_name), e in zip(macro['params'], arg_exprs)
            if param_type != 'class'
        },
        'class-params': {
            param_name: e
            for (param_type, param_name), e in zip(macro['params'], arg_exprs)
            if param_type == 'class'
        }
    }

    return ('splice', translate(substitute_params(macro['body'], subst_env), env), -1)

def substitute_params(expr, env):

    if type(expr) == tuple:

        if expr[0] == 'label':

            label_value = expr[1]
            label_stem = label_value.split('.', 1)[0]

            if label_stem in env['class-params']:
                return substitute_class_param(label_stem, label_value, expr, env)

            return env['params'].get(expr[1], expr)

        else:
            return expr

    return [
        substitute_params(e, env)
        for e in expr
    ]

def substitute_class_param(label_stem, label, expr, env):

    class_expr = env['class-params'][label_stem]

    if label == label_stem:
        return env['class-params'][label]

    label_suffix = label.split('.', 1)[1]

    if label_suffix == 'align_mask':
        value = class_align_mask[class_expr[1]]

    elif label_suffix == 'size':
        value = class_size[class_expr[1]]

    elif label_suffix == 'bits':
        value = class_bits[class_expr[1]]

    elif label_suffix == 'size_bits':
        value = class_size_bits[class_expr[1]]

    else:
        value = f'{class_expr[1]}.{label_suffix}'

    return ('label', value, -1)

class_align_mask = {
    'i8':   '-1',
    'i16':  '-2',
    'i32':  '-4',
    'i64':  '-8',
    'i128': '-16',
    'f32':  '-4',
    'f64':  '-8',
}

class_size = {
    'i8':   '1',
    'i16':  '2',
    'i32':  '4',
    'i64':  '8',
    'i128': '16',
    'f32':  '4',
    'f64':  '8',
}

class_bits = {
    'i8':   '8',
    'i16':  '16',
    'i32':  '32',
    'i64':  '64',
    'i128': '128',
    'f32':  '32',
    'f64':  '64',
}

class_size_bits = {
    'i8':   '3',
    'i16':  '4',
    'i32':  '5',
    'i64':  '6',
    'i128': '7',
    'f32':  '5',
    'f64':  '6',
}

def include_file(expr, env):

    column = expr[0][2]
    path = None

    for e in expr[1:]:

        if not path and type(e) == tuple and e[0] in ('comment', 'newline', 'whitespace'):
            continue

        if path is None and type(e) == tuple and e[0] == 'string':
            path = e[1].strip('"')

        else:
            raise IncludeFilePathExpected(expr)

    src = textwrap.indent(textwrap.dedent(open(path).read()), ' ' * column)

    with current_directory(Path(path).parent):
        return ('splice', translate(parse(src, path), env), -1)

def define_macro(expr, env):

    name = None
    params = []
    body = []

    for e in expr[1:]:

        if not body and type(e) == tuple and e[0] in ('comment', 'newline', 'whitespace'):
            continue

        if name is None:
            if e[0] != 'label':
                raise DefineMacroNameExpected(expr)

            name = e[1]

        elif not body and type(e) != tuple and e[0][1] in  ('class', 'expr', 'label'):

            params.append(define_param(e))

        else:
            body.append(e)

    if name is None:
        raise DefineMacroNameMissing(expr)

    if name in env['macros']:
        raise MacroRedefinition(name, expr)

    env['macros'][name] = {
        'params': params,
        'body': body,
    }

def define_param(expr):

    param_type = expr[0][1]
    param_name = None

    for e in expr[1:]:

        if type(e) == tuple and e[0] in ('comment', 'newline', 'whitespace'):
            continue

        if param_name == None:

            if e[0] != 'label':
                raise DefineParameterNameExpected(expr)

            param_name = e[1]

        else:
            raise DefineParameterUnexpectedExpression(expr, e)

    return (param_type, param_name)

def define_constant(expr, env):
    name = None
    value = None

    for e in expr[1:]:

        if type(e) == tuple and e[0] in ('comment', 'newline', 'whitespace'):
            continue

        if name is None:
            if e[0] != 'label':
                raise DefineConstantNameExpected(expr)

            name = e[1]

        elif value is None and type(e) == tuple:

            value = e[1]

        else:
            raise UnexpectedExprInConstant(expr, e)

    if name is None:
        raise DefineConstantNameMissing(expr)

    if name in env['constants']:
        raise ConstantRedefinition(name, expr)

    env['constants'][name] = value

def define_definition(expr, env):
    name = None
    body = []

    for e in expr[1:]:

        if not body and type(e) == tuple and e[0] in ('comment', 'newline', 'whitespace'):
            continue

        if name is None:
            if e[0] != 'label':
                raise DefineDefinitionNameExpected(expr)

            name = e[1]

        else:

            body.append(e)

    if name is None:
        raise DefineDefinitionNameMissing(expr)

    if name in env['defs']:
        raise Redefinition(name, expr)

    env['defs'][name] = translate(body, env)

def emit(expr):

    if type(expr) == tuple:

        if expr[0] == 'splice':

            for e in expr[1]:
                emit(e)

        else:
            print(expr[1], end='')

    else:
        print('(', end='')

        for e in expr:
            emit(e)

        print(')', end='')

def process(args):

    for expr in parse(open(args.filename).read(), args.filename):
        with current_directory(Path(args.filename).parent):
            env = {
                'debug': args.debug,
                'constants': {},
                'defs': {},
                'macros': {},
                'data-offset': 0,
                'sequences': {},
            }
            emit(translate(expr, env))

if __name__ == '__main__':
    try:
        process(parser.parse_args())

    except WamException as exc:
        print(exc, file=sys.stderr)
        exit(1)
