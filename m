From: Robert Faught <rtf@etnus.com>
Date: Thu, 16 Jan 2003 23:07:00 +0000
Subject: [Linux-ia64] IA64 watchpoint traps not reported in system calls
Message-Id: <marc-linux-ia64-105590709805707@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

A watchpoint set using an IA64 debug data register is ignored when the
location is accessed by a system call such as read.

It would be very good to have the data watch triggered from inside
the kernel reported to the user (or more likely the user`s
debugger), since if you`re trying to find out what is stomping one
of your variables you expect setting a watchpoint on it to tell
you, whether or not the stomping is happening as a result of
passing bad arguments to a system call.


The test below shows the problem using the gdb debugger. It is not a gdb
problem. Our debugger shows the same behavior.

- Rob Faught


This is a simple test case and a gdb session:
--------
/* Watchpoint test program. */

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

/**********************************************************************/
/* Reads zeroes into a buf. */

void read_zero_into (void *buf, int len)
{
    int fd = open ("/dev/zero", O_RDONLY);
    read (fd, buf, len);
    close (fd);
}

void nop ()
{
}

/**********************************************************************/
/* Globals reference tests. */

volatile int gi = -1;  /* Ensure writes happen by tagging it volatile */

void globals_test()
{
    nop();
    gi = 26;
    nop();

    read_zero_into ((void *)&gi, sizeof(gi)); /* Hit the watchpoint from
the kernel */

    nop();
    gi = 41; 		/* Should stop */
    nop();
}

int main()
{
    globals_test();
    exit (0);
}
-------

[ourmachine:328] uname -a
Linux ourmachine 2.4.17-4hpmckinleysmp #1 SMP Mon May 6 15:26:29 MDT
2002 ia64 unknown

[ourmachine:329] gcc -g -o watch watch.c

[ourmachine:330] gdb watch
GNU gdb Red Hat Linux (5.1-1)
Copyright 2001 Free Software Foundation, Inc.
GDB is free software, covered by the GNU General Public License, and you are
welcome to change it and/or distribute copies of it under certain
conditions.
Type "show copying" to see the conditions.
There is absolutely no warranty for GDB.  Type "show warranty" for details.
This GDB was configured as "ia64-redhat-linux"...
(gdb) watch gi
Hardware watchpoint 1: gi
(gdb) run
Starting program: /nfs/fs/u3/home/rtf/watch
Hardware watchpoint 1: gi
Hardware watchpoint 1: gi
Hardware watchpoint 1: gi

Old value = -1
New value = 26
globals_test () at watch.c:31
31
    nop();
(gdb) list 26,39
26

27
void globals_test()
28
{
29
    nop();
30
    gi = 26;
31
    nop();
32

33
    read_zero_into ((void *)&gi, sizeof(gi)); /* Hit the watchpoint from
the kernel */
34

35
    nop();
36
    gi = 41; 		/* Should stop */
37
    nop();
38
}
39

(gdb) cont
Continuing.
Hardware watchpoint 1: gi

Old value = 26
New value = 41
globals_test () at watch.c:37
37
    nop();
(gdb) q
The program is running.  Exit anyway? (y or n) y
---------------------------------
Lines 30 and 36 cause traps but the read called from line 33 does not.



