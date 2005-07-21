From: Takao Indoh <indou.takao@jp.fujitsu.com>
Date: Thu, 21 Jul 2005 11:04:51 +0000
Subject: [PATCH]Show registers for all CPUs in the OS_INIT handler
Message-Id: <C5C58DE4044703indou.takao@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

When OS_INIT handler is called, the registers of monarch CPU are dumped
but the registers of slave CPU are not. It is very inconvenient because
ip cannot be identified on slave cpus.
I'd like to change OS_INIT handler to show registers of all CPUs.

To do this, these changes are needed.

1) In the ia64_mca_init(), register ia64_monarch_init_handler() as 
   both (monarch and slave) handlers
2) Prepare ia64_mca_sal_to_os_state_t for each CPU
3) Serialization of init_handler_platform

This is a patch for kernel 2.6.12.3.
Please let me know if this patch has problems.

Takao Indoh

diff -Nurp linux-2.6.12.3.org/arch/ia64/kernel/asm-offsets.c linux-2.6.12.3/arch/ia64/kernel/asm-offsets.c
--- linux-2.6.12.3.org/arch/ia64/kernel/asm-offsets.c	2005-07-20 16:39:57.000000000 +0900
+++ linux-2.6.12.3/arch/ia64/kernel/asm-offsets.c	2005-07-21 10:31:07.000000000 +0900
@@ -221,6 +221,8 @@ void foo(void)
 	       offsetof (struct ia64_mca_cpu, rbstore));
 	DEFINE(IA64_MCA_CPU_INIT_STACK_OFFSET,
 	       offsetof (struct ia64_mca_cpu, init_stack));
+	DEFINE(IA64_MCA_CPU_HANDOFF_STATE_OFFSET,
+	       offsetof (struct ia64_mca_cpu, handoff_state));
 	BLANK();
 	/* used by fsys_gettimeofday in arch/ia64/kernel/fsys.S */
 	DEFINE(IA64_TIME_INTERPOLATOR_ADDRESS_OFFSET, offsetof (struct time_interpolator, addr));
diff -Nurp linux-2.6.12.3.org/arch/ia64/kernel/mca.c linux-2.6.12.3/arch/ia64/kernel/mca.c
--- linux-2.6.12.3.org/arch/ia64/kernel/mca.c	2005-07-20 16:39:57.000000000 +0900
+++ linux-2.6.12.3/arch/ia64/kernel/mca.c	2005-07-21 11:38:10.770642931 +0900
@@ -468,6 +468,7 @@ fetch_min_state (pal_min_state_area_t *m
 	PUT_NAT_BIT(sw->caller_unat, &pt->r30);	PUT_NAT_BIT(sw->caller_unat, &pt->r31);
 }
 
+static spinlock_t init_handler_lock = SPIN_LOCK_UNLOCKED;
 static void
 init_handler_platform (pal_min_state_area_t *ms,
 		       struct pt_regs *pt, struct switch_stack *sw)
@@ -484,12 +485,14 @@ init_handler_platform (pal_min_state_are
 	 */
 	printk("Delaying for 5 seconds...\n");
 	udelay(5*1000000);
+	spin_lock(&init_handler_lock);
 	show_min_state(ms);
 
 	printk("Backtrace of current task (pid %d, %s)\n", current->pid, current->comm);
 	fetch_min_state(ms, pt, sw);
 	unw_init_from_interruption(&info, current, pt, sw);
 	ia64_do_show_stack(&info, NULL);
+	spin_unlock(&init_handler_lock);
 
 #ifdef CONFIG_SMP
 	/* read_trylock() would be handy... */
@@ -1138,19 +1141,21 @@ void
 ia64_init_handler (struct pt_regs *pt, struct switch_stack *sw)
 {
 	pal_min_state_area_t *ms;
+	struct ia64_mca_cpu *mca_cpu = __va(__get_cpu_var(ia64_mca_data));
+	ia64_mca_sal_to_os_state_t *state = &mca_cpu->handoff_state;
 
 	oops_in_progress = 1;	/* avoid deadlock in printk, but it makes recovery dodgy */
 	console_loglevel = 15;	/* make sure printks make it to console */
 
 	printk(KERN_INFO "Entered OS INIT handler. PSP=%lx\n",
-		ia64_sal_to_os_handoff_state.proc_state_param);
+		state->proc_state_param);
 
 	/*
 	 * Address of minstate area provided by PAL is physical,
 	 * uncacheable (bit 63 set). Convert to Linux virtual
 	 * address in region 6.
 	 */
-	ms = (pal_min_state_area_t *)(ia64_sal_to_os_handoff_state.pal_min_state | (6ul<<61));
+	ms = (pal_min_state_area_t *)(state->pal_min_state | (6ul<<61));
 
 	init_handler_platform(ms, pt, sw);	/* call platform specific routines */
 }
