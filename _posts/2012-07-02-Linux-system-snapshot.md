---
layout: post
title: Collecting diagnostic information for Linux operating systems (2032614)
tag: Linux
---

Tehnicians request diagnostic information from you when a Linux related support request is addressed. This diagnostic information contains general logs and configuration files from the Linux guest operating system. This information is gathered using a specific script or tool within the different distributions.

Note: Collecting diagnostic information is the same as collecting or gathering log files.

This article provides procedures for obtaining diagnostic information for the operating systems Red Hat Enterprise Linux (RHEL) and SUSE Linux Enterprise Desktop/Server (SLES/SLED). All commands in this document have to be executed in the virtual machine guest.

The diagnostic information obtained by using this article is uploaded to VMware Technical Support. To properly identify your information, you need to use the Support Request number you receive when you create the new SR.

Notes:

Resolution
Depending on the used Linux distribution, different tools and commands are used to collect the required data.

Note: All commands require root privileges. A root shell can be obtained with the sudo -s command if the root account is not available.

Novell SUSE Linux Enterprise Server/Desktop (SLES/SLED) 10.x, 11.x and SLES for VMware 11.x

Note: Though these below steps explicitly refer to Novell SUSE Linux, they are also applicable to openSUSE.

SUSE Linux includes the supportconfig command to collect general system information and logs.

The generated file is stored at /var/log/nts_hostname_ date_time.tbz.

Usually, there is no need to install the supportutils package which contains the supportconfig command. However, it can manually be installed via YaST or zypper if it is not already installed. To use YaST to install the necessary package, run this command:
 
yast -i supportutils

For more information, see http://www.novell.com/communities/node/2332/supportconfig-linux.

Novell Support Advisor can be used as an alternative to collect diagnostic information from a SUSE Linux system. The client used to collect the diagnostic information runs on Linux and Microsoft Windows platforms. It can remotely collect diagnostic information from multiple systems and provides a graphical user interface.

For more information, see http://support.novell.com/advisor/.


Red Hat Enterprise Linux (RHEL) 4.6+, 5.x, 6.x

Note: Though these steps explicitly refer to Red Hat Enterprise Linux, they are also applicable to Oracle Linux, CentOS, Scientific Linux and Fedora.

Red Hat Enterprise Linux includes the sosreport command to collect general system information and logs.

Note: Version 4.6 and earlier require the use of the sysreport command. For more information, see https://access.redhat.com/knowledge/articles/1207.

sosreport is installed by default. It can be installed with yum install sos on RHEL 5 and newer or up2date sos on RHEL 4.7 or later, if it is not already installed.

The generated file is stored at /tmp/sosreport-* and is usually in the format tar.xz, gz, or bz2.

For more information, see https://access.redhat.com/knowledge/solutions/3592.
Request a Product Feature
To request a new product feature or to provide feedback on a VMware product, please visit the Request a Product Feature page.

