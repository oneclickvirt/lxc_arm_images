#!/bin/bash
# from
# https://github.com/oneclickvirt/lxc_arm_images
# 2024.02.18


download_images() {
    local jenkins_url="$1"
    local architecture="$2"
    local urls=()
    local arm64_urls=()
    urls=($(curl -s "$jenkins_url/api/xml" | grep -oP '<url>.*?</url>' | grep -oP 'https://.*?(?=<\/url>)'))
    for url in "${urls[@]}"; do
        if [[ $url == *"$architecture"* ]]; then
            url="${url}lastSuccessfulBuild/artifact/rootfs.tar.xz"
            arm64_urls+=("$url")
        fi
    done
    for url in "${arm64_urls[@]}"; do
        system=$(echo "$url" | sed 's/.*image-\([^\/]*\)\/.*/\1/')
        release=$(echo "$url" | grep -oP 'release=\K[^,&]+')
        variant=$(echo "$url" | grep -oP 'variant=\K[^/&]+')
        new_filename="${system}-${architecture}-${release}-${variant}.tar.xz"
        echo "Downloading $url as $new_filename..."
        curl -o "$new_filename" -L "$url"
    done
}

jenkins_urls=(
    "https://jenkins.linuxcontainers.org/view/Images/job/image-debian"
    "https://jenkins.linuxcontainers.org/view/Images/job/image-ubuntu"
    "https://jenkins.linuxcontainers.org/view/Images/job/image-kali"
    "https://jenkins.linuxcontainers.org/view/Images/job/image-centos"
    "https://jenkins.linuxcontainers.org/view/Images/job/image-rockylinux"
    "https://jenkins.linuxcontainers.org/view/Images/job/image-almalinux"
    "https://jenkins.linuxcontainers.org/view/Images/job/image-alpine"
    "https://jenkins.linuxcontainers.org/view/Images/job/image-openwrt"
    "https://jenkins.linuxcontainers.org/view/Images/job/image-oracle"
    "https://jenkins.linuxcontainers.org/view/Images/job/image-opensuse"
    "https://jenkins.linuxcontainers.org/view/Images/job/image-fedora"
    "https://jenkins.linuxcontainers.org/view/Images/job/image-openeuler"
    "https://jenkins.linuxcontainers.org/view/Images/job/image-gentoo"
    "https://jenkins.linuxcontainers.org/view/Images/job/image-devuan"
)

for jenkins_url in "${jenkins_urls[@]}"; do
    if [[ $jenkins_url == *"openwrt"* ]]; then
        download_images "$jenkins_url" "arm64"
    elif [[ $jenkins_url == *"oracle"* ]]; then
        download_images "$jenkins_url" "arm64"
    fi
done
