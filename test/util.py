import math
import random

# Adapted from https://stackoverflow.com/a/15330851
# Much lighter than adding numpy or scikit as a dependency.

def sample_poisson(expected_value):

  n = 0
  limit = math.exp(-expected_value)

  x = random.random()
  while x > limit:
    n += 1
    x *= random.random()

  return n
