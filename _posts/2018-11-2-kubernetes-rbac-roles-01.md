---
layout: post
title: Kubernetes RBAC Practice -1
tag: Kubernetes
---


*  The RBAC API declares four top-level types which will be covered in this section. Users can interact with these resources as they would with any other API resource (via kubectl, API calls, etc.). For instance, kubectl create -f (resource).yml can be used with any of these examples, though readers who wish to follow along should review the section on bootstrapping first.


+ 1  Core Concepts
    1. Role and ClusterRole
    2. RoleBinding and ClusterRoleBinding
    3. Referring to Resources, Referring to Subjects and Aggregated ClusterRoles
    4. Default Roles and Role Bindings 
    5. Privilege Escalation Prevention and Bootstrapping
    6. user credentials and context creation
    7. test user permission verification
  
*  Role and ClusterRole
   
In the RBAC API, a set of permissions. Permissions are purely additive (there are no “deny” rules). 
    
A Role can only be used to grant access to resources within a single namespace

```    
# cat test-role.yaml 
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: edit-role
  namespace: test
rules:
- apiGroups: ["", "extensions", "apps"]
  resources: ["deployments", "replicasets", "pods"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"] # 也可以使用['*']

# oc get role -n test
NAME        AGE
edit-role   1d

```

A ClusterRole can be used to grant the same permissions as a Role, but because they are cluster-scoped, they can also be used to grant access to:

    * cluster-scoped resources (like nodes)
    * non-resource endpoints (like “/healthz”)
    * namespaced resources (like pods) across all namespaces (needed to run kubectl get pods --all-namespaces, for example)

```
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  # "namespace" omitted since ClusterRoles are not namespaced
  name: secret-reader
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "watch", "list"] 
   
```    

+ 2 RoleBinding and ClusterRoleBinding

A role binding grants the permissions defined in a role to a user or set of users. It holds a list of subjects (users, groups, or service accounts)

```
cat test-rolebinding.yaml 
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: edit-rolebinding
  namespace: test
subjects:
- kind: User
  name: test
  apiGroup: ""
roleRef:
  kind: Role
  name: edit-role
  apiGroup: ""

```

A RoleBinding may also reference a ClusterRole to grant the permissions to namespaced resources defined in the ClusterRole within the RoleBinding’s namespace

```
 This role binding allows "dave" to read secrets in the "development" namespace.
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: read-secrets
  namespace: development # This only grants permissions within the "development" namespace.
subjects:
- kind: User
  name: dave # Name is case sensitive
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: secret-reader
  apiGroup: rbac.authorization.k8s.io

```

A ClusterRoleBinding may be used to grant permission at the cluster level and in all namespaces. The following ClusterRoleBinding allows any user in the group “manager” to read secrets in any namespace

```
# This cluster role binding allows anyone in the "manager" group to read secrets in any namespace.
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: read-secrets-global
subjects:
- kind: Group
  name: manager # Name is case sensitive
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: secret-reader
  apiGroup: rbac.authorization.k8s.io

```

+ 3 Referring to Resources, Referring to Subjects and Aggregated ClusterRoles

Resources can also be referred to by name for certain requests through the resourceNames,for example:To restrict a subject to only “get” and “update” asingle configmap: my-configmap

```
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: default
  name: configmap-updater
rules:
- apiGroups: [""]
  resources: ["configmaps"]
  resourceNames: ["my-configmap"]
  verbs: ["update", "get"]

```

Referring to Subjects: RoleBinding or ClusterRoleBinding binds a role to subjects. Subjects can be groups, users or service accounts.

```
For a user named “alice@example.com”:

subjects:
- kind: User
  name: "alice@example.com"
  apiGroup: rbac.authorization.k8s.io
For a group named “frontend-admins”:

subjects:
- kind: Group
  name: "frontend-admins"
  apiGroup: rbac.authorization.k8s.io
For the default service account in the kube-system namespace:

subjects:
- kind: ServiceAccount
  name: default
  namespace: kube-system
For all service accounts in the “qa” namespace:

subjects:
- kind: Group
  name: system:serviceaccounts:qa
  apiGroup: rbac.authorization.k8s.io
For all service accounts everywhere:

subjects:
- kind: Group
  name: system:serviceaccounts
  apiGroup: rbac.authorization.k8s.io
For all authenticated users (version 1.5+):

subjects:
- kind: Group
  name: system:authenticated
  apiGroup: rbac.authorization.k8s.io
For all unauthenticated users (version 1.5+):

subjects:
- kind: Group
  name: system:unauthenticated
  apiGroup: rbac.authorization.k8s.io
For all users (version 1.5+):

subjects:
- kind: Group
  name: system:authenticated
  apiGroup: rbac.authorization.k8s.io
- kind: Group
  name: system:unauthenticated
  apiGroup: rbac.authorization.k8s.io

```

