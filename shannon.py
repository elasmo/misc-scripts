#!/usr/bin/env python3
#
# Simple PoC to calculate Shannon's entropy on words
# contained in a file.
#
import math, sys
from collections import Counter

# Taken from http://rosettacode.org/wiki/Entropy
def entropy(s):
    p, lns = Counter(s), float(len(s))
    return -sum( count/lns * math.log(count/lns, 2) for count in p.values())

if __name__ == "__main__":
    with open(sys.argv[1], "rb") as f:
        data = f.read().split()

        for s in data:
            print("{}:{}:{}".format(sys.argv[1], entropy(s), s))
