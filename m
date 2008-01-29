From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Tue, 29 Jan 2008 05:27:30 +0000
Subject: [PATCH] ia64: VIRT_CPU_ACCOUNTING (accurate cpu time accounting)
Message-Id: <479EB942.30100@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi all,

Here is a refreshed patch to implement VIRT_CPU_ACCOUNTING for ia64,
against latest linux-2.6.24.

If you want to get the detail or performance data, please refer:
 [0/9] of take 1:
   http://www.gelato.unsw.edu.au/archives/linux-ia64/0710/21262.html
 [2/2] of take 2:
   http://www.gelato.unsw.edu.au/archives/linux-ia64/0712/21601.html

The only significant change from take 2 is that the feature is
configured "N" by default.

I have not see any problems on this feature during the past month,
however still I'd appreciate it if you could turn this option to
"Y" and send me your feedback.

Thanks,
H.Seto

-

This patch implements VIRT_CPU_ACCOUNTING for ia64,
which enable us to use more accurate cpu time accounting.

The VIRT_CPU_ACCOUNTING is an item of kernel config, which s390
and powerpc arch have.  By turning this config on, these archs
change the mechanism of cpu time accounting from tick-sampling
based one to state-transition based one.

The state-transition based accounting is done by checking time
(cycle counter in processor) at every state-transition point,
such as entrance/exit of kernel, interrupt, softirq etc.
The difference between point to point is the actual time consumed
during in the state. There is no doubt about that this value is
more accurate than that of tick-sampling based accounting.

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>

---
 arch/ia64/Kconfig              |   11 ++++
 arch/ia64/ia32/elfcore32.h     |   14 +++++
 arch/ia64/kernel/asm-offsets.c |    6 ++
 arch/ia64/kernel/entry.S       |   65 +++++++++++++++++++++++++
 arch/ia64/kernel/fsys.S        |   26 ++++++++++
 arch/ia64/kernel/head.S        |   20 +++++++
 arch/ia64/kernel/ivt.S         |   69 +++++++++++++++++++++++++++
 arch/ia64/kernel/minstate.h    |   14 +++++
 arch/ia64/kernel/time.c        |   78 ++++++++++++++++++++++++++++++
 include/asm-ia64/cputime.h     |  104 ++++++++++++++++++++++++++++++++++++=
+++++
 include/asm-ia64/system.h      |   12 ++++
 include/asm-ia64/thread_info.h |   14 +++++
 12 files changed, 432 insertions(+), 1 deletion(-)

Index: linux-2.6.24/arch/ia64/Kconfig
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.24.orig/arch/ia64/Kconfig
+++ linux-2.6.24/arch/ia64/Kconfig
@@ -262,6 +262,17 @@
 	default "17" if HUGETLB_PAGE
 	default "11"

+config VIRT_CPU_ACCOUNTING
+	bool "Deterministic task and CPU time accounting"
+	default n
+	help
+	  Select this option to enable more accurate task and CPU time
+	  accounting.  This is done by reading a CPU counter on each
+	  kernel entry and exit and on transitions within the kernel
+	  between system, softirq and hardirq state, so there is a
+	  small performance impact.
+	  If in doubt, say N here.
+
 config SMP
 	bool "Symmetric multi-processing support"
 	help
Index: linux-2.6.24/arch/ia64/kernel/time.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.24.orig/arch/ia64/kernel/time.c
+++ linux-2.6.24/arch/ia64/kernel/time.c
@@ -59,6 +59,84 @@
 };
 static struct clocksource *itc_clocksource;

