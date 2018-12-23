---
layout: post
title: Thanos-query testing for the different openshift-clusters
tag: Openshift
---

# It's very interesting, we had deployed Prometheus + Thanos in one Openshift Cluster this week, I will perform a testing crossing over the different Openshift cluster next week, So I just performed a testing with Native Docker Container ,which definitely works, take a note below :)

+ 1 Setup a Standlone Prometheus with Docker 

```

Creating configuration file

 # cat <<EOF > /etc/prometheus/prometheus.yml 
global:
  scrape_interval:     15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

  # Attach these labels to any time series or alerts when communicating with
  # external systems (federation, remote storage, Alertmanager).
  external_labels:
      monitor: 'uat'

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first.rules"
  # - "second.rules"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  - job_name: 'prometheus'
    scrape_interval: 5s
    static_configs:
      - targets: ['127.0.0.1:9090']
  - job_name: 'node'
    scrape_interval: 8s
    static_configs:
      - targets: ['127.0.0.1:9100']
  - job_name: 'cadvisor'
    static_configs:
      - targets: ['127.0.0.1:8080']
EOF

# docker run -u root -d  --name=prometheus-server --privileged=true \
   -v /etc/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml \
   -v /data:/prometheus \
   --net="host" \
   prom/prometheus:v2.4.3 \
   --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/prometheus
```

+ 2 Docker RUN Prometheus Node Exporter

```

# docker run -d \
  --net="host" \
  --pid="host" \
  --name="unify01" \
  -v "/:/host:ro,rslave" \
  quay.io/prometheus/node-exporter \
  --path.rootfs /host

安装 cadvisor

# docker run \
  --volume=/cgroup:/cgroup:ro \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:ro \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --volume=/dev/disk/:/dev/disk:ro \
  --publish=8080:8080 \
  --detach=true \
  --name=cadvisor \
  google/cadvisor:latest

```

+ 3 Deploy the S3/Ceph configuration file for Thanos Sidecar/Store

```

# cat <<EOF >/thanos-config-store/ceph.yml 
type: S3
config:
    endpoint: 192.168.0.24
    bucket: thanos1
    access_key: UNT4Y3I1CXFAVZYZN5RE
    secret_key: Cm0PuqK8HY6dOgV9yCAI2WsaOZntJBC7Zk7Xfc8M
    insecure: true
    signature_version2: false
    encrypt_sse: false  
EOF

# cat <<EOF >/etc/prometheus/s3.yml 
type: S3
config:
    endpoint: 192.168.0.24
    bucket: thanos1
    access_key: UNT4Y3I1CXFAVZYZN5RE
    secret_key: Cm0PuqK8HY6dOgV9yCAI2WsaOZntJBC7Zk7Xfc8M
    insecure: true
    signature_version2: false
    encrypt_sse: false
EOF

```
+ 4 Setup Thanos sidecar and store with Docker

```
Thanos sidecar

# docker run -d -p 11900:10900 \
-p 11901:10901 \
-p 11902:10902 \
-v /etc/prometheus/s3.yml:/etc/prometheus/s3.yml \
--privileged=true \
--name=thanos-sidecar \
improbable/thanos:0.2.0 \
sidecar \
--log.level=debug \
--tsdb.path=/prometheus \
--cluster.address=0.0.0.0:10900 \
--grpc-address=0.0.0.0:10901 \
--http-address=0.0.0.0:10902 \
--prometheus.url=http://localhost:9090 \
--reloader.config-envsubst-file=/etc/prometheus/prometheus.yml \
--objstore.config-file=/etc/prometheus/s3.yml

Thanos store

# docker run -d -p 10900:10900 \
-p 10901:10901 \
-p 10902:10902 \
-v /thanos-config-store/ceph.yml:/thanos-config-store/ceph.yml \
--privileged=true \
--name=thanos-store \
improbable/thanos:0.2.0 \
store \
--log.level=debug \
--objstore.config-file=/thanos-config-store/ceph.yml \
--cluster.address=0.0.0.0:10900 \
--cluster.advertise-address=0.0.0.0:10900 \
--grpc-address=0.0.0.0:10901 \
--http-address=0.0.0.0:10902 \
--data-dir=/thanos-store 

```
+ 5 the exciting Moment , Chagne the deployment of thanos query in Openshift Cluster

```
# oc edit deployment thanos-query
  - args:
  - query
  - --log.level=debug        
  - --cluster.address=0.0.0.0:10900
  - --grpc-address=0.0.0.0:10901
  - --http-address=0.0.0.0:10902
  - --store=thanos-store:10901
  - --store=thanos-sidecar:10901
  - --store=192.168.0.71:10901
# oc delete pod thanos-query-757c69fb46-482d8
# oc logs -f thanos-query-757c69fb46-vln2d -c thanos-query

```
```diff
level=info ts=2018-12-22T04:01:50.220277408Z caller=flags.go:90 msg="StoreAPI address that will be propagated through gossip" address=10.130.2.108:10901
level=info ts=2018-12-22T04:01:50.238563658Z caller=flags.go:105 msg="QueryAPI address that will be propagated through gossip" address=10.130.2.108:10902
level=debug ts=2018-12-22T04:01:50.247477196Z caller=cluster.go:158 component=cluster msg="resolved peers to following addresses" peers=
level=info ts=2018-12-22T04:01:50.249844199Z caller=main.go:256 component=query msg="disabled TLS, key and cert must be set to enable"
level=info ts=2018-12-22T04:01:50.249889203Z caller=query.go:436 msg="starting query node"
level=debug ts=2018-12-22T04:01:50.260493012Z caller=delegate.go:82 component=cluster received=NotifyJoin node=01CZA17357NM6B2RPKFZGRJ2D5 addr=10.130.2.108:10900
level=debug ts=2018-12-22T04:01:50.260563261Z caller=cluster.go:233 component=cluster msg="joined cluster" peerType=query knownPeers=
level=info ts=2018-12-22T04:01:50.260844122Z caller=query.go:405 msg="Listening for query and metrics" address=0.0.0.0:10902
level=info ts=2018-12-22T04:01:50.260911116Z caller=query.go:428 component=query msg="Listening for StoreAPI gRPC" address=0.0.0.0:10901
level=info ts=2018-12-22T04:01:55.273696884Z caller=storeset.go:227 component=storeset msg="adding new store to query storeset" address=thanos-sidecar:10901
level=info ts=2018-12-22T04:01:55.273731284Z caller=storeset.go:227 component=storeset msg="adding new store to query storeset" address=thanos-store:10901
level=info ts=2018-12-22T04:01:55.273742821Z caller=storeset.go:227 component=storeset msg="adding 
+ <font color=#00ff size=5>new store to query storeset" address=192.168.0.71:10901</font>
level=debug ts=2018-12-22T04:02:50.261035578Z caller=cluster.go:307 component=cluster msg="refresh cluster done" peers= resolvedPeers=

```
