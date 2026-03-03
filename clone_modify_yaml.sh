#!/bin/bash
# from https://github.com/oneclickvirt/lxc_arm_images
# Thanks https://github.com/lxc/lxc-ci/tree/main/images

BASE_DIR="${GITHUB_WORKSPACE:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

cd "$BASE_DIR/images_yaml/"

# debian
rm -rf debian.yaml
wget https://raw.githubusercontent.com/lxc/lxc-ci/main/images/debian.yaml
chmod 777 debian.yaml
insert_content_1="    - curl\n    - wget\n    - bash\n    - lsof\n    - sshpass\n    - openssh-server\n    - iptables\n    - dos2unix\n    - cron"
sed -i "/- vim/ a\\$insert_content_1" debian.yaml
insert_content_2=$(cat $BASE_DIR/bash_insert_content.text)
line_number=$(($(wc -l < debian.yaml) - 2))
head -n $line_number debian.yaml > temp.yaml
echo "$insert_content_2" >> temp.yaml
tail -n 2 debian.yaml >> temp.yaml
mv temp.yaml debian.yaml
sed -i -e '/mappings:/i \ ' debian.yaml

# ubuntu
rm -rf ubuntu.yaml
wget https://raw.githubusercontent.com/lxc/lxc-ci/main/images/ubuntu.yaml
chmod 777 ubuntu.yaml
insert_content_1="    - curl\n    - wget\n    - bash\n    - lsof\n    - sshpass\n    - openssh-server\n    - iptables\n    - dos2unix\n    - cron"
sed -i "/- vim/ a\\$insert_content_1" ubuntu.yaml
insert_content_2=$(cat $BASE_DIR/bash_insert_content.text)
line_number=$(($(wc -l < ubuntu.yaml) - 2))
head -n $line_number ubuntu.yaml > temp.yaml
echo "$insert_content_2" >> temp.yaml
tail -n 2 ubuntu.yaml >> temp.yaml
mv temp.yaml ubuntu.yaml
sed -i -e '/mappings:/i \ ' ubuntu.yaml

# kali
rm -rf kali.yaml
wget https://raw.githubusercontent.com/lxc/lxc-ci/main/images/kali.yaml
chmod 777 kali.yaml
insert_content_1="    - curl\n    - wget\n    - bash\n    - lsof\n    - sshpass\n    - openssh-server\n    - iptables\n    - dos2unix\n    - cron"
sed -i "/- systemd/ a\\$insert_content_1" kali.yaml
insert_content_2=$(cat $BASE_DIR/bash_insert_content.text)
line_number=$(($(wc -l < kali.yaml) - 2))
head -n $line_number kali.yaml > temp.yaml
echo "$insert_content_2" >> temp.yaml
tail -n 2 kali.yaml >> temp.yaml
mv temp.yaml kali.yaml
sed -i -e '/mappings:/i \ ' kali.yaml

# centos
rm -rf centos.yaml
wget https://raw.githubusercontent.com/lxc/lxc-ci/main/images/centos.yaml
chmod 777 centos.yaml
# epel-relase 不可用 cron 不可用
insert_content_1="    - curl\n    - wget\n    - bash\n    - lsof\n    - sshpass\n    - openssh-server\n    - iptables\n    - dos2unix\n    - cronie"
sed -i "/- vim-minimal/ a\\$insert_content_1" centos.yaml
insert_content_2=$(cat $BASE_DIR/bash_insert_content.text)
cat centos.yaml > temp.yaml
echo "" >> temp.yaml
echo "$insert_content_2" >> temp.yaml
mv temp.yaml centos.yaml

