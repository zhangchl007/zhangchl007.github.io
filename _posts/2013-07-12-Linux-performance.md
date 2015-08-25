---
layout: post
title: LInux performance tuning basic 
tag: Linux
---
Case 1  . CPU

shell bomp 
<pre><code>
:() { :|:& };:
</pre></code>

Example 3-1 uptime output from a CPU strapped system

18:03:16 up 1 day, 2:46, 6 users, load average: 182.53, 92.02, 37.95

zhangchl perl]$ cat cpuhigh.pl 
<pre><code>
\#!/usr/bin/perl -w

use strict;

my $maxchp=20;

my $i=0;

#for (my $i=0;$i<=100;$i++)

while(1)  

{ 

   print "currect process is $$.....$i\n";

    $i++;

   my $pid=fork();

   if (!(defined $pid))

      {   die "can't fork a child process!\n";}

   elsif($pid==0)

      { print "This is child process$$\n";

        exit;}

   else

      { print "This is parent process$$\n";}

}
</pre></code>
<a href="http://pan.baidu.com/s/1i3quzmH">It's a internal traning material</a>
