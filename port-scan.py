#!/usr/bin/env python3
#
# Simple connect scan PoC
#
from socket import *
setdefaulttimeout(0.05)
print([p for p in range(1, 1025) if socket().connect_ex(('127.0.0.1', p)) == 0])
