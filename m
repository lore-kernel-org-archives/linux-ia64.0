From: Christopher Wedgwood <cw@sgi.com>
Date: Wed, 16 Jul 2003 02:28:36 +0000
Subject: [PATCH] (2.4.21-bjorn-bk) ivt rearrangement and sn2-specific boot-time replacement of alternate d-tl
Message-Id: <marc-linux-ia64-105832263530212@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

This patch is against the linux-ia64-2.4 bk tree (as of a few minutes
ago).  It should apply cleanly to almost any recent 2.4.x tree though.

Like the previous patch this is as much for discussion as inclusion.


As previously mentioned, Altix/SN2 has mixed cachability in the
granule containing the PAL[1].  For this reason we use a different
alternate-dtlb-miss handler than the mainline kernel.

Rather than force everyone to deal with this I've opted for a small
rearrangement and code which allows the platform specific code to
boot-time replace the alternate d-tlb code with it's own version.

Other than the small rearrangement of arch/ia64/kernel/ivt.S this
should uninteresting to non-Altix platforms.




Flame away!

  --cw

[1] This is only part of it.  The PROM reserve space in granule-0 for
    uncahable access using by the fetchop driver.




 kernel/ivt.S       |   89 ++++++++++++++++++++++-----------------
 sn/kernel/Makefile |    1
 sn/kernel/setup.c  |   73 ++++++++++++++++++++++++++++++++
 sn/kernel/sn_ivt.S |   96 +++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 220 insertions(+), 39 deletions(-)



# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1148  -> 1.1149 
#	arch/ia64/kernel/ivt.S	1.8     -> 1.9    
#	arch/ia64/sn/kernel/Makefile	1.4     -> 1.5    
#	arch/ia64/sn/kernel/setup.c	1.8     -> 1.9    
#	               (new)	        -> 1.1     arch/ia64/sn/kernel/sn_ivt.S
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/07/15	cw@tomahawk.engr.sgi.com	1.1149
# Code to dynamically (boot-time) replace the alternate d-tlb miss handler when running
# on SN2 hardware.  This replacement handler has semantics compatible with SN2 low-memory
# layout as dictated by the PROM.
# --------------------------------------------
#
diff -Nru a/arch/ia64/kernel/ivt.S b/arch/ia64/kernel/ivt.S
--- a/arch/ia64/kernel/ivt.S	Tue Jul 15 18:53:16 2003
+++ b/arch/ia64/kernel/ivt.S	Tue Jul 15 18:53:16 2003
@@ -171,7 +171,7 @@
 	;;
 (p10)	itc.i r18				// insert the instruction TLB entry
 (p11)	itc.d r18				// insert the data TLB entry
-(p6)	br.cond.spnt.many page_fault		// handle bad address/page not present (page fault)
+(p6)	br.cond.spnt.many ia64_ivt_page_fault  	// handle bad address/page not present (page fault)
 	mov cr.ifa=r22
 
 #ifdef CONFIG_HUGETLB_PAGE
@@ -231,7 +231,7 @@
 	;;
 	mov b0=r29
 	tbit.z p6,p0=r18,_PAGE_P_BIT		// page present bit cleared?
-(p6)	br.cond.spnt page_fault
+(p6)	br.cond.spnt ia64_ivt_page_fault
 	;;
 	itc.i r18
 	;;
@@ -269,7 +269,7 @@
 	;;
 	mov b0=r29
 	tbit.z p6,p0=r18,_PAGE_P_BIT		// page present bit cleared?
-(p6)	br.cond.spnt page_fault
+(p6)	br.cond.spnt ia64_ivt_page_fault
 	;;
 	itc.d r18
 	;;
@@ -316,7 +316,7 @@
 	or r19=r17,r19		// insert PTE control bits into r19
 	;;
 	or r19=r19,r18		// set bit 4 (uncached) if the access was to region 6
