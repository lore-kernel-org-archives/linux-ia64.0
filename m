From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 31 Jul 2002 16:19:12 +0000
Subject: [Linux-ia64] [patch] important bug fix for irq_cpustat.h
Message-Id: <marc-linux-ia64-105590701905865@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The patch below fixes a typo in irq_cpustat.h.  I found the error
while going over the code as part of synching with Linus' 2.5 tree.
I'm not aware of the typo causing a detectable problem but it's
clearly a bug and I suspect it could cause at least performance
anomalies, if not outright errors.

	--david

--- include/linux/irq_cpustat.h~	Mon Jul 29 15:03:27 2002
+++ include/linux/irq_cpustat.h	Tue Jul 30 18:03:41 2002
@@ -42,7 +42,7 @@
 #define local_ksoftirqd_task()	ksoftirqd_task(smp_processor_id())
 
 /* These will lose the "really_" prefix when the interim macros below are removed.  */
-#define really_local_irq_count()bh_count(smp_processor_id())
+#define really_local_irq_count()irq_count(smp_processor_id())
 #define really_local_bh_count()	bh_count(smp_processor_id())
 
 /* Interim macros for backward compatibility.  They are deprecated.  Use irq_count() and

