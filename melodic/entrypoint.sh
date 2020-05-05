#!/usr/bin/env bash
set -eu

USER_ID=${UID:-1001}
GROUP_ID=${GID:-1001}

echo "Starting with UID : $USER_ID, GID: $GROUP_ID"
addgroup --gid ${GROUP_ID} ubuntu
adduser --gecos "" --disabled-password --uid ${USER_ID} --ingroup ubuntu ubuntu
echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

export HOME=/home/ubuntu

set +u
source "/opt/ros/$ROS_DISTRO/setup.bash"
set -u

# mkdir -p /catkin_ws/src
chown -R ubuntu:ubuntu /catkin_ws
/sbin/su-exec ubuntu bash -l -c "/prepare_release.sh"
echo "release prepare done"
cd /catkin_ws/src/`ls -1 /catkin_ws/src | head -n1`
if [ $# -gt 0 ]; then
	echo $@ | /sbin/su-exec ubuntu bash -li
else
	/sbin/su-exec ubuntu bash -li
fi
