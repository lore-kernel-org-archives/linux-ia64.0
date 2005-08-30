From: Keith Owens <kaos@sgi.com>
Date: Tue, 30 Aug 2005 05:04:35 +0000
Subject: [PATCH 2.6.13 4/7] MCA/INIT: use per cpu stacks
Message-Id: <20050830050435.7997.24322.sendpatchset@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

The bulk of the change.  Use per cpu MCA/INIT stacks.  Change the SAL
to OS state (sos) to be per process.  Do all the assembler work on the
MCA/INIT stacks, leaving the original stack alone.  Pass per cpu state
data to the C handlers for MCA and INIT, which also means changing the
mca_drv interfaces slightly.  Lots of verification on whether the
original stack is usable before converting it to a sleeping process.

Signed-off-by: Keith Owens <kaos@sgi.com>

---

 arch/ia64/kernel/asm-offsets.c |   40 +
 arch/ia64/kernel/mca.c         |  808 +++++++++++++++----------
 arch/ia64/kernel/mca_asm.S     | 1281 ++++++++++++++++++++----------------=
-----
 arch/ia64/kernel/mca_drv.c     |   37 -
 include/asm-ia64/mca.h         |  102 ++-
 include/asm-ia64/mca_asm.h     |  131 ----
 6 files changed, 1273 insertions(+), 1126 deletions(-)

Index: linux/include/asm-ia64/mca_asm.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig/include/asm-ia64/mca_asm.h	2005-08-3=
0 13:56:12.510151860 +1000
+++ linux/include/asm-ia64/mca_asm.h	2005-08-30 13:56:31.817089272 +1000
@@ -8,6 +8,8 @@
  * Copyright (C) 2000 David Mosberger-Tang <davidm@hpl.hp.com>
  * Copyright (C) 2002 Intel Corp.
  * Copyright (C) 2002 Jenna Hall <jenna.s.hall@intel.com>
+ * Copyright (C) 2005 Silicon Graphics, Inc
+ * Copyright (C) 2005 Keith Owens <kaos@sgi.com>
  */
 #ifndef _ASM_IA64_MCA_ASM_H
 #define _ASM_IA64_MCA_ASM_H
@@ -207,106 +209,33 @@
 	;;
=20
 /*
- * The following offsets capture the order in which the
- * RSE related registers from the old context are
- * saved onto the new stack frame.
- *
- *	+-----------------------+
- *	|NDIRTY [BSP - BSPSTORE]|
- *	+-----------------------+
- *	|	RNAT		|
- *	+-----------------------+
- *	|	BSPSTORE	|
- *	+-----------------------+
- *	|	IFS		|
- *	+-----------------------+
- *	|	PFS		|
- *	+-----------------------+
- *	|	RSC		|
- *	+-----------------------+ <-------- Bottom of new stack frame
- */
-#define  rse_rsc_offset		0
-#define  rse_pfs_offset		(rse_rsc_offset+0x08)
-#define  rse_ifs_offset		(rse_pfs_offset+0x08)
-#define  rse_bspstore_offset	(rse_ifs_offset+0x08)
-#define  rse_rnat_offset	(rse_bspstore_offset+0x08)
-#define  rse_ndirty_offset	(rse_rnat_offset+0x08)
-
-/*
- * rse_switch_context
- *
- *	1. Save old RSC onto the new stack frame
- *	2. Save PFS onto new stack frame
- *	3. Cover the old frame and start a new frame.
- *	4. Save IFS onto new stack frame
- *	5. Save the old BSPSTORE on the new stack frame
- *	6. Save the old RNAT on the new stack frame
- *	7. Write BSPSTORE with the new backing store pointer
- *	8. Read and save the new BSP to calculate the #dirty registers
- * NOTE: Look at pages 11-10, 11-11 in PRM Vol 2
- */
-#define rse_switch_context(temp,p_stackframe,p_bspstore)			\
-	;;									\
-	mov     temp=3Dar.rsc;;							\
-	st8     [p_stackframe]=3Dtemp,8;;					\
-	mov     temp=3Dar.pfs;;							\
-	st8     [p_stackframe]=3Dtemp,8;						\
-	cover ;;								\
-	mov     temp=3Dcr.ifs;;							\
-	st8     [p_stackframe]=3Dtemp,8;;						\
-	mov     temp=3Dar.bspstore;;						\
-	st8     [p_stackframe]=3Dtemp,8;;					\
-	mov     temp=3Dar.rnat;;							\
-	st8     [p_stackframe]=3Dtemp,8;						\
-	mov     ar.bspstore=3Dp_bspstore;;					\
-	mov     temp=3Dar.bsp;;							\
-	sub     temp=3Dtemp,p_bspstore;;						\
-	st8     [p_stackframe]=3Dtemp,8;;
-
-/*
- * rse_return_context
- *	1. Allocate a zero-sized frame
- *	2. Store the number of dirty registers RSC.loadrs field
- *	3. Issue a loadrs to insure that any registers from the interrupted
- *	   context which were saved on the new stack frame have been loaded
- *	   back into the stacked registers
- *	4. Restore BSPSTORE
- *	5. Restore RNAT
- *	6. Restore PFS
- *	7. Restore IFS
- *	8. Restore RSC
- *	9. Issue an RFI
- */
-#define rse_return_context(psr_mask_reg,temp,p_stackframe)			\
-	;;									\
-	alloc   temp=3Dar.pfs,0,0,0,0;						\
-	add     p_stackframe=3Drse_ndirty_offset,p_stackframe;;			\
-	ld8     temp=3D[p_stackframe];;						\
-	shl     temp=3Dtemp,16;;							\
-	mov     ar.rsc=3Dtemp;;							\
-	loadrs;;								\
-	add     p_stackframe=3D-rse_ndirty_offset+rse_bspstore_offset,p_stackfram=
e;;\
-	ld8     temp=3D[p_stackframe];;						\
-	mov     ar.bspstore=3Dtemp;;						\
-	add     p_stackframe=3D-rse_bspstore_offset+rse_rnat_offset,p_stackframe;=
;\
-	ld8     temp=3D[p_stackframe];;						\
-	mov     ar.rnat=3Dtemp;;							\
-	add     p_stackframe=3D-rse_rnat_offset+rse_pfs_offset,p_stackframe;;	\
-	ld8     temp=3D[p_stackframe];;						\
-	mov     ar.pfs=3Dtemp;;							\
-	add     p_stackframe=3D-rse_pfs_offset+rse_ifs_offset,p_stackframe;;	\
-	ld8     temp=3D[p_stackframe];;						\
-	mov     cr.ifs=3Dtemp;;							\
-	add     p_stackframe=3D-rse_ifs_offset+rse_rsc_offset,p_stackframe;;	\
-	ld8     temp=3D[p_stackframe];;						\
-	mov     ar.rsc=3Dtemp ;							\
-	mov     temp=3Dpsr;;							\
-	or      temp=3Dtemp,psr_mask_reg;;					\
-	mov     cr.ipsr=3Dtemp;;							\
-	mov     temp=3Dip;;							\
-	add     temp=3D0x30,temp;;						\
-	mov     cr.iip=3Dtemp;;							\
-	srlz.i;;								\
-	rfi;;
+ * The MCA and INIT stacks in struct ia64_mca_cpu look like normal kernel
+ * stacks, except that the SAL/OS state and a switch_stack are stored near=
 the
+ * top of the MCA/INIT stack.  To support concurrent entry to MCA or INIT,=
 as
+ * well as MCA over INIT, each event needs its own SAL/OS state.  All entr=
ies
+ * are 16 byte aligned.
+ *
+ *      +---------------------------+
+ *      |          pt_regs          |
+ *      +---------------------------+
+ *      |        switch_stack       |
+ *      +---------------------------+
+ *      |        SAL/OS state       |
+ *      +---------------------------+
+ *      |    16 byte scratch area   |
+ *      +---------------------------+ <-------- SP at start of C MCA handl=
er
+ *      |           .....           |
+ *      +---------------------------+
+ *      | RBS for MCA/INIT handler  |
+ *      +---------------------------+
+ *      | struct task for MCA/INIT  |
+ *      +---------------------------+ <-------- Bottom of MCA/INIT stack
+ */
+
+#define ALIGN16(x)			((x)&~15)
+#define MCA_PT_REGS_OFFSET		ALIGN16(KERNEL_STACK_SIZE-IA64_PT_REGS_SIZE)
+#define MCA_SWITCH_STACK_OFFSET		ALIGN16(MCA_PT_REGS_OFFSET-IA64_SWITCH_ST=
ACK_SIZE)
+#define MCA_SOS_OFFSET			ALIGN16(MCA_SWITCH_STACK_OFFSET-IA64_SAL_OS_STATE=
_SIZE)
+#define MCA_SP_OFFSET			ALIGN16(MCA_SOS_OFFSET-16)
=20
 #endif /* _ASM_IA64_MCA_ASM_H */
Index: linux/include/asm-ia64/mca.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig/include/asm-ia64/mca.h	2005-08-30 13=
:56:12.511128289 +1000
+++ linux/include/asm-ia64/mca.h	2005-08-30 14:14:18.043763610 +1000
@@ -11,8 +11,6 @@
 #ifndef _ASM_IA64_MCA_H
 #define _ASM_IA64_MCA_H
=20
-#define IA64_MCA_STACK_SIZE	8192
-
 #if !defined(__ASSEMBLY__)
=20
 #include <linux/interrupt.h>