+#ifdef CONFIG_VIRT_CPU_ACCOUNTING
+
+#include <linux/kernel_stat.h>
+
+extern cputime_t cycle_to_cputime(u64 cyc);
+
+/*
+ * Called from the context switch with interrupts disabled, to charge all
+ * accumulated times to the current process, and to prepare accounting on
+ * the next process.
+ */
+void ia64_account_on_switch(struct task_struct *prev, struct task_struct *=
next)
+{
+	struct thread_info *pi =3D task_thread_info(prev);
+	struct thread_info *ni =3D task_thread_info(next);
+	cputime_t delta_stime, delta_utime;
+	__u64 now;
+
+	now =3D ia64_get_itc();
+
+	delta_stime =3D cycle_to_cputime(pi->ac_stime + (now - pi->ac_stamp));
+	account_system_time(prev, 0, delta_stime);
+	account_system_time_scaled(prev, delta_stime);
+
+	if (pi->ac_utime) {
+		delta_utime =3D cycle_to_cputime(pi->ac_utime);
+		account_user_time(prev, delta_utime);
+		account_user_time_scaled(prev, delta_utime);
+	}
+
+	pi->ac_stamp =3D ni->ac_stamp =3D now;
+	ni->ac_stime =3D ni->ac_utime =3D 0;
+}
+
+/*
+ * Account time for a transition between system, hard irq or soft irq stat=
e.
+ * Note that this function is called with interrupts enabled.
+ */
+void account_system_vtime(struct task_struct *tsk)
+{
+	struct thread_info *ti =3D task_thread_info(tsk);
+	unsigned long flags;
+	cputime_t delta_stime;
+	__u64 now;
+
+	local_irq_save(flags);
+
+	now =3D ia64_get_itc();
+
+	delta_stime =3D cycle_to_cputime(ti->ac_stime + (now - ti->ac_stamp));
+	account_system_time(tsk, 0, delta_stime);
+	account_system_time_scaled(tsk, delta_stime);
+	ti->ac_stime =3D 0;
+
+	ti->ac_stamp =3D now;
+
+	local_irq_restore(flags);
+}
+
+/*
+ * Called from the timer interrupt handler to charge accumulated user time
+ * to the current process.  Must be called with interrupts disabled.
+ */
+void account_process_tick(struct task_struct *p, int user_tick)
+{
+	struct thread_info *ti =3D task_thread_info(p);
+	cputime_t delta_utime;
+
+	if (ti->ac_utime) {
+		delta_utime =3D cycle_to_cputime(ti->ac_utime);
+		account_user_time(p, delta_utime);
+		account_user_time_scaled(p, delta_utime);
+		ti->ac_utime =3D 0;
+	}
+}
+
+#endif /* CONFIG_VIRT_CPU_ACCOUNTING */
+
 static irqreturn_t
 timer_interrupt (int irq, void *dev_id)
 {
Index: linux-2.6.24/include/asm-ia64/system.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.24.orig/include/asm-ia64/system.h
+++ linux-2.6.24/include/asm-ia64/system.h
@@ -210,6 +210,13 @@
 extern void ia64_save_extra (struct task_struct *task);
 extern void ia64_load_extra (struct task_struct *task);

+#ifdef CONFIG_VIRT_CPU_ACCOUNTING
+extern void ia64_account_on_switch (struct task_struct *prev, struct task_=
struct *next);
+# define IA64_ACCOUNT_ON_SWITCH(p,n) ia64_account_on_switch(p,n)
+#else
+# define IA64_ACCOUNT_ON_SWITCH(p,n)
+#endif
+
 #ifdef CONFIG_PERFMON
   DECLARE_PER_CPU(unsigned long, pfm_syst_info);
 # define PERFMON_IS_SYSWIDE() (__get_cpu_var(pfm_syst_info) & 0x1)
@@ -222,6 +229,7 @@
 	 || IS_IA32_PROCESS(task_pt_regs(t)) || PERFMON_IS_SYSWIDE())

 #define __switch_to(prev,next,last) do {							 \
+	IA64_ACCOUNT_ON_SWITCH(prev, next);							 \
 	if (IA64_HAS_EXTRA_STATE(prev))								 \
 		ia64_save_extra(prev);								 \
 	if (IA64_HAS_EXTRA_STATE(next))								 \
@@ -266,6 +274,10 @@

 void default_idle(void);

+#ifdef CONFIG_VIRT_CPU_ACCOUNTING
+extern void account_system_vtime(struct task_struct *);
+#endif
+
 #endif /* __KERNEL__ */

 #endif /* __ASSEMBLY__ */
Index: linux-2.6.24/include/asm-ia64/cputime.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.24.orig/include/asm-ia64/cputime.h
+++ linux-2.6.24/include/asm-ia64/cputime.h
@@ -1,6 +1,110 @@
+/*
+ * include/asm-ia64/cputime.h:
+ *		Definitions for measuring cputime on ia64 machines.
+ *
+ * Based on <asm-powerpc/cputime.h>.
+ *
+ * Copyright (C) 2007 FUJITSU LIMITED
+ * Copyright (C) 2007 Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ *
+ * If we have CONFIG_VIRT_CPU_ACCOUNTING, we measure cpu time in nsec.
+ * Otherwise we measure cpu time in jiffies using the generic definitions.
+ */
+
 #ifndef __IA64_CPUTIME_H
 #define __IA64_CPUTIME_H

+#ifndef CONFIG_VIRT_CPU_ACCOUNTING
 #include <asm-generic/cputime.h>
