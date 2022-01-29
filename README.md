# ros-release-tools

[![CI](https://github.com/Tiryoh/ros-release-tools/workflows/CI/badge.svg?branch=master)](https://github.com/Tiryoh/ros-release-tools/actions?query=workflow%3ACI+branch%3Amaster)

Dockerfiles for `catkin_prepare_release` and `bloom-generate`

## Requirements

* Docker
* qemu-user-static

## Installation

### ros-release-tools (this repository)

```
cd $HOME
git clone https://github.com/Tiryoh/ros-release-toos.git
```

### qemu-user-static

This step is required every time the OS is booted.

```
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
```

## Usage

### `catkin_prepare_release`

#### Manual Release

Run [`bin/melodic-release.sh`](./bin/melodic-release.sh) or [`bin/dashing-release.sh`](./bin/dashing-release.sh) in the target ROS package.

### `bloom-generate`

#### Manual Release

Run the following command in the target ROS package.

```
ARCH=arm64 ROS_DISTRO=melodic ~/ros-release-tools/run.sh /release_binary.sh
```

##### args, params

* `ARCH`: `amd64`, `arm64`, `armhf`
* `ROS_DISTRO`: `melodic`, `dashing`

#### GitHub Actions

Create `bloom-generate.yaml` in `.github/workflows`.

```yml
name: bloom-generate
on:
  push:
    tags:
      - "*"
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
        with:
          fetch-depth: 0

      - name: Fetch all tags
        run: git fetch --tags

      - name: Prepare Tiryoh/ros-release-tools
        run: |
          git clone https://github.com/Tiryoh/ros-release-tools.git /tmp/ros-release-tools

      - name: Setup QEMU for Cross-Build
        uses: docker/setup-qemu-action@v1.2.0

      - name: amd64
        continue-on-error: true
        id: amd64
        run: |
          /tmp/ros-release-tools/run.sh /release_binary.sh
          echo ::set-output name=paths::$(ls release/*amd64.deb)
        env:
          ROS_DISTRO: melodic
          ARCH: amd64

      - name: arm64
        continue-on-error: true
        id: arm64
        run: |
          /tmp/ros-release-tools/run.sh /release_binary.sh
          echo ::set-output name=paths::$(ls release/*arm64.deb)
        env:
          ROS_DISTRO: melodic
          ARCH: arm64

      - name: armhf
        continue-on-error: true
        id: armhf
        run: |
          /tmp/ros-release-tools/run.sh /release_binary.sh
          echo ::set-output name=paths::$(ls release/*armhf.deb)
        env:
          ROS_DISTRO: melodic
          ARCH: armhf

      - name: Extract tag name and log
        if: startsWith(github.ref, 'refs/tags/')
        id: repo
        run: |
          echo "# git commit log" | tee msg.txt
          git log --pretty=format:"* %s" $(git describe --abbrev=0 --tags $(git rev-list --tags --skip=1 --max-count=1))..HEAD | tee -a msg.txt
          echo ::set-output name=version::${GITHUB_REF/refs\/tags\//}

      - name: Release
        if: startsWith(github.ref, 'refs/tags/')
        uses: softprops/action-gh-release@v1
        with:
          body_path: msg.txt
          tag_name: ${{ steps.repo.outputs.version }}
          files: |
            ${{ steps.armhf.outputs.paths }}
            ${{ steps.arm64.outputs.paths }}
            ${{ steps.amd64.outputs.paths }}
          draft: false
          prerelease: true
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```
