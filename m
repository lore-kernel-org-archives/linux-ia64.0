From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 16 Nov 2000 07:59:26 +0000
Subject: [Linux-ia64] kernel update (relative to 2.4.0-test10)
Message-Id: <marc-linux-ia64-105590678205730@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Here is the latest IA-64 kernel update.  It's still relative to
test10.  This patch is rather big as it contains the first batch of
code required for the SGI SN1 machine.  Other than that, the following
changes were made:

 - Asit: added workaround for dbr[] access errata
 - Jonathan Nicklin, Patrick O'Rourke: changed locore code to execute
   in virtual mode; with this change, only the (rare) page table accesses a=
re
   now done in physical mode
 - Stephane: cleanup of sal.h; fix unaligned handler to always send SIGBUS
   (not SIGSEGV)
 - Kanoj: fix for ia64_pall_call_static
 - added send_ipi/inX/outX machvec entries; note: both IPI and inX/outX
   are architected in IA-64 and there shouldn't be any need for these
   machvecs; however, there are unfortunately some machines that don't
   follow the architecture and that's why we had to add them; if you're
   a system designer, please follow the IA-64 architecture and do not
   use these machvec entries
 - DCR is now initialized such that all faults are deferred (as requested
   by Intel)
 - cleaned up PCI code and pgtable.h a bit
 - ptce loop info is now maintained per CPU (mostly for cleanliness)
 - width of region id registers is now determined at boot time via
   a call to PAL
 - fix unwind code so it doesn't hang when removing a kernel module

As usual, the full patch can be found at:

 ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64

The file name is linux-2.4.0-test10-ia64-001115.diff*

Enjoy,

	--david

diff -urN linux-davidm/arch/ia64/config.in linux-2.4.0-test10-lia/arch/ia64=
/config.in
--- linux-davidm/arch/ia64/config.in	Wed Nov 15 23:09:41 2000
+++ linux-2.4.0-test10-lia/arch/ia64/config.in	Wed Nov 15 17:52:03 2000
@@ -48,6 +48,10 @@
 	  bool '   Enable Itanium B1-step specific code' CONFIG_ITANIUM_B1_SPECIF=
IC
 	  bool '   Enable Itanium B2-step specific code' CONFIG_ITANIUM_B2_SPECIF=
IC
 	fi
+	bool '  Enable Itanium C-step specific code' CONFIG_ITANIUM_CSTEP_SPECIFIC
+	if [ "$CONFIG_ITANIUM_CSTEP_SPECIFIC" =3D "y" ]; then
+	  bool '   Enable Itanium C0-step specific code' CONFIG_ITANIUM_C0_SPECIF=
IC
+	fi
 	bool '  Force interrupt redirection' CONFIG_IA64_HAVE_IRQREDIR
 	bool '  Enable use of global TLB purge instruction (ptc.g)' CONFIG_ITANIU=
M_PTCG
 	bool '  Enable SoftSDV hacks' CONFIG_IA64_SOFTSDV_HACKS
diff -urN linux-davidm/arch/ia64/kernel/entry.S linux-2.4.0-test10-lia/arch=
/ia64/kernel/entry.S
--- linux-davidm/arch/ia64/kernel/entry.S	Wed Nov 15 23:09:41 2000
+++ linux-2.4.0-test10-lia/arch/ia64/kernel/entry.S	Wed Nov 15 17:52:56 2000
@@ -11,6 +11,17 @@
  * Copyright (C) 1999 Don Dugger <Don.Dugger@intel.com>
  */
 /*
+ * ia64_switch_to now places correct virtual mapping in in TR2 for
+ * kernel stack. This allows us to handle interrupts without changing
+ * to physical mode.
+ *
+ * ar.k4 is now used to hold last virtual map address
+ *=20
+ * Jonathan Nickin	<nicklin@missioncriticallinux.com>
+ * Patrick O'Rourke	<orourke@missioncriticallinux.com>
+ * 11/07/2000
+ /
+/*
  * Global (preserved) predicate usage on syscall entry/exit path:
  *
  *	pKern:		See entry.h.
@@ -27,7 +38,8 @@
 #include <asm/processor.h>
 #include <asm/unistd.h>
 #include <asm/asmmacro.h>
-
+#include <asm/pgtable.h>
+=09
 #include "entry.h"
=20
 	.text
@@ -98,6 +110,8 @@
 	br.ret.sptk.many rp
 END(sys_clone)
=20
+#define KSTACK_TR	2
+
 /*
  * prev_task <- ia64_switch_to(struct task_struct *next)
  */
@@ -108,22 +122,55 @@
 	UNW(.body)
=20
 	adds r22=3DIA64_TASK_THREAD_KSP_OFFSET,r13
-	dep r18=3D-1,r0,0,61	// build mask 0x1fffffffffffffff
+	mov r27=3Dar.k4
+	dep r20=3D0,in0,61,3		// physical address of "current"
+	;;
+	st8 [r22]=3Dsp			// save kernel stack pointer of old task
+	shr.u r26=3Dr20,_PAGE_SIZE_256M
+	;;
+	cmp.eq p7,p6=3Dr26,r0		// check < 256M
 	adds r21=3DIA64_TASK_THREAD_KSP_OFFSET,in0
 	;;
-	st8 [r22]=3Dsp		// save kernel stack pointer of old task
-	ld8 sp=3D[r21]		// load kernel stack pointer of new task
-	and r20=3Din0,r18		// physical address of "current"
-	;;
-	mov ar.k6=3Dr20		// copy "current" into ar.k6
-	mov r8=3Dr13		// return pointer to previously running task
-	mov r13=3Din0		// set "current" pointer
+	/*
+	 * If we've already mapped this task's page, we can skip doing it
+	 * again.
+	 */
+(p6)	cmp.eq p7,p6=3Dr26,r27
+(p6)	br.cond.dpnt.few .map
+	;;
+.done:	ld8 sp=3D[r21]			// load kernel stack pointer of new task
+(p6)	ssm psr.ic			// if we we had to map, renable the psr.ic bit FIRST!!!
 	;;
+(p6)	srlz.d
+	mov ar.k6=3Dr20			// copy "current" into ar.k6
+	mov r8=3Dr13			// return pointer to previously running task
+	mov r13=3Din0			// set "current" pointer
+	;;
+(p6)	ssm psr.i			// renable psr.i AFTER the ic bit is serialized
 	DO_LOAD_SWITCH_STACK( )
+
 #ifdef CONFIG_SMP
-	sync.i			// ensure "fc"s done by this CPU are visible on other CPUs
-#endif
-	br.ret.sptk.few rp
+	sync.i				// ensure "fc"s done by this CPU are visible on other CPUs
+#endif=20
+	br.ret.sptk.few rp		// boogie on out in new context
+
+.map:
+	rsm psr.i | psr.ic
+	movl r25=3D__DIRTY_BITS|_PAGE_PL_0|_PAGE_AR_RWX
+	;;
+	srlz.d
+	or r23=3Dr25,r20			// construct PA | page properties
+	mov r25=3D_PAGE_SIZE_256M<<2
+	;;
+	mov cr.itir=3Dr25
+	mov cr.ifa=3Din0			// VA of next task...
+	;;
+	mov r25=3DKSTACK_TR		// use tr entry #2...
+	mov ar.k4=3Dr26			// remember last page we mapped...
+	;;
+	itr.d dtr[r25]=3Dr23		// wire in new mapping...
+	br.cond.sptk.many .done
+	;;
 END(ia64_switch_to)
=20
 #ifndef CONFIG_IA64_NEW_UNWIND
@@ -611,14 +658,13 @@
 	mov ar.ccv=3Dr1
 	mov ar.fpsr=3Dr13
 	mov b0=3Dr14
-	// turn off interrupts, interrupt collection, & data translation
-	rsm psr.i | psr.ic | psr.dt
+	// turn off interrupts, interrupt collection
+	rsm psr.i | psr.ic
 	;;
 	srlz.i			// EAS 2.5
 	mov b7=3Dr15
 	;;
 	invala			// invalidate ALAT
-	dep r12=3D0,r12,61,3	// convert sp to physical address
 	bsw.0;;			// switch back to bank 0 (must be last in insn group)
 	;;
 #ifdef CONFIG_ITANIUM_ASTEP_SPECIFIC
@@ -1091,7 +1137,7 @@
 	data8 sys_setpriority
 	data8 sys_statfs
 	data8 sys_fstatfs
-	data8 ia64_ni_syscall
+	data8 ia64_ni_syscall			// 1105
 	data8 sys_semget
 	data8 sys_semop
 	data8 sys_semctl
diff -urN linux-davidm/arch/ia64/kernel/fw-emu.c linux-2.4.0-test10-lia/arc=
h/ia64/kernel/fw-emu.c
--- linux-davidm/arch/ia64/kernel/fw-emu.c	Mon Oct  9 17:54:54 2000
+++ linux-2.4.0-test10-lia/arch/ia64/kernel/fw-emu.c	Wed Nov 15 17:53:32 20=
00
@@ -402,7 +402,6 @@
 	sal_systab->sal_rev_minor =3D 1;
 	sal_systab->sal_rev_major =3D 0;
 	sal_systab->entry_count =3D 1;
-	sal_systab->ia32_bios_present =3D 0;
=20
 #ifdef CONFIG_IA64_GENERIC
         strcpy(sal_systab->oem_id, "Generic");
diff -urN linux-davidm/arch/ia64/kernel/head.S linux-2.4.0-test10-lia/arch/=
ia64/kernel/head.S
--- linux-davidm/arch/ia64/kernel/head.S	Wed Nov 15 23:09:41 2000
+++ linux-2.4.0-test10-lia/arch/ia64/kernel/head.S	Wed Nov 15 17:54:03 2000
@@ -168,6 +168,11 @@
 	add r19=3DIA64_NUM_DBG_REGS*8,in0
 	;;
 1:	mov r16=DBr[r18]
+#if defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_BSTEP=
_SPECIFIC) \
+    || defined(CONFIG_ITANIUM_C0_SPECIFIC)
+	;;
+	srlz.d
+#endif
 	mov r17=3Dibr[r18]
 	add r18=3D1,r18
 	;;
@@ -195,6 +200,11 @@
 	add r18=3D1,r18
 	;;
 	mov dbr[r18]=3Dr16
+#if defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_BSTEP=
_SPECIFIC) \
+    || defined(CONFIG_ITANIUM_C0_SPECIFIC)
+	;;
+	srlz.d
+#endif
 	mov ibr[r18]=3Dr17
 	br.cloop.sptk.few 1b
 	;;
diff -urN linux-davidm/arch/ia64/kernel/ivt.S linux-2.4.0-test10-lia/arch/i=
a64/kernel/ivt.S
--- linux-davidm/arch/ia64/kernel/ivt.S	Wed Nov 15 23:09:41 2000
+++ linux-2.4.0-test10-lia/arch/ia64/kernel/ivt.S	Wed Nov 15 17:54:59 2000
@@ -44,20 +44,10 @@
 #include <asm/system.h>
 #include <asm/unistd.h>
=20
-#define MINSTATE_START_SAVE_MIN	/* no special action needed */
-#define MINSTATE_END_SAVE_MIN									\
-	or r2=3Dr2,r14;		/* make first base a kernel virtual address */			\
-	or r12=3Dr12,r14;		/* make sp a kernel virtual address */				\
-	or r13=3Dr13,r14;		/* make `current' a kernel virtual address */			\
-	bsw.1;			/* switch back to bank 1 (must be last in insn group) */	\
-	;;
-
+#define MINSTATE_VIRT	/* needed by minstate.h */
 #include "minstate.h"
=20
 #define FAULT(n)									\
-	rsm psr.dt;			/* avoid nested faults due to TLB misses... */	\
-	;;										\
-	srlz.d;				/* ensure everyone knows psr.dt is off... */	\
 	mov r31=3Dpr;									\
 	mov r19=3Dn;;			/* prepare to save predicates */		\
 	br.cond.sptk.many dispatch_to_fault_handler
@@ -419,6 +409,10 @@
 	//-----------------------------------------------------------------------=
------------
 	// call do_page_fault (predicates are in r31, psr.dt is off, r16 is fault=
ing address)
 page_fault:
+	ssm psr.dt
+	;;
+	srlz.i
+	;;
 	SAVE_MIN_WITH_COVER
 	//
 	// Copy control registers to temporary registers, then turn on psr bits,
@@ -430,7 +424,7 @@
 	mov r9=3Dcr.isr
 	adds r3=3D8,r2				// set up second base pointer
 	;;
-	ssm psr.ic | psr.dt
+	ssm psr.ic
 	;;
 	srlz.i					// guarantee that interrupt collection is enabled
 	;;
@@ -725,16 +719,14 @@
 	mov r16=3Dcr.iim
 	mov r17=3D__IA64_BREAK_SYSCALL
 	mov r31=3Dpr		// prepare to save predicates
-	rsm psr.dt		// avoid nested faults due to TLB misses...
 	;;
-	srlz.d			// ensure everyone knows psr.dt is off...
 	cmp.eq p0,p7=3Dr16,r17	// is this a system call? (p7 <- false, if so)
 (p7)	br.cond.spnt.many non_syscall
=20
 	SAVE_MIN				// uses r31; defines r2:
=20
-	// turn interrupt collection and data translation back on:
-	ssm psr.ic | psr.dt
+	// turn interrupt collection back on:
+	ssm psr.ic
 	;;
 	srlz.i					// guarantee that interrupt collection is enabled
 	cmp.eq pSys,pNonSys=3Dr0,r0		// set pSys=3D1, pNonSys=3D0
@@ -795,17 +787,14 @@
 	.align 1024
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x3000 Entry 12 (size 64 bundles) External Interrupt (4)
-	rsm psr.dt		// avoid nested faults due to TLB misses...
-	;;
-	srlz.d			// ensure everyone knows psr.dt is off...
 	mov r31=3Dpr		// prepare to save predicates
 	;;
=20
 	SAVE_MIN_WITH_COVER	// uses r31; defines r2 and r3
