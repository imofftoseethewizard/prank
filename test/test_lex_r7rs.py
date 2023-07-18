import pytest

from util import create_test_string, format_addr

from modules.debug.block_mgr import *
from modules.debug.chars import *
from modules.debug.lex import *
from modules.debug.lex_r7rs import *
from modules.debug.pairs import *
from modules.debug.strings import *

binary_digits = '01'
octal_digits = '01234567'
decimal_digits = '0123456789'
hex_digits = '0123456789ABCDEFabcdef'

def ordinals(s):
    return [ord(c) for c in s]

binary_ordinals = ordinals(binary_digits)
octal_ordinals = ordinals(octal_digits)
decimal_ordinals = ordinals(decimal_digits)
hex_ordinals = ordinals(hex_digits)

def init_test():
    init_pairs()
    init_blockset_manager()
    init_strings()
    init_lex_r7rs()

def check_match(match_fn, src, expected_rule_id, expected_end=None):
    s = create_test_string(src)
    text = get_string_addr(s)
    end = text + get_string_size(s)

    if expected_end is None:
        expected_end = end

    elif expected_end >= 0:
        expected_end += text

    else:
        expected_end += end

    matched_rule_id, match_end = match_fn(text, end)
    assert matched_rule_id == expected_rule_id.value
    assert match_end == expected_end

def check_match_many(match_fn, src, expected_rule_ids, expected_end=None):
    s = create_test_string(src)
    text = get_string_addr(s)
    end = text + get_string_size(s)

    if expected_end is None:
        expected_end = end

    elif expected_end >= 0:
        expected_end += text

    else:
        expected_end += end

    matched_rule_id, match_end = match_fn(text, end)
    assert matched_rule_id in [r.value for r in expected_rule_ids]
    assert match_end == expected_end

def check_match_fail(match_fn, src, expected_rule_id):
    s = create_test_string(src)
    text = get_string_addr(s)
    end = text + get_string_size(s)

    matched_rule_id, match_end = match_fn(text, end)
    assert matched_rule_id == expected_rule_id.value
    assert match_end == -1

def test_init():
    init_test()

def test_lex_match_delimited_token():
    init_test()

    check_match_fail(lex_match_delimited_token, '', lex_rule_delimited_token)

    check_match(lex_match_delimited_token, '#(',   lex_rule_delimited_token_string)
    check_match(lex_match_delimited_token, '#u8(', lex_rule_delimited_token_string)
    check_match(lex_match_delimited_token, ',@',   lex_rule_delimited_token_string)

    check_match(lex_match_delimited_token, '(', lex_rule_token_char)
    check_match(lex_match_delimited_token, ')', lex_rule_token_char)
    check_match(lex_match_delimited_token, "'", lex_rule_token_char)
    check_match(lex_match_delimited_token, '`', lex_rule_token_char)
    check_match(lex_match_delimited_token, ',', lex_rule_token_char)

    check_match(lex_match_delimited_token, '||',                 lex_rule_vertical_line_quoted_symbol)
    check_match(lex_match_delimited_token, r'|\||',              lex_rule_vertical_line_quoted_symbol)
    check_match(lex_match_delimited_token, r'|\a\b\n\r\t|',      lex_rule_vertical_line_quoted_symbol)
    check_match(lex_match_delimited_token, r'|\xbeef;|',         lex_rule_vertical_line_quoted_symbol)
    check_match(lex_match_delimited_token, '|foo \n bar|',       lex_rule_vertical_line_quoted_symbol)
    check_match(lex_match_delimited_token, '|dos foo \r\n bar|', lex_rule_vertical_line_quoted_symbol)

    check_match(lex_match_delimited_token, '""',                 lex_rule_quoted_string)
    check_match(lex_match_delimited_token, r'"\""',              lex_rule_quoted_string)
    check_match(lex_match_delimited_token, r'"\a\b\n\r\t\\"',    lex_rule_quoted_string)
    check_match(lex_match_delimited_token, r'"\xbeef;"',         lex_rule_quoted_string)
    check_match(lex_match_delimited_token, '"foo \\ \n bar"',    lex_rule_quoted_string)
    check_match(lex_match_delimited_token, '"dos foo \r\n bar"', lex_rule_quoted_string)

def test_lex_match_undelimited_token():
    init_test()

    check_match_fail(lex_match_undelimited_token, '', lex_rule_undelimited_token)

    check_match_fail(lex_match_undelimited_token, '||',                 lex_rule_undelimited_token)
    check_match_fail(lex_match_undelimited_token, r'|\||',              lex_rule_undelimited_token)
    check_match_fail(lex_match_undelimited_token, r'|\a\b\n\r\t|',      lex_rule_undelimited_token)
    check_match_fail(lex_match_undelimited_token, r'|\xbeef;|',         lex_rule_undelimited_token)
    check_match_fail(lex_match_undelimited_token, '|foo \n bar|',       lex_rule_undelimited_token)
    check_match_fail(lex_match_undelimited_token, '|dos foo \r\n bar|', lex_rule_undelimited_token)

    check_match(lex_match_undelimited_token, '#x1', lex_rule_num_16)
    check_match(lex_match_undelimited_token, '1',   lex_rule_num_10)
    check_match(lex_match_undelimited_token, '+1',  lex_rule_num_10)
    check_match(lex_match_undelimited_token, '-i',  lex_rule_num_10)
    check_match(lex_match_undelimited_token, '#d1', lex_rule_num_10)
    check_match(lex_match_undelimited_token, '#o1', lex_rule_num_8)
    check_match(lex_match_undelimited_token, '#b1', lex_rule_num_2)

    check_match(lex_match_undelimited_token, '#f',     lex_rule_boolean)
    check_match(lex_match_undelimited_token, '#false', lex_rule_boolean)
    check_match(lex_match_undelimited_token, '#t',     lex_rule_boolean)
    check_match(lex_match_undelimited_token, '#true',  lex_rule_boolean)

    check_match(lex_match_undelimited_token, '.', lex_rule_dot)

    check_match(lex_match_undelimited_token, 'a',    lex_rule_ordinary_identifier)
    check_match(lex_match_undelimited_token, 'Z',    lex_rule_ordinary_identifier)
    check_match(lex_match_undelimited_token, 'eq!?', lex_rule_ordinary_identifier)
    check_match(lex_match_undelimited_token, 'B-52', lex_rule_ordinary_identifier)

    check_match(lex_match_undelimited_token, '+',    lex_rule_peculiar_identifier)
    check_match(lex_match_undelimited_token, '-',    lex_rule_peculiar_identifier)
    check_match(lex_match_undelimited_token, '-?!A', lex_rule_peculiar_identifier)
    check_match(lex_match_undelimited_token, '...',  lex_rule_peculiar_identifier)

def test_lex_match_token_char():

    check_match_fail(lex_match_token_char, '', lex_rule_token_char)

    for b in range(32, 128):
        c = chr(b)
        if c in "()'`,":
            check_match(lex_match_token_char, c, lex_rule_token_char)
        else:
            check_match_fail(lex_match_token_char, c, lex_rule_token_char)

def test_lex_match_delimited_token_string():
    init_test()

    check_match_fail(lex_match_delimited_token_string, '', lex_rule_delimited_token_string)

    check_match(lex_match_delimited_token_string, '#(',   lex_rule_delimited_token_string)
    check_match(lex_match_delimited_token_string, '#u8(', lex_rule_delimited_token_string)

def test_lex_match_unquote_splicing():
    init_test()

    check_match_fail(lex_match_unquote_splicing, '', lex_rule_unquote_splicing)

    check_match(lex_match_unquote_splicing, ',@', lex_rule_unquote_splicing)

def test_lex_match_delimiter():
    init_test()

    check_match_fail(lex_match_delimiter, '', lex_rule_delimiter)

    for b in range(32, 128):
        c = chr(b)
        if c in '\n\r\t |()";':
            check_match(lex_match_delimiter, c, lex_rule_delimiter)
        else:
            check_match_fail(lex_match_delimiter, c, lex_rule_delimiter)

def test_lex_match_intraline_whitespace():
    test_init()

    check_match_fail(lex_match_intraline_whitespace, '', lex_rule_intraline_whitespace)

    for b in range(32, 128):
        c = chr(b)
        if c in ' \t':
            check_match(lex_match_intraline_whitespace, c, lex_rule_intraline_whitespace)
        else:
            check_match_fail(lex_match_intraline_whitespace, c, lex_rule_intraline_whitespace)

