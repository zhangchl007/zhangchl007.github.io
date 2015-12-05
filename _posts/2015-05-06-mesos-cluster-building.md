---
layout: post
title: 配置和搭建mesos Cluster on Ubuntu 14.04（详细
tag: Docker
---

#docker 01  IP:192.168.122.220  Bcast:192.168.122.255  Mask:255.255.255.0 Ubuntu 14.04
docker 02  IP:192.168.122.221  Bcast:192.168.122.255  Mask:255.255.255.0 Ubuntu 14.04
docker 03  IP:192.168.122.222  Bcast:192.168.122.255  Mask:255.255.255.0 Ubuntu 14.04
docker 04  IP:192.168.122.223  Bcast:192.168.122.255  Mask:255.255.255.0 Ubuntu 14.04
docker 05  IP:192.168.122.224  Bcast:192.168.122.255  Mask:255.255.255.0 Ubuntu 14.04

1.apt-get install curl python-setuptools python-pip python-dev python-protobuf
安装配置ZooKeeper
apt-get install ZooKeeperd
echo 1 | sudo dd of=/var/lib/ZooKeeper/myid
安装Docker
cat /etc/apt/sources.list.d/docker.list 
deb https://apt.dockerproject.org/repo ubuntu-trusty main
sudo apt-get install docker-engine
sudo usermod -aG docker jimmy
sudo service docker start

安装配置Mesos－master和Mesos-slave
curl -fL http://downloads.mesosphere.io/master/ubuntu/14.04/mesos_0.19.0~ubuntu14.04%2B1_amd64.deb -o /tmp/mesos.deb
dpkg -i /tmp/Mesos.deb
mkdir -p /etc/Mesos-master
echo in_memory | sudo dd of=/etc/Mesos-master/registry

安装配置Mesos的Python框架
# curl -fL http://downloads.mesosphere.io/master/ubuntu/14.04/mesos-0.19.0_rc2-py2.7-linux-x86_64.egg -o /tmp/mesos.egg
# easy_install /tmp/mesos.egg
下载安装Mesos管理Docker的代理组件Deimos
# pip install deimos

配置Mesos使用Deimos
# mkdir -p /etc/mesos-slave
# echo /usr/local/bin/deimos | sudo dd of=/etc/mesos-slave/containerizer_path
# echo external | sudo dd of=/etc/mesos-slave/isolation

下载Marathon
curl -O http://downloads.Mesosphere.io/marathon/marathon-0.6.0/marathon-0.6.0.tgz  

2. on the Master Servers
配置3台master上的ZooKeeper,slave节点上的ZooKeeper服务停掉
cat /etc/mesos/zk
zk://localhost:2181/mesos替换成下面（所有节点，包括slave)
zk://192.168.122.220:2181,192.168.122.221:2181,192.168.122.222:2181/mesos

[jimmy@oc3053148748 Desktop]$  for srv in docker01 docker02 docker03;do echo \--$srv--;ssh $srv "sudo cat /etc/mesos/zk";done
--docker01--
zk://192.168.122.220:2181,192.168.122.221:2181,192.168.122.222:2181/mesos
--docker02--
zk://192.168.122.220:2181,192.168.122.221:2181,192.168.122.222:2181/mesos
--docker03--
zk://192.168.122.220:2181,192.168.122.221:2181,192.168.122.222:2181/mesos

配置/etc/zookeeper/conf/myid ，指定id 对应master节点为1，2，3

[jimmy@oc3053148748 Desktop]$  for srv in docker01 docker02 docker03;do echo \--$srv--;ssh $srv "sudo cat /etc/zookeeper/conf/myid";done
\--docker01--
1
\--docker02--
2
\--docker03--
3
配置/etc/zookeeper/conf/zoo.cfg在3台master上
server.1=192.168.122.220:2888:3888
server.2=192.168.122.221:2888:3888
server.3=192.168.122.222:2888:3888
Configure Mesos 选举Quorum 
for srv in docker01 docker02 docker03;do echo --$srv--;ssh $srv "sudo cat /etc/mesos-master/quorum";done 
\--docker01--
2
\--docker02--
2
\--docker03--
2
配置master的主机和IP

echo 192.168.122.220 | sudo tee /etc/mesos-master/ip
sudo cp /etc/mesos-master/ip /etc/mesos-master/hostname
[jimmy@oc3053148748 Desktop]$  for srv in docker01 docker02 docker03;do echo \--$srv--;ssh $srv "sudo cat  /etc/mesos-master/ip";done 
\--docker01--
192.168.122.220
\--docker02--
192.168.122.221
\--docker03--
192.168.122.222
配置Marathon
sudo tar -zxvf marathon-0.6.0.tgz  -C /opt/
sudo mv /opt/marathon-0.6.0 /opt/marathon
cat >>/etc/init/marathon.conf <<EOF
 description "Marathon scheduler for Mesos"
 start on runlevel [2345]
 stop on runlevel [!2345]
 respawn
 respawn limit 10 5
 exec /opt/marathon/bin/start \--master zk://192.168.122.220:2181,192.168.122.221:2181,192.168.122.222:2181/mesos --zk zk://192.168.122.220:2181,192.168.122.221:2181,192.168.122.222:2181/marathon
EOF

配置master节点服务启动规则 
sudo stop mesos-slave
echo manual | sudo tee /etc/init/mesos-slave.override
启动服务sudo stop mesos-slave
sudo restart zookeeper
sudo start mesos-master
sudo start marathon
测试
Start an app with 128 MB memory, 1 CPU, and 1 instance
curl -X POST -H "Accept: application/json" -H "Content-Type: application/json" \
    192.168.122.220:8080/v2/apps \
    -d '{"id": "app-123", "cmd": "sleep 600", "instances": 1, "mem": 128, "cpus": 1}'
# Stop the app
curl -X DELETE 192.168.122.220:8080/v2/apps/app-123
配置slave节点
sudo stop zookeeper
echo manual | sudo tee /etc/init/zookeeper.override
配置slave节点主机名和ip
echo 192.168.122.223 |  sudo tee /etc/mesos-slave/ip
sudo cp /etc/mesos-slave/ip /etc/mesos-slave/hostname
[jimmy@oc3053148748 Downloads]$ for srv in docker04 docker05;do echo \--$srv--;ssh $srv "sudo cat  /etc/mesos-slave/ip";done
\--docker04--
192.168.122.223
\--docker05--
192.168.122.224

sudo stop zookeeper
echo manual | sudo tee /etc/init/zookeeper.override

sudo stop mesos-master
echo manual | sudo tee /etc/init/mesos-master.override
sudo start mesos-slave

constraints we previously set.
成功搭建集群如下：
![Mesos01](https://github.com/zhangchl007/zhangchl007.github.io/tree/master/_image/mesos01.png "Mesos scale-up")
![Mesos02](https://github.com/zhangchl007/zhangchl007.github.io/tree/master/_image/mesos02.png "Mesos scale-up")
