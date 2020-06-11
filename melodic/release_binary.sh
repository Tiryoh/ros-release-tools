#!/usr/bin/env bash

source /ros_ws/install/setup.bash

set -eu

if [[ -e debian ]]; then rm -rf debian; fi

if [[ $# -gt 0 ]] && [[ "$1" == "--ignore-src" ]]; then
	touch /ros_ws/rosdep.yaml
	sudo touch /etc/ros/rosdep/sources.list.d/50-my-packages.list
	echo yaml file:///ros_ws/rosdep.yaml | sudo tee -a /etc/ros/rosdep/sources.list.d/50-my-packages.list > /dev/null
	for ignore_package in ${@:2}; do
		echo ignore: ${ignore_package}
		echo "${ignore_package}:" >> /ros_ws/rosdep.yaml
		echo "  ubuntu: [ros-melodic-$(echo ${ignore_package} | sed -e 's/_/-/g')]" >> /ros_ws/rosdep.yaml
	done
	rosdep update
	bloom-generate rosdebian --os-name ubuntu --os-version bionic --ros-distro melodic
else
	bloom-generate rosdebian --os-name ubuntu --os-version bionic --ros-distro melodic
fi

fakeroot debian/rules binary
mkdir -p release
cp `ls ../*deb` ./release/
echo "SUCCESS"
