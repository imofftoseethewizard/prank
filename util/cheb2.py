def chebyshev_eval(x, z, d, cs):
    u = (x - z)/d

    t_prev = 1
    t = u
    y = cs[0] + t*cs[1]

    for c in cs[2:]:
        t_next = 2 * u * t - t_prev
        t_prev = t
        t = t_next
        y = y + t * c
    return y