+#else
+
+#include <linux/time.h>
+#include <linux/jiffies.h>
+#include <asm/processor.h>
+
+typedef u64 cputime_t;
+typedef u64 cputime64_t;
+
+#define cputime_zero			((cputime_t)0)
+#define cputime_max			((~((cputime_t)0) >> 1) - 1)
+#define cputime_add(__a, __b)		((__a) +  (__b))
+#define cputime_sub(__a, __b)		((__a) -  (__b))
+#define cputime_div(__a, __n)		((__a) /  (__n))
+#define cputime_halve(__a)		((__a) >> 1)
+#define cputime_eq(__a, __b)		((__a) =3D (__b))
+#define cputime_gt(__a, __b)		((__a) >  (__b))
+#define cputime_ge(__a, __b)		((__a) >=3D (__b))
+#define cputime_lt(__a, __b)		((__a) <  (__b))
+#define cputime_le(__a, __b)		((__a) <=3D (__b))
+
+#define cputime64_zero			((cputime64_t)0)
+#define cputime64_add(__a, __b)		((__a) + (__b))
+#define cputime64_sub(__a, __b)		((__a) - (__b))
+#define cputime_to_cputime64(__ct)	(__ct)
+
+/*
+ * Convert cputime <-> jiffies (HZ)
+ */
+#define cputime_to_jiffies(__ct)	((__ct) / (NSEC_PER_SEC / HZ))
+#define jiffies_to_cputime(__jif)	((__jif) * (NSEC_PER_SEC / HZ))
+#define cputime64_to_jiffies64(__ct)	((__ct) / (NSEC_PER_SEC / HZ))
+#define jiffies64_to_cputime64(__jif)	((__jif) * (NSEC_PER_SEC / HZ))
+
+/*
+ * Convert cputime <-> milliseconds
+ */
+#define cputime_to_msecs(__ct)		((__ct) / NSEC_PER_MSEC)
+#define msecs_to_cputime(__msecs)	((__msecs) * NSEC_PER_MSEC)
+
+/*
+ * Convert cputime <-> seconds
+ */
+#define cputime_to_secs(__ct)		((__ct) / NSEC_PER_SEC)
+#define secs_to_cputime(__secs)		((__secs) * NSEC_PER_SEC)
+
+/*
+ * Convert cputime <-> timespec (nsec)
+ */
+static inline cputime_t timespec_to_cputime(const struct timespec *val)
+{
+	cputime_t ret =3D val->tv_sec * NSEC_PER_SEC;
+	return (ret + val->tv_nsec);
+}
+static inline void cputime_to_timespec(const cputime_t ct, struct timespec=
 *val)
+{
+	val->tv_sec  =3D ct / NSEC_PER_SEC;
+	val->tv_nsec =3D ct % NSEC_PER_SEC;
+}
+
+/*
+ * Convert cputime <-> timeval (msec)
+ */
+static inline cputime_t timeval_to_cputime(struct timeval *val)
+{
+	cputime_t ret =3D val->tv_sec * NSEC_PER_SEC;
+	return (ret + val->tv_usec * NSEC_PER_USEC);
+}
+static inline void cputime_to_timeval(const cputime_t ct, struct timeval *=
val)
+{
+	val->tv_sec =3D ct / NSEC_PER_SEC;
+	val->tv_usec =3D (ct % NSEC_PER_SEC) / NSEC_PER_USEC;
+}
+
+/*
+ * Convert cputime <-> clock (USER_HZ)
+ */
+#define cputime_to_clock_t(__ct)	((__ct) / (NSEC_PER_SEC / USER_HZ))
+#define clock_t_to_cputime(__x)		((__x) * (NSEC_PER_SEC / USER_HZ))
+
+/*
+ * Convert cputime64 to clock.
+ */
+#define cputime64_to_clock_t(__ct)      cputime_to_clock_t((cputime_t)__ct)

+#endif /* CONFIG_VIRT_CPU_ACCOUNTING */
 #endif /* __IA64_CPUTIME_H */
Index: linux-2.6.24/arch/ia64/ia32/elfcore32.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.24.orig/arch/ia64/ia32/elfcore32.h
+++ linux-2.6.24/arch/ia64/ia32/elfcore32.h
@@ -30,7 +30,19 @@
 	int	si_errno;			/* errno */
 };