-	ssm psr.ic | psr.dt	// turn interrupt collection and data translation bac=
k on
+	ssm psr.ic		// turn interrupt collection
 	;;
 	adds r3=3D8,r2		// set up second base pointer for SAVE_REST
-	srlz.i			// ensure everybody knows psr.ic and psr.dt are back on
+	srlz.i			// ensure everybody knows psr.ic is back on
 	;;
 	SAVE_REST
 	;;
@@ -855,7 +844,7 @@
 	// The "alloc" can cause a mandatory store which could lead to
 	// an "Alt DTLB" fault which we can handle only if psr.ic is on.
 	//
-	ssm psr.ic | psr.dt
+	ssm psr.ic
 	;;
 	srlz.i		// guarantee that interrupt collection is enabled
 	;;
@@ -900,7 +889,7 @@
 	SAVE_MIN
 	;;
 	mov r14=3Dcr.isr
-	ssm psr.ic | psr.dt
+	ssm psr.ic
 	;;
 	srlz.i					// guarantee that interrupt collection is enabled
 	;;
@@ -985,8 +974,8 @@
 	mov r8=3Dcr.iim			// get break immediate (must be done while psr.ic is of=
f)
 	adds r3=3D8,r2			// set up second base pointer for SAVE_REST
=20
-	// turn interrupt collection and data translation back on:
-	ssm psr.ic | psr.dt
+	// turn interrupt collection back on:
+	ssm psr.ic
 	;;
 	srlz.i				// guarantee that interrupt collection is enabled
 	;;
@@ -1023,7 +1012,7 @@
 	// wouldn't get the state to recover.
 	//
 	mov r15=3Dcr.ifa
-	ssm psr.ic | psr.dt
+	ssm psr.ic
 	;;
 	srlz.i					// guarantee that interrupt collection is enabled
 	;;
@@ -1055,7 +1044,6 @@
 	//
 	// Input:
 	//	psr.ic:	off
-	//	psr.dt:	off
 	//	r19:	fault vector number (e.g., 24 for General Exception)
 	//	r31:	contains saved predicates (pr)
 	//
@@ -1071,7 +1059,7 @@
 	mov r10=3Dcr.iim
 	mov r11=3Dcr.itir
 	;;
-	ssm psr.ic | psr.dt
+	ssm psr.ic
 	;;
 	srlz.i					// guarantee that interrupt collection is enabled
 	;;
@@ -1145,9 +1133,7 @@
 // 0x5400 Entry 24 (size 16 bundles) General Exception (5,32,34,36,38,39)
 	mov r16=3Dcr.isr
 	mov r31=3Dpr
-	rsm psr.dt		// avoid nested faults due to TLB misses...
 	;;
-	srlz.d			// ensure everyone knows psr.dt is off...
 	cmp4.eq p6,p0=3D0,r16
 (p6)	br.sptk dispatch_illegal_op_fault
 	;;
@@ -1157,7 +1143,7 @@
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x5500 Entry 25 (size 16 bundles) Disabled FP-Register (35)
-	rsm psr.dt | psr.dfh			// ensure we can access fph
+	rsm psr.dfh		// ensure we can access fph
 	;;
 	srlz.d
 	mov r31=3Dpr
@@ -1218,11 +1204,9 @@
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x5a00 Entry 30 (size 16 bundles) Unaligned Reference (57)
-	rsm psr.dt		// avoid nested faults due to TLB misses...
 	mov r16=3Dcr.ipsr
 	mov r31=3Dpr		// prepare to save predicates
 	;;								=09
-	srlz.d			// ensure everyone knows psr.dt is off
 	br.cond.sptk.many dispatch_unaligned_handler
=20
 	.align 256
@@ -1304,9 +1288,6 @@
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x6a00 Entry 46 (size 16 bundles) IA-32 Intercept  (30,31,59,70,71)
 #ifdef	CONFIG_IA32_SUPPORT
-	rsm psr.dt
-	;;
-	srlz.d
 	mov r31=3Dpr
 	mov r16=3Dcr.isr
 	;;
@@ -1334,9 +1315,6 @@
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x6b00 Entry 47 (size 16 bundles) IA-32 Interrupt  (74)
 #ifdef CONFIG_IA32_SUPPORT
-	rsm psr.dt
-	;;
-	srlz.d
 	mov r31=3Dpr
 	br.cond.sptk.many dispatch_to_ia32_handler
 #else
diff -urN linux-davidm/arch/ia64/kernel/machvec.c linux-2.4.0-test10-lia/ar=
ch/ia64/kernel/machvec.c
--- linux-davidm/arch/ia64/kernel/machvec.c	Sun Aug 13 10:17:16 2000
+++ linux-2.4.0-test10-lia/arch/ia64/kernel/machvec.c	Wed Nov 15 17:57:18 2=
000
@@ -1,10 +1,12 @@
 #include <linux/config.h>
+
+#ifdef CONFIG_IA64_GENERIC
+
 #include <linux/kernel.h>
+#include <linux/string.h>
=20
 #include <asm/page.h>
 #include <asm/machvec.h>
-
-#ifdef CONFIG_IA64_GENERIC
=20
 struct ia64_machine_vector ia64_mv;
=20
diff -urN linux-davidm/arch/ia64/kernel/mca.c linux-2.4.0-test10-lia/arch/i=
a64/kernel/mca.c
--- linux-davidm/arch/ia64/kernel/mca.c	Wed Nov 15 23:09:41 2000
+++ linux-2.4.0-test10-lia/arch/ia64/kernel/mca.c	Wed Nov 15 17:57:31 2000
@@ -366,7 +366,7 @@
 void
 ia64_mca_wakeup(int cpu)
 {
-	ia64_send_ipi(cpu, IA64_MCA_WAKEUP_INT_VECTOR, IA64_IPI_DM_INT, 0);
+	platform_send_ipi(cpu, IA64_MCA_WAKEUP_INT_VECTOR, IA64_IPI_DM_INT, 0);
 	ia64_mc_info.imi_rendez_checkin[cpu] =3D IA64_MCA_RENDEZ_CHECKIN_NOTDONE;
 =09
 }
diff -urN linux-davidm/arch/ia64/kernel/mca_asm.S linux-2.4.0-test10-lia/ar=
ch/ia64/kernel/mca_asm.S
--- linux-davidm/arch/ia64/kernel/mca_asm.S	Wed Nov 15 23:09:41 2000
+++ linux-2.4.0-test10-lia/arch/ia64/kernel/mca_asm.S	Wed Nov 15 17:57:45 2=
000
@@ -3,8 +3,9 @@
 //
 // Mods by cfleck to integrate into kernel build
 // 00/03/15 davidm Added various stop bits to get a clean compile
-// 00/03/29 cfleck Added code to save INIT handoff state in pt_regs format=
, switch to temp kstack,
-//		   switch modes, jump to C INIT handler
+//
+// 00/03/29 cfleck Added code to save INIT handoff state in pt_regs format=
, switch to temp
+//		   kstack, switch modes, jump to C INIT handler
 //
 #include <asm/pgtable.h>
 #include <asm/processor.h>
@@ -15,14 +16,7 @@
  * When we get an machine check, the kernel stack pointer is no longer
  * valid, so we need to set a new stack pointer.
  */
-#define MINSTATE_START_SAVE_MIN							\
-(pKern) movl sp=3Dia64_init_stack+IA64_STK_OFFSET-IA64_PT_REGS_SIZE;		\
-	;;
-
-#define MINSTATE_END_SAVE_MIN							\
-	or r12=3Dr12,r14;		/* make sp a kernel virtual address */		\
-	or r13=3Dr13,r14;		/* make `current' a kernel virtual address */	\
-	;;
+#define	MINSTATE_PHYS	/* Make sure stack access is physical for MINSTATE *=
/=20
=20
 #include "minstate.h"
 =09
diff -urN linux-davidm/arch/ia64/kernel/minstate.h linux-2.4.0-test10-lia/a=
rch/ia64/kernel/minstate.h
--- linux-davidm/arch/ia64/kernel/minstate.h	Mon Oct  9 17:54:54 2000
+++ linux-2.4.0-test10-lia/arch/ia64/kernel/minstate.h	Wed Nov 15 22:22:30 =
2000
@@ -20,6 +20,72 @@
 #define rR1		r20
=20
 /*
+ * Here start the source dependent macros.
+ */
+
+/*
+ * For ivt.s we want to access the stack virtually so we dont have to disa=
ble translation
+ * on interrupts.
+ */
+#define MINSTATE_START_SAVE_MIN_VIRT								\
+	dep r1=3D-1,r1,61,3;				/* r1 =3D current (virtual) */		\
+(p7)	mov ar.rsc=3Dr0;		/* set enforced lazy mode, pl 0, little-endian, loa=
drs=3D0 */	\
+	;;											\
+(p7)	addl rKRBS=3DIA64_RBS_OFFSET,r1;			/* compute base of RBS */		\
+(p7)	mov rARRNAT=3Dar.rnat;									\
+(pKern) mov r1=3Dsp;					/* get sp  */				\
+	;;											\
+(p7)	addl r1=3DIA64_STK_OFFSET-IA64_PT_REGS_SIZE,r1;	/* compute base of me=
mory stack */	\
+(p7)	mov rARBSPSTORE=3Dar.bspstore;			/* save ar.bspstore */			\
+	;;											\
+(pKern) addl r1=3D-IA64_PT_REGS_SIZE,r1;			/* if in kernel mode, use sp (r=
12) */	\
+(p7)	mov ar.bspstore=3DrKRBS;				/* switch to kernel RBS */		\
+	;;											\
+(p7)	mov r18=3Dar.bsp;										\
+(p7)	mov ar.rsc=3D0x3;		/* set eager mode, pl 0, little-endian, loadrs=3D0=
 */		\
+
+#define MINSTATE_END_SAVE_MIN_VIRT								\
+	or r13=3Dr13,r14;		/* make `current' a kernel virtual address */			\
+	bsw.1;			/* switch back to bank 1 (must be last in insn group) */	\
+	;;
+
+/*
+ * For mca_asm.S we want to access the stack physically since the state is=
 saved before we
+ * go virtual and dont want to destroy the iip or ipsr.
+ */
+#define MINSTATE_START_SAVE_MIN_PHYS								\
+(pKern) movl sp=3Dia64_init_stack+IA64_STK_OFFSET-IA64_PT_REGS_SIZE;				\
+(p7)	mov ar.rsc=3Dr0;		/* set enforced lazy mode, pl 0, little-endian, loa=
drs=3D0 */	\
+(p7)	addl rKRBS=3DIA64_RBS_OFFSET,r1;		/* compute base of register backing=
 store */	\
+	;;											\
+(p7)	mov rARRNAT=3Dar.rnat;									\
+(pKern) dep r1=3D0,sp,61,3;				/* compute physical addr of sp	*/	\
+(p7)	addl r1=3DIA64_STK_OFFSET-IA64_PT_REGS_SIZE,r1;	/* compute base of me=
mory stack */	\
+(p7)	mov rARBSPSTORE=3Dar.bspstore;			/* save ar.bspstore */			\
+(p7)	dep rKRBS=3D-1,rKRBS,61,3;			/* compute kernel virtual addr of RBS */\
+	;;											\
+(pKern) addl r1=3D-IA64_PT_REGS_SIZE,r1;		/* if in kernel mode, use sp (r1=
2) */		\
+(p7)	mov ar.bspstore=3DrKRBS;			/* switch to kernel RBS */			\
+	;;											\
+(p7)	mov r18=3Dar.bsp;										\
+(p7)	mov ar.rsc=3D0x3;		/* set eager mode, pl 0, little-endian, loadrs=3D0=
 */		\
+
+#define MINSTATE_END_SAVE_MIN_PHYS								\
+	or r12=3Dr12,r14;		/* make sp a kernel virtual address */				\
+	or r13=3Dr13,r14;		/* make `current' a kernel virtual address */			\
+	;;
+
+#ifdef MINSTATE_VIRT
+# define MINSTATE_START_SAVE_MIN	MINSTATE_START_SAVE_MIN_VIRT
+# define MINSTATE_END_SAVE_MIN		MINSTATE_END_SAVE_MIN_VIRT
+#endif
+
+#ifdef MINSTATE_PHYS
+# define MINSTATE_START_SAVE_MIN	MINSTATE_START_SAVE_MIN_PHYS
+# define MINSTATE_END_SAVE_MIN		MINSTATE_END_SAVE_MIN_PHYS
+#endif
+
+/*
  * DO_SAVE_MIN switches to the kernel stacks (if necessary) and saves
  * the minimum state necessary that allows us to turn psr.ic back
  * on.
@@ -31,7 +97,6 @@
  *
  * Upon exit, the state is as follows:
  *	psr.ic: off
- *	psr.dt: off
  *	r2 =3D points to &pt_regs.r16
  *	r12 =3D kernel sp (kernel virtual address)
  *	r13 =3D points to current task_struct (kernel virtual address)
@@ -50,7 +115,7 @@
 	mov rCRIPSR=3Dcr.ipsr;									  \
 	mov rB6=B6;		/* rB6 =3D branch reg 6 */					  \
 	mov rCRIIP=3Dcr.iip;									  \
-	mov r1=3Dar.k6;		/* r1 =3D current */						  \
+	mov r1=3Dar.k6;		/* r1 =3D current (physical) */					  \
 	;;											  \
 	invala;											  \
 	extr.u r16=3DrCRIPSR,32,2;		/* extract psr.cpl */				  \
@@ -58,25 +123,11 @@
 	cmp.eq pKern,p7=3Dr0,r16;			/* are we in kernel mode already? (psr.cpl=3D=
0) */ \
 	/* switch from user to kernel RBS: */							  \
 	COVER;											  \
-	;; 									                  \
-	MINSTATE_START_SAVE_MIN									  \
-(p7)	mov ar.rsc=3Dr0;		/* set enforced lazy mode, pl 0, little-endian, loa=
drs=3D0 */	  \
-(p7)	addl rKRBS=3DIA64_RBS_OFFSET,r1;		/* compute base of register backing=
 store */	  \