# almalinux
rm -rf almalinux.yaml
wget https://raw.githubusercontent.com/lxc/lxc-ci/main/images/almalinux.yaml
chmod 777 almalinux.yaml
# cron 不可用
insert_content_1="    - curl\n    - wget\n    - bash\n    - lsof\n    - sshpass\n    - openssh-server\n    - iptables\n    - dos2unix\n    - cronie"
sed -i "/- vim-minimal/ a\\$insert_content_1" almalinux.yaml
insert_content_2=$(cat $BASE_DIR/bash_insert_content.text)
cat almalinux.yaml > temp.yaml
echo "" >> temp.yaml
echo "$insert_content_2" >> temp.yaml
mv temp.yaml almalinux.yaml
# 修复 AlmaLinux 10 GPG key 名称变化问题
python3 - <<'PYEOF'
import re, sys
with open('almalinux.yaml', 'r') as f:
    content = f.read()
# 在 actions: 节层前面插入 post-unpack 动作，为 release 10 修复 repos 中的 GPG key 路径
gpg_fix_action = """
- trigger: post-unpack
  action: |-
    #!/bin/sh
    set -eux
    # AlmaLinux 10 的 GPG key 文件名称变更，修复 repo 中的 gpgkey 引用
    key_file=""
    for k in /etc/pki/rpm-gpg/RPM-GPG-KEY-AlmaLinux-10 \
              /etc/pki/rpm-gpg/RPM-GPG-KEY-AlmaLinux10 \
              /etc/pki/rpm-gpg/RPM-GPG-KEY-AlmaLinux; do
        [ -f "$k" ] && key_file="$k" && break
    done
    if [ -n "$key_file" ]; then
        rpm --import "$key_file" || true
        for repo in /etc/yum.repos.d/*.repo; do
            sed -i "s|gpgkey=.*|gpgkey=file://$key_file|g" "$repo" || true
        done
    else
        # 找不到对应 key 时临时关闭 gpgcheck
        sed -i 's/gpgcheck=1/gpgcheck=0/g' /etc/yum.repos.d/*.repo || true
    fi
  releases:
  - "10"
"""
# 在第一个 'actions:' 标记后插入
insert_pos = content.find('\nactions:')
if insert_pos != -1:
    content = content[:insert_pos] + gpg_fix_action + content[insert_pos:]
with open('almalinux.yaml', 'w') as f:
    f.write(content)
PYEOF

# rockylinux
rm -rf rockylinux.yaml
wget https://raw.githubusercontent.com/lxc/lxc-ci/main/images/rockylinux.yaml
chmod 777 rockylinux.yaml
# cron 不可用
insert_content_1="    - curl\n    - wget\n    - bash\n    - lsof\n    - sshpass\n    - openssh-server\n    - iptables\n    - dos2unix\n    - cronie"
sed -i "/- vim-minimal/ a\\$insert_content_1" rockylinux.yaml
insert_content_2=$(cat $BASE_DIR/bash_insert_content.text)
cat rockylinux.yaml > temp.yaml
echo "" >> temp.yaml
echo "$insert_content_2" >> temp.yaml
mv temp.yaml rockylinux.yaml
# 修复 Rocky Linux 10 GPG key 名称变化问题
python3 - <<'PYEOF'
import re, sys
with open('rockylinux.yaml', 'r') as f:
    content = f.read()
gpg_fix_action = """
- trigger: post-unpack
  action: |-
    #!/bin/sh
    set -eux
    # Rocky Linux 10 的 GPG key 文件名称为 RPM-GPG-KEY-Rocky-10
    key_file=""
    for k in /etc/pki/rpm-gpg/RPM-GPG-KEY-Rocky-10 \
              /etc/pki/rpm-gpg/RPM-GPG-KEY-rockylinux10 \
              /etc/pki/rpm-gpg/RPM-GPG-KEY-rockyofficial; do
        [ -f "$k" ] && key_file="$k" && break
    done
    if [ -n "$key_file" ]; then
        rpm --import "$key_file" || true
        for repo in /etc/yum.repos.d/*.repo; do
            sed -i "s|gpgkey=.*|gpgkey=file://$key_file|g" "$repo" || true
        done
    else
        # 找不到对应 key 时临时关闭 gpgcheck
        sed -i 's/gpgcheck=1/gpgcheck=0/g' /etc/yum.repos.d/*.repo || true
    fi
  releases:
  - "10"
"""
insert_pos = content.find('\nactions:')
if insert_pos != -1:
    content = content[:insert_pos] + gpg_fix_action + content[insert_pos:]
