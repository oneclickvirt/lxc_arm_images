免费计划每月只提供30000积分，6000分钟构筑时间，每个任务最多运行1小时。

The free plan offers only 30,000 points per month, 6,000 minutes of build time, and a maximum of 1 hour of running time per mission.

```
  build_openeuler_first:
      machine:
        image: ubuntu-2204:2024.01.1
      resource_class: arm.large
      steps:
        - checkout
        - run:
            name: Install dependencies
            command: |
              sudo apt-get update
              sudo apt-get install -y sudo zip jq snapd debootstrap
              sudo snap install distrobuilder --classic
        - run:
            name: Build and upload images
            command: |
              chmod 777 build_and_upload.sh
              ./build_and_upload.sh $GITHUB_TOKEN openeuler first
  build_openeuler_second:
      machine:
        image: ubuntu-2204:2024.01.1
      resource_class: arm.large
      steps:
        - checkout
        - run:
            name: Install dependencies
            command: |
              sudo apt-get update
              sudo apt-get install -y sudo zip jq snapd debootstrap
              sudo snap install distrobuilder --classic
        - run:
            name: Build and upload images
            command: |
              chmod 777 build_and_upload.sh
              ./build_and_upload.sh $GITHUB_TOKEN openeuler second


```