From: Keith Owens <kaos@sgi.com>
Date: Sun, 11 Sep 2005 03:36:41 +0000
Subject: [PATCH 2.6.13 8/7 respin 1] MCA/INIT: tweaks
Message-Id: <22055.1126409801@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Respin 1 of the tweaks to the previous MCA/INIT patch sets.

* Remove the requirement that kernel stacks be aligned on KERNEL_STACK_SIZE.
* Remove the serialization of MCA/INIT handlers returning to SAL.  The
  problem looked like a race but was really caused by a broken prom
  doing cacheable accesses to the minstate area.
* Print the cpu number and monarch status in the INIT handler.
* Workaround for broken proms that access the minstate area using
  cacheable addresses.
* Remove the export of the scheduler hooks until we have modular code
  that needs them.
* Remove the final reference to MINSTATE_VIRT.
* Workaround for broken proms that drive all INIT events as slaves.
* Workaround for broken proms that drive all INIT events as monarchs.

Signed-off-by: Keith Owens <kaos@sgi.com>

 arch/ia64/kernel/ivt.S         |    1 
 arch/ia64/kernel/mca.c         |   56 ++++++++++++++++++---------
 arch/ia64/kernel/mca_asm.S     |   85 ++++++++++++++++++++++++++++++++++++-----
 arch/ia64/kernel/vmlinux.lds.S |    1 
 kernel/sched.c                 |    2 
 5 files changed, 114 insertions(+), 31 deletions(-)

Index: linux/arch/ia64/kernel/vmlinux.lds.S
=================================--- linux.orig/arch/ia64/kernel/vmlinux.lds.S	2005-09-11 12:33:19.602657109 +1000
+++ linux/arch/ia64/kernel/vmlinux.lds.S	2005-09-11 13:12:30.345693334 +1000
@@ -165,7 +165,6 @@ SECTIONS
   __init_end = .;
 
   /* The initial task and kernel stack */
-  . = ALIGN(KERNEL_STACK_SIZE);
   .data.init_task : AT(ADDR(.data.init_task) - LOAD_OFFSET)
 	{ *(.data.init_task) }
 
Index: linux/arch/ia64/kernel/mca.c
=================================--- linux.orig/arch/ia64/kernel/mca.c	2005-09-11 12:33:19.565552918 +1000
+++ linux/arch/ia64/kernel/mca.c	2005-09-11 13:13:00.011453791 +1000
@@ -90,7 +90,6 @@
 
 /* Used by mca_asm.S */
 u32				ia64_mca_serialize;
-s32				ia64_mca_init_leave = -1;
 DEFINE_PER_CPU(u64, ia64_mca_data); /* = __per_cpu_mca[smp_processor_id()] */
 DEFINE_PER_CPU(u64, ia64_mca_per_cpu_pte); /* PTE to map per-CPU area */
 DEFINE_PER_CPU(u64, ia64_mca_pal_pte);	    /* PTE to map PAL code */
@@ -704,11 +703,15 @@ ia64_mca_modify_original_stack(struct pt
 		msg = "occurred in user space";
 		goto no_mod;
 	}
