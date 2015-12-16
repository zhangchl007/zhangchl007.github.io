---
layout: post
title: Docker-learning06/Docker Compose installation and deployment
tag: Docker
---

Docker-compose is easy to install and deployment , Please refer to the following steps below.

1. Install Docker Engine version 1.7.1 or greater:
<pre><code>
$curl -L https://github.com/docker/compose/releases/download/1.5.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
$ chmod +x /usr/local/bin/docker-compose
or 
$pip install docker-compose
<pre></code>

2. On this page you build a simple Python web application running on Compose. The application uses the Flask framework and increments a value in Redis.
   While the sample uses Python, the concepts demonstrated here should be understandable even if you’re not familiar with it. 
   
Create a directory for the project:

<pre><code>
mkdir composetest
jimmy@Coreos01:~/composetest$ tree -a
.
├── app.py
├── docker-compose.yml
├── Dockerfile
└── requirements.txt

0 directories, 4 files
jimmy@Coreos01:~/composetest$ cat app.py 
from flask import Flask
from redis import Redis

app = Flask(__name__)
redis = Redis(host='redis', port=6379)

@app.route('/')
def hello():
    redis.incr('hits')
    return 'Hello World! I have been seen %s times.' % redis.get('hits')

if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True)
jimmy@Coreos01:~/composetest$ cat docker-compose.yml 
web:
  build: .
  ports:
   - "5000:5000"
  volumes:
   - .:/code
  links:
   - redis
redis:
  image: redis
jimmy@Coreos01:~/composetest$ cat Dockerfile 
FROM python:2.7
ADD . /code
WORKDIR /code
RUN pip install -r requirements.txt
CMD python app.py
jimmy@Coreos01:~/composetest$ cat requirements.txt 
flask
redis
\
<pre></code>

3. Build the image
<pre><code>
$ docker build -t web .
jimmy@Coreos01:~/composetest$ docker images
REPOSITORY               TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
web                      latest              2e7cb752a718        33 minutes ago      682 MB
composehaproxyweb_weba   latest              04fb79e8f011        2 weeks ago         675.2 MB
composehaproxyweb_webb   latest              04fb79e8f011        2 weeks ago         675.2 MB
composehaproxyweb_webc   latest              04fb79e8f011        2 weeks ago         675.2 MB
<pre></code>

4. Build and run your app with Compose
<pre><code>
 docker-compose  up
Pulling redis (redis:latest)...
latest: Pulling from library/redis
c950d63587be: Pulling fs layer
3ba3ba0cdebd: Pulling fs layer
981344615426: Pulling fs layer
74fe3245cc36: Pulling fs layer
4c1f00c19929: Pulling fs layer
cc3fb584d961: Pulling fs layer
Successfully built 3131aa500109
Creating composetest_web_1
Attaching to composetest_redis_1, composetest_web_1
redis_1 | 1:C 16 Dec 08:14:29.031 # Warning: no config file specified, using the default config. In order to specify a config file use redis-server /path/to/redis.conf
redis_1 |                 _._                                                  
redis_1 |            _.-``__ ''-._                                             
redis_1 |       _.-``    `.  `_.  ''-._           Redis 3.0.5 (00000000/0) 64 bit
<pre></code>
5. check the web app:
<pre><code>
jimmy@Coreos01:~$ docker ps -l
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                    NAMES
e38d83e3247c        composetest_web     "/bin/sh -c 'python a"   9 minutes ago       Up 9 minutes        0.0.0.0:5000->5000/tcp   composetest_web_1

[jimmy@oc3053148748 Desktop]$ curl -L http://192.168.122.241:5000
Hello World! I have been seen 7 times.[jimmy@oc3053148748 Desktop]$ 
<pre></code>

<a href="https://docs.docker.com/compose/gettingstarted/">Docker-compose-getting-started</a>
