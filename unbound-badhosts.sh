#!/bin/sh
# work in progress
trap cleanup EXIT

tmpbuf=$(mktemp) || exit 1
tmpbufsorted=$(mktemp) || exit 1

cleanup() {
    rm -f $tmpbuf $tmpbufsorted
}

error() {
    echo "$(basename $0): ${1:-"Unknown Error"}" 1>&2
    exit 1
}

while read url; do
    buf=$(ftp -o - "$url" | grep -v '^#' | grep -oE '([a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,}' >> $tmpbuf) || error "failed working on $url"
done << EOF
http://sysctl.org/cameleon/hosts
http://winhelp2002.mvps.org/hosts.txt
https://adaway.org/hosts.txt
https://hostfiles.frogeye.fr/firstparty-trackers-hosts.txt
https://hostfiles.frogeye.fr/multiparty-trackers-hosts.txt
https://hosts.nfz.moe/basic/hosts
https://hostsfile.mine.nu/hosts0.txt
https://hostsfile.org/Downloads/hosts.txt
https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext
https://block.energized.pro/ultimate/formats/domains.txt
https://raw.githubusercontent.com/FadeMind/hosts.extras/master/UncheckyAds/hosts
https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.2o7Net/hosts
https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Risk/hosts
https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Spam/hosts
https://raw.githubusercontent.com/PolishFiltersTeam/KADhosts/master/KADhosts_without_controversies.txt
https://raw.githubusercontent.com/StevenBlack/hosts/master/data/KADhosts/hosts
https://raw.githubusercontent.com/StevenBlack/hosts/master/data/UncheckyAds/hosts
https://raw.githubusercontent.com/StevenBlack/hosts/master/data/add.2o7Net/hosts
https://raw.githubusercontent.com/StevenBlack/hosts/master/data/add.Risk/hosts
https://raw.githubusercontent.com/StevenBlack/hosts/master/data/add.Spam/hosts
https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
https://raw.githubusercontent.com/bigdargon/hostsVN/master/hosts
https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt
https://raw.githubusercontent.com/hectorm/hmirror/master/data/kadhosts/list.txt
https://raw.githubusercontent.com/hectorm/hmirror/master/data/mitchellkrogza-badd-boyz-hosts/list.txt
https://raw.githubusercontent.com/jdlingyu/ad-wars/master/hosts
https://raw.githubusercontent.com/mitchellkrogza/Badd-Boyz-Hosts/master/hosts
https://raw.githubusercontent.com/r-a-y/mobile-hosts/master/AdguardMobileAds.txt
https://raw.githubusercontent.com/r-a-y/mobile-hosts/master/AdguardMobileSpyware.txt
https://raw.githubusercontent.com/vokins/yhosts/master/hosts
https://reddestdream.github.io/Projects/MinimalHosts/etc/MinimalHostsBlocker/minimalhosts
https://someonewhocares.org/hosts/zero/hosts
https://ssl.bblck.me/blacklists/hosts-file.txt
https://sysctl.org/cameleon/hosts
https://v.firebog.net/hosts/AdguardDNS.txt
https://v.firebog.net/hosts/Airelle-hrsk.txt
https://v.firebog.net/hosts/Airelle-trc.txt
https://v.firebog.net/hosts/BillStearns.txt
https://v.firebog.net/hosts/Easylist.txt
https://v.firebog.net/hosts/Easyprivacy.txt
https://v.firebog.net/hosts/Kowabit.txt
https://v.firebog.net/hosts/Prigent-Ads.txt
https://v.firebog.net/hosts/Prigent-Malware.txt
https://v.firebog.net/hosts/Prigent-Phishing.txt
https://v.firebog.net/hosts/Shalla-mal.txt
https://v.firebog.net/hosts/static/w3kbl.txt
https://winhelp2002.mvps.org/hosts.txt
https://www.github.developerdan.com/hosts/lists/ads-and-tracking-extended.txt
https://www.malwaredomainlist.com/hostslist/hosts.txt
https://zerodot1.gitlab.io/CoinBlockerLists/hosts
https://zerodot1.gitlab.io/CoinBlockerLists/hosts_browser
EOF

sort -iu $tmpbuf > $tmpbufsorted