@@ -48,7 +46,8 @@ typedef union cmcv_reg_u {
=20
 enum {
 	IA64_MCA_RENDEZ_CHECKIN_NOTDONE	=3D	0x0,
-	IA64_MCA_RENDEZ_CHECKIN_DONE	=3D	0x1
+	IA64_MCA_RENDEZ_CHECKIN_DONE	=3D	0x1,
+	IA64_MCA_RENDEZ_CHECKIN_INIT	=3D	0x2,
 };
=20
 /* Information maintained by the MC infrastructure */
@@ -63,18 +62,42 @@ typedef struct ia64_mc_info_s {
=20
 } ia64_mc_info_t;
=20
-typedef struct ia64_mca_sal_to_os_state_s {
-	u64		imsto_os_gp;		/* GP of the os registered with the SAL */
-	u64		imsto_pal_proc;		/* PAL_PROC entry point - physical addr */
-	u64		imsto_sal_proc;		/* SAL_PROC entry point - physical addr */
-	u64		imsto_sal_gp;		/* GP of the SAL - physical */
-	u64		imsto_rendez_state;	/* Rendez state information */
-	u64		imsto_sal_check_ra;	/* Return address in SAL_CHECK while going
-						 * back to SAL from OS after MCA handling.
-						 */
-	u64		pal_min_state;		/* from PAL in r17 */
-	u64		proc_state_param;	/* from PAL in r18. See SDV 2:268 11.3.2.1 */
-} ia64_mca_sal_to_os_state_t;
+/* Handover state from SAL to OS and vice versa, for both MCA and INIT eve=
nts.
+ * Besides the handover state, it also contains some saved registers from =
the
+ * time of the event.
+ * Note: mca_asm.S depends on the precise layout of this structure.
+ */
+
+struct ia64_sal_os_state {
+	/* SAL to OS, must be at offset 0 */
+	u64			os_gp;			/* GP of the os registered with the SAL, physical */
+	u64			pal_proc;		/* PAL_PROC entry point, physical */
+	u64			sal_proc;		/* SAL_PROC entry point, physical */
+	u64			rv_rc;			/* MCA - Rendezvous state, INIT - reason code */
+	u64			proc_state_param;	/* from R18 */
+	u64			monarch;		/* 1 for a monarch event, 0 for a slave */
+	/* common, must follow SAL to OS */
+	u64			sal_ra;			/* Return address in SAL, physical */
+	u64			sal_gp;			/* GP of the SAL - physical */
+	pal_min_state_area_t	*pal_min_state;		/* from R17.  physical in asm, virt=
ual in C */
+	u64			prev_IA64_KR_CURRENT;	/* previous value of IA64_KR(CURRENT) */
+	struct task_struct	*prev_task;		/* previous task, NULL if it is not usefu=
l */
+	/* Some interrupt registers are not saved in minstate, pt_regs or
+	 * switch_stack.  Because MCA/INIT can occur when interrupts are
+	 * disabled, we need to save the additional interrupt registers over
+	 * MCA/INIT and resume.
+	 */
+	u64			isr;
+	u64			ifa;
+	u64			itir;
+	u64			iipa;
+	u64			iim;
+	u64			iha;
+	/* OS to SAL, must follow common */
+	u64			os_status;		/* OS status to SAL, enum below */
+	u64			context;		/* 0 if return to same context
+							   1 if return to new context */
+};
=20
 enum {
 	IA64_MCA_CORRECTED	=3D	0x0,	/* Error has been corrected by OS_MCA */
@@ -84,35 +107,21 @@ enum {
 };
=20
 enum {
+	IA64_INIT_RESUME	=3D	0x0,	/* Resume after return from INIT */
+	IA64_INIT_WARM_BOOT	=3D	-1,	/* Warm boot of the system need from SAL */
+};
+
+enum {
 	IA64_MCA_SAME_CONTEXT	=3D	0x0,	/* SAL to return to same context */
 	IA64_MCA_NEW_CONTEXT	=3D	-1	/* SAL to return to new context */
 };
=20
-typedef struct ia64_mca_os_to_sal_state_s {
-	u64		imots_os_status;	/*   OS status to SAL as to what happened
-						 *   with the MCA handling.
-						 */
-	u64		imots_sal_gp;		/* GP of the SAL - physical */
-	u64		imots_context;		/* 0 if return to same context
-						   1 if return to new context */
-	u64		*imots_new_min_state;	/* Pointer to structure containing
-						 * new values of registers in the min state
-						 * save area.
-						 */
-	u64		imots_sal_check_ra;	/* Return address in SAL_CHECK while going
-						 * back to SAL from OS after MCA handling.
-						 */
-} ia64_mca_os_to_sal_state_t;
-
 /* Per-CPU MCA state that is too big for normal per-CPU variables.  */
=20
 struct ia64_mca_cpu {
-	u64 stack[IA64_MCA_STACK_SIZE/8];	/* MCA memory-stack */
-	u64 proc_state_dump[512];
-	u64 stackframe[32];
-	u64 rbstore[IA64_MCA_STACK_SIZE/8];	/* MCA reg.-backing store */
+	u64 mca_stack[KERNEL_STACK_SIZE/8];
 	u64 init_stack[KERNEL_STACK_SIZE/8];
-} __attribute__ ((aligned(16)));
+};
=20
 /* Array of physical addresses of each CPU's MCA area.  */
 extern unsigned long __per_cpu_mca[NR_CPUS];
@@ -121,12 +130,29 @@ extern void ia64_mca_init(void);
 extern void ia64_mca_cpu_init(void *);
 extern void ia64_os_mca_dispatch(void);
 extern void ia64_os_mca_dispatch_end(void);
-extern void ia64_mca_ucmc_handler(void);
+extern void ia64_mca_ucmc_handler(struct pt_regs *, struct ia64_sal_os_sta=
te *);
+extern void ia64_init_handler(struct pt_regs *,
+			      struct switch_stack *,
+			      struct ia64_sal_os_state *);
 extern void ia64_monarch_init_handler(void);
 extern void ia64_slave_init_handler(void);
 extern void ia64_mca_cmc_vector_setup(void);
-extern int  ia64_reg_MCA_extension(void*);
+extern int  ia64_reg_MCA_extension(int (*fn)(void *, struct ia64_sal_os_st=
ate *));
 extern void ia64_unreg_MCA_extension(void);
+extern u64 ia64_get_rnat(u64 *);
+
+#else	/* __ASSEMBLY__ */
+
+#define IA64_MCA_CORRECTED	0x0	/* Error has been corrected by OS_MCA */
+#define IA64_MCA_WARM_BOOT	-1	/* Warm boot of the system need from SAL */
+#define IA64_MCA_COLD_BOOT	-2	/* Cold boot of the system need from SAL */
+#define IA64_MCA_HALT		-3	/* System to be halted by SAL */
+
+#define IA64_INIT_RESUME	0x0	/* Resume after return from INIT */
+#define IA64_INIT_WARM_BOOT	-1	/* Warm boot of the system need from SAL */
+
+#define IA64_MCA_SAME_CONTEXT	0x0	/* SAL to return to same context */
+#define IA64_MCA_NEW_CONTEXT	-1	/* SAL to return to new context */
=20
 #endif /* !__ASSEMBLY__ */
 #endif /* _ASM_IA64_MCA_H */
Index: linux/arch/ia64/kernel/mca_asm.S
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig/arch/ia64/kernel/mca_asm.S	2005-08-3=
0 13:56:12.511128289 +1000
+++ linux/arch/ia64/kernel/mca_asm.S	2005-08-30 14:14:18.044740040 +1000
@@ -16,6 +16,9 @@
 // 04/11/12 Russ Anderson <rja@sgi.com>
 //		   Added per cpu MCA/INIT stack save areas.
 //
+// 12/08/05 Keith Owens <kaos@sgi.com>
+//		   Use per cpu MCA/INIT stacks for all data.
+//
 #include <linux/config.h>
 #include <linux/threads.h>
=20
@@ -25,96 +28,23 @@
 #include <asm/mca_asm.h>
 #include <asm/mca.h>
=20
-/*
- * When we get a machine check, the kernel stack pointer is no longer
- * valid, so we need to set a new stack pointer.
- */
-#define	MINSTATE_PHYS	/* Make sure stack access is physical for MINSTATE */
-
-/*
- * Needed for return context to SAL
- */
-#define IA64_MCA_SAME_CONTEXT	0
-#define IA64_MCA_COLD_BOOT	-2
-
-#include "minstate.h"
-
-/*
- * SAL_TO_OS_MCA_HANDOFF_STATE (SAL 3.0 spec)
- *		1. GR1 =3D OS GP
- *		2. GR8 =3D PAL_PROC physical address
- *		3. GR9 =3D SAL_PROC physical address
- *		4. GR10 =3D SAL GP (physical)
- *		5. GR11 =3D Rendez state
- *		6. GR12 =3D Return address to location within SAL_CHECK
- */
-#define SAL_TO_OS_MCA_HANDOFF_STATE_SAVE(_tmp)		\
-	LOAD_PHYSICAL(p0, _tmp, ia64_sal_to_os_handoff_state);; \
-	st8	[_tmp]=3Dr1,0x08;;			\
-	st8	[_tmp]=3Dr8,0x08;;			\
-	st8	[_tmp]=3Dr9,0x08;;			\
-	st8	[_tmp]=3Dr10,0x08;;			\
-	st8	[_tmp]=3Dr11,0x08;;			\
-	st8	[_tmp]=3Dr12,0x08;;			\
-	st8	[_tmp]=3Dr17,0x08;;			\
-	st8	[_tmp]=3Dr18,0x08
-
-/*
- * OS_MCA_TO_SAL_HANDOFF_STATE (SAL 3.0 spec)
- * (p6) is executed if we never entered virtual mode (TLB error)
- * (p7) is executed if we entered virtual mode as expected (normal case)
- *	1. GR8 =3D OS_MCA return status
- *	2. GR9 =3D SAL GP (physical)
- *	3. GR10 =3D 0/1 returning same/new context
- *	4. GR22 =3D New min state save area pointer
- *	returns ptr to SAL rtn save loc in _tmp
- */
-#define OS_MCA_TO_SAL_HANDOFF_STATE_RESTORE(_tmp)	\
-	movl	_tmp=3Dia64_os_to_sal_handoff_state;;	\
-	DATA_VA_TO_PA(_tmp);;				\
-	ld8	r8=3D[_tmp],0x08;;			\
-	ld8	r9=3D[_tmp],0x08;;			\
-	ld8	r10=3D[_tmp],0x08;;			\
-	ld8	r22=3D[_tmp],0x08;;
-	// now _tmp is pointing to SAL rtn save location
-
-/*
- * COLD_BOOT_HANDOFF_STATE() sets ia64_mca_os_to_sal_state
- *	imots_os_status=3DIA64_MCA_COLD_BOOT
- *	imots_sal_gp=3DSAL GP
- *	imots_context=3DIA64_MCA_SAME_CONTEXT
- *	imots_new_min_state=3DMin state save area pointer
- *	imots_sal_check_ra=3DReturn address to location within SAL_CHECK
- *
- */
-#define COLD_BOOT_HANDOFF_STATE(sal_to_os_handoff,os_to_sal_handoff,tmp)\
-	movl	tmp=3DIA64_MCA_COLD_BOOT;					\
-	movl	sal_to_os_handoff=3D__pa(ia64_sal_to_os_handoff_state);	\
-	movl	os_to_sal_handoff=3D__pa(ia64_os_to_sal_handoff_state);;	\
-	st8	[os_to_sal_handoff]=3Dtmp,8;;				\
-	ld8	tmp=3D[sal_to_os_handoff],48;;				\
-	st8	[os_to_sal_handoff]=3Dtmp,8;;				\
-	movl	tmp=3DIA64_MCA_SAME_CONTEXT;;				\
-	st8	[os_to_sal_handoff]=3Dtmp,8;;				\
-	ld8	tmp=3D[sal_to_os_handoff],-8;;				\
-	st8     [os_to_sal_handoff]=3Dtmp,8;;				\
-	ld8	tmp=3D[sal_to_os_handoff];;				\
-	st8     [os_to_sal_handoff]=3Dtmp;;
+#include "entry.h"
=20
 #define GET_IA64_MCA_DATA(reg)						\
 	GET_THIS_PADDR(reg, ia64_mca_data)				\
 	;;								\
 	ld8 reg=3D[reg]
=20
-	.global ia64_os_mca_dispatch
-	.global ia64_os_mca_dispatch_end
-	.global ia64_sal_to_os_handoff_state
-	.global	ia64_os_to_sal_handoff_state
 	.global ia64_do_tlb_purge
+	.global ia64_os_mca_dispatch
+	.global ia64_os_init_dispatch_monarch
+	.global ia64_os_init_dispatch_slave
=20
 	.text
 	.align 16
=20
+//StartMain///////////////////////////////////////////////////////////////=
/////
+
 /*
  * Just the TLB purge part is moved to a separate function
  * so we can re-use the code for cpu hotplug code as well
@@ -207,34 +137,31 @@ ia64_do_tlb_purge:
 	br.sptk.many b1
 	;;
=20
-ia64_os_mca_dispatch:
+//EndMain/////////////////////////////////////////////////////////////////=
/////
+
+//StartMain///////////////////////////////////////////////////////////////=
/////
=20
+ia64_os_mca_dispatch:
 	// Serialize all MCA processing
 	mov	r3=3D1;;
 	LOAD_PHYSICAL(p0,r2,ia64_mca_serialize);;
 ia64_os_mca_spin:
-	xchg8	r4=3D[r2],r3;;
+	xchg4	r4=3D[r2],r3;;
 	cmp.ne	p6,p0=3Dr4,r0
 (p6)	br ia64_os_mca_spin
=20
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
+	mov r3=3DIA64_MCA_CPU_MCA_STACK_OFFSET	// use the MCA stack
+	LOAD_PHYSICAL(p0,r2,1f)			// return address
+	mov r19=3D1				// All MCA events are treated as monarch (for now)
+	br.sptk ia64_state_save			// save the state that is not in minstate
+1:
=20
-	LOAD_PHYSICAL(p0,r16,ia64_sal_to_os_handoff_state+56)
+	GET_IA64_MCA_DATA(r2)
+	// Using MCA stack, struct ia64_sal_os_state, variable proc_state_param
+	;;
+	add r3=3DIA64_MCA_CPU_MCA_STACK_OFFSET+MCA_SOS_OFFSET+IA64_SAL_OS_STATE_P=
ROC_STATE_PARAM_OFFSET, r2
 	;;
-	ld8 r18=3D[r16]		// Get processor state parameter on existing PALE_CHECK.
+	ld8 r18=3D[r3]				// Get processor state parameter on existing PALE_CHECK.
 	;;
 	tbit.nz p6,p7=3Dr18,60
 (p7)	br.spnt done_tlb_purge_and_reload
@@ -323,624 +250,710 @@ ia64_reload_tr:
 	itr.d dtr[r20]=3Dr16
 	;;
 	srlz.d
-	;;
-	br.sptk.many done_tlb_purge_and_reload
-err:
-	COLD_BOOT_HANDOFF_STATE(r20,r21,r22)
-	br.sptk.many ia64_os_mca_done_restore
=20
 done_tlb_purge_and_reload:
=20
-	// Setup new stack frame for OS_MCA handling
-	GET_IA64_MCA_DATA(r2)
-	;;
-	add r3 =3D IA64_MCA_CPU_STACKFRAME_OFFSET, r2
-	add r2 =3D IA64_MCA_CPU_RBSTORE_OFFSET, r2
-	;;
-	rse_switch_context(r6,r3,r2);;	// RSC management in this new context
+	// switch to per cpu MCA stack
+	mov r3=3DIA64_MCA_CPU_MCA_STACK_OFFSET	// use the MCA stack
+	LOAD_PHYSICAL(p0,r2,1f)			// return address
+	br.sptk ia64_new_stack
+1:
+
+	// everything saved, now we can set the kernel registers
+	mov r3=3DIA64_MCA_CPU_MCA_STACK_OFFSET	// use the MCA stack
+	LOAD_PHYSICAL(p0,r2,1f)			// return address
+	br.sptk ia64_set_kernel_registers
+1:
=20
+	// This must be done in physical mode
 	GET_IA64_MCA_DATA(r2)
 	;;
-	add r2 =3D IA64_MCA_CPU_STACK_OFFSET+IA64_MCA_STACK_SIZE-16, r2
-	;;
-	mov r12=3Dr2		// establish new stack-pointer
+	mov r7=3Dr2
=20
         // Enter virtual mode from physical mode
 	VIRTUAL_MODE_ENTER(r2, r3, ia64_os_mca_virtual_begin, r4)
-ia64_os_mca_virtual_begin:
+
+	// This code returns to SAL via SOS r2, in general SAL has no unwind
+	// data.  To get a clean termination when backtracing the C MCA/INIT
+	// handler, create a dummy return address of 0 in this routine.  That
+	// requires that ia64_os_mca_virtual_begin be a global function.
+ENTRY(ia64_os_mca_virtual_begin)
+	.prologue ASM_UNW_PRLG_RP, ASM_UNW_PRLG_GRSAVE(0)
+
+	mov ar.rsc=3D3				// set eager mode for C handler
+	mov r2=3Dr7				// see GET_IA64_MCA_DATA above
+	;;
=20
 	// Call virtual mode handler
-	movl		r2=3Dia64_mca_ucmc_handler;;
-	mov		b6=3Dr2;;
-	br.call.sptk.many    b0=B6;;
-.ret0:
+	alloc r14=3Dar.pfs,0,1,3,0
+	mov loc0=3Dr0				// dummy rp of 0 to terminate backtrace
+	.body
+	;;
+	DATA_PA_TO_VA(r2,r7)
+	;;
+	add out0=3DIA64_MCA_CPU_MCA_STACK_OFFSET+MCA_PT_REGS_OFFSET, r2
+	add out1=3DIA64_MCA_CPU_MCA_STACK_OFFSET+MCA_SWITCH_STACK_OFFSET, r2
+	add out2=3DIA64_MCA_CPU_MCA_STACK_OFFSET+MCA_SOS_OFFSET, r2
+	br.call.sptk.many    b0=3Dia64_mca_handler
+
 	// Revert back to physical mode before going back to SAL
 	PHYSICAL_MODE_ENTER(r2, r3, ia64_os_mca_virtual_end, r4)
 ia64_os_mca_virtual_end:
=20
-	// restore the original stack frame here
-	GET_IA64_MCA_DATA(r2)
+END(ia64_os_mca_virtual_begin)
+
+	// switch back to previous stack
+	alloc r14=3Dar.pfs,0,0,0,0		// remove the MCA handler frame
+	mov r3=3DIA64_MCA_CPU_MCA_STACK_OFFSET	// use the MCA stack
+	LOAD_PHYSICAL(p0,r2,1f)			// return address
+	br.sptk ia64_old_stack
+1:
+
+	mov r3=3DIA64_MCA_CPU_MCA_STACK_OFFSET	// use the MCA stack
+	LOAD_PHYSICAL(p0,r2,1f)			// return address
+	br.sptk ia64_state_restore		// restore the SAL state
+1:
+
+	mov		b0=3Dr12			// SAL_CHECK return address
+
+	// release lock
+	LOAD_PHYSICAL(p0,r3,ia64_mca_serialize);;
+	st4.rel		[r3]=3Dr0
 	;;
-	add r2 =3D IA64_MCA_CPU_STACKFRAME_OFFSET, r2
+	mov r31=3D-1
+	LOAD_PHYSICAL(p0,r3,ia64_mca_init_leave);;
 	;;
-	movl    r4=3DIA64_PSR_MC
+	st4.rel		[r3]=3Dr31
+
+	br		b0
+
+//EndMain/////////////////////////////////////////////////////////////////=
/////
+
+//StartMain///////////////////////////////////////////////////////////////=
/////
+
+//
+// SAL to OS entry point for INIT on all processors.  This has been define=
d for
+// registration purposes with SAL as a part of ia64_mca_init.  Monarch and
+// slave INIT have identical processing, except for the value of the
+// sos->monarch flag in r19.
+//
+
+ia64_os_init_dispatch_monarch:
+	mov r19=3D1				// Bow, bow, ye lower middle classes!
+	br.sptk ia64_os_init_dispatch
+
+ia64_os_init_dispatch_slave:
+	mov r19=3D0				// <igor>yeth, mathter</igor>
+
+ia64_os_init_dispatch:
+
+	mov r3=3DIA64_MCA_CPU_INIT_STACK_OFFSET	// use the INIT stack
+	LOAD_PHYSICAL(p0,r2,1f)			// return address
+	br.sptk ia64_state_save			// save the state that is not in minstate
+1:
+
+	// switch to per cpu INIT stack
+	mov r3=3DIA64_MCA_CPU_INIT_STACK_OFFSET	// use the INIT stack
+	LOAD_PHYSICAL(p0,r2,1f)			// return address
+	br.sptk ia64_new_stack
+1:
+
+	// everything saved, now we can set the kernel registers
+	mov r3=3DIA64_MCA_CPU_INIT_STACK_OFFSET	// use the INIT stack
+	LOAD_PHYSICAL(p0,r2,1f)			// return address
+	br.sptk ia64_set_kernel_registers
+1:
+
+	// This must be done in physical mode
+	GET_IA64_MCA_DATA(r2)
 	;;
-	rse_return_context(r4,r3,r2)	// switch from interrupt context for RSE
+	mov r7=3Dr2
+
+        // Enter virtual mode from physical mode
+	VIRTUAL_MODE_ENTER(r2, r3, ia64_os_init_virtual_begin, r4)
+
+	// This code returns to SAL via SOS r2, in general SAL has no unwind
+	// data.  To get a clean termination when backtracing the C MCA/INIT
+	// handler, create a dummy return address of 0 in this routine.  That
+	// requires that ia64_os_init_virtual_begin be a global function.
+ENTRY(ia64_os_init_virtual_begin)
+	.prologue ASM_UNW_PRLG_RP, ASM_UNW_PRLG_GRSAVE(0)
=20
-	// let us restore all the registers from our PSI structure
-	mov	r8=3Dgp
+	mov ar.rsc=3D3				// set eager mode for C handler
+	mov r2=3Dr7				// see GET_IA64_MCA_DATA above
 	;;
-begin_os_mca_restore:
-	br	ia64_os_mca_proc_state_restore;;
=20
-ia64_os_mca_done_restore:
-	OS_MCA_TO_SAL_HANDOFF_STATE_RESTORE(r2);;
-	// branch back to SALE_CHECK
-	ld8		r3=3D[r2];;
-	mov		b0=3Dr3;;		// SAL_CHECK return address
+	// Call virtual mode handler
+	alloc r14=3Dar.pfs,0,1,3,0
+	mov loc0=3Dr0				// dummy rp of 0 to terminate backtrace
+	.body
+	;;
+	DATA_PA_TO_VA(r2,r7)
+	;;
+	add out0=3DIA64_MCA_CPU_INIT_STACK_OFFSET+MCA_PT_REGS_OFFSET, r2
+	add out1=3DIA64_MCA_CPU_INIT_STACK_OFFSET+MCA_SWITCH_STACK_OFFSET, r2
+	add out2=3DIA64_MCA_CPU_INIT_STACK_OFFSET+MCA_SOS_OFFSET, r2
+	br.call.sptk.many    b0=3Dia64_init_handler
=20
-	// release lock
-	movl		r3=3Dia64_mca_serialize;;
-	DATA_VA_TO_PA(r3);;
-	st8.rel		[r3]=3Dr0
+	// Revert back to physical mode before going back to SAL
+	PHYSICAL_MODE_ENTER(r2, r3, ia64_os_init_virtual_end, r4)
+ia64_os_init_virtual_end:
=20
-	br		b0
+END(ia64_os_init_virtual_begin)
+
+	mov r3=3DIA64_MCA_CPU_INIT_STACK_OFFSET	// use the INIT stack
+	LOAD_PHYSICAL(p0,r2,1f)			// return address
+	br.sptk ia64_state_restore		// restore the SAL state
+1:
+
+	// switch back to previous stack
+	alloc r14=3Dar.pfs,0,0,0,0		// remove the INIT handler frame
+	mov r3=3DIA64_MCA_CPU_INIT_STACK_OFFSET	// use the INIT stack
+	LOAD_PHYSICAL(p0,r2,1f)			// return address
+	br.sptk ia64_old_stack
+1:
+
+	mov		b0=3Dr12			// SAL_CHECK return address
+	;;
+	mov r31=3D-1
+	LOAD_PHYSICAL(p0,r3,ia64_mca_init_leave);;
 	;;
-ia64_os_mca_dispatch_end:
+	st4.rel		[r3]=3Dr31
+	br		b0
+
 //EndMain/////////////////////////////////////////////////////////////////=
/////
=20
+// common defines for the stubs
+#define	ms		r4
+#define	regs		r5
+#define	temp1		r2	/* careful, it overlaps with input registers */
+#define	temp2		r3	/* careful, it overlaps with input registers */
+#define	temp3		r7
+#define	temp4		r14
+
=20
 //++
 // Name:
-//      ia64_os_mca_proc_state_dump()
+//	ia64_state_save()
 //
 // Stub Description:
 //
-//       This stub dumps the processor state during MCHK to a data area
+//	Save the state that is not in minstate.  This is sensitive to the layou=
t of
+//	struct ia64_sal_os_state in mca.h.
+//
+//	r2 contains the return address, r3 contains either
+//	IA64_MCA_CPU_MCA_STACK_OFFSET or IA64_MCA_CPU_INIT_STACK_OFFSET.
+//
+//	The OS to SAL section of struct ia64_sal_os_state is set to a default
+//	value of cold boot (MCA) or warm boot (INIT) and return to the same
+//	context.  ia64_sal_os_state is also used to hold some registers that
+//	need to be saved and restored across the stack switches.
+//
+//	Most input registers to this stub come from PAL/SAL
+//	r1  os gp, physical
+//	r8  pal_proc entry point
+//	r9  sal_proc entry point
+//	r10 sal gp
+//	r11 MCA - rendevzous state, INIT - reason code
+//	r12 sal return address
+//	r17 pal min_state
+//	r18 processor state parameter
+//	r19 monarch flag, set by the caller of this routine
+//
+//	In addition to the SAL to OS state, this routine saves all the
+//	registers that appear in struct pt_regs and struct switch_stack,
+//	excluding those that are already in the PAL minstate area.  This
+//	results in a partial pt_regs and switch_stack, the C code copies the
+//	remaining registers from PAL minstate to pt_regs and switch_stack.  The
+//	resulting structures contain all the state of the original process when
+//	MCA/INIT occurred.
 //
 //--
=20
-ia64_os_mca_proc_state_dump:
-// Save bank 1 GRs 16-31 which will be used by c-language code when we swi=
tch
-//  to virtual addressing mode.
-	GET_IA64_MCA_DATA(r2)
+ia64_state_save:
+	add regs=3DMCA_SOS_OFFSET, r3
+	add ms=3DMCA_SOS_OFFSET+8, r3
+	mov b0=3Dr2		// save return address
+	cmp.eq p1,p2=3DIA64_MCA_CPU_MCA_STACK_OFFSET, r3
+	;;
+	GET_IA64_MCA_DATA(temp2)
+	;;
+	add temp1=3Dtemp2, regs	// struct ia64_sal_os_state on MCA or INIT stack
+	add temp2=3Dtemp2, ms	// struct ia64_sal_os_state+8 on MCA or INIT stack
+	;;
+	mov regs=3Dtemp1		// save the start of sos
+	st8 [temp1]=3Dr1,16	// os_gp
+	st8 [temp2]=3Dr8,16	// pal_proc
+	;;
+	st8 [temp1]=3Dr9,16	// sal_proc
+	st8 [temp2]=3Dr11,16	// rv_rc
+	mov r11=3Dcr.iipa
+	;;
+	st8 [temp1]=3Dr18,16	// proc_state_param
+	st8 [temp2]=3Dr19,16	// monarch
+	mov r6=3DIA64_KR(CURRENT)
+	;;
+	st8 [temp1]=3Dr12,16	// sal_ra
+	st8 [temp2]=3Dr10,16	// sal_gp
+	mov r12=3Dcr.isr
+	;;
+	st8 [temp1]=3Dr17,16	// pal_min_state
+	st8 [temp2]=3Dr6,16	// prev_IA64_KR_CURRENT
+	mov r6=3Dcr.ifa
+	;;
+	st8 [temp1]=3Dr0,16	// prev_task, starts off as NULL
+	st8 [temp2]=3Dr12,16	// cr.isr
+	mov r12=3Dcr.itir
+	;;
+	st8 [temp1]=3Dr6,16	// cr.ifa
+	st8 [temp2]=3Dr12,16	// cr.itir
+	mov r12=3Dcr.iim
+	;;
+	st8 [temp1]=3Dr11,16	// cr.iipa
+	st8 [temp2]=3Dr12,16	// cr.iim
+	mov r6=3Dcr.iha
+(p1)	mov r12=3DIA64_MCA_COLD_BOOT
+(p2)	mov r12=3DIA64_INIT_WARM_BOOT
+	;;
+	st8 [temp1]=3Dr6,16	// cr.iha
+	st8 [temp2]=3Dr12		// os_status, default is cold boot
+	mov r6=3DIA64_MCA_SAME_CONTEXT
+	;;
+	st8 [temp1]=3Dr6		// context, default is same context
+
+	// Save the pt_regs data that is not in minstate.  The previous code
+	// left regs at sos.
+	add regs=3DMCA_PT_REGS_OFFSET-MCA_SOS_OFFSET, regs
+	;;
+	add temp1=3DPT(B6), regs
+	mov temp3=B6
+	mov temp4=B7
+	add temp2=3DPT(B7), regs
+	;;
+	st8 [temp1]=3Dtemp3,PT(AR_CSD)-PT(B6)		// save b6
+	st8 [temp2]=3Dtemp4,PT(AR_SSD)-PT(B7)		// save b7
+	mov temp3=3Dar.csd
+	mov temp4=3Dar.ssd
+	cover						// must be last in group
+	;;
+	st8 [temp1]=3Dtemp3,PT(AR_UNAT)-PT(AR_CSD)	// save ar.csd
+	st8 [temp2]=3Dtemp4,PT(AR_PFS)-PT(AR_SSD)		// save ar.ssd
+	mov temp3=3Dar.unat
+	mov temp4=3Dar.pfs
+	;;
+	st8 [temp1]=3Dtemp3,PT(AR_RNAT)-PT(AR_UNAT)	// save ar.unat
+	st8 [temp2]=3Dtemp4,PT(AR_BSPSTORE)-PT(AR_PFS)	// save ar.pfs
+	mov temp3=3Dar.rnat
+	mov temp4=3Dar.bspstore
+	;;
+	st8 [temp1]=3Dtemp3,PT(LOADRS)-PT(AR_RNAT)	// save ar.rnat
+	st8 [temp2]=3Dtemp4,PT(AR_FPSR)-PT(AR_BSPSTORE)	// save ar.bspstore
+	mov temp3=3Dar.bsp
+	;;
+	sub temp3=3Dtemp3, temp4	// ar.bsp - ar.bspstore
+	mov temp4=3Dar.fpsr
+	;;
+	shl temp3=3Dtemp3,16	// compute ar.rsc to be used for "loadrs"
 	;;
-	add r2 =3D IA64_MCA_CPU_PROC_STATE_DUMP_OFFSET, r2
+	st8 [temp1]=3Dtemp3,PT(AR_CCV)-PT(LOADRS)		// save loadrs
+	st8 [temp2]=3Dtemp4,PT(F6)-PT(AR_FPSR)		// save ar.fpsr
+	mov temp3=3Dar.ccv
 	;;
-// save ar.NaT
-	mov		r5=3Dar.unat                  // ar.unat
+	st8 [temp1]=3Dtemp3,PT(F7)-PT(AR_CCV)		// save ar.ccv
+	stf.spill [temp2]=F6,PT(F8)-PT(F6)
+	;;
+	stf.spill [temp1]=F7,PT(F9)-PT(F7)
+	stf.spill [temp2]=F8,PT(F10)-PT(F8)
+	;;
+	stf.spill [temp1]=F9,PT(F11)-PT(F9)
+	stf.spill [temp2]=F10
+	;;
+	stf.spill [temp1]=F11
=20
-// save banked GRs 16-31 along with NaT bits
-	bsw.1;;
-	st8.spill	[r2]=3Dr16,8;;
-	st8.spill	[r2]=3Dr17,8;;
-	st8.spill	[r2]=3Dr18,8;;
-	st8.spill	[r2]=3Dr19,8;;
-	st8.spill	[r2]=3Dr20,8;;
-	st8.spill	[r2]=3Dr21,8;;
-	st8.spill	[r2]=3Dr22,8;;
-	st8.spill	[r2]=3Dr23,8;;
-	st8.spill	[r2]=3Dr24,8;;
-	st8.spill	[r2]=3Dr25,8;;
-	st8.spill	[r2]=3Dr26,8;;
-	st8.spill	[r2]=3Dr27,8;;
-	st8.spill	[r2]=3Dr28,8;;
-	st8.spill	[r2]=3Dr29,8;;
-	st8.spill	[r2]=3Dr30,8;;
-	st8.spill	[r2]=3Dr31,8;;
-
-	mov		r4=3Dar.unat;;
-	st8		[r2]=3Dr4,8                // save User NaT bits for r16-r31
-	mov		ar.unat=3Dr5                  // restore original unat
-	bsw.0;;
-
-//save BRs
-	add		r4=3D8,r2                  // duplicate r2 in r4
-	add		r6=3D2*8,r2                // duplicate r2 in r4
-
-	mov		r3=B0
-	mov		r5=B1
-	mov		r7=B2;;
-	st8		[r2]=3Dr3,3*8
-	st8		[r4]=3Dr5,3*8
-	st8		[r6]=3Dr7,3*8;;
-
-	mov		r3=B3
-	mov		r5=B4
-	mov		r7=B5;;
-	st8		[r2]=3Dr3,3*8
-	st8		[r4]=3Dr5,3*8
-	st8		[r6]=3Dr7,3*8;;
-
-	mov		r3=B6
-	mov		r5=B7;;
-	st8		[r2]=3Dr3,2*8
-	st8		[r4]=3Dr5,2*8;;
-
-cSaveCRs:
-// save CRs
-	add		r4=3D8,r2                  // duplicate r2 in r4
-	add		r6=3D2*8,r2                // duplicate r2 in r4
-
-	mov		r3=3Dcr.dcr
-	mov		r5=3Dcr.itm
-	mov		r7=3Dcr.iva;;
-
-	st8		[r2]=3Dr3,8*8
-	st8		[r4]=3Dr5,3*8
-	st8		[r6]=3Dr7,3*8;;            // 48 byte rements
-
-	mov		r3=3Dcr.pta;;
-	st8		[r2]=3Dr3,8*8;;            // 64 byte rements
-
-// if PSR.ic=3D0, reading interruption registers causes an illegal operati=
on fault
-	mov		r3=3Dpsr;;
-	tbit.nz.unc	p6,p0=3Dr3,PSR_IC;;           // PSI Valid Log bit pos. test
-(p6)    st8     [r2]=3Dr0,9*8+160             // increment by 232 byte inc.
-begin_skip_intr_regs:
-(p6)	br		SkipIntrRegs;;
-
-	add		r4=3D8,r2                  // duplicate r2 in r4
-	add		r6=3D2*8,r2                // duplicate r2 in r6
-
-	mov		r3=3Dcr.ipsr
-	mov		r5=3Dcr.isr
-	mov		r7=3Dr0;;
-	st8		[r2]=3Dr3,3*8
-	st8		[r4]=3Dr5,3*8
-	st8		[r6]=3Dr7,3*8;;
-
-	mov		r3=3Dcr.iip
-	mov		r5=3Dcr.ifa
-	mov		r7=3Dcr.itir;;
-	st8		[r2]=3Dr3,3*8
-	st8		[r4]=3Dr5,3*8
-	st8		[r6]=3Dr7,3*8;;
-
-	mov		r3=3Dcr.iipa
-	mov		r5=3Dcr.ifs
-	mov		r7=3Dcr.iim;;
-	st8		[r2]=3Dr3,3*8
-	st8		[r4]=3Dr5,3*8
-	st8		[r6]=3Dr7,3*8;;
-
-	mov		r3=3Dcr25;;                   // cr.iha
-	st8		[r2]=3Dr3,160;;               // 160 byte rement
-
-SkipIntrRegs:
-	st8		[r2]=3Dr0,152;;               // another 152 byte .
-
-	add		r4=3D8,r2                     // duplicate r2 in r4
-	add		r6=3D2*8,r2                   // duplicate r2 in r6
-
-	mov		r3=3Dcr.lid
-//	mov		r5=3Dcr.ivr                     // cr.ivr, don't read it
-	mov		r7=3Dcr.tpr;;
-	st8		[r2]=3Dr3,3*8
-	st8		[r4]=3Dr5,3*8
-	st8		[r6]=3Dr7,3*8;;
-
-	mov		r3=3Dr0                       // cr.eoi =3D> cr67
-	mov		r5=3Dr0                       // cr.irr0 =3D> cr68
-	mov		r7=3Dr0;;                     // cr.irr1 =3D> cr69
-	st8		[r2]=3Dr3,3*8
-	st8		[r4]=3Dr5,3*8
-	st8		[r6]=3Dr7,3*8;;
-
-	mov		r3=3Dr0                       // cr.irr2 =3D> cr70
-	mov		r5=3Dr0                       // cr.irr3 =3D> cr71
-	mov		r7=3Dcr.itv;;
-	st8		[r2]=3Dr3,3*8
-	st8		[r4]=3Dr5,3*8
-	st8		[r6]=3Dr7,3*8;;
-
-	mov		r3=3Dcr.pmv
-	mov		r5=3Dcr.cmcv;;
-	st8		[r2]=3Dr3,7*8
-	st8		[r4]=3Dr5,7*8;;
-
-	mov		r3=3Dr0                       // cr.lrr0 =3D> cr80
-	mov		r5=3Dr0;;                     // cr.lrr1 =3D> cr81
-	st8		[r2]=3Dr3,23*8
-	st8		[r4]=3Dr5,23*8;;
-
-	adds		r2%*8,r2;;
-
-cSaveARs:
-// save ARs
-	add		r4=3D8,r2                  // duplicate r2 in r4
-	add		r6=3D2*8,r2                // duplicate r2 in r6
-
-	mov		r3=3Dar.k0
-	mov		r5=3Dar.k1
-	mov		r7=3Dar.k2;;
-	st8		[r2]=3Dr3,3*8
-	st8		[r4]=3Dr5,3*8
-	st8		[r6]=3Dr7,3*8;;
-
-	mov		r3=3Dar.k3
-	mov		r5=3Dar.k4
-	mov		r7=3Dar.k5;;
-	st8		[r2]=3Dr3,3*8
-	st8		[r4]=3Dr5,3*8
-	st8		[r6]=3Dr7,3*8;;
-
-	mov		r3=3Dar.k6
-	mov		r5=3Dar.k7
-	mov		r7=3Dr0;;                     // ar.kr8
-	st8		[r2]=3Dr3,10*8
-	st8		[r4]=3Dr5,10*8
-	st8		[r6]=3Dr7,10*8;;           // rement by 72 bytes
-
-	mov		r3=3Dar.rsc
-	mov		ar.rsc=3Dr0			    // put RSE in enforced lazy mode
-	mov		r5=3Dar.bsp
-	;;
-	mov		r7=3Dar.bspstore;;
-	st8		[r2]=3Dr3,3*8
-	st8		[r4]=3Dr5,3*8
-	st8		[r6]=3Dr7,3*8;;
-
-	mov		r3=3Dar.rnat;;
-	st8		[r2]=3Dr3,8*13             // increment by 13x8 bytes
-
-	mov		r3=3Dar.ccv;;
-	st8		[r2]=3Dr3,8*4
-
-	mov		r3=3Dar.unat;;
-	st8		[r2]=3Dr3,8*4
-
-	mov		r3=3Dar.fpsr;;
-	st8		[r2]=3Dr3,8*4
-
-	mov		r3=3Dar.itc;;
-	st8		[r2]=3Dr3,160                 // 160
-
-	mov		r3=3Dar.pfs;;
-	st8		[r2]=3Dr3,8
-
-	mov		r3=3Dar.lc;;
-	st8		[r2]=3Dr3,8
-
-	mov		r3=3Dar.ec;;
-	st8		[r2]=3Dr3
-	add		r2=3D8*62,r2               //padding
-
-// save RRs
-	mov		ar.lc=3D0x08-1
-	movl		r4=3D0x00;;
-
-cStRR:
-	dep.z		r5=3Dr4,61,3;;
-	mov		r3=3Drr[r5];;
-	st8		[r2]=3Dr3,8
-	add		r4=3D1,r4
-	br.cloop.sptk.few	cStRR
+	// Save the switch_stack data that is not in minstate nor pt_regs.  The
+	// previous code left regs at pt_regs.
+	add regs=3DMCA_SWITCH_STACK_OFFSET-MCA_PT_REGS_OFFSET, regs
+	;;
+	add temp1=3DSW(F2), regs
+	add temp2=3DSW(F3), regs
+	;;
+	stf.spill [temp1]=F2,32
+	stf.spill [temp2]=F3,32
+	;;
+	stf.spill [temp1]=F4,32
+	stf.spill [temp2]=F5,32
+	;;
+	stf.spill [temp1]=F12,32
+	stf.spill [temp2]=F13,32
+	;;
+	stf.spill [temp1]=F14,32
+	stf.spill [temp2]=F15,32
+	;;
+	stf.spill [temp1]=F16,32
+	stf.spill [temp2]=F17,32
+	;;
+	stf.spill [temp1]=F18,32
+	stf.spill [temp2]=F19,32
+	;;
+	stf.spill [temp1]=F20,32
+	stf.spill [temp2]=F21,32
+	;;
+	stf.spill [temp1]=F22,32
+	stf.spill [temp2]=F23,32
+	;;
+	stf.spill [temp1]=F24,32
+	stf.spill [temp2]=F25,32
 	;;
-end_os_mca_dump:
-	br	ia64_os_mca_done_dump;;
+	stf.spill [temp1]=F26,32
+	stf.spill [temp2]=F27,32
+	;;
+	stf.spill [temp1]=F28,32
+	stf.spill [temp2]=F29,32
+	;;
+	stf.spill [temp1]=F30,SW(B2)-SW(F30)
+	stf.spill [temp2]=F31,SW(B3)-SW(F31)
+	mov temp3=B2
+	mov temp4=B3
+	;;
+	st8 [temp1]=3Dtemp3,16	// save b2
+	st8 [temp2]=3Dtemp4,16	// save b3
+	mov temp3=B4
+	mov temp4=B5
+	;;
+	st8 [temp1]=3Dtemp3,SW(AR_LC)-SW(B4)	// save b4
+	st8 [temp2]=3Dtemp4	// save b5
+	mov temp3=3Dar.lc
+	;;
+	st8 [temp1]=3Dtemp3	// save ar.lc
+
+	br.sptk b0
=20
 //EndStub/////////////////////////////////////////////////////////////////=
/////
=20
=20
 //++
 // Name:
-//       ia64_os_mca_proc_state_restore()
+//	ia64_state_restore()
 //
 // Stub Description:
 //
-//       This is a stub to restore the saved processor state during MCHK
+//	Restore the SAL/OS state.  This is sensitive to the layout of struct
+//	ia64_sal_os_state in mca.h.
+//
+//	r2 contains the return address, r3 contains either
+//	IA64_MCA_CPU_MCA_STACK_OFFSET or IA64_MCA_CPU_INIT_STACK_OFFSET.
+//
+//	In addition to the SAL to OS state, this routine restores all the
+//	registers that appear in struct pt_regs and struct switch_stack,
+//	excluding those in the PAL minstate area.
 //
 //--
=20
-ia64_os_mca_proc_state_restore:
+ia64_state_restore:
+	// Restore the switch_stack data that is not in minstate nor pt_regs.
+	add regs=3DMCA_SWITCH_STACK_OFFSET, r3
+	mov b0=3Dr2		// save return address
+	;;
+	GET_IA64_MCA_DATA(temp2)
+	;;
+	add regs=3Dtemp2, regs
+	;;
+	add temp1=3DSW(F2), regs
+	add temp2=3DSW(F3), regs
+	;;
+	ldf.fill f2=3D[temp1],32
+	ldf.fill f3=3D[temp2],32
+	;;
+	ldf.fill f4=3D[temp1],32
+	ldf.fill f5=3D[temp2],32
+	;;
+	ldf.fill f12=3D[temp1],32
+	ldf.fill f13=3D[temp2],32
+	;;
+	ldf.fill f14=3D[temp1],32
+	ldf.fill f15=3D[temp2],32
+	;;
+	ldf.fill f16=3D[temp1],32
+	ldf.fill f17=3D[temp2],32
+	;;
+	ldf.fill f18=3D[temp1],32
+	ldf.fill f19=3D[temp2],32
+	;;
+	ldf.fill f20=3D[temp1],32
+	ldf.fill f21=3D[temp2],32
+	;;
+	ldf.fill f22=3D[temp1],32
+	ldf.fill f23=3D[temp2],32
+	;;
+	ldf.fill f24=3D[temp1],32
+	ldf.fill f25=3D[temp2],32
+	;;
+	ldf.fill f26=3D[temp1],32
+	ldf.fill f27=3D[temp2],32
+	;;
+	ldf.fill f28=3D[temp1],32
+	ldf.fill f29=3D[temp2],32
+	;;
+	ldf.fill f30=3D[temp1],SW(B2)-SW(F30)
+	ldf.fill f31=3D[temp2],SW(B3)-SW(F31)
+	;;
+	ld8 temp3=3D[temp1],16	// restore b2
+	ld8 temp4=3D[temp2],16	// restore b3
+	;;
+	mov b2=3Dtemp3
+	mov b3=3Dtemp4
+	ld8 temp3=3D[temp1],SW(AR_LC)-SW(B4)	// restore b4
+	ld8 temp4=3D[temp2]	// restore b5
+	;;
+	mov b4=3Dtemp3
+	mov b5=3Dtemp4
+	ld8 temp3=3D[temp1]	// restore ar.lc
+	;;
+	mov ar.lc=3Dtemp3
=20
-// Restore bank1 GR16-31
-	GET_IA64_MCA_DATA(r2)
+	// Restore the pt_regs data that is not in minstate.  The previous code
+	// left regs at switch_stack.
+	add regs=3DMCA_PT_REGS_OFFSET-MCA_SWITCH_STACK_OFFSET, regs
+	;;
+	add temp1=3DPT(B6), regs
+	add temp2=3DPT(B7), regs
+	;;
+	ld8 temp3=3D[temp1],PT(AR_CSD)-PT(B6)		// restore b6
+	ld8 temp4=3D[temp2],PT(AR_SSD)-PT(B7)		// restore b7
+	;;
+	mov b6=3Dtemp3
+	mov b7=3Dtemp4
+	ld8 temp3=3D[temp1],PT(AR_UNAT)-PT(AR_CSD)	// restore ar.csd
+	ld8 temp4=3D[temp2],PT(AR_PFS)-PT(AR_SSD)		// restore ar.ssd
+	;;
+	mov ar.csd=3Dtemp3
+	mov ar.ssd=3Dtemp4
+	ld8 temp3=3D[temp1]				// restore ar.unat
+	add temp1=3DPT(AR_CCV)-PT(AR_UNAT), temp1
+	ld8 temp4=3D[temp2],PT(AR_FPSR)-PT(AR_PFS)	// restore ar.pfs
 	;;
-	add r2 =3D IA64_MCA_CPU_PROC_STATE_DUMP_OFFSET, r2
+	mov ar.unat=3Dtemp3
+	mov ar.pfs=3Dtemp4
+	// ar.rnat, ar.bspstore, loadrs are restore in ia64_old_stack.
+	ld8 temp3=3D[temp1],PT(F6)-PT(AR_CCV)		// restore ar.ccv
+	ld8 temp4=3D[temp2],PT(F7)-PT(AR_FPSR)		// restore ar.fpsr
+	;;
+	mov ar.ccv=3Dtemp3
+	mov ar.fpsr=3Dtemp4
+	ldf.fill f6=3D[temp1],PT(F8)-PT(F6)
+	ldf.fill f7=3D[temp2],PT(F9)-PT(F7)
+	;;
+	ldf.fill f8=3D[temp1],PT(F10)-PT(F8)
+	ldf.fill f9=3D[temp2],PT(F11)-PT(F9)
+	;;
+	ldf.fill f10=3D[temp1]
+	ldf.fill f11=3D[temp2]
=20
-restore_GRs:                                    // restore bank-1 GRs 16-31
-	bsw.1;;
-	add		r3=16*8,r2;;                // to get to NaT of GR 16-31
-	ld8		r3=3D[r3];;
-	mov		ar.unat=3Dr3;;                // first restore NaT
-
-	ld8.fill	r16=3D[r2],8;;
-	ld8.fill	r17=3D[r2],8;;
-	ld8.fill	r18=3D[r2],8;;
-	ld8.fill	r19=3D[r2],8;;
-	ld8.fill	r20=3D[r2],8;;
-	ld8.fill	r21=3D[r2],8;;
-	ld8.fill	r22=3D[r2],8;;
-	ld8.fill	r23=3D[r2],8;;
-	ld8.fill	r24=3D[r2],8;;
-	ld8.fill	r25=3D[r2],8;;
-	ld8.fill	r26=3D[r2],8;;
-	ld8.fill	r27=3D[r2],8;;
-	ld8.fill	r28=3D[r2],8;;
-	ld8.fill	r29=3D[r2],8;;
-	ld8.fill	r30=3D[r2],8;;
-	ld8.fill	r31=3D[r2],8;;
-
-	ld8		r3=3D[r2],8;;              // increment to skip NaT
-	bsw.0;;
-
-restore_BRs:
-	add		r4=3D8,r2                  // duplicate r2 in r4
-	add		r6=3D2*8,r2;;              // duplicate r2 in r4
-
-	ld8		r3=3D[r2],3*8
-	ld8		r5=3D[r4],3*8
-	ld8		r7=3D[r6],3*8;;
-	mov		b0=3Dr3
-	mov		b1=3Dr5
-	mov		b2=3Dr7;;
-
-	ld8		r3=3D[r2],3*8
-	ld8		r5=3D[r4],3*8
-	ld8		r7=3D[r6],3*8;;
-	mov		b3=3Dr3
-	mov		b4=3Dr5
-	mov		b5=3Dr7;;
-
-	ld8		r3=3D[r2],2*8
-	ld8		r5=3D[r4],2*8;;
-	mov		b6=3Dr3
-	mov		b7=3Dr5;;
-
-restore_CRs:
-	add		r4=3D8,r2                  // duplicate r2 in r4
-	add		r6=3D2*8,r2;;              // duplicate r2 in r4
-
-	ld8		r3=3D[r2],8*8
-	ld8		r5=3D[r4],3*8
-	ld8		r7=3D[r6],3*8;;            // 48 byte increments
-	mov		cr.dcr=3Dr3
-	mov		cr.itm=3Dr5
-	mov		cr.iva=3Dr7;;
-
-	ld8		r3=3D[r2],8*8;;            // 64 byte increments
-//      mov		cr.pta=3Dr3
-
-
-// if PSR.ic=3D1, reading interruption registers causes an illegal operati=
on fault
-	mov		r3=3Dpsr;;
-	tbit.nz.unc	p6,p0=3Dr3,PSR_IC;;           // PSI Valid Log bit pos. test
-(p6)    st8     [r2]=3Dr0,9*8+160             // increment by 232 byte inc.
-
-begin_rskip_intr_regs:
-(p6)	br		rSkipIntrRegs;;
-
-	add		r4=3D8,r2                  // duplicate r2 in r4
-	add		r6=3D2*8,r2;;              // duplicate r2 in r4
-
-	ld8		r3=3D[r2],3*8
-	ld8		r5=3D[r4],3*8
-	ld8		r7=3D[r6],3*8;;
-	mov		cr.ipsr=3Dr3
-//	mov		cr.isr=3Dr5                   // cr.isr is read only
-
-	ld8		r3=3D[r2],3*8
-	ld8		r5=3D[r4],3*8
-	ld8		r7=3D[r6],3*8;;
-	mov		cr.iip=3Dr3
-	mov		cr.ifa=3Dr5
-	mov		cr.itir=3Dr7;;
-
-	ld8		r3=3D[r2],3*8
-	ld8		r5=3D[r4],3*8
-	ld8		r7=3D[r6],3*8;;
-	mov		cr.iipa=3Dr3
-	mov		cr.ifs=3Dr5
-	mov		cr.iim=3Dr7
-
-	ld8		r3=3D[r2],160;;               // 160 byte increment
-	mov		cr.iha=3Dr3
-
-rSkipIntrRegs:
-	ld8		r3=3D[r2],152;;               // another 152 byte inc.
-
-	add		r4=3D8,r2                     // duplicate r2 in r4
-	add		r6=3D2*8,r2;;                 // duplicate r2 in r6
-
-	ld8		r3=3D[r2],8*3
-	ld8		r5=3D[r4],8*3
-	ld8		r7=3D[r6],8*3;;
-	mov		cr.lid=3Dr3
-//	mov		cr.ivr=3Dr5                   // cr.ivr is read only
-	mov		cr.tpr=3Dr7;;
-
-	ld8		r3=3D[r2],8*3
-	ld8		r5=3D[r4],8*3
-	ld8		r7=3D[r6],8*3;;
-//	mov		cr.eoi=3Dr3
-//	mov		cr.irr0=3Dr5                  // cr.irr0 is read only
-//	mov		cr.irr1=3Dr7;;                // cr.irr1 is read only
-
-	ld8		r3=3D[r2],8*3
-	ld8		r5=3D[r4],8*3
-	ld8		r7=3D[r6],8*3;;
-//	mov		cr.irr2=3Dr3                  // cr.irr2 is read only
-//	mov		cr.irr3=3Dr5                  // cr.irr3 is read only
-	mov		cr.itv=3Dr7;;
-
-	ld8		r3=3D[r2],8*7
-	ld8		r5=3D[r4],8*7;;
-	mov		cr.pmv=3Dr3
-	mov		cr.cmcv=3Dr5;;
-
-	ld8		r3=3D[r2],8*23
-	ld8		r5=3D[r4],8*23;;
-	adds		r2=3D8*23,r2
-	adds		r4=3D8*23,r4;;
-//	mov		cr.lrr0=3Dr3
-//	mov		cr.lrr1=3Dr5
-
-	adds		r2=3D8*2,r2;;
-
-restore_ARs:
-	add		r4=3D8,r2                  // duplicate r2 in r4
-	add		r6=3D2*8,r2;;              // duplicate r2 in r4
-
-	ld8		r3=3D[r2],3*8
-	ld8		r5=3D[r4],3*8
-	ld8		r7=3D[r6],3*8;;
-	mov		ar.k0=3Dr3
-	mov		ar.k1=3Dr5
-	mov		ar.k2=3Dr7;;
-
-	ld8		r3=3D[r2],3*8
-	ld8		r5=3D[r4],3*8
-	ld8		r7=3D[r6],3*8;;
-	mov		ar.k3=3Dr3
-	mov		ar.k4=3Dr5
-	mov		ar.k5=3Dr7;;
-
-	ld8		r3=3D[r2],10*8
-	ld8		r5=3D[r4],10*8
-	ld8		r7=3D[r6],10*8;;
-	mov		ar.k6=3Dr3
-	mov		ar.k7=3Dr5
-	;;
-
-	ld8		r3=3D[r2],3*8
-	ld8		r5=3D[r4],3*8
-	ld8		r7=3D[r6],3*8;;
-//	mov		ar.rsc=3Dr3
-//	mov		ar.bsp=3Dr5                   // ar.bsp is read only
-	mov		ar.rsc=3Dr0			    // make sure that RSE is in enforced lazy mode
-	;;
-	mov		ar.bspstore=3Dr7;;
-
-	ld8		r9=3D[r2],8*13;;
-	mov		ar.rnat=3Dr9
-
-	mov		ar.rsc=3Dr3
-	ld8		r3=3D[r2],8*4;;
-	mov		ar.ccv=3Dr3
-
-	ld8		r3=3D[r2],8*4;;
-	mov		ar.unat=3Dr3
-
-	ld8		r3=3D[r2],8*4;;
-	mov		ar.fpsr=3Dr3
-
-	ld8		r3=3D[r2],160;;               // 160
-//      mov		ar.itc=3Dr3
-
-	ld8		r3=3D[r2],8;;
-	mov		ar.pfs=3Dr3
-
-	ld8		r3=3D[r2],8;;
-	mov		ar.lc=3Dr3
-
-	ld8		r3=3D[r2];;
-	mov		ar.ec=3Dr3
-	add		r2=3D8*62,r2;;             // padding
-
-restore_RRs:
-	mov		r5=3Dar.lc
-	mov		ar.lc=3D0x08-1
-	movl		r4=3D0x00;;
-cStRRr:
-	dep.z		r7=3Dr4,61,3
-	ld8		r3=3D[r2],8;;
-	mov		rr[r7]=3Dr3                   // what are its access previledges?
-	add		r4=3D1,r4
-	br.cloop.sptk.few	cStRRr
+	// Restore the SAL to OS state. The previous code left regs at pt_regs.
+	add regs=3DMCA_SOS_OFFSET-MCA_PT_REGS_OFFSET, regs
+	;;
+	add temp1=3DIA64_SAL_OS_STATE_COMMON_OFFSET, regs
+	add temp2=3DIA64_SAL_OS_STATE_COMMON_OFFSET+8, regs
+	;;
+	ld8 r12=3D[temp1],16	// sal_ra
+	ld8 r9=3D[temp2],16	// sal_gp
+	;;
+	ld8 r22=3D[temp1],24	// pal_min_state, virtual.  skip prev_task
+	ld8 r21=3D[temp2],16	// prev_IA64_KR_CURRENT
 	;;
-	mov		ar.lc=3Dr5
+	ld8 temp3=3D[temp1],16	// cr.isr
+	ld8 temp4=3D[temp2],16	// cr.ifa
 	;;
-end_os_mca_restore:
-	br	ia64_os_mca_done_restore;;
+	mov cr.isr=3Dtemp3
+	mov cr.ifa=3Dtemp4
+	ld8 temp3=3D[temp1],16	// cr.itir
+	ld8 temp4=3D[temp2],16	// cr.iipa
+	;;
+	mov cr.itir=3Dtemp3
+	mov cr.iipa=3Dtemp4
+	ld8 temp3=3D[temp1],16	// cr.iim
+	ld8 temp4=3D[temp2],16	// cr.iha
+	;;
+	mov cr.iim=3Dtemp3
+	mov cr.iha=3Dtemp4
+	dep r22=3D0,r22,62,2	// pal_min_state, physical, uncached
+	mov IA64_KR(CURRENT)=3Dr21
+	ld8 r8=3D[temp1]		// os_status
+	ld8 r10=3D[temp2]		// context
+
+	br.sptk b0
=20
 //EndStub/////////////////////////////////////////////////////////////////=
/////
=20
=20
-// ok, the issue here is that we need to save state information so
-// it can be useable by the kernel debugger and show regs routines.
-// In order to do this, our best bet is save the current state (plus
-// the state information obtain from the MIN_STATE_AREA) into a pt_regs
-// format.  This way we can pass it on in a useable format.
+//++
+// Name:
+//	ia64_new_stack()
 //
-
+// Stub Description:
 //
-// SAL to OS entry point for INIT on the monarch processor
-// This has been defined for registration purposes with SAL
-// as a part of ia64_mca_init.
+//	Switch to the MCA/INIT stack.
 //
-// When we get here, the following registers have been
-// set by the SAL for our use
+//	r2 contains the return address, r3 contains either
+//	IA64_MCA_CPU_MCA_STACK_OFFSET or IA64_MCA_CPU_INIT_STACK_OFFSET.
 //
-//		1. GR1 =3D OS INIT GP
-//		2. GR8 =3D PAL_PROC physical address
-//		3. GR9 =3D SAL_PROC physical address
-//		4. GR10 =3D SAL GP (physical)
-//		5. GR11 =3D Init Reason
-//			0 =3D Received INIT for event other than crash dump switch
-//			1 =3D Received wakeup at the end of an OS_MCA corrected machine check
-//			2 =3D Received INIT dude to CrashDump switch assertion
+//	On entry RBS is still on the original stack, this routine switches RBS
+//	to use the MCA/INIT stack.
 //
-//		6. GR12 =3D Return address to location within SAL_INIT procedure
-
+//	On entry, sos->pal_min_state is physical, on exit it is virtual.
+//
+//--
=20
-GLOBAL_ENTRY(ia64_monarch_init_handler)
-	.prologue
-	// stash the information the SAL passed to os
-	SAL_TO_OS_MCA_HANDOFF_STATE_SAVE(r2)
+ia64_new_stack:
+	add regs=3DMCA_PT_REGS_OFFSET, r3
+	add temp2=3DMCA_SOS_OFFSET+IA64_SAL_OS_STATE_PAL_MIN_STATE_OFFSET, r3
+	mov b0=3Dr2			// save return address
+	GET_IA64_MCA_DATA(temp1)
+	invala
 	;;
-	SAVE_MIN_WITH_COVER
+	add temp2=3Dtemp2, temp1		// struct ia64_sal_os_state.pal_min_state on MC=
A or INIT stack
+	add regs=3Dregs, temp1		// struct pt_regs on MCA or INIT stack
 	;;
-	mov r8=3Dcr.ifa
-	mov r9=3Dcr.isr
-	adds r3=3D8,r2				// set up second base pointer
+	// Address of minstate area provided by PAL is physical, uncacheable.
+	// Convert to Linux virtual address in region 6 for C code.
+	ld8 ms=3D[temp2]			// pal_min_state, physical
+	;;
+	dep temp1=3D-1,ms,62,2		// set region 6
+	mov temp3=3DIA64_RBS_OFFSET-MCA_PT_REGS_OFFSET
+	;;
+	st8 [temp2]=3Dtemp1		// pal_min_state, virtual
+
+	add temp4=3Dtemp3, regs		// start of bspstore on new stack
 	;;
-	SAVE_REST
+	mov ar.bspstore=3Dtemp4		// switch RBS to MCA/INIT stack
+	;;
+	flushrs				// must be first in group
+	br.sptk b0
+
+//EndStub/////////////////////////////////////////////////////////////////=
/////
+
+
+//++
+// Name:
+//	ia64_old_stack()
+//
+// Stub Description:
+//
+//	Switch to the old stack.
+//
+//	r2 contains the return address, r3 contains either
+//	IA64_MCA_CPU_MCA_STACK_OFFSET or IA64_MCA_CPU_INIT_STACK_OFFSET.
+//
+//	On entry, pal_min_state is virtual, on exit it is physical.
+//
+//	On entry RBS is on the MCA/INIT stack, this routine switches RBS
+//	back to the previous stack.
+//
+//	The psr is set to all zeroes.  SAL return requires either all zeroes or
+//	just psr.mc set.  Leaving psr.mc off allows INIT to be issued if this
+//	code does not perform correctly.
+//
+//	The dirty registers at the time of the event were flushed to the
+//	MCA/INIT stack in ia64_pt_regs_save().  Restore the dirty registers
+//	before reverting to the previous bspstore.
+//--
=20
-// ok, enough should be saved at this point to be dangerous, and supply
-// information for a dump
-// We need to switch to Virtual mode before hitting the C functions.
+ia64_old_stack:
+	add regs=3DMCA_PT_REGS_OFFSET, r3
+	mov b0=3Dr2			// save return address
+	GET_IA64_MCA_DATA(temp2)
+	LOAD_PHYSICAL(p0,temp1,1f)
+	;;
+	mov cr.ipsr=3Dr0
+	mov cr.ifs=3Dr0
+	mov cr.iip=3Dtemp1
+	;;
+	invala
+	rfi
+1:
=20
-	movl	r2=3DIA64_PSR_IT|IA64_PSR_IC|IA64_PSR_DT|IA64_PSR_RT|IA64_PSR_DFH|IA=
64_PSR_BN
-	mov	r3=3Dpsr	// get the current psr, minimum enabled at this point
+	add regs=3Dregs, temp2		// struct pt_regs on MCA or INIT stack
 	;;
-	or	r2=3Dr2,r3
+	add temp1=3DPT(LOADRS), regs
 	;;
-	movl	r3=3DIVirtual_Switch
+	ld8 temp2=3D[temp1],PT(AR_BSPSTORE)-PT(LOADRS)	// restore loadrs
 	;;
-	mov	cr.iip=3Dr3	// short return to set the appropriate bits
-	mov	cr.ipsr=3Dr2	// need to do an rfi to set appropriate bits
+	ld8 temp3=3D[temp1],PT(AR_RNAT)-PT(AR_BSPSTORE)	// restore ar.bspstore
+	mov ar.rsc=3Dtemp2
 	;;
-	rfi
+	loadrs
+	ld8 temp4=3D[temp1]		// restore ar.rnat
 	;;
-IVirtual_Switch:
-	//
-	// We should now be running virtual
-	//
-	// Let's call the C handler to get the rest of the state info
-	//
-	alloc r14=3Dar.pfs,0,0,2,0		// now it's safe (must be first in insn group=
!)
+	mov ar.bspstore=3Dtemp3		// back to old stack
 	;;
