From: Keith Owens <kaos@sgi.com>
Date: Thu, 08 Sep 2005 06:53:18 +0000
Subject: [PATCH 2.6.13 8/7] MCA/INIT: tweaks
Message-Id: <10631.1126162398@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Some tweaks to the previous MCA/INIT patch sets.

* Remove the requirement that kernel stacks be aligned on KERNEL_STACK_SIZE.
* Remove the serialization of MCA/INIT handlers returning to SAL.  The
  problem looked like a race but was really caused by a broken prom
  doing cacheable accesses to the minstate area.
* Print the cpu number and monarch status in the INIT handler.
* Workaround for broken proms that access the minstate area using
  cacheable addresses.

Signed-off-by: Keith Owens <kaos@sgi.com>

 mca.c         |   27 ++++++------------
 mca_asm.S     |   85 +++++++++++++++++++++++++++++++++++++++++++++++++++-------
 vmlinux.lds.S |    1 
 3 files changed, 85 insertions(+), 28 deletions(-)

Index: linux/arch/ia64/kernel/vmlinux.lds.S
=================================--- linux.orig/arch/ia64/kernel/vmlinux.lds.S	2005-09-08 14:06:55.344665850 +1000
+++ linux/arch/ia64/kernel/vmlinux.lds.S	2005-09-08 14:07:32.465527377 +1000
@@ -165,7 +165,6 @@ SECTIONS
   __init_end = .;
 
   /* The initial task and kernel stack */
-  . = ALIGN(KERNEL_STACK_SIZE);
   .data.init_task : AT(ADDR(.data.init_task) - LOAD_OFFSET)
 	{ *(.data.init_task) }
 
Index: linux/arch/ia64/kernel/mca.c
=================================--- linux.orig/arch/ia64/kernel/mca.c	2005-09-08 14:06:55.281198033 +1000
+++ linux/arch/ia64/kernel/mca.c	2005-09-08 14:07:32.465527377 +1000
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
 
@@ -1218,8 +1213,8 @@ ia64_init_handler(struct pt_regs *regs, 
 	oops_in_progress = 1;	/* FIXME: make printk NMI/MCA/INIT safe */
 	console_loglevel = 15;	/* make sure printks make it to console */
 
-	printk(KERN_INFO "Entered OS INIT handler. PSP=%lx\n",
-		sos->proc_state_param);
+	printk(KERN_INFO "Entered OS INIT handler. PSP=%lx cpu=%d monarch=%ld\n",
+		sos->proc_state_param, cpu, sos->monarch);
 	salinfo_log_wakeup(SAL_INFO_TYPE_INIT, NULL, 0, 0);
 
 	previous_current = ia64_mca_modify_original_stack(regs, sw, sos, "INIT");
@@ -1230,9 +1225,8 @@ ia64_init_handler(struct pt_regs *regs, 
 		       cpu_relax();	/* spin until monarch enters */
 		while (monarch_cpu != -1)
 		       cpu_relax();	/* spin until monarch leaves */
-		printk("slave returning %d\n", cpu);
+		printk("Slave on cpu %d returning to normal service.\n", cpu);
 		set_curr_task(cpu, previous_current);
-		mca_init_leave(cpu);
 		ia64_mc_info.imi_rendez_checkin[cpu] = IA64_MCA_RENDEZ_CHECKIN_NOTDONE;
 		return;
 	}
@@ -1271,7 +1265,6 @@ ia64_init_handler(struct pt_regs *regs, 
 	}
 	printk("\nINIT dump complete.  Monarch on cpu %d returning to normal service.\n", cpu);
 	set_curr_task(cpu, previous_current);
-	mca_init_leave(cpu);
 	monarch_cpu = -1;
 	return;
 }
Index: linux/arch/ia64/kernel/mca_asm.S
=================================--- linux.orig/arch/ia64/kernel/mca_asm.S	2005-09-08 14:06:55.272410182 +1000
+++ linux/arch/ia64/kernel/mca_asm.S	2005-09-08 14:07:32.109131175 +1000
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

