#!/usr/bin/env bash
set -eu

cd /ros_ws
rosdep update
sudo apt update
rosdep install -r -y -i --from-paths src
colcon build
echo "colcon build passed"
git config --global user.name "${GIT_NAME}"
git config --global user.email "${GIT_EMAIL}"
