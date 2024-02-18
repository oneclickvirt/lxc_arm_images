#!/bin/bash
# from
# https://github.com/oneclickvirt/lxc_arm_images
# 2024.02.09


urls=($(curl -s https://jenkins.linuxcontainers.org/view/Images/job/image-openwrt/api/xml | grep -oP '<url>.*?architecture=arm64.*?</url>' | grep -oP 'https://.*?(?=<\/url>)'))
arm64_urls=()
for url in "${urls[@]}"; do
    if [[ $url == *'architecture=arm64'* ]]; then
        arm64_urls+=("$url")
    fi
done
for url in "${arm64_urls[@]}"; do
    echo "$url"
done
