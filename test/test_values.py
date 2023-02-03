from modules import values

def test_make_value():
    assert values.make_value(0, 0) == 0

def test_is_pair():
    assert values.is_pair_value(values.make_value(values.tag_pair.value, 0))

def test_get_value_data():
    assert values.get_value_data(values.make_value(values.tag_char.value, 16)) == 16

def test_get_value_tag():
    assert values.get_value_tag(values.make_value(values.tag_char.value, 16)) == values.tag_char.value

def test_set_value_data():
    v = values.make_value(0, 0)
    assert values.get_value_data(values.set_value_data(v, 256)) == 256

def test_set_value_tag():
    v = values.make_value(0, 0)
    assert values.get_value_tag(values.set_value_tag(v, values.tag_string.value)) == values.tag_string.value