-(p8)	br.cond.spnt page_fault
+(p8)	br.cond.spnt ia64_ivt_page_fault
 	;;
 	itc.i r19		// insert the TLB entry
 	mov pr=r31,-1
@@ -326,6 +326,7 @@
 	.align 1024
 /////////////////////////////////////////////////////////////////////////////////////////
 // 0x1000 Entry 4 (size 64 bundles) Alt DTLB (7,46)
+	.global alt_dtlb_miss
 ENTRY(alt_dtlb_miss)
 	DBG_FAULT(4)
 	mov r16=cr.ifa		// get address that caused the TLB miss
@@ -356,7 +357,7 @@
 	andcm r18=0x10,r18	// bit 4=~address-bit(61)
 	cmp.ne p8,p0=r0,r23
 (p9)	cmp.eq.or.andcm p6,p7=IA64_ISR_CODE_LFETCH,r22	// check isr.code field
-(p8)	br.cond.spnt page_fault
+(p8)	br.cond.spnt ia64_ivt_page_fault
 
 	dep r21=-1,r21,IA64_PSR_ED_BIT,1
 	or r19=r19,r17		// insert PTE control bits into r19
@@ -369,33 +370,6 @@
 	rfi
 END(alt_dtlb_miss)
 
-	//-----------------------------------------------------------------------------------
-	// call do_page_fault (predicates are in r31, psr.dt may be off, r16 is faulting address)
-ENTRY(page_fault)
-	ssm psr.dt
-	;;
-	srlz.i
-	;;
-	SAVE_MIN_WITH_COVER
-	alloc r15=ar.pfs,0,0,3,0
-	mov out0=cr.ifa
-	mov out1=cr.isr
-	adds r3=8,r2				// set up second base pointer
-	;;
-	ssm psr.ic | PSR_DEFAULT_BITS
-	;;
-	srlz.i					// guarantee that interruption collectin is on
-	;;
-(p15)	ssm psr.i				// restore psr.i
-	movl r14=ia64_leave_kernel
-	;;
-	SAVE_REST
-	mov rp=r14
-	;;
-	adds out2,r12			// out2 = pointer to pt_regs
-	br.call.sptk.many b6=ia64_do_page_fault	// ignore return address
-END(page_fault)
-
 	.align 1024
 /////////////////////////////////////////////////////////////////////////////////////////
 // 0x1400 Entry 5 (size 64 bundles) Data nested TLB (6,45)
@@ -407,8 +381,8 @@
 	 * table is missing, a nested TLB miss fault is triggered and control is
 	 * transferred to this point.  When this happens, we lookup the pte for the
 	 * faulting address by walking the page table in physical mode and return to the
-	 * continuation point passed in register r30 (or call page_fault if the address is
-	 * not mapped).
+	 * continuation point passed in register r30 (or call ia64_ivt_page_fault if the
+	 * address is not mapped).
 	 *
 	 * Input:	r16:	faulting address
 	 *		r29:	saved b0
@@ -452,7 +426,7 @@
 	;;
 (p7)	cmp.eq.or.andcm p6,p7=r17,r0		// was L2 entry NULL?
 	dep r17=r19,r17,3,(PAGE_SHIFT-3)	// compute address of L3 page table entry
-(p6)	br.cond.spnt page_fault
+(p6)	br.cond.spnt ia64_ivt_page_fault
 	mov b0=r30
 	br.sptk.many b0				// return to continuation point
 END(nested_dtlb_miss)
@@ -775,6 +749,43 @@
 	DBG_FAULT(14)
 	FAULT(14)
 
