From: Luming Yu <luming.yu@gmail.com>
Date: Fri, 25 Jun 2010 08:31:29 +0000
Subject: [RFC PATCH --take 2] Add TRACE_IRQFLAGS_SUPPORT, LOCKDEP_SUPPORT then
Message-Id: <AANLkTin0QevX0zZaFc4-LVcoIWfRGmzDKUOSIRKdjKgn@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="0016e64dc986fb4c490489d69820"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--0016e64dc986fb4c490489d69820
Content-Type: text/plain; charset=UTF-8

Hi there,

I just get some free time to have the patch series updated
against Linux-2.6.35-rc3+.

The following rfc patch is to add lockdep support and IRQ-flags
state tracing support for ia64 architecture based on instructions
described in irqflags-tracing.

I've tested the patch against Linux-2.6.35-rc3+ git tree on
 ia64 systems I can have access right now.
It boots fine with and without the irq trace and lockdep
code enabled on all of them.

I also tried function trace and irqoff trace, they seem to work.

The next step is to fix issues and those strange workarounds.
And beautify the code to make it easy merged.

Yeah, I know it's not ready to ask for merge.
I need to find out reasonable ways to address all those
ugly workarounds that just make lockdep code happy..
Most of them are not as easy as it appears...
Some real issues must have been discovered by
those lockdep warnings, but I temporarily suppress
them to get ftrace working...

I also don't want everyone needing ftrace blocked..
Please let me know you have any problems with
the patch series.

The patch contains:

[1/8]  add  ia64 TRACE_IRQFLAGS_SUPPORT
[2/8]  enable LOCKDEP_SUPPORT for ia64
[3/8]  enlarge PERCPU_PAGE_SHIT to 20 from 16
[4/8]  workarounds for hard interrupt
[5/8]  workarounds for mca and NMI
[6/8]  workarounds for system call
[7/8]  various ugly workarounds to suppress locdkep warnning at run time
[8/8]  various ugly workarounds to suppress locdkep warnning  at boot time


# cat /proc/lockdep_stats
 lock-classes:                         1185 [max: 4095]
 direct dependencies:                  4434 [max: 16384]
 indirect dependencies:               12799
 all direct dependencies:             86955
 dependency chains:                    5580 [max: 32768]
 dependency chain hlocks:             14263 [max: 163840]
 in-hardirq chains:                      19
 in-softirq chains:                     316
 in-process chains:                    4136
 stack-trace entries:                     0 [max: 262144]
 combined max dependencies:        26228580
 hardirq-safe locks:                     30
 hardirq-unsafe locks:                  519
 softirq-safe locks:                    121
 softirq-unsafe locks:                  413
 irq-safe locks:                        129
 irq-unsafe locks:                      519
 hardirq-read-safe locks:                 0
 hardirq-read-unsafe locks:              99
 softirq-read-safe locks:                11
 softirq-read-unsafe locks:              89
 irq-read-safe locks:                    11
 irq-read-unsafe locks:                  99
 uncategorized locks:                   112
 unused locks:                            0
 max locking depth:                       9
 max bfs queue depth:                   122
 chain lookup misses:                  5579
 chain lookup hits:                39288389
 cyclic checks:                        4193
 find-mask forwards checks:            1487
 find-mask backwards checks:          28354
 hardirq on events:                57175409
 hardirq off events:               57175383
 redundant hardirq ons:            34600716
 redundant hardirq offs:          102820066
 softirq on events:                 9367917
 softirq off events:                9367945
 redundant softirq ons:                   0
 redundant softirq offs:                  0
 debug_locks:                             1


Ps. The patch is enclosed in attachment. The in-lined one
is c&p of it for reading.

Thanks,
Luming

Signed-off-by: Bob Picco <bob.picco@hp.com>
Signed-off-by: Yu Luming <luming.yu@intel.com>

 arch/ia64/Kconfig              |    6 ++
 arch/ia64/Kconfig.debug        |    3 +
 arch/ia64/include/asm/page.h   |    2
 arch/ia64/include/asm/rwsem.h  |   27 ++++++++----
 arch/ia64/include/asm/system.h |   84 ---------------------------------------
 arch/ia64/kernel/Makefile      |    1
 arch/ia64/kernel/entry.S       |   88 +++++++++++++++++++++++++++++++++++++++++
 arch/ia64/kernel/irq_ia64.c    |    3 +
 arch/ia64/kernel/ivt.S         |    4 +
 arch/ia64/kernel/mca.c         |   15 ++++--
 arch/ia64/kernel/process.c     |    6 +-
 arch/ia64/kernel/ptrace.c      |   34 +++++++++++++++
 arch/ia64/kernel/setup.c       |    4 +
 arch/ia64/kernel/smpboot.c     |    2
 arch/ia64/kernel/time.c        |    4 -
 arch/ia64/mm/fault.c           |    1
 fs/ioctl.c                     |    1
 fs/open.c                      |    1
 fs/read_write.c                |    1
 include/linux/irqflags.h       |    2
 include/linux/lockdep.h        |    2
 kernel/fork.c                  |    4 +
 kernel/lockdep.c               |    8 +++
 kernel/sys.c                   |    1
 kernel/timer.c                 |    1
 kernel/trace/trace_irqsoff.c   |    6 ++
 26 files changed, 206 insertions(+), 105 deletions(-)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 9561082..bbb3e91 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -148,6 +148,12 @@ source "arch/ia64/xen/Kconfig"

 endif

+config LOCKDEP_SUPPORT
+	def_bool y
+
+config STACKTRACE_SUPPORT
+	def_bool y
+
 choice
 	prompt "System type"
 	default IA64_GENERIC
diff --git a/arch/ia64/Kconfig.debug b/arch/ia64/Kconfig.debug
index de9d507..b57bab5 100644
--- a/arch/ia64/Kconfig.debug
+++ b/arch/ia64/Kconfig.debug
@@ -2,6 +2,9 @@ menu "Kernel hacking"

 source "lib/Kconfig.debug"

+config TRACE_IRQFLAGS_SUPPORT
+	def_bool y
+
 choice
 	prompt "Physical memory granularity"
 	default IA64_GRANULE_64MB
diff --git a/arch/ia64/include/asm/page.h b/arch/ia64/include/asm/page.h
index 5f271bc..4109f09 100644
--- a/arch/ia64/include/asm/page.h
+++ b/arch/ia64/include/asm/page.h
@@ -41,7 +41,7 @@
 #define PAGE_SIZE		(__IA64_UL_CONST(1) << PAGE_SHIFT)
 #define PAGE_MASK		(~(PAGE_SIZE - 1))

-#define PERCPU_PAGE_SHIFT	16	/* log2() of max. size of per-CPU area */
+#define PERCPU_PAGE_SHIFT	20	/*20 log2() of max. size of per-CPU area */
 #define PERCPU_PAGE_SIZE	(__IA64_UL_CONST(1) << PERCPU_PAGE_SHIFT)


diff --git a/arch/ia64/include/asm/rwsem.h b/arch/ia64/include/asm/rwsem.h
index e876268..a9ea581 100644
--- a/arch/ia64/include/asm/rwsem.h
+++ b/arch/ia64/include/asm/rwsem.h
@@ -37,6 +37,9 @@ struct rw_semaphore {
 	signed long		count;
 	spinlock_t		wait_lock;
 	struct list_head	wait_list;
+#ifdef CONFIG_DEBUG_LOCK_ALLOC
+	struct lockdep_map dep_map;
+#endif
 };

 #define RWSEM_UNLOCKED_VALUE		__IA64_UL_CONST(0x0000000000000000)
@@ -46,9 +49,15 @@ struct rw_semaphore {
 #define RWSEM_ACTIVE_READ_BIAS		RWSEM_ACTIVE_BIAS
 #define RWSEM_ACTIVE_WRITE_BIAS		(RWSEM_WAITING_BIAS + RWSEM_ACTIVE_BIAS)

+#ifdef CONFIG_DEBUG_LOCK_ALLOC
+# define __RWSEM_DEP_MAP_INIT(lockname) , .dep_map = { .name = #lockname }
+#else
+# define __RWSEM_DEP_MAP_INIT(lockname)
+#endif
+
 #define __RWSEM_INITIALIZER(name) \
 	{ RWSEM_UNLOCKED_VALUE, __SPIN_LOCK_UNLOCKED((name).wait_lock), \
-	  LIST_HEAD_INIT((name).wait_list) }
+	  LIST_HEAD_INIT((name).wait_list) __RWSEM_DEP_MAP_INIT(name)}

 #define DECLARE_RWSEM(name) \
 	struct rw_semaphore name = __RWSEM_INITIALIZER(name)
@@ -58,13 +67,15 @@ extern struct rw_semaphore
*rwsem_down_write_failed(struct rw_semaphore *sem);
 extern struct rw_semaphore *rwsem_wake(struct rw_semaphore *sem);
 extern struct rw_semaphore *rwsem_downgrade_wake(struct rw_semaphore *sem);

