#!/bin/bash
# by https://github.com/oneclickvirt/lxc_arm_images
# 2024.03.06
# curl -L https://raw.githubusercontent.com/oneclickvirt/lxc_arm_images/main/test.sh -o test.sh && chmod +x test.sh && ./test.sh

rm -rf log
rm -rf fixed_images.txt
date=$(date)
echo "$date" >>log
echo "------------------------------------------" >>log
release_names=("ubuntu" "debian" "kali" "centos" "almalinux" "rockylinux" "fedora" "opensuse" "alpine" "archlinux" "gentoo" "openwrt" "oracle" "openeuler")
system_names=()
response=$(curl -slk -m 6 "https://raw.githubusercontent.com/oneclickvirt/lxc_arm_images/main/all_images.txt")
if [ $? -eq 0 ] && [ -n "$response" ]; then
    system_names+=($(echo "$response"))
fi
for ((i = 0; i < ${#release_names[@]}; i++)); do
    release_name="${release_names[i]}"
    temp_images=()
    for sy in "${system_names[@]}"; do
        if [[ $sy == "${release_name}"* ]]; then
            curl -m 60 -LO "https://github.com/oneclickvirt/lxc_arm_images/releases/download/${release_name}/${sy}"
            if [ $? -ne 0 ]; then
                curl -m 60 -LO "https://cdn.spiritlhl.net/https://github.com/oneclickvirt/lxc_arm_images/releases/download/${release_name}/${sy}"
            fi
            temp_images+=("${sy}")
        fi
    done
    for image_name in "${temp_images[@]}"; do
        echo "$image_name"
        echo "$image_name" >>log
        echo "$image_name" >>fixed_images.txt
    done
done