-	;;											  \
-(p7)	mov rARRNAT=3Dar.rnat;									  \
-(pKern)	dep r1=3D0,sp,61,3;				/* compute physical addr of sp  */	  \
-(p7)	addl r1=3DIA64_STK_OFFSET-IA64_PT_REGS_SIZE,r1;	/* compute base of me=
mory stack */	  \
-(p7)	mov rARBSPSTORE=3Dar.bspstore;			/* save ar.bspstore */			  \
-(p7)	dep rKRBS=3D-1,rKRBS,61,3;			/* compute kernel virtual addr of RBS */=
  \
 	;;											  \
-(pKern)	addl r1=3D-IA64_PT_REGS_SIZE,r1;		/* if in kernel mode, use sp (r1=
2) */		  \
-(p7)	mov ar.bspstore=3DrKRBS;			/* switch to kernel RBS */			  \
+	MINSTATE_START_SAVE_MIN									  \
 	;;											  \
-(p7)	mov r18=3Dar.bsp;										  \
-(p7)	mov ar.rsc=3D0x3;		/* set eager mode, pl 0, little-endian, loadrs=3D0=
 */		  \
-												  \
-	mov r16=3Dr1;		/* initialize first base pointer */				  \
-	adds r17=3D8,r1;		/* initialize second base pointer */				  \
+	mov r16=3Dr1;					/* initialize first base pointer */	  \
+	adds r17=3D8,r1;					/* initialize second base pointer */	  \
 	;;											  \
 	st8 [r16]=3DrCRIPSR,16;	/* save cr.ipsr */						  \
 	st8 [r17]=3DrCRIIP,16;	/* save cr.iip */						  \
diff -urN linux-davidm/arch/ia64/kernel/pal.S linux-2.4.0-test10-lia/arch/i=
a64/kernel/pal.S
--- linux-davidm/arch/ia64/kernel/pal.S	Mon Oct  9 17:54:54 2000
+++ linux-2.4.0-test10-lia/arch/ia64/kernel/pal.S	Wed Nov 15 17:58:01 2000
@@ -52,10 +52,9 @@
 /*
  * Make a PAL call using the static calling convention.
  *
- * in0         Pointer to struct ia64_pal_retval
- * in1         Index of PAL service
- * in2 - in4   Remaining PAL arguments
- * in5	       1 =3D> clear psr.ic,  0 =3D> don't clear psr.ic
+ * in0         Index of PAL service
+ * in1 - in3   Remaining PAL arguments
+ * in4	       1 =3D> clear psr.ic,  0 =3D> don't clear psr.ic
  *
  */
 GLOBAL_ENTRY(ia64_pal_call_static)
@@ -69,7 +68,7 @@
 	}
 	;;
 	ld8 loc2 =3D [loc2]		// loc2 <- entry point
-	tbit.nz p6,p7 =3D in5, 0
+	tbit.nz p6,p7 =3D in4, 0
 	adds r8 =3D 1f-1b,r8
 	;;
 	mov loc3 =3D psr
diff -urN linux-davidm/arch/ia64/kernel/pci.c linux-2.4.0-test10-lia/arch/i=
a64/kernel/pci.c
--- linux-davidm/arch/ia64/kernel/pci.c	Wed Nov 15 23:09:41 2000
+++ linux-2.4.0-test10-lia/arch/ia64/kernel/pci.c	Wed Nov 15 17:58:20 2000
@@ -1,10 +1,8 @@
 /*
- * pci.c - Low-Level PCI Access in IA64
+ * pci.c - Low-Level PCI Access in IA-64
  *=20
  * Derived from bios32.c of i386 tree.
- *
  */
-
 #include <linux/config.h>
=20
 #include <linux/types.h>
@@ -44,15 +42,11 @@
  * This interrupt-safe spinlock protects all accesses to PCI
  * configuration space.
  */
-
 spinlock_t pci_lock =3D SPIN_LOCK_UNLOCKED;
=20
-struct pci_fixup pcibios_fixups[] =3D { { 0 } };
-
-#define PCI_NO_CHECKS		0x400
-#define PCI_NO_PEER_FIXUP	0x800
-
-static unsigned int pci_probe =3D PCI_NO_CHECKS;
+struct pci_fixup pcibios_fixups[] =3D {
+	{ 0 }
+};
=20
 /* Macro to build a PCI configuration address to be passed as a parameter =
to SAL. */
=20
@@ -110,7 +104,7 @@
 	return ia64_sal_pci_config_write(PCI_CONFIG_ADDRESS(dev, where), 4, value=
);
 }