def test_lex_match_whitespace():
    init_test()

    check_match_fail(lex_match_whitespace, '', lex_rule_whitespace)

    check_match(lex_match_whitespace, ' ',    lex_rule_intraline_whitespace)
    check_match(lex_match_whitespace, '\t',   lex_rule_intraline_whitespace)
    check_match(lex_match_whitespace, '\n',   lex_rule_line_ending_char)
    check_match(lex_match_whitespace, '\r',   lex_rule_line_ending_char)
    check_match(lex_match_whitespace, '\r\n', lex_rule_dos_line_ending)

def test_lex_match_line_ending():
    init_test()

    check_match_fail(lex_match_line_ending, '',  lex_rule_line_ending)
    check_match_fail(lex_match_line_ending, ' ', lex_rule_line_ending)

    check_match(lex_match_line_ending, '\n',   lex_rule_line_ending_char)
    check_match(lex_match_line_ending, '\r',   lex_rule_line_ending_char)
    check_match(lex_match_line_ending, '\r\n', lex_rule_dos_line_ending)

def test_lex_match_dos_line_ending():
    init_test()

    check_match_fail(lex_match_dos_line_ending, '',   lex_rule_dos_line_ending)
    check_match_fail(lex_match_dos_line_ending, ' ',  lex_rule_dos_line_ending)
    check_match_fail(lex_match_dos_line_ending, '\n', lex_rule_dos_line_ending)
    check_match_fail(lex_match_dos_line_ending, '\r', lex_rule_dos_line_ending)

    check_match(lex_match_dos_line_ending, '\r\n', lex_rule_dos_line_ending)

def test_lex_match_comment():
    init_test()

    check_match_fail(lex_match_comment, '', lex_rule_comment)

    check_match(lex_match_comment, ';abc\n', lex_rule_simple_comment, expected_end=-1)
    check_match(lex_match_comment, '#||#',   lex_rule_nested_comment)

def test_lex_match_simple_comment():
    init_test()

    check_match_fail(lex_match_simple_comment, '',     lex_rule_simple_comment)
    check_match_fail(lex_match_simple_comment, ';',    lex_rule_simple_comment)
    check_match_fail(lex_match_simple_comment, ';abc', lex_rule_simple_comment)

    check_match(lex_match_simple_comment, ';abc\n', lex_rule_simple_comment, expected_end=-1)
    check_match(lex_match_simple_comment, ';abc\r', lex_rule_simple_comment, expected_end=-1)

def test_lex_match_datum_comment():
    init_test()

    check_match_fail(lex_match_datum_comment, '', lex_rule_datum_comment)
    check_match_fail(lex_match_datum_comment, '#', lex_rule_datum_comment)

    check_match(lex_match_datum_comment, '#;', lex_rule_datum_comment)

def test_lex_match_nested_comment():
    init_test()

    check_match_fail(lex_match_nested_comment, '', lex_rule_nested_comment)
    check_match_fail(lex_match_nested_comment, '#', lex_rule_nested_comment)
    check_match_fail(lex_match_nested_comment, '#||', lex_rule_nested_comment)
    check_match_fail(lex_match_nested_comment, '#|comment #|nested improperly|#', lex_rule_nested_comment)

    check_match(lex_match_nested_comment, '#||#', lex_rule_nested_comment)
    check_match(lex_match_nested_comment, '#|comment #|nested|# properly|#', lex_rule_nested_comment)
    check_match(lex_match_nested_comment, '#|multiline comment \n #|nested|# \n properly|#', lex_rule_nested_comment)
    check_match(lex_match_nested_comment, '#|foo|#1', lex_rule_nested_comment, expected_end=-1)

def test_lex_match_begin_nested_comment():
    init_test()

    check_match_fail(lex_match_begin_nested_comment, '', lex_rule_begin_nested_comment)
    check_match_fail(lex_match_begin_nested_comment, '#', lex_rule_begin_nested_comment)

    check_match(lex_match_begin_nested_comment, '#|', lex_rule_begin_nested_comment)

def test_lex_match_end_nested_comment():
    init_test()

    check_match_fail(lex_match_end_nested_comment, '', lex_rule_end_nested_comment)
    check_match_fail(lex_match_end_nested_comment, '|', lex_rule_end_nested_comment)

    check_match(lex_match_end_nested_comment, '|#', lex_rule_end_nested_comment)

def test_lex_match_comment_text():
    init_test()

    check_match_fail(lex_match_comment_text, '', lex_rule_comment_text)

    check_match(lex_match_comment_text, '|#', lex_rule_comment_text, expected_end=0)
    check_match(lex_match_comment_text, '1|#', lex_rule_comment_text, expected_end=1)
    check_match(lex_match_comment_text, '||#', lex_rule_comment_text, expected_end=1)
    check_match(lex_match_comment_text, '1#|', lex_rule_comment_text, expected_end=1)
    check_match(lex_match_comment_text, '##|', lex_rule_comment_text, expected_end=1)

def test_lex_match_nested_comment_delimiters():
    init_test()

    check_match_fail(lex_match_nested_comment_delimiters, '', lex_rule_nested_comment_delimiters)
    check_match_fail(lex_match_nested_comment_delimiters, '#', lex_rule_nested_comment_delimiters)
    check_match_fail(lex_match_nested_comment_delimiters, '|', lex_rule_nested_comment_delimiters)

    check_match(lex_match_nested_comment_delimiters, '|#', lex_rule_nested_comment_delimiters)
    check_match(lex_match_nested_comment_delimiters, '#|', lex_rule_nested_comment_delimiters)

def test_lex_match_directive():
    init_test()

    check_match_fail(lex_match_directive, '', lex_rule_directive)

    check_match(lex_match_directive, '#!fold-case',    lex_rule_directive)
    check_match(lex_match_directive, '#!no-fold-case', lex_rule_directive)

def test_lex_match_atmosphere():
    init_test()

    check_match_fail(lex_match_atmosphere, '', lex_rule_atmosphere)

    check_match(lex_match_atmosphere, '#!fold-case',    lex_rule_directive)
    check_match(lex_match_atmosphere, '#!no-fold-case', lex_rule_directive)
    check_match(lex_match_atmosphere, ' ',              lex_rule_intraline_whitespace)
    check_match(lex_match_atmosphere, '\t',             lex_rule_intraline_whitespace)
    check_match(lex_match_atmosphere, '\n',             lex_rule_line_ending_char)
    check_match(lex_match_atmosphere, '\r',             lex_rule_line_ending_char)
    check_match(lex_match_atmosphere, '\r\n',           lex_rule_dos_line_ending)
    check_match(lex_match_atmosphere, '#||#',           lex_rule_nested_comment)
    check_match(lex_match_atmosphere, ';comment\n',     lex_rule_simple_comment, expected_end=-1)

def test_lex_match_identifier():
    init_test()

    check_match_fail(lex_match_identifier, '',  lex_rule_identifier)
    check_match_fail(lex_match_identifier, '0', lex_rule_identifier)

    check_match(lex_match_identifier, 'a',    lex_rule_ordinary_identifier)
    check_match(lex_match_identifier, 'Z',    lex_rule_ordinary_identifier)
    check_match(lex_match_identifier, 'eq!?', lex_rule_ordinary_identifier)
    check_match(lex_match_identifier, 'B-52', lex_rule_ordinary_identifier)

    check_match(lex_match_identifier, '||',                 lex_rule_vertical_line_quoted_symbol)
    check_match(lex_match_identifier, r'|\||',              lex_rule_vertical_line_quoted_symbol)
    check_match(lex_match_identifier, r'|\a\b\n\r\t|',      lex_rule_vertical_line_quoted_symbol)
    check_match(lex_match_identifier, r'|\xbeef;|',         lex_rule_vertical_line_quoted_symbol)
    check_match(lex_match_identifier, '|foo \n bar|',       lex_rule_vertical_line_quoted_symbol)
    check_match(lex_match_identifier, '|dos foo \r\n bar|', lex_rule_vertical_line_quoted_symbol)

    check_match(lex_match_identifier, '+',    lex_rule_peculiar_identifier)
    check_match(lex_match_identifier, '-',    lex_rule_peculiar_identifier)
    check_match(lex_match_identifier, '-?!A', lex_rule_peculiar_identifier)
    check_match(lex_match_identifier, '...',  lex_rule_peculiar_identifier)