+	/*
+	 * Squatting in this space...  There is no particular reason for this code to be
+	 * here, other than that there happens to be space here that would go unused
+	 * otherwise.  If this fault ever gets "unreserved", simply moved the following
+	 * code to a more suitable spot...
+	 */
+
+	//-----------------------------------------------------------------------------------
+	// call ia64_do_page_fault (predicates are in r31, psr.dt may be off, r16 is faulting
+	// address)
+	//-----------------------------------------------------------------------------------
+	.global ia64_ivt_page_fault
+ENTRY(ia64_ivt_page_fault)
+	ssm psr.dt
+	;;
+	srlz.i
+	;;
+	SAVE_MIN_WITH_COVER
+	alloc r15=ar.pfs,0,0,3,0
+	mov out0=cr.ifa
+	mov out1=cr.isr
+	adds r3=8,r2				// set up second base pointer
+	;;
+	ssm psr.ic | PSR_DEFAULT_BITS
+	;;
+	srlz.i					// guarantee that interruption collectin is on
+	;;
+(p15)	ssm psr.i				// restore psr.i
+	movl r14=ia64_leave_kernel
+	;;
+	SAVE_REST
+	mov rp=r14
+	;;
+	adds out2,r12			// out2 = pointer to pt_regs
+	br.call.sptk.many b6=ia64_do_page_fault	// ignore return address
+END(ia64_ivt_page_fault)
+
 	.align 1024
 /////////////////////////////////////////////////////////////////////////////////////////
 // 0x3c00 Entry 15 (size 64 bundles) Reserved
@@ -1039,7 +1050,7 @@
 	;;
 	mov r31=pr
 	srlz.d
-	br.sptk.many page_fault
+	br.sptk.many ia64_ivt_page_fault
 END(page_not_present)
 
 	.align 256
@@ -1052,7 +1063,7 @@
 	mov r31=pr
 	;;
 	srlz.d
-	br.sptk.many page_fault
+	br.sptk.many ia64_ivt_page_fault
 END(key_permission)
 
 	.align 256
@@ -1065,7 +1076,7 @@
 	mov r31=pr
 	;;
 	srlz.d
-	br.sptk.many page_fault
+	br.sptk.many ia64_ivt_page_fault
 END(iaccess_rights)
 
 	.align 256
@@ -1078,7 +1089,7 @@
 	mov r31=pr
 	;;
 	srlz.d
-	br.sptk.many page_fault
+	br.sptk.many ia64_ivt_page_fault
 END(daccess_rights)
 
 	.align 256
diff -Nru a/arch/ia64/sn/kernel/Makefile b/arch/ia64/sn/kernel/Makefile
--- a/arch/ia64/sn/kernel/Makefile	Tue Jul 15 18:53:16 2003
+++ b/arch/ia64/sn/kernel/Makefile	Tue Jul 15 18:53:16 2003
@@ -47,6 +47,7 @@
 obj-y				= probe.o setup.o sv.o bte.o
 obj-y			        += irq.o mca.o idle.o
 obj-y			        += sn2/sn2.o
+obj-y			        += sn2/sn_ivt.o
 
 obj-$(CONFIG_IA64_GENERIC)      += machvec.o
 obj-$(CONFIG_MODULES)           += sn_ksyms.o
diff -Nru a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
--- a/arch/ia64/sn/kernel/setup.c	Tue Jul 15 18:53:16 2003
+++ b/arch/ia64/sn/kernel/setup.c	Tue Jul 15 18:53:16 2003
@@ -56,6 +56,7 @@
 #include <asm/machvec.h>
 #include <asm/system.h>
 #include <asm/processor.h>
+#include <asm/pgalloc.h>
 #include <asm/sn/sgi.h>
 #include <asm/sn/io.h>
 #include <asm/sn/arch.h>
@@ -223,7 +224,77 @@
 			shub_1_1_found = 1;
 }
 
