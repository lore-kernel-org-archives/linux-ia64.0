From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 13 Oct 2006 17:08:13 +0000
Subject: Patch [2/2] relax per-cpu TLB requirement to DTC
Message-Id: <000201c6eeea$2b134940$ff0da8c0@amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Instead of pinning per-cpu TLB into a DTR, use DTC.  This will free up
one TLB entry for application, or even kernel if access pattern to
per-cpu data area has high temporal locality.

Since per-cpu is mapped at the top of region 7 address, we just need to
add special case in alt_dtlb_miss.  The physical address of per-cpu data
is already conveniently stored in IA64_KR(PER_CPU_DATA).  Latency for
alt_dtlb_miss is not affected as we can hide all the latency.  It was
measured that alt_dtlb_miss handler has 23 cycles latency before and
after the patch.

The performance effect is massive for applications that put lots of tlb
pressure on CPU.  Workload environment like database online transaction
processing or application uses tera-byte of memory would benefit the most.
Measurement with industry standard database benchmark shown an upward
of 1.6% gain.  While smaller workloads like cpu, java also showing small
improvement.=20


Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>


--- ./include/asm-ia64/kregs.h.orig	2006-10-10 19:51:20.000000000 -0700
+++ ./include/asm-ia64/kregs.h	2006-10-13 10:43:09.000000000 -0700
@@ -29,8 +29,7 @@
  */
 #define IA64_TR_KERNEL		0	/* itr0, dtr0: maps kernel image (code & data) */
 #define IA64_TR_PALCODE		1	/* itr1: maps PALcode as required by EFI */
-#define IA64_TR_PERCPU_DATA	1	/* dtr1: percpu data */
-#define IA64_TR_CURRENT_STACK	2	/* dtr2: maps kernel's memory- & register-=
stacks */
+#define IA64_TR_CURRENT_STACK	1	/* dtr1: maps kernel's memory- & register-=
stacks */
=20
 /* Processor status register bits: */
 #define IA64_PSR_BE_BIT		1
--- ./arch/ia64/kernel/ivt.S.orig	2006-10-10 19:51:10.000000000 -0700
+++ ./arch/ia64/kernel/ivt.S	2006-10-13 10:43:09.000000000 -0700
@@ -374,6 +374,7 @@ ENTRY(alt_dtlb_miss)
 	movl r19=3D(((1 << IA64_MAX_PHYS_BITS) - 1) & ~0xfff)
 	mov r21=3Dcr.ipsr
 	mov r31=3Dpr
+	mov r24=3DPERCPU_ADDR
 	;;
 #ifdef CONFIG_DISABLE_VHPT
 	shr.u r22=3Dr16,61			// get the region number into r21
@@ -386,22 +387,30 @@ ENTRY(alt_dtlb_miss)
 (p8)	mov r29=B0				// save b0
 (p8)	br.cond.dptk dtlb_fault
 #endif
+	cmp.ge p10,p11=3Dr16,r24			// access to per_cpu_data?
+	tbit.z p12,p0=3Dr16,61			// access to region 6?
+	mov r25=3DPERCPU_PAGE_SHIFT << 2
+	mov r26=3DPERCPU_PAGE_SIZE
+	nop.m 0
+	nop.b 0
+	;;
+(p10)	mov r19=3DIA64_KR(PER_CPU_DATA)
+(p11)	and r19=3Dr19,r16				// clear non-ppn fields
 	extr.u r23=3Dr21,IA64_PSR_CPL0_BIT,2	// extract psr.cpl
 	and r22=3DIA64_ISR_CODE_MASK,r20		// get the isr.code field
 	tbit.nz p6,p7=3Dr20,IA64_ISR_SP_BIT	// is speculation bit on?
-	shr.u r18=3Dr16,57			// move address bit 61 to bit 4
-	and r19=3Dr19,r16				// clear ed, reserved bits, and PTE control bits
 	tbit.nz p9,p0=3Dr20,IA64_ISR_NA_BIT	// is non-access bit on?
 	;;
