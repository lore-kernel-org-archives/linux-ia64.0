From: Ashok Raj <ashok.raj@intel.com>
Date: Tue, 07 Dec 2004 06:01:59 +0000
Subject: CPU hot-remove - Handoff Processor to SAL
Message-Id: <20041206220159.A7973@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hello All

This patch is for handing off a processor to SAL when a CPU offline operati=
on is=20
performed on a CPU. Extensive testing has been done with offlining during=20
stress for 24+ hrs on a tiger4 system.

Caveats: Current SAL (on tiger4) doesnt seem to deal well, when number of c=
pus
are dropped when injecting MCA errors. So YMMV, but without injecting MCA
the production bios seems to work as expected.

TBD: on other architectures. I havn't tested on other platforms. If someone
could pass on results, that would be great. I will attempt to test when i g=
et a
chance.

SGI platforms seem to ask for new SAL (4.0), which is probably not yet rele=
ased.

I borrowed lots of code to perform TLB purge from mca code. So i converted =
the code=20
to re-use the same code to avoid duplication.

I think Russ Anderson was making some changes in this area for per-cpu allo=
cation=20
to store mca data area. That may need to be re-tro fitted, it shouldnt be l=
ots
of change, since i just relocated the code to use jumps.

Patch attached, Tony, please consider when 2.6.11 opens up. Testing by othe=
r=20
platforms would be great.

--=20
Cheers,
Ashok Raj
- Open Source Technology Center
  Intel Corporation.


---

cpu_sal_handoff : Handoff offline CPU to SAL

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

 linux-2.6.10-rc2-bk14-araj/arch/ia64/kernel/head.S    |  115 +++++++++++++=
+++++
 linux-2.6.10-rc2-bk14-araj/arch/ia64/kernel/mca_asm.S |   86 +++++++------
 linux-2.6.10-rc2-bk14-araj/arch/ia64/kernel/process.c |   18 --
 linux-2.6.10-rc2-bk14-araj/arch/ia64/kernel/smpboot.c |   77 ++++++++----
 linux-2.6.10-rc2-bk14-araj/include/asm-ia64/sal.h     |   31 ++++
 5 files changed, 253 insertions(+), 74 deletions(-)

diff -puN arch/ia64/kernel/head.S~nbrz_no_macro arch/ia64/kernel/head.S
--- linux-2.6.10-rc2-bk14/arch/ia64/kernel/head.S~nbrz_no_macro	2004-11-30 =
14:28:07.000000000 -0800
+++ linux-2.6.10-rc2-bk14-araj/arch/ia64/kernel/head.S	2004-12-02 16:20:54.=
000000000 -0800
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
@@ -120,6 +174,9 @@ start_ap:
 	;;
 1:	// now we are in virtual mode
=20
+	SAL_TO_OS_BOOT_HANDOFF_STATE_SAVE(r2,r3,r4,r5)
+	;;
+
 	// set IVT entry point---can't access I/O ports without it
 	movl r3=3Dia64_ivt
 	;;
@@ -246,6 +303,7 @@ alive_msg_end:
 	ld8 out0=3D[r3]
 	br.call.sptk.many b0=3Dconsole_print
 self:	br.sptk.many self		// endless loop
+
 END(_start)
=20
 GLOBAL_ENTRY(ia64_save_debug_regs)
@@ -982,4 +1040,61 @@ END(ia64_spinlock_contention)
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
--- linux-2.6.10-rc2-bk14/arch/ia64/kernel/smpboot.c~nbrz_no_macro	2004-11-=
30 14:28:07.000000000 -0800
+++ linux-2.6.10-rc2-bk14-araj/arch/ia64/kernel/smpboot.c	2004-11-30 14:28:=
07.000000000 -0800
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
@@ -347,7 +379,6 @@ start_secondary (void *unused)
=20
 	/* Early console may use I/O ports */
 	ia64_set_kr(IA64_KR_IO_BASE, __pa(ia64_iobase));
-
 	Dprintk("start_secondary: starting CPU 0x%x\n", hard_smp_processor_id());
 	efi_map_pal_code();
 	cpu_init();
@@ -385,6 +416,13 @@ do_boot_cpu (int sapicid, int cpu)
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
@@ -397,10 +435,15 @@ do_boot_cpu (int sapicid, int cpu)
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
@@ -571,16 +614,6 @@ void __devinit smp_prepare_boot_cpu(void
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
@@ -593,6 +626,7 @@ int __cpu_disable(void)
=20
 	fixup_irqs();
 	local_flush_tlb_all();
+	cpu_clear(cpu, cpu_callin_map);
 	printk ("Disabled cpu %u\n", smp_processor_id());
 	return 0;
 }
@@ -609,8 +643,10 @@ void __cpu_die(unsigned int cpu)
 			 * TBD: Enable this when physical removal
 			 * or when we put the processor is put in
 			 * SAL_BOOT_RENDEZ mode
