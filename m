From: Ashok Raj <ashok.raj@intel.com>
Date: Wed, 09 Feb 2005 22:38:05 +0000
Subject: Re: [PATCH] CPU hotplug returns CPUs to SAL
Message-Id: <20050209143804.A32557@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1107970828.5478.22.camel@tdi>
In-Reply-To: <1107970828.5478.22.camel@tdi>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Wed, Feb 09, 2005 at 11:19:43AM -0700, Alex Williamson wrote:
> Hi Ashok,
>=20
>    Sorry I missed your patch.  Your assembly is certainly cleaner than
> mine.  We seem to have several differences in the state that actually
> gets saved and restored though.  For instance, I see you're saving k0,
> which is listed as scratch in the spec, but none of the fp, predicate,
> branch registers, region registers, or preserved general registers.
> Shouldn't a few more of those be preserved under "standard calling
> conventions"?  Also, what do you think about treating the saved state as
> a stack?  This could eventually allow the BSP to be sent off spinning in
> SAL.  Thanks,
>=20
> 	Alex

Hi Alex

attached is the newly diffed patches that will work on top of tony's=20
linux-2.6.11-release bk tree. It has Keith's fixes as well and i use the=20
TLB purge portions from what the mca code is already doing.

TBD: save/restore missing registers that are not saved today. I have tested
on tiger with good stress. (For stress testing, you will need the fix for
CONFIG_GENERIC_HARDIRQ which is still not in tony's release tree. Guess it
will get merged after 2.6.11 release, since iam changing some generic files)

Could you give it a try on your systems and give an udpate.

In the meantime, i will try to incorporate the missing pieces as another up=
date
to this patch.



---

Signed-off-by: Ashok Raj <ashok.raj@intel.com>

This patch is required to support cpu removal for IPF systems. Existing code
just fakes the real offline by keeping it run the idle thread, and polling
for the bit to re-appear in the cpu_state to get out of the idle loop.

For the cpu-offline to work correctly, we need to pass control of this CPU =

back to SAL so it can continue in the boot-rendez mode. This gives the
SAL control to not pick this cpu as the monarch processor for global MCA
events, and addition does not wait for this cpu to checkin with SAL
for global MCA events as well. The handoff is implemented as documented in =

SAL specification section 3.2.5.1 "OS_BOOT_RENDEZ to SAL return State"

Once the processor is in this state, the cpu can be woken up again by sendi=
ng=20
another wakeup IPI.=20

echo 0 > /sys/devices/system/cpu/cpu3/online

The above command will attempt to put cpu offline will handoff cpu to SAL=20

echo 1 > /sys/devices/system/cpu/cpu3/online

We will now issue a ipi to wakeup the processor using the cpu_up()

Handling idle threads

Idle threads are created upon demand if one is not available for that logic=
al
cpu number. If say a logical cpu 2 is removed, and a new cpu is inserted
the platform ACPI code handling CPU hotplug would find a new logical cpu
number to use. In which case if the number was cpu 2, the existing idle=20
thread is re-used.

Testing Done:=20
   Only on tiger4:
   Stable 24+hrs of repeated cpu online/offline of 3 processors in a tiger4=
 system
   with ltpstress, make -j's running.

   Early firmware does not work well when a processor is handed off to SAL,=
 and then
   injecting a recoverable MCA event, (atleast the tiger ones).=20

   Without injecting MCA, the processors can be handed off to SAL and can be
   brought back by another echo 1 to the appropriate online file.
---

 release_work-araj/arch/ia64/kernel/head.S    |  114 ++++++++++++++++++++++=
+++++
 release_work-araj/arch/ia64/kernel/mca_asm.S |   88 ++++++++++++--------
 release_work-araj/arch/ia64/kernel/process.c |   22 +----
 release_work-araj/arch/ia64/kernel/smpboot.c |   81 +++++++++++--------
 release_work-araj/include/asm-ia64/sal.h     |   31 +++++++
 5 files changed, 256 insertions(+), 80 deletions(-)

diff -puN arch/ia64/kernel/head.S~nbrz_no_macro arch/ia64/kernel/head.S
--- release_work/arch/ia64/kernel/head.S~nbrz_no_macro	2005-02-09 13:35:47.=
122311635 -0800
+++ release_work-araj/arch/ia64/kernel/head.S	2005-02-09 13:35:47.151608510=
 -0800