=20
-static struct pci_ops pci_conf =3D {
+struct pci_ops pci_conf =3D {
       pci_conf_read_config_byte,
       pci_conf_read_config_word,
       pci_conf_read_config_dword,
@@ -185,17 +179,16 @@
 	return 0;
 }
=20
+void
+pcibios_align_resource (void *data, struct resource *res, unsigned long si=
ze)
+{
+}
+
 /*
  * PCI BIOS setup, always defaults to SAL interface
  */
 char * __init=20
 pcibios_setup (char *str)
 {
-	pci_probe =3D PCI_NO_CHECKS;
 	return NULL;
-}
-
-void
-pcibios_align_resource (void *data, struct resource *res, unsigned long si=
ze)
-{
 }
diff -urN linux-davidm/arch/ia64/kernel/ptrace.c linux-2.4.0-test10-lia/arc=
h/ia64/kernel/ptrace.c
--- linux-davidm/arch/ia64/kernel/ptrace.c	Wed Nov 15 23:09:41 2000
+++ linux-2.4.0-test10-lia/arch/ia64/kernel/ptrace.c	Wed Nov 15 17:58:36 20=
00
@@ -1058,7 +1058,7 @@
 		goto out_tsk;
=20
 	if (child->state !=3D TASK_STOPPED) {
-		if (request !=3D PTRACE_KILL && request !=3D PTRACE_PEEKUSR)
+		if (request !=3D PTRACE_KILL)
 			goto out_tsk;
 	}
=20
diff -urN linux-davidm/arch/ia64/kernel/sal.c linux-2.4.0-test10-lia/arch/i=
a64/kernel/sal.c
--- linux-davidm/arch/ia64/kernel/sal.c	Mon Oct  9 17:54:54 2000
+++ linux-2.4.0-test10-lia/arch/ia64/kernel/sal.c	Wed Nov 15 17:58:45 2000
@@ -104,9 +104,11 @@
 	if (strncmp(systab->signature, "SST_", 4) !=3D 0)
 		printk("bad signature in system table!");
=20
-	printk("SAL v%u.%02u: ia32bios=3D%s, oem=3D%.32s, product=3D%.32s\n",
+	/*=20
+	 * revisions are coded in BCD, so %x does the job for us
+	 */
+	printk("SAL v%x.%02x: oem=3D%.32s, product=3D%.32s\n",
 	       systab->sal_rev_major, systab->sal_rev_minor,
-	       systab->ia32_bios_present ? "present" : "absent",
 	       systab->oem_id, systab->product_id);
=20
 	min =3D ~0UL;
diff -urN linux-davidm/arch/ia64/kernel/setup.c linux-2.4.0-test10-lia/arch=
/ia64/kernel/setup.c
--- linux-davidm/arch/ia64/kernel/setup.c	Mon Oct  9 17:54:55 2000
+++ linux-2.4.0-test10-lia/arch/ia64/kernel/setup.c	Wed Nov 15 22:02:05 2000
@@ -408,6 +408,8 @@
 {
 	extern void __init ia64_rid_init (void);
 	extern void __init ia64_tlb_init (void);
+	pal_vm_info_2_u_t vmi;
+	unsigned int max_ctx;
=20
 	identify_cpu(&my_cpu_data);
=20
@@ -415,15 +417,12 @@
 	memset(ia64_task_regs(current), 0, sizeof(struct pt_regs));
=20
 	/*
-	 * Initialize default control register to defer speculative
-	 * faults.  On a speculative load, we want to defer access
-	 * right, key miss, and key permission faults.  We currently
-	 * do NOT defer TLB misses, page-not-present, access bit, or
-	 * debug faults but kernel code should not rely on any
-	 * particular setting of these bits.
-	ia64_set_dcr(IA64_DCR_DR | IA64_DCR_DK | IA64_DCR_DX | IA64_DCR_PP);
+	 * Initialize default control register to defer all speculative faults.  =
The
+	 * kernel MUST NOT depend on a particular setting of these bits (in other=
 words,
+	 * the kernel must have recovery code for all speculative accesses).
 	 */
-	ia64_set_dcr(IA64_DCR_DR | IA64_DCR_DK | IA64_DCR_DX );
+	ia64_set_dcr(  IA64_DCR_DM | IA64_DCR_DP | IA64_DCR_DK | IA64_DCR_DX | IA=
64_DCR_DR
+		     | IA64_DCR_DA | IA64_DCR_DD);
 #ifndef CONFIG_SMP
 	ia64_set_fpu_owner(0);		/* initialize ar.k5 */
 #endif
@@ -444,4 +443,17 @@
 #ifdef CONFIG_SMP
 	normal_xtp();
 #endif
+
+	/* set ia64_ctx.max_rid to the maximum RID that is supported by all CPUs:=
 */
+	if (ia64_pal_vm_summary(NULL, &vmi) =3D 0)
+		max_ctx =3D (1U << (vmi.pal_vm_info_2_s.rid_size - 3)) - 1;
+	else {
+		printk("ia64_rid_init: PAL VM summary failed, assuming 18 RID bits\n");
+		max_ctx =3D (1U << 15) - 1;	/* use architected minimum */
+	}
+	while (max_ctx < ia64_ctx.max_ctx) {
+		unsigned int old =3D ia64_ctx.max_ctx;
+		if (cmpxchg(&ia64_ctx.max_ctx, old, max_ctx) =3D old)
+			break;
+	}
 }
diff -urN linux-davidm/arch/ia64/kernel/signal.c linux-2.4.0-test10-lia/arc=
h/ia64/kernel/signal.c
--- linux-davidm/arch/ia64/kernel/signal.c	Mon Oct  9 17:54:55 2000
+++ linux-2.4.0-test10-lia/arch/ia64/kernel/signal.c	Wed Nov 15 18:03:14 20=
00
@@ -91,7 +91,7 @@
 		scr->pt.r10 =3D -1;
 	}
 	while (1) {
-		set_current_state(TASK_INTERRUPTIBLE);
+		current->state =3D TASK_INTERRUPTIBLE;
 		schedule();
 		if (ia64_do_signal(&oldset, scr, 1))
 			return -EINTR;
@@ -499,9 +499,10 @@
 			/* Let the debugger run.  */
 			current->exit_code =3D signr;
 			current->thread.siginfo =3D &info;
-			set_current_state(TASK_STOPPED);
+			current->state =3D TASK_STOPPED;
 			notify_parent(current, SIGCHLD);
 			schedule();
+
 			signr =3D current->exit_code;
 			current->thread.siginfo =3D 0;
=20
@@ -557,7 +558,7 @@
 				/* FALLTHRU */
=20
 			      case SIGSTOP:
-				set_current_state(TASK_STOPPED);
+				current->state =3D TASK_STOPPED;
 				current->exit_code =3D signr;
 				if (!(current->p_pptr->sig->action[SIGCHLD-1].sa.sa_flags
 				      & SA_NOCLDSTOP))
diff -urN linux-davidm/arch/ia64/kernel/smp.c linux-2.4.0-test10-lia/arch/i=
a64/kernel/smp.c
--- linux-davidm/arch/ia64/kernel/smp.c	Wed Nov 15 23:09:41 2000
+++ linux-2.4.0-test10-lia/arch/ia64/kernel/smp.c	Wed Nov 15 18:04:37 2000
@@ -279,7 +279,7 @@
                 return;
        =20
 	set_bit(op, &ipi_op[dest_cpu]);
-	ia64_send_ipi(dest_cpu, IPI_IRQ, IA64_IPI_DM_INT, 0);
+	platform_send_ipi(dest_cpu, IPI_IRQ, IA64_IPI_DM_INT, 0);
 }
=20
 static inline void
@@ -429,7 +429,7 @@
 		int i;
 		for (i =3D 0; i < smp_num_cpus; i++) {
 			if (i !=3D smp_processor_id())
-				ia64_send_ipi(i, IPI_IRQ, IA64_IPI_DM_INT, 0);
+				platform_send_ipi(i, IPI_IRQ, IA64_IPI_DM_INT, 0);
 		}
 		goto retry;
 #else
@@ -587,7 +587,7 @@
 	cpu_now_booting =3D cpu;
=20
 	/* Kick the AP in the butt */
-	ia64_send_ipi(cpu, ap_wakeup_vector, IA64_IPI_DM_INT, 0);
+	platform_send_ipi(cpu, ap_wakeup_vector, IA64_IPI_DM_INT, 0);
=20
 	/* wait up to 10s for the AP to start  */
 	for (timeout =3D 0; timeout < 100000; timeout++) {
diff -urN linux-davidm/arch/ia64/kernel/unaligned.c linux-2.4.0-test10-lia/=
arch/ia64/kernel/unaligned.c
--- linux-davidm/arch/ia64/kernel/unaligned.c	Wed Nov 15 23:09:41 2000
+++ linux-2.4.0-test10-lia/arch/ia64/kernel/unaligned.c	Wed Nov 15 18:08:22=
 2000
@@ -1564,9 +1564,13 @@
=20
 	DPRINT(("ret=3D%d\n", ret));
 	if (ret) {
-		lock_kernel();
-	        force_sig(SIGSEGV, current);
-	        unlock_kernel();
+		struct siginfo si;
+
+		si.si_signo =3D SIGBUS;
+		si.si_errno =3D 0;
+		si.si_code =3D BUS_ADRALN;
+		si.si_addr =3D (void *) ifa;
+	        force_sig_info(SIGBUS, &si, current);
 	} else {
 		/*
 	 	 * given today's architecture this case is not likely to happen
diff -urN linux-davidm/arch/ia64/kernel/unwind.c linux-2.4.0-test10-lia/arc=
h/ia64/kernel/unwind.c
--- linux-davidm/arch/ia64/kernel/unwind.c	Wed Nov 15 23:09:41 2000
+++ linux-2.4.0-test10-lia/arch/ia64/kernel/unwind.c	Wed Nov 15 22:08:29 20=
00
@@ -1996,8 +1996,8 @@
 void
 unw_remove_unwind_table (void *handle)
 {
-	struct unw_table *table, *prevt;
-	struct unw_script *tmp, *prev;
+	struct unw_table *table, *prev;
+	struct unw_script *tmp;
 	unsigned long flags;
 	long index;
=20
@@ -2016,41 +2016,35 @@
 	{
 		/* first, delete the table: */
=20
-		for (prevt =3D (struct unw_table *) &unw.tables; prevt; prevt =3D prevt-=
>next)
-			if (prevt->next =3D table)
+		for (prev =3D (struct unw_table *) &unw.tables; prev; prev =3D prev->nex=
t)
+			if (prev->next =3D table)
 				break;
-		if (!prevt) {
+		if (!prev) {
 			dprintk("unwind: failed to find unwind table %p\n", (void *) table);
 			spin_unlock_irqrestore(&unw.lock, flags);
 			return;
 		}
-		prevt->next =3D table->next;
+		prev->next =3D table->next;
+	}
+	spin_unlock_irqrestore(&unw.lock, flags);
=20
-		/* next, remove hash table entries for this table */
+	/* next, remove hash table entries for this table */
=20
-		for (index =3D 0; index <=3D UNW_HASH_SIZE; ++index) {
-			if (unw.hash[index] >=3D UNW_CACHE_SIZE)
-				continue;
-
-			tmp =3D unw.cache + unw.hash[index];
-			prev =3D 0;
-			while (1) {
-				write_lock(&tmp->lock);
-				{
-					if (tmp->ip >=3D table->start && tmp->ip < table->end) {
-						if (prev)
-							prev->coll_chain =3D tmp->coll_chain;
-						else
-							unw.hash[index] =3D -1;
-						tmp->ip =3D 0;
-					} else
-						prev =3D tmp;
-				}
-				write_unlock(&tmp->lock);
+	for (index =3D 0; index <=3D UNW_HASH_SIZE; ++index) {
+		tmp =3D unw.cache + unw.hash[index];
+		if (unw.hash[index] >=3D UNW_CACHE_SIZE
+		    || tmp->ip < table->start || tmp->ip >=3D table->end)
+			continue;
+
+		write_lock(&tmp->lock);
+		{
+			if (tmp->ip >=3D table->start && tmp->ip < table->end) {
+				unw.hash[index] =3D tmp->coll_chain;
+				tmp->ip =3D 0;
 			}
 		}
+		write_unlock(&tmp->lock);
 	}
-	spin_unlock_irqrestore(&unw.lock, flags);
=20
 	kfree(table);
 }
diff -urN linux-davidm/arch/ia64/mm/init.c linux-2.4.0-test10-lia/arch/ia64=
/mm/init.c
--- linux-davidm/arch/ia64/mm/init.c	Mon Oct  9 17:54:56 2000
+++ linux-2.4.0-test10-lia/arch/ia64/mm/init.c	Wed Nov 15 18:39:03 2000
@@ -305,7 +305,7 @@
 		return 0;
 	}
 	flush_page_to_ram(page);
-	set_pte(pte, page_pte_prot(page, PAGE_GATE));
+	set_pte(pte, mk_pte(page, PAGE_GATE));
 	/* no need for flush_tlb */
 	return page;
 }
@@ -423,6 +423,17 @@
 	extern char __start_gate_section[];
 	long reserved_pages, codesize, datasize, initsize;
=20
+#ifdef CONFIG_SWIOTLB
+	{
+		/*
+		 * This needs to be called _after_ the command line has been parsed but
+		 * _before_ any drivers that may need the sw I/O TLB are initialized or
+		 * bootmem has been freed.
+		 */
+		extern void setup_swiotlb (void);
+		setup_swiotlb();
+	}
+#endif
 	if (!mem_map)
 		BUG();
=20
diff -urN linux-davidm/arch/ia64/mm/tlb.c linux-2.4.0-test10-lia/arch/ia64/=
mm/tlb.c
--- linux-davidm/arch/ia64/mm/tlb.c	Wed Nov 15 23:09:41 2000
+++ linux-2.4.0-test10-lia/arch/ia64/mm/tlb.c	Wed Nov 15 22:08:44 2000
@@ -36,15 +36,10 @@
 struct ia64_ctx ia64_ctx =3D {
 	lock:	SPIN_LOCK_UNLOCKED,
 	next:	1,
-	limit:	(1UL << IA64_HW_CONTEXT_BITS)
+	limit:	(1 << 15) - 1,		/* start out with the safe (architected) limit */
+	max_ctx: ~0U
 };
=20
- /*
-  * Put everything in a struct so we avoid the global offset table whenever
-  * possible.
-  */
-ia64_ptce_info_t ia64_ptce_info;
-
 /*
  * Seralize usage of ptc.g=20
  */
@@ -133,12 +128,12 @@
 void
 wrap_mmu_context (struct mm_struct *mm)
 {
+	unsigned long tsk_context, max_ctx =3D ia64_ctx.max_ctx;
 	struct task_struct *tsk;
-	unsigned long tsk_context;
=20
-	if (ia64_ctx.next >=3D (1UL << IA64_HW_CONTEXT_BITS))=20
+	if (ia64_ctx.next > max_ctx)
 		ia64_ctx.next =3D 300;	/* skip daemons */
-	ia64_ctx.limit =3D (1UL << IA64_HW_CONTEXT_BITS);
+	ia64_ctx.limit =3D max_ctx + 1;
=20
 	/*
 	 * Scan all the task's mm->context and set proper safe range
@@ -153,9 +148,9 @@
 		if (tsk_context =3D ia64_ctx.next) {
 			if (++ia64_ctx.next >=3D ia64_ctx.limit) {
 				/* empty range: reset the range limit and start over */
-				if (ia64_ctx.next >=3D (1UL << IA64_HW_CONTEXT_BITS))=20
+				if (ia64_ctx.next > max_ctx)=20
 					ia64_ctx.next =3D 300;
-				ia64_ctx.limit =3D (1UL << IA64_HW_CONTEXT_BITS);
+				ia64_ctx.limit =3D max_ctx + 1;
 				goto repeat;
 			}
 		}
@@ -169,12 +164,13 @@
 void
 __flush_tlb_all (void)
 {
-	unsigned long i, j, flags, count0, count1, stride0, stride1, addr =3D ia6=
4_ptce_info.base;
+	unsigned long i, j, flags, count0, count1, stride0, stride1, addr;
=20
-	count0  =3D ia64_ptce_info.count[0];
-	count1  =3D ia64_ptce_info.count[1];
-	stride0 =3D ia64_ptce_info.stride[0];
-	stride1 =3D ia64_ptce_info.stride[1];
+	addr    =3D my_cpu_data.ptce_base;
+	count0  =3D my_cpu_data.ptce_count[0];
+	count1  =3D my_cpu_data.ptce_count[1];
+	stride0 =3D my_cpu_data.ptce_stride[0];
+	stride1 =3D my_cpu_data.ptce_stride[1];
=20
 	local_irq_save(flags);
 	for (i =3D 0; i < count0; ++i) {
@@ -246,6 +242,14 @@
 void __init
 ia64_tlb_init (void)
 {
-	ia64_get_ptce(&ia64_ptce_info);
+	ia64_ptce_info_t ptce_info;
+
+	ia64_get_ptce(&ptce_info);
+	my_cpu_data.ptce_base =3D ptce_info.base;
+	my_cpu_data.ptce_count[0] =3D ptce_info.count[0];
+	my_cpu_data.ptce_count[1] =3D ptce_info.count[1];
+	my_cpu_data.ptce_stride[0] =3D ptce_info.stride[0];
+	my_cpu_data.ptce_stride[1] =3D ptce_info.stride[1];
+
 	__flush_tlb_all();		/* nuke left overs from bootstrapping... */
 }
diff -urN linux-davidm/arch/ia64/tools/print_offsets.c linux-2.4.0-test10-l=
ia/arch/ia64/tools/print_offsets.c
--- linux-davidm/arch/ia64/tools/print_offsets.c	Fri Jul 14 16:08:12 2000
+++ linux-2.4.0-test10-lia/arch/ia64/tools/print_offsets.c	Wed Nov 15 18:10=
:14 2000
@@ -149,7 +149,7 @@
     { "IA64_SWITCH_STACK_AR_UNAT_OFFSET",	offsetof (struct switch_stack, a=
r_unat) },
     { "IA64_SWITCH_STACK_AR_RNAT_OFFSET",	offsetof (struct switch_stack, a=
r_rnat) },
     { "IA64_SWITCH_STACK_AR_BSPSTORE_OFFSET",	offsetof (struct switch_stac=
k, ar_bspstore) },
-    { "IA64_SWITCH_STACK_PR_OFFSET",	offsetof (struct switch_stack, b0) },
+    { "IA64_SWITCH_STACK_PR_OFFSET",	offsetof (struct switch_stack, pr) },
     { "IA64_SIGCONTEXT_AR_BSP_OFFSET",	offsetof (struct sigcontext, sc_ar_=
bsp) },
     { "IA64_SIGCONTEXT_AR_RNAT_OFFSET",	offsetof (struct sigcontext, sc_ar=
_rnat) },
     { "IA64_SIGCONTEXT_FLAGS_OFFSET",	offsetof (struct sigcontext, sc_flag=
s) },
diff -urN linux-davidm/include/asm-generic/pgtable.h linux-2.4.0-test10-lia=
/include/asm-generic/pgtable.h
--- linux-davidm/include/asm-generic/pgtable.h	Thu Oct 19 15:51:16 2000
+++ linux-2.4.0-test10-lia/include/asm-generic/pgtable.h	Wed Nov 15 18:13:5=
6 2000
@@ -26,7 +26,7 @@
 	return pte;
 }
=20
-static inline void ptep_clear_wrprotect(pte_t *ptep)
+static inline void ptep_set_wrprotect(pte_t *ptep)
 {
 	pte_t old_pte =3D *ptep;
 	set_pte(ptep, pte_wrprotect(old_pte));
diff -urN linux-davidm/include/asm-i386/pgtable.h linux-2.4.0-test10-lia/in=
clude/asm-i386/pgtable.h
--- linux-davidm/include/asm-i386/pgtable.h	Wed Nov 15 23:09:41 2000
+++ linux-2.4.0-test10-lia/include/asm-i386/pgtable.h	Wed Nov 15 18:14:06 2=
000
@@ -283,7 +283,7 @@
=20
 static inline  int ptep_test_and_clear_dirty(pte_t *ptep)	{ return test_an=
d_clear_bit(_PAGE_BIT_DIRTY, ptep); }
 static inline  int ptep_test_and_clear_young(pte_t *ptep)	{ return test_an=
d_clear_bit(_PAGE_BIT_ACCESSED, ptep); }
-static inline void ptep_clear_wrprotect(pte_t *ptep)		{ clear_bit(_PAGE_BI=
T_RW, ptep); }
+static inline void ptep_set_wrprotect(pte_t *ptep)		{ clear_bit(_PAGE_BIT_=
RW, ptep); }
 static inline void ptep_mkdirty(pte_t *ptep)			{ set_bit(_PAGE_BIT_RW, pte=
p); }
=20
 /*
diff -urN linux-davidm/include/asm-ia64/hw_irq.h linux-2.4.0-test10-lia/inc=
lude/asm-ia64/hw_irq.h
--- linux-davidm/include/asm-ia64/hw_irq.h	Wed Nov 15 23:09:41 2000
+++ linux-2.4.0-test10-lia/include/asm-ia64/hw_irq.h	Wed Nov 15 22:54:13 20=
00
@@ -10,6 +10,7 @@
=20
 #include <linux/types.h>
=20
+#include <asm/machvec.h>
 #include <asm/ptrace.h>
 #include <asm/smp.h>
=20
@@ -77,7 +78,7 @@
 static inline void
 hw_resend_irq (struct hw_interrupt_type *h, unsigned int vector)
 {
-	ia64_send_ipi(smp_processor_id(), vector, IA64_IPI_DM_INT, 0);
+	platform_send_ipi(smp_processor_id(), vector, IA64_IPI_DM_INT, 0);
 }
=20
 #endif /* _ASM_IA64_HW_IRQ_H */
diff -urN linux-davidm/include/asm-ia64/io.h linux-2.4.0-test10-lia/include=
/asm-ia64/io.h
--- linux-davidm/include/asm-ia64/io.h	Mon Oct  9 17:54:58 2000
+++ linux-2.4.0-test10-lia/include/asm-ia64/io.h	Wed Nov 15 22:54:12 2000
@@ -29,6 +29,7 @@
=20
 # ifdef __KERNEL__
=20
+#include <asm/machvec.h>
 #include <asm/page.h>
 #include <asm/system.h>
=20
@@ -54,8 +55,7 @@
 #define bus_to_virt	phys_to_virt
 #define virt_to_bus	virt_to_phys
=20
-# else /* !KERNEL */
-# endif /* !KERNEL */
+# endif /* KERNEL */
=20
 /*
  * Memory fence w/accept.  This should never be used in code that is
@@ -100,7 +100,7 @@
  */
=20
 static inline unsigned int
-__inb (unsigned long port)
+__ia64_inb (unsigned long port)
 {
 	volatile unsigned char *addr =3D __ia64_mk_io_addr(port);
 	unsigned char ret;
@@ -111,7 +111,7 @@
 }
=20
 static inline unsigned int
-__inw (unsigned long port)
+__ia64_inw (unsigned long port)
 {
 	volatile unsigned short *addr =3D __ia64_mk_io_addr(port);
 	unsigned short ret;
@@ -122,7 +122,7 @@
 }
=20
 static inline unsigned int
-__inl (unsigned long port)
+__ia64_inl (unsigned long port)
 {
 	volatile unsigned int *addr =3D __ia64_mk_io_addr(port);
 	unsigned int ret;
@@ -133,112 +133,148 @@
 }
=20
 static inline void
-__insb (unsigned long port, void *dst, unsigned long count)
+__ia64_outb (unsigned char val, unsigned long port)
 {
 	volatile unsigned char *addr =3D __ia64_mk_io_addr(port);
-	unsigned char *dp =3D dst;
=20
+	*addr =3D val;
 	__ia64_mf_a();
-	while (count--) {
-		*dp++ =3D *addr;
-	}
-	__ia64_mf_a();
-	return;
 }
=20
 static inline void
-__insw (unsigned long port, void *dst, unsigned long count)
+__ia64_outw (unsigned short val, unsigned long port)
 {
 	volatile unsigned short *addr =3D __ia64_mk_io_addr(port);
-	unsigned short *dp =3D dst;
=20
+	*addr =3D val;
 	__ia64_mf_a();
-	while (count--) {
-		*dp++ =3D *addr;
-	}
-	__ia64_mf_a();
-	return;
 }
=20
 static inline void
-__insl (unsigned long port, void *dst, unsigned long count)
+__ia64_outl (unsigned int val, unsigned long port)
 {
 	volatile unsigned int *addr =3D __ia64_mk_io_addr(port);
-	unsigned int *dp =3D dst;
=20
+	*addr =3D val;
 	__ia64_mf_a();
-	while (count--) {
-		*dp++ =3D *addr;
-	}
-	__ia64_mf_a();
-	return;
 }
=20
 static inline void
-__outb (unsigned char val, unsigned long port)
+__insb (unsigned long port, void *dst, unsigned long count)
 {
-	volatile unsigned char *addr =3D __ia64_mk_io_addr(port);
+	unsigned char *dp =3D dst;
=20
-	*addr =3D val;
-	__ia64_mf_a();
+	if (platform_inb =3D __ia64_inb) {
+		volatile unsigned char *addr =3D __ia64_mk_io_addr(port);
+
+		__ia64_mf_a();
+		while (count--)
+			*dp++ =3D *addr;
+		__ia64_mf_a();
+	} else
+		while (count--)
+			*dp++ =3D platform_inb(port);
+	return;
 }
=20
 static inline void
-__outw (unsigned short val, unsigned long port)
+__insw (unsigned long port, void *dst, unsigned long count)
 {
-	volatile unsigned short *addr =3D __ia64_mk_io_addr(port);
+	unsigned short *dp =3D dst;
=20
-	*addr =3D val;
-	__ia64_mf_a();
+	if (platform_inw =3D __ia64_inw) {
+		volatile unsigned short *addr =3D __ia64_mk_io_addr(port);
+
+		__ia64_mf_a();
+		while (count--)
+			*dp++ =3D *addr;
+		__ia64_mf_a();
+	} else
+		while (count--)
+			*dp++ =3D platform_inw(port);
+	return;
 }
=20
 static inline void
-__outl (unsigned int val, unsigned long port)
+__insl (unsigned long port, void *dst, unsigned long count)
 {
-	volatile unsigned int *addr =3D __ia64_mk_io_addr(port);
+	unsigned int *dp =3D dst;
=20
-	*addr =3D val;
-	__ia64_mf_a();
+	if (platform_inl =3D __ia64_inl) {
+		volatile unsigned int *addr =3D __ia64_mk_io_addr(port);
+
+		__ia64_mf_a();
+		while (count--)
+			*dp++ =3D *addr;
+		__ia64_mf_a();
+	} else
+		while (count--)
+			*dp++ =3D platform_inl(port);
+	return;
 }
=20
 static inline void
 __outsb (unsigned long port, const void *src, unsigned long count)
 {
-	volatile unsigned char *addr =3D __ia64_mk_io_addr(port);
 	const unsigned char *sp =3D src;
=20
-	while (count--) {
-		*addr =3D *sp++;
-	}
-	__ia64_mf_a();
+	if (platform_outb =3D __ia64_outb) {
+		volatile unsigned char *addr =3D __ia64_mk_io_addr(port);
+
+		while (count--)
+			*addr =3D *sp++;
+		__ia64_mf_a();
+	} else
+		while (count--)
+			platform_outb(*sp++, port);
 	return;
 }
=20
 static inline void
 __outsw (unsigned long port, const void *src, unsigned long count)
 {
-	volatile unsigned short *addr =3D __ia64_mk_io_addr(port);
 	const unsigned short *sp =3D src;
=20
-	while (count--) {
-		*addr =3D *sp++;
-	}
-	__ia64_mf_a();
+	if (platform_outw =3D __ia64_outw) {
+		volatile unsigned short *addr =3D __ia64_mk_io_addr(port);
+
+		while (count--)
+			*addr =3D *sp++;
+		__ia64_mf_a();
+	} else
+		while (count--)
+			platform_outw(*sp++, port);
 	return;
 }
=20
 static inline void
 __outsl (unsigned long port, void *src, unsigned long count)
 {
-	volatile unsigned int *addr =3D __ia64_mk_io_addr(port);
 	const unsigned int *sp =3D src;
=20
-	while (count--) {
-		*addr =3D *sp++;
-	}
-	__ia64_mf_a();
+	if (platform_outl =3D __ia64_outl) {
+		volatile unsigned int *addr =3D __ia64_mk_io_addr(port);
+
+		while (count--)
+			*addr =3D *sp++;
+		__ia64_mf_a();
+	} else
+		while (count--)
+			platform_outl(*sp++, port);
 	return;
 }
+
+/*
+ * Unfortunately, some platforms are broken and do not follow the
+ * IA-64 architecture specification regarding legacy I/O support.
+ * Thus, we have to make these operations platform dependent...
+ */
+#define __inb		platform_inb
+#define __inw		platform_inw
+#define __inl		platform_inl
+#define __outb		platform_outb
+#define __outw		platform_outw
+#define __outl		platform_outl
=20
 #define inb		__inb
 #define inw		__inw
diff -urN linux-davidm/include/asm-ia64/machvec.h linux-2.4.0-test10-lia/in=
clude/asm-ia64/machvec.h
--- linux-davidm/include/asm-ia64/machvec.h	Wed Nov 15 23:09:41 2000
+++ linux-2.4.0-test10-lia/include/asm-ia64/machvec.h	Wed Nov 15 22:54:12 2=
000
@@ -31,6 +31,22 @@
 typedef void ia64_mv_mca_handler_t (void);
 typedef void ia64_mv_cmci_handler_t (int, void *, struct pt_regs *);
 typedef void ia64_mv_log_print_t (void);
+typedef void ia64_mv_send_ipi_t (int, int, int, int);
+/*
+ * WARNING: The legacy I/O space is _architected_.  Platforms are
+ * expected to follow this architected model (see Section 10.7 in the
+ * IA-64 Architecture Software Developer's Manual).  Unfortunately,
+ * some broken machines do not follow that model, which is why we have
+ * to make the inX/outX operations part of the machine vector.
+ * Platform designers should follow the architected model whenever
+ * possible.
+ */
+typedef unsigned int ia64_mv_inb_t (unsigned long);
+typedef unsigned int ia64_mv_inw_t (unsigned long);
+typedef unsigned int ia64_mv_inl_t (unsigned long);
+typedef void ia64_mv_outb_t (unsigned char, unsigned long);
+typedef void ia64_mv_outw_t (unsigned short, unsigned long);
+typedef void ia64_mv_outl_t (unsigned int, unsigned long);
=20
 extern void machvec_noop (void);
=20
@@ -54,6 +70,13 @@
 #  define platform_cmci_handler	ia64_mv.cmci_handler
 #  define platform_log_print	ia64_mv.log_print
 #  define platform_pci_fixup	ia64_mv.pci_fixup
+#  define platform_send_ipi	ia64_mv.send_ipi
+#  define platform_inb		ia64_mv.inb
+#  define platform_inw		ia64_mv.inw
+#  define platform_inl		ia64_mv.inl
+#  define platform_outb		ia64_mv.outb
+#  define platform_outw		ia64_mv.outw
+#  define platform_outl		ia64_mv.outl
 # endif
=20
 struct ia64_machine_vector {
@@ -66,6 +89,13 @@
 	ia64_mv_mca_handler_t *mca_handler;
 	ia64_mv_cmci_handler_t *cmci_handler;
 	ia64_mv_log_print_t *log_print;
+	ia64_mv_send_ipi_t *send_ipi;
+	ia64_mv_inb_t *inb;
+	ia64_mv_inw_t *inw;
+	ia64_mv_inl_t *inl;
+	ia64_mv_outb_t *outb;
+	ia64_mv_outw_t *outw;
+	ia64_mv_outl_t *outl;
 };
=20
 #define MACHVEC_INIT(name)			\
@@ -78,7 +108,14 @@
 	platform_mca_init,			\
 	platform_mca_handler,			\
 	platform_cmci_handler,			\
-	platform_log_print			\
+	platform_log_print,			\
+	platform_send_ipi,			\
+	platform_inb,				\
+	platform_inw,				\
+	platform_inl,				\
+	platform_outb,				\
+	platform_outw,				\
+	platform_outl				\
 }
=20
 extern struct ia64_machine_vector ia64_mv;
@@ -112,6 +149,27 @@
 #endif
 #ifndef platform_pci_fixup
 # define platform_pci_fixup	((ia64_mv_pci_fixup_t *) machvec_noop)
+#endif
+#ifndef platform_send_ipi
+# define platform_send_ipi	ia64_send_ipi	/* default to architected version=
 */
+#endif
+#ifndef platform_inb
+# define platform_inb		__ia64_inb
+#endif
+#ifndef platform_inw
+# define platform_inw		__ia64_inw
+#endif
+#ifndef platform_inl
+# define platform_inl		__ia64_inl
+#endif
+#ifndef platform_outb
+# define platform_outb		__ia64_outb
+#endif
+#ifndef platform_outw
+# define platform_outw		__ia64_outw
+#endif
+#ifndef platform_outl
+# define platform_outl		__ia64_outl
 #endif
=20
 #endif /* _ASM_IA64_MACHVEC_H */
diff -urN linux-davidm/include/asm-ia64/machvec_dig.h linux-2.4.0-test10-li=
a/include/asm-ia64/machvec_dig.h
--- linux-davidm/include/asm-ia64/machvec_dig.h	Wed Nov 15 23:09:41 2000
+++ linux-2.4.0-test10-lia/include/asm-ia64/machvec_dig.h	Wed Nov 15 18:15:=
39 2000
@@ -3,9 +3,8 @@
=20
 extern ia64_mv_setup_t dig_setup;
 extern ia64_mv_irq_init_t dig_irq_init;
-extern ia64_mv_pci_fixup_t dig_pci_fixup;
-extern ia64_mv_map_nr_t map_nr_dense;
 extern ia64_mv_pci_fixup_t iosapic_pci_fixup;
+extern ia64_mv_map_nr_t map_nr_dense;
=20
 /*
  * This stuff has dual use!
diff -urN linux-davidm/include/asm-ia64/machvec_hpsim.h linux-2.4.0-test10-=
lia/include/asm-ia64/machvec_hpsim.h
--- linux-davidm/include/asm-ia64/machvec_hpsim.h	Fri Jul 14 16:08:12 2000
+++ linux-2.4.0-test10-lia/include/asm-ia64/machvec_hpsim.h	Wed Nov 15 18:1=
5:49 2000
@@ -15,7 +15,6 @@
 #define platform_name		"hpsim"
 #define platform_setup		hpsim_setup
 #define platform_irq_init	hpsim_irq_init
-#define platform_pci_fixup	hpsim_pci_fixup
 #define platform_map_nr		map_nr_dense
=20
 #endif /* _ASM_IA64_MACHVEC_HPSIM_h */
diff -urN linux-davidm/include/asm-ia64/machvec_init.h linux-2.4.0-test10-l=
ia/include/asm-ia64/machvec_init.h
--- linux-davidm/include/asm-ia64/machvec_init.h	Fri Aug 11 19:09:06 2000
+++ linux-2.4.0-test10-lia/include/asm-ia64/machvec_init.h	Wed Nov 15 22:08=
:12 2000
@@ -4,6 +4,14 @@
=20
 #include <asm/machvec.h>
=20
+extern ia64_mv_send_ipi_t ia64_send_ipi;
+extern ia64_mv_inb_t __ia64_inb;
+extern ia64_mv_inw_t __ia64_inw;
+extern ia64_mv_inl_t __ia64_inl;
+extern ia64_mv_outb_t __ia64_outb;
+extern ia64_mv_outw_t __ia64_outw;
+extern ia64_mv_outl_t __ia64_outl;
+
 #define MACHVEC_HELPER(name)									\
  struct ia64_machine_vector machvec_##name __attribute__ ((unused, __secti=
on__ (".machvec")))	\
 	=3D MACHVEC_INIT(name);
