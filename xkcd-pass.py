#!/usr/bin/env python3
#
# XKCD-style passphrase
# https://docs.python.org/3/library/secrets.html#recipes-and-best-practices
#
from random import choice

with open('/usr/share/dict/words') as f:
    words = [word.strip() for word in f]
    password = ' '.join(choice(words) for i in range(4))

print(password)