@@ -15,6 +15,8 @@
  * Copyright (C) 1999 Don Dugger <Don.Dugger@intel.com>
  * Copyright (C) 2002 Fenghua Yu <fenghua.yu@intel.com>
  *   -Optimize __ia64_save_fpu() and __ia64_load_fpu() for Itanium 2.
+ * Copyright (C) 2004 Ashok Raj <ashok.raj@intel.com>
+ *   Support for CPU Hotplug
  */
=20
 #include <linux/config.h>
@@ -29,6 +31,58 @@
 #include <asm/processor.h>
 #include <asm/ptrace.h>
 #include <asm/system.h>
+#include <asm/mca_asm.h>
+
+#ifdef CONFIG_HOTPLUG_CPU
+#define SAL_PSR_BITS_TO_SET				\
+	(IA64_PSR_AC | IA64_PSR_BN | IA64_PSR_MFH | IA64_PSR_MFL)
+
+#define SAVE_FROM_REG(src, ptr, dest)	\
+	mov dest=3Dsrc;;						\
+	st8 [ptr]=DEst,0x08
+
+#define RESTORE_REG(reg, ptr, _tmp)		\
+	ld8 _tmp=3D[ptr],0x08;;				\
+	mov reg=3D_tmp
+
+#define SAVE_BREAK_REGS(ptr, _idx, _breg, _dest)\
+	mov ar.lc=3DIA64_NUM_DBG_REGS-1;; 			\
+	mov _idx=3D0;; 								\
+1: 												\
+	SAVE_FROM_REG(_breg[_idx], ptr, _dest);;	\
+	add _idx=3D1,_idx;;							\
+	br.cloop.sptk.many 1b
+
+#define RESTORE_BREAK_REGS(ptr, _idx, _breg, _tmp, _lbl)\
+	mov ar.lc=3DIA64_NUM_DBG_REGS-1;;			\
+	mov _idx=3D0;;							\
+_lbl:  RESTORE_REG(_breg[_idx], ptr, _tmp);;	\
+	add _idx=3D1, _idx;;						\
+	br.cloop.sptk.many _lbl
+
+
+#define SAL_TO_OS_BOOT_HANDOFF_STATE_SAVE(_reg1,_reg2,_reg3,_reg4)	\
+	movl _reg2=3Dsal_state_for_booting_cpu;;				\
+	ld8 _reg1=3D[_reg2];;									\
+	SAVE_FROM_REG(b0,_reg1,_reg2);;						\
+	SAVE_FROM_REG(ar.k0,_reg1,_reg2);;					\
+	st8 [_reg1]=3Dr1,0x08;;								\
+	st8 [_reg1]=3Dr12,0x08;;								\
+	st8 [_reg1]=3Dr13,0x08;;								\
+	SAVE_FROM_REG(ar.fpsr,_reg1,_reg2);;				\
+	SAVE_FROM_REG(ar.rnat,_reg1,_reg2);;				\
+	SAVE_FROM_REG(ar.bspstore,_reg1,_reg2);;			\
+	SAVE_FROM_REG(cr.dcr,_reg1,_reg2);;					\
+	SAVE_FROM_REG(cr.iva,_reg1,_reg2);;					\
+	SAVE_FROM_REG(cr.pta,_reg1,_reg2);;					\
+	SAVE_FROM_REG(cr.itv,_reg1,_reg2);;					\
+	SAVE_FROM_REG(cr.pmv,_reg1,_reg2);;					\
+	SAVE_FROM_REG(cr.cmcv,_reg1,_reg2);;				\
+	SAVE_FROM_REG(cr.lrr0,_reg1,_reg2);;				\
+	SAVE_FROM_REG(cr.lrr1,_reg1,_reg2);;
+#else
+#define SAL_TO_OS_BOOT_HANDOFF_STATE_SAVE(a1,a2,a3,a4)
+#endif
=20
 	.section __special_page_section,"ax"
=20
@@ -142,6 +196,9 @@ start_ap:
 	;;
 1:	// now we are in virtual mode
=20
+	SAL_TO_OS_BOOT_HANDOFF_STATE_SAVE(r2,r3,r4,r5)
+	;;
+
 	// set IVT entry point---can't access I/O ports without it
 	movl r3=3Dia64_ivt
 	;;
@@ -993,4 +1050,61 @@ END(ia64_spinlock_contention)
=20
 #endif
