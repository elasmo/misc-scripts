#!/usr/bin/env bash

for c in {1..256}; do
    printf "\e[38;5;${c}m${c}\e[0m\t"

    if [ $(($c % 10)) -eq 0 ]; then
        echo
    fi
done

echo
