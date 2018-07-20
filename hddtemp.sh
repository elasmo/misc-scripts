#!/bin/sh
devices=$(geom disk list | grep "Geom name" | cut -f3 -d' ')
msg=""

for device in ${devices}; do
    temperature=$(smartctl -A /dev/${device} | grep "Temperature_Celsius" | awk '{print $10}')
    msg="${msg}${device}='${temperature}' "
done

echo "$(basename $0): ${msg}"