diff -urN linux-davidm/include/asm-ia64/machvec_sn1.h linux-2.4.0-test10-li=
a/include/asm-ia64/machvec_sn1.h
--- linux-davidm/include/asm-ia64/machvec_sn1.h	Sun Feb  6 18:42:40 2000
+++ linux-2.4.0-test10-lia/include/asm-ia64/machvec_sn1.h	Wed Nov 15 18:16:=
14 2000
@@ -4,6 +4,7 @@
 extern ia64_mv_setup_t sn1_setup;
 extern ia64_mv_irq_init_t sn1_irq_init;
 extern ia64_mv_map_nr_t sn1_map_nr;
+extern ia64_mv_send_ipi_t sn1_send_IPI;
=20
 /*
  * This stuff has dual use!
@@ -16,5 +17,6 @@
 #define platform_setup		sn1_setup
 #define platform_irq_init	sn1_irq_init
 #define platform_map_nr		sn1_map_nr
+#define platform_send_ipi	sn1_send_IPI
=20
 #endif /* _ASM_IA64_MACHVEC_SN1_h */
diff -urN linux-davidm/include/asm-ia64/mmu_context.h linux-2.4.0-test10-li=
a/include/asm-ia64/mmu_context.h
--- linux-davidm/include/asm-ia64/mmu_context.h	Mon Oct  9 17:54:59 2000
+++ linux-2.4.0-test10-lia/include/asm-ia64/mmu_context.h	Wed Nov 15 22:54:=
13 2000
@@ -32,20 +32,11 @@
=20
 #define IA64_REGION_ID_KERNEL	0 /* the kernel's region id (tlb.c depends o=
