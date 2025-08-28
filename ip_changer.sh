#!/bin/bash
# IP-CHANGER (Professional Version)
# GitHub-ready Tor-based IP rotation tool

# -------------------------------
# ROOT CHECK
# -------------------------------
if [[ "$EUID" -ne 0 ]]; then
    echo -e "\033[31m[!] Script must be run as root.\033[0m"
    exit 1
fi

# -------------------------------
# DEPENDENCY CHECK
# -------------------------------
if ! command -v curl &> /dev/null || ! command -v tor &> /dev/null; then
    echo -e "\033[33m[!] Please install curl and tor before running this script.\033[0m"
    exit 1
fi

# -------------------------------
# TOR SERVICE START
# -------------------------------
if ! systemctl --quiet is-active tor.service; then
    echo -e "\033[33m[!] Starting Tor service...\033[0m"
    systemctl start tor.service
fi

# -------------------------------
# CUSTOM ASCII BANNER + AUTHOR
# -------------------------------
cat << "EOF"
    ._____________          _________     _____    _______    _____________________________ 
    |   \______   \         \_   ___ \   /  _  \   \      \  /  _____/\_   _____/\______   \
    |   ||     ___/  ______ /    \  \/  /  /_\  \  /   |   \/   \  ___ |    __)_  |       _/
    |   ||    |     /_____/ \     \____/    |    \/    |    \    \_\  \|        \ |    |   \
    |___||____|              \______  /\____|__  /\____|__  /\______  /_______  / |____|_  /
                                    \/         \/         \/        \/        \/         \/ 
                          Author: CYBER-DOME007
EOF

# -------------------------------
# FUNCTIONS
# -------------------------------
get_ip() {
    curl -s -x socks5h://127.0.0.1:9050 https://checkip.amazonaws.com
}

change_ip() {
    systemctl reload tor.service
    sleep 5
    echo -e "\033[32m[+] New IP: $(get_ip)\033[0m"
}

# -------------------------------
# PROMPT USER FOR INTERVAL AND COUNT
# -------------------------------
while true; do
    read -rp $'\033[34mEnter interval between IP changes in seconds (e.g., 15): \033[0m' interval
    if [[ "$interval" =~ ^[0-9]+$ ]] && [[ "$interval" -ge 1 ]]; then
        break
    else
        echo -e "\033[31m[!] Invalid input. Enter a number greater than 0.\033[0m"
    fi
done

while true; do
    read -rp $'\033[34mEnter number of IP changes (0 = infinite): \033[0m' count
    if [[ "$count" =~ ^[0-9]+$ ]] && [[ "$count" -ge 0 ]]; then
        break
    else
        echo -e "\033[31m[!] Invalid input. Enter 0 or a positive number.\033[0m"
    fi
done

# -------------------------------
# MAIN LOOP
# -------------------------------
if [[ "$count" -eq 0 ]]; then
    echo -e "\033[33m[*] Starting infinite IP changes with $interval seconds interval (Ctrl+C to stop)...\033[0m"
    while true; do
        change_ip
        sleep "$interval"
    done
else
    echo -e "\033[33m[*] Starting $count IP changes with $interval seconds interval...\033[0m"
    for ((i=1; i<=count; i++)); do
        echo -e "\033[36m[INFO] Change #$i\033[0m"
        change_ip
        sleep "$interval"
    done
    echo -e "\033[32m[+] Finished $count IP changes.\033[0m"
fi