-#define jiffies_to_timeval(a,b) do { (b)->tv_usec =3D 0; (b)->tv_sec =3D (=
a)/HZ; }while(0)
+#ifdef CONFIG_VIRT_CPU_ACCOUNTING
+/*
+ * Hacks are here since types between compat_timeval (=3D pair of s32) and
+ * ia64-native timeval (=3D pair of s64) are not compatible, at least a fi=
le
+ * arch/ia64/ia32/../../../fs/binfmt_elf.c will get warnings from compiler=
 on
+ * use of cputime_to_timeval(), which usually an alias of jiffies_to_timev=
al().
+ */
+#define cputime_to_timeval(a,b) \
+	do { (b)->tv_usec =3D 0; (b)->tv_sec =3D (a)/NSEC_PER_SEC; } while(0)
+#else
+#define jiffies_to_timeval(a,b) \
+	do { (b)->tv_usec =3D 0; (b)->tv_sec =3D (a)/HZ; } while(0)
+#endif

 struct elf_prstatus
 {
Index: linux-2.6.24/arch/ia64/kernel/asm-offsets.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.24.orig/arch/ia64/kernel/asm-offsets.c
+++ linux-2.6.24/arch/ia64/kernel/asm-offsets.c
@@ -39,6 +39,12 @@
 	DEFINE(TI_FLAGS, offsetof(struct thread_info, flags));
 	DEFINE(TI_CPU, offsetof(struct thread_info, cpu));
 	DEFINE(TI_PRE_COUNT, offsetof(struct thread_info, preempt_count));
+#ifdef CONFIG_VIRT_CPU_ACCOUNTING
+	DEFINE(TI_AC_STAMP, offsetof(struct thread_info, ac_stamp));
+	DEFINE(TI_AC_LEAVE, offsetof(struct thread_info, ac_leave));
+	DEFINE(TI_AC_STIME, offsetof(struct thread_info, ac_stime));
+	DEFINE(TI_AC_UTIME, offsetof(struct thread_info, ac_utime));
+#endif

 	BLANK();

Index: linux-2.6.24/include/asm-ia64/thread_info.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.24.orig/include/asm-ia64/thread_info.h
+++ linux-2.6.24/include/asm-ia64/thread_info.h
@@ -31,6 +31,12 @@
 	mm_segment_t addr_limit;	/* user-level address space limit */
 	int preempt_count;		/* 0=3Dpremptable, <0=3DBUG; will also serve as bh-co=
unter */
 	struct restart_block restart_block;
+#ifdef CONFIG_VIRT_CPU_ACCOUNTING
+	__u64 ac_stamp;
+	__u64 ac_leave;
+	__u64 ac_stime;
+	__u64 ac_utime;
+#endif
 };

 #define THREAD_SIZE			KERNEL_STACK_SIZE
@@ -62,9 +68,17 @@
 #define task_stack_page(tsk)	((void *)(tsk))

 #define __HAVE_THREAD_FUNCTIONS
+#ifdef CONFIG_VIRT_CPU_ACCOUNTING
+#define setup_thread_stack(p, org)			\
+	*task_thread_info(p) =3D *task_thread_info(org);	\
+	task_thread_info(p)->ac_stime =3D 0;		\
+	task_thread_info(p)->ac_utime =3D 0;		\
+	task_thread_info(p)->task =3D (p);
+#else
 #define setup_thread_stack(p, org) \
 	*task_thread_info(p) =3D *task_thread_info(org); \
 	task_thread_info(p)->task =3D (p);
+#endif
 #define end_of_stack(p) (unsigned long *)((void *)(p) + IA64_RBS_OFFSET)

 #define __HAVE_ARCH_TASK_STRUCT_ALLOCATOR
Index: linux-2.6.24/arch/ia64/kernel/minstate.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.24.orig/arch/ia64/kernel/minstate.h
+++ linux-2.6.24/arch/ia64/kernel/minstate.h
@@ -3,6 +3,18 @@

 #include "entry.h"

+#ifdef CONFIG_VIRT_CPU_ACCOUNTING
+/* read ar.itc in advance, and use it before leaving bank 0 */
+#define ACCOUNT_GET_STAMP				\
+(pUStk) mov.m r20=3Dar.itc;
+#define ACCOUNT_SYS_ENTER				\
+(pUStk) br.call.spnt rp=ACcount_sys_enter		\
+	;;
+#else
+#define ACCOUNT_GET_STAMP
+#define ACCOUNT_SYS_ENTER
+#endif
+
 /*
  * DO_SAVE_MIN switches to the kernel stacks (if necessary) and saves
  * the minimum state necessary that allows us to turn psr.ic back
@@ -122,11 +134,13 @@
 	;;											\
 .mem.offset 0,0; st8.spill [r16]=3Dr2,16;								\
 .mem.offset 8,0; st8.spill [r17]=3Dr3,16;								\
+	ACCOUNT_GET_STAMP									\
 	adds r2=3DIA64_PT_REGS_R16_OFFSET,r1;							\
 	;;											\
 	EXTRA;											\
 	movl r1=3D__gp;		/* establish kernel global pointer */				\
 	;;											\