-			 * cpu_clear(cpu, cpu_callin_map);
+			 cpu_clear(cpu, cpu_callin_map);
+			 printk ("Clearing cpu_callin_map\n");
 			 */
+			printk ("Now cpu %d is dead\n", cpu);
 			return;
 		}
 		current->state =3D TASK_UNINTERRUPTIBLE;
@@ -619,11 +655,6 @@ void __cpu_die(unsigned int cpu)
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
@@ -665,16 +696,12 @@ __cpu_up (unsigned int cpu)
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
--- linux-2.6.10-rc2-bk14/arch/ia64/kernel/process.c~nbrz_no_macro	2004-11-=
30 14:28:07.000000000 -0800
+++ linux-2.6.10-rc2-bk14-araj/arch/ia64/kernel/process.c	2004-11-30 14:28:=
07.000000000 -0800
@@ -3,6 +3,7 @@
  *
  * Copyright (C) 1998-2003 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
+ * 04/11/17 Ashok Raj	<ashok.raj@intel.com> Added CPU Hotplug Support
  */
 #define __KERNEL_SYSCALLS__	/* see <asm/unistd.h> */
 #include <linux/config.h>
@@ -194,6 +195,8 @@ default_idle (void)
 static inline void play_dead(void)
 {
 	extern void ia64_cpu_local_tick (void);
+	unsigned int this_cpu =3D smp_processor_id();
+
 	/* Ack it */
 	__get_cpu_var(cpu_state) =3D CPU_DEAD;
=20
@@ -202,19 +205,8 @@ static inline void play_dead(void)
 	 * it "work" for testing purposes. */
 	max_xtp();
 	local_irq_disable();
-	/* Death loop */
-	while (__get_cpu_var(cpu_state) !=3D CPU_UP_PREPARE)
-		cpu_relax();
-
-	/*
-	 * Enable timer interrupts from now on
-	 * Not required if we put processor in SAL_BOOT_RENDEZ mode.
-	 */
-	local_flush_tlb_all();
-	cpu_set(smp_processor_id(), cpu_online_map);
-	wmb();
-	ia64_cpu_local_tick ();
-	local_irq_enable();
+	ia64_jump_to_sal(&sal_boot_rendez_state[this_cpu]);
+	printk ("Huh? after jump_to_sal? I really shoudn't be here!!\n");
 }
 #else
 static inline void play_dead(void)
diff -puN arch/ia64/kernel/mca_asm.S~nbrz_no_macro arch/ia64/kernel/mca_asm=
.S
--- linux-2.6.10-rc2-bk14/arch/ia64/kernel/mca_asm.S~nbrz_no_macro	2004-11-=
30 14:28:07.000000000 -0800
+++ linux-2.6.10-rc2-bk14-araj/arch/ia64/kernel/mca_asm.S	2004-11-30 14:28:=
07.000000000 -0800
@@ -107,52 +107,22 @@
 	.global	ia64_mca_stackframe
 	.global	ia64_mca_bspstore
 	.global ia64_init_stack
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
+ * return address in b1
+ */
+ia64_do_tlb_purge:
 	mov r16=3Dcr.lid
 	LOAD_PHYSICAL(p0,r17,ia64_mca_tlb_list) // Physical address of ia64_mca_t=
lb_list
 	mov r19=3D0
 	mov r20=3DNR_CPUS
 	;;
 1:	cmp.eq p6,p7=3Dr19,r20
-(p6)	br.spnt.few err
+(p6)	br.spnt.few err1
 	ld8 r18=3D[r17],IA64_MCA_TLB_INFO_SIZE
 	;;
 	add r19=3D1,r19
@@ -237,6 +207,50 @@ begin_tlb_purge_and_reload:
 	;;
 	srlz.i
 	;;
+err1:
+	br.sptk.many  b1
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
+	movl r18=3Dia64_done_tlb_purge;;
+	DATA_VA_TO_PA(r18);;
+	mov b1=3Dr18;;
+	br.sptk.many ia64_do_tlb_purge;;
+ia64_done_tlb_purge:
 	// Finally reload the TR registers.
 	// 1. Reload DTR/ITR registers for kernel.
 	mov r18=3DKERNEL_TR_PAGE_SHIFT<<2
diff -puN include/asm-ia64/sal.h~nbrz_no_macro include/asm-ia64/sal.h
--- linux-2.6.10-rc2-bk14/include/asm-ia64/sal.h~nbrz_no_macro	2004-11-30 1=
4:28:07.000000000 -0800
+++ linux-2.6.10-rc2-bk14-araj/include/asm-ia64/sal.h	2004-11-30 14:28:07.0=
00000000 -0800
@@ -828,6 +828,37 @@ extern int ia64_sal_oemcall_nolock(struc
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
 #endif /* __ASSEMBLY__ */
=20
_
