From: "Donny Cooper" <dcooper@hstc.necsyl.com>
Date: Fri, 01 Jun 2001 19:34:01 +0000
Subject: [Linux-ia64] getlogin problem
Message-Id: <marc-linux-ia64-105590693005684@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

Below is a small test that shows a getlogin problem.

Please review the following session. The getlogin does not
return username if the code is executed in a script with background
command, but returns correctly when run in foreground.

Note: below test uses ecc (Intel Compiler), gcc compiler yields
same results. 

This works correctly in 000828 with 2.4.0-test10 kernel.
 
Any ideas?

Thanks.

Donny
NEC Systems, Inc.

--- Begin Test Case -----------------
Failed Environments:
TurboLinux Beta2-R1 w/ 2.4.0-010109-61 kernel on Lion system
TurboLinux Beta2-R1 w/ 2.4.3-AzusA kernel on AzusA system 
TurboLinux Beta3    w/ 2.4.3-010405 kernel on Lion system

[aamin@lion]$ cat getlogin.c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
main()
{
char *s;
s=malloc(32);
s=getlogin();
printf("arvind login %s \n",s);
}

[aamin@lion]$ ecc -o getlogin getlogin.c

[aamin@lion]$ cat test.csh
#!/bin/csh
./getlogin &

[aamin@lion]$ ./getlogin
arvind login aamin

[aamin@lion]$ test.csh
[1] 15977
[aamin@lion]$ arvind login (null)
 
--- End Test Case -------------------

-----------------------------------
Donny Cooper
NEC Systems, Inc.
Advanced Technical Computing Center
dcooper@atcc.necsyl.com
http://www.necservers.com
----------------------------------- 