-	adds out0=16,sp				// out0 =3D pointer to pt_regs
+	mov ar.rnat=3Dtemp4
 	;;
-	DO_SAVE_SWITCH_STACK
-	.body
-	adds out1=16,sp				// out0 =3D pointer to switch_stack
=20
-	br.call.sptk.many rp=3Dia64_init_handler
-.ret1:
+	br.sptk b0
+
+//EndStub/////////////////////////////////////////////////////////////////=
/////
=20
-return_from_init:
-	br.sptk return_from_init
-END(ia64_monarch_init_handler)
=20
+//++
+// Name:
+//	ia64_set_kernel_registers()
 //
-// SAL to OS entry point for INIT on the slave processor
-// This has been defined for registration purposes with SAL
-// as a part of ia64_mca_init.
+// Stub Description:
 //
+//	Set the registers that are required by the C code in order to run on an
+//	MCA/INIT stack.
+//
+//	r2 contains the return address, r3 contains either
+//	IA64_MCA_CPU_MCA_STACK_OFFSET or IA64_MCA_CPU_INIT_STACK_OFFSET.
+//
+//--
+
+ia64_set_kernel_registers:
+	add temp3=3DMCA_SP_OFFSET, r3
+	add temp4=3DMCA_SOS_OFFSET+IA64_SAL_OS_STATE_OS_GP_OFFSET, r3
+	mov b0=3Dr2		// save return address
+	GET_IA64_MCA_DATA(temp1)
+	;;
+	add temp4=3Dtemp4, temp1	// &struct ia64_sal_os_state.os_gp
+	add r12=3Dtemp1, temp3	// kernel stack pointer on MCA/INIT stack
+	add r13=3Dtemp1, r3	// set current to start of MCA/INIT stack
+	;;
+	ld8 r1=3D[temp4]		// OS GP from SAL OS state
+	;;
+	DATA_PA_TO_VA(r1,temp1)
+	DATA_PA_TO_VA(r12,temp2)
+	DATA_PA_TO_VA(r13,temp3)
+	;;
+	mov IA64_KR(CURRENT)=3Dr13
+
+	// FIXME: do I need to wire IA64_KR_CURRENT_STACK and IA64_TR_CURRENT_STA=
CK?
+
+	br.sptk b0
+
+//EndStub/////////////////////////////////////////////////////////////////=
/////
=20
-GLOBAL_ENTRY(ia64_slave_init_handler)
-1:	br.sptk 1b
-END(ia64_slave_init_handler)
+#undef	ms
+#undef	regs
+#undef	temp1
+#undef	temp2
+#undef	temp3
+#undef	temp4
+
+
+// Support function for mca.c, it is here to avoid using inline asm.  Give=
n the
+// address of an rnat slot, if that address is below the current ar.bspsto=
re
+// then return the contents of that slot, otherwise return the contents of
+// ar.rnat.
+GLOBAL_ENTRY(ia64_get_rnat)
+	alloc r14=3Dar.pfs,1,0,0,0
+	mov ar.rsc=3D0
+	;;
+	mov r14=3Dar.bspstore
+	;;
+	cmp.lt p6,p7=3Din0,r14
+	;;
+(p6)	ld8 r8=3D[in0]
+(p7)	mov r8=3Dar.rnat
+	mov ar.rsc=3D3
+	br.ret.sptk.many rp
+END(ia64_get_rnat)
Index: linux/arch/ia64/kernel/asm-offsets.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig/arch/ia64/kernel/asm-offsets.c	2005-=
08-30 13:56:12.512104719 +1000
+++ linux/arch/ia64/kernel/asm-offsets.c	2005-08-30 13:56:31.822947848 +1000
@@ -211,17 +211,41 @@ void foo(void)
 #endif