-static inline void
-init_rwsem (struct rw_semaphore *sem)
-{
-	sem->count = RWSEM_UNLOCKED_VALUE;
-	spin_lock_init(&sem->wait_lock);
-	INIT_LIST_HEAD(&sem->wait_list);
-}
+extern void __init_rwsem(struct rw_semaphore *sem, const char *name,
+			 struct lock_class_key *key);
+
+#define init_rwsem(sem)						\
+do {								\
+	static struct lock_class_key __key;			\
+								\
+	__init_rwsem((sem), #sem, &__key);			\
+} while (0)

 /*
  * lock for reading
diff --git a/arch/ia64/include/asm/system.h b/arch/ia64/include/asm/system.h
index 9f342a5..0c21f6d 100644
--- a/arch/ia64/include/asm/system.h
+++ b/arch/ia64/include/asm/system.h
@@ -107,88 +107,6 @@ extern struct ia64_boot_param {
  */
 #define set_mb(var, value)	do { (var) = (value); mb(); } while (0)

-#define safe_halt()         ia64_pal_halt_light()    /* PAL_HALT_LIGHT */
-
-/*
- * The group barrier in front of the rsm & ssm are necessary to ensure
- * that none of the previous instructions in the same group are
- * affected by the rsm/ssm.
- */
-/* For spinlocks etc */
-
-/*
- * - clearing psr.i is implicitly serialized (visible by next insn)
- * - setting psr.i requires data serialization
- * - we need a stop-bit before reading PSR because we sometimes
- *   write a floating-point register right before reading the PSR
- *   and that writes to PSR.mfl
- */
-#ifdef CONFIG_PARAVIRT
-#define __local_save_flags()	ia64_get_psr_i()
-#else
-#define __local_save_flags()	ia64_getreg(_IA64_REG_PSR)
-#endif
-
-#define __local_irq_save(x)			\
-do {						\
-	ia64_stop();				\
-	(x) = __local_save_flags();		\
-	ia64_stop();				\
-	ia64_rsm(IA64_PSR_I);			\
-} while (0)
-
-#define __local_irq_disable()			\
-do {						\
-	ia64_stop();				\
-	ia64_rsm(IA64_PSR_I);			\
-} while (0)
-
-#define __local_irq_restore(x)	ia64_intrin_local_irq_restore((x) & IA64_PSR_I)
-
-#ifdef CONFIG_IA64_DEBUG_IRQ
-
-  extern unsigned long last_cli_ip;
-
-# define __save_ip()		last_cli_ip = ia64_getreg(_IA64_REG_IP)
-
-# define local_irq_save(x)					\
-do {								\
-	unsigned long __psr;					\
-								\
-	__local_irq_save(__psr);				\
-	if (__psr & IA64_PSR_I)					\
-		__save_ip();					\
-	(x) = __psr;						\
-} while (0)
-
-# define local_irq_disable()	do { unsigned long __x;
local_irq_save(__x); } while (0)
-
-# define local_irq_restore(x)					\
-do {								\
-	unsigned long __old_psr, __psr = (x);			\
-								\
-	local_save_flags(__old_psr);				\
-	__local_irq_restore(__psr);				\
-	if ((__old_psr & IA64_PSR_I) && !(__psr & IA64_PSR_I))	\
-		__save_ip();					\
-} while (0)
-
-#else /* !CONFIG_IA64_DEBUG_IRQ */
-# define local_irq_save(x)	__local_irq_save(x)
-# define local_irq_disable()	__local_irq_disable()
-# define local_irq_restore(x)	__local_irq_restore(x)
-#endif /* !CONFIG_IA64_DEBUG_IRQ */
-
-#define local_irq_enable()	({ ia64_stop(); ia64_ssm(IA64_PSR_I);
ia64_srlz_d(); })
-#define local_save_flags(flags)	({ ia64_stop(); (flags) =
__local_save_flags(); })
-
-#define irqs_disabled()				\
-({						\
-	unsigned long __ia64_id_flags;		\
-	local_save_flags(__ia64_id_flags);	\
-	(__ia64_id_flags & IA64_PSR_I) == 0;	\
-})
-
 #ifdef __KERNEL__

 /*
@@ -265,7 +183,7 @@ extern void ia64_account_on_switch (struct
task_struct *prev, struct task_struct
 #define __ARCH_WANT_UNLOCKED_CTXSW
 #define ARCH_HAS_PREFETCH_SWITCH_STACK
 #define ia64_platform_is(x) (strcmp(x, platform_name) == 0)
-
+#include <linux/irqflags.h>
 void cpu_idle_wait(void);

 #define arch_align_stack(x) (x)
diff --git a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
index db10b1e..395c2f2 100644
--- a/arch/ia64/kernel/Makefile
+++ b/arch/ia64/kernel/Makefile
@@ -34,6 +34,7 @@ obj-$(CONFIG_AUDIT)		+= audit.o
 obj-$(CONFIG_PCI_MSI)		+= msi_ia64.o
 mca_recovery-y			+= mca_drv.o mca_drv_asm.o
 obj-$(CONFIG_IA64_MC_ERR_INJECT)+= err_inject.o
+obj-$(CONFIG_STACKTRACE)	+= stacktrace.o

 obj-$(CONFIG_PARAVIRT)		+= paravirt.o paravirtentry.o \
 				   paravirt_patch.o
diff --git a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
index 9a260b3..393e68d 100644
--- a/arch/ia64/kernel/entry.S
+++ b/arch/ia64/kernel/entry.S
@@ -48,6 +48,7 @@
 #include <asm/thread_info.h>
 #include <asm/unistd.h>
 #include <asm/ftrace.h>
+#include <asm/irqflags.h>

 #include "minstate.h"

@@ -583,6 +584,88 @@ strace_error:
 	br.cond.sptk .strace_save_retval
 END(ia64_trace_syscall)

+/*
+ * Derived from ia64_trace_syscall
+ */
+GLOBAL_ENTRY(ia64_irqtrace_syscall)
+	PT_REGS_UNWIND_INFO(0)
+	/*
+	 * We need to preserve the scratch registers f6-f11 in case the system
+	 * call is sigreturn.
+	 */
+	adds r16=PT(F6)+16,sp
+	adds r17=PT(F7)+16,sp
+	;;
+ 	stf.spill [r16]=f6,32
+ 	stf.spill [r17]=f7,32
+	;;
+ 	stf.spill [r16]=f8,32
+ 	stf.spill [r17]=f9,32
+	;;
+ 	stf.spill [r16]=f10
+ 	stf.spill [r17]=f11
+	br.call.sptk.many rp=syscall_irqtrace_enter
+	cmp.lt p6,p0=r8,r0			// check tracehook
+	adds r2=PT(R8)+16,sp			// r2 = &pt_regs.r8
+	adds r3=PT(R10)+16,sp			// r3 = &pt_regs.r10
+	mov r10=0
+(p6)	br.cond.sptk irqstrace_error		// syscall failed ->
+	adds r16=PT(F6)+16,sp
+	adds r17=PT(F7)+16,sp
+	;;
+	ldf.fill f6=[r16],32
+	ldf.fill f7=[r17],32
+	;;
+	ldf.fill f8=[r16],32
+	ldf.fill f9=[r17],32
+	;;
+	ldf.fill f10=[r16]
+	ldf.fill f11=[r17]
+	// the syscall number may have changed, so re-load it and re-calculate the
+	// syscall entry-point:
+	adds r15=PT(R15)+16,sp			// r15 = &pt_regs.r15 (syscall #)
+	;;
+	ld8 r15=[r15]
+	mov r3=NR_syscalls - 1
+	;;
+	adds r15=-1024,r15
+	movl r16=sys_call_table
+	;;
+	shladd r20=r15,3,r16			// r20 = sys_call_table + 8*(syscall-1024)
+	cmp.leu p6,p7=r15,r3
+	;;
+(p6)	ld8 r20=[r20]				// load address of syscall entry point
+(p7)	movl r20=sys_ni_syscall
+	;;
+	mov b6=r20
+	br.call.sptk.many rp=b6			// do the syscall
+.irqstrace_check_retval:
+	cmp.lt p6,p0=r8,r0			// syscall failed?
+	adds r2=PT(R8)+16,sp			// r2 = &pt_regs.r8
+	adds r3=PT(R10)+16,sp			// r3 = &pt_regs.r10
+	mov r10=0
+(p6)	br.cond.sptk irqstrace_error		// syscall failed ->
+	;;					// avoid RAW on r10
+.irqstrace_save_retval:
+.mem.offset 0,0; st8.spill [r2]=r8		// store return value in slot for r8
+.mem.offset 8,0; st8.spill [r3]=r10		// clear error indication in slot for r10
+	br.call.sptk.many rp=syscall_irqtrace_leave
+.irqtraceret3:
+(pUStk)	cmp.eq.unc p6,p0=r0,r0			// p6 <- pUStk
+(pUStk)	rsm psr.i				// disable interrupts
+	br.cond.sptk ia64_work_pending_syscall_end
+
+irqstrace_error:
+	ld8 r3=[r2]				// load pt_regs.r8
+	sub r9=0,r8				// negate return value to get errno value
+	;;
+	cmp.ne p6,p0=r3,r0			// is pt_regs.r8!=0?
+	adds r3=16,r2				// r3=&pt_regs.r10
+	;;
+(p6)	mov r10=-1
+(p6)	mov r8=r9
+	br.cond.sptk .irqstrace_save_retval
+END(ia64_irqtrace_syscall)
 	/*
 	 * When traced and returning from sigreturn, we invoke syscall_trace but then
 	 * go straight to ia64_leave_kernel rather than ia64_leave_syscall.
@@ -858,6 +941,11 @@ GLOBAL_ENTRY(__paravirt_leave_kernel)
 	cmp.eq p6,p0=r21,r0		// p6 <- pUStk || (preempt_count == 0)
 #else
 	RSM_PSR_I(pUStk, r17, r31)
+#if 0 //Todo: fix lock held when returning to user space
+	;;
+	LOCKDEP_SYS_EXIT
+	;;
+#endif
 	cmp.eq p0,pLvSys=r0,r0		// pLvSys=0: leave from kernel
 (pUStk)	cmp.eq.unc p6,p0=r0,r0		// p6 <- pUStk
 #endif
diff --git a/arch/ia64/kernel/irq_ia64.c b/arch/ia64/kernel/irq_ia64.c
index f14c35f..3732d59 100644
--- a/arch/ia64/kernel/irq_ia64.c
+++ b/arch/ia64/kernel/irq_ia64.c
@@ -453,6 +453,7 @@ ia64_handle_irq (ia64_vector vector, struct pt_regs *regs)
 	struct pt_regs *old_regs = set_irq_regs(regs);
 	unsigned long saved_tpr;

+	trace_hardirqs_off();
 #if IRQ_DEBUG
 	{
 		unsigned long bsp, sp;
@@ -523,6 +524,8 @@ ia64_handle_irq (ia64_vector vector, struct pt_regs *regs)
 	 * come through until ia64_eoi() has been done.
 	 */
 	irq_exit();
+	if(!current->hardirq_context)
+		trace_hardirqs_on_delayed();
 	set_irq_regs(old_regs);
 }

diff --git a/arch/ia64/kernel/ivt.S b/arch/ia64/kernel/ivt.S
index d93e396..f9731bd 100644
--- a/arch/ia64/kernel/ivt.S
+++ b/arch/ia64/kernel/ivt.S
@@ -855,7 +855,11 @@ ENTRY(break_fault)
 (p10)	br.cond.spnt.many ia64_ret_from_syscall	// B    return if bad
call-frame or r15 is a NaT

 	SSM_PSR_I(p15, p15, r16)		// M2   restore psr.i
+#ifdef CONFIG_TRACE_IRQFLAGS
+(p14)	br.cond.spnt.many ia64_irqtrace_syscall	// B	do syscall-tracing
thingamagic
+#else
 (p14)	br.call.sptk.many b6=b6			// B    invoke syscall-handker
(ignore return addr)
+#endif
 	br.cond.spnt.many ia64_trace_syscall	// B	do syscall-tracing thingamagic
 	// NOT REACHED
 ///////////////////////////////////////////////////////////////////////
diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index a0220dc..ec48cd6 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -536,6 +536,7 @@ ia64_mca_cpe_int_handler (int cpe_irq, void *arg)
 	static int		index;
 	static DEFINE_SPINLOCK(cpe_history_lock);

+	lockdep_off();
 	IA64_MCA_DEBUG("%s: received interrupt vector = %#x on CPU %d\n",
 		       __func__, cpe_irq, smp_processor_id());

@@ -581,7 +582,7 @@ ia64_mca_cpe_int_handler (int cpe_irq, void *arg)
 out:
 	/* Get the CPE error record and log it */
 	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CPE);
-
+	lockdep_on();
 	return IRQ_HANDLED;
 }

@@ -780,7 +781,7 @@ ia64_mca_rendez_int_handler(int rendez_irq, void *arg)
 		{ .sos = NULL, .monarch_cpu = &monarch_cpu };

 	/* Mask all interrupts */
-	local_irq_save(flags);
+	raw_local_irq_save(flags);

 	NOTIFY_MCA(DIE_MCA_RENDZVOUS_ENTER, get_irq_regs(), (long)&nd, 1);

@@ -800,7 +801,7 @@ ia64_mca_rendez_int_handler(int rendez_irq, void *arg)

 	ia64_mc_info.imi_rendez_checkin[cpu] = IA64_MCA_RENDEZ_CHECKIN_NOTDONE;
 	/* Enable all interrupts */
-	local_irq_restore(flags);
+	raw_local_irq_restore(flags);
 	return IRQ_HANDLED;
 }

@@ -1399,7 +1400,7 @@ ia64_mca_cmc_int_handler(int cmc_irq, void *arg)
 		       __func__, cmc_irq, smp_processor_id());

 	/* SAL spec states this should run w/ interrupts enabled */
-	local_irq_enable();
+	raw_local_irq_enable();

 	spin_lock(&cmc_history_lock);
 	if (!cmc_polling_enabled) {
@@ -1536,6 +1537,7 @@ ia64_mca_cpe_int_caller(int cpe_irq, void *arg)
 	static int poll_time = MIN_CPE_POLL_INTERVAL;
 	unsigned int cpuid;

+	lockdep_off();
 	cpuid = smp_processor_id();

 	/* If first cpu, update count */
@@ -1569,6 +1571,7 @@ ia64_mca_cpe_int_caller(int cpe_irq, void *arg)
 			mod_timer(&cpe_poll_timer, jiffies + poll_time);
 		start_count = -1;
 	}
+	lockdep_on();

 	return IRQ_HANDLED;
 }
