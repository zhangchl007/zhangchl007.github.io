#  Satellite Installation

+ 1. Subscribed Red hat Channel for installation 

```
# subscription-manager register
# subscription-manager list --available --matches "*Satellite*"
# subscription-manager attach --pool=8a85f9874152663c0541943739717d11
# subscription-manager repos --disable "*"
# subscription-manager repos --enable=rhel-7-server-rpms \
--enable=rhel-server-rhscl-7-rpms \
--enable=rhel-7-server-satellite-6.4-rpms \
--enable=rhel-7-server-satellite-maintenance-6-rpms \
--enable=rhel-7-server-ansible-2.6-rpms
# yum clean all
# yum repolist

```
+ 2 Preparation host

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

# Starting setup

```

# yum install satellite -y
Install Satellite Server and perform the initial configuration

# satellite-installer --scenario satellite \
--foreman-initial-organization "test.com" \
--foreman-initial-location "Shenzhen" \
--foreman-admin-password redhat \
--foreman-proxy-puppetca true \
--foreman-proxy-tftp true \
--enable-foreman-plugin-discovery

Automatically configuring Satellite Server using an Answer File
cp /etc/foreman-installer/scenarios.d/satellite-answers.yaml \
/etc/foreman-installer/scenarios.d/my-answer-file.yaml

```

# Enabling Connections from a Client to Satellite Server

```
# firewall-cmd \
--add-port="53/udp" --add-port="53/tcp" \
--add-port="67/udp" --add-port="69/udp" \
--add-port="80/tcp"  --add-port="443/tcp" \
--add-port="5000/tcp" --add-port="5647/tcp" \
--add-port="8000/tcp" --add-port="8140/tcp" \
--add-port="9090/tcp"
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

##  Exporting a Subscription Manifest from the Customer Portal and Uploading a Manifest to Your Satellite Server

```
sudo hammer subscription upload \
> --file ~/manifest_file.zip \
> --organization "test.com"
warning: Overriding "Content-Type" header "multipart/form-data" with "multipart/form-data; boundary=----RubyFormBoundaryYEALD05RAEvaS9Ka" due to payload
[.....................................................................................] [100%]

```
## Creating the Domain

```
hammer domain create --name "test.cn" \
--description "My Org domain" \
--dns-id 1 --locations "Shenzhen" \
--organizations "test.com"

```
## Creating subnet

```
hammer subnet create --name Dynamic_Net \
--organizations 'test.com' \
--locations 'Shenzhen' \
--domain-ids 1 \
--boot-mode DHCP \
--network 192.168.0.0 \
--mask 255.255.255.0 \
--ipam None \
--dns-primary 192.168.0.1 \
--gateway 192.168.0.1 \
--from 192.168.0.10 \
--to 192.168.0.50 \
--tftp-id 1

hammer subnet create --name Static_Net \
--organizations 'test.com' \
--locations 'Shenzhen' \
--domain-ids 1 \
--boot-mode Static \
--network 192.168.0.0 \
--mask 255.255.255.0 \
--ipam None \
--dns-primary 192.168.0.1 \
--gateway 192.168.0.1 \
--from 192.168.0.70 \
--to 192.168.0.80 \
--tftp-id 1

sub net can be removed if it's useless

# sudo hammer subnet update --domains "" --name Sub_Net
# sudo hammer subnet delete --name Sub_Net --organization 'test.com' --location 'Shenzhen'

```
## Importing Subscriptions and Synchronizing Content

- Enable your Kickstart repository. 

```
# hammer repository-set enable --organization "test.com" \
--product 'Red Hat Enterprise Linux Server' \
--basearch='x86_64' \
--releasever='7Server' \
--name 'Red Hat Enterprise Linux 7 Server (Kickstart)'

```
- Enable your\ rhel7 server repository.

```
# hammer repository-set enable --organization "test.com" \
--product 'Red Hat Enterprise Linux Server' \
--basearch='x86_64' \
--releasever='7Server' \
--name 'Red Hat Enterprise Linux 7 Server (RPMs)'

