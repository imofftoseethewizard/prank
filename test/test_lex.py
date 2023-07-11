import pytest

from util import format_addr

from modules.debug.block_mgr import *
from modules.debug.chars import *
from modules.debug.lex import *
from modules.debug.lex_test_rules import *
from modules.debug.pairs import *
from modules.debug.strings import *

from modules.debug.lex import lex_match_rule_ as lex_maybe_match_rule

def init_test():
    init_pairs()
    init_blockset_manager()
    init_strings()
    init_lex_test_rules()

def test_init():
    init_test()

    assert get_string_length(charset_ab.value) == 2
    assert get_string_length(charset_ba.value) == 2
    assert get_string_length(charset_bc.value) == 2
    assert get_string_length(empty_string.value) == 0
    assert get_string_length(single_char_string.value) == 1

def test_lex_match_empty():
    init_test()

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_empty(rule_id, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

def test_lex_match_any_char():
    init_test()

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_any_char(rule_id, text, end)
    assert matched_rule_id == rule_id
    assert match_end == -1

    rule_id = 200
    text = get_string_addr(single_char_string.value)
    end = text + get_string_size(single_char_string.value)
    matched_rule_id, match_end = lex_match_any_char(rule_id, text, end)
    assert matched_rule_id == rule_id
    assert match_end == end

def test_lex_match_char():
    init_test()

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_char(rule_id, ord('0'), text, end)
    assert matched_rule_id == rule_id
    assert match_end == -1

    rule_id = 200
    text = end = get_string_addr(single_char_string.value)
    matched_rule_id, match_end = lex_match_char(rule_id, ord('0'), text, end)
    assert matched_rule_id == rule_id
    assert match_end == -1

    rule_id = 200
    text = get_string_addr(single_char_string.value)
    end = text + get_string_size(single_char_string.value)
    matched_rule_id, match_end = lex_match_char(rule_id, ord('a'), text, end)
    assert matched_rule_id == rule_id
    assert match_end == end

def test_lex_match_char_ascii_ci():
    init_test()

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_char_ascii_ci(rule_id, ord('0'), text, end)
    assert matched_rule_id == rule_id
    assert match_end == -1

    rule_id = 200
    text = end = get_string_addr(single_char_string.value)
    matched_rule_id, match_end = lex_match_char_ascii_ci(rule_id, ord('0'), text, end)
    assert matched_rule_id == rule_id
    assert match_end == -1

    rule_id = 200
    text = get_string_addr(single_char_string.value)
    end = text + get_string_size(single_char_string.value)
    matched_rule_id, match_end = lex_match_char_ascii_ci(rule_id, ord('a'), text, end)
    assert matched_rule_id == rule_id
    assert match_end == end

    rule_id = 200
    text = get_string_addr(single_char_string.value)
    end = text + get_string_size(single_char_string.value)
    matched_rule_id, match_end = lex_match_char_ascii_ci(rule_id, ord('A'), text, end)
    assert matched_rule_id == rule_id
    assert match_end == end

def test_lex_match_char_complement_set_of_2():
    init_test()

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_char_complement_set_of_2(rule_id, ord('0'), ord('1'), text, end)
    assert matched_rule_id == rule_id
    assert match_end == -1

    rule_id = 200
    text = get_string_addr(single_char_string.value)
    end = text + get_string_size(single_char_string.value)
    matched_rule_id, match_end = lex_match_char_complement_set_of_2(rule_id, ord('0'), ord('1'), text, end)
    assert matched_rule_id == rule_id
    assert match_end == end

    rule_id = 200
    text = get_string_addr(single_char_string.value)
    end = text + get_string_size(single_char_string.value)
    matched_rule_id, match_end = lex_match_char_complement_set_of_2(rule_id, ord('a'), ord('1'), text, end)
    assert matched_rule_id == rule_id
    assert match_end == -1

    rule_id = 200
    text = get_string_addr(single_char_string.value)
    end = text + get_string_size(single_char_string.value)
    matched_rule_id, match_end = lex_match_char_complement_set_of_2(rule_id, ord('1'), ord('a'), text, end)
    assert matched_rule_id == rule_id
    assert match_end == -1

def test_lex_match_char_range_ascii():
    init_test()

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_char_range_ascii(rule_id, ord('a')-1, ord('a')+1, text, end)
    assert matched_rule_id == rule_id
    assert match_end == -1

    rule_id = 200
    text = get_string_addr(single_char_string.value)
    end = text + get_string_size(single_char_string.value)
    matched_rule_id, match_end = lex_match_char_range_ascii(rule_id, ord('a')-2, ord('a'), text, end)
    assert matched_rule_id == rule_id
    assert match_end == end

    rule_id = 200
    text = get_string_addr(single_char_string.value)
    end = text + get_string_size(single_char_string.value)
    matched_rule_id, match_end = lex_match_char_range_ascii(rule_id, ord('a')-1, ord('a')+1, text, end)
    assert matched_rule_id == rule_id
    assert match_end == end

    rule_id = 200
    text = get_string_addr(single_char_string.value)
    end = text + get_string_size(single_char_string.value)
    matched_rule_id, match_end = lex_match_char_range_ascii(rule_id, ord('a'), ord('a')+2, text, end)
    assert matched_rule_id == rule_id
    assert match_end == end

    rule_id = 200
    text = get_string_addr(single_char_string.value)
    end = text + get_string_size(single_char_string.value)
    matched_rule_id, match_end = lex_match_char_range_ascii(rule_id, ord('a')-2, ord('a')-1, text, end)
    assert matched_rule_id == rule_id
    assert match_end == -1

    rule_id = 200
    text = get_string_addr(single_char_string.value)
    end = text + get_string_size(single_char_string.value)
    matched_rule_id, match_end = lex_match_char_range_ascii(rule_id, ord('a')+1, ord('a')+2, text, end)
    assert matched_rule_id == rule_id
    assert match_end == -1

def test_lex_match_charset_ascii():
    init_test()

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_charset_ascii(rule_id, charset_ab.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == -1

    rule_id = 200
    text = get_string_addr(single_char_string.value)
    end = text + get_string_size(single_char_string.value)
    matched_rule_id, match_end = lex_match_charset_ascii(rule_id, charset_ab.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == end

    rule_id = 200
    text = get_string_addr(single_char_string.value)
    end = text + get_string_size(single_char_string.value)
    matched_rule_id, match_end = lex_match_charset_ascii(rule_id, charset_ba.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == end

    rule_id = 200
    text = get_string_addr(single_char_string.value)
    end = text + get_string_size(single_char_string.value)
    matched_rule_id, match_end = lex_match_charset_ascii(rule_id, charset_bc.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == -1

def test_lex_match_string():
    init_test()

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_string(rule_id, empty_string.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = get_string_addr(single_char_string.value)
    end = text + get_string_size(single_char_string.value)
    matched_rule_id, match_end = lex_match_string(rule_id, empty_string.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_string(rule_id, single_char_string.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == -1

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)
    size = get_string_size(lower_alphabet.value)
    end = text + size

    pattern = get_string_addr(lower_alpha23.value)
    pattern_size = get_string_size(lower_alpha23.value)
    for i in range(size):
        set_string_bytes(pattern+i, ord('0'), 1)
        if i > 0:
            set_string_bytes(pattern+i-1, ord('a')+i-1, 1)
        matched_rule_id, match_end = lex_match_string(rule_id, lower_alpha23.value, text, end)
        assert matched_rule_id == rule_id
        if i < pattern_size:
            assert match_end == -1
        else:
            assert match_end == text + pattern_size

def test_lex_match_string_ascii_ci():
    init_test()

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_string_ascii_ci(rule_id, empty_string.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = get_string_addr(single_char_string.value)
    end = text + get_string_size(single_char_string.value)
    matched_rule_id, match_end = lex_match_string_ascii_ci(rule_id, empty_string.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_string_ascii_ci(rule_id, single_char_string.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == -1

    rule_id = 200
    text = get_string_addr(upper_alphabet.value)
    size = get_string_size(upper_alphabet.value)
    end = text + size

    pattern = get_string_addr(lower_alpha23.value)
    pattern_size = get_string_size(lower_alpha23.value)
    for i in range(size):
        set_string_bytes(pattern+i, ord('0'), 1)
        if i > 0:
            set_string_bytes(pattern+i-1, ord('a')+i-1, 1)
        matched_rule_id, match_end = lex_match_string_ascii_ci(rule_id, lower_alpha23.value, text, end)
        assert matched_rule_id == rule_id
        if i < pattern_size:
            assert match_end == -1
        else:
            assert match_end == text + pattern_size

def test_lex_match_strings_one_of_2():
    init_test()

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_strings_one_of_2(rule_id, empty_string.value, single_char_string.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_strings_one_of_2(rule_id, single_char_string.value, empty_string.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_strings_one_of_2(rule_id, single_char_string.value, lower_alphabet.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == -1

    rule_id = 200
    text = get_string_addr(single_char_string.value)
    end = text + get_string_size(single_char_string.value)
    matched_rule_id, match_end = lex_match_strings_one_of_2(rule_id, empty_string.value, lower_alphabet.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = get_string_addr(single_char_string.value)
    end = text + get_string_size(single_char_string.value)
    matched_rule_id, match_end = lex_match_strings_one_of_2(rule_id, lower_alphabet.value, empty_string.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_strings_one_of_2(rule_id, lower_alpha23.value, single_char_string.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text + get_string_size(lower_alpha23.value)

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_strings_one_of_2(rule_id, single_char_string.value, lower_alpha23.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text + get_string_size(single_char_string.value)

def test_lex_match_strings_ascii_ci_one_of_2():
    init_test()

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_strings_ascii_ci_one_of_2(rule_id, empty_string.value, single_char_string.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_strings_ascii_ci_one_of_2(rule_id, single_char_string.value, empty_string.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_strings_ascii_ci_one_of_2(rule_id, single_char_string.value, lower_alphabet.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == -1

    rule_id = 200
    text = get_string_addr(single_char_string.value)
    end = text + get_string_size(single_char_string.value)
    matched_rule_id, match_end = lex_match_strings_ascii_ci_one_of_2(rule_id, empty_string.value, lower_alphabet.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = get_string_addr(single_char_string.value)
    end = text + get_string_size(single_char_string.value)
    matched_rule_id, match_end = lex_match_strings_ascii_ci_one_of_2(rule_id, lower_alphabet.value, empty_string.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = get_string_addr(upper_alphabet.value)
    end = text + get_string_size(upper_alphabet.value)
    matched_rule_id, match_end = lex_match_strings_ascii_ci_one_of_2(rule_id, lower_alpha23.value, single_char_string.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text + get_string_size(lower_alpha23.value)

    rule_id = 200
    text = get_string_addr(upper_alphabet.value)
    end = text + get_string_size(upper_alphabet.value)
    matched_rule_id, match_end = lex_match_strings_ascii_ci_one_of_2(rule_id, single_char_string.value, lower_alpha23.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text + get_string_size(single_char_string.value)

def test_lex_match_strings_one_of_3():
    init_test()

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_strings_one_of_3(rule_id, empty_string.value, single_char_string.value, lower_alphabet.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_strings_one_of_3(rule_id, lower_alphabet.value, empty_string.value, single_char_string.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_strings_one_of_3(rule_id, single_char_string.value, lower_alphabet.value, empty_string.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_strings_one_of_3(rule_id, single_char_string.value, lower_alphabet.value, lower_alpha23.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == -1

    rule_id = 200
    text = get_string_addr(single_char_string.value)
    end = text + get_string_size(single_char_string.value)
    matched_rule_id, match_end = lex_match_strings_one_of_3(rule_id, empty_string.value, lower_alphabet.value, lower_alpha23.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = get_string_addr(single_char_string.value)
    end = text + get_string_size(single_char_string.value)
    matched_rule_id, match_end = lex_match_strings_one_of_3(rule_id, lower_alpha23.value, empty_string.value, lower_alphabet.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = get_string_addr(single_char_string.value)
    end = text + get_string_size(single_char_string.value)
    matched_rule_id, match_end = lex_match_strings_one_of_3(rule_id, lower_alphabet.value, lower_alpha23.value, empty_string.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_strings_one_of_3(rule_id, single_char_string.value, lower_alphabet.value, lower_alpha23.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text + get_string_size(single_char_string.value)

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_strings_one_of_3(rule_id, lower_alpha23.value, single_char_string.value, lower_alphabet.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text + get_string_size(lower_alpha23.value)

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_strings_one_of_3(rule_id, lower_alphabet.value, lower_alpha23.value, single_char_string.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text + get_string_size(lower_alphabet.value)

def test_lex_match_strings_longest_of_2():
    init_test()

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_strings_longest_of_2(rule_id, empty_string.value, single_char_string.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_strings_longest_of_2(rule_id, single_char_string.value, empty_string.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_strings_longest_of_2(rule_id, single_char_string.value, lower_alphabet.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == -1

    rule_id = 200
    text = get_string_addr(single_char_string.value)
    end = text + get_string_size(single_char_string.value)
    matched_rule_id, match_end = lex_match_strings_longest_of_2(rule_id, empty_string.value, lower_alphabet.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = get_string_addr(single_char_string.value)
    end = text + get_string_size(single_char_string.value)
    matched_rule_id, match_end = lex_match_strings_longest_of_2(rule_id, lower_alphabet.value, empty_string.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_strings_longest_of_2(rule_id, lower_alpha23.value, single_char_string.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text + get_string_size(lower_alpha23.value)

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_strings_longest_of_2(rule_id, single_char_string.value, lower_alpha23.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text + get_string_size(lower_alpha23.value)

def test_lex_match_strings_ascii_ci_longest_of_2():
    init_test()

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_strings_ascii_ci_longest_of_2(rule_id, empty_string.value, single_char_string.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_strings_ascii_ci_longest_of_2(rule_id, single_char_string.value, empty_string.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_strings_ascii_ci_longest_of_2(rule_id, single_char_string.value, lower_alphabet.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == -1

    rule_id = 200
    text = get_string_addr(single_char_string.value)
    end = text + get_string_size(single_char_string.value)
    matched_rule_id, match_end = lex_match_strings_ascii_ci_longest_of_2(rule_id, empty_string.value, lower_alphabet.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = get_string_addr(single_char_string.value)
    end = text + get_string_size(single_char_string.value)
    matched_rule_id, match_end = lex_match_strings_ascii_ci_longest_of_2(rule_id, lower_alphabet.value, empty_string.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = get_string_addr(upper_alphabet.value)
    end = text + get_string_size(upper_alphabet.value)
    matched_rule_id, match_end = lex_match_strings_ascii_ci_longest_of_2(rule_id, lower_alpha23.value, single_char_string.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text + get_string_size(lower_alpha23.value)

    rule_id = 200
    text = get_string_addr(upper_alphabet.value)
    end = text + get_string_size(upper_alphabet.value)
    matched_rule_id, match_end = lex_match_strings_ascii_ci_longest_of_2(rule_id, single_char_string.value, lower_alpha23.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text + get_string_size(lower_alpha23.value)

def test_lex_match_strings_longest_of_3():
    init_test()

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_strings_longest_of_3(rule_id, empty_string.value, single_char_string.value, lower_alphabet.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_strings_longest_of_3(rule_id, lower_alphabet.value, empty_string.value, single_char_string.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_strings_longest_of_3(rule_id, single_char_string.value, lower_alphabet.value, empty_string.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_strings_longest_of_3(rule_id, single_char_string.value, lower_alphabet.value, lower_alpha23.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == -1

    rule_id = 200
    text = get_string_addr(single_char_string.value)
    end = text + get_string_size(single_char_string.value)
    matched_rule_id, match_end = lex_match_strings_longest_of_3(rule_id, empty_string.value, lower_alphabet.value, lower_alpha23.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = get_string_addr(single_char_string.value)
    end = text + get_string_size(single_char_string.value)
    matched_rule_id, match_end = lex_match_strings_longest_of_3(rule_id, lower_alpha23.value, empty_string.value, lower_alphabet.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = get_string_addr(single_char_string.value)
    end = text + get_string_size(single_char_string.value)
    matched_rule_id, match_end = lex_match_strings_longest_of_3(rule_id, lower_alphabet.value, lower_alpha23.value, empty_string.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_strings_longest_of_3(rule_id, single_char_string.value, lower_alphabet.value, lower_alpha23.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text + get_string_size(lower_alphabet.value)

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_strings_longest_of_3(rule_id, lower_alpha23.value, single_char_string.value, lower_alphabet.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text + get_string_size(lower_alphabet.value)

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_strings_longest_of_3(rule_id, lower_alphabet.value, lower_alpha23.value, single_char_string.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text + get_string_size(lower_alphabet.value)

def test_lex_match_strings_ascii_ci_longest_of_3():
    init_test()

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_strings_ascii_ci_longest_of_3(rule_id, empty_string.value, single_char_string.value, lower_alphabet.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_strings_ascii_ci_longest_of_3(rule_id, lower_alphabet.value, empty_string.value, single_char_string.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_strings_ascii_ci_longest_of_3(rule_id, single_char_string.value, lower_alphabet.value, empty_string.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_strings_ascii_ci_longest_of_3(rule_id, single_char_string.value, lower_alphabet.value, lower_alpha23.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == -1

    rule_id = 200
    text = get_string_addr(single_char_string.value)
    end = text + get_string_size(single_char_string.value)
    matched_rule_id, match_end = lex_match_strings_ascii_ci_longest_of_3(rule_id, empty_string.value, lower_alphabet.value, lower_alpha23.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = get_string_addr(single_char_string.value)
    end = text + get_string_size(single_char_string.value)
    matched_rule_id, match_end = lex_match_strings_ascii_ci_longest_of_3(rule_id, lower_alpha23.value, empty_string.value, lower_alphabet.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = get_string_addr(single_char_string.value)
    end = text + get_string_size(single_char_string.value)
    matched_rule_id, match_end = lex_match_strings_ascii_ci_longest_of_3(rule_id, lower_alphabet.value, lower_alpha23.value, empty_string.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = get_string_addr(upper_alphabet.value)
    end = text + get_string_size(upper_alphabet.value)
    matched_rule_id, match_end = lex_match_strings_ascii_ci_longest_of_3(rule_id, single_char_string.value, lower_alphabet.value, lower_alpha23.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text + get_string_size(lower_alphabet.value)

    rule_id = 200
    text = get_string_addr(upper_alphabet.value)
    end = text + get_string_size(upper_alphabet.value)
    matched_rule_id, match_end = lex_match_strings_ascii_ci_longest_of_3(rule_id, lower_alpha23.value, single_char_string.value, lower_alphabet.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text + get_string_size(lower_alphabet.value)

    rule_id = 200
    text = get_string_addr(upper_alphabet.value)
    end = text + get_string_size(upper_alphabet.value)
    matched_rule_id, match_end = lex_match_strings_ascii_ci_longest_of_3(rule_id, lower_alphabet.value, lower_alpha23.value, single_char_string.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text + get_string_size(lower_alphabet.value)

def test_lex_match_strings_longest_of_4():
    init_test()

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_strings_longest_of_4(rule_id, empty_string.value, single_char_string.value, lower_alpha23.value, lower_alphabet.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_strings_longest_of_4(rule_id, lower_alphabet.value, empty_string.value, single_char_string.value, lower_alpha23.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_strings_longest_of_4(rule_id, lower_alpha23.value, lower_alphabet.value, empty_string.value, single_char_string.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_strings_longest_of_4(rule_id, single_char_string.value, lower_alpha23.value, lower_alphabet.value, empty_string.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_strings_longest_of_4(rule_id, single_char_string.value, lower_alphabet.value, lower_alpha23.value, lower_alpha23.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == -1

    rule_id = 200
    text = get_string_addr(single_char_string.value)
    end = text + get_string_size(single_char_string.value)
    matched_rule_id, match_end = lex_match_strings_longest_of_4(rule_id, empty_string.value, lower_alphabet.value, lower_alpha23.value, lower_alpha23.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = get_string_addr(single_char_string.value)
    end = text + get_string_size(single_char_string.value)
    matched_rule_id, match_end = lex_match_strings_longest_of_4(rule_id, lower_alpha23.value, empty_string.value, lower_alphabet.value, lower_alpha23.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = get_string_addr(single_char_string.value)
    end = text + get_string_size(single_char_string.value)
    matched_rule_id, match_end = lex_match_strings_longest_of_4(rule_id, lower_alpha23.value, lower_alpha23.value, empty_string.value, lower_alphabet.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = get_string_addr(single_char_string.value)
    end = text + get_string_size(single_char_string.value)
    matched_rule_id, match_end = lex_match_strings_longest_of_4(rule_id, lower_alphabet.value, lower_alpha23.value, lower_alpha23.value, empty_string.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_strings_longest_of_4(rule_id, empty_string.value, single_char_string.value, lower_alphabet.value, lower_alpha23.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text + get_string_size(lower_alphabet.value)

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_strings_longest_of_4(rule_id, lower_alpha23.value, empty_string.value, single_char_string.value, lower_alphabet.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text + get_string_size(lower_alphabet.value)

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_strings_longest_of_4(rule_id, lower_alphabet.value, lower_alpha23.value, empty_string.value, single_char_string.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text + get_string_size(lower_alphabet.value)

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_strings_longest_of_4(rule_id, single_char_string.value, lower_alphabet.value, lower_alpha23.value, empty_string.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text + get_string_size(lower_alphabet.value)

def test_maybe_match_rule():
    init_test()

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_maybe_match_rule(rule_id, lex_rule_charset_bc.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_maybe_match_rule(rule_id, lex_rule_charset_bc.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)+1
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_maybe_match_rule(rule_id, lex_rule_charset_bc.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text+1

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)+2
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_maybe_match_rule(rule_id, lex_rule_charset_bc.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text+1

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)+3
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_maybe_match_rule(rule_id, lex_rule_charset_bc.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

def test_match_rule_zero_or_more():
    init_test()

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_rule_zero_or_more(rule_id, lex_rule_charset_bc.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_rule_zero_or_more(rule_id, lex_rule_charset_bc.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)+1
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_rule_zero_or_more(rule_id, lex_rule_charset_bc.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text+2

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)+2
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_rule_zero_or_more(rule_id, lex_rule_charset_bc.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text+1

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)+3
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_rule_zero_or_more(rule_id, lex_rule_charset_bc.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

def test_match_rule_one_or_more():
    init_test()

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_rule_one_or_more(rule_id, lex_rule_charset_bc.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == -1

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_rule_one_or_more(rule_id, lex_rule_charset_bc.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == -1

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)+1
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_rule_one_or_more(rule_id, lex_rule_charset_bc.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text+2

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)+2
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_rule_one_or_more(rule_id, lex_rule_charset_bc.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text+1

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)+3
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_rule_one_or_more(rule_id, lex_rule_charset_bc.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == -1

def test_match_rules_sequence_of_2():
    init_test()

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_rules_sequence_of_2(rule_id, lex_rule_charset_ab.value, lex_rule_charset_bc.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == -1

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_rules_sequence_of_2(rule_id, lex_rule_charset_ab.value, lex_rule_charset_bc.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text+2

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)+1
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_rules_sequence_of_2(rule_id, lex_rule_charset_ab.value, lex_rule_charset_bc.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text+2

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)+2
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_rules_sequence_of_2(rule_id, lex_rule_charset_ab.value, lex_rule_charset_bc.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == -1

def test_match_rules_sequence_of_3():
    init_test()

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_rules_sequence_of_3(rule_id, lex_rule_charset_ab.value, lex_rule_charset_bc.value, lex_rule_string_def.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == -1

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_rules_sequence_of_3(rule_id, lex_rule_charset_ab.value, lex_rule_charset_bc.value, lex_rule_string_def.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == -1

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)+1
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_rules_sequence_of_3(rule_id, lex_rule_charset_ab.value, lex_rule_charset_bc.value, lex_rule_string_def.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text+5

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)+2
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_rules_sequence_of_3(rule_id, lex_rule_charset_ab.value, lex_rule_charset_bc.value, lex_rule_string_def.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == -1

def test_match_rules_sequence_of_4():
    init_test()

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_rules_sequence_of_4(rule_id, lex_rule_charset_ab.value, lex_rule_charset_bc.value, lex_rule_string_def.value, lex_rule_charset_defg.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == -1

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_rules_sequence_of_4(rule_id, lex_rule_charset_ab.value, lex_rule_charset_bc.value, lex_rule_string_def.value, lex_rule_charset_defg.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == -1

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)+1
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_rules_sequence_of_4(rule_id, lex_rule_charset_ab.value, lex_rule_charset_bc.value, lex_rule_string_def.value, lex_rule_charset_defg.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text+6

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)+2
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_rules_sequence_of_4(rule_id, lex_rule_charset_ab.value, lex_rule_charset_bc.value, lex_rule_string_def.value, lex_rule_charset_defg.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == -1

def test_match_rules_longest_of_2():
    init_test()

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_rules_longest_of_2(rule_id, lex_rule_charset_ab.value, lex_rule_charset_bc.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == -1

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_rules_longest_of_2(rule_id, lex_rule_charset_ab.value, lex_rule_charset_bc.value, text, end)
    assert matched_rule_id == lex_rule_charset_ab.value
    assert match_end == text+1

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)+1
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_rules_longest_of_2(rule_id, lex_rule_charset_ab.value, lex_rule_charset_bc.value, text, end)
    assert matched_rule_id == lex_rule_charset_ab.value
    assert match_end == text+1

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)+1
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_rules_longest_of_2(rule_id, lex_rule_charset_bc.value, lex_rule_charset_ab.value, text, end)
    assert matched_rule_id == lex_rule_charset_bc.value
    assert match_end == text+1

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)+2
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_rules_longest_of_2(rule_id, lex_rule_charset_ab.value, lex_rule_charset_bc.value, text, end)
    assert matched_rule_id == lex_rule_charset_bc.value
    assert match_end == text+1

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)+3
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_rules_longest_of_2(rule_id, lex_rule_string_def.value, lex_rule_charset_defg.value, text, end)
    assert matched_rule_id == lex_rule_string_def.value
    assert match_end == text+3

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)+3
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_rules_longest_of_2(rule_id, lex_rule_charset_defg.value, lex_rule_string_def.value, text, end)
    assert matched_rule_id == lex_rule_string_def.value
    assert match_end == text+3

def test_match_rules_longest_of_3():
    init_test()

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_rules_longest_of_3(rule_id, lex_rule_charset_ab.value, lex_rule_charset_bc.value, lex_rule_charset_defg.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == -1

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_rules_longest_of_3(rule_id, lex_rule_charset_ab.value, lex_rule_charset_bc.value, lex_rule_charset_defg.value, text, end)
    assert matched_rule_id == lex_rule_charset_ab.value
    assert match_end == text+1

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)+1
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_rules_longest_of_3(rule_id, lex_rule_charset_ab.value, lex_rule_charset_bc.value, lex_rule_charset_defg.value, text, end)
    assert matched_rule_id == lex_rule_charset_ab.value
    assert match_end == text+1

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)+1
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_rules_longest_of_3(rule_id, lex_rule_charset_bc.value, lex_rule_charset_ab.value, lex_rule_charset_defg.value, text, end)
    assert matched_rule_id == lex_rule_charset_bc.value
    assert match_end == text+1

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)+1
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_rules_longest_of_3(rule_id, lex_rule_charset_bc.value, lex_rule_charset_defg.value, lex_rule_charset_ab.value, text, end)
    assert matched_rule_id == lex_rule_charset_bc.value
    assert match_end == text+1

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)+2
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_rules_longest_of_3(rule_id, lex_rule_charset_ab.value, lex_rule_charset_bc.value, lex_rule_charset_defg.value, text, end)
    assert matched_rule_id == lex_rule_charset_bc.value
    assert match_end == text+1

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)+3
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_rules_longest_of_3(rule_id, lex_rule_string_def.value, lex_rule_charset_defg.value, lex_rule_charset_defg.value, text, end)
    assert matched_rule_id == lex_rule_string_def.value
    assert match_end == text+3

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)+3
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_rules_longest_of_3(rule_id, lex_rule_charset_defg.value, lex_rule_string_def.value, lex_rule_charset_defg.value, text, end)
    assert matched_rule_id == lex_rule_string_def.value
    assert match_end == text+3
    rule_id = 200

    text = get_string_addr(lower_alphabet.value)+3
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_rules_longest_of_3(rule_id, lex_rule_charset_defg.value, lex_rule_charset_defg.value, lex_rule_string_def.value, text, end)
    assert matched_rule_id == lex_rule_string_def.value
    assert match_end == text+3

def test_match_rules_longest_of_4():
    init_test()

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_rules_longest_of_4(rule_id, lex_rule_charset_ab.value, lex_rule_charset_bc.value, lex_rule_charset_defg.value, lex_rule_charset_defg.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == -1

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_rules_longest_of_4(rule_id, lex_rule_charset_ab.value, lex_rule_charset_bc.value, lex_rule_charset_defg.value, lex_rule_charset_defg.value, text, end)
    assert matched_rule_id == lex_rule_charset_ab.value
    assert match_end == text+1

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)+1
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_rules_longest_of_4(rule_id, lex_rule_charset_ab.value, lex_rule_charset_bc.value, lex_rule_charset_defg.value, lex_rule_charset_defg.value, text, end)
    assert matched_rule_id == lex_rule_charset_ab.value
    assert match_end == text+1

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)+1
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_rules_longest_of_4(rule_id, lex_rule_charset_bc.value, lex_rule_charset_ab.value, lex_rule_charset_defg.value, lex_rule_charset_defg.value, text, end)
    assert matched_rule_id == lex_rule_charset_bc.value
    assert match_end == text+1

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)+1
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_rules_longest_of_4(rule_id, lex_rule_charset_bc.value, lex_rule_charset_defg.value, lex_rule_charset_ab.value, lex_rule_charset_defg.value, text, end)
    assert matched_rule_id == lex_rule_charset_bc.value
    assert match_end == text+1

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)+2
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_rules_longest_of_4(rule_id, lex_rule_charset_ab.value, lex_rule_charset_bc.value, lex_rule_charset_defg.value, lex_rule_charset_defg.value, text, end)
    assert matched_rule_id == lex_rule_charset_bc.value
    assert match_end == text+1

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)+3
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_rules_longest_of_4(rule_id, lex_rule_string_def.value, lex_rule_charset_defg.value, lex_rule_charset_defg.value, lex_rule_charset_defg.value, text, end)
    assert matched_rule_id == lex_rule_string_def.value
    assert match_end == text+3

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)+3
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_rules_longest_of_4(rule_id, lex_rule_charset_defg.value, lex_rule_string_def.value, lex_rule_charset_defg.value, lex_rule_charset_defg.value, text, end)
    assert matched_rule_id == lex_rule_string_def.value
    assert match_end == text+3
    rule_id = 200

    text = get_string_addr(lower_alphabet.value)+3
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_rules_longest_of_4(rule_id, lex_rule_charset_defg.value, lex_rule_charset_defg.value, lex_rule_string_def.value, lex_rule_charset_defg.value, text, end)
    assert matched_rule_id == lex_rule_string_def.value
    assert match_end == text+3

    text = get_string_addr(lower_alphabet.value)+3
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_rules_longest_of_4(rule_id, lex_rule_charset_defg.value, lex_rule_charset_defg.value, lex_rule_charset_defg.value, lex_rule_string_def.value, text, end)
    assert matched_rule_id == lex_rule_string_def.value
    assert match_end == text+3

def test_match_rules_set_of_2():
    init_test()

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_rules_set_of_2(rule_id, lex_rule_charset_ab.value, lex_rule_charset_bc.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == -1

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_rules_set_of_2(rule_id, lex_rule_charset_ab.value, lex_rule_charset_bc.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text+2

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_rules_set_of_2(rule_id, lex_rule_charset_bc.value, lex_rule_charset_ab.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text+2

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)+2
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_rules_set_of_2(rule_id, lex_rule_charset_ab.value, lex_rule_charset_bc.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == -1

def test_lex_match_until_rule():
    init_test()

    rule_id = 200
    text = end = get_string_addr(empty_string.value)
    matched_rule_id, match_end = lex_match_until_rule(rule_id, lex_rule_charset_ab.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == -1

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_until_rule(rule_id, lex_rule_charset_bc.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text+1

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)+1
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_until_rule(rule_id, lex_rule_charset_bc.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)+2
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_until_rule(rule_id, lex_rule_charset_bc.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == text

    rule_id = 200
    text = get_string_addr(lower_alphabet.value)+3
    end = text + get_string_size(lower_alphabet.value)
    matched_rule_id, match_end = lex_match_until_rule(rule_id, lex_rule_charset_bc.value, text, end)
    assert matched_rule_id == rule_id
    assert match_end == -1
