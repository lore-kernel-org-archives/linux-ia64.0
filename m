From: Andrew Clausen <clausen@melbourne.sgi.com>
Date: Thu, 20 Feb 2003 00:26:55 +0000
Subject: [Linux-ia64] [patch] sys32_sysinfo broken on mips64 and ia64
Message-Id: <marc-linux-ia64-105590709805881@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi all,

The sys32_sysinfo() calls are currently using an old version of
"struct sysinfo32", in both the mips64 and ia64 ports.

busybox's init can't cope with the bogus output on my Origin 200,
so this bug prevents the Debian installer from bootstrapping.

This is the mips64 version of the patch.  A very similar patch
could be constructed for ia64... it's very obvious what to do,
so I'll leave it to you ia64 people :)

Cheers,
Andrew


diff -u -r1.42.2.23 linux32.c
--- arch/mips64/kernel/linux32.c	23 Jan 2003 02:12:59 -0000	1.42.2.23
+++ arch/mips64/kernel/linux32.c	20 Feb 2003 00:05:41 -0000
@@ -672,8 +672,11 @@
         u32 bufferram;
         u32 totalswap;
         u32 freeswap;
-        unsigned short procs;
-        char _f[22];
+        u16 procs;
+	u32 totalhigh;
+	u32 freehigh;
+	u32 mem_unit;
+	char _f[8];
 };
 
 extern asmlinkage int sys_sysinfo(struct sysinfo *info);
@@ -698,6 +701,9 @@
 	err |= __put_user (s.totalswap, &info->totalswap);
 	err |= __put_user (s.freeswap, &info->freeswap);
 	err |= __put_user (s.procs, &info->procs);
+	err |= __put_user (s.totalhigh, &info->totalhigh);
+	err |= __put_user (s.freehigh, &info->freehigh);
+	err |= __put_user (s.mem_unit, &info->mem_unit);
 	if (err)
 		return -EFAULT;
 	return ret;