with open('rockylinux.yaml', 'w') as f:
    f.write(content)
PYEOF

# oracle
rm -rf oracle.yaml
wget https://raw.githubusercontent.com/lxc/lxc-ci/main/images/oracle.yaml
chmod 777 oracle.yaml
# cron 不可用
insert_content_1="    - curl\n    - wget\n    - bash\n    - lsof\n    - sshpass\n    - openssh-server\n    - iptables\n    - dos2unix\n    - cronie"
sed -i "/- vim-minimal/ a\\$insert_content_1" oracle.yaml
insert_content_2=$(cat $BASE_DIR/bash_insert_content.text)
cat oracle.yaml > temp.yaml
echo "" >> temp.yaml
echo "$insert_content_2" >> temp.yaml
mv temp.yaml oracle.yaml

# archlinux
rm -rf archlinux.yaml
wget https://raw.githubusercontent.com/lxc/lxc-ci/main/images/archlinux.yaml
chmod 777 archlinux.yaml
# cronie 不可用 cron 不可用
insert_content_1="    - curl\n    - wget\n    - bash\n    - lsof\n    - sshpass\n    - iptables\n    - dos2unix"
sed -i "/- which/ a\\$insert_content_1" archlinux.yaml
insert_content_2=$(cat $BASE_DIR/bash_insert_content.text)
line_number=$(($(wc -l < archlinux.yaml) - 2))
head -n $line_number archlinux.yaml > temp.yaml
echo "$insert_content_2" >> temp.yaml
tail -n 2 archlinux.yaml >> temp.yaml
mv temp.yaml archlinux.yaml
sed -i -e '/mappings:/i \ ' archlinux.yaml
# 修复 ARM 架构：移除会导致构建失败的 kernel/openssh remove 块，保留 openssh 安装
python3 - <<'PYEOF'
import re
with open('archlinux.yaml', 'r') as f:
    content = f.read()
# 移除 linux-aarch64 remove 块（ARM bootstrap 中内核依赖复杂，移除可能失败）
content = re.sub(
    r'\n  - packages:\n    - linux-aarch64\n    action: remove\n    architectures:\n    - aarch64\n    types:\n    - container',
    '', content)
# 移除 linux-armv7 remove 块
content = re.sub(
    r'\n  - packages:\n    - linux-armv7\n    action: remove\n    architectures:\n    - armv7',
    '', content)
# 从 ARM remove 块中去掉 openssh（aarch64/armv7 构建需要 openssh 提供 sshd）
content = re.sub(
    r'(\n  - packages:\n    - libedit\n    - net-tools)\n    - openssh(\n    action: remove\n    architectures:\n    - aarch64\n    - armv7)',
    r'\1\2', content)
with open('archlinux.yaml', 'w') as f:
    f.write(content)
PYEOF

# gentoo
rm -rf gentoo.yaml
wget https://raw.githubusercontent.com/lxc/lxc-ci/main/images/gentoo.yaml
chmod 777 gentoo.yaml
# cronie 不可用 cron 不可用
insert_content_1="    - curl\n    - wget\n    - bash\n    - lsof\n    - sshpass\n    - iptables\n    - dos2unix"
sed -i "/- sudo/ a\\$insert_content_1" gentoo.yaml
insert_content_2=$(cat $BASE_DIR/bash_insert_content.text)
line_number=$(($(wc -l < gentoo.yaml) - 3))
head -n $line_number gentoo.yaml > temp.yaml
echo "$insert_content_2" >> temp.yaml
tail -n 3 gentoo.yaml >> temp.yaml
mv temp.yaml gentoo.yaml
sed -i -e '/environment:/i \ ' gentoo.yaml
sed -i 's/- default/- openrc/g' gentoo.yaml

