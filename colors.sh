#!/usr/bin/env bash

for c in {1..256}; do
    printf "\e[38;5;${c}m38;5;${c}\e[0m\t"

    if [ $(($c % 6)) -eq 0 ]; then
        echo
    fi
done

echo
