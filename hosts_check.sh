#!/bin/bash

verifica_ip() {
    local ip="$1"

    if [[ ! "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        return 1
    fi

    IFS='.' read -r a b c d <<< "$ip"

    for octet in "$a" "$b" "$c" "$d"; do
        if (( octet < 0 || octet > 255 )); then
            return 1
        fi
    done

    return 0
}

verifica_host_ip() {
    local hostname="$1"
    local ip="$2"
    local dns_server="$3"

    if ! verifica_ip "$ip"; then
        echo "IP invalid: $ip"
        return 1
    fi

    local rezultat
    rezultat=$(dig +time=2 +tries=1 +short @"$dns_server" "$hostname" A)

    if [[ "$rezultat" == "$ip" ]]; then
        echo "Corect: $hostname -> $ip"
        return 0
    else
        echo "Incorect: $hostname -> $ip"
        echo "Raspuns DNS primit: ${rezultat:-niciun raspuns}"
        return 1
    fi
}

DNS_SERVER="8.8.8.8"

while read -r ip hostname rest; do

    [[ -z "$ip" || "$ip" == \#* ]] && continue
    if [[ "$ip" == *:* ]]; then
        continue
    fi
    if [[ "$hostname" == "localhost" || "$hostname" == "student-VM" ]]; then
	echo "Host local ignorat: $hostname"
	continue
    fi
    if verifica_ip "$ip"; then
        verifica_host_ip "$hostname" "$ip" "$DNS_SERVER"
    else
        echo "IP invalid in /etc/hosts: $ip"
    fi

done < /etc/hosts