def test_lex_match_ordinary_identifier():
    init_test()

    check_match_fail(lex_match_ordinary_identifier, '', lex_rule_ordinary_identifier)

    for b0 in range(32, 128):
        c0 = chr(b0)
        s = c0
        if c0 in '!$%^&*/:<=>?_~ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz':
            check_match(lex_match_ordinary_identifier, s, lex_rule_ordinary_identifier)

            for b1 in range(32, 128):
                c1 = chr(b1)
                s = c0 + c1
                if c1 in '0123456789.!@$%^&*/+-:<=>?_~ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz':
                    check_match(lex_match_ordinary_identifier, s, lex_rule_ordinary_identifier)
                else:
                    check_match(lex_match_ordinary_identifier, s, lex_rule_ordinary_identifier, expected_end=1)

        else:
            check_match_fail(lex_match_ordinary_identifier, s, lex_rule_ordinary_identifier)

def test_lex_match_vertical_line_quoted_symbol():
    init_test()

    check_match_fail(lex_match_vertical_line_quoted_symbol, '', lex_rule_vertical_line_quoted_symbol)

    check_match(lex_match_vertical_line_quoted_symbol, '||',                 lex_rule_vertical_line_quoted_symbol)
    check_match(lex_match_vertical_line_quoted_symbol, r'|\||',              lex_rule_vertical_line_quoted_symbol)
    check_match(lex_match_vertical_line_quoted_symbol, r'|\a\b\n\r\t|',      lex_rule_vertical_line_quoted_symbol)
    check_match(lex_match_vertical_line_quoted_symbol, r'|\xbeef;|',         lex_rule_vertical_line_quoted_symbol)
    check_match(lex_match_vertical_line_quoted_symbol, '|foo \n bar|',       lex_rule_vertical_line_quoted_symbol)
    check_match(lex_match_vertical_line_quoted_symbol, '|dos foo \r\n bar|', lex_rule_vertical_line_quoted_symbol)

def test_lex_match_initial():
    init_test()

    check_match_fail(lex_match_initial, '', lex_rule_initial)

    for b in range(32, 128):
        c = chr(b)
        if c in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ':
            check_match(lex_match_initial, c, lex_rule_uppercase_letter)
        elif c in 'abcdefghijklmnopqrstuvwxyz':
            check_match(lex_match_initial, c, lex_rule_lowercase_letter)
        elif c in '!$%&*/:<=>?^_~':
            check_match(lex_match_initial, c, lex_rule_special_initial)
        else:
            check_match_fail(lex_match_initial, c, lex_rule_initial)

def test_lex_match_subsequent():
    init_test()

    check_match_fail(lex_match_subsequent, '', lex_rule_subsequent)

    for b in range(32, 128):
        c = chr(b)
        if c in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ':
            check_match(lex_match_subsequent, c, lex_rule_uppercase_letter)
        elif c in 'abcdefghijklmnopqrstuvwxyz':
            check_match(lex_match_subsequent, c, lex_rule_lowercase_letter)
        elif c in '!$%&*/:<=>?^_~':
            check_match(lex_match_initial, c, lex_rule_special_initial)
        elif c in '0123456789':
            check_match(lex_match_subsequent, c, lex_rule_digit)
        elif c in '+-.@':
            check_match(lex_match_subsequent, c, lex_rule_special_subsequent)
        else:
            check_match_fail(lex_match_subsequent, c, lex_rule_subsequent)

def test_lex_match_explicit_sign():

    check_match_fail(lex_match_explicit_sign, '', lex_rule_explicit_sign)

    for b in range(32, 128):
        c = chr(b)
        if c in '+-':
            check_match(lex_match_explicit_sign, c, lex_rule_explicit_sign)
        else:
            check_match_fail(lex_match_explicit_sign, c, lex_rule_explicit_sign)

def test_lex_match_special_subsequent():
    init_test()

    check_match_fail(lex_match_special_subsequent, '', lex_rule_special_subsequent)

    for b in range(32, 128):
        c = chr(b)
        if c in '+-.@':
            check_match(lex_match_special_subsequent, c, lex_rule_special_subsequent)
        else:
            check_match_fail(lex_match_special_subsequent, c, lex_rule_special_subsequent)

def test_lex_match_inline_hex_escape():
    init_test()

    check_match_fail(lex_match_inline_hex_escape, '',       lex_rule_inline_hex_escape)
    check_match_fail(lex_match_inline_hex_escape, '\\',     lex_rule_inline_hex_escape)
    check_match_fail(lex_match_inline_hex_escape, '\\x',    lex_rule_inline_hex_escape)
    check_match_fail(lex_match_inline_hex_escape, '\\x00',  lex_rule_inline_hex_escape)
    check_match_fail(lex_match_inline_hex_escape, '\\x00 ', lex_rule_inline_hex_escape)

    check_match(lex_match_inline_hex_escape, '\\x00;', lex_rule_inline_hex_escape)
    check_match(lex_match_inline_hex_escape, '\\xff;', lex_rule_inline_hex_escape)
    check_match(lex_match_inline_hex_escape, '\\x1;',  lex_rule_inline_hex_escape)

    check_match(lex_match_inline_hex_escape, '\\x' + hex_digits + ';', lex_rule_inline_hex_escape)

def test_lex_match_mnemonic_escape():
    init_test()

    check_match_fail(lex_match_mnemonic_escape, '',  lex_rule_mnemonic_escape)
    check_match_fail(lex_match_mnemonic_escape, '\\', lex_rule_mnemonic_escape)

    for b in range(32, 128):
        c = chr(b)
        s = f'\\{c}'
        if c in 'abnrt':
            check_match(lex_match_mnemonic_escape, s, lex_rule_mnemonic_escape)
        else:
            check_match_fail(lex_match_mnemonic_escape, c, lex_rule_mnemonic_escape)

def test_lex_match_peculiar_identifier():
    init_test()

    check_match_fail(lex_match_peculiar_identifier, '', lex_rule_peculiar_identifier)

    check_match(lex_match_peculiar_identifier, '+', lex_rule_peculiar_identifier)
    check_match(lex_match_peculiar_identifier, '-', lex_rule_peculiar_identifier)

    for sign in '+-':
        for b0 in range(32, 128):
            c0 = chr(b0)
            s = sign + c0
            if c0 in '!@$%^&*/+-:<=>?_~ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz':
                check_match(lex_match_peculiar_identifier, s, lex_rule_peculiar_identifier)

                for b1 in range(32, 128):
                    c1 = chr(b1)
                    s = sign + c0 + c1
                    if c1 in '0123456789.!@$%^&*/+-:<=>?_~ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz':
                        check_match(lex_match_peculiar_identifier, s, lex_rule_peculiar_identifier)
                    else:
                        check_match(lex_match_peculiar_identifier, s, lex_rule_peculiar_identifier, expected_end=2)

            else:
                check_match(lex_match_peculiar_identifier, s, lex_rule_peculiar_identifier, expected_end=1)

    for sign in '+-':
        for b0 in range(32, 128):
            c0 = chr(b0)
            s = sign + '.' + c0
            if c0 in '.!@$%^&*/+-:<=>?_~ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz':
                check_match(lex_match_peculiar_identifier, s, lex_rule_peculiar_identifier)

                for b1 in range(32, 128):
                    c1 = chr(b1)
                    s = sign + '.' + c0 + c1
                    if c1 in '0123456789.!@$%^&*/+-:<=>?_~ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz':
                        check_match(lex_match_peculiar_identifier, s, lex_rule_peculiar_identifier)
                    else:
                        check_match(lex_match_peculiar_identifier, s, lex_rule_peculiar_identifier, expected_end=3)

            else:
                check_match(lex_match_peculiar_identifier, s, lex_rule_peculiar_identifier, expected_end=1)

    for b0 in range(32, 128):
        c0 = chr(b0)
        s = '.' + c0
        if c0 in '.!@$%^&*/+-:<=>?_~ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz':
            check_match(lex_match_peculiar_identifier, s, lex_rule_peculiar_identifier)

            for b1 in range(32, 128):
                c1 = chr(b1)
                s = '.' + c0 + c1
                if c1 in '0123456789.!@$%^&*/+-:<=>?_~ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz':
                    check_match(lex_match_peculiar_identifier, s, lex_rule_peculiar_identifier)
                else:
                    check_match(lex_match_peculiar_identifier, s, lex_rule_peculiar_identifier, expected_end=2)

        else:
            check_match_fail(lex_match_peculiar_identifier, s, lex_rule_peculiar_identifier)

