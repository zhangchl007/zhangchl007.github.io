---
layout: post
title: NetAPP NAS command Summary
tag: NetAPP
---
 Create Volume 

 SY2nas1a> vol create /vol/NFS_VM30_SY2AS042_A000011 aggr0 630G

SY2nas1a> snap reserve NFS_VM30_SY2AS042_A000011 20

SY2nas1a> snap sched NFS_VM30_SY2AS042_A000011 0 0 0

SY2nas1a> snap autodelete NFS_VM30_SY2AS042_A000011 on

snap autodelete NFS_VM30_SY2AS042_A000011 delete_order oldest_first

SY2nas1a> rdfile /etc/exports

/vol/vol0       -sec=sys,rw,anon=0,nosuid

/vol/vol0/home  -sec=sys,rw,nosuid

/vol/NFS_VM30_SY2AS042_A000011  -sec=sys,rw,nosuid

SY2nas1a> wrfile /etc/exports

/vol/vol0       -sec=sys,rw,anon=0,nosuid
/vol/vol0/home  -sec=sys,rw,nosuid
/vol/NFS_VM30_SY2AS042_A000011  -sec=sys,anon=0,rw=10.70.0.120,root=10.70.0.120
qtree create /vol/NFS_VM30_SY2AS042_A000011/busapps_rpdo_atc0

 wrfile /etc/quotas

/vol/NFS_VM30_SY2AS042_A000011/busapps_rpdo_atc0 tree 2G

quota on NFS_VM30_SY2AS042_A000011

SY2nas1a> exportfs

/vol/NFS_VM30_SY2AS042_A000011  -sec=sys,rw,nosuid
/vol/vol0/home  -sec=sys,rw,nosuid
/vol/vol0       -sec=sys,rw,anon=0,nosuid

SY2nas1a> exportfs -r

Add vfiler for Volume 

 vfiler add vf_NKENAS1a_vsphere00 /vol/NFS_VM30_NKEAS055_A0000010
WARNING: reassigning storage to another vfiler does not change the
security information on that storage. If the security domains are
not identical, unwanted access may be permitted, and wanted access
may be denied.

Fri Feb 27 13:19:22 ICT [NKEnas1a:cmds.vfiler.path.move:notice]: Path /vol/NFS_VM30_NKEAS055_A0000010 was moved to vFiler unit "vf_NKENAS1a_vsphere00".

NKEnas1a> vfiler status -a

vfiler0                          running
vol create Volume1 aggr1 680g

vol options  Volume1  guarantee none

vfiler add vfiler1 /vol/Volume1

vfiler run vfiler1 cifs shares -add Volume1  /vol/Volume1

vfiler run   vfiler1  cifs access -delete Volume1  everyone

vfiler run  vfiler1  cifs access  Volume1  FOL\GOOGLE_MT Read

vfiler run  vfiler1  cifs access  Volume1   FOL\GOOGLE_CA_SAs Full Control
exportfs -p rw=server40-boot.n........................root.net /vol/Volume1

vfiler run vfiler1 exportfs -p rw=server40.............root.net /vol/Volume1

qtree security /vol/ Volume1/ unix

qtree security /vol/Volume1/qtree1 unix

cifs terminate  -V Volume1

exportfs -u /vol/Volume1

useradmin domainuser add user1 -g administrator

