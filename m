From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 06 Feb 2004 21:43:35 +0000
Subject: Trivial patch
Message-Id: <B05667366EE6204181EABE9C1B1C0EB58024DA@scsmsx401.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I don't see cpucount variable is used anywhere in 2.6.2 tree.  So remove
it.

diff -Nur linux-2.6.2/arch/ia64/kernel/smpboot.c
linux-2.6.2.ken/arch/ia64/kernel/smpboot.c
--- linux-2.6.2/arch/ia64/kernel/smpboot.c	2004-01-20
19:49:36.000000000 -0800
+++ linux-2.6.2.ken/arch/ia64/kernel/smpboot.c	2004-02-06
11:58:37.000000000 -0800
@@ -77,7 +77,6 @@
 extern void start_ap (void);
 extern unsigned long ia64_iobase;
 
-int cpucount;
 task_t *task_for_booting_cpu;
 
 /* Bitmask of currently online CPUs */