=20
+#ifdef CONFIG_HOTPLUG_CPU
+GLOBAL_ENTRY(ia64_jump_to_sal)
+	alloc r16=3Dar.pfs,1,0,0,0;;
+	rsm psr.i  | psr.ic
+{
+	flushrs
+	srlz.i
+}
+	tpa r25=3Din0
+	movl r18=3Dtlb_purge_done;;
+	DATA_VA_TO_PA(r18);;
+	mov b1=3Dr18 	// Return location
+	movl r18=3Dia64_do_tlb_purge;;
+	DATA_VA_TO_PA(r18);;
+	mov b2=3Dr18 	// doing tlb_flush work.
+	mov ar.rsc=3D0  // Put RSE  in enforced lazy, LE mode
+	movl r17=1F;;
+	DATA_VA_TO_PA(r17);;
+	mov cr.iip=3Dr17
+	movl r16=3DSAL_PSR_BITS_TO_SET;;
+	mov cr.ipsr=3Dr16
+	mov cr.ifs=3Dr0;;
+	rfi;;
+1:
+	RESTORE_REG(b0, r25, r17);;
+	RESTORE_REG(ar.k0, r25, r17);;
+	ld8 r1=3D[r25],0x08;;
+	ld8 r12=3D[r25],0x08;;
+	ld8 r13=3D[r25],0x08;;
+	RESTORE_REG(ar.fpsr, r25, r17);;
+	RESTORE_REG(ar.rnat, r25, r17);;
+	RESTORE_REG(ar.bspstore, r25, r17);;
+	RESTORE_REG(cr.dcr, r25, r17);;
+	RESTORE_REG(cr.iva, r25, r17);;
+	RESTORE_REG(cr.pta, r25, r17);;
+	RESTORE_REG(cr.itv, r25, r17);;
+	RESTORE_REG(cr.pmv, r25, r17);;
+	RESTORE_REG(cr.cmcv, r25, r17);;
+	RESTORE_REG(cr.lrr0, r25, r17);;
+	RESTORE_REG(cr.lrr1, r25, r17);;
+	/*
+	 * Invalidate all TLB data/inst
+	 */
+
+	br.sptk.many b2;; // jump to tlb purge code
+
+tlb_purge_done:
+	/*
+	 * Now that we have done all the register restores
+	 * we are now ready for the big DIVE to SAL Land
+	 */
+	ssm psr.ic;;
+	srlz.d;;
+	br.ret.sptk.many b0;;
+END(ia64_jump_to_sal)
+#endif /* CONFIG_HOTPLUG_CPU */
+
 #endif /* CONFIG_SMP */
diff -puN arch/ia64/kernel/smpboot.c~nbrz_no_macro arch/ia64/kernel/smpboot=
.c
--- release_work/arch/ia64/kernel/smpboot.c~nbrz_no_macro	2005-02-09 13:35:=
47.126217885 -0800
+++ release_work-araj/arch/ia64/kernel/smpboot.c	2005-02-09 13:35:47.153561=
635 -0800
@@ -9,6 +9,7 @@
  * 02/07/31 David Mosberger <davidm@hpl.hp.com>	Switch over to hotplug-CPU=
 boot-sequence.
  *						smp_boot_cpus()/smp_commence() is replaced by
  *						smp_prepare_cpus()/__cpu_up()/smp_cpus_done().
+ * 04/06/21 Ashok Raj		<ashok.raj@intel.com> Added CPU Hotplug Support
  */
 #include <linux/config.h>
=20
@@ -58,6 +59,37 @@
 #define Dprintk(x...)
 #endif
=20
+#ifdef CONFIG_HOTPLUG_CPU
+/*
+ * Store all idle threads, this can be reused instead of creating
+ * a new thread. Also avoids complicated thread destroy functionality
+ * for idle threads.
+ */
+struct task_struct *idle_thread_array[NR_CPUS];
+
+/*
+ * Global array allocated for NR_CPUS at boot time
+ */
+struct sal_to_os_boot sal_boot_rendez_state[NR_CPUS];
+
+/*
+ * start_ap in head.S uses this to store current booting cpu
+ * info.
+ */
+struct sal_to_os_boot *sal_state_for_booting_cpu =3D &sal_boot_rendez_stat=
e[0];
+
+#define set_brendez_area(x) (sal_state_for_booting_cpu =3D &sal_boot_rende=
z_state[(x)]);
+
+#define get_idle_for_cpu(x)		(idle_thread_array[(x)])
+#define set_idle_for_cpu(x,p)	(idle_thread_array[(x)] =3D (p))
+
+#else
+
+#define get_idle_for_cpu(x)		(NULL)
+#define set_idle_for_cpu(x,p)
+#define set_brendez_area(x)
+#endif
+
=20
 /*
  * ITC synchronization related stuff:
@@ -345,7 +377,6 @@ start_secondary (void *unused)
 {
 	/* Early console may use I/O ports */
 	ia64_set_kr(IA64_KR_IO_BASE, __pa(ia64_iobase));
