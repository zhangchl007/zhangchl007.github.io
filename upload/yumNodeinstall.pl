#!/usr/bin/perl -w
use strict;
use Term::ANSIColor;
my ($rpmliststring,$rpmshotstring);
my $str=`hostname`;
chomp($str);
sub yum_inst {
       open (FH,"<","/tmp/patch_$str.txt") or die "coudn't open lssecfixes result:\t$!\n";
       while (<FH>){
       chomp;
       @_=split;
       $rpmliststring=$_[2];
       $rpmshotstring=$_[3];
       if ( $rpmliststring=~/kernel/) {
          print "Don't upgrade the kerenl by yum update, Please install new kerenl!\n";
          next
        }
       else {

       #my $result= qx{yum update $rpmliststring|| yum update $rpmshotstring};
       system("yum install $rpmliststring|| yum update $rpmshotstring");
        }
       }
     close (FH);
}

if ( -e "/etc/yum.repos.d/rhel5s.repo" || -e "/etc/yum.repos.d/rhel6s.repo"){
     #print "Please press yes all rpm pacakges except kernel will be upgraded according to secfixdb!\n";
     #if(my $chky=(<STDIN>=~/\byes\b/i)) {
         my $exit=yum_inst();
         if ($exit==0) {
            print  "The APARs had been updated on $str!\n"
            }
          else {
            print "Please check APARS upgrade on $str!\n"
            }
     #   }
     # else {
     #      exit(1);
     #   }
    }
else {
     print color 'bold red';
     print << "EOF";
     ----------------------------------------------------------------------------------------------
     print deploy the yum repository file:rhel[56]s.repo before you execute patch automation tool!
     ----------------------------------------------------------------------------------------------
EOF
      print color 'reset';
    }