n this being 0) */
=20
-#define IA64_REGION_ID_BITS	18
-
-#ifdef CONFIG_IA64_TLB_CHECKS_REGION_NUMBER
-# define IA64_HW_CONTEXT_BITS	IA64_REGION_ID_BITS
-#else
-# define IA64_HW_CONTEXT_BITS	(IA64_REGION_ID_BITS - 3)
-#endif
-
-#define IA64_HW_CONTEXT_MASK	((1UL << IA64_HW_CONTEXT_BITS) - 1)
-
 struct ia64_ctx {
 	spinlock_t lock;
 	unsigned int next;	/* next context number to use */
 	unsigned int limit;	/* next >=3D limit =3D> must call wrap_mmu_context() =
*/
+	unsigned int max_ctx;	/* max. context value supported by all CPUs */
 };
=20
 extern struct ia64_ctx ia64_ctx;
@@ -60,11 +51,7 @@
 static inline unsigned long
 ia64_rid (unsigned long context, unsigned long region_addr)
 {
-# ifdef CONFIG_IA64_TLB_CHECKS_REGION_NUMBER
-	return context;
-# else
 	return context << 3 | (region_addr >> 61);
-# endif
 }
=20
 static inline void
@@ -108,12 +95,8 @@
 	unsigned long rid_incr =3D 0;
 	unsigned long rr0, rr1, rr2, rr3, rr4;
=20
-	rid =3D mm->context;
-
-#ifndef CONFIG_IA64_TLB_CHECKS_REGION_NUMBER
-	rid <<=3D 3;	/* make space for encoding the region number */
+	rid =3D mm->context << 3;	/* make space for encoding the region number */
 	rid_incr =3D 1 << 8;
-#endif
=20
 	/* encode the region id, preferred page size, and VHPT enable bit: */
 	rr0 =3D (rid << 8) | (PAGE_SHIFT << 2) | 1;
@@ -132,11 +115,10 @@
 }
=20
 /*
- * Switch from address space PREV to address space NEXT.  Note that
- * TSK may be NULL.
+ * Switch from address space PREV to address space NEXT.
  */
 static inline void
-switch_mm (struct mm_struct *prev, struct mm_struct *next, struct task_str=
uct *tsk, unsigned cpu)
+activate_mm (struct mm_struct *prev, struct mm_struct *next)
 {
 	/*
 	 * We may get interrupts here, but that's OK because interrupt
@@ -147,7 +129,6 @@
 	reload_context(next);
 }
=20
-#define activate_mm(prev,next)					\
-	switch_mm((prev), (next), NULL, smp_processor_id())
+#define switch_mm(prev_mm,next_mm,next_task,cpu)	activate_mm(prev_mm, next=
_mm)
=20
 #endif /* _ASM_IA64_MMU_CONTEXT_H */
diff -urN linux-davidm/include/asm-ia64/page.h linux-2.4.0-test10-lia/inclu=
de/asm-ia64/page.h
--- linux-davidm/include/asm-ia64/page.h	Mon Oct  9 17:54:59 2000
+++ linux-2.4.0-test10-lia/include/asm-ia64/page.h	Wed Nov 15 22:54:12 2000
@@ -58,7 +58,6 @@
 #define pgprot_val(x)	((x).pgprot)
=20
 #define __pte(x)	((pte_t) { (x) } )
-#define __pgd(x)	((pgd_t) { (x) } )
 #define __pgprot(x)	((pgprot_t) { (x) } )
=20
 #  else /* !STRICT_MM_TYPECHECKS */
@@ -102,7 +101,7 @@
 #ifdef CONFIG_IA64_GENERIC
 # include <asm/machvec.h>
 # define virt_to_page(kaddr)   (mem_map + platform_map_nr(kaddr))
-#elif defined (CONFIG_IA64_SN_SN1)
+#elif defined (CONFIG_IA64_SN_SGI_SN1)
 # define virt_to_page(kaddr)   (mem_map + MAP_NR_SN1(kaddr))
 #else
 # define virt_to_page(kaddr)   (mem_map + MAP_NR_DENSE(kaddr))
diff -urN linux-davidm/include/asm-ia64/pgtable.h linux-2.4.0-test10-lia/in=
clude/asm-ia64/pgtable.h
--- linux-davidm/include/asm-ia64/pgtable.h	Wed Nov 15 23:09:41 2000
+++ linux-2.4.0-test10-lia/include/asm-ia64/pgtable.h	Wed Nov 15 22:54:13 2=
000
@@ -82,7 +82,7 @@
 #define PGDIR_SIZE		(__IA64_UL(1) << PGDIR_SHIFT)
 #define PGDIR_MASK		(~(PGDIR_SIZE-1))
 #define PTRS_PER_PGD		(__IA64_UL(1) << (PAGE_SHIFT-3))
-#define USER_PTRS_PER_PGD	PTRS_PER_PGD
+#define USER_PTRS_PER_PGD	(5*PTRS_PER_PGD/8)	/* regions 0-4 are user regio=
ns */
 #define FIRST_USER_PGD_NR	0
=20
 /*
@@ -101,9 +101,6 @@
  */
 #define PTRS_PER_PTE	(__IA64_UL(1) << (PAGE_SHIFT-3))
=20
-/* Number of pointers that fit on a page:  this will go away. */
-#define PTRS_PER_PAGE	(__IA64_UL(1) << (PAGE_SHIFT-3))
-
 # ifndef __ASSEMBLY__
=20
 #include <asm/bitops.h>
@@ -136,19 +133,19 @@
 #define __P001	PAGE_READONLY
 #define __P010	PAGE_READONLY	/* write to priv pg -> copy & make writable */
 #define __P011	PAGE_READONLY	/* ditto */
-#define __P100	__pgprot(_PAGE_ED | _PAGE_A | _PAGE_P | _PAGE_PL_3 | _PAGE_=
AR_X_RX)
-#define __P101	__pgprot(_PAGE_ED | _PAGE_A | _PAGE_P | _PAGE_PL_3 | _PAGE_=
AR_RX)
-#define __P110	__pgprot(_PAGE_ED | _PAGE_A | _PAGE_P | _PAGE_PL_3 | _PAGE_=
AR_RX)
-#define __P111	__pgprot(_PAGE_ED | _PAGE_A | _PAGE_P | _PAGE_PL_3 | _PAGE_=
AR_RX)
+#define __P100	__pgprot(__ACCESS_BITS | _PAGE_PL_3 | _PAGE_AR_X_RX)
+#define __P101	PAGE_COPY
+ #define __P110	PAGE_COPY
+#define __P111	PAGE_COPY
=20
 #define __S000	PAGE_NONE
 #define __S001	PAGE_READONLY
 #define __S010	PAGE_SHARED	/* we don't have (and don't need) write-only */
 #define __S011	PAGE_SHARED
-#define __S100	__pgprot(_PAGE_ED | _PAGE_A | _PAGE_P | _PAGE_PL_3 | _PAGE_=
AR_X_RX)
-#define __S101	__pgprot(_PAGE_ED | _PAGE_A | _PAGE_P | _PAGE_PL_3 | _PAGE_=
AR_RX)
-#define __S110	__pgprot(_PAGE_ED | _PAGE_A | _PAGE_P | _PAGE_PL_3 | _PAGE_=
AR_RWX)
-#define __S111	__pgprot(_PAGE_ED | _PAGE_A | _PAGE_P | _PAGE_PL_3 | _PAGE_=
AR_RWX)
+#define __S100	__pgprot(__ACCESS_BITS | _PAGE_PL_3 | _PAGE_AR_X_RX)
+#define __S101	__pgprot(__ACCESS_BITS | _PAGE_PL_3 | _PAGE_AR_RX)
+#define __S110	__pgprot(__ACCESS_BITS | _PAGE_PL_3 | _PAGE_AR_RWX)
+#define __S111	__pgprot(__ACCESS_BITS | _PAGE_PL_3 | _PAGE_AR_RWX)
=20
 #define pgd_ERROR(e)	printk("%s:%d: bad pgd %016lx.\n", __FILE__, __LINE__=
, pgd_val(e))
 #define pmd_ERROR(e)	printk("%s:%d: bad pmd %016lx.\n", __FILE__, __LINE__=
, pmd_val(e))
@@ -223,7 +220,7 @@
=20
 #define VMALLOC_START		(0xa000000000000000+2*PAGE_SIZE)
 #define VMALLOC_VMADDR(x)	((unsigned long)(x))
-#define VMALLOC_END		0xbfffffffffffffff
+#define VMALLOC_END		(0xa000000000000000+ (1UL << (4*PAGE_SHIFT - 13)))
=20
 /*
  * BAD_PAGETABLE is used when we need a bogus page-table, while
@@ -285,8 +282,8 @@
  */
 #define pte_read(pte)		(((pte_val(pte) & _PAGE_AR_MASK) >> _PAGE_AR_SHIFT)=
 < 6)
 #define pte_write(pte)	((unsigned) (((pte_val(pte) & _PAGE_AR_MASK) >> _PA=
GE_AR_SHIFT) - 2) < 4)
-#define pte_dirty(pte)		(pte_val(pte) & _PAGE_D)
-#define pte_young(pte)		(pte_val(pte) & _PAGE_A)
+#define pte_dirty(pte)		((pte_val(pte) & _PAGE_D) !=3D 0)
+#define pte_young(pte)		((pte_val(pte) & _PAGE_A) !=3D 0)
 /*
  * Note: we convert AR_RWX to AR_RX and AR_RW to AR_R by clearing the
  * 2nd bit in the access rights:
@@ -380,37 +377,68 @@
 static inline int
 ptep_test_and_clear_young (pte_t *ptep)
 {
+#ifdef CONFIG_SMP
 	return test_and_clear_bit(_PAGE_A_BIT, ptep);
+#else
+	pte_t pte =3D *ptep;
+	if (!pte_young(pte))
+		return 0;
+	set_pte(ptep, pte_mkold(pte));
+	return 1;
+#endif
 }
=20
 static inline int
 ptep_test_and_clear_dirty (pte_t *ptep)
 {
+#ifdef CONFIG_SMP
 	return test_and_clear_bit(_PAGE_D_BIT, ptep);
+#else
+	pte_t pte =3D *ptep;
+	if (!pte_dirty(pte))
+		return 0;
+	set_pte(ptep, pte_mkclean(pte));
+	return 1;
+#endif
 }
=20
 static inline pte_t
 ptep_get_and_clear (pte_t *ptep)
 {
+#ifdef CONFIG_SMP
 	return __pte(xchg((long *) ptep, 0));
+#else
+	pte_t pte =3D *ptep;
+	pte_clear(ptep);
+	return pte;
+#endif
 }
=20
-/* XXX this should be called ptep_set_wrprotect!!! */
 static inline void
-ptep_clear_wrprotect (pte_t *ptep)
+ptep_set_wrprotect (pte_t *ptep)
 {
+#ifdef CONFIG_SMP
 	unsigned long new, old;
=20
 	do {
 		old =3D pte_val(*ptep);
 		new =3D pte_val(pte_wrprotect(__pte (old)));
 	} while (cmpxchg((unsigned long *) ptep, old, new) !=3D old);
+#else
+	pte_t old_pte =3D *ptep;
+	set_pte(ptep, pte_wrprotect(old_pte));
+#endif
 }
=20
 static inline void
 ptep_mkdirty (pte_t *ptep)
 {
+#ifdef CONFIG_SMP
 	set_bit(_PAGE_D_BIT, ptep);
+#else
+	pte_t old_pte =3D *ptep;
+	set_pte(ptep, pte_mkdirty(old_pte));
+#endif
 }
=20
 static inline int