def test_lex_match_at_sign():

    check_match_fail(lex_match_at_sign, '', lex_rule_at_sign)

    for b in range(32, 128):
        c = chr(b)
        if c in '@':
            check_match(lex_match_at_sign, c, lex_rule_at_sign)
        else:
            check_match_fail(lex_match_at_sign, c, lex_rule_at_sign)

def test_lex_match_symbol_element():
    init_test()

    check_match_fail(lex_match_symbol_element, '',   lex_rule_symbol_element)
    check_match_fail(lex_match_symbol_element, '|',  lex_rule_symbol_element)
    check_match_fail(lex_match_symbol_element, '\\', lex_rule_symbol_element)

    check_match(lex_match_symbol_element, r'\xabcd;', lex_rule_inline_hex_escape)

    for c in 'abnrt':
        s = f'\\{c}'
        check_match(lex_match_symbol_element, s, lex_rule_mnemonic_escape)

    check_match(lex_match_symbol_element, '\\|', lex_rule_escaped_vertical_line)

def test_lex_match_boolean():
    init_test()

    check_match_fail(lex_match_boolean, '', lex_rule_boolean)

    check_match(lex_match_boolean, '#f',     lex_rule_boolean)
    check_match(lex_match_boolean, '#false', lex_rule_boolean)
    check_match(lex_match_boolean, '#t',     lex_rule_boolean)
    check_match(lex_match_boolean, '#true',  lex_rule_boolean)

def test_lex_match_character():
    init_test()

    check_match_fail(lex_match_character, '', lex_rule_character)

    check_match(lex_match_character, r'#\ ',         lex_rule_escaped_character)
    check_match(lex_match_character, r'#\a',         lex_rule_escaped_character)
    check_match(lex_match_character, r'#\alarm',     lex_rule_named_character)
    check_match(lex_match_character, r'#\backspace', lex_rule_named_character)
    check_match(lex_match_character, r'#\delete',    lex_rule_named_character)
    check_match(lex_match_character, r'#\escape',    lex_rule_named_character)
    check_match(lex_match_character, r'#\newline',   lex_rule_named_character)
    check_match(lex_match_character, r'#\null',      lex_rule_named_character)
    check_match(lex_match_character, r'#\return',    lex_rule_named_character)
    check_match(lex_match_character, r'#\space',     lex_rule_named_character)
    check_match(lex_match_character, r'#\tab',       lex_rule_named_character)
    check_match(lex_match_character, r'#\xb00;',     lex_rule_escaped_character_hex)

def test_lex_match_named_character():
    init_test()

    check_match_fail(lex_match_named_character, '', lex_rule_named_character)

    check_match(lex_match_named_character, r'#\alarm',     lex_rule_named_character)
    check_match(lex_match_named_character, r'#\backspace', lex_rule_named_character)
    check_match(lex_match_named_character, r'#\delete',    lex_rule_named_character)
    check_match(lex_match_named_character, r'#\escape',    lex_rule_named_character)
    check_match(lex_match_named_character, r'#\newline',   lex_rule_named_character)
    check_match(lex_match_named_character, r'#\null',      lex_rule_named_character)
    check_match(lex_match_named_character, r'#\return',    lex_rule_named_character)
    check_match(lex_match_named_character, r'#\space',     lex_rule_named_character)
    check_match(lex_match_named_character, r'#\tab',       lex_rule_named_character)

def test_lex_match_escaped_character_hex():
    init_test()

    check_match_fail(lex_match_escaped_character_hex, '', lex_rule_escaped_character_hex)

    check_match(lex_match_escaped_character_hex, r'#\xb00;', lex_rule_escaped_character_hex)

def test_lex_match_character_name():
    init_test()

    check_match_fail(lex_match_character_name, '', lex_rule_character_name)

    check_match(lex_match_character_name, 'alarm',     lex_rule_character_name)
    check_match(lex_match_character_name, 'backspace', lex_rule_character_name)
    check_match(lex_match_character_name, 'delete',    lex_rule_character_name)
    check_match(lex_match_character_name, 'escape',    lex_rule_character_name)
    check_match(lex_match_character_name, 'newline',   lex_rule_character_name)
    check_match(lex_match_character_name, 'null',      lex_rule_character_name)
    check_match(lex_match_character_name, 'return',    lex_rule_character_name)
    check_match(lex_match_character_name, 'space',     lex_rule_character_name)
    check_match(lex_match_character_name, 'tab',       lex_rule_character_name)

def test_lex_match_quoted_string():
    init_test()

    check_match_fail(lex_match_quoted_string, '', lex_rule_quoted_string)

    check_match(lex_match_quoted_string, '""',                 lex_rule_quoted_string)
    check_match(lex_match_quoted_string, r'"\""',              lex_rule_quoted_string)
    check_match(lex_match_quoted_string, r'"\a\b\n\r\t\\"',    lex_rule_quoted_string)
    check_match(lex_match_quoted_string, r'"\xbeef;"',         lex_rule_quoted_string)
    check_match(lex_match_quoted_string, '"foo \\ \n bar"',    lex_rule_quoted_string)
    check_match(lex_match_quoted_string, '"dos foo \r\n bar"', lex_rule_quoted_string)

def test_lex_match_string_element():
    init_test()

    check_match_fail(lex_match_string_element, '',  lex_rule_string_element)
    check_match_fail(lex_match_string_element, '"', lex_rule_string_element)

    for b in range(32, 128):
        c = chr(b)
        if c not in '\\"':
            check_match(lex_match_string_element, c, lex_rule_string_element_character)

    for c in 'abnrt':
        s = f'\\{c}'
        check_match(lex_match_string_element, s, lex_rule_mnemonic_escape)

    check_match(lex_match_string_element, r'\"',       lex_rule_escaped_double_quote)
    check_match(lex_match_string_element, r'\\',       lex_rule_escaped_backslash)
    check_match(lex_match_string_element, '\\\n',      lex_rule_escaped_line_ending)
    check_match(lex_match_string_element, '\\ \n\t\t', lex_rule_escaped_line_ending)
    check_match(lex_match_string_element, r'\xabcd;',  lex_rule_inline_hex_escape)

def test_lex_match_string_element_character():
    init_test()

    check_match_fail(lex_match_string_element_character, '', lex_rule_string_element_character)

    for b in range(32, 128):
        c = chr(b)
        if c in '\\"':
            check_match_fail(lex_match_string_element_character, c, lex_rule_string_element_character)

        else:
            check_match(lex_match_string_element_character, c, lex_rule_string_element_character)

    check_match(lex_match_string_element_character, 'λ', lex_rule_string_element_character)

def test_lex_match_string_element_character_escape():
    init_test()

    check_match_fail(lex_match_string_element_character_escape, '', lex_rule_string_element_character_escape)

    for b in range(32, 128):
        c = chr(b)
        s = f'\\{c}'
        if c in 'abnrt':
            check_match(lex_match_string_element_character_escape, s, lex_rule_mnemonic_escape)

        elif c == '"':
            check_match(lex_match_string_element_character_escape, s, lex_rule_escaped_double_quote)

        elif c == '\\':
            check_match(lex_match_string_element_character_escape, s, lex_rule_escaped_backslash)

        else:
            check_match_fail(lex_match_string_element_character_escape, s, lex_rule_string_element_character_escape)

def test_lex_match_escaped_line_ending():
    init_test()

    check_match_fail(lex_match_escaped_line_ending, '\\ ', lex_rule_escaped_line_ending)

    check_match(lex_match_escaped_line_ending, '\\\n',      lex_rule_escaped_line_ending)
    check_match(lex_match_escaped_line_ending, '\\ \n\t\t', lex_rule_escaped_line_ending)

def test_lex_match_number():
    init_test()

    check_match_fail(lex_match_number, '', lex_rule_number)

    check_match(lex_match_number, '#x1', lex_rule_num_16)
    check_match(lex_match_number, '1',   lex_rule_num_10)
    check_match(lex_match_number, '#d1', lex_rule_num_10)
    check_match(lex_match_number, '#o1', lex_rule_num_8)
    check_match(lex_match_number, '#b1', lex_rule_num_2)