+	ACCOUNT_SYS_ENTER									\
 	bsw.1;			/* switch back to bank 1 (must be last in insn group) */	\
 	;;

Index: linux-2.6.24/arch/ia64/kernel/ivt.S
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.24.orig/arch/ia64/kernel/ivt.S
+++ linux-2.6.24/arch/ia64/kernel/ivt.S
@@ -805,8 +805,13 @@

 (p8)	adds r28=16,r28				// A    switch cr.iip to next bundle
 (p9)	adds r8=3D1,r8				// A    increment ei to next slot
+#ifdef CONFIG_VIRT_CPU_ACCOUNTING
+	;;
+	mov b6=3Dr30				// I0   setup syscall handler branch reg early
+#else
 	nop.i 0
 	;;
+#endif

 	mov.m r25=3Dar.unat			// M2 (5 cyc)
 	dep r29=3Dr8,r29,41,2			// I0   insert new ei into cr.ipsr
@@ -817,7 +822,11 @@
 	//
 ///////////////////////////////////////////////////////////////////////
 	st1 [r16]=3Dr0				// M2|3 clear current->thread.on_ustack flag
+#ifdef CONFIG_VIRT_CPU_ACCOUNTING
+	mov.m r30=3Dar.itc			// M    get cycle for accounting
+#else
 	mov b6=3Dr30				// I0   setup syscall handler branch reg early
+#endif
 	cmp.eq pKStk,pUStk=3Dr0,r17		// A    were we on kernel stacks already?

 	and r9=3D_TIF_SYSCALL_TRACEAUDIT,r9	// A    mask trace or audit
@@ -829,6 +838,30 @@
 	cmp.eq p14,p0=3Dr9,r0			// A    are syscalls being traced/audited?
 	br.call.sptk.many b7=3Dia64_syscall_setup	// B
 1:
+#ifdef CONFIG_VIRT_CPU_ACCOUNTING
+	// mov.m r30=3Dar.itc is called in advance, and r13 is current
+	add r16=3DTI_AC_STAMP+IA64_TASK_SIZE,r13	// A
+	add r17=3DTI_AC_LEAVE+IA64_TASK_SIZE,r13	// A
+(pKStk)	br.cond.spnt .skip_accounting		// B	unlikely skip
+	;;
+	ld8 r18=3D[r16],TI_AC_STIME-TI_AC_STAMP	// M  get last stamp
+	ld8 r19=3D[r17],TI_AC_UTIME-TI_AC_LEAVE	// M  time at leave
+	;;
+	ld8 r20=3D[r16],TI_AC_STAMP-TI_AC_STIME	// M  cumulated stime
+	ld8 r21=3D[r17]				// M  cumulated utime
+	sub r22=3Dr19,r18				// A  stime before leave
+	;;
+	st8 [r16]=3Dr30,TI_AC_STIME-TI_AC_STAMP	// M  update stamp
+	sub r18=3Dr30,r19				// A  elapsed time in user
+	;;
+	add r20=3Dr20,r22				// A  sum stime
+	add r21=3Dr21,r18				// A  sum utime
+	;;
+	st8 [r16]=3Dr20				// M  update stime
+	st8 [r17]=3Dr21				// M  update utime
+	;;
+.skip_accounting:
+#endif
 	mov ar.rsc=3D0x3				// M2   set eager mode, pl 0, LE, loadrs=3D0
 	nop 0
 	bsw.1					// B (6 cyc) regs are saved, switch to bank 1
@@ -928,6 +961,7 @@
 	 *	- r27: saved ar.rsc
 	 *	- r28: saved cr.iip
 	 *	- r29: saved cr.ipsr