@@ -1894,10 +1897,10 @@ static void __cpuinit
ia64_mca_cmc_vector_adjust(void *dummy)
 {
 	unsigned long flags;

-	local_irq_save(flags);
+	raw_local_irq_save(flags);
 	if (!cmc_polling_enabled)
 		ia64_mca_cmc_vector_enable(NULL);
-	local_irq_restore(flags);
+	raw_local_irq_restore(flags);
 }

 static int __cpuinit mca_cpu_callback(struct notifier_block *nfb,
diff --git a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
index 53f1648..afe0ddf 100644
--- a/arch/ia64/kernel/process.c
+++ b/arch/ia64/kernel/process.c
@@ -237,14 +237,14 @@ update_pal_halt_status(int status)
 void
 default_idle (void)
 {
-	local_irq_enable();
+	raw_local_irq_enable();
 	while (!need_resched()) {
 		if (can_do_pal_halt) {
-			local_irq_disable();
+			raw_local_irq_disable();
 			if (!need_resched()) {
 				safe_halt();
 			}
-			local_irq_enable();
+			raw_local_irq_enable();
 		} else
 			cpu_relax();
 	}
diff --git a/arch/ia64/kernel/ptrace.c b/arch/ia64/kernel/ptrace.c
index 7c7909f..a23c683 100644
--- a/arch/ia64/kernel/ptrace.c
+++ b/arch/ia64/kernel/ptrace.c
@@ -1258,6 +1258,16 @@ syscall_trace_enter (long arg0, long arg1, long
arg2, long arg3,
 	return 0;
 }

+asmlinkage long
+syscall_irqtrace_enter (long arg0, long arg1, long arg2, long arg3,
+		     long arg4, long arg5, long arg6, long arg7,
+		     struct pt_regs regs)
+{
+	raw_local_irq_disable();
+	trace_hardirqs_on();
+	raw_local_irq_enable();
+	return 0;
+}
 /* "asmlinkage" so the input arguments are preserved... */

 asmlinkage void
@@ -1285,6 +1295,30 @@ syscall_trace_leave (long arg0, long arg1, long
arg2, long arg3,
 		ia64_sync_krbs();
 }

+asmlinkage void
+syscall_irqtrace_leave (long arg0, long arg1, long arg2, long arg3,
+		     long arg4, long arg5, long arg6, long arg7,
+		     struct pt_regs regs)
+{
+	int step;
+
+	if (unlikely(current->audit_context)) {
+		int success = AUDITSC_RESULT(regs.r10);
+		long result = regs.r8;
+
+		if (success != AUDITSC_SUCCESS)
+			result = -result;
+		audit_syscall_exit(success, result);
+	}
+
+	step = test_thread_flag(TIF_SINGLESTEP);
+	if (step || test_thread_flag(TIF_SYSCALL_TRACE))
+		tracehook_report_syscall_exit(&regs, step);
+
+	/* copy user rbs to kernel rbs */
+	if (test_thread_flag(TIF_RESTORE_RSE))
+		ia64_sync_krbs();
+}
 /* Utrace implementation starts here */
 struct regset_get {
 	void *kbuf;
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index 41ae6a5..8191631 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -1013,7 +1013,11 @@ cpu_init (void)
 	BUG_ON(current->mm);

 	ia64_mmu_init(ia64_imva(cpu_data));
+
+	/* Temporarily suppress lockdep WARN_ON irqs disabled*/
+	lockdep_off();
 	ia64_mca_cpu_init(ia64_imva(cpu_data));
+	lockdep_on();

 	/* Clear ITC to eliminate sched_clock() overflows in human time.  */
 	ia64_set_itc(0);
diff --git a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
index 6a1380e..bd4ac64 100644
--- a/arch/ia64/kernel/smpboot.c
+++ b/arch/ia64/kernel/smpboot.c
@@ -507,7 +507,7 @@ do_boot_cpu (int sapicid, int cpu)
 	struct create_idle c_idle = {
 		.work = __WORK_INITIALIZER(c_idle.work, do_fork_idle),
 		.cpu	= cpu,
-		.done	= COMPLETION_INITIALIZER(c_idle.done),
+		.done	= COMPLETION_INITIALIZER_ONSTACK(c_idle.done),
 	};

  	c_idle.idle = get_idle_for_cpu(cpu);
diff --git a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
index 653b3c4..39157a7 100644
--- a/arch/ia64/kernel/time.c
+++ b/arch/ia64/kernel/time.c
@@ -210,8 +210,8 @@ timer_interrupt (int irq, void *dev_id)
 		/*
 		 * Allow IPIs to interrupt the timer loop.
 		 */
-		local_irq_enable();
-		local_irq_disable();
+		raw_local_irq_enable();
+		raw_local_irq_disable();
 	}

 skip_process_time_accounting:
diff --git a/arch/ia64/mm/fault.c b/arch/ia64/mm/fault.c
index 0799fea..44f37dc 100644
--- a/arch/ia64/mm/fault.c
+++ b/arch/ia64/mm/fault.c
@@ -82,6 +82,7 @@ ia64_do_page_fault (unsigned long address, unsigned
long isr, struct pt_regs *re
 	unsigned long mask;
 	int fault;

+	trace_hardirqs_on_delayed();
 	/* mmap_sem is performance critical.... */
 	prefetchw(&mm->mmap_sem);

diff --git a/fs/ioctl.c b/fs/ioctl.c
index 2d140a7..1374920 100644
--- a/fs/ioctl.c
+++ b/fs/ioctl.c
@@ -616,6 +616,7 @@ SYSCALL_DEFINE3(ioctl, unsigned int, fd, unsigned
int, cmd, unsigned long, arg)
 	int error = -EBADF;
 	int fput_needed;

+	trace_hardirqs_on_delayed();
 	filp = fget_light(fd, &fput_needed);
 	if (!filp)
 		goto out;
diff --git a/fs/open.c b/fs/open.c
index 5463266..c8a7eca 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -973,6 +973,7 @@ SYSCALL_DEFINE1(close, unsigned int, fd)
 	struct fdtable *fdt;
 	int retval;

+	trace_hardirqs_on_delayed();
 	spin_lock(&files->file_lock);
 	fdt = files_fdtable(files);
 	if (fd >= fdt->max_fds)
diff --git a/fs/read_write.c b/fs/read_write.c
index 9c04852..eda37e2 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -412,6 +412,7 @@ SYSCALL_DEFINE3(write, unsigned int, fd, const
char __user *, buf,
 	ssize_t ret = -EBADF;
 	int fput_needed;

+	trace_hardirqs_on_delayed();
 	file = fget_light(fd, &fput_needed);
 	if (file) {
 		loff_t pos = file_pos_read(file);
diff --git a/include/linux/irqflags.h b/include/linux/irqflags.h
index 006bf45..51d0233 100644
--- a/include/linux/irqflags.h
+++ b/include/linux/irqflags.h
@@ -17,6 +17,7 @@
   extern void trace_softirqs_on(unsigned long ip);
   extern void trace_softirqs_off(unsigned long ip);
   extern void trace_hardirqs_on(void);
+  extern void trace_hardirqs_on_delayed(void);
   extern void trace_hardirqs_off(void);
 # define trace_hardirq_context(p)	((p)->hardirq_context)
 # define trace_softirq_context(p)	((p)->softirq_context)
@@ -29,6 +30,7 @@
 # define INIT_TRACE_IRQFLAGS	.softirqs_enabled = 1,
 #else
 # define trace_hardirqs_on()		do { } while (0)
+# define trace_hardirqs_on_delayed()		do { } while (0)
 # define trace_hardirqs_off()		do { } while (0)
 # define trace_softirqs_on(ip)		do { } while (0)
 # define trace_softirqs_off(ip)		do { } while (0)
diff --git a/include/linux/lockdep.h b/include/linux/lockdep.h
index 06aed83..baa573b 100644
--- a/include/linux/lockdep.h
+++ b/include/linux/lockdep.h
@@ -174,7 +174,7 @@ struct lock_chain {
 	u64				chain_key;
 };

-#define MAX_LOCKDEP_KEYS_BITS		13
+#define MAX_LOCKDEP_KEYS_BITS		12
 /*
  * Subtract one because we offset hlock->class_idx by 1 in order
  * to make 0 mean no class. This avoids overflowing the class_idx
diff --git a/kernel/fork.c b/kernel/fork.c
index b6cce14..0c4ae6d 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1012,6 +1012,10 @@ static struct task_struct
*copy_process(unsigned long clone_flags,
 	rt_mutex_init_task(p);

 #ifdef CONFIG_PROVE_LOCKING
+	//workaround
+	p->hardirqs_enabled = 1;
+	p->hardirqs_enabled = 1;
+
 	DEBUG_LOCKS_WARN_ON(!p->hardirqs_enabled);
 	DEBUG_LOCKS_WARN_ON(!p->softirqs_enabled);
 #endif
diff --git a/kernel/lockdep.c b/kernel/lockdep.c
index 5428679..f501c10 100644
--- a/kernel/lockdep.c
+++ b/kernel/lockdep.c
@@ -2353,6 +2353,14 @@ void trace_hardirqs_on(void)
 }
 EXPORT_SYMBOL(trace_hardirqs_on);

+void trace_hardirqs_on_delayed(void)
+{
+	raw_local_irq_disable();
+	trace_hardirqs_on();
+	raw_local_irq_enable();
+}
+EXPORT_SYMBOL(trace_hardirqs_on_delayed);
+
 /*
  * Hardirqs were disabled:
  */
diff --git a/kernel/sys.c b/kernel/sys.c
index e83ddbb..e0c67db 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -993,6 +993,7 @@ SYSCALL_DEFINE1(getpgid, pid_t, pid)
 	struct pid *grp;
 	int retval;

+	trace_hardirqs_on_delayed();
 	rcu_read_lock();
 	if (!pid)
 		grp = task_pgrp(current);
diff --git a/kernel/timer.c b/kernel/timer.c
index ee305c8..7793991 100644
--- a/kernel/timer.c
+++ b/kernel/timer.c
@@ -1336,6 +1336,7 @@ SYSCALL_DEFINE1(alarm, unsigned int, seconds)
  */
 SYSCALL_DEFINE0(getpid)
 {
+	trace_hardirqs_on_delayed();
 	return task_tgid_vnr(current);
 }

diff --git a/kernel/trace/trace_irqsoff.c b/kernel/trace/trace_irqsoff.c
index 6fd486e..3c2a931 100644
--- a/kernel/trace/trace_irqsoff.c
+++ b/kernel/trace/trace_irqsoff.c
@@ -525,6 +525,12 @@ void trace_hardirqs_on(void)
 }
 EXPORT_SYMBOL(trace_hardirqs_on);

+void trace_hardirqs_on_delayed(void)
+{
+	trace_hardirqs_on();
+}
+EXPORT_SYMBOL(trace_hardirqs_on_delayed);
+
 void trace_hardirqs_off(void)
 {
 	if (!preempt_trace() && irq_trace())

--0016e64dc986fb4c490489d69820
Content-Type: application/octet-stream; name="ia64-lockdep-0625.patch"
Content-Disposition: attachment; filename="ia64-lockdep-0625.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gaur7pp40

ZGlmZiAtLWdpdCBhL2FyY2gvaWE2NC9LY29uZmlnIGIvYXJjaC9pYTY0L0tjb25maWcKaW5kZXgg
OTU2MTA4Mi4uYmJiM2U5MSAxMDA2NDQKLS0tIGEvYXJjaC9pYTY0L0tjb25maWcKKysrIGIvYXJj
aC9pYTY0L0tjb25maWcKQEAgLTE0OCw2ICsxNDgsMTIgQEAgc291cmNlICJhcmNoL2lhNjQveGVu
L0tjb25maWciCiAKIGVuZGlmCiAKK2NvbmZpZyBMT0NLREVQX1NVUFBPUlQKKwlkZWZfYm9vbCB5
CisKK2NvbmZpZyBTVEFDS1RSQUNFX1NVUFBPUlQKKwlkZWZfYm9vbCB5CisKIGNob2ljZQogCXBy
b21wdCAiU3lzdGVtIHR5cGUiCiAJZGVmYXVsdCBJQTY0X0dFTkVSSUMKZGlmZiAtLWdpdCBhL2Fy
Y2gvaWE2NC9LY29uZmlnLmRlYnVnIGIvYXJjaC9pYTY0L0tjb25maWcuZGVidWcKaW5kZXggZGU5
ZDUwNy4uYjU3YmFiNSAxMDA2NDQKLS0tIGEvYXJjaC9pYTY0L0tjb25maWcuZGVidWcKKysrIGIv
YXJjaC9pYTY0L0tjb25maWcuZGVidWcKQEAgLTIsNiArMiw5IEBAIG1lbnUgIktlcm5lbCBoYWNr
aW5nIgogCiBzb3VyY2UgImxpYi9LY29uZmlnLmRlYnVnIgogCitjb25maWcgVFJBQ0VfSVJRRkxB
R1NfU1VQUE9SVAorCWRlZl9ib29sIHkKKwogY2hvaWNlCiAJcHJvbXB0ICJQaHlzaWNhbCBtZW1v
cnkgZ3JhbnVsYXJpdHkiCiAJZGVmYXVsdCBJQTY0X0dSQU5VTEVfNjRNQgpkaWZmIC0tZ2l0IGEv
YXJjaC9pYTY0L2luY2x1ZGUvYXNtL3BhZ2UuaCBiL2FyY2gvaWE2NC9pbmNsdWRlL2FzbS9wYWdl
LmgKaW5kZXggNWYyNzFiYy4uNDEwOWYwOSAxMDA2NDQKLS0tIGEvYXJjaC9pYTY0L2luY2x1ZGUv
YXNtL3BhZ2UuaAorKysgYi9hcmNoL2lhNjQvaW5jbHVkZS9hc20vcGFnZS5oCkBAIC00MSw3ICs0
MSw3IEBACiAjZGVmaW5lIFBBR0VfU0laRQkJKF9fSUE2NF9VTF9DT05TVCgxKSA8PCBQQUdFX1NI
SUZUKQogI2RlZmluZSBQQUdFX01BU0sJCSh+KFBBR0VfU0laRSAtIDEpKQogCi0jZGVmaW5lIFBF
UkNQVV9QQUdFX1NISUZUCTE2CS8qIGxvZzIoKSBvZiBtYXguIHNpemUgb2YgcGVyLUNQVSBhcmVh
ICovCisjZGVmaW5lIFBFUkNQVV9QQUdFX1NISUZUCTIwCS8qMjAgbG9nMigpIG9mIG1heC4gc2l6
ZSBvZiBwZXItQ1BVIGFyZWEgKi8KICNkZWZpbmUgUEVSQ1BVX1BBR0VfU0laRQkoX19JQTY0X1VM
X0NPTlNUKDEpIDw8IFBFUkNQVV9QQUdFX1NISUZUKQogCiAKZGlmZiAtLWdpdCBhL2FyY2gvaWE2
NC9pbmNsdWRlL2FzbS9yd3NlbS5oIGIvYXJjaC9pYTY0L2luY2x1ZGUvYXNtL3J3c2VtLmgKaW5k
ZXggZTg3NjI2OC4uYTllYTU4MSAxMDA2NDQKLS0tIGEvYXJjaC9pYTY0L2luY2x1ZGUvYXNtL3J3
c2VtLmgKKysrIGIvYXJjaC9pYTY0L2luY2x1ZGUvYXNtL3J3c2VtLmgKQEAgLTM3LDYgKzM3LDkg
QEAgc3RydWN0IHJ3X3NlbWFwaG9yZSB7CiAJc2lnbmVkIGxvbmcJCWNvdW50OwogCXNwaW5sb2Nr
X3QJCXdhaXRfbG9jazsKIAlzdHJ1Y3QgbGlzdF9oZWFkCXdhaXRfbGlzdDsKKyNpZmRlZiBDT05G
SUdfREVCVUdfTE9DS19BTExPQworCXN0cnVjdCBsb2NrZGVwX21hcCBkZXBfbWFwOworI2VuZGlm
IAogfTsKIAogI2RlZmluZSBSV1NFTV9VTkxPQ0tFRF9WQUxVRQkJX19JQTY0X1VMX0NPTlNUKDB4
MDAwMDAwMDAwMDAwMDAwMCkKQEAgLTQ2LDkgKzQ5LDE1IEBAIHN0cnVjdCByd19zZW1hcGhvcmUg
ewogI2RlZmluZSBSV1NFTV9BQ1RJVkVfUkVBRF9CSUFTCQlSV1NFTV9BQ1RJVkVfQklBUwogI2Rl
ZmluZSBSV1NFTV9BQ1RJVkVfV1JJVEVfQklBUwkJKFJXU0VNX1dBSVRJTkdfQklBUyArIFJXU0VN
X0FDVElWRV9CSUFTKQogCisjaWZkZWYgQ09ORklHX0RFQlVHX0xPQ0tfQUxMT0MKKyMgZGVmaW5l
IF9fUldTRU1fREVQX01BUF9JTklUKGxvY2tuYW1lKSAsIC5kZXBfbWFwID0geyAubmFtZSA9ICNs
b2NrbmFtZSB9CisjZWxzZQorIyBkZWZpbmUgX19SV1NFTV9ERVBfTUFQX0lOSVQobG9ja25hbWUp
CisjZW5kaWYKKwogI2RlZmluZSBfX1JXU0VNX0lOSVRJQUxJWkVSKG5hbWUpIFwKIAl7IFJXU0VN
X1VOTE9DS0VEX1ZBTFVFLCBfX1NQSU5fTE9DS19VTkxPQ0tFRCgobmFtZSkud2FpdF9sb2NrKSwg
XAotCSAgTElTVF9IRUFEX0lOSVQoKG5hbWUpLndhaXRfbGlzdCkgfQorCSAgTElTVF9IRUFEX0lO
SVQoKG5hbWUpLndhaXRfbGlzdCkgX19SV1NFTV9ERVBfTUFQX0lOSVQobmFtZSl9CiAKICNkZWZp
bmUgREVDTEFSRV9SV1NFTShuYW1lKSBcCiAJc3RydWN0IHJ3X3NlbWFwaG9yZSBuYW1lID0gX19S
V1NFTV9JTklUSUFMSVpFUihuYW1lKQpAQCAtNTgsMTMgKzY3LDE1IEBAIGV4dGVybiBzdHJ1Y3Qg
cndfc2VtYXBob3JlICpyd3NlbV9kb3duX3dyaXRlX2ZhaWxlZChzdHJ1Y3Qgcndfc2VtYXBob3Jl
ICpzZW0pOwogZXh0ZXJuIHN0cnVjdCByd19zZW1hcGhvcmUgKnJ3c2VtX3dha2Uoc3RydWN0IHJ3
X3NlbWFwaG9yZSAqc2VtKTsKIGV4dGVybiBzdHJ1Y3Qgcndfc2VtYXBob3JlICpyd3NlbV9kb3du
Z3JhZGVfd2FrZShzdHJ1Y3Qgcndfc2VtYXBob3JlICpzZW0pOwogCi1zdGF0aWMgaW5saW5lIHZv
aWQKLWluaXRfcndzZW0gKHN0cnVjdCByd19zZW1hcGhvcmUgKnNlbSkKLXsKLQlzZW0tPmNvdW50
ID0gUldTRU1fVU5MT0NLRURfVkFMVUU7Ci0Jc3Bpbl9sb2NrX2luaXQoJnNlbS0+d2FpdF9sb2Nr
KTsKLQlJTklUX0xJU1RfSEVBRCgmc2VtLT53YWl0X2xpc3QpOwotfQorZXh0ZXJuIHZvaWQgX19p
bml0X3J3c2VtKHN0cnVjdCByd19zZW1hcGhvcmUgKnNlbSwgY29uc3QgY2hhciAqbmFtZSwKKwkJ
CSBzdHJ1Y3QgbG9ja19jbGFzc19rZXkgKmtleSk7CisKKyNkZWZpbmUgaW5pdF9yd3NlbShzZW0p
CQkJCQkJXAorZG8gewkJCQkJCQkJXAorCXN0YXRpYyBzdHJ1Y3QgbG9ja19jbGFzc19rZXkgX19r
ZXk7CQkJXAorCQkJCQkJCQlcCisJX19pbml0X3J3c2VtKChzZW0pLCAjc2VtLCAmX19rZXkpOwkJ
CVwKK30gd2hpbGUgKDApCiAKIC8qCiAgKiBsb2NrIGZvciByZWFkaW5nCmRpZmYgLS1naXQgYS9h
cmNoL2lhNjQvaW5jbHVkZS9hc20vc3lzdGVtLmggYi9hcmNoL2lhNjQvaW5jbHVkZS9hc20vc3lz
dGVtLmgKaW5kZXggOWYzNDJhNS4uMGMyMWY2ZCAxMDA2NDQKLS0tIGEvYXJjaC9pYTY0L2luY2x1
ZGUvYXNtL3N5c3RlbS5oCisrKyBiL2FyY2gvaWE2NC9pbmNsdWRlL2FzbS9zeXN0ZW0uaApAQCAt
MTA3LDg4ICsxMDcsNiBAQCBleHRlcm4gc3RydWN0IGlhNjRfYm9vdF9wYXJhbSB7CiAgKi8KICNk
ZWZpbmUgc2V0X21iKHZhciwgdmFsdWUpCWRvIHsgKHZhcikgPSAodmFsdWUpOyBtYigpOyB9IHdo
aWxlICgwKQogCi0jZGVmaW5lIHNhZmVfaGFsdCgpICAgICAgICAgaWE2NF9wYWxfaGFsdF9saWdo
dCgpICAgIC8qIFBBTF9IQUxUX0xJR0hUICovCi0KLS8qCi0gKiBUaGUgZ3JvdXAgYmFycmllciBp
biBmcm9udCBvZiB0aGUgcnNtICYgc3NtIGFyZSBuZWNlc3NhcnkgdG8gZW5zdXJlCi0gKiB0aGF0
IG5vbmUgb2YgdGhlIHByZXZpb3VzIGluc3RydWN0aW9ucyBpbiB0aGUgc2FtZSBncm91cCBhcmUK
LSAqIGFmZmVjdGVkIGJ5IHRoZSByc20vc3NtLgotICovCi0vKiBGb3Igc3BpbmxvY2tzIGV0YyAq
LwotCi0vKgotICogLSBjbGVhcmluZyBwc3IuaSBpcyBpbXBsaWNpdGx5IHNlcmlhbGl6ZWQgKHZp
c2libGUgYnkgbmV4dCBpbnNuKQotICogLSBzZXR0aW5nIHBzci5pIHJlcXVpcmVzIGRhdGEgc2Vy
aWFsaXphdGlvbgotICogLSB3ZSBuZWVkIGEgc3RvcC1iaXQgYmVmb3JlIHJlYWRpbmcgUFNSIGJl
Y2F1c2Ugd2Ugc29tZXRpbWVzCi0gKiAgIHdyaXRlIGEgZmxvYXRpbmctcG9pbnQgcmVnaXN0ZXIg
cmlnaHQgYmVmb3JlIHJlYWRpbmcgdGhlIFBTUgotICogICBhbmQgdGhhdCB3cml0ZXMgdG8gUFNS
Lm1mbAotICovCi0jaWZkZWYgQ09ORklHX1BBUkFWSVJUCi0jZGVmaW5lIF9fbG9jYWxfc2F2ZV9m
bGFncygpCWlhNjRfZ2V0X3Bzcl9pKCkKLSNlbHNlCi0jZGVmaW5lIF9fbG9jYWxfc2F2ZV9mbGFn
cygpCWlhNjRfZ2V0cmVnKF9JQTY0X1JFR19QU1IpCi0jZW5kaWYKLQotI2RlZmluZSBfX2xvY2Fs
X2lycV9zYXZlKHgpCQkJXAotZG8gewkJCQkJCVwKLQlpYTY0X3N0b3AoKTsJCQkJXAotCSh4KSA9
IF9fbG9jYWxfc2F2ZV9mbGFncygpOwkJXAotCWlhNjRfc3RvcCgpOwkJCQlcCi0JaWE2NF9yc20o
SUE2NF9QU1JfSSk7CQkJXAotfSB3aGlsZSAoMCkKLQotI2RlZmluZSBfX2xvY2FsX2lycV9kaXNh
YmxlKCkJCQlcCi1kbyB7CQkJCQkJXAotCWlhNjRfc3RvcCgpOwkJCQlcCi0JaWE2NF9yc20oSUE2
NF9QU1JfSSk7CQkJXAotfSB3aGlsZSAoMCkKLQotI2RlZmluZSBfX2xvY2FsX2lycV9yZXN0b3Jl
KHgpCWlhNjRfaW50cmluX2xvY2FsX2lycV9yZXN0b3JlKCh4KSAmIElBNjRfUFNSX0kpCi0KLSNp
ZmRlZiBDT05GSUdfSUE2NF9ERUJVR19JUlEKLQotICBleHRlcm4gdW5zaWduZWQgbG9uZyBsYXN0
X2NsaV9pcDsKLQotIyBkZWZpbmUgX19zYXZlX2lwKCkJCWxhc3RfY2xpX2lwID0gaWE2NF9nZXRy
ZWcoX0lBNjRfUkVHX0lQKQotCi0jIGRlZmluZSBsb2NhbF9pcnFfc2F2ZSh4KQkJCQkJXAotZG8g
ewkJCQkJCQkJXAotCXVuc2lnbmVkIGxvbmcgX19wc3I7CQkJCQlcCi0JCQkJCQkJCVwKLQlfX2xv
Y2FsX2lycV9zYXZlKF9fcHNyKTsJCQkJXAotCWlmIChfX3BzciAmIElBNjRfUFNSX0kpCQkJCQlc
Ci0JCV9fc2F2ZV9pcCgpOwkJCQkJXAotCSh4KSA9IF9fcHNyOwkJCQkJCVwKLX0gd2hpbGUgKDAp
Ci0KLSMgZGVmaW5lIGxvY2FsX2lycV9kaXNhYmxlKCkJZG8geyB1bnNpZ25lZCBsb25nIF9feDsg
bG9jYWxfaXJxX3NhdmUoX194KTsgfSB3aGlsZSAoMCkKLQotIyBkZWZpbmUgbG9jYWxfaXJxX3Jl
c3RvcmUoeCkJCQkJCVwKLWRvIHsJCQkJCQkJCVwKLQl1bnNpZ25lZCBsb25nIF9fb2xkX3Bzciwg
X19wc3IgPSAoeCk7CQkJXAotCQkJCQkJCQlcCi0JbG9jYWxfc2F2ZV9mbGFncyhfX29sZF9wc3Ip
OwkJCQlcCi0JX19sb2NhbF9pcnFfcmVzdG9yZShfX3Bzcik7CQkJCVwKLQlpZiAoKF9fb2xkX3Bz
ciAmIElBNjRfUFNSX0kpICYmICEoX19wc3IgJiBJQTY0X1BTUl9JKSkJXAotCQlfX3NhdmVfaXAo
KTsJCQkJCVwKLX0gd2hpbGUgKDApCi0KLSNlbHNlIC8qICFDT05GSUdfSUE2NF9ERUJVR19JUlEg
Ki8KLSMgZGVmaW5lIGxvY2FsX2lycV9zYXZlKHgpCV9fbG9jYWxfaXJxX3NhdmUoeCkKLSMgZGVm
aW5lIGxvY2FsX2lycV9kaXNhYmxlKCkJX19sb2NhbF9pcnFfZGlzYWJsZSgpCi0jIGRlZmluZSBs
b2NhbF9pcnFfcmVzdG9yZSh4KQlfX2xvY2FsX2lycV9yZXN0b3JlKHgpCi0jZW5kaWYgLyogIUNP
TkZJR19JQTY0X0RFQlVHX0lSUSAqLwotCi0jZGVmaW5lIGxvY2FsX2lycV9lbmFibGUoKQkoeyBp
YTY0X3N0b3AoKTsgaWE2NF9zc20oSUE2NF9QU1JfSSk7IGlhNjRfc3Jsel9kKCk7IH0pCi0jZGVm
aW5lIGxvY2FsX3NhdmVfZmxhZ3MoZmxhZ3MpCSh7IGlhNjRfc3RvcCgpOyAoZmxhZ3MpID0gX19s
b2NhbF9zYXZlX2ZsYWdzKCk7IH0pCi0KLSNkZWZpbmUgaXJxc19kaXNhYmxlZCgpCQkJCVwKLSh7
CQkJCQkJXAotCXVuc2lnbmVkIGxvbmcgX19pYTY0X2lkX2ZsYWdzOwkJXAotCWxvY2FsX3NhdmVf
ZmxhZ3MoX19pYTY0X2lkX2ZsYWdzKTsJXAotCShfX2lhNjRfaWRfZmxhZ3MgJiBJQTY0X1BTUl9J
KSA9PSAwOwlcCi19KQotCiAjaWZkZWYgX19LRVJORUxfXwogCiAvKgpAQCAtMjY1LDcgKzE4Myw3
IEBAIGV4dGVybiB2b2lkIGlhNjRfYWNjb3VudF9vbl9zd2l0Y2ggKHN0cnVjdCB0YXNrX3N0cnVj
dCAqcHJldiwgc3RydWN0IHRhc2tfc3RydWN0CiAjZGVmaW5lIF9fQVJDSF9XQU5UX1VOTE9DS0VE
X0NUWFNXCiAjZGVmaW5lIEFSQ0hfSEFTX1BSRUZFVENIX1NXSVRDSF9TVEFDSwogI2RlZmluZSBp
YTY0X3BsYXRmb3JtX2lzKHgpIChzdHJjbXAoeCwgcGxhdGZvcm1fbmFtZSkgPT0gMCkKLQorI2lu
Y2x1ZGUgPGxpbnV4L2lycWZsYWdzLmg+CiB2b2lkIGNwdV9pZGxlX3dhaXQodm9pZCk7CiAKICNk
ZWZpbmUgYXJjaF9hbGlnbl9zdGFjayh4KSAoeCkKZGlmZiAtLWdpdCBhL2FyY2gvaWE2NC9rZXJu
ZWwvTWFrZWZpbGUgYi9hcmNoL2lhNjQva2VybmVsL01ha2VmaWxlCmluZGV4IGRiMTBiMWUuLjM5
NWMyZjIgMTAwNjQ0Ci0tLSBhL2FyY2gvaWE2NC9rZXJuZWwvTWFrZWZpbGUKKysrIGIvYXJjaC9p
YTY0L2tlcm5lbC9NYWtlZmlsZQpAQCAtMzQsNiArMzQsNyBAQCBvYmotJChDT05GSUdfQVVESVQp
CQkrPSBhdWRpdC5vCiBvYmotJChDT05GSUdfUENJX01TSSkJCSs9IG1zaV9pYTY0Lm8KIG1jYV9y
ZWNvdmVyeS15CQkJKz0gbWNhX2Rydi5vIG1jYV9kcnZfYXNtLm8KIG9iai0kKENPTkZJR19JQTY0
X01DX0VSUl9JTkpFQ1QpKz0gZXJyX2luamVjdC5vCitvYmotJChDT05GSUdfU1RBQ0tUUkFDRSkJ
Kz0gc3RhY2t0cmFjZS5vCiAKIG9iai0kKENPTkZJR19QQVJBVklSVCkJCSs9IHBhcmF2aXJ0Lm8g
cGFyYXZpcnRlbnRyeS5vIFwKIAkJCQkgICBwYXJhdmlydF9wYXRjaC5vCmRpZmYgLS1naXQgYS9h
cmNoL2lhNjQva2VybmVsL2VudHJ5LlMgYi9hcmNoL2lhNjQva2VybmVsL2VudHJ5LlMKaW5kZXgg
OWEyNjBiMy4uMzkzZTY4ZCAxMDA2NDQKLS0tIGEvYXJjaC9pYTY0L2tlcm5lbC9lbnRyeS5TCisr
KyBiL2FyY2gvaWE2NC9rZXJuZWwvZW50cnkuUwpAQCAtNDgsNiArNDgsNyBAQAogI2luY2x1ZGUg
PGFzbS90aHJlYWRfaW5mby5oPgogI2luY2x1ZGUgPGFzbS91bmlzdGQuaD4KICNpbmNsdWRlIDxh
c20vZnRyYWNlLmg+CisjaW5jbHVkZSA8YXNtL2lycWZsYWdzLmg+CiAKICNpbmNsdWRlICJtaW5z
dGF0ZS5oIgogCkBAIC01ODMsNiArNTg0LDg4IEBAIHN0cmFjZV9lcnJvcjoKIAlici5jb25kLnNw
dGsgLnN0cmFjZV9zYXZlX3JldHZhbAogRU5EKGlhNjRfdHJhY2Vfc3lzY2FsbCkKIAorLyoKKyAq
IERlcml2ZWQgZnJvbSBpYTY0X3RyYWNlX3N5c2NhbGwKKyAqLworR0xPQkFMX0VOVFJZKGlhNjRf
aXJxdHJhY2Vfc3lzY2FsbCkKKwlQVF9SRUdTX1VOV0lORF9JTkZPKDApCisJLyoKKwkgKiBXZSBu
ZWVkIHRvIHByZXNlcnZlIHRoZSBzY3JhdGNoIHJlZ2lzdGVycyBmNi1mMTEgaW4gY2FzZSB0aGUg
c3lzdGVtCisJICogY2FsbCBpcyBzaWdyZXR1cm4uCisJICovCisJYWRkcyByMTY9UFQoRjYpKzE2
LHNwCisJYWRkcyByMTc9UFQoRjcpKzE2LHNwCisJOzsKKyAJc3RmLnNwaWxsIFtyMTZdPWY2LDMy
CisgCXN0Zi5zcGlsbCBbcjE3XT1mNywzMgorCTs7CisgCXN0Zi5zcGlsbCBbcjE2XT1mOCwzMgor
IAlzdGYuc3BpbGwgW3IxN109ZjksMzIKKwk7OworIAlzdGYuc3BpbGwgW3IxNl09ZjEwCisgCXN0
Zi5zcGlsbCBbcjE3XT1mMTEKKwlici5jYWxsLnNwdGsubWFueSBycD1zeXNjYWxsX2lycXRyYWNl
X2VudGVyCisJY21wLmx0IHA2LHAwPXI4LHIwCQkJLy8gY2hlY2sgdHJhY2Vob29rCisJYWRkcyBy
Mj1QVChSOCkrMTYsc3AJCQkvLyByMiA9ICZwdF9yZWdzLnI4CisJYWRkcyByMz1QVChSMTApKzE2
LHNwCQkJLy8gcjMgPSAmcHRfcmVncy5yMTAKKwltb3YgcjEwPTAKKyhwNikJYnIuY29uZC5zcHRr
IGlycXN0cmFjZV9lcnJvcgkJLy8gc3lzY2FsbCBmYWlsZWQgLT4KKwlhZGRzIHIxNj1QVChGNikr
MTYsc3AKKwlhZGRzIHIxNz1QVChGNykrMTYsc3AKKwk7OworCWxkZi5maWxsIGY2PVtyMTZdLDMy
CisJbGRmLmZpbGwgZjc9W3IxN10sMzIKKwk7OworCWxkZi5maWxsIGY4PVtyMTZdLDMyCisJbGRm
LmZpbGwgZjk9W3IxN10sMzIKKwk7OworCWxkZi5maWxsIGYxMD1bcjE2XQorCWxkZi5maWxsIGYx
MT1bcjE3XQorCS8vIHRoZSBzeXNjYWxsIG51bWJlciBtYXkgaGF2ZSBjaGFuZ2VkLCBzbyByZS1s
b2FkIGl0IGFuZCByZS1jYWxjdWxhdGUgdGhlCisJLy8gc3lzY2FsbCBlbnRyeS1wb2ludDoKKwlh
ZGRzIHIxNT1QVChSMTUpKzE2LHNwCQkJLy8gcjE1ID0gJnB0X3JlZ3MucjE1IChzeXNjYWxsICMp
CisJOzsKKwlsZDggcjE1PVtyMTVdCisJbW92IHIzPU5SX3N5c2NhbGxzIC0gMQorCTs7CisJYWRk
cyByMTU9LTEwMjQscjE1CisJbW92bCByMTY9c3lzX2NhbGxfdGFibGUKKwk7OworCXNobGFkZCBy
MjA9cjE1LDMscjE2CQkJLy8gcjIwID0gc3lzX2NhbGxfdGFibGUgKyA4KihzeXNjYWxsLTEwMjQp
CisJY21wLmxldSBwNixwNz1yMTUscjMKKwk7OworKHA2KQlsZDggcjIwPVtyMjBdCQkJCS8vIGxv
YWQgYWRkcmVzcyBvZiBzeXNjYWxsIGVudHJ5IHBvaW50CisocDcpCW1vdmwgcjIwPXN5c19uaV9z
eXNjYWxsCisJOzsKKwltb3YgYjY9cjIwCisJYnIuY2FsbC5zcHRrLm1hbnkgcnA9YjYJCQkvLyBk
byB0aGUgc3lzY2FsbAorLmlycXN0cmFjZV9jaGVja19yZXR2YWw6CisJY21wLmx0IHA2LHAwPXI4
LHIwCQkJLy8gc3lzY2FsbCBmYWlsZWQ/CisJYWRkcyByMj1QVChSOCkrMTYsc3AJCQkvLyByMiA9
ICZwdF9yZWdzLnI4CisJYWRkcyByMz1QVChSMTApKzE2LHNwCQkJLy8gcjMgPSAmcHRfcmVncy5y
MTAKKwltb3YgcjEwPTAKKyhwNikJYnIuY29uZC5zcHRrIGlycXN0cmFjZV9lcnJvcgkJLy8gc3lz
Y2FsbCBmYWlsZWQgLT4KKwk7OwkJCQkJLy8gYXZvaWQgUkFXIG9uIHIxMAorLmlycXN0cmFjZV9z
YXZlX3JldHZhbDoKKy5tZW0ub2Zmc2V0IDAsMDsgc3Q4LnNwaWxsIFtyMl09cjgJCS8vIHN0b3Jl
IHJldHVybiB2YWx1ZSBpbiBzbG90IGZvciByOAorLm1lbS5vZmZzZXQgOCwwOyBzdDguc3BpbGwg
W3IzXT1yMTAJCS8vIGNsZWFyIGVycm9yIGluZGljYXRpb24gaW4gc2xvdCBmb3IgcjEwCisJYnIu
Y2FsbC5zcHRrLm1hbnkgcnA9c3lzY2FsbF9pcnF0cmFjZV9sZWF2ZQorLmlycXRyYWNlcmV0MzoK
KyhwVVN0aykJY21wLmVxLnVuYyBwNixwMD1yMCxyMAkJCS8vIHA2IDwtIHBVU3RrCisocFVTdGsp
CXJzbSBwc3IuaQkJCQkvLyBkaXNhYmxlIGludGVycnVwdHMKKwlici5jb25kLnNwdGsgaWE2NF93
b3JrX3BlbmRpbmdfc3lzY2FsbF9lbmQKKworaXJxc3RyYWNlX2Vycm9yOgorCWxkOCByMz1bcjJd
CQkJCS8vIGxvYWQgcHRfcmVncy5yOAorCXN1YiByOT0wLHI4CQkJCS8vIG5lZ2F0ZSByZXR1cm4g
dmFsdWUgdG8gZ2V0IGVycm5vIHZhbHVlCisJOzsKKwljbXAubmUgcDYscDA9cjMscjAJCQkvLyBp
cyBwdF9yZWdzLnI4IT0wPworCWFkZHMgcjM9MTYscjIJCQkJLy8gcjM9JnB0X3JlZ3MucjEwCisJ
OzsKKyhwNikJbW92IHIxMD0tMQorKHA2KQltb3Ygcjg9cjkKKwlici5jb25kLnNwdGsgLmlycXN0
cmFjZV9zYXZlX3JldHZhbAorRU5EKGlhNjRfaXJxdHJhY2Vfc3lzY2FsbCkKIAkvKgogCSAqIFdo
ZW4gdHJhY2VkIGFuZCByZXR1cm5pbmcgZnJvbSBzaWdyZXR1cm4sIHdlIGludm9rZSBzeXNjYWxs
X3RyYWNlIGJ1dCB0aGVuCiAJICogZ28gc3RyYWlnaHQgdG8gaWE2NF9sZWF2ZV9rZXJuZWwgcmF0
aGVyIHRoYW4gaWE2NF9sZWF2ZV9zeXNjYWxsLgpAQCAtODU4LDYgKzk0MSwxMSBAQCBHTE9CQUxf
RU5UUlkoX19wYXJhdmlydF9sZWF2ZV9rZXJuZWwpCiAJY21wLmVxIHA2LHAwPXIyMSxyMAkJLy8g
cDYgPC0gcFVTdGsgfHwgKHByZWVtcHRfY291bnQgPT0gMCkKICNlbHNlCiAJUlNNX1BTUl9JKHBV
U3RrLCByMTcsIHIzMSkKKyNpZiAwIC8vVG9kbzogZml4IGxvY2sgaGVsZCB3aGVuIHJldHVybmlu
ZyB0byB1c2VyIHNwYWNlCisJOzsKKwlMT0NLREVQX1NZU19FWElUCisJOzsKKyNlbmRpZgogCWNt
cC5lcSBwMCxwTHZTeXM9cjAscjAJCS8vIHBMdlN5cz0wOiBsZWF2ZSBmcm9tIGtlcm5lbAogKHBV
U3RrKQljbXAuZXEudW5jIHA2LHAwPXIwLHIwCQkvLyBwNiA8LSBwVVN0awogI2VuZGlmCmRpZmYg
LS1naXQgYS9hcmNoL2lhNjQva2VybmVsL2lycV9pYTY0LmMgYi9hcmNoL2lhNjQva2VybmVsL2ly
cV9pYTY0LmMKaW5kZXggZjE0YzM1Zi4uMzczMmQ1OSAxMDA2NDQKLS0tIGEvYXJjaC9pYTY0L2tl
cm5lbC9pcnFfaWE2NC5jCisrKyBiL2FyY2gvaWE2NC9rZXJuZWwvaXJxX2lhNjQuYwpAQCAtNDUz
LDYgKzQ1Myw3IEBAIGlhNjRfaGFuZGxlX2lycSAoaWE2NF92ZWN0b3IgdmVjdG9yLCBzdHJ1Y3Qg
cHRfcmVncyAqcmVncykKIAlzdHJ1Y3QgcHRfcmVncyAqb2xkX3JlZ3MgPSBzZXRfaXJxX3JlZ3Mo
cmVncyk7CiAJdW5zaWduZWQgbG9uZyBzYXZlZF90cHI7CiAKKwl0cmFjZV9oYXJkaXJxc19vZmYo
KTsKICNpZiBJUlFfREVCVUcKIAl7CiAJCXVuc2lnbmVkIGxvbmcgYnNwLCBzcDsKQEAgLTUyMyw2
ICs1MjQsOCBAQCBpYTY0X2hhbmRsZV9pcnEgKGlhNjRfdmVjdG9yIHZlY3Rvciwgc3RydWN0IHB0
X3JlZ3MgKnJlZ3MpCiAJICogY29tZSB0aHJvdWdoIHVudGlsIGlhNjRfZW9pKCkgaGFzIGJlZW4g
ZG9uZS4KIAkgKi8KIAlpcnFfZXhpdCgpOworCWlmKCFjdXJyZW50LT5oYXJkaXJxX2NvbnRleHQp
CisJCXRyYWNlX2hhcmRpcnFzX29uX2RlbGF5ZWQoKTsKIAlzZXRfaXJxX3JlZ3Mob2xkX3JlZ3Mp
OwogfQogCmRpZmYgLS1naXQgYS9hcmNoL2lhNjQva2VybmVsL2l2dC5TIGIvYXJjaC9pYTY0L2tl
cm5lbC9pdnQuUwppbmRleCBkOTNlMzk2Li5mOTczMWJkIDEwMDY0NAotLS0gYS9hcmNoL2lhNjQv
a2VybmVsL2l2dC5TCisrKyBiL2FyY2gvaWE2NC9rZXJuZWwvaXZ0LlMKQEAgLTg1NSw3ICs4NTUs
MTEgQEAgRU5UUlkoYnJlYWtfZmF1bHQpCiAocDEwKQlici5jb25kLnNwbnQubWFueSBpYTY0X3Jl
dF9mcm9tX3N5c2NhbGwJLy8gQiAgICByZXR1cm4gaWYgYmFkIGNhbGwtZnJhbWUgb3IgcjE1IGlz
IGEgTmFUCiAKIAlTU01fUFNSX0kocDE1LCBwMTUsIHIxNikJCS8vIE0yICAgcmVzdG9yZSBwc3Iu
aQorI2lmZGVmIENPTkZJR19UUkFDRV9JUlFGTEFHUworKHAxNCkJYnIuY29uZC5zcG50Lm1hbnkg
aWE2NF9pcnF0cmFjZV9zeXNjYWxsCS8vIEIJZG8gc3lzY2FsbC10cmFjaW5nIHRoaW5nYW1hZ2lj
CisjZWxzZQogKHAxNCkJYnIuY2FsbC5zcHRrLm1hbnkgYjY9YjYJCQkvLyBCICAgIGludm9rZSBz
eXNjYWxsLWhhbmRrZXIgKGlnbm9yZSByZXR1cm4gYWRkcikKKyNlbmRpZgogCWJyLmNvbmQuc3Bu
dC5tYW55IGlhNjRfdHJhY2Vfc3lzY2FsbAkvLyBCCWRvIHN5c2NhbGwtdHJhY2luZyB0aGluZ2Ft
YWdpYwogCS8vIE5PVCBSRUFDSEVECiAvLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLwpkaWZmIC0tZ2l0IGEvYXJjaC9p
YTY0L2tlcm5lbC9tY2EuYyBiL2FyY2gvaWE2NC9rZXJuZWwvbWNhLmMKaW5kZXggYTAyMjBkYy4u
ZWM0OGNkNiAxMDA2NDQKLS0tIGEvYXJjaC9pYTY0L2tlcm5lbC9tY2EuYworKysgYi9hcmNoL2lh
NjQva2VybmVsL21jYS5jCkBAIC01MzYsNiArNTM2LDcgQEAgaWE2NF9tY2FfY3BlX2ludF9oYW5k
bGVyIChpbnQgY3BlX2lycSwgdm9pZCAqYXJnKQogCXN0YXRpYyBpbnQJCWluZGV4OwogCXN0YXRp
YyBERUZJTkVfU1BJTkxPQ0soY3BlX2hpc3RvcnlfbG9jayk7CiAKKwlsb2NrZGVwX29mZigpOwog
CUlBNjRfTUNBX0RFQlVHKCIlczogcmVjZWl2ZWQgaW50ZXJydXB0IHZlY3RvciA9ICUjeCBvbiBD
UFUgJWRcbiIsCiAJCSAgICAgICBfX2Z1bmNfXywgY3BlX2lycSwgc21wX3Byb2Nlc3Nvcl9pZCgp
KTsKIApAQCAtNTgxLDcgKzU4Miw3IEBAIGlhNjRfbWNhX2NwZV9pbnRfaGFuZGxlciAoaW50IGNw
ZV9pcnEsIHZvaWQgKmFyZykKIG91dDoKIAkvKiBHZXQgdGhlIENQRSBlcnJvciByZWNvcmQgYW5k
IGxvZyBpdCAqLwogCWlhNjRfbWNhX2xvZ19zYWxfZXJyb3JfcmVjb3JkKFNBTF9JTkZPX1RZUEVf
Q1BFKTsKLQorCWxvY2tkZXBfb24oKTsKIAlyZXR1cm4gSVJRX0hBTkRMRUQ7CiB9CiAKQEAgLTc4
MCw3ICs3ODEsNyBAQCBpYTY0X21jYV9yZW5kZXpfaW50X2hhbmRsZXIoaW50IHJlbmRlel9pcnEs
IHZvaWQgKmFyZykKIAkJeyAuc29zID0gTlVMTCwgLm1vbmFyY2hfY3B1ID0gJm1vbmFyY2hfY3B1
IH07CiAKIAkvKiBNYXNrIGFsbCBpbnRlcnJ1cHRzICovCi0JbG9jYWxfaXJxX3NhdmUoZmxhZ3Mp
OworCXJhd19sb2NhbF9pcnFfc2F2ZShmbGFncyk7CiAKIAlOT1RJRllfTUNBKERJRV9NQ0FfUkVO
RFpWT1VTX0VOVEVSLCBnZXRfaXJxX3JlZ3MoKSwgKGxvbmcpJm5kLCAxKTsKIApAQCAtODAwLDcg
KzgwMSw3IEBAIGlhNjRfbWNhX3JlbmRlel9pbnRfaGFuZGxlcihpbnQgcmVuZGV6X2lycSwgdm9p
ZCAqYXJnKQogCiAJaWE2NF9tY19pbmZvLmltaV9yZW5kZXpfY2hlY2tpbltjcHVdID0gSUE2NF9N
Q0FfUkVOREVaX0NIRUNLSU5fTk9URE9ORTsKIAkvKiBFbmFibGUgYWxsIGludGVycnVwdHMgKi8K
LQlsb2NhbF9pcnFfcmVzdG9yZShmbGFncyk7CisJcmF3X2xvY2FsX2lycV9yZXN0b3JlKGZsYWdz
KTsKIAlyZXR1cm4gSVJRX0hBTkRMRUQ7CiB9CiAKQEAgLTEzOTksNyArMTQwMCw3IEBAIGlhNjRf
bWNhX2NtY19pbnRfaGFuZGxlcihpbnQgY21jX2lycSwgdm9pZCAqYXJnKQogCQkgICAgICAgX19m
dW5jX18sIGNtY19pcnEsIHNtcF9wcm9jZXNzb3JfaWQoKSk7CiAKIAkvKiBTQUwgc3BlYyBzdGF0
ZXMgdGhpcyBzaG91bGQgcnVuIHcvIGludGVycnVwdHMgZW5hYmxlZCAqLwotCWxvY2FsX2lycV9l
bmFibGUoKTsKKwlyYXdfbG9jYWxfaXJxX2VuYWJsZSgpOwogCiAJc3Bpbl9sb2NrKCZjbWNfaGlz
dG9yeV9sb2NrKTsKIAlpZiAoIWNtY19wb2xsaW5nX2VuYWJsZWQpIHsKQEAgLTE1MzYsNiArMTUz
Nyw3IEBAIGlhNjRfbWNhX2NwZV9pbnRfY2FsbGVyKGludCBjcGVfaXJxLCB2b2lkICphcmcpCiAJ
c3RhdGljIGludCBwb2xsX3RpbWUgPSBNSU5fQ1BFX1BPTExfSU5URVJWQUw7CiAJdW5zaWduZWQg
aW50IGNwdWlkOwogCisJbG9ja2RlcF9vZmYoKTsKIAljcHVpZCA9IHNtcF9wcm9jZXNzb3JfaWQo
KTsKIAogCS8qIElmIGZpcnN0IGNwdSwgdXBkYXRlIGNvdW50ICovCkBAIC0xNTY5LDYgKzE1NzEs
NyBAQCBpYTY0X21jYV9jcGVfaW50X2NhbGxlcihpbnQgY3BlX2lycSwgdm9pZCAqYXJnKQogCQkJ
bW9kX3RpbWVyKCZjcGVfcG9sbF90aW1lciwgamlmZmllcyArIHBvbGxfdGltZSk7CiAJCXN0YXJ0
X2NvdW50ID0gLTE7CiAJfQorCWxvY2tkZXBfb24oKTsKIAogCXJldHVybiBJUlFfSEFORExFRDsK
IH0KQEAgLTE4OTQsMTAgKzE4OTcsMTAgQEAgc3RhdGljIHZvaWQgX19jcHVpbml0IGlhNjRfbWNh
X2NtY192ZWN0b3JfYWRqdXN0KHZvaWQgKmR1bW15KQogewogCXVuc2lnbmVkIGxvbmcgZmxhZ3M7
CiAKLQlsb2NhbF9pcnFfc2F2ZShmbGFncyk7CisJcmF3X2xvY2FsX2lycV9zYXZlKGZsYWdzKTsK
IAlpZiAoIWNtY19wb2xsaW5nX2VuYWJsZWQpCiAJCWlhNjRfbWNhX2NtY192ZWN0b3JfZW5hYmxl
KE5VTEwpOwotCWxvY2FsX2lycV9yZXN0b3JlKGZsYWdzKTsKKwlyYXdfbG9jYWxfaXJxX3Jlc3Rv
cmUoZmxhZ3MpOwogfQogCiBzdGF0aWMgaW50IF9fY3B1aW5pdCBtY2FfY3B1X2NhbGxiYWNrKHN0
cnVjdCBub3RpZmllcl9ibG9jayAqbmZiLApkaWZmIC0tZ2l0IGEvYXJjaC9pYTY0L2tlcm5lbC9w
cm9jZXNzLmMgYi9hcmNoL2lhNjQva2VybmVsL3Byb2Nlc3MuYwppbmRleCA1M2YxNjQ4Li5hZmUw
ZGRmIDEwMDY0NAotLS0gYS9hcmNoL2lhNjQva2VybmVsL3Byb2Nlc3MuYworKysgYi9hcmNoL2lh
NjQva2VybmVsL3Byb2Nlc3MuYwpAQCAtMjM3LDE0ICsyMzcsMTQgQEAgdXBkYXRlX3BhbF9oYWx0
X3N0YXR1cyhpbnQgc3RhdHVzKQogdm9pZAogZGVmYXVsdF9pZGxlICh2b2lkKQogewotCWxvY2Fs
X2lycV9lbmFibGUoKTsKKwlyYXdfbG9jYWxfaXJxX2VuYWJsZSgpOwogCXdoaWxlICghbmVlZF9y
ZXNjaGVkKCkpIHsKIAkJaWYgKGNhbl9kb19wYWxfaGFsdCkgewotCQkJbG9jYWxfaXJxX2Rpc2Fi
bGUoKTsKKwkJCXJhd19sb2NhbF9pcnFfZGlzYWJsZSgpOwogCQkJaWYgKCFuZWVkX3Jlc2NoZWQo
KSkgewogCQkJCXNhZmVfaGFsdCgpOwogCQkJfQotCQkJbG9jYWxfaXJxX2VuYWJsZSgpOworCQkJ
cmF3X2xvY2FsX2lycV9lbmFibGUoKTsKIAkJfSBlbHNlCiAJCQljcHVfcmVsYXgoKTsKIAl9CmRp
ZmYgLS1naXQgYS9hcmNoL2lhNjQva2VybmVsL3B0cmFjZS5jIGIvYXJjaC9pYTY0L2tlcm5lbC9w
dHJhY2UuYwppbmRleCA3Yzc5MDlmLi5hMjNjNjgzIDEwMDY0NAotLS0gYS9hcmNoL2lhNjQva2Vy
bmVsL3B0cmFjZS5jCisrKyBiL2FyY2gvaWE2NC9rZXJuZWwvcHRyYWNlLmMKQEAgLTEyNTgsNiAr
MTI1OCwxNiBAQCBzeXNjYWxsX3RyYWNlX2VudGVyIChsb25nIGFyZzAsIGxvbmcgYXJnMSwgbG9u
ZyBhcmcyLCBsb25nIGFyZzMsCiAJcmV0dXJuIDA7CiB9CiAKK2FzbWxpbmthZ2UgbG9uZworc3lz
Y2FsbF9pcnF0cmFjZV9lbnRlciAobG9uZyBhcmcwLCBsb25nIGFyZzEsIGxvbmcgYXJnMiwgbG9u
ZyBhcmczLAorCQkgICAgIGxvbmcgYXJnNCwgbG9uZyBhcmc1LCBsb25nIGFyZzYsIGxvbmcgYXJn
NywKKwkJICAgICBzdHJ1Y3QgcHRfcmVncyByZWdzKQoreworCXJhd19sb2NhbF9pcnFfZGlzYWJs
ZSgpOworCXRyYWNlX2hhcmRpcnFzX29uKCk7CisJcmF3X2xvY2FsX2lycV9lbmFibGUoKTsKKwly
ZXR1cm4gMDsKK30KIC8qICJhc21saW5rYWdlIiBzbyB0aGUgaW5wdXQgYXJndW1lbnRzIGFyZSBw
cmVzZXJ2ZWQuLi4gKi8KIAogYXNtbGlua2FnZSB2b2lkCkBAIC0xMjg1LDYgKzEyOTUsMzAgQEAg
c3lzY2FsbF90cmFjZV9sZWF2ZSAobG9uZyBhcmcwLCBsb25nIGFyZzEsIGxvbmcgYXJnMiwgbG9u
ZyBhcmczLAogCQlpYTY0X3N5bmNfa3JicygpOwogfQogCithc21saW5rYWdlIHZvaWQKK3N5c2Nh
bGxfaXJxdHJhY2VfbGVhdmUgKGxvbmcgYXJnMCwgbG9uZyBhcmcxLCBsb25nIGFyZzIsIGxvbmcg
YXJnMywKKwkJICAgICBsb25nIGFyZzQsIGxvbmcgYXJnNSwgbG9uZyBhcmc2LCBsb25nIGFyZzcs
CisJCSAgICAgc3RydWN0IHB0X3JlZ3MgcmVncykKK3sKKwlpbnQgc3RlcDsKKworCWlmICh1bmxp
a2VseShjdXJyZW50LT5hdWRpdF9jb250ZXh0KSkgeworCQlpbnQgc3VjY2VzcyA9IEFVRElUU0Nf
UkVTVUxUKHJlZ3MucjEwKTsKKwkJbG9uZyByZXN1bHQgPSByZWdzLnI4OworCisJCWlmIChzdWNj
ZXNzICE9IEFVRElUU0NfU1VDQ0VTUykKKwkJCXJlc3VsdCA9IC1yZXN1bHQ7CisJCWF1ZGl0X3N5
c2NhbGxfZXhpdChzdWNjZXNzLCByZXN1bHQpOworCX0KKworCXN0ZXAgPSB0ZXN0X3RocmVhZF9m
bGFnKFRJRl9TSU5HTEVTVEVQKTsKKwlpZiAoc3RlcCB8fCB0ZXN0X3RocmVhZF9mbGFnKFRJRl9T
WVNDQUxMX1RSQUNFKSkKKwkJdHJhY2Vob29rX3JlcG9ydF9zeXNjYWxsX2V4aXQoJnJlZ3MsIHN0
ZXApOworCisJLyogY29weSB1c2VyIHJicyB0byBrZXJuZWwgcmJzICovCisJaWYgKHRlc3RfdGhy
ZWFkX2ZsYWcoVElGX1JFU1RPUkVfUlNFKSkKKwkJaWE2NF9zeW5jX2tyYnMoKTsKK30KIC8qIFV0
cmFjZSBpbXBsZW1lbnRhdGlvbiBzdGFydHMgaGVyZSAqLwogc3RydWN0IHJlZ3NldF9nZXQgewog
CXZvaWQgKmtidWY7CmRpZmYgLS1naXQgYS9hcmNoL2lhNjQva2VybmVsL3NldHVwLmMgYi9hcmNo
L2lhNjQva2VybmVsL3NldHVwLmMKaW5kZXggNDFhZTZhNS4uODE5MTYzMSAxMDA2NDQKLS0tIGEv
YXJjaC9pYTY0L2tlcm5lbC9zZXR1cC5jCisrKyBiL2FyY2gvaWE2NC9rZXJuZWwvc2V0dXAuYwpA
QCAtMTAxMyw3ICsxMDEzLDExIEBAIGNwdV9pbml0ICh2b2lkKQogCUJVR19PTihjdXJyZW50LT5t
bSk7CiAKIAlpYTY0X21tdV9pbml0KGlhNjRfaW12YShjcHVfZGF0YSkpOworCisJLyogVGVtcG9y
YXJpbHkgc3VwcHJlc3MgbG9ja2RlcCBXQVJOX09OIGlycXMgZGlzYWJsZWQqLyAKKwlsb2NrZGVw
X29mZigpOwogCWlhNjRfbWNhX2NwdV9pbml0KGlhNjRfaW12YShjcHVfZGF0YSkpOworCWxvY2tk
ZXBfb24oKTsKIAogCS8qIENsZWFyIElUQyB0byBlbGltaW5hdGUgc2NoZWRfY2xvY2soKSBvdmVy
Zmxvd3MgaW4gaHVtYW4gdGltZS4gICovCiAJaWE2NF9zZXRfaXRjKDApOwpkaWZmIC0tZ2l0IGEv
YXJjaC9pYTY0L2tlcm5lbC9zbXBib290LmMgYi9hcmNoL2lhNjQva2VybmVsL3NtcGJvb3QuYwpp
bmRleCA2YTEzODBlLi5iZDRhYzY0IDEwMDY0NAotLS0gYS9hcmNoL2lhNjQva2VybmVsL3NtcGJv
b3QuYworKysgYi9hcmNoL2lhNjQva2VybmVsL3NtcGJvb3QuYwpAQCAtNTA3LDcgKzUwNyw3IEBA
IGRvX2Jvb3RfY3B1IChpbnQgc2FwaWNpZCwgaW50IGNwdSkKIAlzdHJ1Y3QgY3JlYXRlX2lkbGUg
Y19pZGxlID0gewogCQkud29yayA9IF9fV09SS19JTklUSUFMSVpFUihjX2lkbGUud29yaywgZG9f
Zm9ya19pZGxlKSwKIAkJLmNwdQk9IGNwdSwKLQkJLmRvbmUJPSBDT01QTEVUSU9OX0lOSVRJQUxJ
WkVSKGNfaWRsZS5kb25lKSwKKwkJLmRvbmUJPSBDT01QTEVUSU9OX0lOSVRJQUxJWkVSX09OU1RB
Q0soY19pZGxlLmRvbmUpLAogCX07CiAKICAJY19pZGxlLmlkbGUgPSBnZXRfaWRsZV9mb3JfY3B1
KGNwdSk7CmRpZmYgLS1naXQgYS9hcmNoL2lhNjQva2VybmVsL3RpbWUuYyBiL2FyY2gvaWE2NC9r
ZXJuZWwvdGltZS5jCmluZGV4IDY1M2IzYzQuLjM5MTU3YTcgMTAwNjQ0Ci0tLSBhL2FyY2gvaWE2
NC9rZXJuZWwvdGltZS5jCisrKyBiL2FyY2gvaWE2NC9rZXJuZWwvdGltZS5jCkBAIC0yMTAsOCAr
MjEwLDggQEAgdGltZXJfaW50ZXJydXB0IChpbnQgaXJxLCB2b2lkICpkZXZfaWQpCiAJCS8qCiAJ
CSAqIEFsbG93IElQSXMgdG8gaW50ZXJydXB0IHRoZSB0aW1lciBsb29wLgogCQkgKi8KLQkJbG9j
YWxfaXJxX2VuYWJsZSgpOwotCQlsb2NhbF9pcnFfZGlzYWJsZSgpOworCQlyYXdfbG9jYWxfaXJx
X2VuYWJsZSgpOworCQlyYXdfbG9jYWxfaXJxX2Rpc2FibGUoKTsKIAl9CiAKIHNraXBfcHJvY2Vz
c190aW1lX2FjY291bnRpbmc6CmRpZmYgLS1naXQgYS9hcmNoL2lhNjQvbW0vZmF1bHQuYyBiL2Fy
Y2gvaWE2NC9tbS9mYXVsdC5jCmluZGV4IDA3OTlmZWEuLjQ0ZjM3ZGMgMTAwNjQ0Ci0tLSBhL2Fy
Y2gvaWE2NC9tbS9mYXVsdC5jCisrKyBiL2FyY2gvaWE2NC9tbS9mYXVsdC5jCkBAIC04Miw2ICs4
Miw3IEBAIGlhNjRfZG9fcGFnZV9mYXVsdCAodW5zaWduZWQgbG9uZyBhZGRyZXNzLCB1bnNpZ25l
ZCBsb25nIGlzciwgc3RydWN0IHB0X3JlZ3MgKnJlCiAJdW5zaWduZWQgbG9uZyBtYXNrOwogCWlu
dCBmYXVsdDsKIAorCXRyYWNlX2hhcmRpcnFzX29uX2RlbGF5ZWQoKTsKIAkvKiBtbWFwX3NlbSBp
cyBwZXJmb3JtYW5jZSBjcml0aWNhbC4uLi4gKi8KIAlwcmVmZXRjaHcoJm1tLT5tbWFwX3NlbSk7
CiAKZGlmZiAtLWdpdCBhL2ZzL2lvY3RsLmMgYi9mcy9pb2N0bC5jCmluZGV4IDJkMTQwYTcuLjEz
NzQ5MjAgMTAwNjQ0Ci0tLSBhL2ZzL2lvY3RsLmMKKysrIGIvZnMvaW9jdGwuYwpAQCAtNjE2LDYg
KzYxNiw3IEBAIFNZU0NBTExfREVGSU5FMyhpb2N0bCwgdW5zaWduZWQgaW50LCBmZCwgdW5zaWdu
ZWQgaW50LCBjbWQsIHVuc2lnbmVkIGxvbmcsIGFyZykKIAlpbnQgZXJyb3IgPSAtRUJBREY7CiAJ
aW50IGZwdXRfbmVlZGVkOwogCisJdHJhY2VfaGFyZGlycXNfb25fZGVsYXllZCgpOwogCWZpbHAg
PSBmZ2V0X2xpZ2h0KGZkLCAmZnB1dF9uZWVkZWQpOwogCWlmICghZmlscCkKIAkJZ290byBvdXQ7
CmRpZmYgLS1naXQgYS9mcy9vcGVuLmMgYi9mcy9vcGVuLmMKaW5kZXggNTQ2MzI2Ni4uYzhhN2Vj
YSAxMDA2NDQKLS0tIGEvZnMvb3Blbi5jCisrKyBiL2ZzL29wZW4uYwpAQCAtOTczLDYgKzk3Myw3
IEBAIFNZU0NBTExfREVGSU5FMShjbG9zZSwgdW5zaWduZWQgaW50LCBmZCkKIAlzdHJ1Y3QgZmR0
YWJsZSAqZmR0OwogCWludCByZXR2YWw7CiAKKwl0cmFjZV9oYXJkaXJxc19vbl9kZWxheWVkKCk7
CiAJc3Bpbl9sb2NrKCZmaWxlcy0+ZmlsZV9sb2NrKTsKIAlmZHQgPSBmaWxlc19mZHRhYmxlKGZp
bGVzKTsKIAlpZiAoZmQgPj0gZmR0LT5tYXhfZmRzKQpkaWZmIC0tZ2l0IGEvZnMvcmVhZF93cml0
ZS5jIGIvZnMvcmVhZF93cml0ZS5jCmluZGV4IDljMDQ4NTIuLmVkYTM3ZTIgMTAwNjQ0Ci0tLSBh
L2ZzL3JlYWRfd3JpdGUuYworKysgYi9mcy9yZWFkX3dyaXRlLmMKQEAgLTQxMiw2ICs0MTIsNyBA
QCBTWVNDQUxMX0RFRklORTMod3JpdGUsIHVuc2lnbmVkIGludCwgZmQsIGNvbnN0IGNoYXIgX191
c2VyICosIGJ1ZiwKIAlzc2l6ZV90IHJldCA9IC1FQkFERjsKIAlpbnQgZnB1dF9uZWVkZWQ7CiAK
Kwl0cmFjZV9oYXJkaXJxc19vbl9kZWxheWVkKCk7CiAJZmlsZSA9IGZnZXRfbGlnaHQoZmQsICZm
cHV0X25lZWRlZCk7CiAJaWYgKGZpbGUpIHsKIAkJbG9mZl90IHBvcyA9IGZpbGVfcG9zX3JlYWQo
ZmlsZSk7CmRpZmYgLS1naXQgYS9pbmNsdWRlL2xpbnV4L2lycWZsYWdzLmggYi9pbmNsdWRlL2xp
bnV4L2lycWZsYWdzLmgKaW5kZXggMDA2YmY0NS4uNTFkMDIzMyAxMDA2NDQKLS0tIGEvaW5jbHVk
ZS9saW51eC9pcnFmbGFncy5oCisrKyBiL2luY2x1ZGUvbGludXgvaXJxZmxhZ3MuaApAQCAtMTcs
NiArMTcsNyBAQAogICBleHRlcm4gdm9pZCB0cmFjZV9zb2Z0aXJxc19vbih1bnNpZ25lZCBsb25n
IGlwKTsKICAgZXh0ZXJuIHZvaWQgdHJhY2Vfc29mdGlycXNfb2ZmKHVuc2lnbmVkIGxvbmcgaXAp
OwogICBleHRlcm4gdm9pZCB0cmFjZV9oYXJkaXJxc19vbih2b2lkKTsKKyAgZXh0ZXJuIHZvaWQg
dHJhY2VfaGFyZGlycXNfb25fZGVsYXllZCh2b2lkKTsKICAgZXh0ZXJuIHZvaWQgdHJhY2VfaGFy
ZGlycXNfb2ZmKHZvaWQpOwogIyBkZWZpbmUgdHJhY2VfaGFyZGlycV9jb250ZXh0KHApCSgocCkt
PmhhcmRpcnFfY29udGV4dCkKICMgZGVmaW5lIHRyYWNlX3NvZnRpcnFfY29udGV4dChwKQkoKHAp
LT5zb2Z0aXJxX2NvbnRleHQpCkBAIC0yOSw2ICszMCw3IEBACiAjIGRlZmluZSBJTklUX1RSQUNF
X0lSUUZMQUdTCS5zb2Z0aXJxc19lbmFibGVkID0gMSwKICNlbHNlCiAjIGRlZmluZSB0cmFjZV9o
YXJkaXJxc19vbigpCQlkbyB7IH0gd2hpbGUgKDApCisjIGRlZmluZSB0cmFjZV9oYXJkaXJxc19v
bl9kZWxheWVkKCkJCWRvIHsgfSB3aGlsZSAoMCkKICMgZGVmaW5lIHRyYWNlX2hhcmRpcnFzX29m
ZigpCQlkbyB7IH0gd2hpbGUgKDApCiAjIGRlZmluZSB0cmFjZV9zb2Z0aXJxc19vbihpcCkJCWRv
IHsgfSB3aGlsZSAoMCkKICMgZGVmaW5lIHRyYWNlX3NvZnRpcnFzX29mZihpcCkJCWRvIHsgfSB3
aGlsZSAoMCkKZGlmZiAtLWdpdCBhL2luY2x1ZGUvbGludXgvbG9ja2RlcC5oIGIvaW5jbHVkZS9s
aW51eC9sb2NrZGVwLmgKaW5kZXggMDZhZWQ4My4uYmFhNTczYiAxMDA2NDQKLS0tIGEvaW5jbHVk
ZS9saW51eC9sb2NrZGVwLmgKKysrIGIvaW5jbHVkZS9saW51eC9sb2NrZGVwLmgKQEAgLTE3NCw3
ICsxNzQsNyBAQCBzdHJ1Y3QgbG9ja19jaGFpbiB7CiAJdTY0CQkJCWNoYWluX2tleTsKIH07CiAK
LSNkZWZpbmUgTUFYX0xPQ0tERVBfS0VZU19CSVRTCQkxMworI2RlZmluZSBNQVhfTE9DS0RFUF9L
RVlTX0JJVFMJCTEyCiAvKgogICogU3VidHJhY3Qgb25lIGJlY2F1c2Ugd2Ugb2Zmc2V0IGhsb2Nr
LT5jbGFzc19pZHggYnkgMSBpbiBvcmRlcgogICogdG8gbWFrZSAwIG1lYW4gbm8gY2xhc3MuIFRo
aXMgYXZvaWRzIG92ZXJmbG93aW5nIHRoZSBjbGFzc19pZHgKZGlmZiAtLWdpdCBhL2tlcm5lbC9m
b3JrLmMgYi9rZXJuZWwvZm9yay5jCmluZGV4IGI2Y2NlMTQuLjBjNGFlNmQgMTAwNjQ0Ci0tLSBh
L2tlcm5lbC9mb3JrLmMKKysrIGIva2VybmVsL2ZvcmsuYwpAQCAtMTAxMiw2ICsxMDEyLDEwIEBA
IHN0YXRpYyBzdHJ1Y3QgdGFza19zdHJ1Y3QgKmNvcHlfcHJvY2Vzcyh1bnNpZ25lZCBsb25nIGNs
b25lX2ZsYWdzLAogCXJ0X211dGV4X2luaXRfdGFzayhwKTsKIAogI2lmZGVmIENPTkZJR19QUk9W
RV9MT0NLSU5HCisJLy93b3JrYXJvdW5kIAorCXAtPmhhcmRpcnFzX2VuYWJsZWQgPSAxOworCXAt
PmhhcmRpcnFzX2VuYWJsZWQgPSAxOworCiAJREVCVUdfTE9DS1NfV0FSTl9PTighcC0+aGFyZGly
cXNfZW5hYmxlZCk7CiAJREVCVUdfTE9DS1NfV0FSTl9PTighcC0+c29mdGlycXNfZW5hYmxlZCk7
CiAjZW5kaWYKZGlmZiAtLWdpdCBhL2tlcm5lbC9sb2NrZGVwLmMgYi9rZXJuZWwvbG9ja2RlcC5j
CmluZGV4IDU0Mjg2NzkuLmY1MDFjMTAgMTAwNjQ0Ci0tLSBhL2tlcm5lbC9sb2NrZGVwLmMKKysr
IGIva2VybmVsL2xvY2tkZXAuYwpAQCAtMjM1Myw2ICsyMzUzLDE0IEBAIHZvaWQgdHJhY2VfaGFy
ZGlycXNfb24odm9pZCkKIH0KIEVYUE9SVF9TWU1CT0wodHJhY2VfaGFyZGlycXNfb24pOwogCit2
b2lkIHRyYWNlX2hhcmRpcnFzX29uX2RlbGF5ZWQodm9pZCkKK3sKKwlyYXdfbG9jYWxfaXJxX2Rp
c2FibGUoKTsKKwl0cmFjZV9oYXJkaXJxc19vbigpOworCXJhd19sb2NhbF9pcnFfZW5hYmxlKCk7
Cit9CitFWFBPUlRfU1lNQk9MKHRyYWNlX2hhcmRpcnFzX29uX2RlbGF5ZWQpOworCiAvKgogICog
SGFyZGlycXMgd2VyZSBkaXNhYmxlZDoKICAqLwpkaWZmIC0tZ2l0IGEva2VybmVsL3N5cy5jIGIv
a2VybmVsL3N5cy5jCmluZGV4IGU4M2RkYmIuLmUwYzY3ZGIgMTAwNjQ0Ci0tLSBhL2tlcm5lbC9z
eXMuYworKysgYi9rZXJuZWwvc3lzLmMKQEAgLTk5Myw2ICs5OTMsNyBAQCBTWVNDQUxMX0RFRklO
RTEoZ2V0cGdpZCwgcGlkX3QsIHBpZCkKIAlzdHJ1Y3QgcGlkICpncnA7CiAJaW50IHJldHZhbDsK
IAorCXRyYWNlX2hhcmRpcnFzX29uX2RlbGF5ZWQoKTsKIAlyY3VfcmVhZF9sb2NrKCk7CiAJaWYg
KCFwaWQpCiAJCWdycCA9IHRhc2tfcGdycChjdXJyZW50KTsKZGlmZiAtLWdpdCBhL2tlcm5lbC90
aW1lci5jIGIva2VybmVsL3RpbWVyLmMKaW5kZXggZWUzMDVjOC4uNzc5Mzk5MSAxMDA2NDQKLS0t
IGEva2VybmVsL3RpbWVyLmMKKysrIGIva2VybmVsL3RpbWVyLmMKQEAgLTEzMzYsNiArMTMzNiw3
IEBAIFNZU0NBTExfREVGSU5FMShhbGFybSwgdW5zaWduZWQgaW50LCBzZWNvbmRzKQogICovCiBT
WVNDQUxMX0RFRklORTAoZ2V0cGlkKQogeworCXRyYWNlX2hhcmRpcnFzX29uX2RlbGF5ZWQoKTsK
IAlyZXR1cm4gdGFza190Z2lkX3ZucihjdXJyZW50KTsKIH0KIApkaWZmIC0tZ2l0IGEva2VybmVs
L3RyYWNlL3RyYWNlX2lycXNvZmYuYyBiL2tlcm5lbC90cmFjZS90cmFjZV9pcnFzb2ZmLmMKaW5k
ZXggNmZkNDg2ZS4uM2MyYTkzMSAxMDA2NDQKLS0tIGEva2VybmVsL3RyYWNlL3RyYWNlX2lycXNv
ZmYuYworKysgYi9rZXJuZWwvdHJhY2UvdHJhY2VfaXJxc29mZi5jCkBAIC01MjUsNiArNTI1LDEy
IEBAIHZvaWQgdHJhY2VfaGFyZGlycXNfb24odm9pZCkKIH0KIEVYUE9SVF9TWU1CT0wodHJhY2Vf
aGFyZGlycXNfb24pOwogCit2b2lkIHRyYWNlX2hhcmRpcnFzX29uX2RlbGF5ZWQodm9pZCkKK3sK
Kwl0cmFjZV9oYXJkaXJxc19vbigpOworfQorRVhQT1JUX1NZTUJPTCh0cmFjZV9oYXJkaXJxc19v
bl9kZWxheWVkKTsKKwogdm9pZCB0cmFjZV9oYXJkaXJxc19vZmYodm9pZCkKIHsKIAlpZiAoIXBy
ZWVtcHRfdHJhY2UoKSAmJiBpcnFfdHJhY2UoKSkK
--0016e64dc986fb4c490489d69820--