def test_lex_match_num_16():
    init_test()

    check_match_fail(lex_match_num_16, '', lex_rule_num_16)

    check_match_fail(lex_match_num_16, '1',        lex_rule_num_16)
    check_match_fail(lex_match_num_16, '1/10',     lex_rule_num_16)
    check_match_fail(lex_match_num_16, '-111',     lex_rule_num_16)
    check_match_fail(lex_match_num_16, '+inf.0',   lex_rule_num_16)
    check_match_fail(lex_match_num_16, '1@1/10',   lex_rule_num_16)
    check_match_fail(lex_match_num_16, '1+Inf.0i', lex_rule_num_16)
    check_match_fail(lex_match_num_16, '1+10i',    lex_rule_num_16)
    check_match_fail(lex_match_num_16, '1+i',      lex_rule_num_16)
    check_match_fail(lex_match_num_16, '+1i',      lex_rule_num_16)
    check_match_fail(lex_match_num_16, '+i',       lex_rule_num_16)
    check_match_fail(lex_match_num_16, '+inf.0i',  lex_rule_num_16)

    check_match(lex_match_num_16, '#x1',        lex_rule_num_16)
    check_match(lex_match_num_16, '#x1/10',     lex_rule_num_16)
    check_match(lex_match_num_16, '#x-111',     lex_rule_num_16)
    check_match(lex_match_num_16, '#x+inf.0',   lex_rule_num_16)
    check_match(lex_match_num_16, '#x1@1/10',   lex_rule_num_16)
    check_match(lex_match_num_16, '#x1+Inf.0i', lex_rule_num_16)
    check_match(lex_match_num_16, '#x1+10i',    lex_rule_num_16)
    check_match(lex_match_num_16, '#x1+i',      lex_rule_num_16)
    check_match(lex_match_num_16, '#x+1i',      lex_rule_num_16)
    check_match(lex_match_num_16, '#x+i',       lex_rule_num_16)
    check_match(lex_match_num_16, '#x+inf.0i',  lex_rule_num_16)

def test_lex_match_num_10():
    init_test()

    check_match_fail(lex_match_num_10, '', lex_rule_num_10)

    check_match(lex_match_num_10, '1',        lex_rule_num_10)
    check_match(lex_match_num_10, '1/10',     lex_rule_num_10)
    check_match(lex_match_num_10, '-111',     lex_rule_num_10)
    check_match(lex_match_num_10, '3.14',     lex_rule_num_10)
    check_match(lex_match_num_10, '6.02e+23', lex_rule_num_10)
    check_match(lex_match_num_10, '+inf.0',   lex_rule_num_10)
    check_match(lex_match_num_10, '1@1/10',   lex_rule_num_10)
    check_match(lex_match_num_10, '1+Inf.0i', lex_rule_num_10)
    check_match(lex_match_num_10, '1+10i',    lex_rule_num_10)
    check_match(lex_match_num_10, '1+i',      lex_rule_num_10)
    check_match(lex_match_num_10, '+1i',      lex_rule_num_10)
    check_match(lex_match_num_10, '+i',       lex_rule_num_10)
    check_match(lex_match_num_10, '+inf.0i',  lex_rule_num_10)

    check_match(lex_match_num_10, '#d1',        lex_rule_num_10)
    check_match(lex_match_num_10, '#d1/10',     lex_rule_num_10)
    check_match(lex_match_num_10, '#d-111',     lex_rule_num_10)
    check_match(lex_match_num_10, '#d3.14',     lex_rule_num_10)
    check_match(lex_match_num_10, '#d6.02e+23', lex_rule_num_10)
    check_match(lex_match_num_10, '#d+inf.0',   lex_rule_num_10)
    check_match(lex_match_num_10, '#d1@1/10',   lex_rule_num_10)
    check_match(lex_match_num_10, '#d1+Inf.0i', lex_rule_num_10)
    check_match(lex_match_num_10, '#d1+10i',    lex_rule_num_10)
    check_match(lex_match_num_10, '#d1+i',      lex_rule_num_10)
    check_match(lex_match_num_10, '#d+1i',      lex_rule_num_10)
    check_match(lex_match_num_10, '#d+i',       lex_rule_num_10)
    check_match(lex_match_num_10, '#d+inf.0i',  lex_rule_num_10)

def test_lex_match_num_8():
    init_test()

    check_match_fail(lex_match_num_8, '', lex_rule_num_8)

    check_match_fail(lex_match_num_8, '1',        lex_rule_num_8)
    check_match_fail(lex_match_num_8, '1/10',     lex_rule_num_8)
    check_match_fail(lex_match_num_8, '-111',     lex_rule_num_8)
    check_match_fail(lex_match_num_8, '+inf.0',   lex_rule_num_8)
    check_match_fail(lex_match_num_8, '1@1/10',   lex_rule_num_8)
    check_match_fail(lex_match_num_8, '1+Inf.0i', lex_rule_num_8)
    check_match_fail(lex_match_num_8, '1+10i',    lex_rule_num_8)
    check_match_fail(lex_match_num_8, '1+i',      lex_rule_num_8)
    check_match_fail(lex_match_num_8, '+1i',      lex_rule_num_8)
    check_match_fail(lex_match_num_8, '+i',       lex_rule_num_8)
    check_match_fail(lex_match_num_8, '+inf.0i',  lex_rule_num_8)

    check_match(lex_match_num_8, '#o1',        lex_rule_num_8)
    check_match(lex_match_num_8, '#o1/10',     lex_rule_num_8)
    check_match(lex_match_num_8, '#o-111',     lex_rule_num_8)
    check_match(lex_match_num_8, '#o+inf.0',   lex_rule_num_8)
    check_match(lex_match_num_8, '#o1@1/10',   lex_rule_num_8)
    check_match(lex_match_num_8, '#o1+Inf.0i', lex_rule_num_8)
    check_match(lex_match_num_8, '#o1+10i',    lex_rule_num_8)
    check_match(lex_match_num_8, '#o1+i',      lex_rule_num_8)
    check_match(lex_match_num_8, '#o+1i',      lex_rule_num_8)
    check_match(lex_match_num_8, '#o+i',       lex_rule_num_8)
    check_match(lex_match_num_8, '#o+inf.0i',  lex_rule_num_8)

def test_lex_match_num_2():
    init_test()

    check_match_fail(lex_match_num_2, '', lex_rule_num_2)

    check_match_fail(lex_match_num_2, '1',        lex_rule_num_2)
    check_match_fail(lex_match_num_2, '1/10',     lex_rule_num_2)
    check_match_fail(lex_match_num_2, '-111',     lex_rule_num_2)
    check_match_fail(lex_match_num_2, '+inf.0',   lex_rule_num_2)
    check_match_fail(lex_match_num_2, '1@1/10',   lex_rule_num_2)
    check_match_fail(lex_match_num_2, '1+Inf.0i', lex_rule_num_2)
    check_match_fail(lex_match_num_2, '1+10i',    lex_rule_num_2)
    check_match_fail(lex_match_num_2, '1+i',      lex_rule_num_2)
    check_match_fail(lex_match_num_2, '+1i',      lex_rule_num_2)
    check_match_fail(lex_match_num_2, '+i',       lex_rule_num_2)
    check_match_fail(lex_match_num_2, '+inf.0i',  lex_rule_num_2)

    check_match(lex_match_num_2, '#b1',        lex_rule_num_2)
    check_match(lex_match_num_2, '#b10',       lex_rule_num_2)
    check_match(lex_match_num_2, '#b-111',     lex_rule_num_2)
    check_match(lex_match_num_2, '#b+inf.0',   lex_rule_num_2)
    check_match(lex_match_num_2, '#b1@1/10',   lex_rule_num_2)
    check_match(lex_match_num_2, '#b+Inf.0i',  lex_rule_num_2)
    check_match(lex_match_num_2, '#b1+10i',    lex_rule_num_2)
    check_match(lex_match_num_2, '#b1+i',      lex_rule_num_2)
    check_match(lex_match_num_2, '#b+1i',      lex_rule_num_2)
    check_match(lex_match_num_2, '#b+i',       lex_rule_num_2)
    check_match(lex_match_num_2, '#b+inf.0i',  lex_rule_num_2)

