From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Tue, 16 Oct 2007 13:38:38 +0000
Subject: [PATCH 5/9] ia64: VIRT_CPU_ACCOUNTING (accurate cpu time accounting)
Message-Id: <4714BEDE.5030107@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> [5/9] ia64_acct_vars.patch

Variables to keep ar.itc values is required.

At least we need:

 - holder of time at last check point
    When cpu comes to check-point(state-transition point),
    load the time at last check point from this variable,
    and save current time instead. The difference between
    last time and current time is elapsed time in previous
    state.

However, what we need to care about here is cost of
translation from the difference of time to elapsed time,
i.e. cost of translation from cycle to nsec.

This is a floating point calculation, not so cheap.
So doing this translation in every kernel entrance/exit
is not good idea.

Therefore, we prepare more:

 - holder of cumulated cycles for utime
 - holder of cumulated cycles for stime

Using these variables, we can avoid translation until it
is required. Translations on context switch and that in
account_system_vtime() are not avoidable, since former
changes accounting thread, and latter requires dividing
stime to one in irq/softirq and one in not.

So if the thread repeats round trip between user and kernel
without receiving interrupt, translation is required only
once at leaving on context switch.

On the other hand, a timer interrupt will happen in every
tick, so translation (and update of stime/utime) will be
executed at least every tick.

Finally, I allocate these variables in thread_info since
it is accessible even in kernel entrance/exit, without
causing a page fault. This location is a moot point.

Thanks,
H.Seto

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>

---
 arch/ia64/kernel/asm-offsets.c |    5 +++++
 include/asm-ia64/thread_info.h |   13 +++++++++++++
 2 files changed, 18 insertions(+)

Index: linux-2.6.23/arch/ia64/kernel/asm-offsets.c
=================================--- linux-2.6.23.orig/arch/ia64/kernel/asm-offsets.c
+++ linux-2.6.23/arch/ia64/kernel/asm-offsets.c
@@ -39,6 +39,11 @@
 	DEFINE(TI_FLAGS, offsetof(struct thread_info, flags));
 	DEFINE(TI_CPU, offsetof(struct thread_info, cpu));
 	DEFINE(TI_PRE_COUNT, offsetof(struct thread_info, preempt_count));
+#ifdef CONFIG_VIRT_CPU_ACCOUNTING
+	DEFINE(TI_AC_STAMP, offsetof(struct thread_info, ac_stamp));
+	DEFINE(TI_AC_STIME, offsetof(struct thread_info, ac_stime));
+	DEFINE(TI_AC_UTIME, offsetof(struct thread_info, ac_utime));
+#endif

 	BLANK();

Index: linux-2.6.23/include/asm-ia64/thread_info.h
=================================--- linux-2.6.23.orig/include/asm-ia64/thread_info.h
+++ linux-2.6.23/include/asm-ia64/thread_info.h
@@ -31,6 +31,11 @@
 	mm_segment_t addr_limit;	/* user-level address space limit */
 	int preempt_count;		/* 0=premptable, <0=BUG; will also serve as bh-counter */
 	struct restart_block restart_block;
+#ifdef CONFIG_VIRT_CPU_ACCOUNTING
+	__u64 ac_stamp;
+	__u64 ac_stime;
+	__u64 ac_utime;
+#endif
 };

 #define THREAD_SIZE			KERNEL_STACK_SIZE
@@ -62,9 +67,17 @@
 #define task_stack_page(tsk)	((void *)(tsk))

 #define __HAVE_THREAD_FUNCTIONS
+#ifdef CONFIG_VIRT_CPU_ACCOUNTING
+#define setup_thread_stack(p, org)			\
+	*task_thread_info(p) = *task_thread_info(org);	\
+	task_thread_info(p)->ac_stime = 0;		\
+	task_thread_info(p)->ac_utime = 0;		\
+	task_thread_info(p)->task = (p);
+#else
 #define setup_thread_stack(p, org) \
 	*task_thread_info(p) = *task_thread_info(org); \
 	task_thread_info(p)->task = (p);
+#endif
 #define end_of_stack(p) (unsigned long *)((void *)(p) + IA64_RBS_OFFSET)

 #define __HAVE_ARCH_TASK_STRUCT_ALLOCATOR


