---
layout: post
title: Docker-learning04/Managing data in containers
tag: Docker
---

Sometimes, we need to do troubleshooting in container, we can enter it by the commands below.
<pre><code>
$ docker ps -l
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
8e3e5ec72ab4        ubuntu              "/bin/bash"         8 minutes ago       Up 8 minutes                            sick_ardinghelli
$ docker attach 8e3e5ec72ab4

root@8e3e5ec72ab4:/# 

another way : 
$ docker exec -it sick_ardinghelli /bin/bash
root@8e3e5ec72ab4:/# $ ls
$ 

 detatch from the container without stopping it press CTRL+P followed by CTRL+Q.
<pre></code>


<a href="http://dockerpool.com/static/books/docker_practice/container/enter.html">进入容器</a>
