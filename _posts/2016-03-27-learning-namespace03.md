---
layout: post
title: Learning Linux namespaces - Part3 PID
tag: Linux
---

I spent some time to study the series:Introduction to Linux namespaces - Part 3: PID
it is very interesting ,I wrote the source code and complied them in my laptop 

*Activating the IPC namespace is only a matter of adding “CLONE_NEWIPC” to the “clone” call. It requires no additional setup. It may also be freely combined with other namespaces.Here pipe is a sample way compare with the ways below.

.    signal
.    poll memory
.    sockets
.    use files and file-descriptors

 

* With this namespace it is possible to restart PID numbering and get your own “1” process. This could be seen as a “chroot” in the process identifier tree. It’s extremely handy when you need to deal with pids in day to day work and are stuck with 4 digits numbers…
* We see the source code for creating a namespace pid . 

```
jimmy@jimmy01:~/Download/C_lan$ cat namespace_pid.c 
#define _GNU_SOURCE
#include <sys/types.h>
#include <sys/wait.h>
#include <stdio.h> 
#include <sched.h>
#include <signal.h>
#include <unistd.h>
#define STACK_SIZE (1024 * 1024)
int checkpoint[2];

static char child_stack[STACK_SIZE];
char* const child_args[] = {
"/bin/bash",
NULL
};

int child_main(void* arg) {
  char c;
 //init sync primitive
  close(checkpoint[1]);

 // wait...
  read(checkpoint[0],&c,1);

  printf("- [%5d]World !\n",getpid());
  sethostname("wasweb01", 12);
  execv(child_args[0],child_args);
  printf("Ooops\n");
  return 1;
}

int main() {
  // init sync primitive
   pipe(checkpoint);
   printf(" - [%5d] Hello ?\n",getpid()); 
   int child_pid = clone(child_main,child_stack + STACK_SIZE,
   CLONE_NEWUTS | CLONE_NEWIPC | CLONE_NEWPID | SIGCHLD,NULL);
  // CLONE_NEWIPC | SIGCHLD,NULL);
  // some damn long init job
   sleep(2);
  // sinal done
   close(checkpoint[1]);
   waitpid(child_pid,NULL,0);
   return 0;
}

jimmy@jimmy01:~/Download/C_lan$ gcc -Wall namespace_pid.c -o ipc && sudo ./pid
sudo: 无法解析主机：Namespace
 - [17574] Hello ?
- [    1]World !
root@wasweb01:~/Download/C_lan# ps -ef
Error, do this: mount -t proc proc /proc
root@wasweb01:~/Download/C_lan# mount -t proc proc /proc
root@wasweb01:~/Download/C_lan# ps -ef
UID        PID  PPID  C STIME TTY          TIME CMD
root         1     0  0 09:56 pts/28   00:00:00 /bin/bash
root        15     1  0 09:56 pts/28   00:00:00 ps -ef
root@wasweb01:~/Download/C_lan# 

  
```
<a href="https://blog.yadutaf.fr/2014/01/05/introduction-to-linux-namespaces-part-3-pid/">introduction-to-linux-namespaces-part-3-pid</a>