-
 	Dprintk("start_secondary: starting CPU 0x%x\n", hard_smp_processor_id());
 	efi_map_pal_code();
 	cpu_init();
@@ -384,6 +415,13 @@ do_boot_cpu (int sapicid, int cpu)
 		.done	=3D COMPLETION_INITIALIZER(c_idle.done),
 	};
 	DECLARE_WORK(work, do_fork_idle, &c_idle);
+
+ 	c_idle.idle =3D get_idle_for_cpu(cpu);
+ 	if (c_idle.idle) {
+		init_idle(c_idle.idle, cpu);
+ 		goto do_rest;
+	}
+
 	/*
 	 * We can't use kernel_thread since we must avoid to reschedule the child.
 	 */
@@ -396,10 +434,15 @@ do_boot_cpu (int sapicid, int cpu)
=20
 	if (IS_ERR(c_idle.idle))
 		panic("failed fork for CPU %d", cpu);
+
+	set_idle_for_cpu(cpu, c_idle.idle);
+
+do_rest:
 	task_for_booting_cpu =3D c_idle.idle;
=20
 	Dprintk("Sending wakeup vector %lu to AP 0x%x/0x%x.\n", ap_wakeup_vector,=
 cpu, sapicid);
=20
+	set_brendez_area(cpu);
 	platform_send_ipi(cpu, ap_wakeup_vector, IA64_IPI_DM_INT, 0);
=20
 	/*
@@ -570,16 +613,6 @@ void __devinit smp_prepare_boot_cpu(void
 #ifdef CONFIG_HOTPLUG_CPU
 extern void fixup_irqs(void);
 /* must be called with cpucontrol mutex held */
-static int __devinit cpu_enable(unsigned int cpu)
-{
-	per_cpu(cpu_state,cpu) =3D CPU_UP_PREPARE;
-	wmb();
-
-	while (!cpu_online(cpu))
-		cpu_relax();
-	return 0;
-}
-
 int __cpu_disable(void)
 {
 	int cpu =3D smp_processor_id();
@@ -592,7 +625,7 @@ int __cpu_disable(void)
=20
 	fixup_irqs();
 	local_flush_tlb_all();
-	printk ("Disabled cpu %u\n", smp_processor_id());
+	cpu_clear(cpu, cpu_callin_map);
 	return 0;
 }
=20
@@ -604,12 +637,7 @@ void __cpu_die(unsigned int cpu)
 		/* They ack this in play_dead by setting CPU_DEAD */
 		if (per_cpu(cpu_state, cpu) =3D CPU_DEAD)
 		{
-			/*
-			 * TBD: Enable this when physical removal
-			 * or when we put the processor is put in
-			 * SAL_BOOT_RENDEZ mode
-			 * cpu_clear(cpu, cpu_callin_map);
-			 */
+			printk ("CPU %d is now offline\n", cpu);
 			return;
 		}
 		msleep(100);
@@ -617,11 +645,6 @@ void __cpu_die(unsigned int cpu)
  	printk(KERN_ERR "CPU %u didn't die...\n", cpu);
 }
 #else /* !CONFIG_HOTPLUG_CPU */
