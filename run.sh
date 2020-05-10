#!/usr/bin/env bash
set -eu

SRC_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)
if [ ! "${ROS_DISTRO:+foo}" ]; then
  ROS_DISTRO=melodic
fi
if [ ! "${ARCH:+foo}" ]; then
  ARCH=amd64
fi

COMMAND=${@:-""}
echo $COMMAND

pushd ${SRC_DIR}/${ROS_DISTRO} && \
docker build -t tiryoh/ros-${ARCH}:${ROS_DISTRO}-ros-core -f Dockerfile.${ARCH} . && \
popd
if [ -z $COMMAND ]; then
  docker run --rm -it \
    -e UID=`id -u` -e GID=`id -g` \
    -e GIT_EMAIL="`git config user.email`" \
    -e GIT_NAME="`git config user.name`" \
    -v "`pwd`:/ros_ws/src/ros_package" \
    tiryoh/ros-${ARCH}:${ROS_DISTRO}-ros-core
else
  docker run --rm \
    -e UID=`id -u` -e GID=`id -g` \
    -e GIT_EMAIL="`git config user.email`" \
    -e GIT_NAME="`git config user.name`" \
    -v "`pwd`:/ros_ws/src/ros_package" \
    tiryoh/ros-${ARCH}:${ROS_DISTRO}-ros-core ${COMMAND}
fi