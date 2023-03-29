def chebyshev_eval(x, z, d, cs):
    u = (x - z)/d
    t_prev = 1
    y = cs[0] + u*cs[1]
    t = u
    for c in cs[2:]:
        t_next = 2 * u * t - t_prev
        t_prev = t
        t = t_next
        y = y + t * c
    return y
