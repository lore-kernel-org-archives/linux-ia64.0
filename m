From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Tue, 04 Mar 2003 21:50:43 +0000
Subject: Re: [Linux-ia64] [patch] sys32_sysinfo broken on mips64 and ia64
Message-Id: <marc-linux-ia64-105590709805961@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805881@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805881@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> The sys32_sysinfo() calls are currently using an old version of
> "struct sysinfo32", in both the mips64 and ia64 ports.

Thanks, Andrew.

David, I applied the following patch to 2.4.  It looks like 2.5 needs
the same thing.

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1013  -> 1.1014 
#	arch/ia64/ia32/sys_ia32.c	1.14    -> 1.15   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/03/04	bjorn_helgaas@hp.com	1.1014
# ia64: sys32_sysinfo: update to current struct sysinfo (add totalhigh,
# freehigh, mem_unit).
# --------------------------------------------
#
diff -Nru a/arch/ia64/ia32/sys_ia32.c b/arch/ia64/ia32/sys_ia32.c
--- a/arch/ia64/ia32/sys_ia32.c	Tue Mar  4 14:32:27 2003
+++ b/arch/ia64/ia32/sys_ia32.c	Tue Mar  4 14:32:27 2003
@@ -3707,8 +3707,11 @@
 	u32 bufferram;
 	u32 totalswap;
 	u32 freeswap;
-	unsigned short procs;
-	char _f[22];
+	u16 procs;
+	u32 totalhigh;
+	u32 freehigh;
+	u32 mem_unit;
+	char _f[8];
 };
 
 asmlinkage long
@@ -3737,6 +3740,9 @@
 	err |= __put_user(s.totalswap, &info->totalswap);
 	err |= __put_user(s.freeswap, &info->freeswap);
 	err |= __put_user(s.procs, &info->procs);
+	err |= __put_user(s.totalhigh, &info->totalhigh);
+	err |= __put_user(s.freehigh, &info->freehigh);
+	err |= __put_user(s.mem_unit, &info->mem_unit);
 	if (err)
 		return -EFAULT;
 	return ret;


