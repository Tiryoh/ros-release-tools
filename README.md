# ros-release-tools
Dockerfiles for catkin_prepare_release and bloom-generate

## Usage

### Manual Release

Run `bin/melodic-release.sh` in the target ROS package.

### GitHub Actions

Create `bloom-generate.yml` in `.github/workflows`.

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
      - name: Prepare for Cross-Build
        run: |
          sudo apt-get update
          sudo apt-get install -y qemu-user-static
      - name: Prepare Docker
        run: |
          echo '{"experimental": true}' | sudo tee -a /etc/docker/daemon.json > /dev/null
          mkdir ~/.docker
          echo '{"experimental": "enabled"}' | tee -a ~/.docker/config.json > /dev/null
          sudo service docker restart
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
