---
layout: post
title: Learning Linux namespace UTS (-)
tag: Linux
---

I spent some time to study the series:introduction to Linux namespaces - Part 1: UTS
it is very interesting ,I wrote the source code and complied them in my laptop 

* We try to compile and execute the code below,actually ,we create a new child process /bin/bash, and found the system call instead of fork :)

```
[jimmy@oc3053148748 C_lan]$ cat namespace_ns.c 
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
 execv(child_args[0],child_args);
 printf("Ooops\n");
 return 1;
 };
 int main() {
 printf(" - Hello ?\n");
 int child_pid = clone(child_main,child_stack + STACK_SIZE,SIGCHLD,NULL);
 waitpid(child_pid,NULL,0);
 return 0;
 }
 [jimmy@oc3053148748 C_lan]$ gcc -Wall namespace_ns.c  -o ns && ./ns
 - Hello ?
 - World !

```
* We see the source code for creating a namespace uts ,It is amazing to see the hostname had been changed in new uts. 

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
<a href="https://blog.yadutaf.fr/2013/12/22/introduction-to-linux-namespaces-part-1-uts/">introduction-to-linux-namespaces-part-1-uts</a>
