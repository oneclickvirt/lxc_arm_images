# lxc_arm_images

[![Build LXC ARM images](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/main.yml/badge.svg)](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/main.yml)

## 说明

重命名后保存的镜像列表：https://raw.githubusercontent.com/oneclickvirt/lxc_arm_images/main/fixed_images.txt

默认已安装cloud-init，但其余均未设置

## 上传到对应release

```
# https://api.github.com/repos/oneclickvirt/lxc_arm_images/releases/tags/ubuntu
release_id="142494500"
token=""
for file in *; do
    if [ -f "$file" ]; then
        echo "Uploading $file..."
        curl -s -H "Authorization: Bearer $token" \
             -H "Content-Type: application/zip" \
             --data-binary @"$file" \
             "https://uploads.github.com/repos/oneclickvirt/lxc_arm_images/releases/$release_id/assets?name=$(basename "$file")"
        rm -rf $file
        echo ""
    fi
done
```
