From: Gary Hade <garyhade@us.ibm.com>
Date: Mon, 25 Feb 2002 09:54:30 +0000
Subject: Re: [Linux-ia64] gcc profiling broken on Linux/ia64?
Message-Id: <marc-linux-ia64-105590701905188@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905185@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905185@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Randolph,
I believe this problem is due to a bug in /usr/lib/gcrt1.o 
that was fixed by recent glibc changes to csu/gmon-start.c
(revs 1.13 and 1.14).

Hope this helps.

Gary

--- csu/gmon-start.c.orig	Mon Feb 25 01:10:03 2002
+++ csu/gmon-start.c	Wed Feb 13 17:08:05 2002
@@ -1,5 +1,5 @@
 /* Code to enable profiling at program startup.
-   Copyright (C) 1995, 1996, 1997, 2000, 2001 Free Software Foundation, Inc.
+   Copyright (C) 1995,1996,1997,2000,2001,2002 Free Software Foundation, Inc.
    This file is part of the GNU C Library.
 
    The GNU C Library is free software; you can redistribute it and/or
@@ -63,7 +63,11 @@
 #endif
 
   /* Start keeping profiling records.  */
+#ifdef ENTRY_POINT_DECL
+  __monstartup ((u_long) ENTRY_POINT, (u_long) &etext);
+#else
   __monstartup ((u_long) &ENTRY_POINT, (u_long) &etext);
+#endif
 
   /* Call _mcleanup before exiting; it will write out gmon.out from the
      collected data.  */



On Sat, Feb 23, 2002 at 07:10:30PM -0800, Randolph Chung wrote:
> Greetings....
> 
> I was wondering if anyone has gotten gcc profiling to work on 
> linux/ia64?
> 
> $ cat hello.c 
> int main(int argc, char **argv) { return 0; }
> $ gcc -pg -o hello hello.c
> $ ./hello
> Segmentation fault
> 
> I've tried this with the 2.96 compilers on RedHat 7.2 as well as both
> 2.96 and 3.0.4 compilers on Debian 3.0 (glibc 2.2.4 on RH, 2.2.5 on
> Debian)
> 
> Backtrace with gdb looks like this:
> 
> (gdb) bt
> #0  __mcount (frompc140901064496364080, selfpcF11686018427390128)
>     at mcount.c:96
> #1  0x20000000001fdf30 in mcount () at soinit.c:56
> #2  0x40000000000008b0 in main (argc73766400, argv=0x7000a1000005501)
>     at hello.c:1
> 
> mcount.c:96         toindex = *frompcindex;
> 
> (gdb) print frompcindex
> $1 = (u_short *) 0xa000000000471ce8
> 
> Any pointers would be much appreciated.
> 
> randolph
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Gary Hade
IBM Linux Technology Center
503-578-4503  IBM T/L: 775-4503
garyhade@us.ibm.com
http://www.ibm.com/linux/ltc