# fedora
rm -rf fedora.yaml
wget https://raw.githubusercontent.com/lxc/lxc-ci/main/images/fedora.yaml
chmod 777 fedora.yaml
# cron 不可用
insert_content_1="    - curl\n    - wget\n    - bash\n    - lsof\n    - sshpass\n    - openssh-server\n    - iptables\n    - dos2unix\n    - cronie"
sed -i "/- xz/ a\\$insert_content_1" fedora.yaml
insert_content_2=$(cat $BASE_DIR/bash_insert_content.text)
cat fedora.yaml > temp.yaml
echo "" >> temp.yaml
echo "$insert_content_2" >> temp.yaml
mv temp.yaml fedora.yaml
# fipscheck 在 Fedora 28+ 已被移除，保留会导致构建失败
sed -i '/^    - fipscheck$/d' fedora.yaml
# 将 Koji 源地址改为 Fedora 官方直连地址，解决 fedora-http 下载器在新版本上报
# "Unable to find latest build" 的问题
sed -i 's|url: https://kojipkgs.fedoraproject.org|url: https://dl.fedoraproject.org/pub/fedora/linux/releases|g' fedora.yaml

# alpine
rm -rf alpine.yaml
wget https://raw.githubusercontent.com/lxc/lxc-ci/main/images/alpine.yaml
chmod 777 alpine.yaml
# cronie 不可用 cron 不可用
insert_content_1="    - curl\n    - wget\n    - bash\n    - lsof\n    - sshpass\n    - openssh-server\n    - openssh-keygen\n    - cronie\n    - iptables\n    - dos2unix"
sed -i "/- doas/ a\\$insert_content_1" alpine.yaml
insert_content_2=$(cat $BASE_DIR/sh_insert_content.text)
line_number=$(($(wc -l < alpine.yaml) - 2))
head -n $line_number alpine.yaml > temp.yaml
echo "$insert_content_2" >> temp.yaml
tail -n 2 alpine.yaml >> temp.yaml
mv temp.yaml alpine.yaml
sed -i -e '/mappings:/i \ ' alpine.yaml

# openwrt
rm -rf openwrt.yaml
wget https://raw.githubusercontent.com/lxc/lxc-ci/main/images/openwrt.yaml
chmod 777 openwrt.yaml
# cronie 不可用 cron 不可用
insert_content_1="    - curl\n    - wget\n    - bash\n    - lsof\n    - sshpass\n    - openssh-server\n    - openssh-keygen\n    - iptables"
sed -i "/- sudo/ a\\$insert_content_1" openwrt.yaml
insert_content_2=$(cat $BASE_DIR/sh_insert_content.text)
cat openwrt.yaml > temp.yaml
echo "$insert_content_2" >> temp.yaml
mv temp.yaml openwrt.yaml

# opensuse
rm -rf opensuse.yaml
wget https://raw.githubusercontent.com/lxc/lxc-ci/main/images/opensuse.yaml
chmod 777 opensuse.yaml
# cron 不可用
insert_content_1="    - curl\n    - wget\n    - bash\n    - lsof\n    - sshpass\n    - openssh-server\n    - iptables\n    - dos2unix\n    - cronie"
sed -i "/- vim-minimal/ a\\$insert_content_1" opensuse.yaml
insert_content_2=$(cat $BASE_DIR/bash_insert_content.text)
cat opensuse.yaml > temp.yaml
echo "" >> temp.yaml
echo "$insert_content_2" >> temp.yaml
mv temp.yaml opensuse.yaml

