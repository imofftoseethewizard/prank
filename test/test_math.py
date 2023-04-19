import math
from pytest import approx
from modules.debug.math import *

tau = 2*math.pi
eps = 1.0e-13

def error_ratio(act, exp):
    return abs(act - exp)/exp

def test_sin_0():
    check_sin_0()

def test_chebyshev_sin_0():
    assert chebyshev_sin(0.0) == 0.0

def test_chebyshev_sin_1_12():
    assert error_ratio(chebyshev_sin(1.0/12.0), math.sin(tau/12)) < eps

def test_chebyshev_sin_1_16():
    assert error_ratio(chebyshev_sin(1.0/16.0), math.sin(tau/16)) < eps

def test_chebyshev_sin_1_8():
    assert error_ratio(chebyshev_sin(1.0/8.0), math.sin(tau/8)) < eps

def test_chebyshev_sin_neg_1_12():
    assert error_ratio(chebyshev_sin(-1.0/12.0), math.sin(-tau/12)) < eps

def test_chebyshev_sin_neg_1_16():
    assert error_ratio(chebyshev_sin(-1.0/16.0), math.sin(-tau/16)) < eps

def test_chebyshev_sin_neg_1_8():
    assert error_ratio(chebyshev_sin(-1.0/8.0), math.sin(-tau/8)) < eps

# def test_sin_tau_1_4():
#     print(sin(tau/4.0), math.sin(tau/4.0))
#     check_sin_tau_1_4()

# def test_sin_tau_1_8():
#     print(sin(tau/8.0), math.sin(tau/8.0))
#     check_sin_tau_8()
