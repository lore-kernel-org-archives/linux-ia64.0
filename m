From: Keith Owens <kaos@sgi.com>
Date: Tue, 15 Feb 2005 02:49:51 +0000
Subject: [RFC] Use separate MCA/INIT stacks
Message-Id: <13813.1108435791@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

The changeover to per cpu MCA/INIT stacks appears to be working.
However we still treat them as if we had one MCA stack and no INIT
stack, IOW we are still restricted to one MCA or INIT event at a time.
The (incomplete and work in progress) patch below aims to really use
the per cpu MCA/INIT stacks, my target is :-

* Handle concurrent MCA events on multiple cpus.
* Handle concurrent INIT events on multiple cpus, both monarch and
  slave.
* Cope with nested events, to diagnose MCA events in INIT handlers.
* Give decent traceback through MCA and INIT events, for both online
  (kdb, gdb) and after the event (lcrash) diagnosis.
* Recover from INIT as well as MCA events.  This includes INIT events
  that were sent because an MCA hit some disabled cpus.

Although the patch is incomplete, it will compile.  It is big enough
and there are enough unanswered questions that I am throwing this open
for abuse^Wreview.  Ignore the restore path for returning to the
original stack, that will be filled in once the entry path is
satisfactory.

The patch is bigger than I wanted because I had to remove the static
SAL to OS and OS to SAL states, making them per event instead.  That
caused a lot of small changes in mca.c and mca_drv.c, to pass the
structure instead of using a single static version.  There is enough
overlap between SAL to OS and OS to SAL to make it worth consolidating
them into a single SAL/OS state structure.

proc_state_dump has gone completely.  The MCA/INIT handler should only
need to save the registers that the kernel changes, IOW struct pt_regs
is all that is required.  There may be a couple of other variables that
need to be saved, such as previous values of the IA64_KR registers,
those still need to be added.

The rse_ variables and macros have been removed, together with the
separate stackframe.  They are replaced by the standard RBS switch
information in struct pt_regs.

Outstanding questions:

* What does "current" mean when we have normal stacks plus MCA and INIT
  stacks?  Does current point to the original stack, or does it point
  to the current MCA/INIT stack.  My preference is to point current at
  the current MCA/INIT stack, if that means copying the current state
  from the previous stack then so be it.

* Does the MCA/INIT stack need to be wired into IA64_KR_CURRENT_STACK
  and IA64_TR_CURRENT_STACK?  If it does, what happens to access to the
  original stack?

* Does the code in ia64_pt_regs_save() look sensible?  In particular
  are the NaT handling and the RBS switch correct?

Still to do: The INIT path.  Unwinding.  Finish the restore path.

 arch/ia64/kernel/asm-offsets.c |   40 +
 arch/ia64/kernel/mca.c         |   65 --
 arch/ia64/kernel/mca_asm.S     | 1045 +++++++++++++++++-------------------=
-----
 arch/ia64/kernel/mca_drv.c     |   37 -
 include/asm-ia64/mca.h         |   62 +-
 include/asm-ia64/mca_asm.h     |  128 +----
 6 files changed, 571 insertions(+), 806 deletions(-)

Index: linux/include/asm-ia64/mca.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig/include/asm-ia64/mca.h	2005-02-15 13=
:27:38.000000000 +1100
+++ linux/include/asm-ia64/mca.h	2005-02-15 13:27:42.000000000 +1100
@@ -11,8 +11,6 @@
 #ifndef _ASM_IA64_MCA_H
 #define _ASM_IA64_MCA_H
=20
-#define IA64_MCA_STACK_SIZE	8192
-
 #if !defined(__ASSEMBLY__)
=20
 #include <linux/interrupt.h>
