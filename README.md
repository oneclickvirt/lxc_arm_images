# lxc_arm_images

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