```

- Enable your Satellite Tools repository.

```
# hammer repository-set enable --organization "test.com" \
--product 'Red Hat Enterprise Linux Server' \
--basearch='x86_64' \
--name 'Red Hat Satellite Tools 6.4 (for RHEL 7 Server) (RPMs)'

# sudo hammer repository list
---|------------------------------------------------------------|---------------------------------|--------------|---------------------------------------------------------------------------------
ID | NAME                                                       | PRODUCT                         | CONTENT TYPE | URL                                                                             
---|------------------------------------------------------------|---------------------------------|--------------|---------------------------------------------------------------------------------
3  | Red Hat Enterprise Linux 7 Server Kickstart x86_64 7Server | Red Hat Enterprise Linux Server | yum          | https://cdn.redhat.com/content/dist/rhel/server/7/7Server/x86_64/kickstart      
4  | Red Hat Satellite Tools 6.4 for RHEL 7 Server RPMs x86_64  | Red Hat Enterprise Linux Server | yum          | https://cdn.redhat.com/content/dist/rhel/server/7/7Server/x86_64/sat-tools/6....

```
- Creating a Custom  repositories

```
# hammer product create --name "Puppet" --organization
# hammer repository create --name "Puppet Modules" \
--organization 'test.com' \
--product "Puppet" \
--content-type cont_type \
--publish-via-http true \
--url ""
# 
```

# Synchronization

```
# hammer repository synchronize --organization "test.com" \
--product 'Red Hat Enterprise Linux Server' \
--name  'Red Hat Enterprise Linux 7 Server Kickstart x86_64 7.5' \
--async
# hammer repository synchronize --organization "test.com" \
--product 'Red Hat Enterprise Linux Server' \
--name 'Red Hat Satellite Tools 6.4 for RHEL 7 Server RPMs x86_64' \
--async

```

## Managing and Promoting Content

* Creating Application Life Cycle Environments

```
# hammer lifecycle-environment create --name Development \
--prior Library \
--organization  'test.com'

# hammer lifecycle-environment  list
---|-------------|--------
ID | NAME        | PRIOR  
---|-------------|--------
4  | Development | Library
1  | Library     |        
---|-------------|--------
```
* Creating Content Views Using Hammer CLI

````
# hammer content-view create --organization "test.com" \
--name 'RHEL7_Base' \
--label rhel7_base \
--description 'Core Build for RHEL 7'

```
* Add the Kickstart repository and the Satellite Tools repository

```
# hammer content-view add-repository --organization "test.com" \
--name 'RHEL7_Base' --product 'Red Hat Enterprise Linux Server' \
--repository 'Red Hat Enterprise Linux 7 Server Kickstart x86_64 7Server'

# hammer content-view add-repository --organization "test.com" \
--name 'RHEL7_Base' \
--product 'Red Hat Enterprise Linux Server' \
--repository 'Red Hat Satellite Tools 6.4 for RHEL 7 Server RPMs x86_64'

# hammer content-view puppet-module add --organization "test.com" \
--content-view RHEL7_Base \
--name motd  --author jeffmccune

```
## Publishing a Content View and Promote your Content View

```
# hammer content-view publish --organization "test.com" \
--name RHEL7_Base \
--description 'Initial Publishing'

# hammer content-view version promote \
--organization "test.com" \
--content-view RHEL7_Base \
--to-lifecycle-environment Development

```
# Creating and Editing Activation Keys

```
# subscription-manager clean
# rpm -Uvh http://satellite.example.com/pub/katello-ca-consumer-latest.noarch.rpm
# subscription-manager register --org="test_com" --activationkey="dev-key"
```

# Registering Existing Hosts

```
# rpm -Uvh http://satellite.example.com/pub/katello-ca-consumer-latest.noarch.rpm

# subscription-manager clean
# subscription-manager register --org="test_com" --activationkey="dev-key"

```
# Patching Your System Using Katello Agent

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

    # yum -y install katello-agent

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
