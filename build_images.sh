#!/bin/bash
# 从 https://github.com/oneclickvirt/lxc_arm_images 获取

run_funct="${1:-debian}"
is_build_image="${2:-false}"
build_arch="${3:-arm64}"
zip_name_list=()
opath=$(pwd)
[ "$is_build_image" == true ] && rm -rf *.tar.xz
ls
# 检查并安装依赖工具
if command -v apt-get >/dev/null 2>&1; then
    # ubuntu debian kali
    if ! command -v sudo >/dev/null 2>&1; then
        apt-get install sudo -y
    fi
    if ! command -v zip >/dev/null 2>&1; then
        sudo apt-get install zip -y
    fi
    if ! command -v jq >/dev/null 2>&1; then
        sudo apt-get install jq -y
    fi
    uname_output=$(uname -a)
    if [[ $uname_output != *ARM* && $uname_output != *arm* && $uname_output != *aarch* ]]; then
        if ! command -v snap >/dev/null 2>&1; then
            sudo apt-get install snapd -y
        fi
        sudo systemctl start snapd
        if ! command -v distrobuilder >/dev/null 2>&1; then
            sudo snap install distrobuilder --classic
        fi
    else
        # if ! command -v snap >/dev/null 2>&1; then
        #     sudo apt-get install snapd -y
        # fi
        # sudo systemctl start snapd
        # if ! command -v distrobuilder >/dev/null 2>&1; then
        #     sudo snap install distrobuilder --classic
        # fi
        if ! command -v distrobuilder >/dev/null 2>&1; then
            $HOME/goprojects/bin/distrobuilder --version
        fi
        if [ $? -ne 0 ]; then
            sudo apt-get install build-essential -y
            export CGO_ENABLED=1
            export CC=gcc
            wget https://go.dev/dl/go1.21.6.linux-arm64.tar.gz
            chmod 777 go1.21.6.linux-arm64.tar.gz
            rm -rf /usr/local/go && tar -C /usr/local -xzf go1.21.6.linux-arm64.tar.gz
            export GOROOT=/usr/local/go
            export PATH=$GOROOT/bin:$PATH
            export GOPATH=$HOME/goprojects/
            go version
            apt-get install -q -y debootstrap rsync gpg squashfs-tools git make
            git config --global user.name "daily-update"
            git config --global user.email "tg@spiritlhl.top"
            mkdir -p $HOME/go/src/github.com/lxc/
            cd $HOME/go/src/github.com/lxc/
            git clone https://github.com/lxc/distrobuilder
            cd ./distrobuilder
            make
            export PATH=$HOME/goprojects/bin:$PATH
            echo $PATH
            find $HOME -name distrobuilder -type f 2>/dev/null
            $HOME/goprojects/bin/distrobuilder --version
            cd "$opath"
        fi
        # wget https://api.ilolicon.com/distrobuilder.deb
        # dpkg -i distrobuilder.deb
    fi
    if ! command -v debootstrap >/dev/null 2>&1; then
        sudo apt-get install debootstrap -y
    fi
fi

