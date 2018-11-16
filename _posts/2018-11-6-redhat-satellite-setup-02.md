---
layout: post
title: Satellite Installation Part2
tag: Linux
---

Capsule Server Installation

+ 1 Preparation host

Table 1.2. Storage Requirements for Capsule Server Installation
 
| Directory | Installation Size | Runtime Size	| Considerations |
|--------|--------|--------|--------|
| /var/cache/pulp/  |  1M  |    20G |    See the notes in this section’s introduction    |
| /var/lib/pulp/    |  1M  | 500M   |    Continues to grow as content is added    |
| /var/lib/mongodb/ | 3.5 GB |  50GB |   Continues to grow as content is added     |

Create and mount the related directory

```
# mkdir -p {/var/lib/pulp/,/var/lib/mongodb/}
# pvcreate /dev/vdb
# vgcreate datavg /dev/vdb
# lvcreate -L 60G -n satedata_lv datavg
# lvcreate -L 20G -n mongodb_lv datavg
# mkfs.xfs /dev/mapper/datavg-satedata_lv
# mkfs.xfs /dev/mapper/datavg-mongodb_lv
# grep _lv /etc/fstab
/dev/mapper/datavg-satedata_lv         /var/lib/pulp     xfs     defaults        0 0
/dev/mapper/datavg-mongodb_lv         /var/lib/mongodb   xfs     defaults        0 0

Synchronizing Time using chronyd

# ansible sat-nodes -a 'yum install chrony -y'
# ansible sat-nodes -a 'systemctl start chronyd'
# ansible sat-nodes -a 'systemctl enable chronyd'

```

# Enabling Connections from Satellite Server and Clients to a Capsule Server

```
# firewall-cmd --add-port="53/udp" --add-port="53/tcp" \
--add-port="67/udp" --add-port="69/udp" \
--add-port="80/tcp" --add-port="443/tcp" \
--add-port="5000/tcp" --add-port="5647/tcp" \
--add-port="8000/tcp" --add-port="8140/tcp" \
--add-port="8443/tcp" --add-port="9090/tcp"
# firewall-cmd --runtime-to-permanent
# firewall-cmd --reload
# firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: eth0
  sources: 
  services: ssh dhcpv6-client
  ports: 53/udp 53/tcp 67/udp 69/udp 80/tcp 443/tcp 5000/tcp 5647/tcp 8000/tcp 8140/tcp 9090/tcp
  protocols: 
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 

```
# Enabling Connections from Capsule Server to Satellite Server

```
Configure the firewall on Satellite Server:

# firewall-cmd --add-port="5000/tcp" \
--add-port="5646/tcp" --add-port="443/tcp" \
--add-port="5647/tcp" --add-port="80/tcp"

Make the changes persistent:

# firewall-cmd --runtime-to-permanent
````
# Synchronizing Time 
```
# yum install chrony
# systemctl start chronyd
# systemctl enable chronyd
```
# Deploy virt-who for KVM Host and Guest

```
# For host
# cat /etc/virt-who.d/kvm.conf 
[kvm]
type=libvirt
owner=test_com
env=Development/rhel7_base
hypervisor_id=hostname

#for guest
#cat /etc/virt-who.d/kvm.conf 
[hypervisor1]
type=libvirt
hypervisor_id=hostname
server=qemu+ssh://192.168.0.101/system
owner=test_com 
env=Development/rhel7_base

```

# Registering to Satellite Server

```
# rpm -Uvh http://satellite.example.com/pub/katello-ca-consumer-latest.noarch.rpm

# subscription-manager clean
# subscription-manager register --org="test_com" --activationkey="dev-key"

```

##Attaching the Capsule Server Subscription

```
# subscription-manager repos --disable "*"

# subscription-manager repos --enable rhel-7-server-rpms \
--enable rhel-7-server-satellite-capsule-6.4-rpms \
--enable rhel-server-rhscl-7-rpms \
--enable rhel-7-server-satellite-maintenance-6-rpms \
--enable rhel-7-server-ansible-2.6-rpms
```

## Capsule Server setup

```
# yum install satellite-capsule -y

```

## Performing Initial Configuration of Capsule Server

Create the certificates archive on ==Satellite Server==
```
# sudo capsule-certs-generate \
--foreman-proxy-fqdn mycapsule.example.com \
--certs-tar mycapsule.example.com-certs.tar

# sudo satellite-installer --scenario capsule\
                      --foreman-proxy-content-parent-fqdn           "satellite01.example.com"\
                      --foreman-proxy-register-in-foreman           "true"\
                      --foreman-proxy-foreman-base-url              "https://satellite01.example.com"\
                      --foreman-proxy-trusted-hosts                 "satellite01.example.com"\
                      --foreman-proxy-trusted-hosts                 "satellite02.example.com"\
                      --foreman-proxy-oauth-consumer-key            "fVzvZjbU2MUdiwqxn6BaFmRYPS83PNqF"\
                      --foreman-proxy-oauth-consumer-secret         "uzwXn36bs5BgYFtRVbin9Ni3wc54vsuh"\
                      --foreman-proxy-content-certs-tar             "/home/jimmy/satellite02.example.com-certs.tar"\
                      --puppet-server-foreman-url                   "https://satellite01.example.com"

```

## Patching Your System Using Katello Agent

```
    # yum install katello-agent
     On Red Hat Enterprise Linux 6, run the following command:

    # service goferd start

    On Red Hat Enterprise Linux 7, run the following command:

    # systemctl start goferd
     Install client package:

    To report package & errata information:

    # yum -y install katello-host-tools
    To optionally report tracer information:

    # yum -y install katello-host-tools-tracer
    For remote actions and reporting package & errata information:
```
## Enabling Remote Execution on Capsule Server

```
# satellite-installer --scenario capsule \
--enable-foreman-proxy-plugin-remote-execution-ssh
```

## Adding Life Cycle Environments to Capsule Servers

```
# hammer capsule list
# hammer capsule info --id capsule_id_number
# hammer capsule content available-lifecycle-environments \
--id capsule_id_number
# hammer capsule content add-lifecycle-environment \
--id capsule_id_number --environment-id environment_id_number

To synchronize all content from your Satellite Server environment to Capsule Server, enter the following command:

# hammer capsule content synchronize --id capsule_id_number

To synchronize a specific life cycle environment from your Satellite Server to Capsule Server, enter the following command:
# hammer capsule content synchronize --id external_capsule_id_number \
--environment-id environment_id_number

```

## Enabling Power Management on Managed Hosts

```
# satellite-installer --scenario capsule \
--foreman-proxy-bmc "true" \
--foreman-proxy-bmc-default-provider "freeipmi"
```
# Configuring DNS, DHCP, and TFTP on Capsule Server

```
# satellite-installer --scenario capsule \
--foreman-proxy-dns true \
--foreman-proxy-dns-managed true \
--foreman-proxy-dns-interface eth0 \
--foreman-proxy-dns-zone example.com \
--foreman-proxy-dns-forwarders 172.17.13.1 \
--foreman-proxy-dns-reverse 13.17.172.in-addr.arpa \
--foreman-proxy-dhcp true \
--foreman-proxy-dhcp-managed true \
--foreman-proxy-dhcp-interface eth0 \
--foreman-proxy-dhcp-range "172.17.13.100 172.17.13.150" \
--foreman-proxy-dhcp-gateway 172.17.13.1 \
--foreman-proxy-dhcp-nameservers 172.17.13.2 \
--foreman-proxy-tftp true \
--foreman-proxy-tftp-managed true \
--foreman-proxy-tftp-servername $(hostname)
```
##  Configuring Capsule Server with a Custom Server Certificate
