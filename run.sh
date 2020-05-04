#!/usr/bin/env bash
set -eu

SRC_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)
ROS_DISTRO=melodic
ARCH=armhf
# ARCH=arm64
# ARCH=amd64

pushd ${SRC_DIR}/${ROS_DISTRO} && \
docker build -t tiryoh/ros:${ROS_DISTRO}-ros-core -f Dockerfile.${ARCH} . && \
popd
docker run --rm -it \
	-e UID=`id -u` -e GID=`id -g` \
	-e GIT_EMAIL="`git config user.email`" \
	-e GIT_NAME="`git config user.name`" \
	-v "`pwd`:/catkin_ws/src/ros_package" \
	tiryoh/ros:${ROS_DISTRO}-ros-core