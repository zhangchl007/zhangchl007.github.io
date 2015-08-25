---
layout: post
title: A script to get cron jobs on AIX servers
tag: perl
---
I wrote a script to capture the tasks in cron job on AIX , but I feel it's not good ,which is more complicated than shell 
<pre><code>
\#!/usr/bin/perl -w
use strict;
use Term::ANSIColor;
my (@b,%c);
my $user_name=$ENV{'USER'};
if ($user_name ne "root") {
      print color 'bold red';
      print "Please execute the script by SUDO as root!\n";
      print "For example:sudo /tmp/get_server_info.pl\n";
      print color 'reset';
      exit(1);

}
open(my $fh,'<','/var/spool/cron/crontabs/root') or die "the dirctory can't be openned $!";
while (<$fh>) {
    if ($_!~/^#(.*)/) {
    my @a=split;
    push @b,"$a[5]\n";
    }
    @b=grep {++$c{$_} <2 }@b;

#    print "@b";
foreach my $b(@b) {
        system("/usr/bin/ls -lR $b");
   }

}
closedir $fh
</pre></code>
