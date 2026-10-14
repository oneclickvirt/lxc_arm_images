#!/bin/bash
set -eo pipefail
source "$CI_IMAGE_SCRIPT_ROOT/ci_network.sh"
# from https://github.com/oneclickvirt/lxc_arm_images
# Thanks https://github.com/lxc/lxc-ci/tree/main/images

BASE_DIR="${GITHUB_WORKSPACE:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

cd "$BASE_DIR/images_yaml/"

# debian
rm -rf debian.yaml
wget https://raw.githubusercontent.com/lxc/lxc-ci/main/images/debian.yaml
insert_content_1="    - curl\n    - wget\n    - bash\n    - lsof\n    - sshpass\n    - openssh-server\n    - iptables\n    - dos2unix\n    - cron"
sed -i "/- vim/ a\\$insert_content_1" debian.yaml
"$CI_IMAGE_PYTHON" "$CI_IMAGE_SCRIPT_ROOT/append_image_actions.py" "debian.yaml" "$CI_IMAGE_SCRIPT_ROOT/../../bash_insert_content.text"
sed -i -e '/mappings:/i \ ' debian.yaml

# ubuntu
rm -rf ubuntu.yaml
wget https://raw.githubusercontent.com/lxc/lxc-ci/main/images/ubuntu.yaml
insert_content_1="    - curl\n    - wget\n    - bash\n    - lsof\n    - sshpass\n    - openssh-server\n    - iptables\n    - dos2unix\n    - cron"
sed -i "/- vim/ a\\$insert_content_1" ubuntu.yaml
"$CI_IMAGE_PYTHON" "$CI_IMAGE_SCRIPT_ROOT/append_image_actions.py" "ubuntu.yaml" "$CI_IMAGE_SCRIPT_ROOT/../../bash_insert_content.text"
sed -i -e '/mappings:/i \ ' ubuntu.yaml

# kali
rm -rf kali.yaml
wget https://raw.githubusercontent.com/lxc/lxc-ci/main/images/kali.yaml
insert_content_1="    - curl\n    - wget\n    - bash\n    - lsof\n    - sshpass\n    - openssh-server\n    - iptables\n    - dos2unix\n    - cron"
sed -i "/- systemd/ a\\$insert_content_1" kali.yaml
# Replace upstream ifupdown with ifupdown2 for the default variant
sed -i 's/^    - ifupdown$/    - ifupdown2/' kali.yaml
"$CI_IMAGE_PYTHON" "$CI_IMAGE_SCRIPT_ROOT/append_image_actions.py" "kali.yaml" "$CI_IMAGE_SCRIPT_ROOT/../../bash_insert_content.text"
sed -i -e '/mappings:/i \ ' kali.yaml

# centos
rm -rf centos.yaml
wget https://raw.githubusercontent.com/lxc/lxc-ci/main/images/centos.yaml
# epel-relase 不可用 cron 不可用
insert_content_1="    - curl\n    - wget\n    - bash\n    - lsof\n    - sshpass\n    - openssh-server\n    - iptables\n    - dos2unix\n    - cronie"
sed -i "/- vim-minimal/ a\\$insert_content_1" centos.yaml
"$CI_IMAGE_PYTHON" "$CI_IMAGE_SCRIPT_ROOT/append_image_actions.py" "centos.yaml" "$CI_IMAGE_SCRIPT_ROOT/../../bash_insert_content.text"

# almalinux
rm -rf almalinux.yaml
wget https://raw.githubusercontent.com/lxc/lxc-ci/main/images/almalinux.yaml
# cron 不可用
insert_content_1="    - curl\n    - wget\n    - bash\n    - lsof\n    - sshpass\n    - openssh-server\n    - iptables\n    - dos2unix\n    - cronie"
sed -i "/- vim-minimal/ a\\$insert_content_1" almalinux.yaml
"$CI_IMAGE_PYTHON" "$CI_IMAGE_SCRIPT_ROOT/append_image_actions.py" "almalinux.yaml" "$CI_IMAGE_SCRIPT_ROOT/../../bash_insert_content.text"

# rockylinux
rm -rf rockylinux.yaml
wget https://raw.githubusercontent.com/lxc/lxc-ci/main/images/rockylinux.yaml
# cron 不可用
insert_content_1="    - curl\n    - wget\n    - bash\n    - lsof\n    - sshpass\n    - openssh-server\n    - iptables\n    - dos2unix\n    - cronie"
sed -i "/- vim-minimal/ a\\$insert_content_1" rockylinux.yaml
"$CI_IMAGE_PYTHON" "$CI_IMAGE_SCRIPT_ROOT/append_image_actions.py" "rockylinux.yaml" "$CI_IMAGE_SCRIPT_ROOT/../../bash_insert_content.text"

# oracle
rm -rf oracle.yaml
wget https://raw.githubusercontent.com/lxc/lxc-ci/main/images/oracle.yaml
# cron 不可用
insert_content_1="    - curl\n    - wget\n    - bash\n    - lsof\n    - sshpass\n    - openssh-server\n    - iptables\n    - dos2unix\n    - cronie"
sed -i "/- vim-minimal/ a\\$insert_content_1" oracle.yaml
"$CI_IMAGE_PYTHON" "$CI_IMAGE_SCRIPT_ROOT/append_image_actions.py" "oracle.yaml" "$CI_IMAGE_SCRIPT_ROOT/../../bash_insert_content.text"