=20
 	BLANK();
-	DEFINE(IA64_MCA_CPU_PROC_STATE_DUMP_OFFSET,
-	       offsetof (struct ia64_mca_cpu, proc_state_dump));
-	DEFINE(IA64_MCA_CPU_STACK_OFFSET,
-	       offsetof (struct ia64_mca_cpu, stack));
-	DEFINE(IA64_MCA_CPU_STACKFRAME_OFFSET,
-	       offsetof (struct ia64_mca_cpu, stackframe));
-	DEFINE(IA64_MCA_CPU_RBSTORE_OFFSET,
-	       offsetof (struct ia64_mca_cpu, rbstore));
+	DEFINE(IA64_MCA_CPU_MCA_STACK_OFFSET,
+	       offsetof (struct ia64_mca_cpu, mca_stack));
 	DEFINE(IA64_MCA_CPU_INIT_STACK_OFFSET,
 	       offsetof (struct ia64_mca_cpu, init_stack));
 	BLANK();
+	DEFINE(IA64_SAL_OS_STATE_COMMON_OFFSET,
+	       offsetof (struct ia64_sal_os_state, sal_ra));
+	DEFINE(IA64_SAL_OS_STATE_OS_GP_OFFSET,
+	       offsetof (struct ia64_sal_os_state, os_gp));
+	DEFINE(IA64_SAL_OS_STATE_PAL_MIN_STATE_OFFSET,
+	       offsetof (struct ia64_sal_os_state, pal_min_state));
+	DEFINE(IA64_SAL_OS_STATE_PROC_STATE_PARAM_OFFSET,
+	       offsetof (struct ia64_sal_os_state, proc_state_param));
+	DEFINE(IA64_SAL_OS_STATE_SIZE,
+	       sizeof (struct ia64_sal_os_state));
+	DEFINE(IA64_PMSA_GR_OFFSET,
+	       offsetof (struct pal_min_state_area_s, pmsa_gr));
+	DEFINE(IA64_PMSA_BANK1_GR_OFFSET,
+	       offsetof (struct pal_min_state_area_s, pmsa_bank1_gr));
+	DEFINE(IA64_PMSA_PR_OFFSET,
+	       offsetof (struct pal_min_state_area_s, pmsa_pr));
+	DEFINE(IA64_PMSA_BR0_OFFSET,
+	       offsetof (struct pal_min_state_area_s, pmsa_br0));
+	DEFINE(IA64_PMSA_RSC_OFFSET,
+	       offsetof (struct pal_min_state_area_s, pmsa_rsc));
+	DEFINE(IA64_PMSA_IIP_OFFSET,
+	       offsetof (struct pal_min_state_area_s, pmsa_iip));
+	DEFINE(IA64_PMSA_IPSR_OFFSET,
+	       offsetof (struct pal_min_state_area_s, pmsa_ipsr));
+	DEFINE(IA64_PMSA_IFS_OFFSET,
+	       offsetof (struct pal_min_state_area_s, pmsa_ifs));
+	DEFINE(IA64_PMSA_XIP_OFFSET,
+	       offsetof (struct pal_min_state_area_s, pmsa_xip));
+	BLANK();
+
 	/* used by fsys_gettimeofday in arch/ia64/kernel/fsys.S */
 	DEFINE(IA64_TIME_INTERPOLATOR_ADDRESS_OFFSET, offsetof (struct time_inter=
polator, addr));
 	DEFINE(IA64_TIME_INTERPOLATOR_SOURCE_OFFSET, offsetof (struct time_interp=
olator, source));
Index: linux/arch/ia64/kernel/mca_drv.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig/arch/ia64/kernel/mca_drv.c	2005-08-3=
0 13:56:12.512104719 +1000
+++ linux/arch/ia64/kernel/mca_drv.c	2005-08-30 13:56:31.823924278 +1000
@@ -4,6 +4,8 @@
  *
  * Copyright (C) 2004 FUJITSU LIMITED
  * Copyright (C) Hidetoshi Seto (seto.hidetoshi@jp.fujitsu.com)
