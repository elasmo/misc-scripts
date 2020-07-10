#!/usr/bin/env python3
#
# Sloppy script to parse greppable nmap output (-oG)
#
import re
import sys

with open(sys.argv[1], "r") as fp:
    for line in fp:
        fields = line.split("\t")

        if fields[0].startswith("Host"):
            host_line = fields[0].split(" ")
            ip_addr   = host_line[1]
            hostname  = re.sub("\(|\)", "", host_line[2])

            if fields[1].startswith("Ports"):
                ports = fields[1].split(", ")

                # Iterate over discovered ports
                for port_field in ports:

                    # Port field ends with "/", we don't want to include that in our output
                    port_field = re.sub("/$", "", port_field)

                    # Pick out fields
                    [ port, state, protocol, owner, service, rpc_info, version ] = port_field.split('/', 6);

                    # Skip to next item if port is closed
                    if state != 'open':
                        continue

                    # First field starts with "Ports: ", we don't want that
                    port = re.sub("^Ports: ", "", port)

                    # Nmap substitues "|" for "/" to not break parsing, change it back
                    service = re.sub("\|", "/", service)
                    version = re.sub("\|", "/", version)
