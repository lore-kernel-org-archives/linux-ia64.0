From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 28 Apr 2004 16:11:38 +0000
Subject: [PATCH] minor processor.h cleanup
Message-Id: <200404281011.38501.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Move PSR.ic clear/restore into ia64_itr().
Remove ia64_itc(), ia64_ptr(), ia64_set_iva() (unused).

=== arch/ia64/kernel/efi.c 1.32 vs edited ==--- 1.32/arch/ia64/kernel/efi.c	Mon Apr 26 23:07:41 2004
+++ edited/arch/ia64/kernel/efi.c	Tue Apr 27 17:16:24 2004
@@ -383,7 +383,7 @@
 	efi_memory_desc_t *md;
 	u64 efi_desc_size;
 	int pal_code_count = 0;
-	u64 mask, psr;
+	u64 mask;
 	u64 vaddr;
 	int cpu;
 
@@ -437,15 +437,9 @@
 		       vaddr & mask, (vaddr & mask) + IA64_GRANULE_SIZE);
 #endif
 
-		/*
-		 * Cannot write to CRx with PSR.ic=1
-		 */
-		psr = ia64_clear_ic();
 		ia64_itr(0x1, IA64_TR_PALCODE, vaddr & mask,
 			 pte_val(pfn_pte(md->phys_addr >> PAGE_SHIFT, PAGE_KERNEL)),
 			 IA64_GRANULE_SHIFT);
-		ia64_set_psr(psr);		/* restore psr */
-		ia64_srlz_i();
 
 		cpu = smp_processor_id();
 
=== arch/ia64/mm/init.c 1.59 vs edited ==--- 1.59/arch/ia64/mm/init.c	Mon Apr 26 23:07:41 2004
+++ edited/arch/ia64/mm/init.c	Tue Apr 27 17:17:02 2004
@@ -278,7 +278,7 @@
 void __init
 ia64_mmu_init (void *my_cpu_data)
 {
-	unsigned long psr, pta, impl_va_bits;
+	unsigned long pta, impl_va_bits;
 	extern void __init tlb_init (void);
 	int cpu;
 
@@ -289,13 +289,9 @@
 #endif
 
 	/* Pin mapping for percpu area into TLB */
-	psr = ia64_clear_ic();
 	ia64_itr(0x2, IA64_TR_PERCPU_DATA, PERCPU_ADDR,
 		 pte_val(pfn_pte(__pa(my_cpu_data) >> PAGE_SHIFT, PAGE_KERNEL)),
 		 PERCPU_PAGE_SHIFT);
-
-	ia64_set_psr(psr);
-	ia64_srlz_i();
 
 	/*
 	 * Check if the virtually mapped linear page table (VMLPT) overlaps with a mapped
=== include/asm-ia64/processor.h 1.59 vs edited ==--- 1.59/include/asm-ia64/processor.h	Thu Mar 25 19:06:29 2004
+++ edited/include/asm-ia64/processor.h	Tue Apr 27 17:22:04 2004
@@ -489,6 +489,8 @@
 	  __u64 vmaddr, __u64 pte,
 	  __u64 log_page_size)
 {
+	__u64 psr;
+	psr = ia64_clear_ic();
 	ia64_setreg(_IA64_REG_CR_ITIR, (log_page_size << 2));
 	ia64_setreg(_IA64_REG_CR_IFA, vmaddr);
 	ia64_stop();
@@ -496,44 +498,7 @@
 		ia64_itri(tr_num, pte);
 	if (target_mask & 0x2)
 		ia64_itrd(tr_num, pte);
-}
-
-/*
- * Insert a translation into the instruction and/or data translation
- * cache.
- */
-static inline void
-ia64_itc (__u64 target_mask, __u64 vmaddr, __u64 pte,
-	  __u64 log_page_size)
-{
-	ia64_setreg(_IA64_REG_CR_ITIR, (log_page_size << 2));
-	ia64_setreg(_IA64_REG_CR_IFA, vmaddr);
-	ia64_stop();
-	/* as per EAS2.6, itc must be the last instruction in an instruction group */
-	if (target_mask & 0x1)
-		ia64_itci(pte);
-	if (target_mask & 0x2)
-		ia64_itcd(pte);
-}
-
-/*
- * Purge a range of addresses from instruction and/or data translation
- * register(s).
- */
-static inline void
-ia64_ptr (__u64 target_mask, __u64 vmaddr, __u64 log_size)
-{
-	if (target_mask & 0x1)
-		ia64_ptri(vmaddr, (log_size << 2));
-	if (target_mask & 0x2)
-		ia64_ptrd(vmaddr, (log_size << 2));
-}
-
-/* Set the interrupt vector address.  The address must be suitably aligned (32KB).  */
-static inline void
-ia64_set_iva (void *ivt_addr)
-{
-	ia64_setreg(_IA64_REG_CR_IVA, (__u64) ivt_addr);
+	ia64_set_psr(psr);
 	ia64_srlz_i();
 }
 