Aggregated ClusterRoles: a sample word by label, The clusterrole：monitoring-endpoints will be added to "monitoring" clusterrole

```
# monitoring-endpoints clusterrole

kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: monitoring-endpoints
  labels:
    rbac.example.com/aggregate-to-monitoring: "true"
# These rules will be added to the "monitoring" role.
rules:
- apiGroups: [""]
  resources: ["services", "endpoints", "pods"]
  verbs: ["get", "list", "watch"]


# "monitoring" clusterrole

kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: monitoring
aggregationRule:
  clusterRoleSelectors:
  - matchLabels:
      rbac.example.com/aggregate-to-monitoring: "true"
rules: [] # Rules are automatically filled in by the controller manager.

````

+ 4 Default Roles and Role Bindings

```
# oc get clusterroles
NAME                                                                   AGE
admin                                                                  83d
cluster-admin                                                          83d
edit                                                                   83d
flannel                                                                83d
system:aggregate-to-admin                                              83d
system:aggregate-to-edit                                               83d
system:aggregate-to-view                                               83d
system:auth-delegator                                                  83d
system:aws-cloud-provider                                              83d
system:basic-user                                                      83d
system:certificates.k8s.io:certificatesigningrequests:nodeclient       83d
system:certificates.k8s.io:certificatesigningrequests:selfnodeclient   83d
system:controller:attachdetach-controller                              83d
system:controller:certificate-controller                               83d
system:controller:clusterrole-aggregation-controller                   83d
system:controller:cronjob-controller                                   83d
system:controller:daemon-set-controller                                83d
system:controller:deployment-controller                                83d
system:controller:disruption-controller                                83d
system:controller:endpoint-controller                                  83d
system:controller:expand-controller                                    83d
system:controller:generic-garbage-collector                            83d
system:controller:horizontal-pod-autoscaler                            83d
system:controller:job-controller                                       83d
system:controller:namespace-controller                                 83d
system:controller:node-controller                                      83d
system:controller:persistent-volume-binder                             83d
system:controller:pod-garbage-collector                                83d
system:controller:pv-protection-controller                             83d
system:controller:pvc-protection-controller                            83d
system:controller:replicaset-controller                                83d
system:controller:replication-controller                               83d
system:controller:resourcequota-controller                             83d
system:controller:route-controller                                     83d
system:controller:service-account-controller                           83d
system:controller:service-controller                                   83d
system:controller:statefulset-controller                               83d
system:controller:ttl-controller                                       83d
system:coredns                                                         83d
system:csi-external-attacher                                           83d
system:csi-external-provisioner                                        83d
system:discovery                                                       83d
system:heapster                                                        83d
system:kube-aggregator                                                 83d
system:kube-controller-manager                                         83d
system:kube-dns                                                        83d
system:kube-scheduler                                                  83d
system:kubelet-api-admin                                               83d
system:node                                                            83d
system:node-bootstrapper                                               83d
system:node-problem-detector                                           83d
system:node-proxier                                                    83d
system:persistent-volume-provisioner                                   83d
system:volume-scheduler                                                83d
view                                                    

```

User-facing Roles

The roles intended to be granted within particular namespaces using RoleBindings (admin, edit, view)

The super-user roles (cluster-admin), roles intended to be granted cluster-wide using ClusterRoleBindings (cluster-status



+ 5  Privilege Escalation Prevention and Bootstrapping

```



```

+ 6   user credentials and context creation

```
# openssl genrsa -out test.key 2048

# openssl req -new -key test.key -out test.csr -subj "/CN=test/O=users"

# openssl x509 -req -in test.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out test.crt -days 500

Signature ok
subject=/CN=test/O=users
Getting CA Private Key