+ * Copyright (C) 2005 Silicon Graphics, Inc
+ * Copyright (C) 2005 Keith Owens <kaos@sgi.com>
  */
 #include <linux/config.h>
 #include <linux/types.h>
@@ -38,10 +40,6 @@
 /* max size of SAL error record (default) */
 static int sal_rec_max =3D 10000;
=20
-/* from mca.c */
-static ia64_mca_sal_to_os_state_t *sal_to_os_handoff_state;
-static ia64_mca_os_to_sal_state_t *os_to_sal_handoff_state;
-
 /* from mca_drv_asm.S */
 extern void *mca_handler_bhhook(void);
=20
@@ -316,7 +314,8 @@ init_record_index_pools(void)
  */
=20
 static mca_type_t
-is_mca_global(peidx_table_t *peidx, pal_bus_check_info_t *pbci)
+is_mca_global(peidx_table_t *peidx, pal_bus_check_info_t *pbci,
+	      struct ia64_sal_os_state *sos)
 {
 	pal_processor_state_info_t *psp =3D (pal_processor_state_info_t*)peidx_ps=
p(peidx);
=20
@@ -327,7 +326,7 @@ is_mca_global(peidx_table_t *peidx, pal_
 	 * Therefore it is local MCA when rendezvous has not been requested.
 	 * Failed to rendezvous, the system must be down.
 	 */
-	switch (sal_to_os_handoff_state->imsto_rendez_state) {
+	switch (sos->rv_rc) {
 		case -1: /* SAL rendezvous unsuccessful */
 			return MCA_IS_GLOBAL;
 		case  0: /* SAL rendezvous not required */
@@ -388,7 +387,8 @@ is_mca_global(peidx_table_t *peidx, pal_
  */
=20
 static int
-recover_from_read_error(slidx_table_t *slidx, peidx_table_t *peidx, pal_bu=
s_check_info_t *pbci)
+recover_from_read_error(slidx_table_t *slidx, peidx_table_t *peidx, pal_bu=
s_check_info_t *pbci,
+			struct ia64_sal_os_state *sos)
 {
 	sal_log_mod_error_info_t *smei;
 	pal_min_state_area_t *pmsa;
@@ -426,7 +426,7 @@ recover_from_read_error(slidx_table_t *s
 			 *  setup for resume to bottom half of MCA,
 			 * "mca_handler_bhhook"
 			 */
-			pmsa =3D (pal_min_state_area_t *)(sal_to_os_handoff_state->pal_min_stat=
e | (6ul<<61));
+			pmsa =3D sos->pal_min_state;
 			/* pass to bhhook as 1st argument (gr8) */
 			pmsa->pmsa_gr[8-1] =3D smei->target_identifier;
 			/* set interrupted return address (but no use) */
@@ -459,7 +459,8 @@ recover_from_read_error(slidx_table_t *s
  */
=20
 static int
-recover_from_platform_error(slidx_table_t *slidx, peidx_table_t *peidx, pa=
l_bus_check_info_t *pbci)
+recover_from_platform_error(slidx_table_t *slidx, peidx_table_t *peidx, pa=
l_bus_check_info_t *pbci,
+			    struct ia64_sal_os_state *sos)
 {
 	int status =3D 0;
 	pal_processor_state_info_t *psp =3D (pal_processor_state_info_t*)peidx_ps=
p(peidx);
@@ -469,7 +470,7 @@ recover_from_platform_error(slidx_table_
 		case 1: /* partial read */
 		case 3: /* full line(cpu) read */
 		case 9: /* I/O space read */
-			status =3D recover_from_read_error(slidx, peidx, pbci);
+			status =3D recover_from_read_error(slidx, peidx, pbci, sos);
 			break;
 		case 0: /* unknown */
 		case 2: /* partial write */
@@ -508,7 +509,8 @@ recover_from_platform_error(slidx_table_
  */
=20
 static int
-recover_from_processor_error(int platform, slidx_table_t *slidx, peidx_tab=
le_t *peidx, pal_bus_check_info_t *pbci)
+recover_from_processor_error(int platform, slidx_table_t *slidx, peidx_tab=
le_t *peidx, pal_bus_check_info_t *pbci,
+			     struct ia64_sal_os_state *sos)
 {
 	pal_processor_state_info_t *psp =3D (pal_processor_state_info_t*)peidx_ps=
p(peidx);
=20
@@ -545,7 +547,7 @@ recover_from_processor_error(int platfor
 	 * This means "there are some platform errors".
 	 */
 	if (platform)=20
-		return recover_from_platform_error(slidx, peidx, pbci);
+		return recover_from_platform_error(slidx, peidx, pbci, sos);
 	/*=20
 	 * On account of strange SAL error record, we cannot recover.=20
 	 */
@@ -562,8 +564,7 @@ recover_from_processor_error(int platfor
=20
 static int
 mca_try_to_recover(void *rec,=20
-	ia64_mca_sal_to_os_state_t *sal_to_os_state,
-	ia64_mca_os_to_sal_state_t *os_to_sal_state)
+	struct ia64_sal_os_state *sos)
 {
 	int platform_err;
 	int n_proc_err;
@@ -571,10 +572,6 @@ mca_try_to_recover(void *rec,=20
 	peidx_table_t peidx;
 	pal_bus_check_info_t pbci;
=20
-	/* handoff state from/to mca.c */
-	sal_to_os_handoff_state =3D sal_to_os_state;
-	os_to_sal_handoff_state =3D os_to_sal_state;
-
 	/* Make index of SAL error record */
 	platform_err =3D mca_make_slidx(rec, &slidx);
=20
@@ -597,11 +594,11 @@ mca_try_to_recover(void *rec,=20
 	*((u64*)&pbci) =3D peidx_check_info(&peidx, bus_check, 0);
=20
 	/* Check whether MCA is global or not */
-	if (is_mca_global(&peidx, &pbci))
+	if (is_mca_global(&peidx, &pbci, sos))
 		return 0;
 =09
 	/* Try to recover a processor error */
-	return recover_from_processor_error(platform_err, &slidx, &peidx, &pbci);
+	return recover_from_processor_error(platform_err, &slidx, &peidx, &pbci, =
sos);
 }
=20
 /*
Index: linux/arch/ia64/kernel/mca.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig/arch/ia64/kernel/mca.c	2005-08-30 13=
:56:12.512104719 +1000
+++ linux/arch/ia64/kernel/mca.c	2005-08-30 14:14:18.042787181 +1000
@@ -48,6 +48,9 @@
  *            Delete dead variables and functions.
  *            Reorder to remove the need for forward declarations and to c=
onsolidate
  *            related code.
+ *
+ * 2005-08-12 Keith Owens <kaos@sgi.com>
+ *	      Convert MCA/INIT handlers to use per event stacks and SAL/OS stat=
e.
  */
 #include <linux/config.h>
 #include <linux/types.h>
@@ -77,6 +80,8 @@
 #include <asm/irq.h>
 #include <asm/hw_irq.h>
=20
+#include "entry.h"
+
 #if defined(IA64_MCA_DEBUG_INFO)
 # define IA64_MCA_DEBUG(fmt...)	printk(fmt)
 #else
@@ -84,9 +89,8 @@
 #endif
=20
 /* Used by mca_asm.S */
-ia64_mca_sal_to_os_state_t	ia64_sal_to_os_handoff_state;
-ia64_mca_os_to_sal_state_t	ia64_os_to_sal_handoff_state;
-u64				ia64_mca_serialize;
+u32				ia64_mca_serialize;
+s32				ia64_mca_init_leave =3D -1;
 DEFINE_PER_CPU(u64, ia64_mca_data); /* =3D __per_cpu_mca[smp_processor_id(=
)] */
 DEFINE_PER_CPU(u64, ia64_mca_per_cpu_pte); /* PTE to map per-CPU area */
 DEFINE_PER_CPU(u64, ia64_mca_pal_pte);	    /* PTE to map PAL code */
@@ -95,8 +99,10 @@ DEFINE_PER_CPU(u64, ia64_mca_pal_base);=20
 unsigned long __per_cpu_mca[NR_CPUS];
=20
 /* In mca_asm.S */
-extern void			ia64_monarch_init_handler (void);
-extern void			ia64_slave_init_handler (void);
+extern void			ia64_os_init_dispatch_monarch (void);
+extern void			ia64_os_init_dispatch_slave (void);
+
+static int monarch_cpu =3D -1;
=20
 static ia64_mc_info_t		ia64_mc_info;
=20
@@ -234,7 +240,8 @@ ia64_log_get(int sal_info_type, u8 **buf
  *  This function retrieves a specified error record type from SAL
  *  and wakes up any processes waiting for error records.
  *
- *  Inputs  :   sal_info_type   (Type of error record MCA/CMC/CPE/INIT)
+ *  Inputs  :   sal_info_type   (Type of error record MCA/CMC/CPE)
+ *              FIXME: remove MCA and irq_safe.
  */
 static void
 ia64_mca_log_sal_error_record(int sal_info_type)
@@ -242,7 +249,7 @@ ia64_mca_log_sal_error_record(int sal_in
 	u8 *buffer;
 	sal_log_record_header_t *rh;
 	u64 size;
-	int irq_safe =3D sal_info_type !=3D SAL_INFO_TYPE_MCA && sal_info_type !=
=3D SAL_INFO_TYPE_INIT;
+	int irq_safe =3D sal_info_type !=3D SAL_INFO_TYPE_MCA;
 #ifdef IA64_MCA_DEBUG_INFO
 	static const char * const rec_name[] =3D { "MCA", "INIT", "CMC", "CPE" };
 #endif
@@ -330,191 +337,6 @@ ia64_mca_cpe_int_handler (int cpe_irq, v
=20
 #endif /* CONFIG_ACPI */
=20
-static void
-show_min_state (pal_min_state_area_t *minstate)
-{
-	u64 iip =3D minstate->pmsa_iip + ((struct ia64_psr *)(&minstate->pmsa_ips=
r))->ri;
-	u64 xip =3D minstate->pmsa_xip + ((struct ia64_psr *)(&minstate->pmsa_xps=
r))->ri;
-
-	printk("NaT bits\t%016lx\n", minstate->pmsa_nat_bits);
-	printk("pr\t\t%016lx\n", minstate->pmsa_pr);
-	printk("b0\t\t%016lx ", minstate->pmsa_br0); print_symbol("%s\n", minstat=
e->pmsa_br0);
-	printk("ar.rsc\t\t%016lx\n", minstate->pmsa_rsc);
-	printk("cr.iip\t\t%016lx ", iip); print_symbol("%s\n", iip);
-	printk("cr.ipsr\t\t%016lx\n", minstate->pmsa_ipsr);
-	printk("cr.ifs\t\t%016lx\n", minstate->pmsa_ifs);
-	printk("xip\t\t%016lx ", xip); print_symbol("%s\n", xip);
-	printk("xpsr\t\t%016lx\n", minstate->pmsa_xpsr);
-	printk("xfs\t\t%016lx\n", minstate->pmsa_xfs);
-	printk("b1\t\t%016lx ", minstate->pmsa_br1);
-	print_symbol("%s\n", minstate->pmsa_br1);
-
-	printk("\nstatic registers r0-r15:\n");
-	printk(" r0- 3 %016lx %016lx %016lx %016lx\n",
-	       0UL, minstate->pmsa_gr[0], minstate->pmsa_gr[1], minstate->pmsa_gr=
[2]);
-	printk(" r4- 7 %016lx %016lx %016lx %016lx\n",
-	       minstate->pmsa_gr[3], minstate->pmsa_gr[4],
-	       minstate->pmsa_gr[5], minstate->pmsa_gr[6]);
-	printk(" r8-11 %016lx %016lx %016lx %016lx\n",
-	       minstate->pmsa_gr[7], minstate->pmsa_gr[8],
-	       minstate->pmsa_gr[9], minstate->pmsa_gr[10]);
-	printk("r12-15 %016lx %016lx %016lx %016lx\n",
-	       minstate->pmsa_gr[11], minstate->pmsa_gr[12],
-	       minstate->pmsa_gr[13], minstate->pmsa_gr[14]);
-
-	printk("\nbank 0:\n");
-	printk("r16-19 %016lx %016lx %016lx %016lx\n",
-	       minstate->pmsa_bank0_gr[0], minstate->pmsa_bank0_gr[1],
-	       minstate->pmsa_bank0_gr[2], minstate->pmsa_bank0_gr[3]);
-	printk("r20-23 %016lx %016lx %016lx %016lx\n",
-	       minstate->pmsa_bank0_gr[4], minstate->pmsa_bank0_gr[5],
-	       minstate->pmsa_bank0_gr[6], minstate->pmsa_bank0_gr[7]);
-	printk("r24-27 %016lx %016lx %016lx %016lx\n",
-	       minstate->pmsa_bank0_gr[8], minstate->pmsa_bank0_gr[9],
-	       minstate->pmsa_bank0_gr[10], minstate->pmsa_bank0_gr[11]);
-	printk("r28-31 %016lx %016lx %016lx %016lx\n",
-	       minstate->pmsa_bank0_gr[12], minstate->pmsa_bank0_gr[13],
-	       minstate->pmsa_bank0_gr[14], minstate->pmsa_bank0_gr[15]);
-
-	printk("\nbank 1:\n");
-	printk("r16-19 %016lx %016lx %016lx %016lx\n",
-	       minstate->pmsa_bank1_gr[0], minstate->pmsa_bank1_gr[1],
-	       minstate->pmsa_bank1_gr[2], minstate->pmsa_bank1_gr[3]);
-	printk("r20-23 %016lx %016lx %016lx %016lx\n",
-	       minstate->pmsa_bank1_gr[4], minstate->pmsa_bank1_gr[5],
-	       minstate->pmsa_bank1_gr[6], minstate->pmsa_bank1_gr[7]);
-	printk("r24-27 %016lx %016lx %016lx %016lx\n",
-	       minstate->pmsa_bank1_gr[8], minstate->pmsa_bank1_gr[9],
-	       minstate->pmsa_bank1_gr[10], minstate->pmsa_bank1_gr[11]);
-	printk("r28-31 %016lx %016lx %016lx %016lx\n",
-	       minstate->pmsa_bank1_gr[12], minstate->pmsa_bank1_gr[13],
-	       minstate->pmsa_bank1_gr[14], minstate->pmsa_bank1_gr[15]);
-}
-
-static void
-fetch_min_state (pal_min_state_area_t *ms, struct pt_regs *pt, struct swit=
ch_stack *sw)
-{
-	u64 *dst_banked, *src_banked, bit, shift, nat_bits;
-	int i;
-
-	/*
-	 * First, update the pt-regs and switch-stack structures with the content=
s stored
-	 * in the min-state area:
-	 */
-	if (((struct ia64_psr *) &ms->pmsa_ipsr)->ic =3D 0) {
-		pt->cr_ipsr =3D ms->pmsa_xpsr;
-		pt->cr_iip =3D ms->pmsa_xip;
-		pt->cr_ifs =3D ms->pmsa_xfs;
-	} else {
-		pt->cr_ipsr =3D ms->pmsa_ipsr;
-		pt->cr_iip =3D ms->pmsa_iip;
-		pt->cr_ifs =3D ms->pmsa_ifs;
-	}
-	pt->ar_rsc =3D ms->pmsa_rsc;
-	pt->pr =3D ms->pmsa_pr;
-	pt->r1 =3D ms->pmsa_gr[0];
-	pt->r2 =3D ms->pmsa_gr[1];
-	pt->r3 =3D ms->pmsa_gr[2];
-	sw->r4 =3D ms->pmsa_gr[3];
-	sw->r5 =3D ms->pmsa_gr[4];
-	sw->r6 =3D ms->pmsa_gr[5];
-	sw->r7 =3D ms->pmsa_gr[6];
-	pt->r8 =3D ms->pmsa_gr[7];
-	pt->r9 =3D ms->pmsa_gr[8];
-	pt->r10 =3D ms->pmsa_gr[9];
-	pt->r11 =3D ms->pmsa_gr[10];
-	pt->r12 =3D ms->pmsa_gr[11];
-	pt->r13 =3D ms->pmsa_gr[12];
-	pt->r14 =3D ms->pmsa_gr[13];
-	pt->r15 =3D ms->pmsa_gr[14];
-	dst_banked =3D &pt->r16;		/* r16-r31 are contiguous in struct pt_regs */
-	src_banked =3D ms->pmsa_bank1_gr;
-	for (i =3D 0; i < 16; ++i)
-		dst_banked[i] =3D src_banked[i];
-	pt->b0 =3D ms->pmsa_br0;
-	sw->b1 =3D ms->pmsa_br1;
-
-	/* construct the NaT bits for the pt-regs structure: */
-#	define PUT_NAT_BIT(dst, addr)					\
-	do {								\
-		bit =3D nat_bits & 1; nat_bits >>=3D 1;			\
-		shift =3D ((unsigned long) addr >> 3) & 0x3f;		\
-		dst =3D ((dst) & ~(1UL << shift)) | (bit << shift);	\
-	} while (0)
-
-	/* Rotate the saved NaT bits such that bit 0 corresponds to pmsa_gr[0]: */
-	shift =3D ((unsigned long) &ms->pmsa_gr[0] >> 3) & 0x3f;
-	nat_bits =3D (ms->pmsa_nat_bits >> shift) | (ms->pmsa_nat_bits << (64 - s=
hift));
-
-	PUT_NAT_BIT(sw->caller_unat, &pt->r1);
-	PUT_NAT_BIT(sw->caller_unat, &pt->r2);
-	PUT_NAT_BIT(sw->caller_unat, &pt->r3);
-	PUT_NAT_BIT(sw->ar_unat, &sw->r4);
-	PUT_NAT_BIT(sw->ar_unat, &sw->r5);
-	PUT_NAT_BIT(sw->ar_unat, &sw->r6);
-	PUT_NAT_BIT(sw->ar_unat, &sw->r7);
-	PUT_NAT_BIT(sw->caller_unat, &pt->r8);	PUT_NAT_BIT(sw->caller_unat, &pt->=
r9);
-	PUT_NAT_BIT(sw->caller_unat, &pt->r10);	PUT_NAT_BIT(sw->caller_unat, &pt-=
>r11);
-	PUT_NAT_BIT(sw->caller_unat, &pt->r12);	PUT_NAT_BIT(sw->caller_unat, &pt-=
>r13);
-	PUT_NAT_BIT(sw->caller_unat, &pt->r14);	PUT_NAT_BIT(sw->caller_unat, &pt-=
>r15);
-	nat_bits >>=3D 16;	/* skip over bank0 NaT bits */
-	PUT_NAT_BIT(sw->caller_unat, &pt->r16);	PUT_NAT_BIT(sw->caller_unat, &pt-=
>r17);
-	PUT_NAT_BIT(sw->caller_unat, &pt->r18);	PUT_NAT_BIT(sw->caller_unat, &pt-=
>r19);
-	PUT_NAT_BIT(sw->caller_unat, &pt->r20);	PUT_NAT_BIT(sw->caller_unat, &pt-=
>r21);
-	PUT_NAT_BIT(sw->caller_unat, &pt->r22);	PUT_NAT_BIT(sw->caller_unat, &pt-=
>r23);
-	PUT_NAT_BIT(sw->caller_unat, &pt->r24);	PUT_NAT_BIT(sw->caller_unat, &pt-=
>r25);
-	PUT_NAT_BIT(sw->caller_unat, &pt->r26);	PUT_NAT_BIT(sw->caller_unat, &pt-=
>r27);
-	PUT_NAT_BIT(sw->caller_unat, &pt->r28);	PUT_NAT_BIT(sw->caller_unat, &pt-=
>r29);
-	PUT_NAT_BIT(sw->caller_unat, &pt->r30);	PUT_NAT_BIT(sw->caller_unat, &pt-=
>r31);
-}
-
-static void
-init_handler_platform (pal_min_state_area_t *ms,
-		       struct pt_regs *pt, struct switch_stack *sw)
-{
-	struct unw_frame_info info;
-
-	/* if a kernel debugger is available call it here else just dump the regi=
sters */
-
-	/*
-	 * Wait for a bit.  On some machines (e.g., HP's zx2000 and zx6000, INIT =
can be
-	 * generated via the BMC's command-line interface, but since the console =
is on the
-	 * same serial line, the user will need some time to switch out of the BM=
C before
-	 * the dump begins.
-	 */
-	printk("Delaying for 5 seconds...\n");
-	udelay(5*1000000);
-	show_min_state(ms);
-
-	printk("Backtrace of current task (pid %d, %s)\n", current->pid, current-=
>comm);
-	fetch_min_state(ms, pt, sw);
-	unw_init_from_interruption(&info, current, pt, sw);
-	ia64_do_show_stack(&info, NULL);
-
-#ifdef CONFIG_SMP
-	/* read_trylock() would be handy... */
-	if (!tasklist_lock.write_lock)
-		read_lock(&tasklist_lock);
-#endif
-	{
-		struct task_struct *g, *t;
-		do_each_thread (g, t) {
-			if (t =3D current)
-				continue;
-
-			printk("\nBacktrace of pid %d (%s)\n", t->pid, t->comm);
-			show_stack(t, NULL);
-		} while_each_thread (g, t);
-	}
-#ifdef CONFIG_SMP
-	if (!tasklist_lock.write_lock)
-		read_unlock(&tasklist_lock);
-#endif
-
-	printk("\nINIT dump complete.  Please reboot now.\n");
-	while (1);			/* hang city if no debugger */
-}
-
 #ifdef CONFIG_ACPI
 /*
  * ia64_mca_register_cpev
@@ -657,42 +479,6 @@ ia64_mca_cmc_vector_enable_keventd(void=20
 }
=20
 /*
- * ia64_mca_wakeup_ipi_wait
- *
- *	Wait for the inter-cpu interrupt to be sent by the
- *	monarch processor once it is done with handling the
- *	MCA.
- *
- *  Inputs  :   None
- *  Outputs :   None
- */
-static void
-ia64_mca_wakeup_ipi_wait(void)
-{
-	int	irr_num =3D (IA64_MCA_WAKEUP_VECTOR >> 6);
-	int	irr_bit =3D (IA64_MCA_WAKEUP_VECTOR & 0x3f);
-	u64	irr =3D 0;
-
-	do {
-		switch(irr_num) {
-		      case 0:
-			irr =3D ia64_getreg(_IA64_REG_CR_IRR0);
-			break;
-		      case 1:
-			irr =3D ia64_getreg(_IA64_REG_CR_IRR1);
-			break;
-		      case 2:
-			irr =3D ia64_getreg(_IA64_REG_CR_IRR2);
-			break;
-		      case 3:
-			irr =3D ia64_getreg(_IA64_REG_CR_IRR3);
-			break;
-		}
-		cpu_relax();
-	} while (!(irr & (1UL << irr_bit))) ;
-}
-
-/*
  * ia64_mca_wakeup
  *
  *	Send an inter-cpu interrupt to wake-up a particular cpu
@@ -757,11 +543,9 @@ ia64_mca_rendez_int_handler(int rendez_i
 	 */
 	ia64_sal_mc_rendez();
=20
-	/* Wait for the wakeup IPI from the monarch
-	 * This waiting is done by polling on the wakeup-interrupt
-	 * vector bit in the processor's IRRs
-	 */
-	ia64_mca_wakeup_ipi_wait();
+	/* Wait for the monarch cpu to exit. */
+	while (monarch_cpu !=3D -1)
+	       cpu_relax();	/* spin until monarch leaves */
=20
 	/* Enable all interrupts */
 	local_irq_restore(flags);
@@ -789,53 +573,13 @@ ia64_mca_wakeup_int_handler(int wakeup_i
 	return IRQ_HANDLED;
 }
=20
-/*
- * ia64_return_to_sal_check
- *
- *	This is function called before going back from the OS_MCA handler
- *	to the OS_MCA dispatch code which finally takes the control back
- *	to the SAL.
- *	The main purpose of this routine is to setup the OS_MCA to SAL
- *	return state which can be used by the OS_MCA dispatch code
- *	just before going back to SAL.
- *
- *  Inputs  :   None
- *  Outputs :   None
- */
-
-static void
-ia64_return_to_sal_check(int recover)
-{
-
-	/* Copy over some relevant stuff from the sal_to_os_mca_handoff
-	 * so that it can be used at the time of os_mca_to_sal_handoff
-	 */
-	ia64_os_to_sal_handoff_state.imots_sal_gp -		ia64_sal_to_os_handoff_state=
.imsto_sal_gp;
-
-	ia64_os_to_sal_handoff_state.imots_sal_check_ra -		ia64_sal_to_os_handoff=
_state.imsto_sal_check_ra;
-
-	if (recover)
-		ia64_os_to_sal_handoff_state.imots_os_status =3D IA64_MCA_CORRECTED;
-	else
-		ia64_os_to_sal_handoff_state.imots_os_status =3D IA64_MCA_COLD_BOOT;
-
-	/* Default =3D tell SAL to return to same context */
-	ia64_os_to_sal_handoff_state.imots_context =3D IA64_MCA_SAME_CONTEXT;
-
-	ia64_os_to_sal_handoff_state.imots_new_min_state -		(u64 *)ia64_sal_to_os=
_handoff_state.pal_min_state;
-
-}
-
 /* Function pointer for extra MCA recovery */
 int (*ia64_mca_ucmc_extension)
-	(void*,ia64_mca_sal_to_os_state_t*,ia64_mca_os_to_sal_state_t*)
+	(void*,struct ia64_sal_os_state*)
 	=3D NULL;
=20
 int
-ia64_reg_MCA_extension(void *fn)
+ia64_reg_MCA_extension(int (*fn)(void *, struct ia64_sal_os_state *))
 {
 	if (ia64_mca_ucmc_extension)
 		return 1;
@@ -854,8 +598,324 @@ ia64_unreg_MCA_extension(void)
 EXPORT_SYMBOL(ia64_reg_MCA_extension);
 EXPORT_SYMBOL(ia64_unreg_MCA_extension);
=20
+
+static inline void
+copy_reg(const u64 *fr, u64 fnat, u64 *tr, u64 *tnat)
+{
+	u64 fslot, tslot, nat;
+	*tr =3D *fr;
+	fslot =3D ((unsigned long)fr >> 3) & 63;
+	tslot =3D ((unsigned long)tr >> 3) & 63;
+	*tnat &=3D ~(1UL << tslot);
+	nat =3D (fnat >> fslot) & 1;
+	*tnat |=3D (nat << tslot);
+}
+
+/* On entry to this routine, we are running on the per cpu stack, see
+ * mca_asm.h.  The original stack has not been touched by this event.  Som=
e of
+ * the original stack's registers will be in the RBS on this stack.  This =
stack
+ * also contains a partial pt_regs and switch_stack, the rest of the data =
is in
+ * PAL minstate.
+ *
+ * The first thing to do is modify the original stack to look like a block=
ed
+ * task so we can run backtrace on the original task.  Also mark the per c=
pu
+ * stack as current to ensure that we use the correct task state, it also =
means
+ * that we can do backtrace on the MCA/INIT handler code itself.
+ */
+
+static task_t *
+ia64_mca_modify_original_stack(struct pt_regs *regs,
+		const struct switch_stack *sw,
+		struct ia64_sal_os_state *sos,
+		const char *type)
+{
+	char *p, comm[sizeof(current->comm)];
+	ia64_va va;
+	extern char ia64_leave_kernel[];	/* Need asm address, not function descri=
ptor */
+	const pal_min_state_area_t *ms =3D sos->pal_min_state;
+	task_t *previous_current;
+	struct pt_regs *old_regs;
+	struct switch_stack *old_sw;
+	unsigned size =3D sizeof(struct pt_regs) +
+			sizeof(struct switch_stack) + 16;
+	u64 *old_bspstore, *old_bsp;
+	u64 *new_bspstore, *new_bsp;
+	u64 old_unat, old_rnat, new_rnat, nat;
+	u64 slots, loadrs =3D regs->loadrs;
+	u64 r12 =3D ms->pmsa_gr[12-1], r13 =3D ms->pmsa_gr[13-1];
+	u64 ar_bspstore =3D regs->ar_bspstore;
+	u64 ar_bsp =3D regs->ar_bspstore + (loadrs >> 16);
+	const u64 *bank;
+	const char *msg;
+	int cpu =3D smp_processor_id();
+
+	previous_current =3D curr_task(cpu);
+	set_curr_task(cpu, current);
+	if ((p =3D strchr(current->comm, ' ')))
+		*p =3D '\0';
+
+	/* Best effort attempt to cope with MCA/INIT delivered while in
+	 * physical mode.
+	 */
+	regs->cr_ipsr =3D ms->pmsa_ipsr;
+	if (ia64_psr(regs)->dt =3D 0) {
+		va.l =3D r12;
+		if (va.f.reg =3D 0) {
+			va.f.reg =3D 7;
+			r12 =3D va.l;
+		}
+		va.l =3D r13;
+		if (va.f.reg =3D 0) {
+			va.f.reg =3D 7;
+			r13 =3D va.l;
+		}
+	}
+	if (ia64_psr(regs)->rt =3D 0) {
+		va.l =3D ar_bspstore;
+		if (va.f.reg =3D 0) {
+			va.f.reg =3D 7;
+			ar_bspstore =3D va.l;
+		}
+		va.l =3D ar_bsp;
+		if (va.f.reg =3D 0) {
+			va.f.reg =3D 7;
+			ar_bsp =3D va.l;
+		}
+	}
+
+	/* mca_asm.S ia64_old_stack() cannot assume that the dirty registers
+	 * have been copied to the old stack, the old stack may fail the
+	 * validation tests below.  So ia64_old_stack() must restore the dirty
+	 * registers from the new stack.  The old and new bspstore probably
+	 * have different alignments, so loadrs calculated on the old bsp
+	 * cannot be used to restore from the new bsp.  Calculate a suitable
+	 * loadrs for the new stack and save it in the new pt_regs, where
+	 * ia64_old_stack() can get it.
+	 */
+	old_bspstore =3D (u64 *)ar_bspstore;
+	old_bsp =3D (u64 *)ar_bsp;
+	slots =3D ia64_rse_num_regs(old_bspstore, old_bsp);
+	new_bspstore =3D (u64 *)((u64)current + IA64_RBS_OFFSET);
+	new_bsp =3D ia64_rse_skip_regs(new_bspstore, slots);
+	regs->loadrs =3D (new_bsp - new_bspstore) * 8 << 16;
+
+	/* Verify the previous stack state before we change it */
+	if (user_mode(regs)) {
+		msg =3D "occurred in user space";
+		goto no_mod;
+	}
+	if ((r12 & -KERNEL_STACK_SIZE) !=3D r13) {
+		msg =3D "inconsistent r12 and r13";
+		goto no_mod;
+	}
+	if ((ar_bspstore & -KERNEL_STACK_SIZE) !=3D r13) {
+		msg =3D "inconsistent ar.bspstore and r13";
+		goto no_mod;
+	}
+	va.p =3D old_bspstore;
+	if (va.f.reg < 5) {
+		msg =3D "old_bspstore is in the wrong region";
+		goto no_mod;
+	}
+	if ((ar_bsp & -KERNEL_STACK_SIZE) !=3D r13) {
+		msg =3D "inconsistent ar.bsp and r13";
+		goto no_mod;
+	}
+	size +=3D (ia64_rse_skip_regs(old_bspstore, slots) - old_bspstore) * 8;
+	if (ar_bspstore + size > r12) {
+		msg =3D "no room for blocked state";
+		goto no_mod;
+	}
+
+	/* Change the comm field on the MCA/INT task to include the pid that
+	 * was interrupted, it makes for easier debugging.  If that pid was 0
+	 * (swapper or nested MCA/INIT) then use the start of the previous comm
+	 * field suffixed with its cpu.
+	 */
+	if (previous_current->pid)
+		snprintf(comm, sizeof(comm), "%s %d",
+			current->comm, previous_current->pid);
+	else {
+		int l;
+		if ((p =3D strchr(previous_current->comm, ' ')))
+			l =3D p - previous_current->comm;
+		else
+			l =3D strlen(previous_current->comm);
+		snprintf(comm, sizeof(comm), "%s %*s %d",
+			current->comm, l, previous_current->comm,
+			previous_current->thread_info->cpu);
+	}
+	memcpy(current->comm, comm, sizeof(current->comm));
+
+	/* Make the original task look blocked.  First stack a struct pt_regs,
+	 * describing the state at the time of interrupt.  mca_asm.S built a
+	 * partial pt_regs, copy it and fill in the blanks using minstate.
+	 */
+	p =3D (char *)r12 - sizeof(*regs);
+	old_regs =3D (struct pt_regs *)p;
+	memcpy(old_regs, regs, sizeof(*regs));
+	/* If ipsr.ic then use pmsa_{iip,ipsr,ifs}, else use
+	 * pmsa_{xip,xpsr,xfs}
+	 */
+	if (ia64_psr(regs)->ic) {
+		old_regs->cr_iip =3D ms->pmsa_iip;
+		old_regs->cr_ipsr =3D ms->pmsa_ipsr;
+		old_regs->cr_ifs =3D ms->pmsa_ifs;
+	} else {
+		old_regs->cr_iip =3D ms->pmsa_xip;
+		old_regs->cr_ipsr =3D ms->pmsa_xpsr;
+		old_regs->cr_ifs =3D ms->pmsa_xfs;
+	}
+	old_regs->pr =3D ms->pmsa_pr;
+	old_regs->b0 =3D ms->pmsa_br0;
+	old_regs->loadrs =3D loadrs;
+	old_regs->ar_rsc =3D ms->pmsa_rsc;
+	old_unat =3D old_regs->ar_unat;
+	copy_reg(&ms->pmsa_gr[1-1], ms->pmsa_nat_bits, &old_regs->r1, &old_unat);
+	copy_reg(&ms->pmsa_gr[2-1], ms->pmsa_nat_bits, &old_regs->r2, &old_unat);
+	copy_reg(&ms->pmsa_gr[3-1], ms->pmsa_nat_bits, &old_regs->r3, &old_unat);
+	copy_reg(&ms->pmsa_gr[8-1], ms->pmsa_nat_bits, &old_regs->r8, &old_unat);
+	copy_reg(&ms->pmsa_gr[9-1], ms->pmsa_nat_bits, &old_regs->r9, &old_unat);
+	copy_reg(&ms->pmsa_gr[10-1], ms->pmsa_nat_bits, &old_regs->r10, &old_unat=
);
+	copy_reg(&ms->pmsa_gr[11-1], ms->pmsa_nat_bits, &old_regs->r11, &old_unat=
);
+	copy_reg(&ms->pmsa_gr[12-1], ms->pmsa_nat_bits, &old_regs->r12, &old_unat=
);
+	copy_reg(&ms->pmsa_gr[13-1], ms->pmsa_nat_bits, &old_regs->r13, &old_unat=
);
+	copy_reg(&ms->pmsa_gr[14-1], ms->pmsa_nat_bits, &old_regs->r14, &old_unat=
);
+	copy_reg(&ms->pmsa_gr[15-1], ms->pmsa_nat_bits, &old_regs->r15, &old_unat=
);
+	if (ia64_psr(old_regs)->bn)
+		bank =3D ms->pmsa_bank1_gr;
+	else
+		bank =3D ms->pmsa_bank0_gr;
+	copy_reg(&bank[16-16], ms->pmsa_nat_bits, &old_regs->r16, &old_unat);
+	copy_reg(&bank[17-16], ms->pmsa_nat_bits, &old_regs->r17, &old_unat);
+	copy_reg(&bank[18-16], ms->pmsa_nat_bits, &old_regs->r18, &old_unat);
+	copy_reg(&bank[19-16], ms->pmsa_nat_bits, &old_regs->r19, &old_unat);
+	copy_reg(&bank[20-16], ms->pmsa_nat_bits, &old_regs->r20, &old_unat);
+	copy_reg(&bank[21-16], ms->pmsa_nat_bits, &old_regs->r21, &old_unat);
+	copy_reg(&bank[22-16], ms->pmsa_nat_bits, &old_regs->r22, &old_unat);
+	copy_reg(&bank[23-16], ms->pmsa_nat_bits, &old_regs->r23, &old_unat);
+	copy_reg(&bank[24-16], ms->pmsa_nat_bits, &old_regs->r24, &old_unat);
+	copy_reg(&bank[25-16], ms->pmsa_nat_bits, &old_regs->r25, &old_unat);
+	copy_reg(&bank[26-16], ms->pmsa_nat_bits, &old_regs->r26, &old_unat);
+	copy_reg(&bank[27-16], ms->pmsa_nat_bits, &old_regs->r27, &old_unat);
+	copy_reg(&bank[28-16], ms->pmsa_nat_bits, &old_regs->r28, &old_unat);
+	copy_reg(&bank[29-16], ms->pmsa_nat_bits, &old_regs->r29, &old_unat);
+	copy_reg(&bank[30-16], ms->pmsa_nat_bits, &old_regs->r30, &old_unat);
+	copy_reg(&bank[31-16], ms->pmsa_nat_bits, &old_regs->r31, &old_unat);
+
+	/* Next stack a struct switch_stack.  mca_asm.S built a partial
+	 * switch_stack, copy it and fill in the blanks using pt_regs and
+	 * minstate.
+	 *
+	 * In the synthesized switch_stack, b0 points to ia64_leave_kernel,
+	 * ar.pfs is set to 0.
+	 *
+	 * unwind.c::unw_unwind() does special processing for interrupt frames.
+	 * It checks if the PRED_NON_SYSCALL predicate is set, if the predicate
+	 * is clear then unw_unwind() does _not_ adjust bsp over pt_regs.  Not
+	 * that this is documented, of course.  Set PRED_NON_SYSCALL in the
+	 * switch_stack on the original stack so it will unwind correctly when
+	 * unwind.c reads pt_regs.
+	 *
+	 * thread.ksp is updated to point to the synthesized switch_stack.
+	 */
+	p -=3D sizeof(struct switch_stack);
+	old_sw =3D (struct switch_stack *)p;
+	memcpy(old_sw, sw, sizeof(*sw));
+	old_sw->caller_unat =3D old_unat;
+	old_sw->ar_fpsr =3D old_regs->ar_fpsr;
+	copy_reg(&ms->pmsa_gr[4-1], ms->pmsa_nat_bits, &old_sw->r4, &old_unat);
+	copy_reg(&ms->pmsa_gr[5-1], ms->pmsa_nat_bits, &old_sw->r5, &old_unat);
+	copy_reg(&ms->pmsa_gr[6-1], ms->pmsa_nat_bits, &old_sw->r6, &old_unat);
+	copy_reg(&ms->pmsa_gr[7-1], ms->pmsa_nat_bits, &old_sw->r7, &old_unat);
+	old_sw->b0 =3D (u64)ia64_leave_kernel;
+	old_sw->b1 =3D ms->pmsa_br1;
+	old_sw->ar_pfs =3D 0;
+	old_sw->ar_unat =3D old_unat;
+	old_sw->pr =3D old_regs->pr | (1UL << PRED_NON_SYSCALL);
+	previous_current->thread.ksp =3D (u64)p - 16;
+
+	/* Finally copy the original stack's registers back to its RBS.
+	 * Registers from ar.bspstore through ar.bsp at the time of the event
+	 * are in the current RBS, copy them back to the original stack.  The
+	 * copy must be done register by register because the original bspstore
+	 * and the current one have different alignments, so the saved RNAT
+	 * data occurs at different places.
+	 *
+	 * mca_asm does cover, so the old_bsp already includes all registers at
+	 * the time of MCA/INIT.  It also does flushrs, so all registers before
+	 * this function have been written to backing store on the MCA/INIT
+	 * stack.
+	 */
+	new_rnat =3D ia64_get_rnat(ia64_rse_rnat_addr(new_bspstore));
+	old_rnat =3D regs->ar_rnat;
+	while (slots--) {
+		if (ia64_rse_is_rnat_slot(new_bspstore)) {
+			new_rnat =3D ia64_get_rnat(new_bspstore++);
+		}
+		if (ia64_rse_is_rnat_slot(old_bspstore)) {
+			*old_bspstore++ =3D old_rnat;
+			old_rnat =3D 0;
+		}
+		nat =3D (new_rnat >> ia64_rse_slot_num(new_bspstore)) & 1UL;
+		old_rnat &=3D ~(1UL << ia64_rse_slot_num(old_bspstore));
+		old_rnat |=3D (nat << ia64_rse_slot_num(old_bspstore));
+		*old_bspstore++ =3D *new_bspstore++;
+	}
+	old_sw->ar_bspstore =3D (unsigned long)old_bspstore;
+	old_sw->ar_rnat =3D old_rnat;
+
+	sos->prev_task =3D previous_current;
+	return previous_current;
+
+no_mod:
+	printk(KERN_INFO "cpu %d, %s %s, original stack not modified\n",
+			smp_processor_id(), type, msg);
+	return previous_current;
+}
+
+/* The monarch/slave interaction is based on monarch_cpu and requires that=
 all
+ * slaves have entered rendezvous before the monarch leaves.  If any cpu h=
as
+ * not entered rendezvous yet then wait a bit.  The assumption is that any
+ * slave that has not rendezvoused after a reasonable time is never going =
to do
+ * so.  In this context, slave includes cpus that respond to the MCA rende=
zvous
+ * interrupt, as well as cpus that receive the INIT slave event.
+ */
+
+static void
+ia64_wait_for_slaves(int monarch)
+{
+	int c, wait =3D 0;
+	for_each_online_cpu(c) {
+		if (c =3D monarch)
+			continue;
+		if (ia64_mc_info.imi_rendez_checkin[c] =3D IA64_MCA_RENDEZ_CHECKIN_NOTDO=
NE) {
+			udelay(1000);		/* short wait first */
+			wait =3D 1;
+			break;
+		}
+	}
+	if (!wait)
+		return;
+	for_each_online_cpu(c) {
+		if (c =3D monarch)
+			continue;
+		if (ia64_mc_info.imi_rendez_checkin[c] =3D IA64_MCA_RENDEZ_CHECKIN_NOTDO=
NE) {
+			udelay(5*1000000);	/* wait 5 seconds for slaves (arbitrary) */
+			break;
+		}
+	}
+}
+
+static void
+mca_init_leave(int cpu)
+{
+	 while (cmpxchg_acq(&ia64_mca_init_leave, -1, cpu) !=3D -1)
+		 cpu_relax();
+}
+
 /*
- * ia64_mca_ucmc_handler
+ * ia64_mca_handler
  *
  *	This is uncorrectable machine check handler called from OS_MCA
  *	dispatch code which is in turn called from SAL_CHECK().
@@ -866,16 +926,28 @@ EXPORT_SYMBOL(ia64_unreg_MCA_extension);
  *	further MCA logging is enabled by clearing logs.
  *	Monarch also has the duty of sending wakeup-IPIs to pull the
  *	slave processors out of rendezvous spinloop.
- *
- *  Inputs  :   None
- *  Outputs :   None
  */
 void
-ia64_mca_ucmc_handler(void)
+ia64_mca_handler(struct pt_regs *regs, struct switch_stack *sw,
+		 struct ia64_sal_os_state *sos)
 {
 	pal_processor_state_info_t *psp =3D (pal_processor_state_info_t *)
-		&ia64_sal_to_os_handoff_state.proc_state_param;
-	int recover;=20
+		&sos->proc_state_param;
+	int recover, cpu =3D smp_processor_id();
+	task_t *previous_current;
+
+	oops_in_progress =3D 1;	/* FIXME: make printk NMI/MCA/INIT safe */
+	previous_current =3D ia64_mca_modify_original_stack(regs, sw, sos, "MCA");
+	monarch_cpu =3D cpu;
+	ia64_wait_for_slaves(cpu);
+
+	/* Wakeup all the processors which are spinning in the rendezvous loop.
+	 * They will leave SAL, then spin in the OS with interrupts disabled
+	 * until this monarch cpu leaves the MCA handler.  That gets control
+	 * back to the OS so we can backtrace the other cpus, backtrace when
+	 * spinning in SAL does not work.
+	 */
+	ia64_mca_wakeup_all();
=20
 	/* Get the MCA error record and log it */
 	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_MCA);
@@ -883,25 +955,21 @@ ia64_mca_ucmc_handler(void)
 	/* TLB error is only exist in this SAL error record */
 	recover =3D (psp->tc && !(psp->cc || psp->bc || psp->rc || psp->uc))
 	/* other error recovery */
-	   || (ia64_mca_ucmc_extension=20
+	   || (ia64_mca_ucmc_extension
 		&& ia64_mca_ucmc_extension(
 			IA64_LOG_CURR_BUFFER(SAL_INFO_TYPE_MCA),
-			&ia64_sal_to_os_handoff_state,
-			&ia64_os_to_sal_handoff_state));=20
+			sos));
=20
 	if (recover) {
 		sal_log_record_header_t *rh =3D IA64_LOG_CURR_BUFFER(SAL_INFO_TYPE_MCA);
 		rh->severity =3D sal_log_severity_corrected;
 		ia64_sal_clear_state_info(SAL_INFO_TYPE_MCA);
+		sos->os_status =3D IA64_MCA_CORRECTED;
 	}
-	/*
-	 *  Wakeup all the processors which are spinning in the rendezvous
-	 *  loop.
-	 */
-	ia64_mca_wakeup_all();
=20
-	/* Return to SAL */
-	ia64_return_to_sal_check(recover);
+	set_curr_task(cpu, previous_current);
+	mca_init_leave(cpu);
+	monarch_cpu =3D -1;
 }
=20
 static DECLARE_WORK(cmc_disable_work, ia64_mca_cmc_vector_disable_keventd,=
 NULL);
@@ -1125,34 +1193,87 @@ ia64_mca_cpe_poll (unsigned long dummy)
 /*
  * C portion of the OS INIT handler
  *
- * Called from ia64_monarch_init_handler
- *
- * Inputs: pointer to pt_regs where processor info was saved.
- *
- * Returns:
- *   0 if SAL must warm boot the System
- *   1 if SAL must return to interrupted context using PAL_MC_RESUME
+ * Called from ia64_os_init_dispatch
  *
+ * Inputs: pointer to pt_regs where processor info was saved.  SAL/OS stat=
e for
+ * this event.  This code is used for both monarch and slave INIT events, =
see
+ * sos->monarch.
+ *
+ * All INIT events switch to the INIT stack and change the previous proces=
s to
+ * blocked status.  If one of the INIT events is the monarch then we are
+ * probably processing the nmi button/command.  Use the monarch cpu to dum=
p all
+ * the processes.  The slave INIT events all spin until the monarch cpu
+ * returns.  We can also get INIT slave events for MCA, in which case the =
MCA
+ * process is the monarch.
  */
+
 void
-ia64_init_handler (struct pt_regs *pt, struct switch_stack *sw)
+ia64_init_handler(struct pt_regs *regs, struct switch_stack *sw,
+		  struct ia64_sal_os_state *sos)
 {
-	pal_min_state_area_t *ms;
+	task_t *previous_current;
+	int cpu =3D smp_processor_id(), c;
+	struct task_struct *g, *t;
=20
-	oops_in_progress =3D 1;	/* avoid deadlock in printk, but it makes recover=
y dodgy */
+	oops_in_progress =3D 1;	/* FIXME: make printk NMI/MCA/INIT safe */
 	console_loglevel =3D 15;	/* make sure printks make it to console */
=20
 	printk(KERN_INFO "Entered OS INIT handler. PSP=3D%lx\n",
-		ia64_sal_to_os_handoff_state.proc_state_param);
+		sos->proc_state_param);
+	salinfo_log_wakeup(SAL_INFO_TYPE_INIT, NULL, 0, 0);
+
+	previous_current =3D ia64_mca_modify_original_stack(regs, sw, sos, "INIT"=
);
+	sos->os_status =3D IA64_INIT_RESUME;
+	if (!sos->monarch) {
+		ia64_mc_info.imi_rendez_checkin[cpu] =3D IA64_MCA_RENDEZ_CHECKIN_INIT;
+		while (monarch_cpu =3D -1)
+		       cpu_relax();	/* spin until monarch enters */
+		while (monarch_cpu !=3D -1)
+		       cpu_relax();	/* spin until monarch leaves */
+		printk("slave returning %d\n", cpu);
+		set_curr_task(cpu, previous_current);
+		mca_init_leave(cpu);
+		ia64_mc_info.imi_rendez_checkin[cpu] =3D IA64_MCA_RENDEZ_CHECKIN_NOTDONE;
+		return;
+	}
+
+	monarch_cpu =3D cpu;
=20
 	/*
-	 * Address of minstate area provided by PAL is physical,
-	 * uncacheable (bit 63 set). Convert to Linux virtual
-	 * address in region 6.
+	 * Wait for a bit.  On some machines (e.g., HP's zx2000 and zx6000, INIT =
can be
+	 * generated via the BMC's command-line interface, but since the console =
is on the
+	 * same serial line, the user will need some time to switch out of the BM=
C before
+	 * the dump begins.
 	 */
-	ms =3D (pal_min_state_area_t *)(ia64_sal_to_os_handoff_state.pal_min_stat=
e | (6ul<<61));
-
-	init_handler_platform(ms, pt, sw);	/* call platform specific routines */
+	printk("Delaying for 5 seconds...\n");
+	udelay(5*1000000);
+	ia64_wait_for_slaves(cpu);
+	printk(KERN_ERR "Processes interrupted by INIT -");
+	for_each_online_cpu(c) {
+		struct ia64_sal_os_state *s;
+		t =3D __va(__per_cpu_mca[c] + IA64_MCA_CPU_INIT_STACK_OFFSET);
+		s =3D (struct ia64_sal_os_state *)((char *)t + MCA_SOS_OFFSET);
+		g =3D s->prev_task;
+		if (g) {
+			if (g->pid)
+				printk(" %d", g->pid);
+			else
+				printk(" %d (cpu %d task 0x%p)", g->pid, task_cpu(g), g);
+		}
+	}
+	printk("\n\n");
+	if (read_trylock(&tasklist_lock)) {
+		do_each_thread (g, t) {
+			printk("\nBacktrace of pid %d (%s)\n", t->pid, t->comm);
+			show_stack(t, NULL);
+		} while_each_thread (g, t);
+		read_unlock(&tasklist_lock);
+	}
+	printk("\nINIT dump complete.  Monarch on cpu %d returning to normal serv=
ice.\n", cpu);
+	set_curr_task(cpu, previous_current);
+	mca_init_leave(cpu);
+	monarch_cpu =3D -1;
+	return;
 }
=20
 static int __init
@@ -1202,6 +1323,34 @@ static struct irqaction mca_cpep_irqacti
 };
 #endif /* CONFIG_ACPI */
=20
+/* Minimal format of the MCA/INIT stacks.  The pseudo processes that run on
+ * these stacks can never sleep, they cannot return from the kernel to user
+ * space, they do not appear in a normal ps listing.  So there is no need =
to
+ * format most of the fields.
+ */
+
+static void
+format_mca_init_stack(void *mca_data, unsigned long offset,
+		const char *type, int cpu)
+{
+	struct task_struct *p =3D (struct task_struct *)((char *)mca_data + offse=
t);
+	struct thread_info *ti;
+	memset(p, 0, KERNEL_STACK_SIZE);
+	ti =3D (struct thread_info *)((char *)p + IA64_TASK_SIZE);
+	ti->flags =3D _TIF_MCA_INIT;
+	ti->preempt_count =3D 1;
+	ti->task =3D p;
+	ti->cpu =3D cpu;
+	p->thread_info =3D ti;
+	p->state =3D TASK_UNINTERRUPTIBLE;
+	__set_bit(cpu, &p->cpus_allowed);
+	INIT_LIST_HEAD(&p->tasks);
+	p->parent =3D p->real_parent =3D p->group_leader =3D p;
+	INIT_LIST_HEAD(&p->children);
+	INIT_LIST_HEAD(&p->sibling);
+	strncpy(p->comm, type, sizeof(p->comm)-1);
+}
+
 /* Do per-CPU MCA-related initialization.  */
=20
 void __devinit
@@ -1214,19 +1363,28 @@ ia64_mca_cpu_init(void *cpu_data)
 		int cpu;
=20
 		mca_data =3D alloc_bootmem(sizeof(struct ia64_mca_cpu)
-					 * NR_CPUS);
+					 * NR_CPUS + KERNEL_STACK_SIZE);
+		mca_data =3D (void *)(((unsigned long)mca_data +
+					KERNEL_STACK_SIZE - 1) &
+				(-KERNEL_STACK_SIZE));
 		for (cpu =3D 0; cpu < NR_CPUS; cpu++) {
+			format_mca_init_stack(mca_data,
+					offsetof(struct ia64_mca_cpu, mca_stack),
+					"MCA", cpu);
+			format_mca_init_stack(mca_data,
+					offsetof(struct ia64_mca_cpu, init_stack),
+					"INIT", cpu);
 			__per_cpu_mca[cpu] =3D __pa(mca_data);
 			mca_data +=3D sizeof(struct ia64_mca_cpu);
 		}
 	}
=20
-        /*
-         * The MCA info structure was allocated earlier and its
-         * physical address saved in __per_cpu_mca[cpu].  Copy that
-         * address * to ia64_mca_data so we can access it as a per-CPU
-         * variable.
-         */
+	/*
+	 * The MCA info structure was allocated earlier and its
+	 * physical address saved in __per_cpu_mca[cpu].  Copy that
+	 * address * to ia64_mca_data so we can access it as a per-CPU
+	 * variable.
+	 */
 	__get_cpu_var(ia64_mca_data) =3D __per_cpu_mca[smp_processor_id()];
=20
 	/*
@@ -1236,11 +1394,11 @@ ia64_mca_cpu_init(void *cpu_data)
 	__get_cpu_var(ia64_mca_per_cpu_pte)  		pte_val(mk_pte_phys(__pa(cpu_data)=
, PAGE_KERNEL));
=20
-        /*
-         * Also, stash away a copy of the PAL address and the PTE
-         * needed to map it.
-         */
-        pal_vaddr =3D efi_get_pal_addr();
+	/*
+	 * Also, stash away a copy of the PAL address and the PTE
+	 * needed to map it.
+	 */
+	pal_vaddr =3D efi_get_pal_addr();
 	if (!pal_vaddr)
 		return;
 	__get_cpu_var(ia64_mca_pal_base) @@ -1272,8 +1430,8 @@ ia64_mca_cpu_init(=
void *cpu_data)
 void __init
 ia64_mca_init(void)
 {
-	ia64_fptr_t *mon_init_ptr =3D (ia64_fptr_t *)ia64_monarch_init_handler;
-	ia64_fptr_t *slave_init_ptr =3D (ia64_fptr_t *)ia64_slave_init_handler;
+	ia64_fptr_t *init_hldlr_ptr_monarch =3D (ia64_fptr_t *)ia64_os_init_dispa=
tch_monarch;
+	ia64_fptr_t *init_hldlr_ptr_slave =3D (ia64_fptr_t *)ia64_os_init_dispatc=
h_slave;
 	ia64_fptr_t *mca_hldlr_ptr =3D (ia64_fptr_t *)ia64_os_mca_dispatch;
 	int i;
 	s64 rc;
@@ -1351,9 +1509,9 @@ ia64_mca_init(void)
 	 * XXX - disable SAL checksum by setting size to 0, should be
 	 * size of the actual init handler in mca_asm.S.
 	 */
-	ia64_mc_info.imi_monarch_init_handler		=3D ia64_tpa(mon_init_ptr->fp);
+	ia64_mc_info.imi_monarch_init_handler		=3D ia64_tpa(init_hldlr_ptr_monarc=
h->fp);
 	ia64_mc_info.imi_monarch_init_handler_size	=3D 0;
-	ia64_mc_info.imi_slave_init_handler		=3D ia64_tpa(slave_init_ptr->fp);
+	ia64_mc_info.imi_slave_init_handler		=3D ia64_tpa(init_hldlr_ptr_slave->f=
p);
 	ia64_mc_info.imi_slave_init_handler_size	=3D 0;
=20
 	IA64_MCA_DEBUG("%s: OS INIT handler at %lx\n", __FUNCTION__,
