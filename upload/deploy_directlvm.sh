#!/bin/bash
dockerset=0
########docker user id creation@#################
#groupadd admin
#useradd -g admin jimmy
#groupadd docker
#usermod -aG docker jimmy
#/bin/sed -i '/^%wheel/a%admin  ALL=(ALL) NOPASSWD:     ALL' /etc/sudoers
if [[ $(whoami) != "root" ]]
then
  echo "You MUST be user \"root\" to start this script.Abort the rest of process."
        exit 1 
fi

#####direct devicemapper driver########
function direct_lvm() {
pvcreate "$devpv"
vgcreate dockervg "$devpv"
lvcreate --wipesignatures y -n thinpool dockervg -l 95%VG
lvcreate --wipesignatures y -n thinpoolmeta dockervg -l 1%VG
lvconvert -y --zero n -c 512K --thinpool dockervg/thinpool --poolmetadata dockervg/thinpoolmeta
}

###docker installation########
tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF

if [ -f "/etc/yum.repos.d/docker.repo" ];then
    echo "Please be patient for Docker installation!"
    /bin/yum install docker-engine -y || dockerset=1
   if [ "$dockerset" ];then 
    /bin/systemctl enable docker 
   else 
    echo "docker-engine installation is failed!"
    exit 1
   fi
else 
   echo "Please deploy the repository for docker-engine installation!"
   exit 1
fi
echo "Please specify the disk device for Dockervg,for example /dev/sdb1"
read devpv
if [ ! -z "$devpv" ];then
     direct_lvm
else 
     echo "Please specify the disk device for Dockervg!"
     exit 1
fi

tee /etc/lvm/profile/docker-thinpool.profile <<-'EOF'
activation {
    thin_pool_autoextend_threshold=80
    thin_pool_autoextend_percent=20
}
EOF

######the parameters for Docker daemon########

if [ -f /etc/lvm/profile/docker-thinpool.profile ];then
mkdir -p /etc/docker
cat <<EOF > /etc/docker/daemon.json
 {
     "storage-driver": "devicemapper",
     "storage-opts": [
         "dm.thinpooldev=/dev/mapper/dockervg-thinpool",
         "dm.use_deferred_removal=true",
         "dm.use_deferred_deletion=true"
     ]
 }
EOF
else
 echo "Please specify the profile for dockervg thinpool!"
 exit 2
fi 
#######start docker daemon#######
if [ -f /etc/docker/daemon.json ]; then
  lvchange --metadataprofile docker-thinpool dockervg/thinpool
  rm -rf /var/lib/docker/*
  /bin/systemctl daemon-reload
  /bin/systemctl start docker
else 
  echo "Please input the parameters for the docker daemon!"
  exit 2 
fi
