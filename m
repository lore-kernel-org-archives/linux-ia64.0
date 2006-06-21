From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Wed, 21 Jun 2006 03:17:24 +0000
Subject: [RFC 3/3] init.c - extract PTA setup
Message-Id: <20060621031724.22750.91082.sendpatchset@wagner.orchestra.cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Kexec wants a way to enable and disable the VHPT, and it seems quite
straight forward to abstract it.  I think the reduced ia64_mmu_init is
an improvement.

Signed-Off-By: Ian Wienand <ianw@gelato.unsw.edu.au>

---

 arch/ia64/mm/init.c        |   55 ++++++++++++++++++++++++++++-----------------
 include/asm-ia64/pgalloc.h |    3 ++
 2 files changed, 38 insertions(+), 20 deletions(-)

Index: linux-2.6.17/arch/ia64/mm/init.c
=================================--- linux-2.6.17.orig/arch/ia64/mm/init.c	2006-06-21 11:10:47.000000000 +1000
+++ linux-2.6.17/arch/ia64/mm/init.c	2006-06-21 12:02:49.000000000 +1000
@@ -335,26 +335,9 @@
 	ia64_patch_gate();
 }
 
-void __devinit
-ia64_mmu_init (void *my_cpu_data)
+static void ia64_initialize_pta(int vhpt_enable)
 {
-	unsigned long psr, pta, impl_va_bits;
-	extern void __devinit tlb_init (void);
-
-#ifdef CONFIG_DISABLE_VHPT
-#	define VHPT_ENABLE_BIT	0
-#else
-#	define VHPT_ENABLE_BIT	1
-#endif
-
-	/* Pin mapping for percpu area into TLB */
-	psr = ia64_clear_ic();
-	ia64_itr(0x2, IA64_TR_PERCPU_DATA, PERCPU_ADDR,
-		 pte_val(pfn_pte(__pa(my_cpu_data) >> PAGE_SHIFT, PAGE_KERNEL)),
-		 PERCPU_PAGE_SHIFT);
-
-	ia64_set_psr(psr);
-	ia64_srlz_i();
+	unsigned long pta, impl_va_bits;
 
 	/*
 	 * Check if the virtually mapped linear page table (VMLPT) overlaps with a mapped
@@ -402,8 +385,40 @@
 	 * size of the table, and bit 0 whether the VHPT walker is
 	 * enabled.
 	 */
-	ia64_set_pta(pta | (0 << 8) | (vmlpt_bits << 2) | VHPT_ENABLE_BIT);
+	ia64_set_pta(pta | (0 << 8) | (vmlpt_bits << 2) | vhpt_enable);
+}
+
+void ia64_enable_vhpt(void)
+{
+	ia64_initialize_pta(1);
+}
 
+void ia64_disable_vhpt(void)
+{
+	ia64_initialize_pta(0);
+}
+
+void __devinit
+ia64_mmu_init (void *my_cpu_data)
+{
+	unsigned long psr;
+	extern void __devinit tlb_init (void);
+
+	/* Pin mapping for percpu area into TLB */
+	psr = ia64_clear_ic();
+	ia64_itr(0x2, IA64_TR_PERCPU_DATA, PERCPU_ADDR,
+		 pte_val(pfn_pte(__pa(my_cpu_data) >> PAGE_SHIFT, PAGE_KERNEL)),
+		 PERCPU_PAGE_SHIFT);
+
+	ia64_set_psr(psr);
+	ia64_srlz_i();
+
+#ifdef CONFIG_DISABLE_VHPT
+	printk(KERN_INFO "VHPT walker disabled\n");
+	ia64_disable_vhpt();
+#else
+	ia64_enable_vhpt();
+#endif
 	ia64_tlb_init();
 
 #ifdef	CONFIG_HUGETLB_PAGE
Index: linux-2.6.17/include/asm-ia64/pgalloc.h
=================================--- linux-2.6.17.orig/include/asm-ia64/pgalloc.h	2006-06-18 11:49:35.000000000 +1000
+++ linux-2.6.17/include/asm-ia64/pgalloc.h	2006-06-21 11:35:41.000000000 +1000
@@ -161,4 +161,7 @@
 
 extern void check_pgt_cache(void);
 
+void ia64_enable_vhpt(void);
+void ia64_disable_vhpt(void);
+
 #endif				/* _ASM_IA64_PGALLOC_H */
