From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 03 Oct 2003 23:27:34 +0000
Subject: [PATCH 2.6.0test5: 3 of 3] MCA/TLB recovery
Message-Id: <marc-linux-ia64-106522396923445@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Here's all the rest.  Code to save enough information about
the settings in the ITR/DTR registers in an array of structures
(ia64_mca_tlb_list[]).  Then when an MCA comes we check the
"processor state parameter" to see if this was a TLB error, if
so we purge the whole TC, and all the ITR/DTR registers and
reload the ITR/DTR registers in physical mode in mca_asm.S.
Note that we use cr.lid to identify the right entry in the
array, because in physical mode we can't tell which linux
logical cpu number we are (smp_processor_id() can't be called).

C-code in mca.c now uses the same min_state area that the PAL
used, and checks to see if the error was just a TLB error, in
which case everything was fixed, and we can ask the SAL to
continue.  Otherwise we still reboot.

Acknowledgements:
  most of this piece of the patch was written by Fenghua Yu
  based on earlier versions by Jenna Hall, and by me.

-Tony

diff -ru temp/arch/ia64/kernel/asm-offsets.c mca/arch/ia64/kernel/asm-offse=
ts.c
--- temp/arch/ia64/kernel/asm-offsets.c	2003-09-08 12:50:28.000000000 -0700
+++ mca/arch/ia64/kernel/asm-offsets.c	2003-10-03 11:22:11.000000000 -0700
@@ -12,6 +12,7 @@
 #include <asm-ia64/ptrace.h>
 #include <asm-ia64/siginfo.h>
 #include <asm-ia64/sigcontext.h>
+#include <asm-ia64/mca.h>
=20
 #include "../kernel/sigframe.h"
=20
@@ -186,4 +187,7 @@
 # error "CLONE_SETTLS_BIT incorrect, please fix"
 #endif
=20
+	BLANK();
+	DEFINE(IA64_MCA_TLB_INFO_SIZE, sizeof (struct ia64_mca_tlb_info));
+
 }
diff -ru temp/arch/ia64/kernel/efi.c mca/arch/ia64/kernel/efi.c
--- temp/arch/ia64/kernel/efi.c	2003-10-03 15:25:04.346056774 -0700
+++ mca/arch/ia64/kernel/efi.c	2003-10-03 10:40:06.000000000 -0700
@@ -30,6 +30,7 @@
 #include <asm/kregs.h>
 #include <asm/pgtable.h>
 #include <asm/processor.h>
+#include <asm/mca.h>
=20
 #define EFI_DEBUG	0
=20
@@ -402,6 +403,9 @@
 	int pal_code_count =3D 0;
 	u64 mask, psr;
 	u64 vaddr;
+#ifdef CONFIG_IA64_MCA
+	int cpu;
+#endif
=20
 	efi_map_start =3D __va(ia64_boot_param->efi_memmap);
 	efi_map_end   =3D efi_map_start + ia64_boot_param->efi_memmap_size;
@@ -460,6 +464,14 @@
 			 IA64_GRANULE_SHIFT);
 		ia64_set_psr(psr);		/* restore psr */
 		ia64_srlz_i();
+
+#ifdef CONFIG_IA64_MCA
+		cpu =3D smp_processor_id();
+
+		/* insert this TR into our list for MCA recovery purposes */
+		ia64_mca_tlb_list[cpu].pal_base=3Dvaddr & mask;
+		ia64_mca_tlb_list[cpu].pal_paddr=3D pte_val(mk_pte_phys(md->phys_addr, P=
AGE_KERNEL));
+#endif
 	}
 }
=20
diff -ru temp/arch/ia64/kernel/mca_asm.S mca/arch/ia64/kernel/mca_asm.S
--- temp/arch/ia64/kernel/mca_asm.S	2003-10-03 15:35:44.284525497 -0700
+++ mca/arch/ia64/kernel/mca_asm.S	2003-10-03 15:14:01.983760201 -0700
@@ -13,7 +13,9 @@
 //		   2. Restore current thread pointer to kr6
 //		   3. Move stack ptr 16 bytes to conform to C calling convention
 //
+//
 #include <linux/config.h>
+#include <linux/threads.h>
=20
 #include <asm/asmmacro.h>
 #include <asm/pgtable.h>
@@ -22,20 +24,15 @@
 #include <asm/mca.h>
