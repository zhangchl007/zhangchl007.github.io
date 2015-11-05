---
layout: post
title: How to resize root lv with luks Encrption 
tag: Linux
---
Even I did it  many times ,but I have to write down the notes in case I forget it! 
<pre><code>
1. boot up Linux os with rescue mode . 
2. make sure which partition / resides and type the command 
   cryptsetup luksOpen /dev/sda2 devicename  
3. varyon system vg

   vgchage -ay 
4. Please make sure lvsize > filesytem size ,then type the command 
   lvresise -L  lvname -r 
<pre></code>

Git it done now :)
<a href="https://www.redhat.com/summit/2011/presentations/summit/taste_of_training/thursday/Strickland_On_Disk_Encryption_with_RHEL.pdf">Redhat Disk Encrption</a>
