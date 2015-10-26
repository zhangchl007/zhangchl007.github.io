---
layout: post
title: perl-networking-programming01
tag: perl
---

 Please see the socket sample server/client 

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
\#$trans_serv#This value should always be the result of a successful call to getprotobyname
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
      send( UDP_SOCK, $data, 0, $from_who )
      or warn "udp_s5: send to socket failed.\n";

    }
   else
    { warn "Problem with recv: $!\n";
  }
}
<pre></code>

client side
<pre><code>
\#!/usr/bin/perl -w
use strict;
use Socket;
use constant MAX_RECV_LEN    =>65536;
use constant SIMPLE_UDP_PORT => 4001;
use constant REMOTE_HOST     =>	'localhost';
my $trans_serv =getprotobyname('udp');
my $remote     =shift || REMOTE_HOST;
my $remote_host =gethostbyname($remote) or die "udp_c2:name lookup failed:$remote\n";
my $remote_port =shift ||SIMPLE_UDP_PORT;
my $destination =sockaddr_in($remote_port,$remote_host);
  socket(UDP_SOCK,PF_INET,SOCK_DGRAM,$trans_serv) or die "udp_c2:can't create Socket:$!";
my $msg_count=1;
my $big_chunk='x'x 65000;
while ( $msg_count <11)
{
my $data=$msg_count.'->'.$big_chunk;
send(UDP_SOCK,$data,0,$destination) or warn "udp_c6: send to socket failed: $msg_count\n";
sleep(1);
$msg_count++;

$SIG{ALRM}=sub{die "recv timeout\n"};
alarm(5);
eval {
     my $from_who=recv(UDP_SOCK, $data,MAX_RECV_LEN,0);
     if ($from_who)
    {
      my ($the_port,$the_ip)=sockaddr_in($from_who);
      my $remote_name =gethostbyaddr($the_ip,AF_INET);
       warn "Received from $remote_name:",length($data),
      '->',substr($data,0,39),"\n";
     } else {
         warn "problem with recv: $!\n";
         }
       alarm(0);
};
if ($@)
 {
    die "udp_c6: $@\n" unless $@=~/recv timeout/;
    warn "udp_c6: recv timed out, canceling ...\n";

 }
}
close UDP_SOCK or die "udp_c6:close socket failed:$!\n";
<pre></code>

<a href="http://dockerpool.com/static/books/docker_practice/container/enter.html">进入容器</a>
