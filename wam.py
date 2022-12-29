import argparse
import textwrap
import re

parser = argparse.ArgumentParser(
    prog='wam',
    description='Extension to WAT to support debug and include forms.')

parser.add_argument('filename')
parser.add_argument('-d', '--debug', action='store_true')

def process(args):

    def process_include(match):
        indent = match.group(1)
        path = match.group(2)
        return textwrap.indent(textwrap.dedent(open(path).read()), indent)

    def process_debug(match):
        return match.group(1) if args.debug else ''

    text = open(args.filename).read()
    text = re.sub(r'( *)\(include +"(([^"\\]|\\.)*)"\)', process_include, text)
    text = re.sub(r'\(debug +(\(export +"([^"\\]|\\.)*"\))\)', process_debug, text)

    print(text)

if __name__ == '__main__':
    process(parser.parse_args())
