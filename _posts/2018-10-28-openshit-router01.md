---
layout: post
title: Openshift Router Sharding For Different Env and HA Solution
tag: Openshift
---


*  The bigger Openshift cluster,In case , Customer want to seperate the traffic between critical and generate bussiness, The router sharding would be a good way, Openshift routers can run on the specifed nodes to support the app from the different env by namespace label
 

+ 1  solution Design 
    1. Identify the bussiness app (prioritizing)
    2. Infra Environment(Prod and Dev),Infra node 
    4. Router location(distributed the different nodes or multi router with different ports in the infra nodes)
    5. Router high availabilty(VIP:192.168.0.16 for prod and VIP:192.168.0.17 for dev)  
    6. Firewall rule and the openning port
    7. Deploy and testing 
  
*  It's a router sharding testing lab

  ![router-lab](https://raw.githubusercontent.com/zhangchl007/zhangchl007.github.io/master/_image/sharding.png)
 
+ 2 select two infra-nodes for prod and dev env and label them as below.

```
$ oc label node infra01.zhangchl008.example.com ha-router=true
$ oc label node infra02.zhangchl008.example.com ha-router=true

```
+ 3 check the prod router 

```
$ oc get pods
NAME                       READY     STATUS    RESTARTS   AGE
docker-registry-1-v4x2z    1/1       Running   2          10h
registry-console-1-k2gnv   1/1       Running   2          10h
router-2-5nffn             1/1       Running   3          6h
router-2-f6s9l             1/1       Running   2          6h

$ oc set env dc/router NAMESPACE_LABELS="router=prod"

```
+ 4 Delopy the router for dev env in the same infra nodes,the ports will be changed as 10080/10443/11936 ,If an administrator wants to restrict all routes to a specific routing subdomain, they can pass the --force-subdomain option to the oc adm router command:$ oc adm router --force-subdomain='${name}-${namespace}.apps.example.com'. Here we don't want specific routing subdomain.

```
$ oc adm router router-dev --replicas=0 --selector='node-role.kubernetes.io/infra=true' \
  --service-account=router --ports='10080:10080,10443:10443' --images=registry.zhangchl008.example.com/openshift3/ose-haproxy-router:v3.11.16

$ oc env dc/router NAMESPACE_LABELS="router=dev"

$ oc set env dc/router-dev ROUTER_SERVICE_HTTP_PORT=10080  \
  ROUTER_SERVICE_HTTPS_PORT=10443 \
  STATS_PORT=11936 \
  ROUTER_LISTEN_ADDR=0.0.0.0:11936

$ oc edit dc/router-dev

container port: 11936

$ oc set env dc/router-dev NAMESPACE_LABELS="router=dev"

$ oc scale dc/router-dev --replicas=1

$ oc get pods 
oc get pods
NAME                       READY     STATUS    RESTARTS   AGE
docker-registry-1-v4x2z    1/1       Running   2          10h
registry-console-1-k2gnv   1/1       Running   2          10h
router-2-5nffn             1/1       Running   3          6h
router-2-f6s9l             1/1       Running   2          6h
router-dev-5-bqhmf         1/1       Running   2          6h
router-dev-5-nwvsz         1/1       Running   2          6h

```
+ 5  Deploy Router HA for prod and dev 

```
$ oc adm policy add-scc-to-user privileged -z ipfailover

* for prod

$ oc adm ipfailover router-ha \
    --replicas=2 --watch-port=80 \
    --selector="ha-router=true" \
    --virtual-ips="192.168.0.16" \
    --service-account=ipfailover --create
$ oc get pods
NAME                       READY     STATUS    RESTARTS   AGE
docker-registry-1-v4x2z    1/1       Running   2          10h
registry-console-1-k2gnv   1/1       Running   2          10h
router-2-5nffn             1/1       Running   3          6h
router-2-f6s9l             1/1       Running   2          6h
router-dev-5-bqhmf         1/1       Running   2          6h
router-dev-5-nwvsz         1/1       Running   2          6h
router-ha-2-59hwb          1/1       Running   3          8h
router-ha-2-cjhkf          1/1       Running   3          8h

* for dev 

$ oc adm ipfailover router-ha-dev \
    --replicas=2 --watch-port=10080 \
    --selector="ha-router=true" \
    --virtual-ips="192.168.0.17" \
	--images=registry.zhangchl008.example.com/openshift3/ose-keepalived-ipfailover:v3.11.16 \
    --service-account=ipfailover --create

$ oc edit dc/router-ha-dev

change 63000 as the port: 64000

$ oc get pods
NAME                       READY     STATUS    RESTARTS   AGE
docker-registry-1-v4x2z    1/1       Running   2          10h
registry-console-1-k2gnv   1/1       Running   2          10h
router-2-5nffn             1/1       Running   3          6h
router-2-f6s9l             1/1       Running   2          6h
router-dev-5-bqhmf         1/1       Running   2          6h
router-dev-5-nwvsz         1/1       Running   2          6h
router-ha-2-59hwb          1/1       Running   3          8h
router-ha-2-cjhkf          1/1       Running   3          8h
router-ha-dev-2-g2bvc      1/1       Running   3          6h
router-ha-dev-2-szksf      1/1       Running   2          6h

```

+ 6  Add the firewall rule in two infra nodes and make it change with the config file "/etc/sysconfig/iptables"

```
$ iptables -A OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 10443 -j ACCEPT
$ iptables -A OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 10080 -j ACCEPT

```
+ 7 verify the vip for prod and dev environment

```
$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 52:54:00:95:54:eb brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.34/24 brd 192.168.0.255 scope global noprefixroute eth0
       valid_lft forever preferred_lft forever
    inet 192.168.0.17/32 scope global eth0
       valid_lft forever preferred_lft forever
    inet 192.168.0.16/32 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::d05:453a:b96c:8279/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
```

+ 8 create the prod and dev projects 

```
$ oc new-project app-prod
$ oc label namespace app-prod  "router=prod"
$ oc new-project app-dev
$ oc label namespace app-dev  "router=dev"

#add project label for openshift infra projects
for i in `oc get projects --show-labels|awk '{if($1~/openshift/ || $1~/kube/ || $1 ~/management/) print $1}'`;do oc label namespace $i "router=prod" ;done

```
+ 9 Deploy app in prod and dev env .If an administrator wants to restrict all routes to a specific routing subdomain, they can pass the --force-subdomain option to the oc adm router command:

```
$ oc new-app --name prod-nodejs https://github.com/zhangchl007/nodejs-demo --hostname=prod-nodejs-app-prod.apps.zhangchl008.example.com

$ oc new-app --name dev-nodejs https://github.com/zhangchl007/nodejs-demo --hostname=dev-nodejs-app-dev.apps.zhangchl008.example.com

```
+ 10 Verify the app route for prod and dev 

* http://dev-nodejs-app-dev.apps.zhangchl008.example.com:10080

  ![router-dev](https://raw.githubusercontent.com/zhangchl007/zhangchl007.github.io/master/_image/router-dev.png)

* http://prod-nodejs-app-prod.apps.zhangchl008.example.com
  
  ![router-prod](https://raw.githubusercontent.com/zhangchl007/zhangchl007.github.io/master/_image/router-prod.png)
  
* Reference:
 <a href="https://docs.openshift.com/container-platform/3.9/install_config/router/default_haproxy_router.html">Openshift Router</a>
 
 <a href="https://containers.ninja/openshift/loadbalancing/haproxy/sharding/2018/04/11/openshift-prod-dev-router-sharding.html">Openshift Router Sharding for Production and Development traffic</a>

