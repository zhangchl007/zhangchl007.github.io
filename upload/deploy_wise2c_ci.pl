#!/usr/bin/perl -w
use strict;
use Term::ANSIColor;

my ($pushimg,$oldimg,@a,@b,%h);
my $reg="harbor01.test01.com";
my $project='library';
########## modify image tag format sub###########
sub labeltag {
    my $str=$_[0];
    $pushimg="$reg/$project/".$str;
    return $pushimg;
    #print "$str\n"
}

########find all images#####################
open (my $fh,"<","docker-compose.yml") or die "coudn't find docker-compose.yml$!\n";
while (<$fh>){
   if ($_=~ /\s+(image):(.*):?/){
       my $img;
       chomp;
       $img=$2;
       if ($img=~/:/) {
          $h{$img}=1
       }
       else {
          $h{"$img:latest"}=1
       }
      }
}
close $fh;

###########download docker images##############
foreach (keys%h) { 
     s/^$|^\s+//g;
     my @args = ("docker pull", "$_");
     if (system("@args") ==0) {
         print  "the image:$_ has been downloaded\n";
         push @a,"$_"
      }
     else {
        push @b, "system @args failed: $?\n"
      }
}
 print @b;
########## modify tag as the private registry#########
foreach (@a) { 
     labeltag($_);
     my @args = ("docker tag","$_", "$pushimg");
     if (system("@args") ==0) {
         print  "the image tag:$_ has been changed as $pushimg\n"
       }
     else {
         print  "system @args failed: $?\n";
      }
}
############push docker images##############
foreach (@a) {

     labeltag($_);
     my @args = ("docker push", "$pushimg");

     if (system("@args") ==0) {
         print  "the image:$_ has been pushed to $reg\n"
       }
     else {
         print  "system @args failed: $?\n";
      }

}