# 构建或列出不同发行版的镜像
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
                # apk apt dnf egoportage opkg pacman portage yum equo xbps zypper luet slackpkg
                if [[ "$run_funct" == "centos" || "$run_funct" == "openeuler" ]]; then
                    manager="yum"
                elif [[ "$run_funct" == "fedora" ]]; then
                    manager="dnf"
                elif [[ "$run_funct" == "kali" || "$run_funct" == "ubuntu" || "$run_funct" == "debian" ]]; then
                    manager="apt"
                elif [[ "$run_funct" == "almalinux" || "$run_funct" == "rockylinux" || "$run_funct" == "oracle" ]]; then
                    manager="dnf"
                elif [[ "$run_funct" == "archlinux" ]]; then
                    manager="pacman"
                elif [[ "$run_funct" == "alpine" ]]; then
                    manager="apk"
                elif [[ "$run_funct" == "openwrt" ]]; then
                    manager="opkg"
                    [ "${version}" = "snapshot" ] && manager="apk"
                elif [[ "$run_funct" == "gentoo" ]]; then
                    manager="portage"
                elif [[ "$run_funct" == "opensuse" ]]; then
                    manager="zypper"
                else
                    echo "Unsupported distribution: $run_funct"
                    exit 1
                fi
                EXTRA_ARGS=""
                if [[ "$run_funct" == "centos" ]]; then
                    [ "${arch}" = "amd64" ] && arch="x86_64"
                    [ "${arch}" = "arm64" ] && arch="aarch64"
                    if [ "$version" = "7" ] && [ "${arch}" != "amd64" ] && [ "${arch}" != "x86_64" ]; then
                        EXTRA_ARGS="-o source.url=http://mirror.math.princeton.edu/pub/centos-altarch/ -o source.skip_verification=true"
                    fi
                    if [ "$version" = "8-Stream" ] || [ "$version" = "9-Stream" ]; then
                        EXTRA_ARGS="${EXTRA_ARGS} -o source.variant=boot"
                    fi
                    if [ "$version" = "9-Stream" ]; then
                        EXTRA_ARGS="${EXTRA_ARGS} -o source.url=https://mirror1.hs-esslingen.de/pub/Mirrors/centos-stream"
                    fi
                elif [[ "$run_funct" == "rockylinux" ]]; then
                    [ "${arch}" = "amd64" ] && arch="x86_64"
                    [ "${arch}" = "arm64" ] && arch="aarch64"
                    EXTRA_ARGS="-o source.variant=boot"
                    # Rocky Linux 10 GPG key 名称变更，跳过 ISO 来源验证
                    if [ "$version" = "10" ]; then
                        EXTRA_ARGS="$EXTRA_ARGS -o source.skip_verification=true"
                    fi
                elif [[ "$run_funct" == "almalinux" ]]; then
                    [ "${arch}" = "amd64" ] && arch="x86_64"
                    [ "${arch}" = "arm64" ] && arch="aarch64"
                    EXTRA_ARGS="-o source.variant=boot"
                    # AlmaLinux 10 GPG key 名称变更，跳过 ISO 来源验证
                    if [ "$version" = "10" ]; then
                        EXTRA_ARGS="$EXTRA_ARGS -o source.skip_verification=true"
                    fi
                elif [[ "$run_funct" == "oracle" ]]; then
                    [ "${arch}" = "amd64" ] && arch="x86_64"
                    [ "${arch}" = "arm64" ] && arch="aarch64"
                    EXTRA_ARGS="-o source.url=https://yum.oracle.com/ISOS/OracleLinux"
                elif [[ "$run_funct" == "archlinux" ]]; then
                    [ "${arch}" = "amd64" ] && arch="x86_64"
                    [ "${arch}" = "arm64" ] && arch="aarch64"
                    if [ "${arch}" != "amd64" ] && [ "${arch}" != "i386" ] && [ "${arch}" != "x86_64" ]; then
                        # archlinuxarm.org 仅支持 HTTP，需跳过 GPG 验证
                        EXTRA_ARGS="-o source.url=http://os.archlinuxarm.org -o source.skip_verification=true"
                    fi
                elif [[ "$run_funct" == "alpine" ]]; then
                    [ "${arch}" = "amd64" ] && arch="x86_64"
                    [ "${arch}" = "arm64" ] && arch="aarch64"
                    if [ "${version}" = "edge" ]; then
                        EXTRA_ARGS="-o source.same_as=3.19"
                    fi
                elif [[ "$run_funct" == "fedora" || "$run_funct" == "openeuler" || "$run_funct" == "opensuse" || "$run_funct" == "openwrt" ]]; then
                    [ "${arch}" = "amd64" ] && arch="x86_64"
                    [ "${arch}" = "arm64" ] && arch="aarch64"
                elif [[ "$run_funct" == "gentoo" ]]; then
                    [ "${arch}" = "x86_64" ] && arch="amd64"
                    [ "${arch}" = "aarch64" ] && arch="arm64"
                    if [ "${variant}" = "cloud" ]; then
                        EXTRA_ARGS="-o source.variant=openrc"
                    else
                        EXTRA_ARGS="-o source.variant=${variant}"
                    fi
                elif [[ "$run_funct" == "debian" ]]; then
                    [ "${arch}" = "x86_64" ] && arch="amd64"
                    [ "${arch}" = "aarch64" ] && arch="arm64"
                elif [[ "$run_funct" == "ubuntu" ]]; then
                    [ "${arch}" = "x86_64" ] && arch="amd64"
                    [ "${arch}" = "aarch64" ] && arch="arm64"
                    if [ "${arch}" != "amd64" ] && [ "${arch}" != "i386" ] && [ "${arch}" != "x86_64" ]; then
                        EXTRA_ARGS="-o source.url=http://ports.ubuntu.com/ubuntu-ports"
                    fi
                fi
                if [ "$is_build_image" == true ]; then
                    if command -v distrobuilder >/dev/null 2>&1; then
                        if [[ "$run_funct" == "gentoo" ]]; then
                            echo "sudo distrobuilder build-lxc "${opath}/images_yaml/${run_funct}.yaml" -o image.architecture=${arch} -o image.variant=${variant} ${EXTRA_ARGS}"
                            if sudo distrobuilder build-lxc "${opath}/images_yaml/${run_funct}.yaml" -o image.architecture=${arch} -o image.variant=${variant} ${EXTRA_ARGS}; then
                                echo "Command succeeded"
                            fi
                        elif [[ "$run_funct" != "archlinux" ]]; then
                            echo "sudo distrobuilder build-lxc "${opath}/images_yaml/${run_funct}.yaml" -o image.release=${version} -o image.architecture=${arch} -o image.variant=${variant} -o packages.manager=${manager} ${EXTRA_ARGS}"
                            if sudo distrobuilder build-lxc "${opath}/images_yaml/${run_funct}.yaml" -o image.release=${version} -o image.architecture=${arch} -o image.variant=${variant} -o packages.manager=${manager} ${EXTRA_ARGS}; then
                                echo "Command succeeded"
                            fi
                        else
                            echo "sudo distrobuilder build-lxc "${opath}/images_yaml/${run_funct}.yaml" -o image.architecture=${arch} -o image.variant=${variant} -o packages.manager=${manager} ${EXTRA_ARGS}"
                            if sudo distrobuilder build-lxc "${opath}/images_yaml/${run_funct}.yaml" -o image.architecture=${arch} -o image.variant=${variant} -o packages.manager=${manager} ${EXTRA_ARGS}; then
                                echo "Command succeeded"
                            fi
                        fi
                    else
                        if [[ "$run_funct" == "gentoo" ]]; then
                            echo "sudo $HOME/goprojects/bin/distrobuilder build-lxc "${opath}/images_yaml/${run_funct}.yaml" -o image.architecture=${arch} -o image.variant=${variant} ${EXTRA_ARGS}"
                            if sudo $HOME/goprojects/bin/distrobuilder build-lxc "${opath}/images_yaml/${run_funct}.yaml" -o image.architecture=${arch} -o image.variant=${variant} ${EXTRA_ARGS}; then
                                echo "Command succeeded"
                            fi
                        elif [[ "$run_funct" != "archlinux" ]]; then
                            echo "sudo $HOME/goprojects/bin/distrobuilder build-lxc "${opath}/images_yaml/${run_funct}.yaml" -o image.release=${version} -o image.architecture=${arch} -o image.variant=${variant} -o packages.manager=${manager} ${EXTRA_ARGS}"
                            if sudo $HOME/goprojects/bin/distrobuilder build-lxc "${opath}/images_yaml/${run_funct}.yaml" -o image.release=${version} -o image.architecture=${arch} -o image.variant=${variant} -o packages.manager=${manager} ${EXTRA_ARGS}; then
                                echo "Command succeeded"
                            fi
                        else
                            echo "sudo $HOME/goprojects/bin/distrobuilder build-lxc "${opath}/images_yaml/${run_funct}.yaml" -o image.architecture=${arch} -o image.variant=${variant} -o packages.manager=${manager} ${EXTRA_ARGS}"
                            if sudo $HOME/goprojects/bin/distrobuilder build-lxc "${opath}/images_yaml/${run_funct}.yaml" -o image.architecture=${arch} -o image.variant=${variant} -o packages.manager=${manager} ${EXTRA_ARGS}; then
                                echo "Command succeeded"
                            fi
                        fi
                    fi
                    # 强制设置架构名字
                    if [[ "$run_funct" == "gentoo" || "$run_funct" == "debian" || "$run_funct" == "ubuntu" ]]; then
                        [ "${arch}" = "amd64" ] && arch="x86_64"
                    elif [[ "$run_funct" == "fedora" || "$run_funct" == "openeuler" || "$run_funct" == "opensuse" || "$run_funct" == "openwrt" || "$run_funct" == "alpine" || "$run_funct" == "oracle" || "$run_funct" == "archlinux" ]]; then
                        [ "${arch}" = "aarch64" ] && arch="arm64"
                    elif [[ "$run_funct" == "almalinux" || "$run_funct" == "centos" || "$run_funct" == "rockylinux" ]]; then
                        [ "${arch}" = "aarch64" ] && arch="arm64"
                    fi
                    ls
                    if [ -f rootfs.tar.xz ]; then
                        mv rootfs.tar.xz "${run_funct}_${ver_num}_${version}_${arch}_${variant}.tar.xz"
                        rm -rf rootfs.tar.xz
                    fi
                    ls
                else
                    # 强制设置架构名字
                    if [[ "$run_funct" == "gentoo" || "$run_funct" == "debian" || "$run_funct" == "ubuntu" ]]; then
                        [ "${arch}" = "amd64" ] && arch="x86_64"
                    elif [[ "$run_funct" == "fedora" || "$run_funct" == "openeuler" || "$run_funct" == "opensuse" || "$run_funct" == "openwrt" || "$run_funct" == "alpine" || "$run_funct" == "oracle" || "$run_funct" == "archlinux" ]]; then
                        [ "${arch}" = "aarch64" ] && arch="arm64"
                    elif [[ "$run_funct" == "almalinux" || "$run_funct" == "centos" || "$run_funct" == "rockylinux" ]]; then
                        [ "${arch}" = "aarch64" ] && arch="arm64"
                    fi
                    zip_name_list+=("${run_funct}_${ver_num}_${version}_${arch}_${variant}.tar.xz")
                fi
            done
        done
    done
    if [ "$is_build_image" == false ]; then
        echo "${zip_name_list[@]}"
    fi
}