# kubectl config set-credentials test --client-certificate=test.crt  --client-key=test.key --embed-certs=true --kubeconfig=test.conf

# kubectl config set-context test-context --cluster=kubernetes --namespace=test --user=test --kubeconfig=test.conf

# kubectl create namespace test

# kubectl create -f test-role.yaml

# kubectl create -f test-rolebinding.yaml

```

+ 7 test user permission verification

```
# kubectl auth can-i create deployments --namespace=test --as=test
yes
# kubectl auth can-i create deployments --namespace=kube-system --as=test
no

# cat  /root/.kube/test.conf 
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUN5RENDQWJDZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRFNE1EZ3hPREE0TXpZeU1Gb1hEVEk0TURneE5UQTRNell5TUZvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTWtXCnlpbnVMa1BtaW5GYjNvWHJaNmNzbVM3WW9LeXFlcmcySENQbmdKaHpDYUx5YmVENGRQaTFodG11VnN0RVZZbXAKdTRLQWJwdDZGR2FLMjJSY01XUFNSQ01vNHFBT1lnYWZINTBUaCtqR3M5Ykw2ekIyWmV5SXdFa28xSmU0UVZabgowT0djaTNWZ3RGNzZSOVVuZ3d4eXB6UVpzQVE0ZDg1SUcrNHZ2MURXUnR2dndvckRueldNeEc0cjRUYURTODRuCi9XZXdzTk04NURVdG9jL3FJQlRPOVVtNlZKU2xSclhEdzJKMlhOVnN2NDlSQ0lUdTZIc3l5aENPbVVjMlJzT0MKUDF0QmZCUzVCQmg3Y2FwT2pkaW1TWUoyczU4bWNsS0dxNy84NFNSdzh5ZmlnUHByMkVyaW5lU2ZzSjNSTEZaMwo5OGorRXVQYU9abG5TZTd6M0JzQ0F3RUFBYU1qTUNFd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0RRWUpLb1pJaHZjTkFRRUxCUUFEZ2dFQkFDVUdzSGFab0lIdjN3VXk2emI0NHVBaCtPRTYKU3BUeXZrbU94K2IrYU5KVC9xRWN6bnNlN2I5bEM1L2hVZ2F5VnFNWk1QMEhvVU8zbWpRbi9xV2I0aDl6eDY2Mwpsd3RQR0EyN09FckhFQWREcm5adW9XT1doM0x1KzB0RmdsZzEvcFg4R3EzeHEwWkxYdVBqQURCSC9tWGZYY3dOCkxOTzArdjRRbHRTZ3ByZmlvWmpUNkxuZ0tDbzhweE9MMkxIdHVtbndoWG5IZGprVDk5MXJkaEtwcGZvS1ZQMHcKb1gyNWdVdkZQb2Q4Z2o0VVNBdkJyNTB2cHpWQVB4dk40QjIxbUMrTmxxYnhoMEhsVDVXcEJYYmlpQVZjOUZ2VwpoNFgrVkp0WHgzejAvVWZOT1BuVjI1M2lvSHFCVCsvWXh0V3pCeUR6cUhkcTdialdoa29uV1gxWnlJQT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
    server: https://192.168.122.21:6443
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    namespace: test
    user: test
  name: test-context
