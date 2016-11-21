---
layout: post
title: A tool to monitor rancher agent status NS(FS) by python
tag: rancher
---

Due to the monitoring requirements from client ,I spent some time to write a tool to collect agent status for Rancher  

* Here are the source code below :). 



```
#!/usr/bin/python
#coding=utf-8
import os
import re
import time
import urllib2
import json
####rancher api username/password ########
#username=os.getenv('RANCHER_ACCESS_KEY')
#password=os.getenv('RANCHER_SECRET_KEY')

username="F5D4DC1FE5172065D0BF"
password="4SBn4NB3MfiCA19BbiCTAreeikDws1j3eiighGWa"

#####define function to get rancher api############
def api_return(url):
   global hjson
   p = urllib2.HTTPPasswordMgrWithDefaultRealm()
   p.add_password(None, url, username, password)
   handler = urllib2.HTTPBasicAuthHandler(p)
   opener = urllib2.build_opener(handler)
   urllib2.install_opener(opener)
   page = urllib2.urlopen(url)
   hjson=json.loads(page.read())
   return hjson
########define convert disk size######
def convert(m,n):
   if (m=='TB'):
       return float(n)*1000*1000*10000
   elif (m=='GB'):
       return float(n)*1024*1024
   elif (m=='MB'):
       return float(n)*1000
   else:
        return float(n)
######access rancher api#######
while True:
######access rancher server api#######
#  url = 'http://192.168.122.11:8080/v1/projects/1a5/physicalhosts'
  url = 'http://182.140.210.213:8080/v1/projects/1a5/physicalhosts'
  hjson=api_return(url) 
  for i in hjson['data']:
      global host_name,time_stamp
############obtain all rancher agent api#########
      url=i['links']['hosts']
      hjson=api_return(url)
      if len(hjson['data'])==0:
              continue
      host_name=hjson['data'][0]['hostname']
      time_stamp=hjson['data'][0]['createdTS']
      print '{"metric":"rancher.agent","agentstatus":%s,"timestamp":%d,"tags":{"machine":"%s"}}' %(hjson['data'][0]['agentState'],time_stamp,host_name) 
#####print docker dockerStorageDriverStatus##########
      d = hjson['data'][0]['info']['diskInfo']['dockerStorageDriverStatus']
      for key in sorted(d.keys()):
          p1=re.search(r'Data Space Available',key)
          p2=re.search(r'Data Space Total',key)
          p3=re.search(r'Data Space Used',key)
          p4=re.search(r'Metadata Space Available',key)
          p5=re.search(r'Metadata Space Total',key)
          p6=re.search(r'Metadata Space Used',key)
          if (p1 and d[key]):
             k=re.compile('([\d.]+)\s+(\w+)')
             v=k.search(d[key]).groups()
             data_free=convert(v[1],v[0])
             print '{"metric":"docker.thinpool.data.free","timestamp":%d,"value":%s,"tags":{"machine":"%s"}}' %(time_stamp,data_free,host_name)
          elif (p2 and d[key]):
             k=re.compile('([\d.]+)\s+(\w+)')
             v=k.search(d[key]).groups()
             data_total=convert(v[1],v[0])
             print '{"metric":"docker.thinpool.data.total","timestamp":%d,"value":%s,"tags":{"machine":"%s"}}' %(time_stamp,data_total,host_name)
          elif (p3 and d[key]):
             k=re.compile('([\d.]+)\s+(\w+)')
             v=k.search(d[key]).groups()
             data_used=convert(v[1],v[0])
             print '{"metric":"docker.thinpool.data.used","timestamp":%d,"value":%s,"tags":{"machine":"%s"}}' %(time_stamp,data_used,host_name)
          elif (p4 and d[key]):
             k=re.compile('([\d.]+)\s+(\w+)')
             v=k.search(d[key]).groups()
             meta_free=convert(v[1],v[0])
             print '{"metric":"docker.thinpool.metadata.free","timestamp":%d,"value":%s,"tags":{"machine":"%s"}}' %(time_stamp,meta_free,host_name)
          elif (p5 and d[key]):
             k=re.compile('([\d.]+)\s+(\w+)')
             v=k.search(d[key]).groups()
             meta_total=convert(v[1],v[0])
             print '{"metric":"docker.thinpool.metadata.total","timestamp":%d,"value":%s,"tags":{"machine":"%s"}}' %(time_stamp,meta_total,host_name)
          elif (p6 and d[key]):
             k=re.compile('([\d.]+)\s+(\w+)')
             v=k.search(d[key]).groups()
             meta_used=convert(v[1],v[0])
             print '{"metric":"docker.thinpool.metadata.used","timestamp":%d,"value":%s,"tags":{"machine":"%s"}}' %(time_stamp,meta_used,host_name)

  time.sleep(10) 

  
```
<a href="https://blog.yadutaf.fr/2014/01/12/introduction-to-linux-namespaces-part-4-ns-fs//">introduction-to-linux-namespaces-part-4-ns(fs)</a>
