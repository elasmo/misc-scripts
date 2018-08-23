#!/bin/sh
# 
# Generates a blacklist used  for GeoIP blocking using OpenBSD pf
#
# pf.conf example:
# table <geoip_blacklist> persist file "/etc/pf/geoip_blacklist"
# block in quick on egress from <geoip_blacklist> 
#
# https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2#Officially_assigned_code_elements
#
country_codes="cn az by kz kg ru tj tm uz vn"
pf_dir="/etc/pf"
pf_table="geoip_blacklist"
blacklist="${pf_dir}/geoip_blacklist"

echo > ${blacklist}
chmod 600 ${blacklist}

for cc in ${country_codes}; do 
    ftp -o - http://ipdeny.com/ipblocks/data/countries/${cc}.zone >> ${blacklist}
    sleep 1
done

pfctl -t ${pf_table} -T replace -f ${blacklist}

logger "${blacklist} blacklist updated."
