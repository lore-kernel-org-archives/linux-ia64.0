From: David Miller <davem@davemloft.net>
Date: Mon, 12 Mar 2007 22:51:57 +0000
Subject: Re: [QUICKLIST 0/6] Arch independent quicklists V1
Message-Id: <20070312.155157.74747634.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070311020923.19905.49260.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070311020923.19905.49260.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: clameter@sgi.com
Cc: linux-kernel@vger.kernel.org, ak@suse.com, holt@sgi.com, linux-ia64@vger.kernel.org, mpm@selenic.com

From: Christoph Lameter <clameter@sgi.com>
Date: Sat, 10 Mar 2007 18:09:23 -0800 (PST)

> 6 patches follow this message:
> 
> [QUICKLIST 1/6] Extract quicklist implementation from IA64
> [QUICKLIST 2/6] i386: quicklist support
> [QUICKLIST 3/6] i386: Use standard list manipulators for pgd_list
> [QUICKLIST 4/6] x86_64: Single quicklist
> [QUICKLIST 5/6] x86_64: Separate quicklist for pgds
> [QUICKLIST 6/6] slub: remove special casing for PAGE_SIZE slabs

I ported this to sparc64 as per the patch below, tested on
UP SunBlade1500 and 24 cpu Niagara T1000.

And for fun I checked everything except the SLUB patch into
a cloned Linus tree at:

	kernel.org:/pub/scm/linux/kernel/git/davem/quicklist-2.6.git

Someone with some extreme patience could do the sparc 32-bit port too,
in fact it's lacking the cached PGD update logic that x86 et al. have
so it would even end up being a bug fix :-)  This lack is why sparc32
pre-initializes the vmalloc/module area PGDs with static page tables
at boot time, FWIW.

commit 3f5d1a8772b300d401ff88065c3a6def0c5011d0
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Mon Mar 12 15:20:14 2007 -0700

    [QUICKLIST]: Add sparc64 quicklist support.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/arch/sparc64/Kconfig b/arch/sparc64/Kconfig
index f75a686..40371db 100644
--- a/arch/sparc64/Kconfig
+++ b/arch/sparc64/Kconfig
@@ -26,6 +26,10 @@ config MMU
 	bool
 	default y
 
+config NR_QUICK
+	int
+	default 1
+
 config STACKTRACE_SUPPORT
 	bool
 	default y
diff --git a/arch/sparc64/mm/init.c b/arch/sparc64/mm/init.c
index b1a1ee0..e399537 100644
--- a/arch/sparc64/mm/init.c
+++ b/arch/sparc64/mm/init.c
@@ -176,30 +176,6 @@ unsigned long sparc64_kern_sec_context __read_mostly;
 
 int bigkernel = 0;
 
-struct kmem_cache *pgtable_cache __read_mostly;
-
-static void zero_ctor(void *addr, struct kmem_cache *cache, unsigned long flags)
-{
-	clear_page(addr);
-}
-
-extern void tsb_cache_init(void);
-
-void pgtable_cache_init(void)
-{
-	pgtable_cache = kmem_cache_create("pgtable_cache",
-					  PAGE_SIZE, PAGE_SIZE,
-					  SLAB_HWCACHE_ALIGN |
-					  SLAB_MUST_HWCACHE_ALIGN,
-					  zero_ctor,
-					  NULL);
-	if (!pgtable_cache) {
-		prom_printf("Could not create pgtable_cache\n");
-		prom_halt();
-	}
-	tsb_cache_init();
-}
-
 #ifdef CONFIG_DEBUG_DCFLUSH
 atomic_t dcpage_flushes = ATOMIC_INIT(0);
 #ifdef CONFIG_SMP
diff --git a/arch/sparc64/mm/tsb.c b/arch/sparc64/mm/tsb.c
index 236d02f..57eb302 100644
--- a/arch/sparc64/mm/tsb.c
+++ b/arch/sparc64/mm/tsb.c
@@ -252,7 +252,7 @@ static const char *tsb_cache_names[8] = {
 	"tsb_1MB",
 };
 
-void __init tsb_cache_init(void)
+void __init pgtable_cache_init(void)
 {
 	unsigned long i;
 
diff --git a/include/asm-sparc64/pgalloc.h b/include/asm-sparc64/pgalloc.h
index 5891ff7..c7cb5d5 100644
--- a/include/asm-sparc64/pgalloc.h
+++ b/include/asm-sparc64/pgalloc.h
@@ -6,6 +6,7 @@
 #include <linux/sched.h>
 #include <linux/mm.h>
 #include <linux/slab.h>
+#include <linux/quicklist.h>
 
 #include <asm/spitfire.h>
 #include <asm/cpudata.h>
@@ -13,52 +14,50 @@
 #include <asm/page.h>
 
 /* Page table allocation/freeing. */
-extern struct kmem_cache *pgtable_cache;
 
 static inline pgd_t *pgd_alloc(struct mm_struct *mm)
 {
-	return kmem_cache_alloc(pgtable_cache, GFP_KERNEL);
+	return quicklist_alloc(0, GFP_KERNEL, NULL);
 }
 
 static inline void pgd_free(pgd_t *pgd)
 {
-	kmem_cache_free(pgtable_cache, pgd);
+	quicklist_free(0, NULL, pgd);
 }
 
 #define pud_populate(MM, PUD, PMD)	pud_set(PUD, PMD)
 
 static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	return kmem_cache_alloc(pgtable_cache,
-				GFP_KERNEL|__GFP_REPEAT);
+	return quicklist_alloc(0, GFP_KERNEL, NULL);
 }
 
 static inline void pmd_free(pmd_t *pmd)
 {
-	kmem_cache_free(pgtable_cache, pmd);
+	quicklist_free(0, NULL, pmd);
 }
 
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 					  unsigned long address)
 {
-	return kmem_cache_alloc(pgtable_cache,
-				GFP_KERNEL|__GFP_REPEAT);
+	return quicklist_alloc(0, GFP_KERNEL, NULL);
 }
 
 static inline struct page *pte_alloc_one(struct mm_struct *mm,
 					 unsigned long address)
 {
-	return virt_to_page(pte_alloc_one_kernel(mm, address));
+	void *pg = quicklist_alloc(0, GFP_KERNEL, NULL);
+	return pg ? virt_to_page(pg) : NULL;
 }
 		
 static inline void pte_free_kernel(pte_t *pte)
 {
-	kmem_cache_free(pgtable_cache, pte);
+	quicklist_free(0, NULL, pte);
 }
 
 static inline void pte_free(struct page *ptepage)
 {
-	pte_free_kernel(page_address(ptepage));
+	quicklist_free(0, NULL, page_address(ptepage));
 }
 
 
@@ -66,6 +65,9 @@ static inline void pte_free(struct page *ptepage)
 #define pmd_populate(MM,PMD,PTE_PAGE)		\
 	pmd_populate_kernel(MM,PMD,page_address(PTE_PAGE))
 
-#define check_pgt_cache()	do { } while (0)
+static inline void check_pgt_cache(void)
+{
+	quicklist_check(0, NULL);
+}
 
 #endif /* _SPARC64_PGALLOC_H */