=20
 /*
- * When we get an machine check, the kernel stack pointer is no longer
+ * When we get a machine check, the kernel stack pointer is no longer
  * valid, so we need to set a new stack pointer.
  */
 #define	MINSTATE_PHYS	/* Make sure stack access is physical for MINSTATE */
=20
 /*
- * Needed for ia64_sal call
- */
-#define SAL_GET_STATE_INFO      0x01000001
-
-/*
  * Needed for return context to SAL
  */
-#define IA64_MCA_SAME_CONTEXT	0x0
+#define IA64_MCA_SAME_CONTEXT	0
 #define IA64_MCA_COLD_BOOT	-2
=20
 #include "minstate.h"
@@ -71,20 +68,36 @@
  *	returns ptr to SAL rtn save loc in _tmp
  */
 #define OS_MCA_TO_SAL_HANDOFF_STATE_RESTORE(_tmp)	\
-	LOAD_PHYSICAL(p6, _tmp, ia64_sal_to_os_handoff_state);; \
-	LOAD_PHYSICAL(p7, _tmp, ia64_os_to_sal_handoff_state);; \
-(p6)	movl	r8=3DIA64_MCA_COLD_BOOT;			\
-(p6)	movl	r10=3DIA64_MCA_SAME_CONTEXT;		\
-(p6)	add     _tmp=3D0x18,_tmp;;			\
-(p6)	ld8	r9=3D[_tmp],0x10;				\
-(p6)	movl	r22=3Dia64_mca_min_state_save_info;;	\
-(p7)	ld8	r8=3D[_tmp],0x08;;			\
-(p7)	ld8	r9=3D[_tmp],0x08;;			\
-(p7)	ld8     r10=3D[_tmp],0x08;;			\
-(p7)	ld8     r22=3D[_tmp],0x08;;			\
-	DATA_VA_TO_PA(r22)
+	movl	_tmp=3Dia64_os_to_sal_handoff_state;;	\
+	DATA_VA_TO_PA(_tmp);;				\
+	ld8	r8=3D[_tmp],0x08;;			\
+	ld8	r9=3D[_tmp],0x08;;			\
+	ld8	r10=3D[_tmp],0x08;;			\
+	ld8	r22=3D[_tmp],0x08;;
 	// now _tmp is pointing to SAL rtn save location
=20
+/*=20
+ * COLD_BOOT_HANDOFF_STATE() sets ia64_mca_os_to_sal_state
+ *	imots_os_status=3DIA64_MCA_COLD_BOOT
+ *	imots_sal_gp=3DSAL GP
+ *	imots_context=3DIA64_MCA_SAME_CONTEXT
+ *	imots_new_min_state=3DMin state save area pointer
+ *	imots_sal_check_ra=3DReturn address to location within SAL_CHECK
+ *
+ */
+#define COLD_BOOT_HANDOFF_STATE(sal_to_os_handoff,os_to_sal_handoff,tmp)\
+	movl	tmp=3DIA64_MCA_COLD_BOOT;					\
+	movl	sal_to_os_handoff=3D__pa(ia64_sal_to_os_handoff_state);	\
+	movl	os_to_sal_handoff=3D__pa(ia64_os_to_sal_handoff_state);;	\
+	st8	[os_to_sal_handoff]=3Dtmp,8;;				\
+	ld8	tmp=3D[sal_to_os_handoff],48;;				\
+	st8	[os_to_sal_handoff]=3Dtmp,8;;				\
+	movl	tmp=3DIA64_MCA_SAME_CONTEXT;;				\
+	st8	[os_to_sal_handoff]=3Dtmp,8;;				\
+	ld8	tmp=3D[sal_to_os_handoff],-8;;				\
+	st8     [os_to_sal_handoff]=3Dtmp,8;;				\
+	ld8	tmp=3D[sal_to_os_handoff];;				\
+	st8     [os_to_sal_handoff]=3Dtmp;;
=20
 	.global ia64_os_mca_dispatch
 	.global ia64_os_mca_dispatch_end
@@ -95,21 +108,21 @@
 	.global	ia64_mca_stackframe
 	.global	ia64_mca_bspstore
 	.global ia64_init_stack
-	.global ia64_mca_sal_data_area
-	.global ia64_tlb_functional
-	.global ia64_mca_min_state_save_info
=20
 	.text
 	.align 16
=20
 ia64_os_mca_dispatch:
=20
-#if defined(MCA_TEST)
-	// Pretend that we are in interrupt context
-	mov		r2=3Dpsr
-	dep		r2=3D0, r2, PSR_IC, 2;
-	mov		psr.l =3D r2
-#endif	/* #if defined(MCA_TEST) */
+	// Serialize all MCA processing
+//	movl	r2=3Dia64_mca_serialize
+	mov	r3=3D1;;
+//	DATA_VA_TO_PA(r2);;
+	LOAD_PHYSICAL(p0,r2,ia64_mca_serialize);;
+ia64_os_mca_spin:
+	xchg8	r4=3D[r2],r3;;
+	cmp.ne	p6,p0=3Dr4,r0
+(p6)	br ia64_os_mca_spin
=20
 	// Save the SAL to OS MCA handoff state as defined
 	// by SAL SPEC 3.0
@@ -126,6 +139,191 @@
=20
 ia64_os_mca_done_dump:
=20
+//	movl r16=3D__pa(ia64_sal_to_os_handoff_state)+56
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
+	mov r16=3Dcr.lid
+//	movl r17=3D__pa(ia64_mca_tlb_list) // Physical address of ia64_mca_tlb_=
list=20
+	LOAD_PHYSICAL(p0,r17,ia64_mca_tlb_list) // Physical address of ia64_mca_t=
lb_list=20
+	mov r19=3D0
+	mov r20=3DNR_CPUS
+	;;
+1:	cmp.eq p6,p7=3Dr19,r20
+(p6)	br.spnt.few err
+	ld8 r18=3D[r17],IA64_MCA_TLB_INFO_SIZE
+	;;
+	add r19=3D1,r19
+	cmp.eq p6,p7=3Dr18,r16
+(p7)	br.sptk.few 1b
+	;;=20
+	adds r17=3D-IA64_MCA_TLB_INFO_SIZE,r17
+	;;
+	mov r23=3Dr17		// save current ia64_mca_percpu_info addr pointer.
+	adds r17=16,r17
+	;;
+	.global aegl
+aegl:
+	ld8 r18=3D[r17],8		// r18=3Dptce_base
+  	;;
+	ld4 r19=3D[r17],4		// r19=3Dptce_count[0]
+	;;
+	ld4 r20=3D[r17],4		// r20=3Dptce_count[1]
+	;;
+	ld4 r21=3D[r17],4		// r21=3Dptce_stride[0]
+	mov r24=3D0
+	;;
+	ld4 r22=3D[r17],4		// r22=3Dptce_stride[1]
+	adds r20=3D-1,r20
+	;;
+2:
+	cmp.ltu p6,p7=3Dr24,r19
+(p7)	br.cond.dpnt.few 4f
+	mov ar.lc=3Dr20
+3:
+	ptc.e r18
+	;;
+	add r18=3Dr22,r18
+	br.cloop.sptk.few 3b
+	;;
+	add r18=3Dr21,r18
+	add r24=3D1,r24
+	;;
+	br.sptk.few 2b
+4:
+	srlz.i 			// srlz.i implies srlz.d
+	;;
+
+        // Now purge addresses formerly mapped by TR registers
+	// 1. Purge ITR&DTR for kernel.
+	movl r16=3DKERNEL_START
+	mov r18=3DKERNEL_TR_PAGE_SHIFT<<2
+	;;
+	ptr.i r16, r18
+	ptr.d r16, r18
+	;;
+	srlz.i
+	;;
+	srlz.d
+	;;
+	// 2. Purge DTR for PERCPU data.
+	movl r16=3DPERCPU_ADDR
+	mov r18=3DPERCPU_PAGE_SHIFT<<2
+	;;
+	ptr.d r16,r18
+	;;
+	srlz.d
+	;;
+	// 3. Purge ITR for PAL code.
+	adds r17H,r23
+	;;
+	ld8 r16=3D[r17]
+	mov r18=3DIA64_GRANULE_SHIFT<<2
+	;;
+	ptr.i r16,r18
+	;;
+	srlz.i
+	;;
+	// 4. Purge DTR for stack.=20
+	mov r16=3DIA64_KR(CURRENT_STACK)
+	;;
+	shl r16=3Dr16,IA64_GRANULE_SHIFT
+	movl r19=3DPAGE_OFFSET
+	;;
+	add r16=3Dr19,r16
+	mov r18=3DIA64_GRANULE_SHIFT<<2
+	;;
+	ptr.d r16,r18
+	;;=20
+	srlz.i
+	;;
+	// Finally reload the TR registers.
+	// 1. Reload DTR/ITR registers for kernel.
+	mov r18=3DKERNEL_TR_PAGE_SHIFT<<2
+	movl r17=3DKERNEL_START
+	;;
+	mov cr.itir=3Dr18
+	mov cr.ifa=3Dr17
+        mov r16=3DIA64_TR_KERNEL
+	mov r19=3Dip
+	movl r18=3DPAGE_KERNEL
+	;;
+        dep r17=3D0,r19,0, KERNEL_TR_PAGE_SHIFT
+	;;
+	or r18=3Dr17,r18
+	;;
+        itr.i itr[r16]=3Dr18
+	;;
+        itr.d dtr[r16]=3Dr18
+        ;;
+	srlz.i
+	srlz.d
+	;;
+	// 2. Reload DTR register for PERCPU data.
+	adds r17=3D8,r23
+	movl r16=3DPERCPU_ADDR		// vaddr
+	movl r18=3DPERCPU_PAGE_SHIFT<<2
+	;;
+	mov cr.itir=3Dr18
+	mov cr.ifa=3Dr16
+	;;
+	ld8 r18=3D[r17]			// pte
+	mov r16=3DIA64_TR_PERCPU_DATA;
+	;;
+	itr.d dtr[r16]=3Dr18
+	;;
+	srlz.d
+	;;
+	// 3. Reload ITR for PAL code.
+	adds r17@,r23
+	;;
+	ld8 r18=3D[r17],8			// pte
+	;;
+	ld8 r16=3D[r17]			// vaddr
+	mov r19=3DIA64_GRANULE_SHIFT<<2
+	;;
+	mov cr.itir=3Dr19
+	mov cr.ifa=3Dr16
+	mov r20=3DIA64_TR_PALCODE
+	;;
+	itr.i itr[r20]=3Dr18
+	;;
+	srlz.i
+	;;
+	// 4. Reload DTR for stack.
+	mov r16=3DIA64_KR(CURRENT_STACK)
+	;;
+	shl r16=3Dr16,IA64_GRANULE_SHIFT
+	movl r19=3DPAGE_OFFSET
+	;;
+	add r18=3Dr19,r16=09
+	movl r20=3DPAGE_KERNEL
+	;;
+	add r16=3Dr20,r16
+	mov r19=3DIA64_GRANULE_SHIFT<<2
+	;;
+	mov cr.itir=3Dr19
+	mov cr.ifa=3Dr18
+	mov r20=3DIA64_TR_CURRENT_STACK
+	;;
+	itr.d dtr[r20]=3Dr16
+	;;
+	srlz.d
+	;;
+	br.sptk.many done_tlb_purge_and_reload
+err:
+	COLD_BOOT_HANDOFF_STATE(r20,r21,r22)
+	br.sptk.many ia64_os_mca_done_restore
+
+done_tlb_purge_and_reload:
+
 	// Setup new stack frame for OS_MCA handling
 	movl	r2=3Dia64_mca_bspstore;;	// local bspstore area location in r2
 	DATA_VA_TO_PA(r2);;