def test_lex_match_complex_16():
    init_test()

    check_match_fail(lex_match_complex_16, '', lex_rule_complex_16)

    check_match(lex_match_complex_16, '1',        lex_rule_signed_real_16)
    check_match(lex_match_complex_16, '1/10',     lex_rule_signed_real_16)
    check_match(lex_match_complex_16, '-111',     lex_rule_signed_real_16)
    check_match(lex_match_complex_16, '+inf.0',   lex_rule_infnan)
    check_match(lex_match_complex_16, '1@1/10',   lex_rule_complex_polar_16)
    check_match(lex_match_complex_16, '1+Inf.0i', lex_rule_complex_infnan_im_16)
    check_match(lex_match_complex_16, '1+10i',    lex_rule_full_complex_16)
    check_match(lex_match_complex_16, '1+i',      lex_rule_complex_unit_im_16)
    check_match(lex_match_complex_16, '+1i',      lex_rule_complex_im_only_16)
    check_match(lex_match_complex_16, '+i',       lex_rule_unit_im)
    check_match(lex_match_complex_16, '+inf.0i',  lex_rule_infnan_im)

def test_lex_match_complex_10():
    init_test()

    check_match_fail(lex_match_complex_10, '', lex_rule_complex_10)

    check_match(lex_match_complex_10, '1',        lex_rule_signed_real_10)
    check_match(lex_match_complex_10, '1/10',     lex_rule_signed_real_10)
    check_match(lex_match_complex_10, '-111',     lex_rule_signed_real_10)
    check_match(lex_match_complex_10, '3.14',     lex_rule_signed_real_10)
    check_match(lex_match_complex_10, '6.02e+23', lex_rule_signed_real_10)
    check_match(lex_match_complex_10, '+inf.0',   lex_rule_infnan)
    check_match(lex_match_complex_10, '1@1/10',   lex_rule_complex_polar_10)
    check_match(lex_match_complex_10, '1+Inf.0i', lex_rule_complex_infnan_im_10)
    check_match(lex_match_complex_10, '1+10i',    lex_rule_full_complex_10)
    check_match(lex_match_complex_10, '1+i',      lex_rule_complex_unit_im_10)
    check_match(lex_match_complex_10, '+1i',      lex_rule_complex_im_only_10)
    check_match(lex_match_complex_10, '+i',       lex_rule_unit_im)
    check_match(lex_match_complex_10, '+inf.0i',  lex_rule_infnan_im)

def test_lex_match_complex_8():
    init_test()

    check_match_fail(lex_match_complex_8, '', lex_rule_complex_8)

    check_match(lex_match_complex_8, '1',        lex_rule_signed_real_8)
    check_match(lex_match_complex_8, '1/10',     lex_rule_signed_real_8)
    check_match(lex_match_complex_8, '-111',     lex_rule_signed_real_8)
    check_match(lex_match_complex_8, '+inf.0',   lex_rule_infnan)
    check_match(lex_match_complex_8, '1@1/10',   lex_rule_complex_polar_8)
    check_match(lex_match_complex_8, '1+Inf.0i', lex_rule_complex_infnan_im_8)
    check_match(lex_match_complex_8, '1+10i',    lex_rule_full_complex_8)
    check_match(lex_match_complex_8, '1+i',      lex_rule_complex_unit_im_8)
    check_match(lex_match_complex_8, '+1i',      lex_rule_complex_im_only_8)
    check_match(lex_match_complex_8, '+i',       lex_rule_unit_im)
    check_match(lex_match_complex_8, '+inf.0i',  lex_rule_infnan_im)

def test_lex_match_complex_2():
    init_test()

    check_match_fail(lex_match_complex_2, '', lex_rule_complex_2)

    check_match(lex_match_complex_2, '1',        lex_rule_signed_real_2)
    check_match(lex_match_complex_2, '1/10',     lex_rule_signed_real_2)
    check_match(lex_match_complex_2, '-111',     lex_rule_signed_real_2)
    check_match(lex_match_complex_2, '+inf.0',   lex_rule_infnan)
    check_match(lex_match_complex_2, '1@1/10',   lex_rule_complex_polar_2)
    check_match(lex_match_complex_2, '1+Inf.0i', lex_rule_complex_infnan_im_2)
    check_match(lex_match_complex_2, '1+10i',    lex_rule_full_complex_2)
    check_match(lex_match_complex_2, '1+i',      lex_rule_complex_unit_im_2)
    check_match(lex_match_complex_2, '+1i',      lex_rule_complex_im_only_2)
    check_match(lex_match_complex_2, '+i',       lex_rule_unit_im)
    check_match(lex_match_complex_2, '+inf.0i',  lex_rule_infnan_im)

def test_lex_match_unit_im():
    init_test()

    check_match_fail(lex_match_unit_im, '', lex_rule_unit_im)

    for v in ('+I', '+i', '-I', '-i'):
        check_match(lex_match_unit_im, v, lex_rule_unit_im)

def test_lex_match_infnan_im():
    init_test()

    check_match_fail(lex_match_infnan_im, '', lex_rule_infnan_im)
    check_match_fail(lex_match_infnan_im, '+inf.0', lex_rule_infnan_im)

    for v in ('+Inf.0i', '+NaN.0I', '-Inf.0I', '-NaN.0i'):
        check_match(lex_match_infnan_im, v, lex_rule_infnan_im)
        check_match(lex_match_infnan_im, v.upper(), lex_rule_infnan_im)
        check_match(lex_match_infnan_im, v.lower(), lex_rule_infnan_im)

def test_lex_match_complex_polar_16():
    init_test()

    check_match_fail(lex_match_complex_polar_16, '', lex_rule_complex_polar_16)

    check_match(lex_match_complex_polar_16, '1@1/10', lex_rule_complex_polar_16)

def test_lex_match_complex_polar_10():
    init_test()

    check_match_fail(lex_match_complex_polar_10, '', lex_rule_complex_polar_10)

    check_match(lex_match_complex_polar_10, '1@1/10', lex_rule_complex_polar_10)

def test_lex_match_complex_polar_8():
    init_test()

    check_match_fail(lex_match_complex_polar_8, '', lex_rule_complex_polar_8)

    check_match(lex_match_complex_polar_8, '1@1/10', lex_rule_complex_polar_8)

def test_lex_match_complex_polar_2():
    init_test()

    check_match_fail(lex_match_complex_polar_2, '', lex_rule_complex_polar_2)

    check_match(lex_match_complex_polar_2, '1@1/10', lex_rule_complex_polar_2)

def test_lex_match_complex_infnan_im_16():
    init_test()

    check_match_fail(lex_match_complex_infnan_im_16, '', lex_rule_complex_infnan_im_16)

    check_match(lex_match_complex_infnan_im_16, '1+Inf.0i', lex_rule_complex_infnan_im_16)
    check_match(lex_match_complex_infnan_im_16, '+11-NaN.0i', lex_rule_complex_infnan_im_16)

def test_lex_match_complex_infnan_im_10():
    init_test()

    check_match_fail(lex_match_complex_infnan_im_10, '', lex_rule_complex_infnan_im_10)

    check_match(lex_match_complex_infnan_im_10, '1+Inf.0i', lex_rule_complex_infnan_im_10)
    check_match(lex_match_complex_infnan_im_10, '+11-NaN.0i', lex_rule_complex_infnan_im_10)

def test_lex_match_complex_infnan_im_8():
    init_test()

    check_match_fail(lex_match_complex_infnan_im_8, '', lex_rule_complex_infnan_im_8)

    check_match(lex_match_complex_infnan_im_8, '1+Inf.0i', lex_rule_complex_infnan_im_8)
    check_match(lex_match_complex_infnan_im_8, '+11-NaN.0i', lex_rule_complex_infnan_im_8)

def test_lex_match_complex_infnan_im_2():
    init_test()

    check_match_fail(lex_match_complex_infnan_im_2, '', lex_rule_complex_infnan_im_2)

    check_match(lex_match_complex_infnan_im_2, '1+Inf.0i', lex_rule_complex_infnan_im_2)
    check_match(lex_match_complex_infnan_im_2, '+11-NaN.0i', lex_rule_complex_infnan_im_2)

def test_lex_match_full_complex_16():
    init_test()

    check_match_fail(lex_match_full_complex_16, '', lex_rule_full_complex_16)

    check_match(lex_match_full_complex_16, '1+10i', lex_rule_full_complex_16)
    check_match(lex_match_full_complex_16, '+11-101I', lex_rule_full_complex_16)