@@ -444,16 +472,13 @@
 # define update_mmu_cache(vma,address,pte)							\
 do {												\
 	/*											\
-	 * XXX fix me!!										\
-	 *											\
-	 * It's not clear this is a win.  We may end up pollute the				\
+	 * This is usually not a win.  We may end up polluting the				\
 	 * dtlb with itlb entries and vice versa (e.g., consider stack				\
 	 * pages that are normally marked executable).  It would be				\
 	 * better to insert the TLB entry for the TLB cache that we				\
 	 * know needs the new entry.  However, the update_mmu_cache()				\
 	 * arguments don't tell us whether we got here through a data				\
-	 * access or through an instruction fetch.  Talk to Linus to				\
-	 * fix this.										\
+	 * access or through an instruction fetch.						\
 	 *											\
 	 * If you re-enable this code, you must disable the ptc code in				\
 	 * Entry 20 of the ivt.									\
@@ -467,7 +492,7 @@
 #endif
=20
 #define SWP_TYPE(entry)			(((entry).val >> 1) & 0xff)
-#define SWP_OFFSET(entry)		((entry).val >> 9)
+#define SWP_OFFSET(entry)		(((entry).val << 1) >> 10)
 #define SWP_ENTRY(type,offset)		((swp_entry_t) { ((type) << 1) | ((offset)=
 << 9) })
 #define pte_to_swp_entry(pte)		((swp_entry_t) { pte_val(pte) })
 #define swp_entry_to_pte(x)		((pte_t) { (x).val })
diff -urN linux-davidm/include/asm-ia64/processor.h linux-2.4.0-test10-lia/=
include/asm-ia64/processor.h
--- linux-davidm/include/asm-ia64/processor.h	Wed Nov 15 23:09:41 2000
+++ linux-2.4.0-test10-lia/include/asm-ia64/processor.h	Wed Nov 15 22:54:12=
 2000
@@ -248,6 +248,9 @@
 	__u64 usec_per_cyc;	/* 2^IA64_USEC_PER_CYC_SHIFT*1000000/itc_freq */
 	__u64 unimpl_va_mask;	/* mask of unimplemented virtual address bits (from=
 PAL) */
 	__u64 unimpl_pa_mask;	/* mask of unimplemented physical address bits (fro=
m PAL) */
+	__u64 ptce_base;
+	__u32 ptce_count[2];
+	__u32 ptce_stride[2];
 #ifdef CONFIG_SMP
 	__u64 loops_per_sec;
 	__u64 ipi_count;
diff -urN linux-davidm/include/asm-ia64/sal.h linux-2.4.0-test10-lia/includ=
e/asm-ia64/sal.h
--- linux-davidm/include/asm-ia64/sal.h	Mon Oct  9 17:55:00 2000
+++ linux-2.4.0-test10-lia/include/asm-ia64/sal.h	Wed Nov 15 22:54:23 2000
@@ -24,7 +24,9 @@
=20
 extern spinlock_t sal_lock;
=20
-#define __SAL_CALL(result,args...)	result =3D (*ia64_sal)(args)
+/* SAL spec _requires_ eight args for each call. */
+#define __SAL_CALL(result,a0,a1,a2,a3,a4,a5,a6,a7)	\
+	result =3D (*ia64_sal)(a0,a1,a2,a3,a4,a5,a6,a7)
=20
 #ifdef CONFIG_SMP
 # define SAL_CALL(result,args...) do {		\
@@ -60,10 +62,10 @@
 	 * informational value should be printed (e.g., "reboot for
 	 * change to take effect").
 	 */
-	s64 	status;
-	u64 	v0;
-	u64 	v1;
-	u64 	v2;
+	s64 status;
+	u64 v0;
+	u64 v1;
+	u64 v2;
 };
=20
 typedef struct ia64_sal_retval (*ia64_sal_handler) (u64, ...);
@@ -78,24 +80,27 @@
  * The SAL system table is followed by a variable number of variable
  * length descriptors.  The structure of these descriptors follows
  * below.
+ * The defininition follows SAL specs from July 2000
  */
 struct ia64_sal_systab {
-	char signature[4];	/* should be "SST_" */
-	int size;		/* size of this table in bytes */
-	unsigned char sal_rev_minor;
-	unsigned char sal_rev_major;
-	unsigned short entry_count;	/* # of entries in variable portion */
-	unsigned char checksum;
-	char ia32_bios_present;
-	unsigned short reserved1;
-	char oem_id[32];	/* ASCII NUL terminated OEM id
-				   (terminating NUL is missing if
-				   string is exactly 32 bytes long). */
-	char product_id[32];	/* ASCII product id  */
-	char reserved2[16];
+	u8 signature[4];	/* should be "SST_" */
+	u32 size;		/* size of this table in bytes */
+	u8 sal_rev_minor;
+	u8 sal_rev_major;
+	u16 entry_count;	/* # of entries in variable portion */
+	u8 checksum;
+	u8 reserved1[7];
+	u8 sal_a_rev_minor;
+	u8 sal_a_rev_major;
+	u8 sal_b_rev_minor;
+	u8 sal_b_rev_major;
+	/* oem_id & product_id: terminating NUL is missing if string is exactly 3=
2 bytes long. */
+	u8 oem_id[32];
+	u8 product_id[32];	/* ASCII product id  */
+	u8 reserved2[8];
 };
=20
-enum SAL_Systab_Entry_Type {
+enum sal_systab_entry_type {
 	SAL_DESC_ENTRY_POINT =3D 0,
 	SAL_DESC_MEMORY =3D 1,
 	SAL_DESC_PLATFORM_FEATURE =3D 2,
@@ -115,75 +120,78 @@
  */
 #define SAL_DESC_SIZE(type)	"\060\040\020\040\020\020"[(unsigned) type]
=20
-struct ia64_sal_desc_entry_point {
-	char type;
-	char reserved1[7];
-	s64 pal_proc;
-	s64 sal_proc;
-	s64 gp;
-	char reserved2[16];
-};
-
-struct ia64_sal_desc_memory {
-	char type;
-	char used_by_sal;	/* needs to be mapped for SAL? */
-	char mem_attr;		/* current memory attribute setting */
-	char access_rights;	/* access rights set up by SAL */
-	char mem_attr_mask;	/* mask of supported memory attributes */
-	char reserved1;
-	char mem_type;		/* memory type */
-	char mem_usage;		/* memory usage */
-	s64 addr;		/* physical address of memory */
-	unsigned int length;	/* length (multiple of 4KB pages) */
-	unsigned int reserved2;
-	char oem_reserved[8];
-};
+typedef struct ia64_sal_desc_entry_point {
+	u8 type;
+	u8 reserved1[7];
+	u64 pal_proc;
+	u64 sal_proc;
+	u64 gp;
+	u8 reserved2[16];
+}ia64_sal_desc_entry_point_t;
+
+typedef struct ia64_sal_desc_memory {
+	u8 type;
+	u8 used_by_sal;	/* needs to be mapped for SAL? */
+	u8 mem_attr;		/* current memory attribute setting */
+	u8 access_rights;	/* access rights set up by SAL */
+	u8 mem_attr_mask;	/* mask of supported memory attributes */
+	u8 reserved1;
+	u8 mem_type;		/* memory type */
+	u8 mem_usage;		/* memory usage */
+	u64 addr;		/* physical address of memory */
+	u32 length;	/* length (multiple of 4KB pages) */
+	u32 reserved2;
+	u8 oem_reserved[8];
+} ia64_sal_desc_memory_t;
=20
 #define IA64_SAL_PLATFORM_FEATURE_BUS_LOCK		(1 << 0)
 #define IA64_SAL_PLATFORM_FEATURE_IRQ_REDIR_HINT	(1 << 1)
 #define IA64_SAL_PLATFORM_FEATURE_IPI_REDIR_HINT	(1 << 2)
=20
-struct ia64_sal_desc_platform_feature {
-	char type;
-	unsigned char feature_mask;
-	char reserved1[14];
-};
-
-struct ia64_sal_desc_tr {
-	char type;
-	char tr_type;		/* 0 =3D instruction, 1 =3D data */
-	char regnum;		/* translation register number */
-	char reserved1[5];
-	s64 addr;		/* virtual address of area covered */
-	s64 page_size;		/* encoded page size */
-	char reserved2[8];
-};
+typedef struct ia64_sal_desc_platform_feature {
+	u8 type;
+	u8 feature_mask;
+	u8 reserved1[14];
+} ia64_sal_desc_platform_feature_t;
+
+typedef struct ia64_sal_desc_tr {
+	u8 type;
+	u8 tr_type;		/* 0 =3D instruction, 1 =3D data */
+	u8 regnum;		/* translation register number */
+	u8 reserved1[5];
+	u64 addr;		/* virtual address of area covered */
+	u64 page_size;		/* encoded page size */
+	u8 reserved2[8];
+} ia64_sal_desc_tr_t;
=20
 typedef struct ia64_sal_desc_ptc {
-	char type;
-	char reserved1[3];
-	unsigned int num_domains;	/* # of coherence domains */
-	s64  domain_info;		/* physical address of domain info table */
+	u8 type;
+	u8 reserved1[3];
+	u32 num_domains;	/* # of coherence domains */
+	u64 domain_info;	/* physical address of domain info table */
 } ia64_sal_desc_ptc_t;
=20
 typedef struct ia64_sal_ptc_domain_info {
-	unsigned long proc_count;	/* number of processors in domain */
-	long proc_list;			/* physical address of LID array */
+	u64 proc_count;		/* number of processors in domain */
+	u64 proc_list;		/* physical address of LID array */
 } ia64_sal_ptc_domain_info_t;
=20
 typedef struct ia64_sal_ptc_domain_proc_entry {
-	unsigned char id;		/* id of processor */
-	unsigned char eid;		/* eid of processor */
+	u64 reserved : 16;
+	u64 eid : 8;		/* eid of processor */
+	u64 id  : 8;		/* id of processor */
+	u64 ignored : 32;
 } ia64_sal_ptc_domain_proc_entry_t;
=20
+
 #define IA64_SAL_AP_EXTERNAL_INT 0
=20
-struct ia64_sal_desc_ap_wakeup {
-	char type;
-	char mechanism;		/* 0 =3D external interrupt */
-	char reserved1[6];
-	long vector;		/* interrupt vector in range 0x10-0xff */
-};
+typedef struct ia64_sal_desc_ap_wakeup {
+	u8 type;
+	u8 mechanism;		/* 0 =3D external interrupt */
+	u8 reserved1[6];
+	u64 vector;		/* interrupt vector in range 0x10-0xff */
+} ia64_sal_desc_ap_wakeup_t ;
=20
 extern ia64_sal_handler ia64_sal;
 extern struct ia64_sal_desc_ptc *ia64_ptc_domain_info;
@@ -218,24 +226,24 @@
=20
 /* Encodings for vectors which can be registered by the OS with SAL */
 enum {
-	SAL_VECTOR_OS_MCA		=3D	0,
-	SAL_VECTOR_OS_INIT		=3D	1,
-	SAL_VECTOR_OS_BOOT_RENDEZ	=3D	2
+	SAL_VECTOR_OS_MCA		=3D 0,
+	SAL_VECTOR_OS_INIT		=3D 1,
+	SAL_VECTOR_OS_BOOT_RENDEZ	=3D 2
 };
=20
 /* Definition of the SAL Error Log from the SAL spec */
=20
 /* Definition of timestamp according to SAL spec for logging purposes */
=20
-typedef struct sal_log_timestamp_s {
-	u8	slh_century;				/* Century (19, 20, 21, ...) */
-	u8	slh_year;				/* Year (00..99) */
-	u8	slh_month;				/* Month (1..12) */
-	u8	slh_day;				/* Day (1..31) */
-	u8	slh_reserved;				=09
-	u8	slh_hour;				/* Hour (0..23)	*/
-	u8	slh_minute;				/* Minute (0..59) */
-	u8	slh_second;				/* Second (0..59) */
+typedef struct sal_log_timestamp {
+	u8 slh_century;		/* Century (19, 20, 21, ...) */
+	u8 slh_year;		/* Year (00..99) */
+	u8 slh_month;		/* Month (1..12) */
+	u8 slh_day;		/* Day (1..31) */
+	u8 slh_reserved;				=09
+	u8 slh_hour;		/* Hour (0..23)	*/
+	u8 slh_minute;		/* Minute (0..59) */
+	u8 slh_second;		/* Second (0..59) */
 } sal_log_timestamp_t;
=20
=20
@@ -243,126 +251,126 @@
 #define MAX_TLB_ERRORS				6
 #define MAX_BUS_ERRORS				1
=20
-typedef struct sal_log_processor_info_s {
+typedef struct sal_log_processor_info {
 	struct	{
-		u64		slpi_psi	: 1,
-				slpi_cache_check: MAX_CACHE_ERRORS,
-				slpi_tlb_check	: MAX_TLB_ERRORS,
-				slpi_bus_check	: MAX_BUS_ERRORS,
-				slpi_reserved2	: (31 - (MAX_TLB_ERRORS + MAX_CACHE_ERRORS
-							 + MAX_BUS_ERRORS)),
-				slpi_minstate	: 1,
-				slpi_bank1_gr	: 1,
-				slpi_br		: 1,
-				slpi_cr		: 1,
-				slpi_ar		: 1,
-				slpi_rr		: 1,
-				slpi_fr		: 1,
-				slpi_reserved1	: 25;
+		u64 slpi_psi		: 1,
+		    slpi_cache_check: MAX_CACHE_ERRORS,
+		    slpi_tlb_check	: MAX_TLB_ERRORS,
+		    slpi_bus_check	: MAX_BUS_ERRORS,
+		    slpi_reserved2	: (31 - (MAX_TLB_ERRORS + MAX_CACHE_ERRORS
+		    			 + MAX_BUS_ERRORS)),
+		    slpi_minstate	: 1,
+		    slpi_bank1_gr	: 1,
+		    slpi_br		: 1,
+		    slpi_cr		: 1,
+		    slpi_ar		: 1,
+		    slpi_rr		: 1,
+		    slpi_fr		: 1,
+		    slpi_reserved1	: 25;
 	} slpi_valid;
=20
-	pal_processor_state_info_t	slpi_processor_state_info;
+	pal_processor_state_info_t slpi_processor_state_info;
=20
 	struct {
-		pal_cache_check_info_t	slpi_cache_check;
-		u64			slpi_target_address;
+		pal_cache_check_info_t slpi_cache_check;
+		u64 slpi_target_address;
 	} slpi_cache_check_info[MAX_CACHE_ERRORS];
 	=09
-	pal_tlb_check_info_t		slpi_tlb_check_info[MAX_TLB_ERRORS];
+	pal_tlb_check_info_t slpi_tlb_check_info[MAX_TLB_ERRORS];
=20
 	struct {
-		pal_bus_check_info_t	slpi_bus_check;
-		u64			slpi_requestor_addr;=09
-		u64			slpi_responder_addr;=09
-		u64			slpi_target_addr;
+		pal_bus_check_info_t slpi_bus_check;
+		u64 slpi_requestor_addr;=09
+		u64 slpi_responder_addr;=09
+		u64 slpi_target_addr;
 	} slpi_bus_check_info[MAX_BUS_ERRORS];
=20
-	pal_min_state_area_t		slpi_min_state_area;
-	u64				slpi_br[8];
-	u64				slpi_cr[128];
-	u64				slpi_ar[128];
-	u64				slpi_rr[8];
-	u64				slpi_fr[128];
+	pal_min_state_area_t slpi_min_state_area;
+	u64 slpi_br[8];
+	u64 slpi_cr[128];
+	u64 slpi_ar[128];
+	u64 slpi_rr[8];
+	u64 slpi_fr[128];
 } sal_log_processor_info_t;
=20
 /* platform error log structures */
 typedef struct platerr_logheader {
-	u64	nextlog;	/* next log offset if present */
-	u64	loglength;	/* log length */
-	u64	logsubtype;	/* log subtype memory/bus/component */
-	u64	eseverity;	/* error severity */
+	u64 nextlog;		/* next log offset if present */
+	u64 loglength;		/* log length */
+	u64 logsubtype;		/* log subtype memory/bus/component */
+	u64 eseverity;		/* error severity */
 } ehdr_t;
=20
 typedef struct sysmem_errlog {
-	ehdr_t	lhdr;		/* header */
-	u64	vflag;		/* valid bits for each field in the log */
-	u64	addr;		/* memory address */
-	u64	data;		/* memory data */
-	u64	cmd;		/* command bus value if any */
-	u64	ctrl;		/* control bus value if any */
-	u64	addrsyndrome;	/* memory address ecc/parity syndrome bits */
-	u64	datasyndrome;	/* data ecc/parity syndrome */
-	u64	cacheinfo;	/* platform cache info as defined in pal spec. table 7-34 =
*/
+	ehdr_t lhdr;		/* header */
+	u64 vflag;		/* valid bits for each field in the log */
+	u64 addr;		/* memory address */
+	u64 data;		/* memory data */
+	u64 cmd;		/* command bus value if any */
+	u64 ctrl;		/* control bus value if any */
+	u64 addrsyndrome;	/* memory address ecc/parity syndrome bits */
+	u64 datasyndrome;	/* data ecc/parity syndrome */
+	u64 cacheinfo;		/* platform cache info as defined in pal spec. table 7-34=
 */
 } merrlog_t;
=20
 typedef struct sysbus_errlog {
-	ehdr_t	lhdr;		/* linkded list header */
-	u64	vflag;		/* valid bits for each field in the log */
-	u64	busnum;		/* bus number in error */
-	u64	reqaddr;	/* requestor address */
-	u64	resaddr;	/* responder address */
-	u64	taraddr;	/* target address */
-	u64	data;		/* requester r/w data */
-	u64	cmd;		/* bus commands */
-	u64	ctrl;		/* bus controls (be# &-0) */
-	u64	addrsyndrome;	/* addr bus ecc/parity bits */
-	u64	datasyndrome;	/* data bus ecc/parity bits */
-	u64	cmdsyndrome;	/* command bus ecc/parity bits */
-	u64	ctrlsyndrome;	/* control bus ecc/parity bits */
+	ehdr_t lhdr;		/* linkded list header */
+	u64 vflag;		/* valid bits for each field in the log */
+	u64 busnum;		/* bus number in error */
+	u64 reqaddr;		/* requestor address */
+	u64 resaddr;		/* responder address */
+	u64 taraddr;		/* target address */
+	u64 data;		/* requester r/w data */
+	u64 cmd;		/* bus commands */
+	u64 ctrl;		/* bus controls (be# &-0) */
+	u64 addrsyndrome;	/* addr bus ecc/parity bits */
+	u64 datasyndrome;	/* data bus ecc/parity bits */
+	u64 cmdsyndrome;	/* command bus ecc/parity bits */
+	u64 ctrlsyndrome;	/* control bus ecc/parity bits */
 } berrlog_t;
=20
 /* platform error log structures */
 typedef struct syserr_chdr {	/* one header per component */
-	u64	busnum;		/* bus number on which the component resides */
-	u64	devnum;		/* same as device select */
-	u64	funcid;		/* function id of the device */
-	u64	devid;		/* pci device id */
-	u64	classcode;	/* pci class code for the device */
-	u64	cmdreg;		/* pci command reg value */
-	u64	statreg;	/* pci status reg value */
+	u64 busnum;		/* bus number on which the component resides */
+	u64 devnum;		/* same as device select */
+	u64 funcid;		/* function id of the device */
+	u64 devid;		/* pci device id */
+	u64 classcode;		/* pci class code for the device */
+	u64 cmdreg;		/* pci command reg value */
+	u64 statreg;		/* pci status reg value */
 } chdr_t;
=20
 typedef struct cfginfo {
-	u64	cfgaddr;
-	u64	cfgval;
+	u64 cfgaddr;
+	u64 cfgval;
 } cfginfo_t;
=20
 typedef struct sys_comperr {	/* per component */
-	ehdr_t	lhdr;		/* linked list header */
-	u64	vflag;		/* valid bits for each field in the log */
-	chdr_t	scomphdr;=09
-	u64	numregpair;	/* number of reg addr/value pairs */
+	ehdr_t lhdr;		/* linked list header */
+	u64 vflag;		/* valid bits for each field in the log */
+	chdr_t scomphdr;=09
+	u64 numregpair;		/* number of reg addr/value pairs */
 	cfginfo_t cfginfo;
 } cerrlog_t;
=20
 typedef struct sel_records {
-	ehdr_t	lhdr;
-	u64	seldata;
+	ehdr_t lhdr;
+	u64 seldata;
 } isel_t;
=20
 typedef struct plat_errlog {
-	u64	      mbcsvalid;	/* valid bits for each type of log */
-	merrlog_t     smemerrlog;	/* platform memory error logs */
-	berrlog_t     sbuserrlog;	/* platform bus error logs */
-	cerrlog_t     scomperrlog;	/* platform chipset error logs */
-	isel_t	      selrecord;	/* ipmi sel record */
+	u64 mbcsvalid;		/* valid bits for each type of log */
+	merrlog_t smemerrlog;	/* platform memory error logs */
+	berrlog_t sbuserrlog;	/* platform bus error logs */
+	cerrlog_t scomperrlog;	/* platform chipset error logs */
+	isel_t selrecord;	/* ipmi sel record */
 } platforminfo_t;
=20
 /* over all log structure (processor+platform) */
=20
 typedef union udev_specific_log {
-	sal_log_processor_info_t  proclog;
-	platforminfo_t		  platlog;
+	sal_log_processor_info_t proclog;
+	platforminfo_t platlog;
 } devicelog_t;
=20
=20
@@ -378,21 +386,18 @@
 #define sal_log_processor_info_rr_valid			slpi_valid.slpi_rr
 #define sal_log_processor_info_fr_valid			slpi_valid.slpi_fr
=20
-typedef struct sal_log_header_s {
-	u64			slh_next_log;		/* Offset of the next log from the=20
-							 * beginning of  this structure.
-							 */
-	uint			slh_log_len;		/* Length of this error log in bytes */
-	ushort			slh_log_type;		/* Type of log (0 - cpu ,1 - platform) */
-	ushort			slh_log_sub_type;	/* SGI specific sub type */
-	sal_log_timestamp_t	slh_log_timestamp;	/* Timestamp */
+typedef struct sal_log_header {
+	u64 slh_next_log;	/* Offset of the next log from the beginning of this st=
ructure */
+	u32 slh_log_len;	/* Length of this error log in bytes */
+	u16 slh_log_type;	/* Type of log (0 - cpu ,1 - platform) */
+	u16 slh_log_sub_type;	/* SGI specific sub type */
+	sal_log_timestamp_t slh_log_timestamp;	/* Timestamp */
 } sal_log_header_t;
=20
 /* SAL PSI log structure */
-typedef struct psilog
-{
-	sal_log_header_t   sal_elog_header;
-	devicelog_t        devlog;
+typedef struct psilog {
+	sal_log_header_t sal_elog_header;
+	devicelog_t devlog;
 } ia64_psilog_t;
=20
 /*
@@ -405,7 +410,7 @@
 {
 	struct ia64_sal_retval isrv;
=20
-	SAL_CALL(isrv, SAL_FREQ_BASE, which);
+	SAL_CALL(isrv, SAL_FREQ_BASE, which, 0, 0, 0, 0, 0, 0);
 	*ticks_per_second =3D isrv.v0;
 	*drift_info =3D isrv.v1;
 	return isrv.status;
@@ -416,7 +421,7 @@
 ia64_sal_cache_flush (u64 cache_type)
 {
 	struct ia64_sal_retval isrv;
-	SAL_CALL(isrv, SAL_CACHE_FLUSH, cache_type);
+	SAL_CALL(isrv, SAL_CACHE_FLUSH, cache_type, 0, 0, 0, 0, 0, 0);
 	return isrv.status;
 }
=20
@@ -427,7 +432,7 @@
 ia64_sal_cache_init (void)
 {
 	struct ia64_sal_retval isrv;
-	SAL_CALL(isrv, SAL_CACHE_INIT);
+	SAL_CALL(isrv, SAL_CACHE_INIT, 0, 0, 0, 0, 0, 0, 0);
 	return isrv.status;
 }
=20
@@ -438,7 +443,8 @@
 ia64_sal_clear_state_info (u64 sal_info_type, u64 sal_info_sub_type)
 {
 	struct ia64_sal_retval isrv;
-	SAL_CALL(isrv, SAL_CLEAR_STATE_INFO, sal_info_type, sal_info_sub_type);
+	SAL_CALL(isrv, SAL_CLEAR_STATE_INFO, sal_info_type, sal_info_sub_type,
+	         0, 0, 0, 0, 0);
 	return isrv.status;
 }
=20
@@ -450,7 +456,8 @@
 ia64_sal_get_state_info (u64 sal_info_type, u64 sal_info_sub_type, u64 *sa=
l_info)
 {
 	struct ia64_sal_retval isrv;
-	SAL_CALL(isrv, SAL_GET_STATE_INFO, sal_info_type, sal_info_sub_type, sal_=
info);
+	SAL_CALL(isrv, SAL_GET_STATE_INFO, sal_info_type, sal_info_sub_type,
+	         sal_info, 0, 0, 0, 0);
 	if (isrv.status)
 		return 0;
 	return isrv.v0;
@@ -462,7 +469,8 @@
 ia64_sal_get_state_info_size (u64 sal_info_type, u64 sal_info_sub_type)
 {
 	struct ia64_sal_retval isrv;
-	SAL_CALL(isrv, SAL_GET_STATE_INFO_SIZE, sal_info_type, sal_info_sub_type);
+	SAL_CALL(isrv, SAL_GET_STATE_INFO_SIZE, sal_info_type, sal_info_sub_type,
+	         0, 0, 0, 0, 0);
 	if (isrv.status)
 		return 0;
 	return isrv.v0;
@@ -475,7 +483,7 @@
 ia64_sal_mc_rendez (void)
 {
 	struct ia64_sal_retval isrv;
-	SAL_CALL(isrv, SAL_MC_RENDEZ);
+	SAL_CALL(isrv, SAL_MC_RENDEZ, 0, 0, 0, 0, 0, 0, 0);
 	return isrv.status;
 }
=20
@@ -487,7 +495,8 @@
 ia64_sal_mc_set_params (u64 param_type, u64 i_or_m, u64 i_or_m_val, u64 ti=
meout)
 {
 	struct ia64_sal_retval isrv;
-	SAL_CALL(isrv, SAL_MC_SET_PARAMS, param_type, i_or_m, i_or_m_val, timeout=
);
+	SAL_CALL(isrv, SAL_MC_SET_PARAMS, param_type, i_or_m, i_or_m_val, timeout,
+	         0, 0, 0);
 	return isrv.status;
 }
=20
@@ -505,7 +514,7 @@
 	 */
 	spin_lock_irqsave(&ivr_read_lock, flags);
 #endif
-	SAL_CALL(isrv, SAL_PCI_CONFIG_READ, pci_config_addr, size);
+	SAL_CALL(isrv, SAL_PCI_CONFIG_READ, pci_config_addr, size, 0, 0, 0, 0, 0);
 #ifdef CONFIG_ITANIUM_A1_SPECIFIC
 	spin_unlock_irqrestore(&ivr_read_lock, flags);
 #endif
@@ -528,7 +537,8 @@
 	 */
 	spin_lock_irqsave(&ivr_read_lock, flags);
 #endif
-	SAL_CALL(isrv, SAL_PCI_CONFIG_WRITE, pci_config_addr, size, value);
+	SAL_CALL(isrv, SAL_PCI_CONFIG_WRITE, pci_config_addr, size, value,
+	         0, 0, 0, 0);
 #ifdef CONFIG_ITANIUM_A1_SPECIFIC
 	spin_unlock_irqrestore(&ivr_read_lock, flags);
 #endif
@@ -543,7 +553,8 @@
 ia64_sal_register_physical_addr (u64 phys_entry, u64 phys_addr)
 {
 	struct ia64_sal_retval isrv;
-	SAL_CALL(isrv, SAL_REGISTER_PHYSICAL_ADDR, phys_entry, phys_addr);
+	SAL_CALL(isrv, SAL_REGISTER_PHYSICAL_ADDR, phys_entry, phys_addr,
+	         0, 0, 0, 0, 0);
 	return isrv.status;
 }
=20
@@ -569,7 +580,8 @@
 		     u64 *error_code, u64 *scratch_buf_size_needed)
 {
 	struct ia64_sal_retval isrv;
-	SAL_CALL(isrv, SAL_UPDATE_PAL, param_buf, scratch_buf, scratch_buf_size);
+	SAL_CALL(isrv, SAL_UPDATE_PAL, param_buf, scratch_buf, scratch_buf_size,
+	         0, 0, 0, 0);
 	if (error_code)
 		*error_code =3D isrv.v0;
 	if (scratch_buf_size_needed)
diff -urN linux-davidm/kernel/printk.c linux-2.4.0-test10-lia/kernel/printk=
.c
--- linux-davidm/kernel/printk.c	Wed Nov 15 23:09:41 2000
+++ linux-2.4.0-test10-lia/kernel/printk.c	Wed Nov 15 19:49:26 2000
@@ -512,7 +512,7 @@
=20
 #include <asm/io.h>
=20
-#define VGABASE		((char *)0x00000000000b8000)
+#define VGABASE		((char *)0xc0000000000b8000)
=20
 static int current_ypos =3D 50, current_xpos =3D 0;
=20
diff -urN linux-davidm/mm/memory.c linux-2.4.0-test10-lia/mm/memory.c
--- linux-davidm/mm/memory.c	Mon Oct 30 14:32:57 2000
+++ linux-2.4.0-test10-lia/mm/memory.c	Wed Nov 15 19:49:41 2000
@@ -227,7 +227,7 @@
=20
 				/* If it's a COW mapping, write protect it both in the parent and the =
child */
 				if (cow) {
-					ptep_clear_wrprotect(src_pte);
+					ptep_set_wrprotect(src_pte);
 					pte =3D *src_pte;
 				}
=20