@@ -139,17 +337,11 @@
 					// (C calling convention)
 	DATA_VA_TO_PA(r12);;
=20
-	// Check to see if the MCA resulted from a TLB error
-begin_tlb_error_check:
-        br      ia64_os_mca_tlb_error_check;;
-
-done_tlb_error_check:
-
-        // If TLB is functional, enter virtual mode from physical mode
+        // Enter virtual mode from physical mode
 	VIRTUAL_MODE_ENTER(r2, r3, ia64_os_mca_virtual_begin, r4)
 ia64_os_mca_virtual_begin:
=20
-	// call our handler
+	// Call virtual mode handler
 	movl		r2=3Dia64_mca_ucmc_handler;;
 	mov		b6=3Dr2;;
 	br.call.sptk.many    b0=B6;;
@@ -158,13 +350,6 @@
 	PHYSICAL_MODE_ENTER(r2, r3, ia64_os_mca_virtual_end, r4)
 ia64_os_mca_virtual_end:
=20
-#if defined(MCA_TEST)
-	// Pretend that we are in interrupt context
-	mov	r2=3Dpsr;;
-	dep	r2=3D0, r2, PSR_IC, 2;;
-	mov	psr.l =3D r2;;
-#endif	/* #if defined(MCA_TEST) */
-
 	// restore the original stack frame here
 	movl    r2=3Dia64_mca_stackframe	// restore stack frame from memory at r2
 	;;
