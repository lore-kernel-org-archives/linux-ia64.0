From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 18 Dec 2003 23:37:09 +0000
Subject: [patch] 2.6.0 MCA TLB error recovery
Message-Id: <marc-linux-ia64-107179074306357@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

David,

Here's the updated version of the MCA TLB recovery patch
(and I've made the assumption that you'll take Keith's
salinfo patch from 11/25 and the deadlock fix that he posted
on 12/7 first ... so this patch is against base 2.6.0 with
Keith's patches applied).

One slight glitch that I don't understand.  When I injected a
TLB error I saw this printk on the console:

   +CPU 3: SAL log contains MCA error record
   +Err Record ID: 545586543104884737    SAL Rev:  0.03
   +Time: 12/18/2003 10:28:32    Severity 0

But the salinfo_decode daemon didn't wake up to pluck this
from the kernel and deposit it in /var/log/salinfo/{raw,decoded}/*
After I rebooted the daemon picked up the log and decoded it and
reported 4 copies of the same stuff, one from each cpu:

   BEGIN HARDWARE ERROR STATE from mca on cpu 3
   Err Record ID: 545586543104884737    SAL Rev:  0.03
   Time: 2003-12-18 10:28:32    Severity 0
   Processor Device Error Info Section
     UNCORRECTED PROCESSOR ERROR: TLB Check
       processor lid            : 0x00000000c6180000
         cpu: M nasid: 0x618
       processor state parameter: 0x10000000ff7211a0
   blah, blah, blah

It looks like salinfo_log_wakeup() is called right before
ia64_log_print() ... so I'm not sure why the salinfo_decode
daemon kept on snoozing.  Keith: am I missing something obvious?

Here's the patch (substantial portions of this code written by Fenghua Yu):

diff -ru linux-2.6.0/arch/ia64/kernel/asm-offsets.c tlbfix/arch/ia64/kernel=
/asm-offsets.c
--- linux-2.6.0/arch/ia64/kernel/asm-offsets.c	2003-12-17 18:59:39.00000000=
0 -0800
+++ tlbfix/arch/ia64/kernel/asm-offsets.c	2003-12-18 09:47:18.000000000 -08=
00
@@ -12,6 +12,7 @@
 #include <asm-ia64/ptrace.h>
 #include <asm-ia64/siginfo.h>
 #include <asm-ia64/sigcontext.h>
+#include <asm-ia64/mca.h>
=20
 #include "../kernel/sigframe.h"
=20
@@ -204,4 +205,7 @@
 # error "CLONE_SETTLS_BIT incorrect, please fix"
 #endif
=20
+	BLANK();
+	DEFINE(IA64_MCA_TLB_INFO_SIZE, sizeof (struct ia64_mca_tlb_info));
+
 }
diff -ru linux-2.6.0/arch/ia64/kernel/efi.c tlbfix/arch/ia64/kernel/efi.c
--- linux-2.6.0/arch/ia64/kernel/efi.c	2003-12-17 18:58:05.000000000 -0800
+++ tlbfix/arch/ia64/kernel/efi.c	2003-12-18 09:47:18.000000000 -0800
@@ -30,6 +30,7 @@
 #include <asm/kregs.h>
 #include <asm/pgtable.h>
 #include <asm/processor.h>
+#include <asm/mca.h>
=20
 #define EFI_DEBUG	0
=20
@@ -395,6 +396,9 @@
 	int pal_code_count =3D 0;
 	u64 mask, psr;
 	u64 vaddr;
+#ifdef CONFIG_IA64_MCA
+	int cpu;
+#endif
=20
 	efi_map_start =3D __va(ia64_boot_param->efi_memmap);
 	efi_map_end   =3D efi_map_start + ia64_boot_param->efi_memmap_size;
@@ -455,6 +459,14 @@
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
diff -ru linux-2.6.0/arch/ia64/kernel/mca_asm.S tlbfix/arch/ia64/kernel/mca=
_asm.S
--- linux-2.6.0/arch/ia64/kernel/mca_asm.S	2003-12-17 18:59:29.000000000 -0=
800
+++ tlbfix/arch/ia64/kernel/mca_asm.S	2003-12-18 09:47:18.000000000 -0800
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
@@ -71,19 +68,36 @@
  *	returns ptr to SAL rtn save loc in _tmp
  */
 #define OS_MCA_TO_SAL_HANDOFF_STATE_RESTORE(_tmp)	\
-	LOAD_PHYSICAL(p6, _tmp, ia64_sal_to_os_handoff_state);; \
-	LOAD_PHYSICAL(p7, _tmp, ia64_os_to_sal_handoff_state);; \
-(p6)	movl	r8=3DIA64_MCA_COLD_BOOT;			\
-(p6)	movl	r10=3DIA64_MCA_SAME_CONTEXT;		\
-(p6)	add     _tmp=3D0x18,_tmp;;			\
-(p6)	ld8	r9=3D[_tmp],0x10;				\
-(p6)	mov	r22=3Dr0;;				\
-(p7)	ld8	r8=3D[_tmp],0x08;;			\
-(p7)	ld8	r9=3D[_tmp],0x08;;			\
-(p7)	ld8     r10=3D[_tmp],0x08;;			\
-(p7)	ld8     r22=3D[_tmp],0x08;;
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
@@ -94,20 +108,21 @@
 	.global	ia64_mca_stackframe
 	.global	ia64_mca_bspstore
 	.global ia64_init_stack
-	.global ia64_mca_sal_data_area
-	.global ia64_tlb_functional
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
@@ -124,6 +139,191 @@
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
@@ -137,17 +337,11 @@
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
@@ -156,13 +350,6 @@
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
@@ -178,14 +365,16 @@
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
@@ -205,8 +394,9 @@
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
@@ -658,79 +848,6 @@
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
diff -ru linux-2.6.0/arch/ia64/kernel/mca.c tlbfix/arch/ia64/kernel/mca.c
--- linux-2.6.0/arch/ia64/kernel/mca.c	2003-12-18 09:18:53.000000000 -0800
+++ tlbfix/arch/ia64/kernel/mca.c	2003-12-18 09:47:18.000000000 -0800
@@ -78,9 +78,8 @@
 u64				ia64_mca_stackframe[32];
 u64				ia64_mca_bspstore[1024];
 u64				ia64_init_stack[KERNEL_STACK_SIZE/8] __attribute__((aligned(16)));
-u64				ia64_mca_sal_data_area[1356];
-u64				ia64_tlb_functional;
 u64				ia64_os_mca_recovery_successful;
+u64				ia64_mca_serialize;
 static void			ia64_mca_wakeup_ipi_wait(void);
 static void			ia64_mca_wakeup(int cpu);
 static void			ia64_mca_wakeup_all(void);
@@ -90,6 +89,8 @@
 static u64			ia64_log_get(int sal_info_type, u8 **buffer);
 extern struct hw_interrupt_type	irq_type_iosapic_level;
=20
+struct ia64_mca_tlb_info ia64_mca_tlb_list[NR_CPUS];
+
 static struct irqaction cmci_irqaction =3D {
 	.handler =3D	ia64_mca_cmc_int_handler,
 	.flags =3D	SA_INTERRUPT,
@@ -944,6 +945,9 @@
 void
 ia64_return_to_sal_check(void)
 {
+	pal_processor_state_info_t *psp =3D (pal_processor_state_info_t *)
+		&ia64_sal_to_os_handoff_state.proc_state_param;
+
 	/* Copy over some relevant stuff from the sal_to_os_mca_handoff
 	 * so that it can be used at the time of os_mca_to_sal_handoff
 	 */
@@ -953,14 +957,22 @@
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
 	ia64_os_to_sal_handoff_state.imots_new_min_state  		(u64 *)ia64_sal_to_os=
_handoff_state.pal_min_state;
+
 }
=20
 /*
@@ -1338,8 +1350,8 @@
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
diff -ru linux-2.6.0/arch/ia64/mm/init.c tlbfix/arch/ia64/mm/init.c
--- linux-2.6.0/arch/ia64/mm/init.c	2003-12-17 18:58:48.000000000 -0800
+++ tlbfix/arch/ia64/mm/init.c	2003-12-18 09:47:18.000000000 -0800
@@ -34,6 +34,7 @@
 #include <asm/tlb.h>
 #include <asm/uaccess.h>
 #include <asm/unistd.h>
+#include <asm/mca.h>
=20
 DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
=20
@@ -277,6 +278,10 @@
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
@@ -335,6 +340,23 @@
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
diff -ru linux-2.6.0/include/asm-ia64/mca.h tlbfix/include/asm-ia64/mca.h
--- linux-2.6.0/include/asm-ia64/mca.h	2003-12-18 09:18:53.000000000 -0800
+++ tlbfix/include/asm-ia64/mca.h	2003-12-18 09:47:18.000000000 -0800
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
diff -ru linux-2.6.0/include/asm-ia64/pgtable.h tlbfix/include/asm-ia64/pgt=
able.h
--- linux-2.6.0/include/asm-ia64/pgtable.h	2003-12-17 18:58:39.000000000 -0=
800
+++ tlbfix/include/asm-ia64/pgtable.h	2003-12-18 09:47:18.000000000 -0800
@@ -230,6 +230,10 @@
=20
 #define mk_pte(page, pgprot)	pfn_pte(page_to_pfn(page), (pgprot))
=20
+/* This takes a physical page address that is used by the remapping functi=
ons */
+#define mk_pte_phys(physpage, pgprot) \
+({ pte_t __pte; pte_val(__pte) =3D physpage + pgprot_val(pgprot); __pte; })
+
 #define pte_modify(_pte, newprot) \
 	(__pte((pte_val(_pte) & ~_PAGE_CHG_MASK) | (pgprot_val(newprot) & _PAGE_C=
HG_MASK)))
=20
