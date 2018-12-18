---
layout: post
title: Ceph radosgw Deployment with tsl/ssl
tag: Openshift
---

+ 1 Create radios gateway keyring

```
# sudo ceph-authtool --create-keyring /etc/ceph/ceph.client.radosgw.keyring
creating /etc/ceph/ceph.client.radosgw.keyring
# sudo chmod +r /etc/ceph/ceph.client.radosgw.keyring
使用ceph-authtool在keyring文件中生成随机密码
# sudo ceph-authtool /etc/ceph/ceph.client.radosgw.keyring -n client.radosgw.gateway --gen-key
在keyring中增加存储集群的操作权限；
# sudo ceph-authtool -n client.radosgw.gateway --cap osd 'allow rwx' --cap mon 'allow rwx' /etc/ceph/ceph.client.radosgw.keyring
将key添加到ceph storage cluster
# sudo ceph -k /etc/ceph/ceph.client.admin.keyring auth add client.radosgw.gateway -i /etc/ceph/ceph.client.radosgw.keyring
added key for client.radosgw.gateway
==   equal the steps above ==
# sudo ceph --cluster ceph --name client.admin --keyring /etc/ceph/ceph.client.admin.keyring auth get-or-create client.rgw.ceph04 osd 'allow rwx' mon 'allow rwx' -o /etc/ceph/ceph.client.rgw.ceph04.keyring

# sudo cat /etc/ceph/ceph.client.rgw.ceph04.keyring 
[client.rgw.ceph04]
	key = AQBi4w9ccJULHhAALNDddEm83W9CFa90iSN+2Q==

# 

```

+ 2 在ceph.conf中配置gateway的keyring文件路径

```
# vi /etc/ceph/ceph.conf
[client.rgw.ceph04]
host = ceph04
keyring = /etc/ceph/ceph.client.rgw.ceph04.keyring
log file = /var/log/ceph/client.rgw.ceph04.log
rgw_frontends =civetweb port=80
rgw print continue = false

```

+ 3 Install radoagw

```
# ceph-deploy install --rgw ceph04
# ceph-deploy rgw create ceph04

# sudo firewall-cmd --zone=public --add-port 80/tcp --permanent
# sudo firewall-cmd --reload

```

+ 4 将生成的keyring文件上传到gateway的机器

```
# scp /etc/ceph/ceph.client.rgw.ceph04.keyring ceph04:/etc/ceph/ceph.client.rgw.ceph04.keyring

```
+ 5 将为s3访问创建一个用户

```
# sudo radosgw-admin user create --secret="123" --uid="s3" --display-name="s3 user"

```

+ 5 配置s3cmd 