def test_lex_match_full_complex_10():
    init_test()

    check_match_fail(lex_match_full_complex_10, '', lex_rule_full_complex_10)

    check_match(lex_match_full_complex_10, '1+10i', lex_rule_full_complex_10)
    check_match(lex_match_full_complex_10, '+11-101I', lex_rule_full_complex_10)

def test_lex_match_full_complex_8():
    init_test()

    check_match_fail(lex_match_full_complex_8, '', lex_rule_full_complex_8)

    check_match(lex_match_full_complex_8, '1+10i', lex_rule_full_complex_8)
    check_match(lex_match_full_complex_8, '+11-101I', lex_rule_full_complex_8)

def test_lex_match_full_complex_2():
    init_test()

    check_match_fail(lex_match_full_complex_2, '', lex_rule_full_complex_2)

    check_match(lex_match_full_complex_2, '1+10i', lex_rule_full_complex_2)
    check_match(lex_match_full_complex_2, '+11-101I', lex_rule_full_complex_2)

def test_lex_match_complex_unit_im_16():
    init_test()

    check_match_fail(lex_match_complex_unit_im_16, '', lex_rule_complex_unit_im_16)

    check_match(lex_match_complex_unit_im_16, '1+i', lex_rule_complex_unit_im_16)
    check_match(lex_match_complex_unit_im_16, '+11-I', lex_rule_complex_unit_im_16)

def test_lex_match_complex_unit_im_10():
    init_test()

    check_match_fail(lex_match_complex_unit_im_10, '', lex_rule_complex_unit_im_10)

    check_match(lex_match_complex_unit_im_10, '1+i', lex_rule_complex_unit_im_10)
    check_match(lex_match_complex_unit_im_10, '+11-I', lex_rule_complex_unit_im_10)

def test_lex_match_complex_unit_im_8():
    init_test()

    check_match_fail(lex_match_complex_unit_im_8, '', lex_rule_complex_unit_im_8)

    check_match(lex_match_complex_unit_im_8, '1+i', lex_rule_complex_unit_im_8)
    check_match(lex_match_complex_unit_im_8, '+11-I', lex_rule_complex_unit_im_8)

def test_lex_match_complex_unit_im_2():
    init_test()

    check_match_fail(lex_match_complex_unit_im_2, '', lex_rule_complex_unit_im_2)

    check_match(lex_match_complex_unit_im_2, '1+i', lex_rule_complex_unit_im_2)
    check_match(lex_match_complex_unit_im_2, '+11-I', lex_rule_complex_unit_im_2)

def test_lex_match_complex_im_only_16():
    init_test()

    check_match_fail(lex_match_complex_im_only_16, '', lex_rule_complex_im_only_16)

    check_match(lex_match_complex_im_only_16, '+1i', lex_rule_complex_im_only_16)
    check_match(lex_match_complex_im_only_16, '-11I', lex_rule_complex_im_only_16)

def test_lex_match_complex_im_only_10():
    init_test()

    check_match_fail(lex_match_complex_im_only_10, '', lex_rule_complex_im_only_10)

    check_match(lex_match_complex_im_only_10, '+1i', lex_rule_complex_im_only_10)
    check_match(lex_match_complex_im_only_10, '-11I', lex_rule_complex_im_only_10)

def test_lex_match_complex_im_only_8():
    init_test()

    check_match_fail(lex_match_complex_im_only_8, '', lex_rule_complex_im_only_8)

    check_match(lex_match_complex_im_only_8, '+1i', lex_rule_complex_im_only_8)
    check_match(lex_match_complex_im_only_8, '-11I', lex_rule_complex_im_only_8)

def test_lex_match_complex_im_only_2():
    init_test()

    check_match_fail(lex_match_complex_im_only_2, '', lex_rule_complex_im_only_2)

    check_match(lex_match_complex_im_only_2, '+1i', lex_rule_complex_im_only_2)
    check_match(lex_match_complex_im_only_2, '-11I', lex_rule_complex_im_only_2)

def test_lex_match_real_16():
    init_test()

    check_match_fail(lex_match_real_16, '', lex_rule_real_16)

    check_match(lex_match_real_16, '1', lex_rule_signed_real_16)
    check_match(lex_match_real_16, '+inf.0', lex_rule_infnan)

def test_lex_match_real_10():
    init_test()

    check_match_fail(lex_match_real_10, '', lex_rule_real_10)

    check_match(lex_match_real_10, '1', lex_rule_signed_real_10)
    check_match(lex_match_real_10, '+inf.0', lex_rule_infnan)

def test_lex_match_real_8():
    init_test()

    check_match_fail(lex_match_real_8, '', lex_rule_real_8)

    check_match(lex_match_real_8, '1', lex_rule_signed_real_8)
    check_match(lex_match_real_8, '+inf.0', lex_rule_infnan)

def test_lex_match_real_2():
    init_test()

    check_match_fail(lex_match_real_2, '', lex_rule_real_2)

    check_match(lex_match_real_2, '1', lex_rule_signed_real_2)
    check_match(lex_match_real_2, '+inf.0', lex_rule_infnan)

def test_lex_match_signed_real_16():
    init_test()

    check_match_fail(lex_match_signed_real_16, '', lex_rule_signed_real_16)

    for src in (hex_digits, '+' + hex_digits, '-' + hex_digits + '/' + hex_digits[::-1]):
        check_match(lex_match_signed_real_16, src, lex_rule_signed_real_16)

def test_lex_match_signed_real_10():
    init_test()

    check_match_fail(lex_match_signed_real_10, '', lex_rule_signed_real_10)

    check_match(lex_match_signed_real_10, '+3.14', lex_rule_signed_real_10)

    for src in (decimal_digits,
                '+' + decimal_digits,
                '-' + decimal_digits + '/' + decimal_digits[::-1]):
        check_match(lex_match_signed_real_10, src, lex_rule_signed_real_10)

def test_lex_match_signed_real_8():
    init_test()

    check_match_fail(lex_match_signed_real_8, '', lex_rule_signed_real_8)

    for src in (octal_digits,
                '+' + octal_digits,
                '-' + octal_digits + '/' + octal_digits[::-1]):
        check_match(lex_match_signed_real_8, src, lex_rule_signed_real_8)

def test_lex_match_signed_real_2():
    init_test()

    check_match_fail(lex_match_signed_real_2, '', lex_rule_signed_real_2)

    for src in (binary_digits,
                '+' + binary_digits,
                '-' + binary_digits + '/' + binary_digits[::-1]):
        check_match(lex_match_signed_real_2, src, lex_rule_signed_real_2)

def test_lex_match_ureal_16():
    init_test()

    check_match_fail(lex_match_ureal_16, '', lex_rule_ureal_16)

    check_match(lex_match_ureal_16, hex_digits + ' ', lex_rule_uinteger_16, expected_end=-1)
    check_match(lex_match_ureal_16, hex_digits + '/' + hex_digits, lex_rule_urational_16)

def test_lex_match_ureal_10():
    init_test()

    check_match_fail(lex_match_ureal_10, '', lex_rule_ureal_10)

    check_match(lex_match_ureal_10, '3.14', lex_rule_decimal_10)
    check_match(lex_match_ureal_10, decimal_digits + ' ', lex_rule_uinteger_10, expected_end=-1)
    check_match(lex_match_ureal_10, decimal_digits + '/' + decimal_digits, lex_rule_urational_10)

def test_lex_match_ureal_8():
    init_test()

    check_match_fail(lex_match_ureal_8, '', lex_rule_ureal_8)

    check_match(lex_match_ureal_8, octal_digits + ' ', lex_rule_uinteger_8, expected_end=-1)
    check_match(lex_match_ureal_8, octal_digits + '/' + octal_digits, lex_rule_urational_8)

def test_lex_match_ureal_2():
    init_test()

    check_match_fail(lex_match_ureal_2, '', lex_rule_ureal_2)

    check_match(lex_match_ureal_2, binary_digits + ' ', lex_rule_uinteger_2, expected_end=-1)
    check_match(lex_match_ureal_2, binary_digits + '/' + binary_digits, lex_rule_urational_2)

def test_lex_match_urational_16():
    init_test()

    check_match_fail(lex_match_urational_16, '', lex_rule_urational_16)
    check_match_fail(lex_match_urational_16, hex_digits + ' ', lex_rule_urational_16)

    check_match(lex_match_urational_16, hex_digits + '/' + hex_digits, lex_rule_urational_16)

