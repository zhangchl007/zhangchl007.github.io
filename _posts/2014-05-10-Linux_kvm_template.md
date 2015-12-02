---
layout: post
title: How to make a kvm guest template for virt-clone 
tag: Linux
---
Let us see the steps below. 
Create a kvm guest
<pre><code>
virt-install --connect qemu:///system \
       --name docker01 \
       --vcpus 1 \
       --ram 1024 \
       --disk path=/var/lib/1libvirt/images/docker01.img,size=8  \
       --network bridge:virbr0 \
       --accelerate \
       --vnc \
       --arch x86_64 \
        --pxe
<pre></code>
How to make a kvm guest os
<pre><code>
1.  Creating Definition File And Template Image and shut down docker01
jimmy@oc3053148748 Downloads]$ sudo virsh list --all
 Id    Name                           State
----------------------------------------------------
 1     Cobbler                        running
 2     Linux_Windows_7-KVM            running
 4     Coreos01                       running
 -     docker01                       shut off
2.  virsh dumpxml docker01 >/home/jimmy/Downloads/template.xml
3.  cp docker01.img  /home/jimmy/Downloads/template.img
4.  in template.xml point the disk source file to template.img
5.  run virt-sysprep 
virt-sysprep -a /home/jimmy/Downloads/template.img
6.Cloning new VMs from Template

virt-clone --connect qemu:///system                    \
  --original-xml /home/jimmy/Downloads/template.xml  \
  --name docker02                                        \
  --file /var/lib/libvirt/images/docker02.img
<pre></code>
