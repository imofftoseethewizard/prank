import struct

from modules.debug.chars import *
from modules.debug.strings import *

from util import create_test_string, format_addr, u32

def test_calc_encoded_length():
    for b in range(32, 128):
        assert calc_encoded_length(b) == 1

    s = create_test_string('λ')
    assert calc_encoded_length(get_string_char(get_string_addr(s))) == 2

def test_encode_code_point():

    c = ' '
    assert encode_code_point(ord(c)) == struct.unpack('<B', c.encode())[0]

    c = 'λ'
    assert encode_code_point(ord(c)) == struct.unpack('<H', c.encode())[0]

    c = 'ᴁ'
    x, y, z = struct.unpack('<BBB', c.encode())
    assert encode_code_point(ord(c)) == x + (y<<8) + (z<<16)

    c = '𝅘𝅥𝅮'
    w, x, y, z = struct.unpack('<BBBB', c.encode())
    print(hex(ord(c)))
    print(hex(w), hex(x), hex(y), hex(z))
    print(hex(w + (x<<8) + (y<<16) + (z<<24)))
    print(hex(u32(encode_code_point(ord(c)))))
    assert u32(encode_code_point(ord(c))) == w + (x<<8) + (y<<16) + (z<<24)