+/*
+ * SN2 requires very slightly different alternate data-TLB miss handler than what
+ * the mainline linux kernel provides.  At some point this approach could be used
+ * to allow the use of the low-memory thrown away on other platforms when VGA is
+ * present.
+ *
+ * On SN2 we want to load small TCs for granule-0 (and aliases of) faulting
+ * addresses.  The details of this are more sublte than at which they first
+ * appear.
+ */
+static void __init
+sn2_replace_ivt(void)
+{
+	extern unsigned char alt_dtlb_miss[], ia64_ivt_page_fault[];
+	extern unsigned char sn2_alt_dtlb_miss[], sn2_alt_dtlb_miss_end[];
+	extern unsigned char sn2_alt_dtlb_miss_patch1[];
+
+	unsigned char *s, *d;
+	u64 *p;
+	u64 len = (u64)sn2_alt_dtlb_miss_end - (u64)sn2_alt_dtlb_miss;
+	u64 broffs = (ia64_ivt_page_fault - alt_dtlb_miss) - (sn2_alt_dtlb_miss_patch1 - sn2_alt_dtlb_miss);
+	u64 psr;
+	int i;
+
+	/* printk(KERN_DEBUG "Replacing alternate data-TLB miss handler.\n"); */
+
+	/* Check the code isn't too large */
+	if (len > 1024) {
+		printk(KERN_ERR "SGI: Specific alt_dtlb_misse too large!  Not replacing\n");
+		return;
+	}
+
+	/* check the offset is sane (should always be) */
+	if ((broffs>>4) + (1<<20) >= (1<<21)) {
+		printk(KERN_ERR "SGI: IVT patch ivt offset %ld invalid!   Not replacing!\n", broffs);
+		return;
+	}
 
+	/* 2nd half of bundle to patch (has slot 2) */
+	p = (u64*)sn2_alt_dtlb_miss_patch1 + 1;
+	/* patch the offset into slot 2 (imm20b + s) */
+	*p = (*p & ~(0x8fffff000000000)) | ((broffs & 0x1000000) << 35) | ((broffs & 0x0fffff0) << 32);
+
+	/* don't want any interrupts when doing this */
+	psr = ia64_clear_ic();
+
+	/* copy over the existing code, flush i-cache as required */
+	d = alt_dtlb_miss;
+	s = sn2_alt_dtlb_miss;
+	for (i=0; i<len; ++i, ++s) {
+		*d++ = *s;
+		if ((((u64)s) & 63) = 63) {
+			ia64_insn_group_barrier();
+			ia64_fc((void*)s);
+		}
+	}
+	ia64_insn_group_barrier();
+	ia64_fc((void*)s);
+
+	/* sync & serialize instruction stream */
+	ia64_sync_i();
+	ia64_srlz_i();
+
+	/* restore interrupt status */
+	ia64_set_psr(psr);
+
+	/* flush any TC's we have had previously loaded that could cause problems here */
+	local_flush_tlb_all();
+
+	printk(KERN_DEBUG "SGI: Replaced alt_dtlb_miss handler.\n");
+}
 
 /**
  * sn_setup - SN platform setup routine
@@ -263,6 +334,8 @@
 	}
 
 	io_sh_swapper(get_nasid(), 0);
+	/* Patch the ivt */
+	sn2_replace_ivt();
 
 	master_nasid = get_nasid();
 	(void)get_console_nasid();
