From: Jack Steiner <steiner@sgi.com>
Date: Wed, 26 Nov 2003 15:23:10 +0000
Subject: [PATCH] - kernel profiler & spinlock_contention
Message-Id: <marc-linux-ia64-106986108616188@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Profiling is more useful if addresses in spinlock_contention
were attributed to the caller of spinlock_contention.



diff -Naur linux_base/arch/ia64/kernel/head.S linux/arch/ia64/kernel/head.S
--- linux_base/arch/ia64/kernel/head.S	Tue Nov 25 10:03:46 2003
+++ linux/arch/ia64/kernel/head.S	Tue Nov 25 15:21:58 2003
@@ -888,6 +888,8 @@
 	cmp4.eq p14,p0=r30,r0
 (p14)	br.cond.sptk.few b6	// lock is now free, try to acquire
 	br.cond.sptk.few .wait
+	.global ia64_spinlock_contention_pre3_4_end    // for kernprof
+ia64_spinlock_contention_pre3_4_end:
 END(ia64_spinlock_contention_pre3_4)
 
 #else



diff -Naur linux_base/arch/ia64/kernel/time.c linux/arch/ia64/kernel/time.c
--- linux_base/arch/ia64/kernel/time.c	Tue Nov 25 10:03:46 2003
+++ linux/arch/ia64/kernel/time.c	Tue Nov 25 10:07:21 2003
@@ -202,6 +202,9 @@
 {
 	unsigned long ip, slot;
 	extern cpumask_t prof_cpu_mask;
+#ifdef CONFIG_SMP
+	extern char ia64_spinlock_contention_pre3_4[], ia64_spinlock_contention_pre3_4_end[];
+#endif
 
 	profile_hook(regs);
 
@@ -216,7 +219,14 @@
 	 * bits 2 and 3 rather than bits 0 and 1.
 	 */
 	slot = ip & 3;
-	ip = (ip & ~3UL) + 4*slot;
+	ip = (ip & ~3UL);
+#ifdef CONFIG_SMP
+	if (ip >= (unsigned long)ia64_spinlock_contention_pre3_4 &&
+			ip < (unsigned long)ia64_spinlock_contention_pre3_4_end)
+		ip = regs->r28;
+	else
+#endif
+	ip += 4*slot;
 
 	/*
 	 * Only measure the CPUs specified by /proc/irq/prof_cpu_mask.
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


