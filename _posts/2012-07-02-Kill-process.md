---
layout: post
title: Kill the abnormal the process of bsm/fyt 
tag: shell
---
ll the abnormal the process of bsm/fyt with high nice cpu > 80%

<pre><code>
\#!/bin/bash
top_cpu=$(/usr/bin/top -b -n 5  | /bin/awk -F'[:,]' '/^Cpu/{sub("\\%.*","",$4);sum+=$4}END {print sum/4}') #####determine top ni value##############
my_pid=$(/bin/ps -eo pid,args,pcpu|egrep "/busapps/rfyt|rbsm"| awk '{if ($3 >80) print $1}') #####get fyt/bsm process if the pid cpu usage > 80########
if [ $top_cpu > 80 ];then ######kill the process if top ni cpu > 80%

for srv in $my_pid
do
/bin/kill -9 $srv
done
</pre></code>