-static int __devinit cpu_enable(unsigned int cpu)
-{
-	return 0;
-}
-
 int __cpu_disable(void)
 {
 	return -ENOSYS;
@@ -663,16 +686,12 @@ __cpu_up (unsigned int cpu)
 		return -EINVAL;
=20
 	/*
-	 * Already booted.. just enable and get outa idle lool
+	 * Already booted cpu? not valid anymore since we dont
+	 * do idle loop tightspin anymore.
 	 */
 	if (cpu_isset(cpu, cpu_callin_map))
-	{
-		cpu_enable(cpu);
-		local_irq_enable();
-		while (!cpu_isset(cpu, cpu_online_map))
-			mb();
-		return 0;
-	}
+		return -EINVAL;
+
 	/* Processor goes to start_secondary(), sets online flag */
 	ret =3D do_boot_cpu(sapicid, cpu);
 	if (ret < 0)
diff -puN arch/ia64/kernel/process.c~nbrz_no_macro arch/ia64/kernel/process=
.c
--- release_work/arch/ia64/kernel/process.c~nbrz_no_macro	2005-02-09 13:35:=
47.131100698 -0800
+++ release_work-araj/arch/ia64/kernel/process.c	2005-02-09 13:35:47.154538=
197 -0800
@@ -3,6 +3,7 @@
  *
  * Copyright (C) 1998-2003 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
+ * 04/11/17 Ashok Raj	<ashok.raj@intel.com> Added CPU Hotplug Support
  */
 #define __KERNEL_SYSCALLS__	/* see <asm/unistd.h> */
 #include <linux/config.h>
@@ -200,27 +201,20 @@ default_idle (void)
 static inline void play_dead(void)
 {
 	extern void ia64_cpu_local_tick (void);
+	unsigned int this_cpu =3D smp_processor_id();
+
 	/* Ack it */
 	__get_cpu_var(cpu_state) =3D CPU_DEAD;
=20
-	/* We shouldn't have to disable interrupts while dead, but
-	 * some interrupts just don't seem to go away, and this makes
-	 * it "work" for testing purposes. */
 	max_xtp();
 	local_irq_disable();
-	/* Death loop */
-	while (__get_cpu_var(cpu_state) !=3D CPU_UP_PREPARE)
-		cpu_relax();
-
+	idle_task_exit();
+	ia64_jump_to_sal(&sal_boot_rendez_state[this_cpu]);
 	/*
-	 * Enable timer interrupts from now on
-	 * Not required if we put processor in SAL_BOOT_RENDEZ mode.
+	 * The above is a point of no-return, the processor is
+	 * expected to be in SAL loop now.
 	 */
-	local_flush_tlb_all();
-	cpu_set(smp_processor_id(), cpu_online_map);
-	wmb();
-	ia64_cpu_local_tick ();
-	local_irq_enable();
+	BUG();
 }
 #else
 static inline void play_dead(void)
diff -puN arch/ia64/kernel/mca_asm.S~nbrz_no_macro arch/ia64/kernel/mca_asm=
.S
--- release_work/arch/ia64/kernel/mca_asm.S~nbrz_no_macro	2005-02-09 13:35:=
47.135983510 -0800
+++ release_work-araj/arch/ia64/kernel/mca_asm.S	2005-02-09 13:35:47.155514=
760 -0800
@@ -110,46 +110,19 @@
 	.global ia64_os_mca_dispatch_end
 	.global ia64_sal_to_os_handoff_state
 	.global	ia64_os_to_sal_handoff_state
+	.global ia64_do_tlb_purge
=20
 	.text
 	.align 16
=20
-ia64_os_mca_dispatch:
-
-	// Serialize all MCA processing
-	mov	r3=3D1;;
-	LOAD_PHYSICAL(p0,r2,ia64_mca_serialize);;
-ia64_os_mca_spin:
-	xchg8	r4=3D[r2],r3;;
-	cmp.ne	p6,p0=3Dr4,r0
-(p6)	br ia64_os_mca_spin
-
-	// Save the SAL to OS MCA handoff state as defined
-	// by SAL SPEC 3.0
-	// NOTE : The order in which the state gets saved
-	//	  is dependent on the way the C-structure
-	//	  for ia64_mca_sal_to_os_state_t has been
-	//	  defined in include/asm/mca.h
-	SAL_TO_OS_MCA_HANDOFF_STATE_SAVE(r2)
-	;;
-
-	// LOG PROCESSOR STATE INFO FROM HERE ON..
-begin_os_mca_dump:
-	br	ia64_os_mca_proc_state_dump;;
-
-ia64_os_mca_done_dump:
-
-	LOAD_PHYSICAL(p0,r16,ia64_sal_to_os_handoff_state+56)
-	;;
-	ld8 r18=3D[r16]		// Get processor state parameter on existing PALE_CHECK.
-	;;
-	tbit.nz p6,p7=3Dr18,60
-(p7)	br.spnt done_tlb_purge_and_reload
-
-	// The following code purges TC and TR entries. Then reload all TC entrie=
s.
-	// Purge percpu data TC entries.
-begin_tlb_purge_and_reload:
+/*
+ * Just the TLB purge part is moved to a separate function
+ * so we can re-use the code for cpu hotplug code as well
+ * Caller should now setup b1, so we can branch once the
+ * tlb flush is complete.
+ */
=20
+ia64_do_tlb_purge:
 #define O(member)	IA64_CPUINFO_##member##_OFFSET
=20
 	GET_THIS_PADDR(r2, cpu_info)	// load phys addr of cpu_info into r2
@@ -230,6 +203,51 @@ begin_tlb_purge_and_reload:
 	;;
 	srlz.i
 	;;
+	// Now branch away to caller.
+	br.sptk.many b1
+	;;
+
+ia64_os_mca_dispatch:
+
+	// Serialize all MCA processing
+	mov	r3=3D1;;
+	LOAD_PHYSICAL(p0,r2,ia64_mca_serialize);;
+ia64_os_mca_spin:
+	xchg8	r4=3D[r2],r3;;
+	cmp.ne	p6,p0=3Dr4,r0
+(p6)	br ia64_os_mca_spin
+
+	// Save the SAL to OS MCA handoff state as defined
+	// by SAL SPEC 3.0
+	// NOTE : The order in which the state gets saved
+	//	  is dependent on the way the C-structure
+	//	  for ia64_mca_sal_to_os_state_t has been
+	//	  defined in include/asm/mca.h
+	SAL_TO_OS_MCA_HANDOFF_STATE_SAVE(r2)
+	;;
+
+	// LOG PROCESSOR STATE INFO FROM HERE ON..
+begin_os_mca_dump:
+	br	ia64_os_mca_proc_state_dump;;
+
+ia64_os_mca_done_dump:
+
+	LOAD_PHYSICAL(p0,r16,ia64_sal_to_os_handoff_state+56)
+	;;
+	ld8 r18=3D[r16]		// Get processor state parameter on existing PALE_CHECK.
+	;;
+	tbit.nz p6,p7=3Dr18,60
+(p7)	br.spnt done_tlb_purge_and_reload
+
+	// The following code purges TC and TR entries. Then reload all TC entrie=
s.
+	// Purge percpu data TC entries.
+begin_tlb_purge_and_reload:
+	movl r18=3Dia64_reload_tr;;
+	LOAD_PHYSICAL(p0,r18,ia64_reload_tr);;
+	mov b1=3Dr18;;
+	br.sptk.many ia64_do_tlb_purge;;
+
+ia64_reload_tr:
 	// Finally reload the TR registers.
 	// 1. Reload DTR/ITR registers for kernel.
 	mov r18=3DKERNEL_TR_PAGE_SHIFT<<2
diff -puN include/asm-ia64/sal.h~nbrz_no_macro include/asm-ia64/sal.h
--- release_work/include/asm-ia64/sal.h~nbrz_no_macro	2005-02-09 13:35:47.1=
39889760 -0800
+++ release_work-araj/include/asm-ia64/sal.h	2005-02-09 13:35:47.156491322 =
-0800
@@ -832,6 +832,37 @@ extern int ia64_sal_oemcall_nolock(struc
 				   u64, u64, u64, u64, u64);
 extern int ia64_sal_oemcall_reentrant(struct ia64_sal_retval *, u64, u64, =
u64,
 				      u64, u64, u64, u64, u64);
+#ifdef CONFIG_HOTPLUG_CPU
+/*
+ * System Abstraction Layer Specification
+ * Section 3.2.5.1: OS_BOOT_RENDEZ to SAL return State.
+ */
+struct sal_to_os_boot {
+	u64	br0;		/* return addr into SAL boot rendez routine */
+	u64 k0;
+	u64 gr1;		/* SAL:GP */
+	u64 gr12;		/* SAL:SP */
+	u64 gr13;		/* SAL: Task Pointer */
+	u64 fpsr;
+	u64 rnat;
+	u64 bspstore;
+	u64 dcr;		/* Default Control Register */
+	u64 iva;
+	u64 pta;
+	u64 itv;
+	u64 pmv;
+	u64 cmcv;
+	u64 lrr0;
+	u64 lrr1;
+};
+
+/*
+ * Global array allocated for NR_CPUS at boot time
+ */
+extern struct sal_to_os_boot sal_boot_rendez_state[NR_CPUS];
+
+extern void ia64_jump_to_sal(struct sal_to_os_boot *);
+#endif
=20
 extern void ia64_sal_handler_init(void *entry_point, void *gpval);
=20
_