@@ -180,14 +365,16 @@
 	br	ia64_os_mca_proc_state_restore;;
=20
 ia64_os_mca_done_restore:
-	movl	r3=3Dia64_tlb_functional;;
-	DATA_VA_TO_PA(r3);;
-	ld8	r3=3D[r3];;
-	cmp.eq	p6,p7=3Dr0,r3;;
 	OS_MCA_TO_SAL_HANDOFF_STATE_RESTORE(r2);;
 	// branch back to SALE_CHECK
 	ld8		r3=3D[r2];;
 	mov		b0=3Dr3;;		// SAL_CHECK return address
+
+	// release lock
+	movl		r3=3Dia64_mca_serialize;;
+	DATA_VA_TO_PA(r3);;
+	st8.rel		[r3]=3Dr0
+
 	br		b0
 	;;
 ia64_os_mca_dispatch_end:
@@ -207,8 +394,9 @@
 ia64_os_mca_proc_state_dump:
 // Save bank 1 GRs 16-31 which will be used by c-language code when we swi=
tch
 //  to virtual addressing mode.
-	movl		r2=3Dia64_mca_proc_state_dump;;           // Os state dump area
-        DATA_VA_TO_PA(r2)                   // convert to to physical addr=
ess
+//	movl		r2=3Dia64_mca_proc_state_dump;;           // Os state dump area
+//        DATA_VA_TO_PA(r2)                   // convert to to physical ad=
dress
+	LOAD_PHYSICAL(p0,r2,ia64_mca_proc_state_dump)// convert OS state dump are=
a to physical address
=20
 // save ar.NaT
 	mov		r5=3Dar.unat                  // ar.unat
@@ -660,79 +848,6 @@
=20
 //EndStub/////////////////////////////////////////////////////////////////=
/////
=20
-//++
-// Name:
-//	ia64_os_mca_tlb_error_check()
-//
-// Stub Description:
-//
-//	This stub checks to see if the MCA resulted from a TLB error
-//
-//--
-
-ia64_os_mca_tlb_error_check:
-
-	// Retrieve sal data structure for uncorrected MCA
-
-	// Make the ia64_sal_get_state_info() call
-	movl	r4=3Dia64_mca_sal_data_area;;
-	movl	r7=3Dia64_sal;;
-	mov	r6=3Dr1			// save gp
-	DATA_VA_TO_PA(r4)		// convert to physical address
-	DATA_VA_TO_PA(r7);;		// convert to physical address
-	ld8	r7=3D[r7]			// get addr of pdesc from ia64_sal
-	movl	r3=3DSAL_GET_STATE_INFO;;
-	DATA_VA_TO_PA(r7);;		// convert to physical address
-	ld8	r8=3D[r7],8;;		// get pdesc function pointer
-	dep	r8=3D0,r8,61,3;;		// convert SAL VA to PA
-	ld8	r1=3D[r7];;		// set new (ia64_sal) gp
-	dep	r1=3D0,r1,61,3;;		// convert SAL VA to PA
-	mov	b6=3Dr8
-
-	alloc	r5=3Dar.pfs,8,0,8,0;;	// allocate stack frame for SAL call
-	mov	out0=3Dr3			// which SAL proc to call
-	mov	out1=3Dr0			// error type =3D MCA
-	mov	out2=3Dr0			// null arg
-	mov	out3=3Dr4			// data copy area
-	mov	out4=3Dr0			// null arg
-	mov	out5=3Dr0			// null arg
-	mov	out6=3Dr0			// null arg
-	mov	out7=3Dr0;;		// null arg
-
-	br.call.sptk.few	b0=B6;;
-
-	mov	r1=3Dr6			// restore gp
-	mov	ar.pfs=3Dr5;;		// restore ar.pfs
-
-	movl	r6=3Dia64_tlb_functional;;
-	DATA_VA_TO_PA(r6)		// needed later
-
-	cmp.eq	p6,p7=3Dr0,r8;;		// check SAL call return address
-(p7)	st8	[r6]=3Dr0			// clear tlb_functional flag
-(p7)    br	tlb_failure		// error; return to SAL
-
-	// examine processor error log for type of error
-	add	r4@+24,r4;;		// parse past record header (length@)
-					// and section header (length$)
-	ld4	r4=3D[r4]			// get valid field of processor log
-	mov	r5=3D0xf00;;
-	and	r5=3Dr4,r5;;		// read bits 8-11 of valid field
-					// to determine if we have a TLB error
-	movl	r3=3D0x1
-	cmp.eq	p6,p7=3Dr0,r5;;
-	// if no TLB failure, set tlb_functional flag
-(p6)	st8	[r6]=3Dr3
-	// else clear flag
-(p7)	st8	[r6]=3Dr0
-
-	// if no TLB failure, continue with normal virtual mode logging
-(p6)    br	done_tlb_error_check
-	// else no point in entering virtual mode for logging
-tlb_failure:
-	br      ia64_os_mca_virtual_end
-
-//EndStub/////////////////////////////////////////////////////////////////=
/////
-
=20
 // ok, the issue here is that we need to save state information so
 // it can be useable by the kernel debugger and show regs routines.
