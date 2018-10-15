---
layout: post
title: Persistent Storage using Ceph(12.2.8 luminous) RBD with Openshift V3.10
tag: docker
---

long time no update, It's hard to keep doing one thing :(

* I had performed a testing with openshift dynamic ceph provisioning just now :). 

First, we suggest you create a seperated rbd pool for openshift data persistance

- 1. create ceph rbd pool

```
# sudo ceph osd pool create kube 128  # 128 is pg number ,redhat recommendation 100-200 per osd

# sudo ceph auth get-or-create client.kube mon 'allow r, allow command "osd blacklist"' osd 'allow class-read object_prefix rbd_children, allow rwx pool=kube' -o ceph.client.kube.keyring

```
- 2. Set tunables profile to HAMMER for  Ceph 12.2.8 luminous ,otherwise the volume can't be mounted with Openshift pod

```
#sudo ceph osd crush tunables hammer 
 
```
- 3. Get cliet key from ceph cluster

```
sudo ceph auth get-key client.admin | base64
QVFENHhibGJMTE5kSWhBQUY2TVZlZEhtSHBMYnFxSGcya2RvMHc9PQ==

sudo ceph auth get-key client.kube | base64
QVFBT0NNUmJzUkFRR0JBQUJLRnFqQWd5WUZkald1WGU2emliZ2c9PQ==

```
- 4. create the ceph user secret  

```
cat <<EOF > ceph-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: ceph-secret
  namespace: kube-system
data:
  key: QVFENHhibGJMTE5kSWhBQUY2TVZlZEhtSHBMYnFxSGcya2RvMHc9PQ== 
type: kubernetes.io/rbd 
EOF 

cat <<EOF > ceph-user-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: ceph-user-secret
  namespace: ceph-test
data:
  key: QVFBT0NNUmJzUkFRR0JBQUJLRnFqQWd5WUZkald1WGU2emliZ2c9PQ==
type: kubernetes.io/rbd
EOF

# oc create -f ceph-secret.yaml 
# oc create -f ceph-user-secret.yaml

```

- 5. Create ceph storage class 

```
cat <<EOF >ceph-storageclass.yaml
apiVersion: storage.k8s.io/v1beta1
kind: StorageClass
metadata:
  name: dynamic
  annotations:
     storageclass.beta.kubernetes.io/is-default-class: "true"
provisioner: kubernetes.io/rbd
parameters:
  monitors: 192.168.1.11:6789,192.168.1.12:6789,192.168.1.13:6789 
  adminId: admin 
  adminSecretName: ceph-secret 
  adminSecretNamespace: kube-system 
  pool: kube  
  userId: kube  
  userSecretName: ceph-user-secret 
EOF

# oc create -f ceph-storageclass.yaml

```
- 6. Make sure the latest ceph-common package had been installed all openshift nodes and 6789 port is openning for ceph

```
ansible nodes -myum -a 'name=ceph-common state=latest'
node01.zhangchl008.tpddns.cn | SUCCESS => {
    "changed": false, 
    "failed": false, 
    "msg": "", 
    "rc": 0, 
    "results": [
        "All packages providing ceph-common are up to date", 
        ""
    ]
}
node03.zhangchl008.tpddns.cn | SUCCESS => {
    "changed": false, 
    "failed": false, 
    "msg": "", 
    "rc": 0, 
    "results": [
        "All packages providing ceph-common are up to date", 
        ""
    ]
}
infra01.zhangchl008.tpddns.cn | SUCCESS => {
    "changed": false, 
    "failed": false, 
    "msg": "", 
    "rc": 0, 
    "results": [
        "All packages providing ceph-common are up to date", 
        ""
    ]
}
node02.zhangchl008.tpddns.cn | SUCCESS => {
    "changed": false, 
    "failed": false, 
    "msg": "", 
    "rc": 0, 
    "results": [
        "All packages providing ceph-common are up to date", 
        ""
    ]
}
master01.zhangchl008.tpddns.cn | SUCCESS => {
    "changed": false, 
    "failed": false, 
    "msg": "", 
    "rc": 0, 
    "results": [
        "All packages providing ceph-common are up to date", 
        ""
    ]
}
infra02.zhangchl008.tpddns.cn | SUCCESS => {
    "changed": false, 
    "failed": false, 
    "msg": "", 
    "rc": 0, 
    "results": [
        "All packages providing ceph-common are up to date", 
        ""
    ]
}

```

- 7. Create pvc into openshift  

```
cat <<EOF > ceph-pvc.yaml
apiVersion: v1
metadata:
  name: ceph-claim
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 200Mi
  storageClassName: dynamic
EOF

# oc create -f ceph-pvc.yaml

#  oc get pvc
NAME         STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
ceph-claim   Bound     pvc-750bb94d-d055-11e8-bdac-5254001b6444   500Mi      RWO            dynamic        1h

cat <<EOF > ceph-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: ceph-pod1 
spec:
  containers:
  - name: ceph-busybox
    image: busybox 
    command: ["sleep", "60000"]
    volumeMounts:
    - name: ceph-vol1 
      mountPath: /usr/share/busybox 
      readOnly: false
  volumes:
  - name: ceph-vol1
    persistentVolumeClaim:
      claimName: ceph-claim
  securityContext: 
    fsGroup: 7777 
EOF

# oc create -f ceph-pod.yaml

# oc get pods -o wide
NAME        READY     STATUS    RESTARTS   AGE       IP            NODE
ceph-pod1   1/1       Running   0          58m       10.128.2.32   node01.zhangchl008.tpddns.cn

```

at last , If you want dynamic storage class  to every project, you must modify the default project template ,add  ceph-user-secret  when you create openshift project , Please refer to Red hat Doc: <a href=" https://docs.openshift.com/container-platform/3.11/welcome/index.html">OpenShift Container Platform 3.10 Documentation</a> 
