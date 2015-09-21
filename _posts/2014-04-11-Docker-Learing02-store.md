---
layout: post
title: Docker-selflearning02/whereis are docker images?
tag: Docker
---

Where are docker images stored on host server? Please refer to code below.
<pre><code>
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
training/webapp     latest              02a8815912ca        4 months ago        348.8 MB
$ sudo find / -name "*02a8815912ca*"
/var/lib/docker/aufs/diff/02a8815912ca800f99b7d912485e8c618260e27c6de8d7a161b356b322d5c121    #new/modified files of the original image in /var/lib/docker/aufs/diff
/var/lib/docker/aufs/mnt/02a8815912ca800f99b7d912485e8c618260e27c6de8d7a161b356b322d5c121     #mount the image with rw under this directory
/var/lib/docker/aufs/layers/02a8815912ca800f99b7d912485e8c618260e27c6de8d7a161b356b322d5c121  #metedat of layer
/var/lib/docker/graph/02a8815912ca800f99b7d912485e8c618260e27c6de8d7a161b356b322d5c121        #image 
$ sudo ls -l /var/lib/docker/graph/02a8815912ca800f99b7d912485e8c618260e27c6de8d7a161b356b322d5c121
total 12
-rw------- 1 root root 1544 Sep 19 08:37 json      #holds metadata about the image 
-rw------- 1 root root    1 Sep 19 08:37 layersize #just a number, indicating the size of the layer
-rw------- 1 root root   82 Sep 19 08:37 tar-data.json.gz
$ sudo cat /var/lib/docker/aufs/layers/02a8815912ca800f99b7d912485e8c618260e27c6de8d7a161b356b322d5c121
b37deb56df95e18dbc67aff2102d1635c8a693f6ab1e7a0bc368195a8a1311e6
b1ae241d644a28b8ef86c7222f5014ac329e54df99a6bfd09fdfe1c88bfbf8c3
cc06fd877d54a69abdb67843acd0ea312721f65b150896ef4161c3e7b964bba3
33e109f2ff13e7873c645ca3619d8c323eb253385f97afc2764337df63930724
99b0d955e85d52084946665b77242de5b41843f8dc3ebd60b2031c82046b8bda
7d0ff9745632509b52c8eb971bb8f01ee1da0037c9e321ec52a2730cf7081500
0a4852b23749d58d62765824bd37f171e54f38ae133ec2bd9cb842e01c7c1775
23f0158a1fbeb574218c76b77fc32aed5b01401733895cbdd263c77651d6d8a2
07f8e8c5e66084bef8f848877857537ffe1c47edd01a93af27e7161672ad0e95
37bea4ee0c816e3a3fa025f36127ef8ef0817b3f8fcd7b49eb7b26064f647bb0
a82efea989f94b1d9fac76e26e37b0bbde11047a3afcaa47064949dfa3b3209b
e9e06b06e14c2f7d8df0251e3bb852c3a10a70639498163d4f180a823c18fdfc
$ sudo cat /var/lib/docker/aufs/mnt/02a8815912ca800f99b7d912485e8c618260e27c6de8d7a161b356b322d5c121
cat: /var/lib/docker/aufs/mnt/02a8815912ca800f99b7d912485e8c618260e27c6de8d7a161b356b322d5c121: Is a directory
$ sudo ls -l /var/lib/docker/aufs/mnt/02a8815912ca800f99b7d912485e8c618260e27c6de8d7a161b356b322d5c121
total 0

</pre></code>

/etc/apt/sources.list.d/docker.list #It's defined docker package source 

<a href="http://blog.thoward37.me/articles/where-are-docker-images-stored/">Where are Docker images stored?</a>
<a href="http://www.infoq.com/cn/articles/docker-source-code-analysis-part11?utm_source=tuicool">Docker源码分析（十一）：镜像存储</a>
