---
layout: post
title: The script will archive the log files before today according to mtime of files 
tag: shell
---

<pre><code>
\#!/bin/sh
\### The script will archive the log files before today  according to mtime of files###
\###except the files are using under the specifed directory###
AR_FILE="/opt/httpd-2.2.8/archive/tyreplus\`date --date='1 days ago' +%Y%m\`.tar"
FILES_DIR="/opt/httpd-2.2.8/logs/*"
TODAY=\`date +%Y-%m-%d\`
main_tar(){
        for srv in $FILES_DIR
        do
                MTIME=\`stat $srv | awk '{if ($1~/Modify/) print $2}'\`
                if [ "$MTIME" != "$TODAY" -a -f "$srv" ]; then

                         tar -rvf $AR_FILE $srv --remove-files
                fi
        done
}

if [ -f "$AR_FILE" ]; then
        main_tar

       tar -czvf $AR_FILE.gz $AR_FILE --remove-files
else
        touch $AR_FILE
        main_tar
      tar -czvf $AR_FILE.gz $AR_FILE --remove-files
fi
</pre></code>
<a href="http://pan.baidu.com/s/1i3quzmH">It's a internal traning material</a>