current-context: test-context
kind: Config
preferences: {}
users:
- name: test
  user:
    client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNzRENDQVpnQ0NRQ1VYTk5tNzlPWVlUQU5CZ2txaGtpRzl3MEJBUXNGQURBVk1STXdFUVlEVlFRREV3cHIKZFdKbGNtNWxkR1Z6TUI0WERURTRNVEV3T0RBNE16a3hNRm9YRFRJd01ETXlNakE0TXpreE1Gb3dIekVOTUFzRwpBMVVFQXd3RWRHVnpkREVPTUF3R0ExVUVDZ3dGZFhObGNuTXdnZ0VpTUEwR0NTcUdTSWIzRFFFQkFRVUFBNElCCkR3QXdnZ0VLQW9JQkFRQ3J6bzg5RHJISnhKSklISUZ3cWxMaEZ4TEhhS0lmR1p0WDB1MlIxS1I3akxoK0E3Q2EKUGZRUHdCSHdpRUFTNnRpaXEvMENhQXNtR2xuTWRQRnVnVzgyNXEyTTIxeFdORUZaRThRUmRUOXp3WVRJWTlvVQpuZWJ1aHBaS3hMNkpnRithdlg1L3Z6MkdhUCtWY1FyRzgwb2MwSWRBcjMrajJwblJ2MXJlcDRERklHeXVYY2pFCnUzWDU0K1ZDMmhiVU9iNjBneW4zOE91bWNKWUNSdFI5TzU4anl1ZmVHY2NiREZnM3k5RGt2b3MvemUvdFc3elYKN0tOR2ZLQktQQTNxQlNvdFB3Q0lFcE4rekNWaEV3aFJXck0yclhnY2ZKa1RpN1JRMDRKQ1dHLzZ4MmNySEhPZgpYbkUwWWU2MFlSU0FUU21Lck1HeU9iRXVFZklzRUVmb0hKUDNBZ01CQUFFd0RRWUpLb1pJaHZjTkFRRUxCUUFECmdnRUJBRzlrY2t1RTI0MUl0UVErZ0p0V0pJTnEyQS96eWV1MEUzQzY5ZWpFbGZDMkdMaWdmd004ZVVpc2RMQUsKUWZ3NGhUVVRGNG5WOWhOMlJhRzVsSDB1UjhhMWxweHZnYmZCOUN2eGx1YkkrenMvaGtVVmZWdmxmSXNhWjZLUAoxMDcwYjNSQ1F0Z0NsUW9HZ3hTN3FVMklISTdEdkM3YW04U0tHcVJJL2ZrODB3STZ6dXhXOXQ0WUZSd0ZRUmtSCjdxdUpiemo1cDBxdFNMVW9WcVlBdjNuZ1BFYlFqSmxxWCtDZS8zQm1SYVAyWVFReGN4OGRUM2s4bE5TZUVtcTcKL2hxV0J6VSs2QlRJMlk2TzNtUkhoNjVGRWZqd2VDNHV4dytxTmU4b2dMcWc1UFdJamNXa3ZURmhHVjVMMkQ0agprenJva2NZKytLVEtxQU83SGkxTXRXRXZpSGs9Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    client-key-data: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcEFJQkFBS0NBUUVBcTg2UFBRNnh5Y1NTU0J5QmNLcFM0UmNTeDJpaUh4bWJWOUx0a2RTa2U0eTRmZ093Cm1qMzBEOEFSOEloQUV1cllvcXY5QW1nTEpocFp6SFR4Ym9Gdk51YXRqTnRjVmpSQldSUEVFWFUvYzhHRXlHUGEKRkozbTdvYVdTc1MraVlCZm1yMStmNzg5aG1qL2xYRUt4dk5LSE5DSFFLOS9vOXFaMGI5YTNxZUF4U0JzcmwzSQp4THQxK2VQbFF0b1cxRG0rdElNcDkvRHJwbkNXQWtiVWZUdWZJOHJuM2huSEd3eFlOOHZRNUw2TFA4M3Y3VnU4CjFleWpSbnlnU2p3TjZnVXFMVDhBaUJLVGZzd2xZUk1JVVZxek5xMTRISHlaRTR1MFVOT0NRbGh2K3Nkbkt4eHoKbjE1eE5HSHV0R0VVZ0UwcGlxekJzam14TGhIeUxCQkg2QnlUOXdJREFRQUJBb0lCQVFDZThzTmlZYTNxVllwZwpYTDhFVlEvSVgyaG9SRTE1S0YrbnFPVlIvY0VPN09uaTY5Yi9YRUhvTUhKb2JpV1pXdHlCNDB4NFpYbXJEc1gxCmVsdkRPTXlEcG5iNTBoaGpTSVVNdkZTeE1pQTZIOWVRN1pCZGNwaXNKS2YzRkg2VEI4bHJoOVQ0cXgxb3RNdUEKbnN5eHMzUGxwS2I5R1dDbFh5RGdCSUUxYlJLZFRCVkszTm5MTkw0ZE5yRWZnTmFneDA5SzVNMzZDaGtKeEs3TwpvbDl0MjBQZm42YWNpU2lJY1dsOVhLUTRFMUxOTUlqRTZ3OG1iYzVicUdnYWpTQVhnMVZVUXRJbndMcTZ5Z1haClNyVExpaXlLUTdQM3pWdS9Pays1ZFRIVHZxS0ZZNndRWktFV0hiWGJrdEVqeFRjKzhRK3Y4YzYyeEE1R0V1QlAKWDQwNEhNMkJBb0dCQU9DS1F0WGtiUzJlekZLWlBiRG82VWVSaC93SllycU1rcm1LWnVNUU91ejkrMWJBR00wUwpNN1lYQnlrMm92MjZKNm5HYi9udWFMTWdVL2QyK3EyR3JadUtGTm9nbmhPWUI1anFYS3ljVExqV0l5cTE4d3pRCjFFYTM4ekVvSk1kTTh6R2dZOVZyNDlXVEg4Q3JwamsxMTMxMDFVdk9MTVFHd29VRHRuQk02UWl2QW9HQkFNUGcKNFFBbWlSVngzeU04OExiNmZUaG5CbzhNRTZKRjlMbm1XeXYyR0NuNmJQR2l3Q0xkWm14Yi9QU2EvZEVCNXl0WAo2bjZRN0RCcjZpZTNCMi9XcllqTHFjMVNaa1RQUmJZWThZdG9saXN6WU82c2F0em02dGVLbWZHK2o3WEVpUHI4Ci9OZWxKVHc4bVQwSmpDbk9YQk1hUXB2SmJBNXpBRG1SMzJFVkQrczVBb0dBRG8zbnR5V1BUaDIwOE1XdUVnR0cKM1hTNWM4VEgrWCtUSXlPdGQ1cGR0MjdmRThodjB4c1M3d0tmSERUR2E5dmRKa3dPaGd6R0RKWlQydjZEVVN3aApwS3RXbnF6dWtpYVFsNERaY1BiUW9rcC9EUTJ1SzI1OTAvZW9jODgrVXd6UjFxMm15dmFyVmZTcllqbStGSWRBCjZJamlLbis2dHhvWkViWWo1VE9YQjFFQ2dZQm1nZlFkK1F5NmJVcENEYTFIaE5VdFJEVlpmUTkxVjdqWDVLYUgKM2hVTk91SHlucUtBWEc4eWUvMW9JUWg5YmNxRmswL0RocUlrUVFWY1hWdUYrc244RWVFOTgwWlQ4a2pnSURPZwpLazZVTXlJaUpaY1RIY0YrcFNrbEt2M1lPUThha25UYmdiQjMwcHE3SjVqemMrd1pqeCtXbVpWMEJsanl4OVVuCjREYmhlUUtCZ1FDMFBTaGxLVVBDZzlJOG92UlFBdzVCb1hqM2xrajlkemdScm1EKzkzNmwvYmJPYnhlL3ZxbXcKdHJaVjQzNW0zKzhSMlo4aTNtVEx3N05GcENHeHNDSFBmRGcxY0NxdVdpR3Y4R2wvSTVWN2JPZmo2cWdkRmZBUQpSOGxoenRSRWxYNU90U1RPUFBGOFNFOGtLcytYemZFMENPL1F3UmdpekRBc09oVExKVkUzYUE9PQotLS0tLUVORCBSU0EgUFJJVkFURSBLRVktLS0tLQo=

# cp /root/.kube   /root/.kube.bak

# cp test.conf /root/.kube/config

# oc get pods
NAME                         READY     STATUS    RESTARTS   AGE
web-server-6d76bcd4b-4sd4c   1/1       Running   0          1d
web-server-6d76bcd4b-zj9wz   1/1       Running   0          1d
# oc get namespaces
No resources found.
Error from server (Forbidden): namespaces is forbidden: User "test" cannot list namespaces at the cluster scope
# oc get pods --all-namespaces -o wide
No resources found.
Error from server (Forbidden): pods is forbidden: User "test" cannot list pods at the cluster scope
# kubectl auth can-i create deployments
yes
# kubectl auth can-i create deployments --namespace=default
no

# kubectl config get-contexts
CURRENT   NAME           CLUSTER      AUTHINFO   NAMESPACE
*         test-context   kubernetes   test       test

```

+ 8 Reference 

<a href="https://kubernetes.io/docs/reference/access-authn-authz/rbac/">Using RBAC Authorization</a>
