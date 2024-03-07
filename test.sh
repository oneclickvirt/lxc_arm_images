#!/bin/bash
# by https://github.com/oneclickvirt/lxc_arm_images
# 2024.03.06
# curl -L https://raw.githubusercontent.com/oneclickvirt/lxc_arm_images/main/test.sh -o test.sh && chmod +x test.sh && ./test.sh
#!/bin/bash

log_file="log"
fixed_images_file="fixed_images.txt"
date=$(date)
rm -rf "$log_file"
rm -rf "fixed_images.txt"
echo "$date" >> "$log_file"
echo "------------------------------------------" >> "$log_file"
release_names=("ubuntu" "debian" "kali" "centos" "almalinux" "rockylinux" "fedora" "opensuse" "alpine" "archlinux" "gentoo" "openwrt" "oracle" "openeuler")
system_names=()
response=$(curl -slk -m 6 "https://raw.githubusercontent.com/oneclickvirt/lxc_arm_images/main/all_images.txt")
if [ $? -eq 0 ] && [ -n "$response" ]; then
    system_names+=($(echo "$response"))
fi
for release_name in "${release_names[@]}"; do
    temp_images=()
    for sy in "${system_names[@]}"; do
        if [[ $sy == "${release_name}"* ]]; then
            # Check if the file exists
            if curl --output /dev/null --silent --head --fail "https://github.com/oneclickvirt/lxc_arm_images/releases/download/${release_name}/${sy}"; then
                temp_images+=("$sy")
            else
                if curl --output /dev/null --silent --head --fail "https://cdn.spiritlhl.net/https://github.com/oneclickvirt/lxc_arm_images/releases/download/${release_name}/${sy}"; then
                    temp_images+=("$sy")
                fi
            fi
        fi
    done
    for image_name in "${temp_images[@]}"; do
        echo "$image_name"
        echo "$image_name" >> "$log_file"
        echo "$image_name" >> "$fixed_images_file"
        echo "------------------------------------------" >> "$log_file"
    done
done
