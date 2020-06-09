#!/bin/sh
# 
# Generates a blacklist used for GeoIP blocking using OpenBSD pf
#
# pf.conf example:
# table <geoipblock> persist file "/etc/pf.geoipblock"
# block in quick on egress from <geoipblock> 
#
# https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2#Officially_assigned_code_elements
#
# Preferably updated on a regular basis by using crontab, eg.:
# crontab -e
#     1       *       *       *       /root/scripts/geoipblock.sh > /dev/null 2>&1
country_codes="cn az by kz kg ru tj tm uz vn id"
pf_table="geoipban"
blacklist_tmp=$(mktemp) || exit 1
blacklist="/etc/pf.geoipban"

for cc in ${country_codes}; do 
    ftp -o - http://ipdeny.com/ipblocks/data/countries/${cc}.zone | grep -E -o '^([0-9]{1,3}\.){3}[0-9]{1,3}(\/([0-9]|[1-2][0-9]|3[0-2]))?' >> ${blacklist_tmp}
    sleep 1
done

echo > ${blacklist}
chmod 600 ${blacklist}

sort -u ${blacklist_tmp} | sort -n > ${blacklist}
rm ${blacklist_tmp}

pfctl -t ${pf_table} -T replace -f ${blacklist} || exit 1

logger "${blacklist} blacklist updated."