-	if ((r12 & -KERNEL_STACK_SIZE) != r13) {
+	if (r13 != sos->prev_IA64_KR_CURRENT) {
+		msg = "inconsistent previous current and r13";
+		goto no_mod;
+	}
+	if ((r12 - r13) >= KERNEL_STACK_SIZE) {
 		msg = "inconsistent r12 and r13";
 		goto no_mod;
 	}
-	if ((ar_bspstore & -KERNEL_STACK_SIZE) != r13) {
+	if ((ar_bspstore - r13) >= KERNEL_STACK_SIZE) {
 		msg = "inconsistent ar.bspstore and r13";
 		goto no_mod;
 	}
@@ -717,7 +720,7 @@ ia64_mca_modify_original_stack(struct pt
 		msg = "old_bspstore is in the wrong region";
 		goto no_mod;
 	}
-	if ((ar_bsp & -KERNEL_STACK_SIZE) != r13) {
+	if ((ar_bsp - r13) >= KERNEL_STACK_SIZE) {
 		msg = "inconsistent ar.bsp and r13";
 		goto no_mod;
 	}
@@ -907,13 +910,6 @@ ia64_wait_for_slaves(int monarch)
 	}
 }
 
-static void
-mca_init_leave(int cpu)
-{
-	 while (cmpxchg_acq(&ia64_mca_init_leave, -1, cpu) != -1)
-		 cpu_relax();
-}
-
 /*
  * ia64_mca_handler
  *
@@ -968,7 +964,6 @@ ia64_mca_handler(struct pt_regs *regs, s
 	}
 
 	set_curr_task(cpu, previous_current);
-	mca_init_leave(cpu);
 	monarch_cpu = -1;
 }
 
@@ -1211,6 +1206,8 @@ void
 ia64_init_handler(struct pt_regs *regs, struct switch_stack *sw,
 		  struct ia64_sal_os_state *sos)
 {
+	static atomic_t slaves;
+	static atomic_t monarchs;
 	task_t *previous_current;
 	int cpu = smp_processor_id(), c;
 	struct task_struct *g, *t;
@@ -1218,22 +1215,47 @@ ia64_init_handler(struct pt_regs *regs, 
 	oops_in_progress = 1;	/* FIXME: make printk NMI/MCA/INIT safe */
 	console_loglevel = 15;	/* make sure printks make it to console */
 
-	printk(KERN_INFO "Entered OS INIT handler. PSP=%lx\n",
-		sos->proc_state_param);
+	printk(KERN_INFO "Entered OS INIT handler. PSP=%lx cpu=%d monarch=%ld\n",
+		sos->proc_state_param, cpu, sos->monarch);
 	salinfo_log_wakeup(SAL_INFO_TYPE_INIT, NULL, 0, 0);
 
 	previous_current = ia64_mca_modify_original_stack(regs, sw, sos, "INIT");
 	sos->os_status = IA64_INIT_RESUME;
+
+	/* FIXME: Workaround for broken proms that drive all INIT events as
+	 * slaves.  The last slave that enters is promoted to be a monarch.
+	 * Remove this code in September 2006, that gives platforms a year to
+	 * fix their proms and get their customers updated.
+	 */
+	if (!sos->monarch && atomic_add_return(1, &slaves) = num_online_cpus()) {
+		printk(KERN_WARNING "%s: Promoting cpu %d to monarch.\n",
+		       __FUNCTION__, cpu);
+		atomic_dec(&slaves);
+		sos->monarch = 1;
+	}
+
+	/* FIXME: Workaround for broken proms that drive all INIT events as
+	 * monarchs.  Second and subsequent monarchs are demoted to slaves.
+	 * Remove this code in September 2006, that gives platforms a year to
+	 * fix their proms and get their customers updated.
+	 */
+	if (sos->monarch && atomic_add_return(1, &monarchs) > 1) {
+		printk(KERN_WARNING "%s: Demoting cpu %d to slave.\n",
+			       __FUNCTION__, cpu);
+		atomic_dec(&monarchs);
+		sos->monarch = 0;
+	}
+
 	if (!sos->monarch) {
 		ia64_mc_info.imi_rendez_checkin[cpu] = IA64_MCA_RENDEZ_CHECKIN_INIT;
 		while (monarch_cpu = -1)
 		       cpu_relax();	/* spin until monarch enters */
 		while (monarch_cpu != -1)
 		       cpu_relax();	/* spin until monarch leaves */
-		printk("slave returning %d\n", cpu);
+		printk("Slave on cpu %d returning to normal service.\n", cpu);
 		set_curr_task(cpu, previous_current);
-		mca_init_leave(cpu);
 		ia64_mc_info.imi_rendez_checkin[cpu] = IA64_MCA_RENDEZ_CHECKIN_NOTDONE;
+		atomic_dec(&slaves);
 		return;
 	}
 
@@ -1270,8 +1292,8 @@ ia64_init_handler(struct pt_regs *regs, 
 		read_unlock(&tasklist_lock);
 	}
 	printk("\nINIT dump complete.  Monarch on cpu %d returning to normal service.\n", cpu);
+	atomic_dec(&monarchs);
 	set_curr_task(cpu, previous_current);
-	mca_init_leave(cpu);
 	monarch_cpu = -1;
 	return;
 }
