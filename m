From: Keith Owens <kaos@sgi.com>
Date: Sun, 20 Jul 2003 09:51:06 +0000
Subject: [patch] 2.4.21-ia64-030702 arch/ia64/kernel/unwind.c
Message-Id: <marc-linux-ia64-105869470116420@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This has been fixed once but must have slipped through the cracks.  It
only shows up when you turn on unwind debugging.


--- 2.4.21/arch/ia64/kernel/unwind.c	2003-07-20 19:48:22.000000000 +1000
+++ 2.4.21/arch/ia64/kernel/unwind.c	2003-07-20 19:48:13.000000000 +1000
@@ -1934,7 +1934,7 @@
 		   "  pr     0x%lx\n"
 		   "  sw     0x%lx\n"
 		   "  sp     0x%lx\n",
-		   __FUNCTION__, (unsigned long) task, rbslimit, rbstop, stktop, stklimit,
+		   __FUNCTION__, (unsigned long) t, rbslimit, rbstop, stktop, stklimit,
 		   info->pr, (unsigned long) info->sw, info->sp);
 	STAT(unw.stat.api.init_time += ia64_get_itc() - start; local_irq_restore(flags));
 }

