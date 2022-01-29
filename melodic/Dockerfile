FROM ubuntu:18.04 as builder
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y --no-install-recommends gcc libc-dev
RUN curl -o /usr/local/bin/su-exec.c https://raw.githubusercontent.com/ncopa/su-exec/master/su-exec.c
RUN gcc -Wall /usr/local/bin/su-exec.c -o/usr/local/bin/su-exec
RUN chown root:root /usr/local/bin/su-exec
RUN chmod 0755 /usr/local/bin/su-exec

FROM ros:melodic-ros-base
COPY --from=builder /usr/local/bin/su-exec /sbin/
RUN apt-get update && \
	apt-get install -y iputils-ping net-tools dnsutils && \
	chmod 4755 /bin/ping && \
	apt-get install -y python-catkin-tools python-bloom dh-make fakeroot && \
	apt-get install -y python-rosdep python3-vcstool && \
	rm -rf /var/lib/apt/lists/*
WORKDIR /ros_ws
COPY ./entrypoint.sh /
COPY ./prepare_release.sh /
COPY ./release.sh /
COPY ./release_binary.sh /
ENTRYPOINT ["/entrypoint.sh"]