@@ -63,18 +61,26 @@ typedef struct ia64_mc_info_s {
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
+ * Note: mca_asm.S depends on the precise layout of this structure.
+ */
+
+struct ia64_sal_os_state {
+	/* SAL to OS, must be at offset 0 */
+	u64			os_gp;			/* GP of the os registered with the SAL, physical */
+	u64			pal_proc;		/* PAL_PROC entry point, physical */
+	u64			sal_proc;		/* SAL_PROC entry point, physical */
+	u64			rendez_state;		/* Rendez state information */
+	u64			proc_state_param;	/* from R18 */
+	/* common, must follow SAL to OS */
+	u64			sal_ra;			/* Return address in SAL, physical */
+	u64			sal_gp;			/* GP of the SAL - physical */
+	pal_min_state_area_t	*pal_min_state;		/* from R17.  physical in asm, virt=
ual in C */
+	/* OS to SAL, must follow common */
+	u64			os_status;		/* OS status to SAL, enum below */
+	u64			context;		/* 0 if return to same context
+							   1 if return to new context */
+};
=20
 enum {
 	IA64_MCA_CORRECTED	=3D	0x0,	/* Error has been corrected by OS_MCA */
@@ -88,29 +94,10 @@ enum {
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
 } __attribute__ ((aligned(16)));
=20
@@ -121,11 +108,14 @@ extern void ia64_mca_init(void);
 extern void ia64_mca_cpu_init(void *);
 extern void ia64_os_mca_dispatch(void);
 extern void ia64_os_mca_dispatch_end(void);
-extern void ia64_mca_ucmc_handler(void);
+extern void ia64_mca_ucmc_handler(struct ia64_sal_os_state *);
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
=20
 #endif /* !__ASSEMBLY__ */
Index: linux/arch/ia64/kernel/mca_asm.S
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig/arch/ia64/kernel/mca_asm.S	2005-02-1=
5 13:27:38.000000000 +1100
+++ linux/arch/ia64/kernel/mca_asm.S	2005-02-15 13:27:42.000000000 +1100
@@ -16,6 +16,9 @@
 // 04/11/12 Russ Anderson <rja@sgi.com>
 //		   Added per cpu MCA/INIT stack save areas.
 //
+// 05/02/13 Keith Owens <kaos@sgi.com>
+//		   Use per cpu MCA/INIT stack save areas for all data.
+//
 #include <linux/config.h>
 #include <linux/threads.h>
=20
@@ -39,68 +42,6 @@
=20
 #include "minstate.h"
=20
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
-
 #define GET_IA64_MCA_DATA(reg)						\
 	GET_THIS_PADDR(reg, ia64_mca_data)				\
 	;;								\
@@ -108,14 +49,12 @@
=20
 	.global ia64_os_mca_dispatch
 	.global ia64_os_mca_dispatch_end
-	.global ia64_sal_to_os_handoff_state
-	.global	ia64_os_to_sal_handoff_state
=20
 	.text
 	.align 16
=20
 ia64_os_mca_dispatch:
-
+	.prologue
 	// Serialize all MCA processing
 	mov	r3=3D1;;
 	LOAD_PHYSICAL(p0,r2,ia64_mca_serialize);;
@@ -124,24 +63,17 @@ ia64_os_mca_spin:
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
+	movl r2=1F				// return address
+	mov r3=3DIA64_MCA_CPU_MCA_STACK_OFFSET	// use the MCA stack
+	br.sptk ia64_sal_os_state_save		// save the SAL to OS MCA handoff state
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
@@ -305,65 +237,56 @@ begin_tlb_purge_and_reload:
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
-
-	GET_IA64_MCA_DATA(r2)
-	;;
-	add r2 =3D IA64_MCA_CPU_STACK_OFFSET+IA64_MCA_STACK_SIZE-16, r2
-	;;
-	mov r12=3Dr2		// establish new stack-pointer
+	// create struct pt_regs from min_state, switch stack
+	movl r2=1F				// return address
+	mov r3=3DIA64_MCA_CPU_MCA_STACK_OFFSET	// use the MCA stack
+	br.sptk ia64_pt_regs_save
+1:
+
+	// everything saved, now we can set the kernel registers
+	movl r2=1F				// return address
+	mov r3=3DIA64_MCA_CPU_MCA_STACK_OFFSET	// use the MCA stack
+	br.sptk ia64_set_kernel_registers
+1:
=20
         // Enter virtual mode from physical mode
 	VIRTUAL_MODE_ENTER(r2, r3, ia64_os_mca_virtual_begin, r4)
 ia64_os_mca_virtual_begin:
=20
-	// Call virtual mode handler
-	movl		r2=3Dia64_mca_ucmc_handler;;
-	mov		b6=3Dr2;;
-	br.call.sptk.many    b0=B6;;
-.ret0:
-	// Revert back to physical mode before going back to SAL
-	PHYSICAL_MODE_ENTER(r2, r3, ia64_os_mca_virtual_end, r4)
-ia64_os_mca_virtual_end:
+	mov ar.rsc=3D3				// set eager mode for C handler
=20
-	// restore the original stack frame here
+	// Call virtual mode handler
+	alloc r14=3Dar.pfs,0,0,1,0
+	.body
 	GET_IA64_MCA_DATA(r2)
 	;;
-	add r2 =3D IA64_MCA_CPU_STACKFRAME_OFFSET, r2
-	;;
-	movl    r4=3DIA64_PSR_MC
+	add out0=3DIA64_MCA_CPU_MCA_STACK_OFFSET+MCA_SOS_OFFSET, r2
 	;;
-	rse_return_context(r4,r3,r2)	// switch from interrupt context for RSE
+	DATA_PA_TO_VA(out0,r2)
+	br.call.sptk.many    b0=3Dia64_mca_ucmc_handler;;
=20
-	// let us restore all the registers from our PSI structure
-	mov	r8=3Dgp
-	;;
-begin_os_mca_restore:
-	br	ia64_os_mca_proc_state_restore;;
+	// Revert back to physical mode before going back to SAL
+	PHYSICAL_MODE_ENTER(r2, r3, ia64_os_mca_virtual_end, r4)
+ia64_os_mca_virtual_end:
=20
-ia64_os_mca_done_restore:
-	OS_MCA_TO_SAL_HANDOFF_STATE_RESTORE(r2);;
-	// branch back to SALE_CHECK
-	ld8		r3=3D[r2];;
-	mov		b0=3Dr3;;		// SAL_CHECK return address
+	// restore struct pt_regs (kernel modified registers), switch back to
+	// previous stack
+	movl r2=1F				// return address
+	mov r3=3DIA64_MCA_CPU_MCA_STACK_OFFSET	// use the MCA stack
+	br.sptk ia64_pt_regs_restore
+1:
+
+	movl r2=1F				// return address
+	mov r3=3DIA64_MCA_CPU_MCA_STACK_OFFSET	// use the MCA stack
+	br.sptk ia64_sal_os_state_restore	// restore the SAL to OS MCA handoff st=
ate
+1:
+	mov		b0=3Dr12;;		// SAL_CHECK return address
=20
 	// release lock
-	movl		r3=3Dia64_mca_serialize;;
-	DATA_VA_TO_PA(r3);;
+	LOAD_PHYSICAL(p0,r3,ia64_mca_serialize);;
 	st8.rel		[r3]=3Dr0
=20
 	br		b0
@@ -374,471 +297,403 @@ ia64_os_mca_dispatch_end:
=20
 //++
 // Name:
-//      ia64_os_mca_proc_state_dump()
+//      ia64_sal_os_state_save()
 //
 // Stub Description:
 //
-//       This stub dumps the processor state during MCHK to a data area
+//       Save the SAL/OS state.  This is sensitive to the layout of struct
+//       ia64_sal_os_state in mca.h.
+//
+//       r2 contains the return address, r3 contains either
+//       IA64_MCA_CPU_MCA_STACK_OFFSET or IA64_MCA_CPU_INIT_STACK_OFFSET.
+//
+//       The OS to SAL section of struct ia64_sal_os_state is set to a def=
ault
+//       value of cold boot and return to the same context.
 //
 //--
=20
-ia64_os_mca_proc_state_dump:
-// Save bank 1 GRs 16-31 which will be used by c-language code when we swi=
tch
-//  to virtual addressing mode.
+ia64_sal_os_state_save:
+	mov b0=3Dr2		// save return address
 	GET_IA64_MCA_DATA(r2)
+	add r3=3DMCA_SOS_OFFSET, r3
+	;;
+	add r3=3Dr2, r3		// struct ia64_sal_os_state on MCA or INIT stack
+	;;
+	st8 [r3]=3Dr1,8		// OS GP, physical
+	;;
+	st8 [r3]=3Dr8,8		// PAL_PROC, physical
+	;;
+	st8 [r3]=3Dr9,8		// SAL_PROC, physical
+	;;
+	st8 [r3]=3Dr11,8		// rendezvous state
+	;;
+	st8 [r3]=3Dr18,8		// processor state parameter
+	;;
+	st8 [r3]=3Dr12,8		// SAL return address, physical
+	;;
+	st8 [r3]=3Dr10,8		// SAL GP, physical
+	;;
+	st8 [r3]=3Dr17,8		// PAL min_state, physical in asm, virtual in C
+	mov r6=3DIA64_MCA_COLD_BOOT
 	;;
-	add r2 =3D IA64_MCA_CPU_PROC_STATE_DUMP_OFFSET, r2
+	st8 [r3]=3Dr6,8		// set default OS status
+	mov r7=3DIA64_MCA_SAME_CONTEXT
 	;;
-// save ar.NaT
-	mov		r5=3Dar.unat                  // ar.unat
+	st8 [r3]=3Dr7,8		// set default OS context
+	br.sptk b0
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
+//EndStub/////////////////////////////////////////////////////////////////=
/////
+
+
+//++
+// Name:
+//      ia64_sal_os_state_restore()
+//
+// Stub Description:
+//
+//       Restore the SAL/OS state.  This is sensitive to the layout of str=
uct
+//       ia64_sal_os_state in mca.h.
+//
+//       r2 contains the return address, r3 contains either
+//       IA64_MCA_CPU_MCA_STACK_OFFSET or IA64_MCA_CPU_INIT_STACK_OFFSET.
+//
+//--
+
+ia64_sal_os_state_restore:
+	mov b0=3Dr2		// save return address
+	GET_IA64_MCA_DATA(r2)
+	add r3=3DMCA_SOS_OFFSET+IA64_SAL_OS_STATE_COMMON_OFFSET, r3
+	;;
+	add r3=3Dr2, r3		// common struct ia64_sal_os_state on MCA or INIT stack
+	;;
+	ld8 r12=3D[r3],8		// SAL return address, physical
+	;;
+	ld8 r9=3D[r3],8		// SAL GP, physical
+	;;
+	ld8 r22=3D[r3],8		// pal_min_state
+	;;
+	ld8 r8=3D[r3],8		// OS status
 	;;
-end_os_mca_dump:
-	br	ia64_os_mca_done_dump;;
+	ld8 r10=3D[r3],8		// OS context
+	br.sptk b0
=20
 //EndStub/////////////////////////////////////////////////////////////////=
/////
=20
=20
 //++
 // Name:
-//       ia64_os_mca_proc_state_restore()
+//	ia64_pt_regs_save()
 //
 // Stub Description:
 //
-//       This is a stub to restore the saved processor state during MCHK
+//	Create a struct pt_regs from the current registers plus the contents
+//	of pal_min_state.
 //
+//	r2 contains the return address, r3 contains either
+//	IA64_MCA_CPU_MCA_STACK_OFFSET or IA64_MCA_CPU_INIT_STACK_OFFSET.
+//
+//	On entry, sos->pal_min_state is physical, on exit it is virtual.
+//
+//	On entry RBS is still on the original stack, this routine switches RBS
+//	to use the MCA/INIT stack.  MCA/INIT handlers are entered in RSE lazy
+//	mode, with cover already issued.
+//=09
 //--
=20
-ia64_os_mca_proc_state_restore:
+#define	ms		r4
+#define	regs		r5
+#define	save_unat	r6
+#define	temp1		r2	/* careful, it overlaps with input registers */
+#define	temp2		r3	/* careful, it overlaps with input registers */
+#define	temp3		r7
+#define	temp4		r8
=20
-// Restore bank1 GR16-31
+ia64_pt_regs_save:
+	add regs=3DMCA_PT_REGS_OFFSET, r3
+	add temp2=3DMCA_SOS_OFFSET+IA64_SAL_OS_STATE_PAL_MIN_STATE_OFFSET, r3
+	mov b0=3Dr2		// save return address
+	GET_IA64_MCA_DATA(temp1)
+	;;
+	add temp2=3Dtemp2, temp1	// struct ia64_sal_os_state.pal_min_state on MCA=
 or INIT stack
+	add regs=3Dregs, temp1	// struct pt_regs on MCA or INIT stack
+	;;
+	// Address of minstate area provided by PAL is physical, uncacheable.
+	// Convert to Linux virtual address in region 6 for C code.
+	ld8 ms=3D[temp2]		// pal_min_state, physical
+	;;
+	dep temp1=3D-1,ms,62,2	// set region 6
+	;;
+	st8 [temp2]=3Dtemp1	// pal_min_state, virtual
+
+	// copy the ar, cr, pr, br entries
+	add temp1=3DIA64_PMSA_PR_OFFSET, ms
+	add temp2=3DIA64_PT_REGS_PR_OFFSET, regs
+	;;
+	ld8 temp3=3D[temp1],8			// pmsa_pr
+	;;
+	st8 [temp2]=3Dtemp3
+	add temp2=3DIA64_PT_REGS_B0_OFFSET, regs
+	ld8 temp4=3D[temp1],8			// pmsa_br0
+	;;
+	st8 [temp2]=3Dtemp4
+	add temp2=3DIA64_PT_REGS_AR_RSC_OFFSET, regs
+	ld8 temp3=3D[temp1],8			// pmsa_rsc
+	;;
+	st8 [temp2]=3Dtemp3
+	// if ipsr.ic then use pmsa_{iip,ipsr,ifs}, else use pmsa_{xip,xpsr,xfs}
+	// we just copied pmsa_rsc, so temp1 contains &pmsa_iip.
+	add temp2=3DIA64_PMSA_IPSR_OFFSET, ms
+	;;
+	ld8 temp3=3D[temp2]			// pmsa_ipsr
+	;;
+	tbit.z p6,p0=3Dtemp3, 13			// test ipsr.ic
+	;;
+(p6)	add temp1=3DIA64_PMSA_XIP_OFFSET-IA64_PMSA_IIP_OFFSET, temp1
+	;;
+	ld8 temp3=3D[temp1],8			// save iip or xip
+	add temp2=3DIA64_PT_REGS_CR_IIP_OFFSET, regs
+	;;
+	st8 [temp2]=3Dtemp3
+	ld8 temp4=3D[temp1],8			// save ispr or xpsr
+	add temp2=3DIA64_PT_REGS_CR_IPSR_OFFSET, regs
+	;;
+	st8 [temp2]=3Dtemp4
+	ld8 temp3=3D[temp1],8			// save ifs or xfs
+	add temp2=3DIA64_PT_REGS_CR_IFS_OFFSET, regs
+	;;
+	st8 [temp2]=3Dtemp3
+	mov temp3=3Dar.unat
+	add temp2=3DIA64_PT_REGS_AR_UNAT_OFFSET, regs
+	;;
+	st8 [temp2]=3Dtemp3			// save ar.unat
+	mov temp3=3Dar.pfs
+	add temp2=3DIA64_PT_REGS_AR_PFS_OFFSET, regs
+	;;
+	st8 [temp2]=3Dtemp3			// save ar.pfs
+	mov temp3=3Dar.bspstore
+	add temp2=3DIA64_PT_REGS_AR_BSPSTORE_OFFSET, regs
+	;;
+	extr.u temp4=3Dtemp3, 61, 3		// region from old ar.bspstore=20
+	;;
+	cmp.ne p6,p0=3Dtemp4, r0			// is old ar.bspstore a virtual address?
+(p6)	br.cond.dpnt 1f
+	DATA_PA_TO_VA(temp3,temp4)		// no, C code needs a virtual address
+	;;
+1:	st8 [temp2]=3Dtemp3			// save ar.bspstore
+	mov temp3=3Dar.rnat
+	add temp2=3DIA64_PT_REGS_AR_RNAT_OFFSET, regs
+	;;
+	st8 [temp2]=3Dtemp3			// save ar.rnat
+	mov temp1=3D-MCA_PT_REGS_OFFSET+IA64_RBS_OFFSET
+	;;
+	add temp1=3Dtemp1, regs			// step to RBS offset in current stack
+	add temp2=3DIA64_PT_REGS_LOADRS_OFFSET, regs
+	;;
+	mov ar.bspstore=3Dtemp1			// switch RBS to MCA/INIT stack
+	;;
+	mov temp3=3Dar.bsp
+	;;
+	sub temp3=3Dtemp3, temp1			// ar.bsp - ar.bspstore
+	;;
+	shl temp3=3Dtemp3,16			// compute ar.rsc to be used for "loadrs"
+	;;
+	st8 [temp2]=3Dtemp3			// save loadrs
+
+	// copy the general registers that are not done by SAVE_REST
+	mov save_unat=3Dar.unat				// save current unat
+	ld8 temp1=3D[ms]					// pmsa_nat_bits
+	;;
+	mov ar.unat=3Dtemp1				// load NaT bits for registers in pal_min_state
+	add temp1=3DIA64_PMSA_GR_OFFSET+(1-1)*8, ms	// &pal_min_state_area.pmsa_g=
r[1-1], saved GR1
+	add temp2=3DIA64_PMSA_GR_OFFSET+(2-1)*8, ms	// &pal_min_state_area.pmsa_g=
r[2-1], saved GR2
+	add temp3=3DIA64_PMSA_GR_OFFSET+(3-1)*8, ms	// &pal_min_state_area.pmsa_g=
r[3-1], saved GR3
+	;;
+	ld8.fill r1=3D[temp1]
+	ld8.fill r16=3D[temp2]				// copy r2 in r16
+	ld8.fill r17=3D[temp3]				// copy r3 in r17
+	;;
+	add temp1=3DIA64_PMSA_GR_OFFSET+(8-1)*8, ms	// &pal_min_state_area.pmsa_g=
r[8-1], saved GR8
+	add temp2=3DIA64_PMSA_GR_OFFSET+(9-1)*8, ms	// &pal_min_state_area.pmsa_g=
r[9-1], saved GR9
+	;;
+	ld8.fill r8=3D[temp1],16
+	ld8.fill r9=3D[temp2],16
+	;;
+	ld8.fill r10=3D[temp1],16
+	ld8.fill r11=3D[temp2],16
+	;;
+	ld8.fill r12=3D[temp1],16
+	ld8.fill r13=3D[temp2],16
+	;;
+	ld8.fill r14=3D[temp1]
+	ld8.fill r15=3D[temp2]
+	;;
+	mov ar.unat=3Dsave_unat				// restore current unat
+	add temp1=3DIA64_PT_REGS_R8_OFFSET, regs
+	add temp2=3DIA64_PT_REGS_R9_OFFSET, regs
+	;;
+.mem.offset 0,0; st8.spill [temp1]=3Dr8,16
+.mem.offset 8,0; st8.spill [temp2]=3Dr9,16
+	;;
+.mem.offset 0,0; st8.spill [temp1]=3Dr10
+.mem.offset 8,0; st8.spill [temp2]=3Dr11
+	;;
+	add temp1=3DIA64_PT_REGS_R1_OFFSET, regs
+	add temp2=3DIA64_PT_REGS_R12_OFFSET, regs
+	;;
+.mem.offset 0,0; st8.spill [temp1]=3Dr1
+.mem.offset 8,0; st8.spill [temp2]=3Dr12
+	;;
+	add temp1=3DIA64_PT_REGS_R13_OFFSET, regs
+	add temp2=3DIA64_PT_REGS_R14_OFFSET, regs
+	;;
+.mem.offset 0,0; st8.spill [temp1]=3Dr13
+.mem.offset 8,0; st8.spill [temp2]=3Dr14
+	;;
+	add temp1=3DIA64_PT_REGS_R15_OFFSET, regs
+	add temp2=3DIA64_PT_REGS_R2_OFFSET, regs
+	;;
+.mem.offset 0,0; st8.spill [temp1]=3Dr15
+.mem.offset 8,0; st8.spill [temp2]=3Dr16,8	// actually r2
+	;;
+	st8.spill [temp2]=3Dr17			// actually r3
+	;;
+
+	// restore bank 1 gr16-31 from pal_minstate, including NaT bits.
+	// SAVE_REST assumes that these registers are unchanged from the
+	// interrupt.
+
+	mov save_unat=3Dar.unat			// save current unat
+	ld8 temp1=3D[ms]				// pmsa_nat_bits
+	;;
+	mov ar.unat=3Dtemp1			// load NaT bits for registers in pal_min_state
+	add temp1=3DIA64_PMSA_BANK1_GR_OFFSET, ms		// &pal_min_state_area.pmsa_ba=
nk1_gr[0], saved GR16
+	add temp2=3DIA64_PMSA_BANK1_GR_OFFSET+8, ms	// &pal_min_state_area.pmsa_b=
ank1_gr[1], saved GR17
+	;;
+	ld8.fill r16=3D[temp1],16
+	ld8.fill r17=3D[temp2],16
+	;;
+	ld8.fill r18=3D[temp1],16
+	ld8.fill r19=3D[temp2],16
+	;;
+	ld8.fill r20=3D[temp1],16
+	ld8.fill r21=3D[temp2],16
+	;;
+	ld8.fill r22=3D[temp1],16
+	ld8.fill r23=3D[temp2],16
+	;;
+	ld8.fill r24=3D[temp1],16
+	ld8.fill r25=3D[temp2],16
+	;;
+	ld8.fill r26=3D[temp1],16
+	ld8.fill r27=3D[temp2],16
+	;;
+	ld8.fill r28=3D[temp1],16
+	ld8.fill r29=3D[temp2],16
+	;;
+	ld8.fill r30=3D[temp1],16
+	ld8.fill r31=3D[temp2],16
+	;;
+	mov ar.unat=3Dsave_unat			// restore current unat
+
+	// get ready for SAVE_REST
+	add temp1=3DIA64_PT_REGS_R16_OFFSET, regs
+	add temp2=3DIA64_PT_REGS_R17_OFFSET, regs
+	mov r8=3Dar.ccv
+	mov r9=3Dar.csd
+	mov r10=3Dar.ssd
+	movl r11=3DFPSR_DEFAULT
+	;;
+	SAVE_REST
+
+	br.sptk b0
+
+//EndStub/////////////////////////////////////////////////////////////////=
/////
+
+
+//++
+// Name:
+//      ia64_pt_regs_restore()
+//
+// Stub Description:
+//
+//	Restore the modified kernel registers from the struct pt_regs that was
+//	created from the entry state plus pal_min_state.
+//
+//	r2 contains the return address, r3 contains either
+//	IA64_MCA_CPU_MCA_STACK_OFFSET or IA64_MCA_CPU_INIT_STACK_OFFSET.
+//
+//	On entry, pal_min_state is virtual, on exit it is physical.
+//
+//	On entry RBS is on the MCA/INIT stack, this routine switches RBS
+//	back to the previous stack.
+//
+//--
+
+ia64_pt_regs_restore:
+	mov b0=3Dr2		// save return address
 	GET_IA64_MCA_DATA(r2)
+	add r3=3DMCA_SOS_OFFSET+IA64_SAL_OS_STATE_PAL_MIN_STATE_OFFSET, r3
+	;;
+	add r3=3Dr2, r3		// struct ia64_sal_os_state.pal_min_state on MCA or INIT=
 stack
+	;;
+	// Convert Linux virtual address in region 6 back to physical.
+	ld8 ms=3D[r3]		// pal_min_state, virtual
 	;;
-	add r2 =3D IA64_MCA_CPU_PROC_STATE_DUMP_OFFSET, r2
+	DATA_VA_TO_PA(ms)
+	;;
+	st8 [r3]=3Dms
+	// FIXME: restore pt_regs
+	br.sptk b0
+
+//EndStub/////////////////////////////////////////////////////////////////=
/////
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
+
+//++
+// Name:
+//	ia64_set_kernel_registers()
+//
+// Stub Description:
+//
+//	Set the registers that are required by the kernel to run on an MCA/INIT
+//	stack.
+//
+//	r2 contains the return address, r3 contains either
+//	IA64_MCA_CPU_MCA_STACK_OFFSET or IA64_MCA_CPU_INIT_STACK_OFFSET.
+//=09
+//--
+
+ia64_set_kernel_registers:
+	add temp3=3DMCA_SP_OFFSET, r3
+	add temp4=3DMCA_SOS_OFFSET+IA64_SAL_OS_STATE_OS_GP_OFFSET, r3
+	mov b0=3Dr2		// save return address
+	GET_IA64_MCA_DATA(r2)
+	;;
+	add temp4=3Dtemp4, r2	// &struct ia64_sal_os_state.os_gp
+	;;
+	ld8 r1=3D[temp4]		// OS GP from SAL OS state
+	add r12=3Dr2, temp3	// kernel stack pointer on MCA/INIT stack
+	add r13=3Dr2, r3		// set current to start of MCA/INIT stack
 	;;
-	mov		ar.lc=3Dr5
+	DATA_PA_TO_VA(r1,temp1)
+	DATA_PA_TO_VA(r12,temp2)
+	DATA_PA_TO_VA(r13,temp3)
 	;;
-end_os_mca_restore:
-	br	ia64_os_mca_done_restore;;
+	mov IA64_KR(CURRENT)=3Dr13
+
+	// FIXME: do I need to wire IA64_KR_CURRENT_STACK and IA64_TR_CURRENT_STA=
CK?
+
+	br.sptk b0
=20
 //EndStub/////////////////////////////////////////////////////////////////=
/////
=20
+#undef	ms
+#undef	regs
+#undef	save_unat
+#undef	temp1
+#undef	temp2
+#undef	temp3
+#undef	temp4
+
=20
 // ok, the issue here is that we need to save state information so
 // it can be useable by the kernel debugger and show regs routines.
@@ -870,51 +725,44 @@ end_os_mca_restore:
 GLOBAL_ENTRY(ia64_monarch_init_handler)
 	.prologue
 	// stash the information the SAL passed to os
-	SAL_TO_OS_MCA_HANDOFF_STATE_SAVE(r2)
-	;;
-	SAVE_MIN_WITH_COVER
-	;;
-	mov r8=3Dcr.ifa
-	mov r9=3Dcr.isr
-	adds r3=3D8,r2				// set up second base pointer
-	;;
-	SAVE_REST
+	movl r2=1F				// return address
+	mov r3=3DIA64_MCA_CPU_INIT_STACK_OFFSET	// use the INIT stack
+	br.sptk ia64_sal_os_state_save		// save the SAL to OS INIT handoff state
+1:
+
+	// create struct pt_regs from min_state, switch stack, set kernel registe=
rs
+	movl r2=1F				// return address
+	mov r3=3DIA64_MCA_CPU_MCA_STACK_OFFSET	// use the MCA stack
+	br.sptk ia64_pt_regs_save
+1:
+	//
+        // Enter virtual mode from physical mode
+	VIRTUAL_MODE_ENTER(r2, r3, ia64_os_init_virtual_begin, r4)
+ia64_os_init_virtual_begin:
=20
-// ok, enough should be saved at this point to be dangerous, and supply
-// information for a dump
-// We need to switch to Virtual mode before hitting the C functions.
+	mov ar.rsc=3D3				// set eager mode for C handler
=20
-	movl	r2=3DIA64_PSR_IT|IA64_PSR_IC|IA64_PSR_DT|IA64_PSR_RT|IA64_PSR_DFH|IA=
64_PSR_BN
-	mov	r3=3Dpsr	// get the current psr, minimum enabled at this point
-	;;
-	or	r2=3Dr2,r3
-	;;
-	movl	r3=3DIVirtual_Switch
-	;;
-	mov	cr.iip=3Dr3	// short return to set the appropriate bits
-	mov	cr.ipsr=3Dr2	// need to do an rfi to set appropriate bits
-	;;
-	rfi
-	;;
-IVirtual_Switch:
-	//
-	// We should now be running virtual
-	//
-	// Let's call the C handler to get the rest of the state info
-	//
-	alloc r14=3Dar.pfs,0,0,2,0		// now it's safe (must be first in insn group=
!)
-	;;
-	adds out0=16,sp				// out0 =3D pointer to pt_regs
-	;;
-	DO_SAVE_SWITCH_STACK
-	.body
-	adds out1=16,sp				// out0 =3D pointer to switch_stack
+	// Call virtual mode handler
+	br.call.sptk.many    b0=3Dia64_init_handler;;
=20
-	br.call.sptk.many rp=3Dia64_init_handler
-.ret1:
+	// Revert back to physical mode before going back to SAL
+	PHYSICAL_MODE_ENTER(r2, r3, ia64_os_init_virtual_end, r4)
+ia64_os_init_virtual_end:
+
+	// restore struct pt_regs (kernel modified registers), switch back to
+	// previous stack
+	movl r2=1F				// return address
+	mov r3=3DIA64_MCA_CPU_INIT_STACK_OFFSET	// use the INIT stack
+	br.sptk ia64_pt_regs_restore
+1:
+
+	movl r2=1F				// return address
+	mov r3=3DIA64_MCA_CPU_INIT_STACK_OFFSET	// use the INIT stack
+	br.sptk ia64_sal_os_state_restore	// restore the SAL to OS INIT handoff s=
tate
+1:
+	mov		b0=3Dr12;;		// SAL_CHECK return address
+	br		b0
=20
-return_from_init:
-	br.sptk return_from_init
 END(ia64_monarch_init_handler)
=20
 //
@@ -926,3 +774,4 @@ END(ia64_monarch_init_handler)
 GLOBAL_ENTRY(ia64_slave_init_handler)
 1:	br.sptk 1b
 END(ia64_slave_init_handler)
+
Index: linux/arch/ia64/kernel/asm-offsets.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig/arch/ia64/kernel/asm-offsets.c	2005-=
02-15 13:27:38.000000000 +1100
+++ linux/arch/ia64/kernel/asm-offsets.c	2005-02-15 13:27:42.000000000 +1100
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
Index: linux/include/asm-ia64/mca_asm.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig/include/asm-ia64/mca_asm.h	2005-02-1=
5 13:27:38.000000000 +1100
+++ linux/include/asm-ia64/mca_asm.h	2005-02-15 13:27:42.000000000 +1100
@@ -8,6 +8,8 @@
  * Copyright (C) 2000 David Mosberger-Tang <davidm@hpl.hp.com>
  * Copyright (C) 2002 Intel Corp.
  * Copyright (C) 2002 Jenna Hall <jenna.s.hall@intel.com>
+ * Copyright (C) 2004 Silicon Graphics, Inc
+ * Copyright (C) 2004 Keith Owens <kaos@sgi.com>
  */
 #ifndef _ASM_IA64_MCA_ASM_H
 #define _ASM_IA64_MCA_ASM_H
@@ -207,106 +209,30 @@
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
+ * stacks, except that the SAL/OS state is stored at the top of the MCA/IN=
IT
+ * stack.  To support concurrent entry to MCA or INIT, as well as MCA over
+ * INIT, each event needs its own SAL/OS state.  All entries are 16 byte
+ * aligned.
+ *
+ *      +---------------------------+
+ *      |        SAL/OS state       |
+ *      +---------------------------+
+ *      |         pt_regs           |
+ *      +---------------------------+
+ *      |    16 byte scratch area   |
+ *      +---------------------------+ <-------- SP at start of C MCA handl=
er
+ *      |           .....           |
+ *      +---------------------------+
+ *      | RBS for MCA/INIT handler  |
+ *      +---------------------------+
+ *      | struct task, not used yet |
+ *      +---------------------------+ <-------- Bottom of MCA/INIT stack
+ */
+
+#define ALIGN16(x)			((x)&~15)
+#define MCA_SOS_OFFSET			ALIGN16(KERNEL_STACK_SIZE-IA64_SAL_OS_STATE_SIZE)
+#define MCA_PT_REGS_OFFSET		ALIGN16(MCA_SOS_OFFSET-IA64_PT_REGS_SIZE)
+#define MCA_SP_OFFSET			ALIGN16(MCA_PT_REGS_OFFSET-16)
=20
 #endif /* _ASM_IA64_MCA_ASM_H */
Index: linux/arch/ia64/kernel/mca_drv.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig/arch/ia64/kernel/mca_drv.c	2005-02-1=
5 13:27:38.000000000 +1100
+++ linux/arch/ia64/kernel/mca_drv.c	2005-02-15 13:27:42.000000000 +1100
@@ -4,6 +4,8 @@
  *
  * Copyright (C) 2004 FUJITSU LIMITED
  * Copyright (C) Hidetoshi Seto (seto.hidetoshi@jp.fujitsu.com)
+ * Copyright (C) 2005 Silicon Graphics, Inc
+ * Copyright (C) Keith Owens <kaos@sgi.com>
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
@@ -317,7 +315,8 @@ init_record_index_pools(void)
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
@@ -328,7 +327,7 @@ is_mca_global(peidx_table_t *peidx, pal_
 	 * Therefore it is local MCA when rendezvous has not been requested.
 	 * Failed to rendezvous, the system must be down.
 	 */
-	switch (sal_to_os_handoff_state->imsto_rendez_state) {
+	switch (sos->rendez_state) {
 		case -1: /* SAL rendezvous unsuccessful */
 			return MCA_IS_GLOBAL;
 		case  0: /* SAL rendezvous not required */
@@ -389,7 +388,8 @@ is_mca_global(peidx_table_t *peidx, pal_
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
@@ -427,7 +427,7 @@ recover_from_read_error(slidx_table_t *s
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
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig/arch/ia64/kernel/mca.c	2005-02-15 13=
:27:38.000000000 +1100
+++ linux/arch/ia64/kernel/mca.c	2005-02-15 13:27:42.000000000 +1100
@@ -48,6 +48,9 @@
  *            Delete dead variables and functions.
  *            Reorder to remove the need for forward declarations and to c=
onsolidate
  *            related code.
+ *
+ * 2005-02-13 Keith Owens <kaos@sgi.com>
+ *	      Convert MCA/INIT handlers to use per event stacks and SAL/OS stat=
e.
  */
 #include <linux/config.h>
 #include <linux/types.h>
@@ -84,8 +87,6 @@
 #endif
=20
 /* Used by mca_asm.S */
-ia64_mca_sal_to_os_state_t	ia64_sal_to_os_handoff_state;
-ia64_mca_os_to_sal_state_t	ia64_os_to_sal_handoff_state;
 u64				ia64_mca_serialize;
 DEFINE_PER_CPU(u64, ia64_mca_data); /* =3D __per_cpu_mca[smp_processor_id(=
)] */
 DEFINE_PER_CPU(u64, ia64_mca_per_cpu_pte); /* PTE to map per-CPU area */
@@ -804,38 +805,24 @@ ia64_mca_wakeup_int_handler(int wakeup_i
  */
=20
 static void
-ia64_return_to_sal_check(int recover)
+ia64_return_to_sal_check(int recover, struct ia64_sal_os_state *sos)
 {
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
 	if (recover)
-		ia64_os_to_sal_handoff_state.imots_os_status =3D IA64_MCA_CORRECTED;
+		sos->os_status =3D IA64_MCA_CORRECTED;
 	else
-		ia64_os_to_sal_handoff_state.imots_os_status =3D IA64_MCA_COLD_BOOT;
+		sos->os_status =3D IA64_MCA_COLD_BOOT;
=20
 	/* Default =3D tell SAL to return to same context */
-	ia64_os_to_sal_handoff_state.imots_context =3D IA64_MCA_SAME_CONTEXT;
-
-	ia64_os_to_sal_handoff_state.imots_new_min_state -		(u64 *)ia64_sal_to_os=
_handoff_state.pal_min_state;
-
+	sos->context =3D IA64_MCA_SAME_CONTEXT;
 }
=20
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
@@ -867,15 +854,15 @@ EXPORT_SYMBOL(ia64_unreg_MCA_extension);
  *	Monarch also has the duty of sending wakeup-IPIs to pull the
  *	slave processors out of rendezvous spinloop.
  *
- *  Inputs  :   None
+ *  Inputs  :   SAL/OS state for this event.
  *  Outputs :   None
  */
 void
-ia64_mca_ucmc_handler(void)
+ia64_mca_ucmc_handler(struct ia64_sal_os_state *sos)
 {
 	pal_processor_state_info_t *psp =3D (pal_processor_state_info_t *)
-		&ia64_sal_to_os_handoff_state.proc_state_param;
-	int recover;=20
+		&sos->proc_state_param;
+	int recover;
=20
 	/* Get the MCA error record and log it */
 	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_MCA);
@@ -883,11 +870,10 @@ ia64_mca_ucmc_handler(void)
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
@@ -901,7 +887,7 @@ ia64_mca_ucmc_handler(void)
 	ia64_mca_wakeup_all();
=20
 	/* Return to SAL */
-	ia64_return_to_sal_check(recover);
+	ia64_return_to_sal_check(recover, sos);
 }
=20
 static DECLARE_WORK(cmc_disable_work, ia64_mca_cmc_vector_disable_keventd,=
 NULL);
@@ -1127,7 +1113,8 @@ ia64_mca_cpe_poll (unsigned long dummy)
  *
  * Called from ia64_monarch_init_handler
  *
- * Inputs: pointer to pt_regs where processor info was saved.
+ * Inputs: pointer to pt_regs where processor info was saved.  SAL/OS stat=
e for
+ * this event.
  *
  * Returns:
  *   0 if SAL must warm boot the System
@@ -1135,24 +1122,16 @@ ia64_mca_cpe_poll (unsigned long dummy)
  *
  */
 void
-ia64_init_handler (struct pt_regs *pt, struct switch_stack *sw)
+ia64_init_handler (struct pt_regs *pt, struct switch_stack *sw,
+		   struct ia64_sal_os_state *sos)
 {
-	pal_min_state_area_t *ms;
-
 	oops_in_progress =3D 1;	/* avoid deadlock in printk, but it makes recover=
y dodgy */
 	console_loglevel =3D 15;	/* make sure printks make it to console */
=20
 	printk(KERN_INFO "Entered OS INIT handler. PSP=3D%lx\n",
-		ia64_sal_to_os_handoff_state.proc_state_param);
-
-	/*
-	 * Address of minstate area provided by PAL is physical,
-	 * uncacheable (bit 63 set). Convert to Linux virtual
-	 * address in region 6.
-	 */
-	ms =3D (pal_min_state_area_t *)(ia64_sal_to_os_handoff_state.pal_min_stat=
e | (6ul<<61));
+		sos->proc_state_param);
=20
-	init_handler_platform(ms, pt, sw);	/* call platform specific routines */
+	init_handler_platform(sos->pal_min_state, pt, sw);	/* call platform speci=
fic routines */
 }
=20
 static int __init