@@ -1273,7 +1278,7 @@ void __init
 ia64_mca_init(void)
 {
 	ia64_fptr_t *mon_init_ptr = (ia64_fptr_t *)ia64_monarch_init_handler;
-	ia64_fptr_t *slave_init_ptr = (ia64_fptr_t *)ia64_slave_init_handler;
+	ia64_fptr_t *slave_init_ptr = (ia64_fptr_t *)ia64_monarch_init_handler;
 	ia64_fptr_t *mca_hldlr_ptr = (ia64_fptr_t *)ia64_os_mca_dispatch;
 	int i;
 	s64 rc;
diff -Nurp linux-2.6.12.3.org/arch/ia64/kernel/mca_asm.S linux-2.6.12.3/arch/ia64/kernel/mca_asm.S
--- linux-2.6.12.3.org/arch/ia64/kernel/mca_asm.S	2005-07-20 16:39:57.000000000 +0900
+++ linux-2.6.12.3/arch/ia64/kernel/mca_asm.S	2005-07-21 10:36:11.000000000 +0900
@@ -59,6 +59,20 @@
 	st8	[_tmp]=r17,0x08;;			\
 	st8	[_tmp]=r18,0x08
 
+#define SAL_TO_OS_MCA_HANDOFF_STATE_SAVE_PER_CPU(_tmp)	\
+	mov _tmp=IA64_KR(PER_CPU_DATA);;		\
+	addl _tmp=THIS_CPU(ia64_mca_data),_tmp;;	\
+	ld8 _tmp=[_tmp];;				\
+	addl _tmp=IA64_MCA_CPU_HANDOFF_STATE_OFFSET,_tmp;;	\
+	st8	[_tmp]=r1,0x08;;			\
+	st8	[_tmp]=r8,0x08;;			\
+	st8	[_tmp]=r9,0x08;;			\
+	st8	[_tmp]=r10,0x08;;			\
+	st8	[_tmp]=r11,0x08;;			\
+	st8	[_tmp]=r12,0x08;;			\
+	st8	[_tmp]=r17,0x08;;			\
+	st8	[_tmp]=r18,0x08
+
 /*
  * OS_MCA_TO_SAL_HANDOFF_STATE (SAL 3.0 spec)
  * (p6) is executed if we never entered virtual mode (TLB error)
@@ -888,7 +902,7 @@ end_os_mca_restore:
 GLOBAL_ENTRY(ia64_monarch_init_handler)
 	.prologue
 	// stash the information the SAL passed to os
-	SAL_TO_OS_MCA_HANDOFF_STATE_SAVE(r2)
+	SAL_TO_OS_MCA_HANDOFF_STATE_SAVE_PER_CPU(r2)
 	;;
 	SAVE_MIN_WITH_COVER
 	;;
diff -Nurp linux-2.6.12.3.org/include/asm-ia64/mca.h linux-2.6.12.3/include/asm-ia64/mca.h
--- linux-2.6.12.3.org/include/asm-ia64/mca.h	2005-07-20 16:39:59.000000000 +0900
+++ linux-2.6.12.3/include/asm-ia64/mca.h	2005-07-21 10:37:09.000000000 +0900
@@ -112,6 +112,7 @@ struct ia64_mca_cpu {
 	u64 stackframe[32];
 	u64 rbstore[IA64_MCA_STACK_SIZE/8];	/* MCA reg.-backing store */
 	u64 init_stack[KERNEL_STACK_SIZE/8];
+	ia64_mca_sal_to_os_state_t handoff_state;
 } __attribute__ ((aligned(16)));
 
 /* Array of physical addresses of each CPU's MCA area.  */
