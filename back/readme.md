## runner

[![almalinux arm64](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/almalinux_arm64.yml/badge.svg)](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/almalinux_arm64.yml) [![alpine arm64](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/alpine_arm64.yml/badge.svg)](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/alpine_arm64.yml) [![archlinux arm64](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/archlinux_arm64.yml/badge.svg)](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/archlinux_arm64.yml) [![centos arm64](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/centos_arm64.yml/badge.svg)](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/centos_arm64.yml) [![debian arm64](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/debian_arm64.yml/badge.svg)](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/debian_arm64.yml) [![kali arm64](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/kali_arm64.yml/badge.svg)](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/kali_arm64.yml) [![openwrt arm64](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/openwrt_arm64.yml/badge.svg)](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/openwrt_arm64.yml) [![ubuntu arm64](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/ubuntu_arm64.yml/badge.svg)](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/ubuntu_arm64.yml) [![gentoo arm64](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/gentoo_arm64.yml/badge.svg)](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/gentoo_arm64.yml) [![fedora arm64](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/fedora_arm64.yml/badge.svg)](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/fedora_arm64.yml) [![openeuler arm64](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/openeuler_arm64.yml/badge.svg)](https://github.com/oneclickvirt/lxc_arm_images/actions/workflows/openeuler_arm64.yml)

```
export RUNNER_ALLOW_RUNASROOT=1
```

```
./config.sh xxxxxxxxxxxxxxxxxxxxxxx
```

```
nano /etc/systemd/system/github-runner.service
```

```
[Unit]
Description=GitHub Actions Runner

[Service]
Type=simple
WorkingDirectory=/root/actions-runner
ExecStart=/root/actions-runner/run.sh
User=root
Restart=always
Environment="RUNNER_ALLOW_RUNASROOT=1"

[Install]
WantedBy=multi-user.target
```

```
sudo systemctl daemon-reload
sudo systemctl start github-runner
```

```
sudo systemctl status github-runner
```

```
sudo systemctl enable github-runner
```