```
# s3cmd --configure

# cat ~/.s3cfg 
[default]
access_key = UNT4Y3I1CXFAVZYZN5RE
access_token = 
add_encoding_exts = 
add_headers = 
bucket_location = US
ca_certs_file = 
cache_file = 
check_ssl_certificate = True
check_ssl_hostname = True
cloudfront_host = 192.168.0.24
content_disposition = 
content_type = 
default_mime_type = binary/octet-stream
delay_updates = False
delete_after = False
delete_after_fetch = False
delete_removed = False
dry_run = False
enable_multipart = True
encrypt = False
expiry_date = 
expiry_days = 
expiry_prefix = 
follow_symlinks = False
force = False
get_continue = False
gpg_command = /usr/bin/gpg
gpg_decrypt = %(gpg_command)s -d --verbose --no-use-agent --batch --yes --passphrase-fd %(passphrase_fd)s -o %(output_file)s %(input_file)s
gpg_encrypt = %(gpg_command)s -c --verbose --no-use-agent --batch --yes --passphrase-fd %(passphrase_fd)s -o %(output_file)s %(input_file)s
gpg_passphrase = redhat
guess_mime_type = True
host_base = ceph04.zhangchl008.tpddns.cn
host_bucket = ceph04.zhangchl008.tpddns.cn/%(bucket)
human_readable_sizes = False
invalidate_default_index_on_cf = False
invalidate_default_index_root_on_cf = True
invalidate_on_cf = False
kms_key = 
limit = -1
limitrate = 0
list_md5 = False
log_target_prefix = 
long_listing = False
max_delete = -1
mime_type = 
multipart_chunk_size_mb = 15
multipart_max_chunks = 10000
preserve_attrs = True
progress_meter = True
proxy_host = 
proxy_port = 0
put_continue = False
recursive = False
recv_chunk = 65536
reduced_redundancy = False
requester_pays = False
restore_days = 1
restore_priority = Standard
secret_key = Cm0PuqK8HY6dOgV9yCAI2WsaOZntJBC7Zk7Xfc8M
send_chunk = 65536
server_side_encryption = False
signature_v2 = False
signurl_use_https = False
simpledb_host = sdb.amazonaws.com
skip_existing = False
socket_timeout = 300
stats = False
stop_on_error = False
storage_class = 
throttle_max = 100
upload_id = 
urlencoding_mode = normal
use_http_expect = False
use_https = True
use_mime_magic = True
verbosity = WARNING
website_endpoint = http://%(bucket)s.s3-website-%(location)s.amazonaws.com/
website_error = 
website_index = index.html
[jimmy@registry ~]$ clear
[jimmy@registry ~]$ cat ~/.s3cfg 
[default]
access_key = UNT4Y3I1CXFAVZYZN5RE
access_token = 
add_encoding_exts = 
add_headers = 
bucket_location = US
ca_certs_file = 
cache_file = 
check_ssl_certificate = True
check_ssl_hostname = True
cloudfront_host = 192.168.0.24
content_disposition = 
content_type = 
default_mime_type = binary/octet-stream
delay_updates = False
delete_after = False
delete_after_fetch = False
delete_removed = False
dry_run = False
enable_multipart = True
encrypt = False
expiry_date = 
expiry_days = 
expiry_prefix = 
follow_symlinks = False
force = False
get_continue = False
gpg_command = /usr/bin/gpg
gpg_decrypt = %(gpg_command)s -d --verbose --no-use-agent --batch --yes --passphrase-fd %(passphrase_fd)s -o %(output_file)s %(input_file)s
gpg_encrypt = %(gpg_command)s -c --verbose --no-use-agent --batch --yes --passphrase-fd %(passphrase_fd)s -o %(output_file)s %(input_file)s
gpg_passphrase = redhat
guess_mime_type = True
host_base = ceph04.zhangchl008.tpddns.cn
host_bucket = ceph04.zhangchl008.tpddns.cn/%(bucket)
human_readable_sizes = False
invalidate_default_index_on_cf = False
invalidate_default_index_root_on_cf = True
invalidate_on_cf = False
kms_key = 
limit = -1
limitrate = 0
list_md5 = False
log_target_prefix = 
long_listing = False
max_delete = -1
mime_type = 
multipart_chunk_size_mb = 15
multipart_max_chunks = 10000
preserve_attrs = True
progress_meter = True
proxy_host = 
proxy_port = 0
put_continue = False
recursive = False
recv_chunk = 65536
reduced_redundancy = False
requester_pays = False
restore_days = 1
restore_priority = Standard
secret_key = Cm0PuqK8HY6dOgV9yCAI2WsaOZntJBC7Zk7Xfc8M
send_chunk = 65536
server_side_encryption = False
signature_v2 = False
signurl_use_https = False
simpledb_host = sdb.amazonaws.com
skip_existing = False
socket_timeout = 300
stats = False
stop_on_error = False
storage_class = 
throttle_max = 100
upload_id = 
urlencoding_mode = normal
use_http_expect = False
use_https = True
use_mime_magic = True
verbosity = WARNING
website_endpoint = http://%(bucket)s.s3-website-%(location)s.amazonaws.com/
website_error =
website_index = index.html

# s3cmd mb s3://thanos
# s3cmd ls  -v
2018-12-17 01:23  s3://thanos

# s3cmd put file.txt s3://thanos/file.txt
# s3cmd put --acl-public file.txt s3://my-bucket-name/file.txt
# s3cmd del s3://thanos/file.txt

```

+ 5 配置civetweb with https

```
# openssl req -x509 -new -nodes -sha512 -days 3650 \
    -subj "/C=TW/ST=Taipei/L=Taipei/O=example/OU=Personal/CN=zhangchl008.tpddns.cn" \
    -key ca.key \
    -out ca.crt
	 openssl req -sha512 -new \
    -subj "/C=TW/ST=Taipei/L=Taipei/O=example/OU=Personal/CN=zhangchl008.tpddns.cn" \
    -key ceph04.zhangchl008.tpddns.cn.key \
    -out ceph04.zhangchl008.tpddns.cn.csr 
# cat > v3.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth 
subjectAltName = @alt_names

[alt_names]
DNS.1=ceph04.zhangchl008.tpddns.cn
DNS.2=ceph04.zhangchl008.tpddns
DNS.3=ceph04
EOF

# openssl x509 -req -sha512 -days 3650 \
    -extfile v3.ext \
    -CA ca.crt -CAkey ca.key -CAcreateserial \
    -in ceph04.zhangchl008.tpddns.cn.csr \
    -out ceph04.zhangchl008.tpddns.cn.crt
```

+ 6 修改ceph.conf

```
[mgr]
mgr modules = dashboard
[client.rgw.ceph04]
host = ceph04.zhangchl008.tpddns.cn
keyring = /etc/ceph/ceph.client.rgw.ceph04.keyring
log file = /var/log/ceph/client.rgw.ceph04.log
rgw_frontends = civetweb port=80+443s ssl_certificate=/etc/ceph/private/ceph04.example.com.pem
rgw print continue = false
# overwriting the configuration 
# ceph-deploy --overwrite-conf config push ceph02 ceph03 ceph04
# sudo systemctl restart ceph-radosgw@rgw.ceph04
Delete bucket
# radosgw-admin bucket rm --bucket=mybucket --purge-objects
```
