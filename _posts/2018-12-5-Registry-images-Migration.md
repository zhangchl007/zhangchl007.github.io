---
layout: post
title: Openshift Internal Docker Registry Images Migration
tag: Openshift
---


+ 1 In case, you do ocp internal docker images migration 

```
# cat img-migration.py

#!/usr/bin/python
#coding=utf-8
from multiprocessing import Process,Pool
import requests,os,re,time,urllib2,json,smtplib,subprocess,signal
### define openshift api######
url = 'https://master01.zhangchl008.tpddns.cn:8443/oapi/v1/imagestreams'
headers = {'Authorization': 'Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6InJvYm90LXRva2VuLXRybXI3Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6InJvYm90Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQudWlkIjoiNDU4N2ZiOWUtZjYyOS0xMWU4LTlhMTMtNTI1NDAwMWI2NDQ0Iiwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50OmRlZmF1bHQ6cm9ib3QifQ.vDVBHInEJzR9hHGpwzR8UBzDF_K_HVP4tIT75REPuxJ6DREwDcX4qMQ1s_KVtvgDm6hQ52RuXc-4hCsStKAWBN2aH5VYTgSY36ssiIMRyULM7wRrk7U60HlL6sB6BWZ36bPt8amTYXprRIyeop9OLYQ8q_ZMEMtaqPYFBecmSRdGv2jycfk_ixtKBCytik20OTWUDW0CWrGYw5yGWNScs2E9tCGDG-llxWG0i83qtnvEDF7U6XVZQmOh1lxTkpoqrOEcqEGwm82KaeN_e_wmFNRYhb1u0ghoxupwpD_w4YuuuMatORaEZmMxLx0e7kZhdjS6dD2KR6q8eDfcc43AaA'}
#####get json data########
def api_return(url):
   global hjson
   r=requests.get(url, headers=headers, verify=False)
   t=json.loads(r.content)
   return t

def pullimgs(img):
    command="docker pull " + img
    print command
    proc = subprocess.Popen(command,stdout=subprocess.PIPE, shell=True)
    proc_stdout = proc.communicate()[0].strip()
    print proc_stdout
    proc.send_signal(signal.SIGINT)  
    #os.kill(0, signal.CTRL_C_EVENT)
def listimgs(url):
    mylist = [] 
    hjson=api_return(url)
    for i in hjson['items']:
       dstatus= i['status']  # internal docker images dict
       dmeta  = i['metadata'] # internal docker image medata: app name and project
       if (dstatus.has_key('tags') and ("openshift" not in dmeta['namespace'])): # filter openshift
          for j in dstatus['tags']:
             imgs = dstatus['dockerImageRepository'] + ":" + j['tag'] # docker images 
             mylist.append(imgs)
    return mylist

if __name__ =='__main__': #执行主进程
    try:    
        print 'Run the main process (%s).' % (os.getpid())
        mainStart = time.time() #记录主进程开始的时间
        p = Pool(3)           #开辟进程池
        mylist=listimgs(url)
        for i in mylist:
           p.apply_async(pullimgs,args=(i,))
        print 'Waiting for all subprocesses done ...'
        p.close() #关闭进程池
        p.join()  #等待开辟的所有进程执行完后，主进程才继续往下执行
        print 'All subprocesses done'
        mainEnd = time.time()  #记录主进程结束时间
        print 'All process ran %0.2f seconds.' % (mainEnd-mainStart)
    except KeyboardInterrupt:
        print 'Killed by user'
        sys.exit(0)

```

