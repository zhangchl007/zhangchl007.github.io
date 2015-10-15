#!/usr/bin/perl -w
use strict;
use Term::ANSIColor;
use File::Basename qw(fileparse);
my (@b,%h);
my ($due_time,$adv_id,$line,$os_version,$up_version,$apar_id);
my $str=`hostname`;
chomp($str);
my @lssec= glob "/tmp/lssec/secfixdb.*";
my $lssec_db= grep /redhat[56]/i, @lssec;

sub mkrpm_list;
sub chk_pre;

if ( -e "/etc/redhat-release"){
     $os_version="RedHat";
     chk_pre();
   }
else {print "Please make sure OS version is RedHat\n";
     exit(1)
    }

sub chk_pre {
if ( -e "/tmp/lssec/lssecfixes" && defined($lssec_db)){
     my @input=`perl /tmp/lssec/lssecfixes -d . -p >"/tmp/patch_$str.txt" 2>/dev/null`;
     my $exit=mkrpm_list();
     if ($exit==0) {
        print "The APARs list had been generated under /tmp/patch_$str.txt!\n"
        }
     else {
       print "The APARs list can't be generated under /tmp!\n"
        }
     }

else {
     print color 'bold red';
     print << "EOF";
     ----------------------------------------------------------------------------------------
     Please make sure you already put the lssecfixes and db under the currunt path
     secfixdb can download from
     wget -c --retr-symlinks http://lssec.hursley.ibm.com/secfixdb/lssec_secfixdb_all.tar.gz
     ----------------------------------------------------------------------------------------
EOF
      print color 'reset';
    }

}
sub mkrpm_list {
open (FH,"<","/tmp/patch_$str.txt") or die "coudn't open lssecfixes result:\t$!\n";
while (<FH>){
       if ($_=~/(^\d+)\/(\d+)\/(\d+).*?(RHSA-\d+:\d+-?\d+).*/) {
           #s/(^\d+)\/(\d+)\/(\d+).*?(RHSA-\d+:\d+-?\d+).*/$3$1$2/g;
           chomp;
           $adv_id=$4;
           $due_time="$3$1$2";
           next
         }

         if ($_=~/\</) {
         @_=split;
         my $new_cl="$_[0]"."-$_[3]";
         $line="$due_time\t$adv_id\t$new_cl\t"."$_";
         @b=split(/\s+/,$line);
         if(!defined$h{$b[3]}||$h{$b[3]}->[0]<$b[0]) {
            $h{$b[3]}=[@b[0..3]];
           }
         }
}
close(FH);
#Generate patch update list for each server
open (OU,">","/tmp/patch_$str.txt") or die "The file coudn't be created:\t$!\n";
#print the hash as the newest patch
while ( my($k,$v)= each%h) {
       print OU "@$v\n";
 }

close(FH);
}

