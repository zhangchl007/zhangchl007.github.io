---
layout: post
title: Docker-Learning01/conf-files
tag: Docker
---

/etc/init/docker.conf It's a script to start docker server daemon. Please the code below
<pre><code>
description "Docker daemon"
start on (local-filesystems and net-device-up IFACE!=lo)
stop on runlevel [!2345]
limit nofile 524288 1048576
limit nproc 524288 1048576
respawn
kill timeout 20
pre-start script
	#see also https://github.com/tianon/cgroupfs-mount/blob/master/cgroupfs-mount
	if grep -v '^#' /etc/fstab | grep -q cgroup \
		|| [ ! -e /proc/cgroups ] \
		|| [ ! -d /sys/fs/cgroup ]; then
		exit 0
	fi
	if ! mountpoint -q /sys/fs/cgroup; then
		mount -t tmpfs -o uid=0,gid=0,mode=0755 cgroup /sys/fs/cgroup
	fi
	(
		cd /sys/fs/cgroup
		for sys in $(awk '!/^#/ { if ($4 == 1) print $1 }' /proc/cgroups); do
			mkdir -p $sys
			if ! mountpoint -q $sys; then
				if ! mount -n -t cgroup -o $sys cgroup $sys; then
					rmdir $sys || true
				fi
			fi
		done
	)
end script

script
	#modify these in /etc/default/$UPSTART_JOB (/etc/default/docker)
	DOCKER=/usr/bin/$UPSTART_JOB
	DOCKER_OPTS=
	if [ -f /etc/default/$UPSTART_JOB ]; then
		. /etc/default/$UPSTART_JOB
	fi
	exec "$DOCKER" daemon $DOCKER_OPTS
end script

#Don't emit "started" event until docker.sock is ready.
#See https://github.com/docker/docker/issues/6647

post-start script
	DOCKER_OPTS=
	if [ -f /etc/default/$UPSTART_JOB ]; then
		. /etc/default/$UPSTART_JOB
	fi
	if ! printf "%s" "$DOCKER_OPTS" | grep -qE -e '-H|--host'; then
		while ! [ -e /var/run/docker.sock ]; do
			initctl status $UPSTART_JOB | grep -qE "(stop|respawn)/" && exit 1
			echo "Waiting for /var/run/docker.sock"
			sleep 0.1
		done
		echo "/var/run/docker.sock is up"
	fi
end script
</pre></code>
/etc/apt/sources.list.d/docker.list #It's defined docker package source 

/etc/systemd/system/sockets.target.wants/docker.socket #docker conf for Systemd

/etc/systemd/system/multi-user.target.wants/docker.service #docker conf for Systemd

/etc/apparmor.d/cache/docker #component

/etc/apparmor.d/docker       #component

/etc/default/docker          #SysVinit configuration file

/etc/init.d/docker           #It is included by /etc/init/docker.conf

/etc/bash_completion.d/docker #bash completion file for core docker commands

<a href="https://blog.linuxeye.com/400.html">systemd详解</a>
