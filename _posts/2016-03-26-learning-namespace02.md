---
layout: post
title: Learning Linux namespaces - Part2 IPC
tag: Linux
---

I spent some time to study the series:Introduction to Linux namespaces - Part 2: IPC
it is very interesting ,I wrote the source code and complied them in my laptop 

* We try to compile and execute the code below,actually ,we create a new child process /bin/bash, and found the system call instead of fork,we will now go deeper and look at a more security oriented namespace: IPC, Inter-Process Communications.
*Activating the IPC namespace is only a matter of adding “CLONE_NEWIPC” to the “clone” call. It requires no additional setup. It may also be freely combined with other namespaces.Here pipe is a sample way compare with the ways below.

.    signal
.    poll memory
.    sockets
.    use files and file-descriptors

 

* We see the source code for creating a namespace ipc . 

```
[jimmy@oc3053148748 C_lan]$ cat namespace_uts.c 
 #define _GNU_SOURCE
 #include <sys/types.h>
 #include <sys/wait.h>
 #include <stdio.h> 
 #include <sched.h>
 #include <signal.h>
 #include <unistd.h>
 #define STACK_SIZE (1024 * 1024)
 static char child_stack[STACK_SIZE];
 char* const child_args[] = {
 "/bin/bash",
 NULL
 };
 int child_main(void* arg) {
 printf("- World !\n");
 sethostname("Namespace", 12);
 execv(child_args[0],child_args);
 printf("Ooops\n");
 return 1;
 };
 int main(){
 printf(" - Hello ?\n");
 int child_pid = clone(child_main,child_stack + STACK_SIZE,CLONE_NEWUTS|SIGCHLD,NULL);
 waitpid(child_pid,NULL,0);
 return 0;
 };
 [jimmy@oc3053148748 C_lan]$ gcc -Wall namespace_uts.c  -o uts && sudo ./uts
  \- Hello ?
  \- World !
  [root@Namespace C_lan]# hostname
  Namespace
  [root@Namespace C_lan]# echo $$
  10666

```
<a href="https://blog.yadutaf.fr/2013/12/28/introduction-to-linux-namespaces-part-2-ipc/">introduction-to-linux-namespaces-part-2-ipc</a>