# archlinux
rm -rf archlinux.yaml
wget https://raw.githubusercontent.com/lxc/lxc-ci/main/images/archlinux.yaml
# cronie 不可用 cron 不可用
insert_content_1="    - curl\n    - wget\n    - bash\n    - lsof\n    - sshpass\n    - iptables\n    - dos2unix"
sed -i "/- which/ a\\$insert_content_1" archlinux.yaml
"$CI_IMAGE_PYTHON" "$CI_IMAGE_SCRIPT_ROOT/append_image_actions.py" "archlinux.yaml" "$CI_IMAGE_SCRIPT_ROOT/../../bash_insert_content.text"
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
# cronie 不可用 cron 不可用
insert_content_1="    - curl\n    - wget\n    - bash\n    - lsof\n    - sshpass\n    - iptables\n    - dos2unix"
sed -i "/- sudo/ a\\$insert_content_1" gentoo.yaml
"$CI_IMAGE_PYTHON" "$CI_IMAGE_SCRIPT_ROOT/append_image_actions.py" "gentoo.yaml" "$CI_IMAGE_SCRIPT_ROOT/../../bash_insert_content.text"
sed -i -e '/environment:/i \ ' gentoo.yaml
sed -i 's/- default/- openrc/g' gentoo.yaml

# fedora
rm -rf fedora.yaml
wget https://raw.githubusercontent.com/lxc/lxc-ci/main/images/fedora.yaml
# cron 不可用
insert_content_1="    - curl\n    - wget\n    - bash\n    - lsof\n    - sshpass\n    - openssh-server\n    - iptables\n    - dos2unix\n    - cronie"
sed -i "/- xz/ a\\$insert_content_1" fedora.yaml
"$CI_IMAGE_PYTHON" "$CI_IMAGE_SCRIPT_ROOT/append_image_actions.py" "fedora.yaml" "$CI_IMAGE_SCRIPT_ROOT/../../bash_insert_content.text"
# fipscheck 在 Fedora 28+ 已被移除，保留会导致构建失败
sed -i '/^    - fipscheck$/d' fedora.yaml
# 将 Koji 源地址改为 Fedora 官方直连地址，解决 fedora-http 下载器在新版本上报
# "Unable to find latest build" 的问题
# Preserve Koji's package-tree source; image_source_compat.py also checks it.

# alpine
rm -rf alpine.yaml
wget https://raw.githubusercontent.com/lxc/lxc-ci/main/images/alpine.yaml
# cronie 不可用 cron 不可用
insert_content_1="    - curl\n    - wget\n    - bash\n    - lsof\n    - sshpass\n    - openssh-server\n    - openssh-keygen\n    - cronie\n    - iptables\n    - dos2unix"
sed -i "/- doas/ a\\$insert_content_1" alpine.yaml
"$CI_IMAGE_PYTHON" "$CI_IMAGE_SCRIPT_ROOT/append_image_actions.py" "alpine.yaml" "$CI_IMAGE_SCRIPT_ROOT/../../sh_insert_content.text"
sed -i -e '/mappings:/i \ ' alpine.yaml

# openwrt
rm -rf openwrt.yaml
wget https://raw.githubusercontent.com/lxc/lxc-ci/main/images/openwrt.yaml
# cronie 不可用 cron 不可用
insert_content_1="    - curl\n    - wget\n    - bash\n    - lsof\n    - sshpass\n    - openssh-server\n    - openssh-keygen\n    - iptables"
sed -i "/- sudo/ a\\$insert_content_1" openwrt.yaml
"$CI_IMAGE_PYTHON" "$CI_IMAGE_SCRIPT_ROOT/append_image_actions.py" "openwrt.yaml" "$CI_IMAGE_SCRIPT_ROOT/../../sh_insert_content.text"

# opensuse
rm -rf opensuse.yaml
wget https://raw.githubusercontent.com/lxc/lxc-ci/main/images/opensuse.yaml
# cron 不可用；原 vim-minimal 锚点已被上游移除，改用 which
insert_content_1="    - curl\n    - wget\n    - bash\n    - lsof\n    - sshpass\n    - openssh-server\n    - iptables\n    - dos2unix\n    - cronie"
sed -i "/- which/ a\\$insert_content_1" opensuse.yaml
"$CI_IMAGE_PYTHON" "$CI_IMAGE_SCRIPT_ROOT/append_image_actions.py" "opensuse.yaml" "$CI_IMAGE_SCRIPT_ROOT/../../bash_insert_content.text"

# openeuler
rm -rf openeuler.yaml
wget https://raw.githubusercontent.com/lxc/lxc-ci/main/images/openeuler.yaml
# cron 不可用
insert_content_1="    - curl\n    - wget\n    - bash\n    - lsof\n    - sshpass\n    - openssh-server\n    - iptables\n    - dos2unix\n    - cronie"
sed -i "/- vim-minimal/ a\\$insert_content_1" openeuler.yaml
"$CI_IMAGE_PYTHON" "$CI_IMAGE_SCRIPT_ROOT/append_image_actions.py" "openeuler.yaml" "$CI_IMAGE_SCRIPT_ROOT/../../bash_insert_content.text"

cd $BASE_DIR
