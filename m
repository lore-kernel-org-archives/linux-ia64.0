From: Paul Jackson <pj@sgi.com>
Date: Wed, 05 Nov 2003 04:17:53 +0000
Subject: [PATCH] prof_cpu_mask_read_proc() cpumask print in /proc botch
Message-Id: <marc-linux-ia64-106800594630021@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Display of cpumask for /proc/irq/prof_cpu_mask has a botch in the print
loop - should consume 2 bytes per loop.

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1356  -> 1.1357 
#	arch/ia64/kernel/irq.c	1.30    -> 1.31   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/11/04	pj@sgi.com	1.1357
# fix prof_cpu_mask_read_proc() print loop - 2 bytes per iteration
# --------------------------------------------
#
diff -Nru a/arch/ia64/kernel/irq.c b/arch/ia64/kernel/irq.c
--- a/arch/ia64/kernel/irq.c	Tue Nov  4 19:31:16 2003
+++ b/arch/ia64/kernel/irq.c	Tue Nov  4 19:31:16 2003
@@ -1039,7 +1039,7 @@
 	if (count < HEX_DIGITS+1)
 		return -EINVAL;
 
-	for (k = 0; k < sizeof(cpumask_t)/sizeof(unsigned long); ++k) {
+	for (k = 0; k < sizeof(cpumask_t)/sizeof(u16); ++k) {
 		int j = sprintf(page, "%04hx", (u16)cpus_coerce(*mask));
 		len += j;
 		page += j;


-- 
                          I won't rest till it's the best ...
                          Programmer, Linux Scalability
                          Paul Jackson <pj@sgi.com> 1.650.933.1373
