#!/bin/bash

if [ -z "$1" ]; then
    echo "Error: GITHUB_TOKEN not provided"
    exit 1
fi

echo "Checking GITHUB_TOKEN (first 4 characters): ${GITHUB_TOKEN:0:4}"
GITHUB_TOKEN="$1"

# apt-get update
# apt-get install -y sudo
# sudo apt-get install -y zip jq snapd debootstrap
# sudo snap install distrobuilder --classic

# distros=("ubuntu" "oracle" "openeuler")
distro="$2"
if [ -n $distro ]; then
    echo "Processing distro: $distro"
    zip_name_list=($(bash build_images.sh $distro false arm64 | tail -n 1))
    echo "Zip name list: ${zip_name_list[*]}"
    release_id=$(curl -s -H "Accept: application/vnd.github.v3+json" "https://api.github.com/repos/oneclickvirt/lxc_arm_images/releases/tags/$distro" | jq -r ".id")
    echo "Release ID: $release_id"
    echo "Building $distro and package zips"
    bash build_images.sh $distro true arm64
    # 计算数组的中点
    half=$(( (${#zip_name_list[@]} + 1) / 2 ))
    first_half=("${zip_name_list[@]:0:half}")
    second_half=("${zip_name_list[@]:half}")
    # 处理命令行参数
    if [ "$3" == "first" ]; then
        echo "Processing first half:"
        for file in "${first_half[@]}"; do
            echo "Processing file: $file"
            if [ -f "$file" ] && [ $(stat -c %s "$file") -gt 10485760 ]; then
                echo "Checking if $file already exists in release..."
                existing_asset_id=$(curl -s -H "Accept: application/vnd.github.v3+json" \
                "https://api.github.com/repos/oneclickvirt/lxc_arm_images/releases/$release_id/assets" \
                | jq -r --arg name "$(basename "$file")" '.[] | select(.name == $name) | .id')
                
                if [ -n "$existing_asset_id" ]; then
                    echo "Asset $file already exists in release, deleting existing asset..."
                    delete_response=$(curl -s -X DELETE -H "Authorization: Bearer $GITHUB_TOKEN" "https://api.github.com/repos/oneclickvirt/lxc_arm_images/releases/assets/$existing_asset_id")
                    echo "Delete response: $delete_response"
                    if [ $? -eq 0 ] && ! echo "$delete_response" | grep -q "error"; then
                        echo "Existing asset deleted successfully."
                    else
                        echo "Failed to delete existing asset. Skipping file upload..."
                        rm -f "$file"
                        continue
                    fi
                else
                    echo "No existing $file file."
                fi
                
                echo "Uploading $file to release..."
                upload_response=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
                -H "Content-Type: application/zip" \
                --data-binary @"$file" \
                "https://uploads.github.com/repos/oneclickvirt/lxc_arm_images/releases/$release_id/assets?name=$(basename "$file")")
                echo "Upload response: $upload_response"
                rm -f "$file"
            else
                echo "No $file or file is less than 10 MB"
            fi
        done
    elif [ "$3" == "second" ]; then
        echo "Processing second half:"
        for file in "${second_half[@]}"; do
            echo "Processing file: $file"
            if [ -f "$file" ] && [ $(stat -c %s "$file") -gt 10485760 ]; then
                echo "Checking if $file already exists in release..."
                existing_asset_id=$(curl -s -H "Accept: application/vnd.github.v3+json" \
                "https://api.github.com/repos/oneclickvirt/lxc_arm_images/releases/$release_id/assets" \
                | jq -r --arg name "$(basename "$file")" '.[] | select(.name == $name) | .id')
                
                if [ -n "$existing_asset_id" ]; then
                    echo "Asset $file already exists in release, deleting existing asset..."
                    delete_response=$(curl -s -X DELETE -H "Authorization: Bearer $GITHUB_TOKEN" "https://api.github.com/repos/oneclickvirt/lxc_arm_images/releases/assets/$existing_asset_id")
                    echo "Delete response: $delete_response"
                    if [ $? -eq 0 ] && ! echo "$delete_response" | grep -q "error"; then
                        echo "Existing asset deleted successfully."
                    else
                        echo "Failed to delete existing asset. Skipping file upload..."
                        rm -f "$file"
                        continue
                    fi
                else
                    echo "No existing $file file."
                fi
                
                echo "Uploading $file to release..."
                upload_response=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
                -H "Content-Type: application/zip" \
                --data-binary @"$file" \
                "https://uploads.github.com/repos/oneclickvirt/lxc_arm_images/releases/$release_id/assets?name=$(basename "$file")")
                echo "Upload response: $upload_response"
                rm -f "$file"
            else
                echo "No $file or file is less than 10 MB"
            fi
        done
    else
        echo "Usage: $0 {first|second}"
        exit 1
    fi
fi
