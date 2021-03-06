---
layout: post
title: ROOTNFS solution for RHEL6 with netapp NAS
tag: NetAPP
---
>
1. Summary in KVM test env

test05/192.168.122.16 test06/192.168.122.17(nfs server) dhcp by kvm

1. build diskless RHEL6 client

1.1 Install dracut-network for nfsroot loading
<pre><code>
            yum install dracut-network

         # cat   /etc/dracut.conf 
dracutmodules+="nfs network base"
omit_dracutmodules+="btrfs dm dmraid dmsquash-live lvm mdraid multipath"
add_dracutmodules+="network nfs"
add_drivers+="vmxnet3"
mdadmconf="no"
lvmconf="no"
</pre></code>


1.2 Customized initramfs

dracut -f /boot/netboot6.img `uname -r`

1.3 modify grub.conf
<pre><code>
default=0
timeout=5
splashimage=(hd0,0)/grub/splash.xpm.gz
hiddenmenu
title RHEL6_diskless (2.6.32-358.el6.x86_64)
root (hd0,0)
kernel /vmlinuz-2.6.32-358.el6.x86_64 rd.debug rd.shell rd.ip=auto root=nfs:192.168.122.17:/netboot/ rw 
initrd /netboot6.img   
</pre></code>
Deploy the static ip address for diskless client
<pre><code>
title RHEL6_diskless (2.6.32-358.el6.x86_64)
root (hd0,0)
kernel /vmlinuz-2.6.32-358.el6.x86_64 rd.debug rd.shell ip=192.168.122.16:192.168.122.17::255.255.255.0:test05:eth0:off root=nfs:192.168.122.17:/netboot/ rw 
initrd /netboot6.img 
</pre></code>
2. deploy NFS server in another RHEL6

2.1 mkdir /netboot

[root@test06 etc]# cat /etc/exports

/netboot/            *(rw,async,no_root_squash)

2.2 sync the whole /  to nfs server:/netboot

rsync -a -e ssh --exclude='/proc/*' --exclude='/sys/*' test05:/ /netboot

2.3modify /netboot/etc/fstab

cat /netboot/etc/fstab

<pre><code>
 /etc/fstab
\#Created by anaconda on Thu Oct  2 09:34:37 2014
\#Accessible filesystems, by reference, are maintained under '/dev/disk'
\#See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info

192.168.122.252:/netboot/ /                   nfs    defaults        1 1
UUID=36cb173e-2705-4688-9f3c-7eb864dc1f11 /boot                   ext3    defaults        1 2
/dev/mapper/rootvg-lv_swap swap                    swap    defaults        0 0
tmpfs                   /dev/shm                tmpfs   defaults        0 0
devpts                  /dev/pts                devpts  gid=5,mode=620  0 0
sysfs                   /sys                    sysfs   defaults        0 0
proc                    /proc                   proc    defaults        0 0
</pre></code>
Reference 

http://people.redhat.com/harald/dracut-rhel6.html#Injecting

https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Storage_Administration_Guide/ 


