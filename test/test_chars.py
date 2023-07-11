from modules.debug.chars import *
from modules.debug.strings import *

from util import create_test_string, format_addr

def test_calc_encoded_length():
    for b in range(32, 128):
        assert calc_encoded_length(b) == 1

    s = create_test_string('λ')
    assert calc_encoded_length(get_string_char(get_string_addr(s))) == 2