-	andcm r18=3D0x10,r18	// bit 4=3D~address-bit(61)
+(p10)	sub r19=3Dr19,r26
+(p10)	mov cr.itir=3Dr25
 	cmp.ne p8,p0=3Dr0,r23
 (p9)	cmp.eq.or.andcm p6,p7=3DIA64_ISR_CODE_LFETCH,r22	// check isr.code fi=
eld
+(p12)	dep r17=3D-1,r17,4,1			// set ma=3DUC for region 6 addr
 (p8)	br.cond.spnt page_fault
=20
 	dep r21=3D-1,r21,IA64_PSR_ED_BIT,1
-	or r19=3Dr19,r17		// insert PTE control bits into r19
 	;;
-	or r19=3Dr19,r18		// set bit 4 (uncached) if the access was to region 6
+	or r19=3Dr19,r17		// insert PTE control bits into r19
 (p6)	mov cr.ipsr=3Dr21
 	;;
 (p7)	itc.d r19		// insert the TLB entry
--- ./arch/ia64/kernel/mca_asm.S.orig	2006-10-10 19:51:10.000000000 -0700
+++ ./arch/ia64/kernel/mca_asm.S	2006-10-13 10:43:09.000000000 -0700
@@ -101,14 +101,6 @@ ia64_do_tlb_purge:
 	;;
 	srlz.d
 	;;
-	// 2. Purge DTR for PERCPU data.
-	movl r16=3DPERCPU_ADDR
-	mov r18=3DPERCPU_PAGE_SHIFT<<2
-	;;
-	ptr.d r16,r18
-	;;
-	srlz.d
-	;;
 	// 3. Purge ITR for PAL code.
 	GET_THIS_PADDR(r2, ia64_mca_pal_base)
 	;;
@@ -196,22 +188,6 @@ ia64_reload_tr:
 	srlz.i
 	srlz.d
 	;;
-	// 2. Reload DTR register for PERCPU data.
-	GET_THIS_PADDR(r2, ia64_mca_per_cpu_pte)
-	;;
-	movl r16=3DPERCPU_ADDR		// vaddr
-	movl r18=3DPERCPU_PAGE_SHIFT<<2
-	;;
-	mov cr.itir=3Dr18
-	mov cr.ifa=3Dr16
-	;;
-	ld8 r18=3D[r2]			// load per-CPU PTE
-	mov r16=3DIA64_TR_PERCPU_DATA;
-	;;
-	itr.d dtr[r16]=3Dr18
-	;;
-	srlz.d
-	;;
 	// 3. Reload ITR for PAL code.
 	GET_THIS_PADDR(r2, ia64_mca_pal_pte)
 	;;
--- ./arch/ia64/mm/init.c.orig	2006-10-10 19:51:10.000000000 -0700
+++ ./arch/ia64/mm/init.c	2006-10-13 10:43:09.000000000 -0700
@@ -337,7 +337,7 @@ setup_gate (void)
 void __devinit
 ia64_mmu_init (void *my_cpu_data)
 {
-	unsigned long psr, pta, impl_va_bits;
+	unsigned long pta, impl_va_bits;
 	extern void __devinit tlb_init (void);
=20
 #ifdef CONFIG_DISABLE_VHPT
@@ -346,15 +346,6 @@ ia64_mmu_init (void *my_cpu_data)
 #	define VHPT_ENABLE_BIT	1
 #endif
=20
-	/* Pin mapping for percpu area into TLB */
-	psr =3D ia64_clear_ic();
-	ia64_itr(0x2, IA64_TR_PERCPU_DATA, PERCPU_ADDR,
-		 pte_val(pfn_pte(__pa(my_cpu_data) >> PAGE_SHIFT, PAGE_KERNEL)),
-		 PERCPU_PAGE_SHIFT);
-
-	ia64_set_psr(psr);
-	ia64_srlz_i();
-
 	/*
 	 * Check if the virtually mapped linear page table (VMLPT) overlaps with =
a mapped
 	 * address space.  The IA-64 architecture guarantees that at least 50 bit=
s of
