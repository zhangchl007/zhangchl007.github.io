---
layout: post
title: A script to format /etc/security for AIX
tag: perl
---
I wrote a script to capture the tasks in cron job on AIX , but I feel it's not good ,which is more complicated than shell 
<pre><code>
\#!/usr/bin/perl -w
use strict;
use File::Basename qw(fileparse);
my @lsdir= glob "/home/hp09396/Spasswd/Spasswd*";
foreach my $dir (@lsdir) {
    my ($fname,$fdir)=fileparse($dir);
    open (FH,"<","$dir") or die "coudn't open password file:$!\n";
    open (OU,">","/tmp/$fname") or die "coudn't creat the file:$!\n";
    while (<FH>){
        chomp if  $_=~/=/ or $_=~/\w+:/;
        s/\s+password\s+=\s+//g;
        s/\s+lastupdate\s+=\s+/:/g;
        s/\s+flags\s+=\s+/:/g;
        print OU
  }
print OU "\n";
#rename("/tmp/passwd_","$name");
close(FH);
close(OU);
};
chmod 0644, glob "/tmp/Spasswd*";
</pre></code>
