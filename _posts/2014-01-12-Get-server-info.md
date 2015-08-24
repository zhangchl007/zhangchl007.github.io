---
layout: post
title: collect server information/Get-server-info
tag: perl
---
<pre><code>
#!/usr/bin/perl -w
use strict;
use Term::ANSIColor;
my ($cpu,$count,$cpu_core,$mem,$version,@a,@b,%h);
my $user_name=$ENV{'USER'};
if ($user_name ne "root") {
      print color 'bold red';
      print "Please execute the script by SUDO as root!\n";
      print "For example:sudo /tmp/get_server_info.pl\n";
      print color 'reset';
      exit(1);
}
#OS Version
open (FHV,"<","/etc/issue") or die "coudn't open /etc/issue$!\n";
while (<FHV>) {
       $version=$_ if $_=~/Linux/;
       chomp($version);
} 
close FHV;
#CPU info###
open (FHC,"<","/proc/cpuinfo") or die "coudn't open /proc/cpuinfo$!\n";
#match 
while (<FHC>){
   if ($_=~/model\s+name/){
      s/model\s+name\s:\s+(.*)/$1/g;
      chomp;
      $cpu=$_;
      }
   if ($_=~/physical\s+id/) {
      s/physical\s+id\s+:\s+(\d+)/$1/g;
      push(@a,$_);
      } 
     
   if ($_=~/processor/){ 
   ++$count;
      }
   if ($_=~/cpu\s+cores/){
      s/cpu\s+cores\s+:\s+(\d+)/$1/g;
      chomp;
      $cpu_core=$_;
      } 
      
}
close FHC;
#Memory info
open (FHM,"<","/proc/meminfo") or die "coudn't open /proc/meminfo$!\n";
while (<FHM>){
   if ($_=~/MemTotal:/){
      s/MemTotal:\s+(\d+)\s+kB/$1/g;
      $mem=$_;
      }
}
close FHM;
#put scalar to array and find the max valve of physical id.
my $phynum=shift@a;
  foreach(@a){
     if ($_>$phynum){
     $phynum=$_;
  }
}
#Disk info
open (FHD,"<","/proc/partitions") or die "The /proc/partitions couldn't be openned$!\n";
while (<FHD>) {
     $h{$2}=int($1/(1000*1000)+1) if $_=~/\s+\d+\s+\d+\s+(\d+)\s+([a-z]{3}\b)/;
}
close FHD; 
####Server summary info###
open (FHS,"-|","/usr/sbin/dmidecode") or die "dmidecode permission denied$!\n";
while (<FHS>){
       #if ($_=~/System\s+Information/../Base\s+Board\s+Information/){
       if ($_=~/System\s+Information/../^$/){
            push @b,"The Manufacturer is $1\n" if $_=~/\s+Manufacturer:\s+(.*)/;
            push @b,"The Product Number is $1\n" if $_=~/\s+Product\s+Name:\s+(.*)/;
            push @b,"The Product Model is $1\n" if $_=~/\s+Version:\s+(.*)/;
            push @b,"The serial Number is $1\n" if $_=~/\s+Serial\s+Number:\s+(.*)/;
 }
}
close FHS;
#output
if (defined($phynum)){
      &Prt_info($cpu,$phynum+1,$cpu_core,$count,$mem,$version,\@b,\%h);
 }
else {
      print color 'bold yellow';
      print "Your OS is a VM\n";
      print color 'reset';
      &Prt_info($cpu,0,0,$count,$mem,$version,\@b,\%h);
  }
sub Prt_info {
     my($a,$b,$c,$d,$e,$f,$ref_array01,$ref_hash01)=@_;
     print color 'bold yellow';
     print "--------------The Server Summary----------------------\n";
     print "The OS Version is $f\n";
     print "@{$ref_array01}";
     print "The CPU mode is\t$a\n";
     print "The number of physical CPU is\t$b\n";
     print "The number of CPU cores is\t$c\n";
     print "The number of logical CPUs is\t$d\n";
     print "The Memory is\t", int($e/(1024*1024)+1),"G\n";
     while( my ($key,$value)=each%$ref_hash01) {
      print "The DISK $key is $value","G\n";
      }
     print "------------------------------------------------------\n";
     print color 'reset';
}
</pre></code>  
