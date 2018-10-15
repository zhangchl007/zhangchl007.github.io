---
layout: post
title: Ceph(12.2.8 luminous) Community Setup on RHEL 7.5
tag: Storage
---


*  Take a notes for Ceph sample Setup


1.  Ceph-deploy Setup Preperation 

   1. Firewall rule  
   2. NTP Sync
   3. Hardware Selection 
   4. use cases 
     ## Throughput-optimized:
     ## Capacity-optimized: 
     ## IOPS-optimized: 
   5. Storage Sizing 

2. Configuring ansible group and ssh authentication

```
#  cat /etc/ansible/hosts
[ceph-nodes]
ceph01 ansible_user=jimmy ansible_become=yes 
ceph02 ansible_user=jimmy ansible_become=yes
ceph03 ansible_user=jimmy ansible_become=yes
ceph04 ansible_user=jimmy ansible_become=yes

[pcs-nodes]
pcs01 ansible_user=jimmy ansible_become=yes
pcs02 ansible_user=jimmy ansible_become=yes 

#  for srv in ceph01 ceph02 ceph03 ceph04 ;do ssh-copy-id ~/.ssh/id_dsa.pub $srv;done
# cat   ~/.ssh/config 
Host ceph01
   Hostname ceph01
   User cephuser
Host ceph02
   Hostname ceph02
   User cephuser
Host ceph03
   Hostname ceph03
   User cephuser
Host ceph04
   Hostname ceph04
   User cephuser
Host pcs01
   Hostname pcs01
   User cephuser
Host pcs02
   Hostname pcs02
   User cephuser
     
```
3. Configuring firewall rules

# sudo firewall-cmd --zone=public --add-service=ceph-mon --permanent
# sudo firewall-cmd --zone=public --add-service=ceph --permanent
# sudo firewall-cmd --reload

4. Add EPEL and Ceph repo

```
# ansible ceph-nodes -m shell -a 'yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm'
# cat /etc/yum.repos.d/ceph.repo
[ceph]
name=Ceph packages for $basearch
baseurl=http://mirrors.163.com/ceph/rpm-luminous/el7/$basearch
enabled=1
gpgcheck=1
priority=1
type=rpm-md
gpgkey=http://mirrors.163.com/ceph/keys/release.asc

[ceph-noarch]
name=Ceph noarch packages
baseurl=http://mirrors.163.com/ceph/rpm-luminous/el7/noarch
enabled=1
gpgcheck=1
priority=1
type=rpm-md
gpgkey=http://mirrors.163.com/ceph/keys/release.asc

[ceph-source]
name=Ceph source packages
baseurl=http://mirrors.163.com/ceph/rpm-luminous/el7/SRPMS
enabled=0
gpgcheck=1
type=rpm-md
gpgkey=http://mirrors.163.com/ceph/keys/release.asc

- copy to each node 

# ansible ceph-nodes -m copy -a 'src=/etc/yum.repos.d/ceph.repo dest=/etc/yum.repos.d/'
# ansible ceph-nodes -mshell -a 'yum clean all'
# ansible ceph-nodes -mshell -a 'yum update -y'
# ansible ceph-nodes -myum -a 'name=ceph-deploy state=latest'
# ansible ceph-nodes -mshell -a 'ceph -v'
ceph03 | SUCCESS | rc=0 >>
ceph version 12.2.8 (ae699615bac534ea496ee965ac6192cb7e0e07c0) luminous (stable)

ceph02 | SUCCESS | rc=0 >>
ceph version 12.2.8 (ae699615bac534ea496ee965ac6192cb7e0e07c0) luminous (stable)

ceph01 | SUCCESS | rc=0 >>
ceph version 12.2.8 (ae699615bac534ea496ee965ac6192cb7e0e07c0) luminous (stable)

ceph04 | SUCCESS | rc=0 >>
ceph version 12.2.8 (ae699615bac534ea496ee965ac6192cb7e0e07c0) luminous (stable)


```
5. Add Ceph user

``` 
# ansible ceph-nodes -mshell -a 'useradd -d /home/cephuser -m cephuser'
# ansible ceph-nodes -mshell -a 'echo "cephuser ALL = (root) NOPASSWD:ALL" | tee /etc/sudoers.d/cephuser'
- create directory 
# mkdir -p my-cluster/
# ceph-deploy new ceph02 ceph03 ceph04

# ceph-deploy install  ceph01 ceph02 ceph03 ceph04
# ceph-deploy mon create-initial
# ceph-deploy admin ceph01
# ceph-deploy osd create --data /dev/vdb ceph02
# ceph-deploy osd create --data /dev/vdb ceph03
# ceph-deploy osd create --data /dev/vdb ceph04
# sudo ceph -s
# sudo ceph health
# ceph-deploy mgr create ceph01
# sudo ceph config-key put mgr/dashboard/server_addr 192.168.0.21
# sudo ceph config-key put mgr/dashboard/server_port 8000
# vi  ceph.conf
[global]
fsid = f888d0f7-1cba-438e-b5ac-8ea29c79471c
mon_initial_members = ceph02, ceph03, ceph04
mon_host = 192.168.0.22,192.168.0.23,192.168.0.24
auth_cluster_required = cephx
auth_service_required = cephx
auth_client_required = cephx
osd_pool_default_size = 2
osd_pool_default_min_size = 1
rbd_default_features = 1
osd_pool_default_pg_num = 128
osd_pool_default_pgp_num = 128
public_network =  192.168.0.0/24
[mon]
mon_clock_drift_allowed = 1
mon clock drift warn backoff = 30
mon_allow_pool_delete = true
[mgr]
mgr modules = dashboard
# sudo ceph mgr module enable dashboard
# sudo systemctl restart ceph-mgr@ch-mon-1
# ceph-deploy --overwrite-conf config push ceph02 ceph03 ceph04
# sudo ceph quorum_status --format json-pretty
# sudo  ceph osd tree
ID CLASS WEIGHT  TYPE NAME       STATUS REWEIGHT PRI-AFF 
-1       0.08789 root default                            
-3       0.02930     host ceph02                         
 0   hdd 0.02930         osd.0       up  1.00000 1.00000 
-5       0.02930     host ceph03                         
 1   hdd 0.02930         osd.1       up  1.00000 1.00000 
-7       0.02930     host ceph04                         
 2   hdd 0.02930         osd.2       up  1.00000 1.00000

```