# 不同发行版的配置
# build_or_list_images 镜像名字 镜像版本号 variants的值
case "$run_funct" in
debian)
    build_or_list_images "bullseye bookworm trixie" "11 12 13" "default cloud"
    ;;
ubuntu)
    build_or_list_images "bionic focal jammy noble" "18.04 20.04 22.04 24.04" "default cloud"
    ;;
kali)
    build_or_list_images "kali-rolling" "latest" "default cloud"
    ;;
archlinux)
    build_or_list_images "current" "current" "default cloud"
    ;;
gentoo)
    build_or_list_images "current" "current" "cloud systemd openrc"
    ;;
centos)
    build_or_list_images "9-Stream" "9" "default cloud"
    ;;
almalinux)
    build_or_list_images "8 9 10" "8 9 10" "default cloud"
    ;;
rockylinux)
    build_or_list_images "8 9 10" "8 9 10" "default cloud"
    ;;
alpine)
    build_or_list_images "3.19 3.20 3.21" "3.19 3.20 3.21" "default cloud"
    ;;
openwrt)
    build_or_list_images "23.05 24.10" "23.05 24.10" "default cloud"
    ;;
oracle)
    build_or_list_images "8 9" "8 9" "default cloud"
    ;;
fedora)
    # Fedora 42 尚未正式发布，暂只构建 40/41
    build_or_list_images "40 41" "40 41" "default cloud"
    ;;
opensuse)
    build_or_list_images "15.6 tumbleweed" "15.6 tumbleweed" "default cloud"
    ;;
openeuler)
    build_or_list_images "22.03 24.03" "22.03 24.03" "default cloud"
    ;;
*)
    echo "Invalid distribution specified."
    ;;
esac