# openeuler
rm -rf openeuler.yaml
wget https://raw.githubusercontent.com/lxc/lxc-ci/main/images/openeuler.yaml
chmod 777 openeuler.yaml
# cron 不可用
insert_content_1="    - curl\n    - wget\n    - bash\n    - lsof\n    - sshpass\n    - openssh-server\n    - iptables\n    - dos2unix\n    - cronie"
sed -i "/- vim-minimal/ a\\$insert_content_1" openeuler.yaml
insert_content_2=$(cat $BASE_DIR/bash_insert_content.text)
cat openeuler.yaml > temp.yaml
echo "" >> temp.yaml
echo "$insert_content_2" >> temp.yaml
mv temp.yaml openeuler.yaml

cd $BASE_DIR
# 更新支持的镜像列表
build_or_list_images() {
    local versions=()
    local ver_nums=()
    local variants=()
    read -ra versions <<< "$1"
    read -ra ver_nums <<< "$2"
    read -ra variants <<< "$3"
    local architectures=("$build_arch")
    local len=${#versions[@]}
    for ((i = 0; i < len; i++)); do
        version=${versions[i]}
        ver_num=${ver_nums[i]}
        for arch in "${architectures[@]}"; do
            for variant in "${variants[@]}"; do
                local url="https://github.com/oneclickvirt/lxc_arm_images/releases/download/${run_funct}/${run_funct}_${ver_num}_${version}_${arch}_${variant}.tar.xz"
                if curl --output /dev/null --silent --head --fail "$url"; then
                    echo "${run_funct}_${ver_num}_${version}_${arch}_${variant}.tar.xz" >> all_images.txt
                else
                    echo "File not found: $url"
                fi
            done
        done
    done
}

# 不同发行版的配置
# build_or_list_images 镜像名字 镜像版本号 variants的值
build_arch="arm64"
run_funct="debian"
build_or_list_images "bullseye bookworm trixie" "11 12 13" "default cloud"
run_funct="ubuntu"
build_or_list_images "bionic focal jammy noble" "18.04 20.04 22.04 24.04" "default cloud"
run_funct="kali"
build_or_list_images "kali-rolling" "latest" "default cloud"
run_funct="archlinux"
build_or_list_images "current" "current" "default cloud"
run_funct="gentoo"
build_or_list_images "current" "current" "cloud systemd openrc"
run_funct="centos"
build_or_list_images "9-Stream" "9" "default cloud"
run_funct="almalinux"
build_or_list_images "8 9 10" "8 9 10" "default cloud"
run_funct="rockylinux"
build_or_list_images "8 9 10" "8 9 10" "default cloud"
run_funct="alpine"
build_or_list_images "3.19 3.20 3.21" "3.19 3.20 3.21" "default cloud"
run_funct="openwrt"
build_or_list_images "23.05 24.10" "23.05 24.10" "default cloud"
run_funct="oracle"
build_or_list_images "8 9" "8 9" "default cloud"
run_funct="fedora"
# Fedora 42 尚未正式发布（预计 2026-04），暂只构建 41
build_or_list_images "40 41" "40 41" "default cloud"
run_funct="opensuse"
build_or_list_images "15.6 tumbleweed" "15.6 tumbleweed" "default cloud"
run_funct="openeuler"
build_or_list_images "22.03 24.03" "22.03 24.03" "default cloud"
# 去除重复行
remove_duplicate_lines() {
    # 预处理：去除行尾空格和制表符
    sed -i 's/[ \t]*$//' "$1"
    # 去除重复行并跳过空行和注释行
    if [ -f "$1" ]; then
        awk '{ line = $0; gsub(/^[ \t]+/, "", line); gsub(/[ \t]+/, " ", line); if (!NF || !seen[line]++) print $0 }' "$1" >"$1.tmp" && mv -f "$1.tmp" "$1"
    fi
}
remove_duplicate_lines "all_images.txt"
sed -i '/^$/d' "all_images.txt"
