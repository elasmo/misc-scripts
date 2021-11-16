#!/usr/bin/env python3
#
# Snippet to parse dhcp leases and their corresponding dhcp client hostnames

import re
pattern = re.compile(r"lease ([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}) {.*?client-hostname \"([A-Za-z0-9]+)\";.*?}", re.MULTILINE | re.DOTALL)
with open("/var/db/dhcpd.leases") as f:
    for match in pattern.finditer(f.read()):
        print(match.group(1), match.group(2))