Index: linux/arch/ia64/kernel/mca_asm.S
=================================--- linux.orig/arch/ia64/kernel/mca_asm.S	2005-09-11 12:33:19.558717936 +1000
+++ linux/arch/ia64/kernel/mca_asm.S	2005-09-11 13:12:29.878961933 +1000
@@ -319,11 +319,6 @@ END(ia64_os_mca_virtual_begin)
 	// release lock
 	LOAD_PHYSICAL(p0,r3,ia64_mca_serialize);;
 	st4.rel		[r3]=r0
-	;;
-	mov r31=-1
-	LOAD_PHYSICAL(p0,r3,ia64_mca_init_leave);;
-	;;
-	st4.rel		[r3]=r31
 
 	br		b0
 
@@ -414,11 +409,6 @@ END(ia64_os_init_virtual_begin)
 1:
 
 	mov		b0=r12			// SAL_CHECK return address
-	;;
-	mov r31=-1
-	LOAD_PHYSICAL(p0,r3,ia64_mca_init_leave);;
-	;;
-	st4.rel		[r3]=r31
 	br		b0
 
 //EndMain//////////////////////////////////////////////////////////////////////
@@ -626,6 +616,81 @@ ia64_state_save:
 	;;
 	st8 [temp1]=temp3	// save ar.lc
 
+	// FIXME: Some proms are incorrectly accessing the minstate area as
+	// cached data.  The C code uses region 6, uncached virtual.  Ensure
+	// that there is no cache data lying around for the first 1K of the
+	// minstate area.
+	// Remove this code in September 2006, that gives platforms a year to
+	// fix their proms and get their customers updated.
+
+	add r12*1,r17
+	add r22*2,r17
+	add r32*3,r17
+	add r42*4,r17
+	add r52*5,r17
+	add r62*6,r17
+	add r72*7,r17
+	;;
+	fc r17
+	fc r1
+	fc r2
+	fc r3
+	fc r4
+	fc r5
+	fc r6
+	fc r7
+	add r172*8,r17
+	add r12*8,r1
+	add r22*8,r2
+	add r32*8,r3
+	add r42*8,r4
+	add r52*8,r5
+	add r62*8,r6
+	add r72*8,r7
+	;;
+	fc r17
+	fc r1
+	fc r2
+	fc r3
+	fc r4
+	fc r5
+	fc r6
+	fc r7
+	add r172*8,r17
+	add r12*8,r1
+	add r22*8,r2
+	add r32*8,r3
+	add r42*8,r4
+	add r52*8,r5
+	add r62*8,r6
+	add r72*8,r7
+	;;
+	fc r17
+	fc r1
+	fc r2
+	fc r3
+	fc r4
+	fc r5
+	fc r6
+	fc r7
+	add r172*8,r17
+	add r12*8,r1
+	add r22*8,r2
+	add r32*8,r3
+	add r42*8,r4
+	add r52*8,r5
+	add r62*8,r6
+	add r72*8,r7
+	;;
+	fc r17
+	fc r1
+	fc r2
+	fc r3
+	fc r4
+	fc r5
+	fc r6
+	fc r7
+
 	br.sptk b0
 
 //EndStub//////////////////////////////////////////////////////////////////////
Index: linux/arch/ia64/kernel/ivt.S
=================================--- linux.orig/arch/ia64/kernel/ivt.S	2005-09-11 12:31:54.629180129 +1000
+++ linux/arch/ia64/kernel/ivt.S	2005-09-11 12:33:19.645619855 +1000
@@ -69,7 +69,6 @@
 # define DBG_FAULT(i)
 #endif
 
-#define MINSTATE_VIRT	/* needed by minstate.h */
 #include "minstate.h"
 
 #define FAULT(n)									\
Index: linux/kernel/sched.c
=================================--- linux.orig/kernel/sched.c	2005-09-11 12:33:19.492320964 +1000
+++ linux/kernel/sched.c	2005-09-11 13:12:30.747004225 +1000
@@ -3478,7 +3478,6 @@ task_t *curr_task(int cpu)
 {
 	return cpu_curr(cpu);
 }
-EXPORT_SYMBOL_GPL(curr_task);
 
 /**
  * set_curr_task - set the current task for a given cpu.
@@ -3496,7 +3495,6 @@ void set_curr_task(int cpu, task_t *p)
 {
 	cpu_curr(cpu) = p;
 }
-EXPORT_SYMBOL_GPL(set_curr_task);
 
 /**
  * find_process_by_pid - find a process with a matching PID value.

