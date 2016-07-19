---
layout: post
title: AIAVitality Transition Project
tag: Linux
---
AIA Vitality Satellite system overview : DSY Satellite server would be Satellite 5,  

a three-tier architectur. the global satellite server -proxy server -client

1. DSY disconnect the server and remove the managed linux/proxy system registration 

2. build the new satellite server and and re-active the proxy system

    1. what's the step on old server
    2. What's the step on new server
    3. how to re-active the satellite proxy 
3. deploy client agent

4. How Puppet/cobbler are interated into Satellite server

5. How many Linux client server will be supported
6.Git

7.database/postpress sql

If you suspect you have version 5.2 or older, use the rpm query command to see what version of rhns you have installed:

# rpm -q rhns
rhns-5.1.1-16
Use the rhn-schema-version command to query the database for its schema version:

# rhn-schema-version
5.1.0-27
<pre><code>
installation steps
1.
mkdir -p /var/satellite
mkdir -p /var/cache/rhn
mkdir -p /var/lib/linux
mkdir /home/satellite_install
mkdir -p /opt/rh/postgresql92/root/var/lib/pgsql
2.
/dev/mapper/vg_satellite5-lv_rhn
                       15G   38M   14G   1% /var/cache/rhn
/dev/mapper/vg_satellite5-lv_pgsql
                      4.8G   10M  4.6G   1% /opt/rh/postgresql92/root/var/lib/pgsql
/var/lib/linux/rhel6.iso
                      3.6G  3.6G     0 100% /var/lib/linux
3.yum install OpenIPMI OpenIPMI-libs lm_sensors-libs net-snmp-libs redhat-rpm-config
rning: more packages were installed by yum than expected:
	redhat-rpm-config
Warning: yum did not install the following packages:
	OpenIPMI
	OpenIPMI-libs
	lm_sensors-libs
	net-snmp-libs
4.Activate the satellite certificate

mv satellite5.test.com.xml  satellite5.test.com.cert

5.Installation complete.
Visit https://satellite5.test.com to create the Red Hat Satellite administrator account.

 https://avplinsat01.aiavitality.com
configure email forward
satadmin/AIA_secure01
ln -s /usr/bin/ack_enqueuer.pl /etc/smrsh/.
Open your firewall to the following hosts for access to Red Hat's Content D elivery Network (CD N):
rhn.red hat.com
xmlrpc.rhn.redhat.com
satellite.rhn.red hat.co m
content-xmlrpc.rhn.redhat.com
content-web.rhn.redhat.com
content-satellite.rhn.redhat.com
<pre></code>

`
