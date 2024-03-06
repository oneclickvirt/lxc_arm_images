# lxc_arm_images

[![almalinux arm64](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/almalinux_arm64.yml/badge.svg)](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/almalinux_arm64.yml) [![alpine arm64](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/alpine_arm64.yml/badge.svg)](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/alpine_arm64.yml) [![archlinux arm64](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/archlinux_arm64.yml/badge.svg)](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/archlinux_arm64.yml) [![centos arm64](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/centos_arm64.yml/badge.svg)](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/centos_arm64.yml) [![debian arm64](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/debian_arm64.yml/badge.svg)](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/debian_arm64.yml) [![kali arm64](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/kali_arm64.yml/badge.svg)](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/kali_arm64.yml) [![openwrt arm64](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/openwrt_arm64.yml/badge.svg)](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/openwrt_arm64.yml) [![oralce arm64](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/oralce_arm64.yml/badge.svg)](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/oralce_arm64.yml) [![rockylinux arm64](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/rockylinux_arm64.yml/badge.svg)](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/rockylinux_arm64.yml) [![ubuntu arm64](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/ubuntu_arm64.yml/badge.svg)](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/ubuntu_arm64.yml) [![gentoo arm64](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/gentoo_arm64.yml/badge.svg)](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/gentoo_arm64.yml) [![fedora arm64](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/fedora_arm64.yml/badge.svg)](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/fedora_arm64.yml) [![openeuler arm64](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/openeuler_arm64.yml/badge.svg)](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/openeuler_arm64.yml) [![opensuse arm64](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/opensuse_arm64.yml/badge.svg)](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/opensuse_arm64.yml) [![clone yaml](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/clone_yaml.yml/badge.svg)](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/clone_yaml.yml)

## 说明

Releases中的镜像(每日拉取镜像进行自动修补和更新)：

已预安装：wget curl openssh-server sshpass sudo cron(cronie) lsof iptables dos2unix

已预开启SSH登陆，预设SSH监听IPV4和IPV6的22端口，开启允许密码验证登陆

所有镜像均开启允许root用户进行SSH登录

默认用户名：```root```

未修改默认密码，与官方仓库一致

本仓库所有镜像的名字列表：https://github.com/oneclickvirt/lxc_arm_images/blob/main/all_images.txt

~~本仓库测试无误的镜像的名字列表：https://github.com/oneclickvirt/lxc_arm_images/blob/main/fixed_images.txt~~

本仓库每日检测可用性的日志：https://github.com/oneclickvirt/lxc_arm_images/blob/main/log

本仓库的容器镜像服务于： https://github.com/spiritLHLS/pve

## Introduce

Mirrors in Releases (pulls mirrors daily for automatic patching and updating):

Pre-installed: wget curl openssh-server sshpass sudo cron(cronie) lsof iptables dos2unix

Pre-enabled SSH login, preset SSH listening on port 22 of IPV4 and IPV6, enabled to allow password authentication login

All mirrors are enabled to allow SSH login for root users.

Default username: ```root```.

Unchanged default password, consistent with official repository.

A list of names for all images in this repository: https://github.com/oneclickvirt/lxc_arm_images/blob/main/all_images.txt

~~A list of names of images in this repository that have been tested without error: https://github.com/oneclickvirt/lxc_arm_images/blob/main/fixed_images.txt~~

A log of daily availability tests for this repository: https://github.com/oneclickvirt/lxc_arm_images/blob/main/log

This repository container images serves https://github.com/spiritLHLS/pve

## Test

```
image=""
pct create 101 "$image" -cores 1 -cpuunits 1024 -memory 1024 -swap 0 -rootfs local:10 -onboot 1 -features nesting=1
pct start 101
pct set 101 --hostname 101
pct set 101 --net0 name=spiritlhl,ip=172.16.1.2/24,bridge=vmbr1,gw=172.16.1.1
pct set 101 --nameserver 1.1.1.1
pct set 101 --searchdomain local
sleep 3
echo "nameserver 8.8.8.8" | pct exec $CTID -- tee -a /etc/resolv.conf
echo "nameserver 8.8.4.4" | pct exec $CTID -- tee -a /etc/resolv.conf
```

```
pct enter 101
```

```
pct stop 101 && pct destroy 101
```

## Thanks

https://github.com/spiritLHLS/pve

https://linuxcontainers.org/incus/docs/main/

https://github.com/lxc/lxc-ci/tree/main/images

https://github.com/lxc/distrobuilder

https://go.dev/dl/