def test_lex_match_urational_10():
    init_test()

    check_match_fail(lex_match_urational_10, '', lex_rule_urational_10)
    check_match_fail(lex_match_urational_10, decimal_digits + ' ', lex_rule_urational_10)

    check_match(lex_match_urational_10, decimal_digits + '/' + decimal_digits, lex_rule_urational_10)

def test_lex_match_urational_8():
    init_test()

    check_match_fail(lex_match_urational_8, '', lex_rule_urational_8)
    check_match_fail(lex_match_urational_8, octal_digits + ' ', lex_rule_urational_8)

    check_match(lex_match_urational_8, octal_digits + '/' + octal_digits, lex_rule_urational_8)

def test_lex_match_urational_2():
    init_test()

    check_match_fail(lex_match_urational_2, '', lex_rule_urational_2)
    check_match_fail(lex_match_urational_2, binary_digits + ' ', lex_rule_urational_2)

    check_match(lex_match_urational_2, binary_digits + '/' + binary_digits, lex_rule_urational_2)

def test_lex_match_decimal_10():
    init_test()

    check_match_fail(lex_match_decimal_10, '', lex_rule_decimal_10)

    for src in ('1', '1e+2', '.3E-10', '6.25'):
        check_match(lex_match_decimal_10, src, lex_rule_decimal_10)

def test_lex_match_uinteger_16():
    init_test()

    check_match_fail(lex_match_uinteger_16, '', lex_rule_uinteger_16)

    for n in (1, 2, 3):
        check_match(lex_match_uinteger_16, n * hex_digits, lex_rule_uinteger_16)

def test_lex_match_uinteger_10():
    init_test()

    check_match_fail(lex_match_uinteger_10, '', lex_rule_uinteger_10)

    for n in (1, 2, 3):
        check_match(lex_match_uinteger_10, n * decimal_digits, lex_rule_uinteger_10)

def test_lex_match_uinteger_8():
    init_test()

    check_match_fail(lex_match_uinteger_8, '', lex_rule_uinteger_8)

    for n in (1, 2, 4):
        check_match(lex_match_uinteger_8, n * octal_digits, lex_rule_uinteger_8)

def test_lex_match_uinteger_2():
    init_test()

    check_match_fail(lex_match_uinteger_2, '', lex_rule_uinteger_2)

    for n in (1, 5, 15):
        check_match(lex_match_uinteger_2, n * binary_digits, lex_rule_uinteger_2)

def test_lex_match_prefix_16():
    init_test()

    check_match_fail(lex_match_prefix_16, '', lex_rule_prefix_16)

    check_match(lex_match_prefix_16, '#x0', lex_rule_prefix_16, expected_end=2)
    check_match(lex_match_prefix_16, '#e#x', lex_rule_prefix_16)
    check_match(lex_match_prefix_16, '#x#i', lex_rule_prefix_16)

def test_lex_match_prefix_10():
    init_test()

    check_match(lex_match_prefix_10, '', lex_rule_prefix_10)
    check_match(lex_match_prefix_10, '#d0', lex_rule_prefix_10, expected_end=2)
    check_match(lex_match_prefix_10, '#e#d', lex_rule_prefix_10)
    check_match(lex_match_prefix_10, '#d#i', lex_rule_prefix_10)
    check_match(lex_match_prefix_10, '#e0', lex_rule_prefix_10, expected_end=2)
    check_match(lex_match_prefix_10, '#i0', lex_rule_prefix_10, expected_end=2)

def test_lex_match_prefix_8():
    init_test()

    check_match_fail(lex_match_prefix_8, '', lex_rule_prefix_8)

    check_match(lex_match_prefix_8, '#o0', lex_rule_prefix_8, expected_end=2)
    check_match(lex_match_prefix_8, '#e#o', lex_rule_prefix_8)
    check_match(lex_match_prefix_8, '#o#i', lex_rule_prefix_8)

def test_lex_match_prefix_2():
    init_test()

    check_match_fail(lex_match_prefix_2, '', lex_rule_prefix_2)

    check_match(lex_match_prefix_2, '#b0', lex_rule_prefix_2, expected_end=2)
    check_match(lex_match_prefix_2, '#e#b', lex_rule_prefix_2)
    check_match(lex_match_prefix_2, '#b#i', lex_rule_prefix_2)

def test_lex_match_infnan():
    init_test()

    check_match_fail(lex_match_infnan, '', lex_rule_infnan)
    check_match_fail(lex_match_infnan, 'inf', lex_rule_infnan)

    for v in ('+Inf.0', '+NaN.0', '-Inf.0', '-NaN.0'):
        check_match(lex_match_infnan, v, lex_rule_infnan)
        check_match(lex_match_infnan, v.upper(), lex_rule_infnan)
        check_match(lex_match_infnan, v.lower(), lex_rule_infnan)

def test_lex_match_suffix():
    init_test()

    check_match(lex_match_suffix, '', lex_rule_suffix)
    check_match(lex_match_suffix, 'e+0', lex_rule_suffix)
    check_match(lex_match_suffix, 'e+1234', lex_rule_suffix)

def test_lex_match_sign():
    init_test()

    check_match(lex_match_sign, '', lex_rule_sign)
    check_match(lex_match_sign, '+', lex_rule_sign)
    check_match(lex_match_sign, '-', lex_rule_sign)

def test_lex_match_exactness():
    init_test()

    check_match(lex_match_exactness, '', lex_rule_exactness)
    check_match(lex_match_exactness, '#e', lex_rule_exactness)
    check_match(lex_match_exactness, '#E', lex_rule_exactness)
    check_match(lex_match_exactness, '#i', lex_rule_exactness)
    check_match(lex_match_exactness, '#I', lex_rule_exactness)

def test_lex_match_radix_2():
    init_test()

    check_match_fail(lex_match_radix_2, '', lex_rule_radix_2)

    check_match(lex_match_radix_2, '#b', lex_rule_radix_2)
    check_match(lex_match_radix_2, '#B', lex_rule_radix_2)

def test_lex_match_radix_8():
    init_test()

    check_match_fail(lex_match_radix_8, '', lex_rule_radix_8)

    check_match(lex_match_radix_8, '#o', lex_rule_radix_8)
    check_match(lex_match_radix_8, '#O', lex_rule_radix_8)

def test_lex_match_radix_10():
    init_test()

    check_match(lex_match_radix_10, '', lex_rule_radix_10)
    check_match(lex_match_radix_10, '#d', lex_rule_radix_10)
    check_match(lex_match_radix_10, '#D', lex_rule_radix_10)

def test_lex_match_radix_16():
    init_test()

    check_match_fail(lex_match_radix_16, '', lex_rule_radix_16)

    check_match(lex_match_radix_16, '#x', lex_rule_radix_16)
    check_match(lex_match_radix_16, '#X', lex_rule_radix_16)

def test_lex_match_digit_2():
    init_test()

    check_match_fail(lex_match_digit_2, '', lex_rule_digit_2)

    for b in range(256):
        if b in binary_ordinals:
            check_match(lex_match_digit_2, chr(b), lex_rule_digit_2)
        else:
            check_match_fail(lex_match_digit_2, chr(b), lex_rule_digit_2)

def test_lex_match_digit_8():
    init_test()

    check_match_fail(lex_match_digit_8, '', lex_rule_digit_8)

    for b in range(256):
        if b in octal_ordinals:
            check_match(lex_match_digit_8, chr(b), lex_rule_digit_8)
        else:
            check_match_fail(lex_match_digit_8, chr(b), lex_rule_digit_8)

def test_lex_match_digit():
    init_test()

    check_match_fail(lex_match_digit, '', lex_rule_digit)

    for b in range(256):
        if b in decimal_ordinals:
            check_match(lex_match_digit, chr(b), lex_rule_digit)
        else:
            check_match_fail(lex_match_digit, chr(b), lex_rule_digit)

def test_lex_match_digit_16():
    init_test()

    check_match_fail(lex_match_digit_16, '', lex_rule_digit_16)

    matching_rule_ids = (lex_rule_digit, lex_rule_digit_16_A_F, lex_rule_digit_16_a_f)

    for b in range(256):
        if b in hex_ordinals:
            check_match_many(lex_match_digit_16, chr(b), matching_rule_ids)
        else:
            check_match_fail(lex_match_digit_16, chr(b), lex_rule_digit_16)