+	 *	- r30: ar.itc for accounting (don't touch)
 	 *	- r31: saved pr
 	 *	-  b0: original contents (to be saved)
 	 * On exit:
@@ -1090,6 +1124,41 @@
 	DBG_FAULT(16)
 	FAULT(16)

+#ifdef CONFIG_VIRT_CPU_ACCOUNTING
+	/*
+	 * There is no particular reason for this code to be here, other than
+	 * that there happens to be space here that would go unused otherwise.
+	 * If this fault ever gets "unreserved", simply moved the following
+	 * code to a more suitable spot...
+	 *
+	 * account_sys_enter is called from SAVE_MIN* macros if accounting is
+	 * enabled and if the macro is entered from user mode.
+	 */
+ENTRY(account_sys_enter)
+	// mov.m r20=3Dar.itc is called in advance, and r13 is current
+	add r16=3DTI_AC_STAMP+IA64_TASK_SIZE,r13
+	add r17=3DTI_AC_LEAVE+IA64_TASK_SIZE,r13
+	;;
+	ld8 r18=3D[r16],TI_AC_STIME-TI_AC_STAMP	// time at last check in kernel
+	ld8 r19=3D[r17],TI_AC_UTIME-TI_AC_LEAVE	// time at left from kernel
+        ;;
+	ld8 r23=3D[r16],TI_AC_STAMP-TI_AC_STIME	// cumulated stime
+	ld8 r21=3D[r17]				// cumulated utime
+	sub r22=3Dr19,r18				// stime before leave kernel
+	;;
+	st8 [r16]=3Dr20,TI_AC_STIME-TI_AC_STAMP	// update stamp
+	sub r18=3Dr20,r19				// elapsed time in user mode
+	;;
+	add r23=3Dr23,r22				// sum stime
+	add r21=3Dr21,r18				// sum utime
+	;;
+	st8 [r16]=3Dr23				// update stime
+	st8 [r17]=3Dr21				// update utime
+	;;
+	br.ret.sptk.many rp
+END(account_sys_enter)
+#endif
+
 	.org ia64_ivt+0x4400
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x4400 Entry 17 (size 64 bundles) Reserved
Index: linux-2.6.24/arch/ia64/kernel/fsys.S
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.24.orig/arch/ia64/kernel/fsys.S
+++ linux-2.6.24/arch/ia64/kernel/fsys.S
@@ -660,7 +660,11 @@
 	nop.i 0
 	;;
 	mov ar.rsc=3D0				// M2   set enforced lazy mode, pl 0, LE, loadrs=3D0
+#ifdef CONFIG_VIRT_CPU_ACCOUNTING
+	mov.m r30=3Dar.itc			// M    get cycle for accounting
+#else
 	nop.m 0
+#endif
 	nop.i 0
 	;;
 	mov r23=3Dar.bspstore			// M2 (12 cyc) save ar.bspstore
@@ -682,6 +686,28 @@
 	cmp.ne pKStk,pUStk=3Dr0,r0		// A    set pKStk <- 0, pUStk <- 1
 	br.call.sptk.many b7=3Dia64_syscall_setup	// B
 	;;
+#ifdef CONFIG_VIRT_CPU_ACCOUNTING
+	// mov.m r30=3Dar.itc is called in advance
+	add r16=3DTI_AC_STAMP+IA64_TASK_SIZE,r2
+	add r17=3DTI_AC_LEAVE+IA64_TASK_SIZE,r2
+	;;
+	ld8 r18=3D[r16],TI_AC_STIME-TI_AC_STAMP	// time at last check in kernel
+	ld8 r19=3D[r17],TI_AC_UTIME-TI_AC_LEAVE	// time at leave kernel
+	;;
+	ld8 r20=3D[r16],TI_AC_STAMP-TI_AC_STIME	// cumulated stime
+	ld8 r21=3D[r17]				// cumulated utime
+	sub r22=3Dr19,r18				// stime before leave kernel
+	;;
+	st8 [r16]=3Dr30,TI_AC_STIME-TI_AC_STAMP	// update stamp
+	sub r18=3Dr30,r19				// elapsed time in user mode
+	;;
+	add r20=3Dr20,r22				// sum stime
+	add r21=3Dr21,r18				// sum utime
+	;;
+	st8 [r16]=3Dr20				// update stime
+	st8 [r17]=3Dr21				// update utime
+	;;
+#endif
 	mov ar.rsc=3D0x3				// M2   set eager mode, pl 0, LE, loadrs=3D0
 	mov rp=3Dr14				// I0   set the real return addr
 	and r3=3D_TIF_SYSCALL_TRACEAUDIT,r3	// A
Index: linux-2.6.24/arch/ia64/kernel/entry.S
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.24.orig/arch/ia64/kernel/entry.S
+++ linux-2.6.24/arch/ia64/kernel/entry.S
@@ -710,6 +710,16 @@
 (pUStk)	cmp.eq.unc p6,p0=3Dr0,r0		// p6 <- pUStk
 #endif
 .work_processed_syscall:
+#ifdef CONFIG_VIRT_CPU_ACCOUNTING
+	adds r2=3DPT(LOADRS)+16,r12
+(pUStk)	mov.m r22=3Dar.itc			// fetch time at leave
+	adds r18=3DTI_FLAGS+IA64_TASK_SIZE,r13
+	;;
+(p6)	ld4 r31=3D[r18]				// load current_thread_info()->flags
+	ld8 r19=3D[r2],PT(B6)-PT(LOADRS)		// load ar.rsc value for "loadrs"
+	adds r3=3DPT(AR_BSPSTORE)+16,r12		// deferred
+	;;
+#else
 	adds r2=3DPT(LOADRS)+16,r12
 	adds r3=3DPT(AR_BSPSTORE)+16,r12
 	adds r18=3DTI_FLAGS+IA64_TASK_SIZE,r13
@@ -718,6 +728,7 @@
 	ld8 r19=3D[r2],PT(B6)-PT(LOADRS)		// load ar.rsc value for "loadrs"
 	nop.i 0
 	;;
+#endif
 	mov r16=3Dar.bsp				// M2  get existing backing store pointer
 	ld8 r18=3D[r2],PT(R9)-PT(B6)		// load b6
 (p6)	and r15=3DTIF_WORK_MASK,r31		// any work other than TIF_SYSCALL_TRACE?
@@ -737,12 +748,21 @@

 	ld8 r29=3D[r2],16		// M0|1 load cr.ipsr
 	ld8 r28=3D[r3],16		// M0|1 load cr.iip
+#ifdef CONFIG_VIRT_CPU_ACCOUNTING
+(pUStk) add r14=3DTI_AC_LEAVE+IA64_TASK_SIZE,r13
+	;;
+	ld8 r30=3D[r2],16		// M0|1 load cr.ifs
+	ld8 r25=3D[r3],16		// M0|1 load ar.unat
+(pUStk) add r15=3DIA64_TASK_THREAD_ON_USTACK_OFFSET,r13
+	;;
+#else
 	mov r22=3Dr0		// A    clear r22
 	;;
 	ld8 r30=3D[r2],16		// M0|1 load cr.ifs
 	ld8 r25=3D[r3],16		// M0|1 load ar.unat
 (pUStk) add r14=3DIA64_TASK_THREAD_ON_USTACK_OFFSET,r13
 	;;
+#endif
 	ld8 r26=3D[r2],PT(B0)-PT(AR_PFS)	// M0|1 load ar.pfs
 (pKStk)	mov r22=3Dpsr			// M2   read PSR now that interrupts are disabled
 	nop 0
@@ -759,7 +779,11 @@
 	ld8.fill r1=3D[r3],16			// M0|1 load r1
 (pUStk) mov r17=3D1				// A
 	;;
+#ifdef CONFIG_VIRT_CPU_ACCOUNTING
+(pUStk) st1 [r15]=3Dr17				// M2|3
+#else
 (pUStk) st1 [r14]=3Dr17				// M2|3
+#endif
 	ld8.fill r13=3D[r3],16			// M0|1
 	mov f8=F0				// F    clear f8
 	;;
@@ -775,12 +799,22 @@
 	shr.u r18=3Dr19,16		// I0|1 get byte size of existing "dirty" partition
 	cover				// B    add current frame into dirty partition & set cr.ifs
 	;;
+#ifdef CONFIG_VIRT_CPU_ACCOUNTING
+	mov r19=3Dar.bsp			// M2   get new backing store pointer
+	st8 [r14]=3Dr22			// M	save time at leave
+	mov f10=F0			// F    clear f10
+
+	mov r22=3Dr0			// A	clear r22
+	movl r14=3D__kernel_syscall_via_epc // X
+	;;
+#else
 	mov r19=3Dar.bsp			// M2   get new backing store pointer
 	mov f10=F0			// F    clear f10

 	nop.m 0
 	movl r14=3D__kernel_syscall_via_epc // X
 	;;
+#endif
 	mov.m ar.csd=3Dr0			// M2   clear ar.csd
 	mov.m ar.ccv=3Dr0			// M2   clear ar.ccv
 	mov b7=3Dr14			// I0   clear b7 (hint with __kernel_syscall_via_epc)
@@ -913,10 +947,18 @@
 	adds r16=3DPT(CR_IPSR)+16,r12
 	adds r17=3DPT(CR_IIP)+16,r12

+#ifdef CONFIG_VIRT_CPU_ACCOUNTING
+	.pred.rel.mutex pUStk,pKStk
+(pKStk)	mov r22=3Dpsr		// M2 read PSR now that interrupts are disabled
+(pUStk)	mov.m r22=3Dar.itc	// M  fetch time at leave
+	nop.i 0
+	;;
+#else
 (pKStk)	mov r22=3Dpsr		// M2 read PSR now that interrupts are disabled
 	nop.i 0
 	nop.i 0
 	;;
+#endif
 	ld8 r29=3D[r16],16	// load cr.ipsr
 	ld8 r28=3D[r17],16	// load cr.iip
 	;;
@@ -938,15 +980,37 @@
 	;;
 	ld8.fill r12=3D[r16],16
 	ld8.fill r13=3D[r17],16
+#ifdef CONFIG_VIRT_CPU_ACCOUNTING
+(pUStk)	adds r3=3DTI_AC_LEAVE+IA64_TASK_SIZE,r18
+#else
 (pUStk)	adds r18=3DIA64_TASK_THREAD_ON_USTACK_OFFSET,r18
+#endif
 	;;
 	ld8 r20=3D[r16],16	// ar.fpsr
 	ld8.fill r15=3D[r17],16
+#ifdef CONFIG_VIRT_CPU_ACCOUNTING
+(pUStk)	adds r18=3DIA64_TASK_THREAD_ON_USTACK_OFFSET,r18	// deferred
+#endif
 	;;
 	ld8.fill r14=3D[r16],16
 	ld8.fill r2=3D[r17]
 (pUStk)	mov r17=3D1
 	;;
+#ifdef CONFIG_VIRT_CPU_ACCOUNTING
+	//  mmi_ :  ld8 st1 shr;;         mmi_ : st8 st1 shr;;
+	//  mib  :  mov add br        ->  mib  : ld8 add br
+	//  bbb_ :  br  nop cover;;       mbb_ : mov br  cover;;
+	//
+	//  no one require bsp in r16 if (pKStk) branch is selected.
+(pUStk)	st8 [r3]=3Dr22		// save time at leave
+(pUStk)	st1 [r18]=3Dr17		// restore current->thread.on_ustack
+	shr.u r18=3Dr19,16	// get byte size of existing "dirty" partition
+	;;
+	ld8.fill r3=3D[r16]	// deferred
+	LOAD_PHYS_STACK_REG_SIZE(r17)
+(pKStk)	br.cond.dpnt skip_rbs_switch
+	mov r16=3Dar.bsp		// get existing backing store pointer
+#else
 	ld8.fill r3=3D[r16]
 (pUStk)	st1 [r18]=3Dr17		// restore current->thread.on_ustack
 	shr.u r18=3Dr19,16	// get byte size of existing "dirty" partition
@@ -954,6 +1018,7 @@
 	mov r16=3Dar.bsp		// get existing backing store pointer
 	LOAD_PHYS_STACK_REG_SIZE(r17)
 (pKStk)	br.cond.dpnt skip_rbs_switch
+#endif

 	/*
 	 * Restore user backing store.
Index: linux-2.6.24/arch/ia64/kernel/head.S
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.24.orig/arch/ia64/kernel/head.S
+++ linux-2.6.24/arch/ia64/kernel/head.S
@@ -1002,6 +1002,26 @@
 	br.ret.sptk.many rp
 END(sched_clock)

+#ifdef CONFIG_VIRT_CPU_ACCOUNTING
+GLOBAL_ENTRY(cycle_to_cputime)
+	alloc r16=3Dar.pfs,1,0,0,0
+	addl r8=3DTHIS_CPU(cpu_info) + IA64_CPUINFO_NSEC_PER_CYC_OFFSET,r0
+	;;
+	ldf8 f8=3D[r8]
+	;;
+	setf.sig f9=3Dr32
+	;;
+	xmpy.lu f10=F9,f8	// calculate low 64 bits of 128-bit product	(4 cyc)
+	xmpy.hu f11=F9,f8	// calculate high 64 bits of 128-bit product
+	;;
+	getf.sig r8=F10		//						(5 cyc)
+	getf.sig r9=F11
+	;;
+	shrp r8=3Dr9,r8,IA64_NSEC_PER_CYC_SHIFT
+	br.ret.sptk.many rp
+END(cycle_to_cputime)
+#endif /* CONFIG_VIRT_CPU_ACCOUNTING */
+
 GLOBAL_ENTRY(start_kernel_thread)
 	.prologue
 	.save rp, r0				// this is the end of the call-chain
