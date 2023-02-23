import argparse
import os
import re
import textwrap

parser = argparse.ArgumentParser(
    prog='wam',
    description='Extension to WAT to support debug and include forms.')

parser.add_argument('filename')
parser.add_argument('-d', '--debug', action='store_true', default=os.environ.get('WAM_DEBUG'))

lexemes = {
    'open-paren': re.compile(r'\('),
    'close-paren': re.compile(r'\)'),
    'comment': re.compile(';;[^\n]*'),
    'whitespace': re.compile('[ \t]+'),
    'newline': re.compile('\n'),
    'label': re.compile(r'\$[-a-z0-9]+'),
    'string': re.compile(r'"([^"\\]|\\.)*"'),
    'token': re.compile(r'[-a-z0-9._]+'),
}

def next_token(src, pos):
    for name, regexp in lexemes.items():
        match = regexp.match(src, pos)
        if match:
            return (name, match)

    return (None, None)

def tokens(src):

    pos = 0
    indent = 0

    while True:
        name, match = next_token(src, pos)

        if name is None:
            break

        yield (name, match, indent)

        if name == 'newline':
            indent = 0
        else:
            indent = match.end() - match.start()

        pos = match.end()

def parse(src):

    exprs = [[]]

    for name, match, indent in tokens(src):

        if name == 'open-paren':
            new_expr = []
            exprs[-1].append(new_expr)
            exprs.append(new_expr)

        elif name == 'close-paren':
            if len(exprs) == 1:
                raise Exception(f'unmatched close paren: {match}', match)
            exprs.pop()

        else:
            exprs[-1].append((name, match, indent))

    if len(exprs) > 1:
        raise Exception('unmatched open paren at end of file')

    return exprs[0]

def translate(expr, env):

    if type(expr) == tuple:
        return expr

    op = None
    rest = expr

    if type(expr[0]) == tuple:
        op = expr[0][1].group()
        rest = expr[0:]

    if op == 'debug':

        if not env['debug']:
            return None

        else:
            return translate_debug(expr[1:], env)

    if op == 'expand':
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

    debug_expr = None

    for e in expr[1:]:

        if not debug_expr and type(e) == tuple and e[0] in ('comment', 'newline', 'whitespace'):
            continue

        else:
            assert type(e) == list and debug_expr is None, (expr, e)
            debug_expr = e

    return translate(debug_expr, env)

def expand_macro(expr, env):

    name = None
    label_exprs = []

    for e in expr[1:]:

        if type(e) == tuple and e[0] in ('comment', 'newline', 'whitespace'):
            continue

        if type(e) == tuple and e[0] == 'label':

            if name is None:
                name = e[1].group()

            else:
                label_exprs.append(e)

        else:
            assert False, (expr, e)

    macro = env['macros'][name]

    assert len(label_exprs) == len(macro['labels'])

    subst_env = {
        **env,
        'labels': {
            label: e
            for label, e in zip(macro['labels'], label_exprs)
        }
    }

    return ('splice', translate(substitute_labels(macro['body'], subst_env), env), -1)

def substitute_labels(expr, env):

    if type(expr) == tuple:

        if expr[0] == 'label':
            return env['labels'].get(expr[1].group(), expr)

        else:
            return expr

    return [
        substitute_labels(e, env)
        for e in expr
    ]

def include_file(expr, env):

    indent = expr[0][2]
    path = None

    for e in expr[1:]:

        if not path and type(e) == tuple and e[0] in ('comment', 'newline', 'whitespace'):
            continue

        if path is None and type(e) == tuple and e[0] == 'string':
            path = e[1].group().strip('"')

        else:
            assert False, (expr, e)

    src = textwrap.indent(textwrap.dedent(open(path).read()), ' ' * indent)

    return ('splice', translate(parse(src), env), -1)

def define_macro(expr, env):

    name = None
    labels = []
    body = []

    for e in expr[1:]:

        if not body and type(e) == tuple and e[0] in ('comment', 'newline', 'whitespace'):
            continue

        if name is None:
            assert e[0] == 'label', e
            name = e[1].group()

        elif not body and type(e) != tuple and e[0][1].group() == 'label':
            labels.append(define_label(e))

        else:
            body.append(e)

    assert name is not None, expr
    assert name not in env['macros'], expr

    env['macros'][name] = {
        'labels': labels,
        'body': body,
    }

def define_label(expr):

    label = None

    for e in expr[1:]:

        if type(e) == tuple and e[0] in ('comment', 'newline', 'whitespace'):
            continue

        if label == None:
            assert e[0] == 'label'
            label = e[1].group()

        else:
            assert False, (expr, e)

    return label

def emit(expr):

    if type(expr) == tuple:

        if expr[0] == 'splice':

            for e in expr[1]:
                emit(e)

        else:
            print(expr[1].group(), end='')

    else:
        print('(', end='')

        for e in expr:
            emit(e)

        print(')', end='')

def process(args):

    for expr in parse(open(args.filename).read()):
        emit(translate(expr, { 'debug': args.debug, 'macros': {} }))

if __name__ == '__main__':
    process(parser.parse_args())
