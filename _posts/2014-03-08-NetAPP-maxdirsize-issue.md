---
layout: post
title: NetAPP NAS maxdirsize issue RCA
tag: NetAPP
---
			Root Cause Analysis Report

RCA for e-ESM Ticket: <IN51278802> 
Date Occurred: <2015-03-28 16:49:29> 
Duration:   <> hr<>minutes
Issue : <[LMC] : [FYT] - [unable to access FYT management module] >
	Technical platform: < Linux	>
Business Impact :  < FYT management module was unable to access>
	Impacted countries : <TH > 
	BS platform : <FYT >	


Prepared By:
 	
Contributors/Participants: 

IBM Oracle Team

IBM Unix team

IBM Storage Team



Section 1 – Background 


Management Summary of Events
Please refer to Detailed Log of Events.

Detailed Discussion of Events
Please refer to Detailed Log of Events.

Detailed Log of Events 

Date
Time
Log
2015-Mar-28
04:49:29 PM
> S1 ticket is created by RCC 

> 05:31:00 PM
> DBA team got IBM Ops team's on-call to check the oracle database on LMCAS050
> 
> 05:09:29 PM
> DBA checked the oracle core services were not down but there'is error message[ORA-09925:Unable to create audit trail file shown when new session connects into database
> 
> 06:13:00 PM
> DBA team found the OS issue that Oracle audit trace logs couldn't be cretaed into the OS directory "/busdata/rfyt/lmc1/oracle/admin/adump" and when executing the command "ls -lrat |tail -20" to simply list the files under this directory of Oracle audit logs but no outputs are shown for long times.
> 
> 06:15:00 PM
> DBA team assisted OS support team to help diagnose this issue from OS perspective.
> 
> 06:20:00 PM
> OS team support checked the OS's performance, confirmed there are no OS issue happened at the OS level
> 
> 07:20:00 PM
> PCM team cooperate the relavent teams to diagnose this issue, tried to communicate the application supporting team to restart the FYT application.
> 
> 08:20:00 PM
> As the oracle database is also being userd by the other applcation module.PCM held the conference to discuss to get the corresponding approval to restart the database.
> 
> 08:40:00 PM
> After got the PCM's verbal approval, DBA team restarted the database, but the ORA-09925 is still existing
> 
> 08:54:00 PM
> DBA team tried to rename the previous folder "adump" to "adump.old". and then re-create one new folder "adump" under the directory
> 
> 08:55:00 PM
> After took this temporary solution, the issue was fixed temporary per got confirmed.


Section 2 – Impact 

Michelin end user can't open FYT management module


Section 3 - Corrective Action 

Action Item
Responsible
Due Date
Status
   Rename the directory of oracle audit log                            DBA                       MAR-28             Done
   Refined the options of  maxdirsize in LMC  NAS                Storage                  MAR-31            Done
			
> Section 4 – Root Cause 
> 
> 1. Why the end user can't open FYT management module
> Because FYT can't create a new oracle session 
> 2. Why FYT can't create a new oracle session ?
> Because oracle audit log couldn't be created under the defined path: /oracle/app/oracle/admin/test/adump/
> 
> 3. Why oracle audit log couldn't be created under the defined path?
>  Oracle database had produced over 600 thousand small audit logs ,As the oracle audit function is enabled according to compliance with GSD331 security police's requirement, So it's normal situation that there're very many oracle audit trace logs to be generated. Hence,
>  the Directory entry file size on disk that a directory file takes up is over the maxdirsize  limit In NAS, the new audit log file can’t be created under the current directory
> 
>       Please refer to the following link: 3011562
>                        
>       The actual value >  The default value
>  The default value of maxdirsize to on NAS is 45875   
   ![the default maxdirsize](https://raw.githubusercontent.com/zhangchl007/zhangchl007.github.io/master/_image/maxdirsize01.png)

>    The actual value of maxdirsize to on NAS is 45876
   ![The actual value of maxdirsize](https://raw.githubusercontent.com/zhangchl007/zhangchl007.github.io/master/_image/maxdirsize02.png)
     


Section 5 - Opportunities for Improvement  


No
Recommendation
Grade
Comments
Owner
Agreed completion date
Status
1. 
List all archived directories of oracle audit log on NDI infrastructure
H

DBA
TBD
TBD
2. 
Review and adjust the option in NAS side for oracle audit log directory
H

Storage
TBD
TBD
3
Oracle audit log files will be archived  as long as 90days on NDI infrastructure according to VGSR
H

DBA
TBD
TBD



Section 6 - Follow-on Notes 
Please refer to Section 5

