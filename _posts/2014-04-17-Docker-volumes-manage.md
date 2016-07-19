---
layout: post
title: Docker-learning04/Managing data volume in containers
tag: Docker
---

Basic useful feature list:

 * we will learn how to mount a data volume from host server and peform the backup and recovery
 for data volume

And here's some code! :+1:

```jjimmy@Coreos01:/opt$ ls -l /opt/app
total 0
-rw-r--r-- 1 root root 0 Jul  8 09:08 1.txt
jimmy@Coreos01:/opt$ docker run -d -p 8080:5000 -v /opt/app/:/webapp training/webapp python app.py
4600bdc31e82c0043cc55a41c11dd4238c2cd2898b0ac4446c2a46c71dda9558
jimmy@Coreos01:/opt$ docker ps 
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                                      NAMES
4600bdc31e82        training/webapp     "python app.py"          5 seconds ago       Up 3 seconds        0.0.0.0:8080->5000/tcp                     sleepy_williams
9d4aab6a5254        ubuntu/test01       "/usr/sbin/apache2ctl"   22 hours ago        Up 22 hours         0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp   prickly_lumiere
jimmy@Coreos01:/opt$ docker run --rm --volumes-from sleepy_williams -v $(pwd):/backup  training/webapp tar cvf /backup/backup.tar /webapp
tar: Removing leading `/' from member names
/webapp/
/webapp/1.txt
jimmy@Coreos01:/opt$ ls -l
total 16
drwxr-xr-x 2 root root  4096 Jul  8 09:48 app
-rw-r--r-- 1 root root 10240 Jul  8 09:56 backup.tar
jimmy@Coreos01:/opt$ docker run -d  -P  -v /opt/app/:/webapp training/webapp python app.py
8ae7957f2c87af04775b0318b354436e69fbcacc50b46c6ed19453443cf96374
jimmy@Coreos01:/opt$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED              STATUS              PORTS                                      NAMES
8ae7957f2c87        training/webapp     "python app.py"          4 seconds ago        Up 3 seconds        0.0.0.0:32771->5000/tcp                    elegant_carson
4600bdc31e82        training/webapp     "python app.py"          About a minute ago   Up About a minute   0.0.0.0:8080->5000/tcp                     sleepy_williams
9d4aab6a5254        ubuntu/test01       "/usr/sbin/apache2ctl"   22 hours ago         Up 22 hours         0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp   prickly_lumiere
jimmy@Coreos01:/opt$ docker exec elegant_carson rm /webapp/1.txt
jimmy@Coreos01:/opt$ docker exec elegant_carson ls -lR /webapp
/webapp:
total 0

jimmy@Coreos01:/opt$ docker run --rm --volumes-from elegant_carson -v $(pwd):/backup  training/webapp bash -c "cd /webapp && tar xvf /backup/backup.tar --strip 1" 
webapp/1.txt
jimmy@Coreos01:/opt$ docker exec elegant_carson ls -lR /webapp
/webapp:
total 0
-rw-r--r-- 1 root root 0 Jul  8 13:08 1.txt

```

This is [on GitHub](https://github.com/jbt/markdown-editor) so let me know if I've b0rked it somewhere.


Props to Mr. Doob and his [code editor](http://mrdoob.com/projects/code-editor/), from which
the inspiration to this, and some handy implementation hints, came.

