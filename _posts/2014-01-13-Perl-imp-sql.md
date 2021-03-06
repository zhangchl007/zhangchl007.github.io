---
layout: post
title: Import data to MySQL
tag: perl
---
<pre><code>
\#!/usr/bin/perl
# ====================================
# Author:         Ryan Li
# FILE NAME:         nagios_report.pl
# Date:              
# Version:	 1.1
# ====================================
# Todo:
use strict;
use warnings;
use Data::Dumper;
use DBI;
use Spreadsheet::WriteExcel;
use Date::Calc qw(Day_of_Week);
sub debug;
sub pre_chks;
sub err;
sub special_change_sheet_aref;
sub push_site_exetime;
sub gen_xls_sheet_aref;
sub gen_avg_row;
sub map_aref_xls_sheet;
sub gen_sql_statement;
sub read_config_hash;
sub connect_mysql;
sub JDE_sql_seg;
my $debug = 0;
###
# Main
###
pre_chks();
# update here:
my $year = "2012";
my $month = "06"; 
my $config_href = read_config_hash();
my ($xls_href);
# connect to mysql server
my $dbh = connect_mysql();
foreach my $app (keys %{ $config_href }){
print "Process APP: $app ... \n";
my $xls_fn = $app . '_' . $year . '-' .  $month . ".xls";
# generate title, will push site name into it.
my $title_aref = $app =~ /JDE/ ? [ 'date', '' ] : [ 'date' ];
# my $title_aref = [ 'date' ];
my $date_href;
foreach my $site ( keys %{$config_href->{$app}}){
my $application = $config_href->{$app}{$site}[1];
my $sql_statement = gen_sql_statement($application, $site, $year, $month);
my $sql_aref  = $dbh->selectall_arrayref($sql_statement);
# debug $sql_aref;
# push site into title line.
push @$title_aref, $site;
# push exe_time into $sheet_ref->{date}, corresponding to tilte line.
# app -> date ->  [ exe_time, exe_time ]
$date_href = push_site_exetime($sql_aref,$date_href);
# debug $date_href;
}
# Convert to array mapping sheet.
my $sheet_aref = gen_xls_sheet_aref($app,$date_href,$title_aref);
$sheet_aref =  special_change_sheet_aref($app, $sheet_aref);
# debug $sheet_aref;
$xls_href->{$xls_fn}{'response'} = $sheet_aref;
}
# Map href->{xls}{sheet}{aref} to excel files.
# debug $xls_href;
map_aref_xls_sheet($xls_href);
###
# SUBS
###
sub special_change_sheet_aref {
my ($app, $sheet_aref) = @_;
# add country to aref
# JDE here
my $JDE_countries = ['', 'Vietnam', 'Singapore', 'Thailand', 'China', 'Japan'];
push @{$sheet_aref->[0]}, @$JDE_countries if $app =~ /JDE/;
# splice (@$sheet_aref,1,0,$JDE_countries) if $app =~ /JDE/;
# splice ( @{$sheet_aref->[1]},1,0,$JDE_countries) if $app =~ /JDE/;
return $sheet_aref;
}
sub push_site_exetime{
my ($sql_aref,$href) = @_;
foreach my $s_aref (@$sql_aref){
my (undef,$date,$exe_time,$site,$application) = @$s_aref;
push @{ $href->{$date} },$exe_time;
}
return $href;
}
sub gen_xls_sheet_aref{
my ($app,$date_href,$title_aref) = @_;
my $sheet_aref;
push @{$sheet_aref->[0]},'Average of response';
push @$sheet_aref, $title_aref;
my $date_aref;
foreach my $date ( sort keys %$date_href){
if ($app eq 'JDE'){
my $weekday = week_day($date);
push @$date_aref, [ $date, $weekday, @{$date_href->{$date}} ];
}
else{
push @$date_aref, [ $date, @{$date_href->{$date}} ];
}
}
push @$sheet_aref, @$date_aref;
my $calc_total_row = gen_avg_row($sheet_aref);
push @$sheet_aref, $calc_total_row;
return $sheet_aref;
}
sub gen_avg_row {
my ($sheet_aref) = @_;
my $row_num = @$sheet_aref;
my $col_num = @{$sheet_aref->[-1]};
my $avg_row_content = ['Total'];
my $num_to_abc_href = {
1 => 'A',
2 => 'B',
3 => 'C',
4 => 'D',
5 => 'E',
6 => 'F',
7 => 'G',
8 => 'H',
9 => 'I',
10 => 'J',
};
#=SUM(B3:B24)
foreach my $i ( 2 .. $col_num){
my $calc_cell = '=AVERAGE(' .  $num_to_abc_href->{$i} . '3:' . $num_to_abc_href->{$i} . $row_num . ')';
push @$avg_row_content, $calc_cell ;
# debug $avg_row_content;
}
return $avg_row_content;
}
sub map_aref_xls_sheet{
my ($href) = @_;
print "Generating excel ... \n";
# Excel file -> Sheet -> aref
foreach my $xls ( keys %{ $href }){
   # Create a new Excel workbook
    my $workbook = Spreadsheet::WriteExcel->new($xls);
    my $format = $workbook->add_format();
    $format->set_font('Arial');
    $format->set_size(9);
   
    # debug $href;
    foreach my $sheet_name ( keys %{ $href->{$xls} }){
   	# Create a new Excel sheet
    my $sheet = $workbook->add_worksheet($sheet_name);
    for my $row ( 0 .. @{$href->{$xls}{$sheet_name}} -1 ){
err('$href->{$xls}{$sheet_name} should be aref') if ref($href->{$xls}{$sheet_name}) ne 'ARRAY';
    for my $col ( 0 .. @{$href->{$xls}{$sheet_name}[$row]}){
    $sheet->write($row,$col,$href->{$xls}{$sheet_name}[$row][$col],$format);
    }
    }
    }
}
    return;
}
sub pre_chks{
print "checking env before doing anything\n";
# mysql driver chk.
my @drivers = DBI->available_drivers;
# debug \@drivers;
die "Please install mysql driver to continue!" unless grep /mysql/, @drivers;
}
sub debug { print "**", Dumper($_[0]) , "**" if $debug == 1;}
sub err { print "ERROR: $_[0]\n"; exit 3;}
sub gen_sql_statement{
my ($application, $site, $year, $month) = @_;
my $y_m = $year . '-' . $month;
my $time_frame = q{ };
if ($application eq "JDE"){
$time_frame = JDE_sql_seg($site);
}
my $sql_statement=qq|
SELECT  datetime as day,
(date(datetime)) as date, 
(avg(exectime)) as exectime, site, application 
FROM nagioslog 
WHERE 1 
AND application = '$application' 
AND site = '$site'  
AND DATE_FORMAT(datetime, '\%Y-\%m')  = "$y_m"|
. $time_frame
. q| AND state IN ('ok','warning') 
GROUP BY 'date'|;
debug $sql_statement;
return $sql_statement;
}
sub connect_mysql{
my ($application,$site) = @_;
# connnect to mysql db located in lagios server
my $dbserver="xxx.xxxx.xxx.x";
my $dbname="cacti";
my $dbtable="nagioslog";
my $dbuser="cacti";
my $dbpasswd="cacti";
my $dsn = "DBI:mysql:dbname=$dbname;host=$dbserver";
print "Connecting to mysql server $dbserver with id: $dbname \n";
my $dbh = DBI->connect($dsn, $dbuser, $dbpasswd) or die "Database error: $DBI::errstr";
print "connection to mysql server $dbserver have been made successfully\n";
return $dbh;
}
sub week_day{
my $date = shift;
my ($year, $month, $day) = split /-/,$date;
my $wday = Day_of_Week($year, $month, $day);
my $weekday_href = {
1 => 'Monday',
2 => 'Tuesday',
3 => 'Wednesday',
4 => 'Thursday',
5 => 'Friday',
6 => 'Saturday',
7 => 'Sunday',
};
return $weekday_href->{$wday};
}
sub JDE_sql_seg {
my ($site) = @_;
my ($start_hour,$end_hour);
if ($site =~ m{APP_JDE_SG2|APP_JDE_Vietnam|APP_JDE_SWT}){
($start_hour,$end_hour) = qw/09 18/;
}
elsif($site =~ m{APP_JDE_MGT|APP_JDE_NMT}){
($start_hour,$end_hour) = qw/08 20/;
}
elsif($site =~ m{APP_JDE_LCH}){
($start_hour,$end_hour) = qw/08 17/;
}
else{
err("the JDE site name: $site is not recognized as a legal one.\n");
}
my $statement = q|hour(datetime) >= | 
. $start_hour 
. q|AND hour(datetime) < |
. $end_hour
. q| AND DAYOFWEEK(datetime) NOT IN (1,7) AND |;
return $statement;
}
sub read_config_hash {
my $href;
while (<DATA>){
chomp;
my ($app,$application_name,$site,$country,$location) = split /,/;
$href->{$app}{$site} = [$app,$application_name,$site,$country,$location];
}
return $href;
}
__DATA__
JDE,JDE-Singapore,APP_JDE_SG2,Singapore,SG2
JDE,JDE-Thailand,APP_JDE_LCH,Thailand,LCH
</pre></code>  