diff -ru temp/arch/ia64/kernel/mca.c mca/arch/ia64/kernel/mca.c
--- temp/arch/ia64/kernel/mca.c	2003-10-03 15:37:40.095070954 -0700
+++ mca/arch/ia64/kernel/mca.c	2003-10-03 11:45:43.000000000 -0700
@@ -78,11 +78,8 @@
 u64				ia64_mca_stackframe[32];
 u64				ia64_mca_bspstore[1024];
 u64				ia64_init_stack[KERNEL_STACK_SIZE/8] __attribute__((aligned(16)));
-u64				ia64_mca_sal_data_area[1356];
-u64				ia64_tlb_functional;
 u64				ia64_os_mca_recovery_successful;
-/* TODO: need to assign min-state structure to UC memory */
-u64				ia64_mca_min_state_save_info[MIN_STATE_AREA_SIZE] __attribute__((al=
igned(512)));
+u64				ia64_mca_serialize;
 static void			ia64_mca_wakeup_ipi_wait(void);
 static void			ia64_mca_wakeup(int cpu);
 static void			ia64_mca_wakeup_all(void);
@@ -91,6 +88,8 @@
 extern void			ia64_slave_init_handler (void);
 extern struct hw_interrupt_type	irq_type_iosapic_level;
=20
+struct ia64_mca_tlb_info ia64_mca_tlb_list[NR_CPUS];
+
 static struct irqaction cmci_irqaction =3D {
 	.handler =3D	ia64_mca_cmc_int_handler,
 	.flags =3D	SA_INTERRUPT,
@@ -466,26 +465,6 @@
 #endif /* PLATFORM_MCA_HANDLERS */
=20
 /*
- * routine to process and prepare to dump min_state_save
- * information for debugging purposes.
- */
-void
-ia64_process_min_state_save (pal_min_state_area_t *pmss)
-{
-	int i, max =3D MIN_STATE_AREA_SIZE;
-	u64 *tpmss_ptr =3D (u64 *)pmss;
-	u64 *return_min_state_ptr =3D ia64_mca_min_state_save_info;
-
-	for (i=3D0;i<max;i++) {
-
-		/* copy min-state register info for eventual return to PAL */
-		*return_min_state_ptr++ =3D *tpmss_ptr;
-
-		tpmss_ptr++;  /* skip to next entry */
-	}
-}
-
-/*
  * ia64_mca_cmc_vector_setup
  *
  *  Setup the corrected machine check vector register in the processor and
@@ -828,7 +807,7 @@
 			irr =3D ia64_getreg(_IA64_REG_CR_IRR3);
 			break;
 		}
-	} while (!(irr & (1 << irr_bit))) ;
+	} while (!(irr & (1UL << irr_bit))) ;
 }
=20
 /*
@@ -946,6 +925,9 @@
 void
 ia64_return_to_sal_check(void)
 {
+	pal_processor_state_info_t *psp =3D (pal_processor_state_info_t *)
+		&ia64_sal_to_os_handoff_state.proc_state_param;
+
 	/* Copy over some relevant stuff from the sal_to_os_mca_handoff
 	 * so that it can be used at the time of os_mca_to_sal_handoff
 	 */
@@ -955,15 +937,22 @@
 	ia64_os_to_sal_handoff_state.imots_sal_check_ra  		ia64_sal_to_os_handoff=
_state.imsto_sal_check_ra;
=20
-	/* Cold Boot for uncorrectable MCA */
-	ia64_os_to_sal_handoff_state.imots_os_status =3D IA64_MCA_COLD_BOOT;
+	/*
+	 * Did we correct the error? At the moment the only error that
+	 * we fix is a TLB error, if any other kind of error occurred
+	 * we must reboot.
+	 */
+	if (psp->cc =3D 1 && psp->bc =3D 1 && psp->rc =3D 1 && psp->uc =3D 1)
+		ia64_os_to_sal_handoff_state.imots_os_status =3D IA64_MCA_COLD_BOOT;
+	else
+		ia64_os_to_sal_handoff_state.imots_os_status =3D IA64_MCA_CORRECTED;
=20
 	/* Default =3D tell SAL to return to same context */
 	ia64_os_to_sal_handoff_state.imots_context =3D IA64_MCA_SAME_CONTEXT;
=20
-	/* Register pointer to new min state values */
 	ia64_os_to_sal_handoff_state.imots_new_min_state -		ia64_mca_min_state_sa=
ve_info;
+		(u64 *)ia64_sal_to_os_handoff_state.pal_min_state;
+
 }
