#!/usr/bin/env python3
#
# Sloppy script to parse greppable nmap output (-oG)
#
import re
import sys

with open(sys.argv[1]) as fp:
    for line in fp:
        fields = line.split('\t')

        if fields[0].startswith("Host"):
            host_line = fields[0].split(" ")

            # Pick out IP address and hostname
            ip_addr   = host_line[1]
            hostname  = re.sub('\(|\)', '', host_line[2])

            if fields[1].startswith("Ports"):
                ports_line = fields[1].split(', ')

                # Loop over discovered ports
                for ports in ports_line:

                    # Remove trailing slash
                    ports = re.sub('/$', '', ports)

                    # Pick out fields
                    [ port, state, proto, owner, service, rpc_info, version ] \
                            = ports.split('/', 6);

                    # Skip to next if state isn't set to open
                    if state != "open":
                        continue

                    # Remove leading "Ports:" string 
                    port = re.sub("^Ports: ", '', port)

                    # Nmap substitues "|" for "/", change it back
                    service = re.sub('\|', '/', service)
                    version = re.sub('\|', '/', version)