diff -Nru a/arch/ia64/sn/kernel/sn_ivt.S b/arch/ia64/sn/kernel/sn_ivt.S
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/arch/ia64/sn/kernel/sn_ivt.S	Tue Jul 15 18:53:16 2003
@@ -0,0 +1,96 @@
+/* -*- mode: fundamental -*- */
+
+/*
+ * SN2 specific ivt(s)
+ *
+ * archi/ia64/sn/kernel/setup.c will dynamically replace code in the
+ * ivt with code from here
+ *
+ * Please note: We need to be sure that any changes in ivt.S are also
+ * reflected here (for example, if the ia64_ivt_page_fault register
+ * usage changes) and vice-versa.
+ *
+ * Copyright (c) 1998-2003 Hewlett-Packard Company
+ *	Stephane Eranian <eranian@hpl.hp.com>
+ *	David Mosberger <davidm@hpl.hp.com>
+ *
+ * Copyright (c) 2003 Silicon Graphics, Inc.  All Rights Reserved.
+ *
+ */
+
+#include <linux/config.h>
+
+#include <asm/asmmacro.h>
+#include <asm/break.h>
+#include <asm/kregs.h>
+#include <asm/offsets.h>
+#include <asm/pgtable.h>
+#include <asm/processor.h>
+#include <asm/ptrace.h>
+#include <asm/system.h>
+#include <asm/unistd.h>
+
+
+/* If someone has a *really* good reason to disable the VHPT for SN2 I'll fix this. --cw */
+#ifdef CONFIG_DISABLE_VHPT
+#error SN2 requires VHPT be enabled
+#endif
+
+	.section ".text.init", "ax"
+
+/*
+ * SN2 specific region 6/7 dtlb miss handler.
+ *
+ * On SN2 some granule-0 addresses (and therefore any aliases) are
+ * actually used uncachable.  We load small TC entries to ensure there
+ * is no-overlap between such regions (which could cause a Cache-Check
+ * MCA).
+ */
+#define SN2_GMASK	(((1 << (36-IA64_GRANULE_SHIFT)) - 1) << IA64_GRANULE_SHIFT)
+	.global sn2_alt_dtlb_miss
+ENTRY(sn2_alt_dtlb_miss)
+	mov r16=cr.ifa					// get address that caused the TLB miss
+	movl r17=PAGE_KERNEL				// kernel protection bits (RWX)
+	mov r20=cr.isr					// need to check for SP and NA status
+	movl r19=(((1<<IA64_MAX_PHYS_BITS)-1) & ~0xfff)	// suitable mask
+	mov r21=cr.ipsr					// get ipsr incase we need to poke the ED bit
+	mov r31=pr					// save pr's
+	mov r25=_PAGE_SIZE_4K<<2				// granule-0 requires we use smaller pages
+	;;
+	movl r27=SN2_GMASK				// Mask suitable to fine granule-0 (aliased) addresses
+	tbit.nz p9,p0=r20,IA64_ISR_NA_BIT			// is non-access bit on?
+	and r22=IA64_ISR_CODE_MASK,r20			// get the isr.code field
+	extr.u r23=r21,IA64_PSR_CPL0_BIT,2			// extract psr.cpl
+	shr.u r26=r16,61					// region number
+	;;
+	tbit.nz p6,p7=r20,IA64_ISR_SP_BIT			// is speculation bit on?
+	and r19=r19,r16					// clear ED, reserved bits, and PTE control bits
+	cmp.eq p10,p11=7,r26				// p11 <- region 7 (else p10 <- !0 => region 6)
+	and r24=r27,r16					// mask away all but region bits
+	;;
+	cmp.ne.andcm p10,p0=r0,r24			// p10 <- region-6 AND granule-0
+
+/* arch/ia64/sn/kernel/setup.c patches this code, you should check there if you need to mess about with this */
+	.global sn2_alt_dtlb_miss_patch1
+sn2_alt_dtlb_miss_patch1:
+	{ .mib
+(p9)	cmp.eq.or.andcm p6,p7=IA64_ISR_CODE_LFETCH,r22	// check isr.code field
+	cmp.ne p8,p0=r0,r23				// p8 <- cpl = 0?
+(p8)	br.cond.spnt.many ia64_ivt_page_fault		// NB: gets patched
+	}
+
+	;;
+(p10)	mov cr.itir=r25					// use smaller pagesize for tc
+	dep r21=-1,r21,IA64_PSR_ED_BIT,1			// r21 is psr with ED enabled
+	or r19=r19,r17					// insert PTE control bits into r19
+	;;
+(p6)	mov cr.ipsr=r21					// p6 (speculation): set ed (else we can get stuck)
+(p11)	dep r19=-1,r19,4,1				// set bit 4 (uncached) if the access was to region 6
+	;;
+(p7)	itc.d r19					// insert the TLB entry
+	mov pr=r31,-1					// restore pr's
+	rfi
+END(alt_dtlb_miss)
+	.align 8
+	.global sn2_alt_dtlb_miss_end
+sn2_alt_dtlb_miss_end:
