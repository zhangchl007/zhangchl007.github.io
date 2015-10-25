---
layout: post
title: perl-networking-programming01
tag: perl
---

I will continue learning perl network programming ,it is the first example.

server side
<pre><code>
\#!/usr/bin/perl -w
use strict;
use Socket;
use constant SIMPLE_UDP_PORT => 4001;  #define port
use constant MAX_RECV_LEN    => 65536; #1500 define frame size on Ethernet networks
use constant LOCAL_INETNAME  =>	'localhost'; #the name of the network device
my $trans_serv =getprotobyname('udp');
my $local_host =gethostbyname(LOCAL_INETNAME);
my $local_port =shift||SIMPLE_UDP_PORT;
my $local_addr =sockaddr_in($local_port,INADDR_ANY);
#$trans_serv#This value should always be the result of a successful call to getprotobyname
  socket(UDP_SOCK,PF_INET,SOCK_DGRAM,$trans_serv) or die "can't create Socket:$!\n";
  bind(UDP_SOCK,$local_addr) or die "bind failed:$!\n";
my $data;
while(1)
{   my $from_who=recv(UDP_SOCK,$data,MAX_RECV_LEN,0);
    if ($from_who)
    {
      my ($the_port,$the_ip) = sockaddr_in ( $from_who);
      my $remote_name =gethostbyaddr($the_ip,AF_INET);
     # warn "received from\t",inet_ntoa($the_ip), ": $data\n"; 
      warn "Received from $remote_name:",length($data),'->',substr($data,0,39),"\n";
      sleep(3);
    }
   else
    { warn "Problem with recv: $!\n";
}
}


<pre></code>


<a href="http://dockerpool.com/static/books/docker_practice/container/enter.html">进入容器</a>