=20
 /*
@@ -1341,8 +1330,8 @@
 void
 ia64_log_prt_guid (efi_guid_t *p_guid, prfunc_t prfunc)
 {
-	char out[40];
-	printk(KERN_DEBUG "GUID =3D %s\n", efi_guid_unparse(p_guid, out));
+	//char out[40];
+	//printk(KERN_DEBUG "GUID =3D %s\n", efi_guid_unparse(p_guid, out));
 }
=20
 static void
@@ -2162,9 +2151,6 @@
 	if (slpi->valid.psi_static_struct) {
 		spsi =3D (sal_processor_static_info_t *)p_data;
=20
-		/* copy interrupted context PAL min-state info */
-		ia64_process_min_state_save(&spsi->min_state_area);
-
 		/* Print branch register contents if valid */
 		if (spsi->valid.br)
 			ia64_log_processor_regs_print(spsi->br, 8, brbits, "Branch", "br",
diff -ru temp/arch/ia64/mm/init.c mca/arch/ia64/mm/init.c
--- temp/arch/ia64/mm/init.c	2003-09-08 12:50:03.000000000 -0700
+++ mca/arch/ia64/mm/init.c	2003-10-03 13:23:06.000000000 -0700
@@ -32,6 +32,7 @@
 #include <asm/tlb.h>
 #include <asm/uaccess.h>
 #include <asm/unistd.h>
+#include <asm/mca.h>
=20
 DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
=20
@@ -327,6 +328,10 @@
 {
 	unsigned long psr, pta, impl_va_bits;
 	extern void __init tlb_init (void);
+#ifdef CONFIG_IA64_MCA
+	int cpu;
+#endif
+
 #ifdef CONFIG_DISABLE_VHPT
 #	define VHPT_ENABLE_BIT	0
 #else
@@ -385,6 +390,23 @@
 	ia64_set_pta(pta | (0 << 8) | (vmlpt_bits << 2) | VHPT_ENABLE_BIT);
=20
 	ia64_tlb_init();
+
+#ifdef	CONFIG_IA64_MCA
+	cpu =3D smp_processor_id();
+
+	/* mca handler uses cr.lid as key to pick the right entry */
+	ia64_mca_tlb_list[cpu].cr_lid =3D ia64_getreg(_IA64_REG_CR_LID);
+
+	/* insert this percpu data information into our list for MCA recovery pur=
poses */
+	ia64_mca_tlb_list[cpu].percpu_paddr=3Dpte_val(mk_pte_phys(__pa(my_cpu_dat=
a), PAGE_KERNEL));
+	/* Also save per-cpu tlb flush recipe for use in physical mode mca handle=
r */
+	ia64_mca_tlb_list[cpu].ptce_base=3Dlocal_cpu_data->ptce_base;
+	ia64_mca_tlb_list[cpu].ptce_count[0]=3Dlocal_cpu_data->ptce_count[0];
+	ia64_mca_tlb_list[cpu].ptce_count[1]=3Dlocal_cpu_data->ptce_count[1];
+	ia64_mca_tlb_list[cpu].ptce_stride[0]=3Dlocal_cpu_data->ptce_stride[0];
+	ia64_mca_tlb_list[cpu].ptce_stride[1]=3Dlocal_cpu_data->ptce_stride[1];
+#endif
+
 }
=20
 #ifdef CONFIG_VIRTUAL_MEM_MAP
diff -ru temp/include/asm-ia64/mca_asm.h mca/include/asm-ia64/mca_asm.h
--- temp/include/asm-ia64/mca_asm.h	2003-09-08 12:50:28.000000000 -0700
+++ mca/include/asm-ia64/mca_asm.h	2003-10-03 15:14:53.836298628 -0700
@@ -113,7 +113,7 @@
 	movl	temp2 =3D start_addr;							\
 	mov	cr.ipsr =3D temp1;							\
 	;;										\
-	INST_VA_TO_PA(temp2);								\
+	LOAD_PHYSICAL(p0,temp2,start_addr);						\
 	;;										\
 	mov	cr.iip =3D temp2;								\
 	mov	cr.ifs =3D r0;								\
diff -ru temp/include/asm-ia64/mca.h mca/include/asm-ia64/mca.h
--- temp/include/asm-ia64/mca.h	2003-09-08 12:49:57.000000000 -0700
+++ mca/include/asm-ia64/mca.h	2003-10-03 15:10:47.618528206 -0700
@@ -18,6 +18,7 @@
 #include <asm/param.h>
 #include <asm/sal.h>
 #include <asm/processor.h>
+#include <asm/mca_asm.h>
=20
 /* These are the return codes from all the IA64_MCA specific interfaces */
 typedef	int ia64_mca_return_code_t;
@@ -61,6 +62,17 @@
 	IA64_MCA_RENDEZ_CHECKIN_DONE	=3D	0x1
 };
