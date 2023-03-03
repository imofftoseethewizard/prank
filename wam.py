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

lexemes = {
    'open-paren': re.compile(r'\('),
    'close-paren': re.compile(r'\)'),
    'comment': re.compile(';;[^\n]*'),
    'whitespace': re.compile('[ \t]+'),
    'newline': re.compile('\n'),
    'label': re.compile(r'[A-Z$%,][-a-z0-9._/]+'),
    'string': re.compile(r'"([^"\\]|\\.)*"'),
    'token': re.compile(r'[-a-z0-9._]+'),
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
    indent = 0
    line = 1

    while True:
        name, match = next_token(src, pos)

        if name is None:
            break

        yield (name, match, line, indent, src, path)

        if name == 'newline':
            indent = 0
            line += 1
        else:
            indent = match.end() - match.start()

        pos = match.end()

def parse(src, path):

    exprs = [[]]

    for name, match, line, indent, src, path in tokens(src, path):

        if name == 'open-paren':
            new_expr = []
            exprs[-1].append(new_expr)
            exprs.append(new_expr)

        elif name == 'close-paren':
            if len(exprs) == 1:
                raise Exception(f'unmatched close paren: {match}', match)
            exprs.pop()

        else:
            exprs[-1].append((name, match.group(), line, indent, src, path))

    if len(exprs) > 1:
        from pprint import pprint; pprint(exprs)
        raise Exception('unmatched open paren at end of file')

    return exprs[0]

def translate(expr, env):

    if type(expr) == tuple:
        return expr

    op = None
    rest = expr

    if type(expr[0]) == tuple:
        op = expr[0][1]
        rest = expr[0:]

    if op == 'debug':

        if not env['debug']:
            return None

        else:
            return translate_debug(expr[1:], env)

    if op and op.startswith('%'):
        return expand_macro(expr, env)

    if op == 'include':
        return include_file(expr, env)

    if op == 'macro':
        return define_macro(expr, env)

    return [
        e1
        for e1 in (translate(e0, env) for e0 in rest)
        if e1 is not None
    ]

def translate_debug(expr, env):

    debug_exprs = []

    for e in expr[1:]:

        if not debug_exprs and type(e) == tuple and e[0] in ('comment', 'newline', 'whitespace'):
            continue

        else:
            debug_exprs.append(e)

    return ('splice', [translate(e, env) for e in debug_exprs], -1)


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

class_size = {
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

    indent = expr[0][2]
    path = None

    for e in expr[1:]:

        if not path and type(e) == tuple and e[0] in ('comment', 'newline', 'whitespace'):
            continue

        if path is None and type(e) == tuple and e[0] == 'string':
            path = e[1].strip('"')

        else:
            raise IncludeFilePathExpected(expr)

    src = textwrap.indent(textwrap.dedent(open(path).read()), ' ' * indent)

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
            emit(translate(expr, { 'debug': args.debug, 'macros': {} }))

if __name__ == '__main__':
    try:
        process(parser.parse_args())

    except WamException as exc:
        print(exc, file=sys.stderr)
        exit(1)
