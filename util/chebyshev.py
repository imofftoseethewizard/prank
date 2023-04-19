# from https://www.embeddedrelated.com/showarticle/152.php
#
# usage
#
# >>> import cheby
# >>> import numpy as np
# >>> import math
# >>> c = cheby.Cheby.fit(np.sin,0,math.pi/2,5)
# >>> c
# Cheby(0.0, 1.5707963267948966, 0.60219470125550711, 0.51362516668030367, -0.10354634422944738, -0.013732035086651754, 0.001358650338492214, 0.00010765948465629727)
# >>> c(math.pi*np.array([0, 1.0/6, 1.0/4, 1.0/3]))
# array([  6.21628624e-06,   5.00003074e-01,   7.07099696e-01,
#          8.66028717e-01])
import math
import numpy as np
def chebspace(npts):
    t = (np.array(range(0,npts)) + 0.5) / npts
    return -np.cos(t*math.pi)
def chebmat(u, N):
    T = np.column_stack((np.ones(len(u)), u))
    for n in range(2,N+1):
        Tnext = 2*u*T[:,n-1] - T[:,n-2]
        T = np.column_stack((T,Tnext))
    return T
class Cheby(object):
    def __init__(self, a, b, *coeffs):
        self.c = (a+b)/2.0
        self.m = (b-a)/2.0
        self.coeffs = np.array(coeffs, ndmin=1)
    def rangestart(self):
        return self.c-self.m
    def rangeend(self):
        return self.c+self.m
    def range(self):
        return (self.rangestart(), self.rangeend())
    def degree(self):
        return len(self.coeffs)-1
    def truncate(self, n):
        return Cheby(self.rangestart(), self.rangeend(), *self.coeffs[0:n+1])
    def asTaylor(self, x0=0, m0=1.0):
        n = self.degree()+1
        Tprev = np.zeros(n)
        T     = np.zeros(n)
        Tprev[0] = 1
        T[1]  = 1
        # evaluate y = Chebyshev functions as polynomials in u
        y     = self.coeffs[0] * Tprev
        for co in self.coeffs[1:]:
            y = y + T*co
            xT = np.roll(T, 1)
            xT[0] = 0
            Tnext = 2*xT - Tprev
            Tprev = T
            T = Tnext
        # now evaluate y2 = polynomials in x
        P     = np.zeros(n)
        y2    = np.zeros(n)
        P[0]  = 1
        k0 = -self.c/self.m
        k1 = 1.0/self.m
        k0 = k0 + k1*x0
        k1 = k1/m0
        for yi in y:
            y2 = y2 + P*yi
            Pnext = np.roll(P, 1)*k1
            Pnext[0] = 0
            P = Pnext + k0*P
        return y2
    def __call__(self, x):
        xa = np.array(x, copy=False, ndmin=1)
        u = np.array((xa-self.c)/self.m)
        Tprev = np.ones(len(u))
        y = self.coeffs[0] * Tprev
        if self.degree() > 0:
            y = y + u*self.coeffs[1]
            T = u
        for n in range(2,self.degree()+1):
            Tnext = 2*u*T - Tprev
            Tprev = T
            T = Tnext
            y = y + T*self.coeffs[n]
        return y
    def __repr__(self):
        return "Cheby%s" % (self.range()+tuple(c for c in self.coeffs)).__repr__()
    @staticmethod
    def fit(func, a, b, degree):
        N = degree+1
        u = chebspace(N)
        x = (u*(b-a) + (b+a))/2.0
        y = func(x)
        T = chebmat(u, N=degree)
        c = 2.0/N * np.dot(y,T)
        c[0] = c[0]/2
        return Cheby(a, b, *c)

# additions to original

def test(c, x, f):
   return (c(x)-f(x))/f(x)

def make_sin(n):
  c = Cheby.fit(np_sin_pi_x,-0.25,0.25,n)
  for i in range(0, n, 2):
    c.coeffs[i] = 0.0
  return c

def make_cos(n):
  c = Cheby.fit(np_cos_pi_x,-0.25,0.25,n)
  for i in range(1, n, 2):
    c.coeffs[i] = 0.0
  return c

def sin_pi_x(x):
  return math.sin(x*2*math.pi)

def cos_pi_x(x):
  return math.cos(x*2*math.pi)

np_sin_pi_x = np.frompyfunc(sin_pi_x, 1, 1)
np_cos_pi_x = np.frompyfunc(cos_pi_x, 1, 1)
