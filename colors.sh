#!/usr/bin/env bash
bold="\e[1m"
uline="\e[4m"
rev="\e[7m"
reset="\e[0m"

for c in {0..255}; do
    printf "\e[38;5;%sm%s\e[0m\t" ${c} ${c}
	printf "\e[1m"
    printf "\e[38;5;%sm%s${reset}\t" ${c} ${c}

	[ $((${c}%10)) -eq 0 ] && printf "\n"
done

echo
