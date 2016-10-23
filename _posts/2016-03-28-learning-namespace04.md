---
layout: post
title: Learning Linux namespaces - Part4 NS(FS)
tag: Linux
---

I spent some time to study the series:Introduction to Linux namespaces - Part 4 NS(FS) 
it is very interesting ,I wrote the source code and complied them in my laptop 

* Following the previous post on FS namespace (mountpoints table isolation), we will now have a look at an amazing one: isolated mount table. 



```
jimmy@jimmy01:~/Download/C_lan$ cat  namespace_ns.c 
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
  printf(" - [%5] World !\n",getpid());
  sethostname("wasweb01", 12);

 // remount "/proc" to get accurate "top" && "ps" output
  mount("proc", "/proc", "proc", 0, NULL);
 // wait...
  read(checkpoint[0],&c,1);

  execv(child_args[0],child_args);
  printf("Ooops\n");
  return 1;
}

int main() {
  // init sync primitive
   pipe(checkpoint);
   printf(" - [%5d] Hello ?\n",getpid());  
   int child_pid = clone(child_main,child_stack + STACK_SIZE,
   CLONE_NEWUTS | CLONE_NEWIPC | CLONE_NEWPID | CLONE_NEWNS | SIGCHLD,NULL);
  // some damn long init job
   sleep(1);
  // sinal done
   close(checkpoint[1]);
   waitpid(child_pid,NULL,0);
   return 0;
}

jimmy@jimmy01:~/Download/C_lan$ gcc -Wall namespace_ns.c -o ns && sudo ./ns
namespace_ns.c: In function ‘child_main’:
namespace_ns.c:21:10: warning: unknown conversion type character ‘]’ in format [-Wformat=]
   printf(" - [%5] World !\n",getpid());
          ^
namespace_ns.c:21:10: warning: too many arguments for format [-Wformat-extra-args]
namespace_ns.c:25:3: warning: implicit declaration of function ‘mount’ [-Wimplicit-function-declaration]
   mount("proc", "/proc", "proc", 0, NULL);
   ^
 - [ 9967] Hello ?
 - [%5] World !

  
```
<a href="https://blog.yadutaf.fr/2014/01/12/introduction-to-linux-namespaces-part-4-ns-fs//">introduction-to-linux-namespaces-part-4-ns(fs)</a>
