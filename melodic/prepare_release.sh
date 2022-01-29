#!/usr/bin/env bash
set -eu

echo ==================
echo uname -m: `uname -m`
echo prepare_release.sh
echo ==================
cd /ros_ws
rosdep update || echo \"rosdep update error\"; ping -c4 raw.githubusercontent.com; rosdep update;
catkin init
rosdep install -r -y -i --from-paths .
catkin build
echo "catkin build passed"
git config --global user.name "${GIT_NAME}"
git config --global user.email "${GIT_EMAIL}"
