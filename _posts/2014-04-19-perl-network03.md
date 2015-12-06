---
layout: post
title: perl-networking-programming02(TCP)
tag: perl
---

 Please see the socket sample server/client 

server side
<pre><code>
\#!/usr/bin/perl -w
use strict;
use Socket;
use IO::Handle;
use constant MY_ECHO_PORT => 2007;

my ($bytes_out,$bytes_in) = (0,0);

my $port =shift || MY_ECHO_PORT;
my $protocol =getprotobyname ('tcp');
$SIG{'INT'} = sub {
     print STDERR "bytes_sent = $bytes_out,bytes_received = $bytes_in\n";
     exit 0;
};
socket(SOCK, AF_INET, SOCK_STREAM, $protocol) or die "socket) failed: $!";
setsockopt(SOCK,SOL_SOCKET,SO_REUSEADDR,1)    or die "Can't set SO_REUSADDR: $!" ;

my $my_addr =sockaddr_in($port,INADDR_ANY);
bind(SOCK,$my_addr) or die "bind() failed: $!";

listen(SOCK,SOMAXCONN) or die "listen() failed: $!";

warn "waiting for incoming connecdtions on port $port...\n";

while (1) {
   next unless my $remote_addr = accept (SESSION,SOCK);
   my ($port,$hisaddr) = sockaddr_in($remote_addr);
   warn "Connection from [",inet_ntoa($hisaddr),",$port]\n";
   SESSION->autoflush(1);

   while (<SESSION>) {
     $bytes_in +=length($_);
     chomp;
     my $msg_out =(scalar reverse $_) . "\n";
     print SESSION $msg_out;
     $bytes_out +=length($msg_out);
    }

   warn " Connection from [",inet_ntoa($hisaddr),",$port] finished\n";
   close SESSION;
}
close SOCK;
<pre></code>
client side
<pre><code>
\#!/usr/bin/perl -w
\###usage pl_socket03_c01.pl host port#######
use strict;
use Socket;
use IO::Handle;
my ($bytes_out,$bytes_in) = (0,0);
my $host =shift || 'localhost';
my $port =shift || getservbyname('echo','tcp');
my $protocol = getprotobyname('tcp');
$host =inet_aton($host) or die "$host: unknown host";
socket(SOCK, AF_INET, SOCK_STREAM, $protocol) or die "socket() failed: $!";

my $dest_addr = sockaddr_in($port,$host);
connect(SOCK,$dest_addr) or die "connect() failed: $!";
SOCK->autoflush(1);

while (my $msg_out = <>) {
   print SOCK $msg_out;
   my $msg_in = <SOCK>;
   print $msg_in;
   $bytes_out += length($msg_out);
   $bytes_in  += length($msg_in);
}
close SOCK;
print STDERR "bytes_sent = $bytes_out, bytes_received = $bytes_in\n";
<pre></code>

<a href="https://github.com/zhangchl007/zhangchl007.github.io/blob/master/upload/pl_sock_stcp02.pl">server side code</a>
<a href="https://github.com/zhangchl007/zhangchl007.github.io/blob/master/upload/pl_sock_ctcp02.pl">client side code</a>
