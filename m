From: Will Cohen <wcohen@redhat.com>
Date: Tue, 26 Aug 2003 20:42:27 +0000
Subject: [PATCH] ia64 oprofile support for 2.6.0-test4
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------070408040704010905050106"
Message-Id: <marc-linux-ia64-106193081107734@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------070408040704010905050106
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

I have revised the oprofile patch for ia64 to provide just the basic 
timer interrupt mechanism to avoid interferring with the perfmon 2.0 
support. I have verified the oprofile ia64 patch applies cleanly and 
build a working kernel with the 2.6.0-test4 kernel and the 
linux-2.6.0-test4-ia64-030826.diff.bz2 patch.

More work is required to get oprofile to work with the perfmon 2.0. 
However, the patch as it is currently implements should not cause 
problems for the perfom 2.0 support.


-Will

--------------070408040704010905050106
Content-Type: text/plain;
 name="oprof20030825d.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="oprof20030825d.patch"

--- linux-2.6.0-test4-bk2oprof/arch/ia64/kernel/time.c.orig	2003-08-22 19:53:07.000000000 -0400
+++ linux-2.6.0-test4-bk2oprof/arch/ia64/kernel/time.c	2003-08-26 15:15:35.568906131 -0400
@@ -18,6 +18,7 @@
 #include <linux/interrupt.h>
 #include <linux/efi.h>
 #include <linux/timex.h>
+#include <linux/profile.h>
 
 #include <asm/delay.h>
 #include <asm/hw_irq.h>
@@ -39,29 +40,6 @@
 #endif
 
 static void
-do_profile (unsigned long ip)
-{
-	extern cpumask_t prof_cpu_mask;
-
-	if (!prof_buffer)
-		return;
-
-	if (!cpu_isset(smp_processor_id(), prof_cpu_mask))
-		return;
-
-	ip -= (unsigned long) _stext;
-	ip >>= prof_shift;
-	/*
-	 * Don't ignore out-of-bounds IP values silently, put them into the last
-	 * histogram slot, so if present, they will show up as a sharp peak.
-	 */
-	if (ip > prof_len - 1)
-		ip = prof_len - 1;
-
-	atomic_inc((atomic_t *) &prof_buffer[ip]);
-}
-
-static void
 itc_reset (void)
 {
 }
@@ -199,6 +177,47 @@
 	tv->tv_usec = usec;
 }
 