=20
+/* the following data structure is used for TLB error recovery purposes */
+extern struct ia64_mca_tlb_info {
+	u64	cr_lid;
+	u64	percpu_paddr;
+	u64	ptce_base;
+	u32	ptce_count[2];
+	u32	ptce_stride[2];=20
+	u64	pal_paddr;
+	u64	pal_base;
+} ia64_mca_tlb_list[NR_CPUS];
+
 /* Information maintained by the MC infrastructure */
 typedef struct ia64_mc_info_s {
 	u64		imi_mca_handler;
@@ -108,7 +120,7 @@
 	IA64_MCA_NEW_CONTEXT	=3D	-1	/* SAL to return to new context */
 };
=20
-#define MIN_STATE_AREA_SIZE     57
+#define MIN_STATE_AREA_SIZE     58
=20
 typedef struct ia64_mca_os_to_sal_state_s {
 	u64		imots_os_status;	/*   OS status to SAL as to what happened
diff -ru temp/include/asm-ia64/pal.h mca/include/asm-ia64/pal.h
--- temp/include/asm-ia64/pal.h	2003-09-08 12:50:12.000000000 -0700
+++ mca/include/asm-ia64/pal.h	2003-10-03 11:47:57.000000000 -0700
@@ -405,10 +405,11 @@
 						 * generated.
 						 * (Trap Lost )
 						 */
-			op		: 3,	/* Operation that
-						 * caused the machine
-						 * check
+			mi		: 1,	/* More information available
+						 * call PAL_MC_ERROR_INFO
 						 */
+			pi		: 1,	/* Precise instruction pointer */
+			pm		: 1,	/* Precise min-state save area */
=20
 			dy		: 1,	/* Processor dynamic
 						 * state valid
@@ -450,11 +451,12 @@
 						 * by the processor
 						 */
=20
-			reserved2	: 12,
+			reserved2	: 11,
 			cc		: 1,	/* Cache check */
 			tc		: 1,	/* TLB check */
 			bc		: 1,	/* Bus check */
-			uc		: 1;	/* Unknown check */
+			rc		: 1,	/* Register file check */
+			uc		: 1;	/* Uarch check */
=20
 } pal_processor_state_info_t;
=20
diff -ru temp/include/asm-ia64/pgtable.h mca/include/asm-ia64/pgtable.h
--- temp/include/asm-ia64/pgtable.h	2003-09-08 12:49:59.000000000 -0700
+++ mca/include/asm-ia64/pgtable.h	2003-10-03 10:40:05.000000000 -0700
@@ -232,6 +232,10 @@
=20
 #define mk_pte(page, pgprot)	pfn_pte(page_to_pfn(page), (pgprot))
=20
+/* This takes a physical page address that is used by the remapping functi=
ons */
+#define mk_pte_phys(physpage, pgprot) \
+({ pte_t __pte; pte_val(__pte) =3D physpage + pgprot_val(pgprot); __pte; })
+
 #define pte_modify(_pte, newprot) \
 	(__pte((pte_val(_pte) & _PAGE_CHG_MASK) | pgprot_val(newprot)))
=20


