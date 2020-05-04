#!/usr/bin/env bash
set -eu

if [[ -e debian ]]; then rm -rf debian; fi
bloom-generate rosdebian --os-name ubuntu --os-version bionic --ros-distro melodic
fakeroot debian/rules binary
mkdir -p release
cp `ls ../*deb` ./release/