+/*
+ * The profiling function is SMP safe. (nothing can mess
+ * around with "current", and the profiling counters are
+ * updated with atomic operations). This is especially
+ * useful with a profiling multiplier != 1
+ */
+static inline void
+ia64_do_profile(struct pt_regs * regs)
+{
+	unsigned long eip;
+	extern unsigned long prof_cpu_mask;
+ 
+	profile_hook(regs);
+ 
+	if (user_mode(regs))
+		return;
+ 
+	if (!prof_buffer)
+		return;
+
+	eip = instruction_pointer(regs);
+ 
+	/*
+	 * Only measure the CPUs specified by /proc/irq/prof_cpu_mask.
+	 * (default is all CPUs.)
+	 */
+	if (!((1<<smp_processor_id()) & prof_cpu_mask))
+		return;
+
+	eip -= (unsigned long) &_stext;
+	eip >>= prof_shift;
+	/*
+	 * Don't ignore out-of-bounds EIP values silently,
+	 * put them into the last histogram slot, so if
+	 * present, they will show up as a sharp peak.
+	 */
+	if (eip > prof_len-1)
+		eip = prof_len-1;
+	atomic_inc((atomic_t *)&prof_buffer[eip]);
+}
+
 static irqreturn_t
 timer_interrupt (int irq, void *dev_id, struct pt_regs *regs)
 {
@@ -210,14 +229,9 @@
 		printk(KERN_ERR "Oops: timer tick before it's due (itc=%lx,itm=%lx)\n",
 		       ia64_get_itc(), new_itm);
 
+	ia64_do_profile(regs);
+
 	while (1) {
-		/*
-		 * Do kernel PC profiling here.  We multiply the instruction number by
-		 * four so that we can use a prof_shift of 2 to get instruction-level
-		 * instead of just bundle-level accuracy.
-		 */
-		if (!user_mode(regs))
-			do_profile(regs->cr_iip + 4*ia64_psr(regs)->ri);
 
 #ifdef CONFIG_SMP
 		smp_do_timer(regs);
--- linux-2.6.0-test4-bk2oprof/arch/ia64/Makefile.orig	2003-08-22 19:51:04.000000000 -0400
+++ linux-2.6.0-test4-bk2oprof/arch/ia64/Makefile	2003-08-25 14:35:58.000000000 -0400
@@ -65,6 +65,7 @@
 drivers-$(CONFIG_IA64_HP_SIM)	+= arch/ia64/hp/sim/
 drivers-$(CONFIG_IA64_HP_ZX1)	+= arch/ia64/hp/common/ arch/ia64/hp/zx1/
 drivers-$(CONFIG_IA64_GENERIC)	+= arch/ia64/hp/common/ arch/ia64/hp/zx1/ arch/ia64/hp/sim/
+drivers-$(CONFIG_OPROFILE)	+= arch/ia64/oprofile/
 
 boot := arch/ia64/hp/sim/boot
 
--- /dev/null	2003-08-22 16:30:19.000000000 -0400
+++ linux-2.6.0-test4-bk2oprof/arch/ia64/oprofile/init.c	2003-08-25 15:58:25.000000000 -0400
@@ -0,0 +1,25 @@
+/**
+ * @file init.c
+ *
+ * @remark Copyright 2002 OProfile authors
+ * @remark Read the file COPYING
+ *
+ * @author John Levon <levon@movementarian.org>
+ */
+
+#include <linux/kernel.h>
+#include <linux/oprofile.h>
+#include <linux/init.h>
+#include <linux/errno.h>
+ 
+extern void timer_init(struct oprofile_operations ** ops);
+
+int __init oprofile_arch_init(struct oprofile_operations ** ops)
+{
+	return -ENODEV;
+}
+
+
+void oprofile_arch_exit(void)
+{
+}
--- /dev/null	2003-08-22 16:30:19.000000000 -0400
+++ linux-2.6.0-test4-bk2oprof/arch/ia64/oprofile/Kconfig	2003-08-25 14:35:58.000000000 -0400
@@ -0,0 +1,23 @@
+
+menu "Profiling support"
+	depends on EXPERIMENTAL
+
+config PROFILING
+	bool "Profiling support (EXPERIMENTAL)"
+	help
+	  Say Y here to enable the extended profiling support mechanisms used
+	  by profilers such as OProfile.
+	  
+
+config OPROFILE
+	tristate "OProfile system profiling (EXPERIMENTAL)"
+	depends on PROFILING
+	help
+	  OProfile is a profiling system capable of profiling the
+	  whole system, include the kernel, kernel modules, libraries,
+	  and applications.
+
+	  If unsure, say N.
+
+endmenu
+
--- /dev/null	2003-08-22 16:30:19.000000000 -0400
+++ linux-2.6.0-test4-bk2oprof/arch/ia64/oprofile/Makefile	2003-08-25 14:35:58.000000000 -0400
@@ -0,0 +1,9 @@
+obj-$(CONFIG_OPROFILE) += oprofile.o
+
+DRIVER_OBJS := $(addprefix ../../../drivers/oprofile/, \
+		oprof.o cpu_buffer.o buffer_sync.o \
+		event_buffer.o oprofile_files.o \
+		oprofilefs.o oprofile_stats.o \
+		timer_int.o )
+
+oprofile-y := $(DRIVER_OBJS) init.o
--- linux-2.6.0-test4-bk2oprof/arch/ia64/Kconfig.orig	2003-08-25 11:29:46.000000000 -0400
+++ linux-2.6.0-test4-bk2oprof/arch/ia64/Kconfig	2003-08-25 14:35:58.000000000 -0400
@@ -589,6 +589,8 @@
 
 source "arch/ia64/hp/sim/Kconfig"
 
+source "arch/ia64/oprofile/Kconfig"
+
 
 menu "Kernel hacking"
 
--- linux-2.6.0-test4-bk2oprof/include/asm-ia64/hw_irq.h.orig	2003-08-22 19:55:39.000000000 -0400
+++ linux-2.6.0-test4-bk2oprof/include/asm-ia64/hw_irq.h	2003-08-26 15:13:40.369970010 -0400
@@ -9,6 +9,7 @@
 #include <linux/interrupt.h>
 #include <linux/sched.h>
 #include <linux/types.h>
+#include <linux/profile.h>
 
 #include <asm/machvec.h>
 #include <asm/ptrace.h>
--- linux-2.6.0-test4-bk2oprof/include/asm-ia64/ptrace.h.orig	2003-08-22 19:57:23.000000000 -0400
+++ linux-2.6.0-test4-bk2oprof/include/asm-ia64/ptrace.h	2003-08-26 15:12:29.157256063 -0400
@@ -223,6 +223,13 @@
 };
 
 #ifdef __KERNEL__
+/*
+ * We use the ia64_psr(regs)->ri to determine which of the three
+ * instructions in bundle took the sample. The instructions in the
+ * ia64 do not fall on nice four byte boundaries, so there is no point
+ * in multiplying ia64_psr(regs)->ri by 4.
+ */
+#define instruction_pointer(regs) ((regs)->cr_iip + ia64_psr(regs)->ri)
   /* given a pointer to a task_struct, return the user's pt_regs */
 # define ia64_task_regs(t)		(((struct pt_regs *) ((char *) (t) + IA64_STK_OFFSET)) - 1)
 # define ia64_psr(regs)			((struct ia64_psr *) &(regs)->cr_ipsr)

--------------070408040704010905050106--

