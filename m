From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Thu, 24 Mar 2005 07:18:17 +0000
Subject: [PATCH] pte prefetching
Message-Id: <424269B9.9020306@yahoo.com.au>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------080107010700000706020804"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------080107010700000706020804
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

Sending this to the ia64 list, because that is so far the only platform
I have tested on, and because the patch may be more likely to have real
applications on ia64 systems.

I have been looking at different implementations of unmapping and page
table freeing recently. As a consequence, I came to notice that the
vast majority of L2 cache misses on ia64 (and probably all
architectures) in an unmapping workload comes from the line:
	pte_t ptent = *pte;
In zap_pte_range, ie. walking the bottom level page table pages.
I should qualify that - that is the case when the page tables
aren't in cache - this does not apply to a simple lmbench fork/exit
test for example.

Anyway, I tried prefetching a line ahead of the one we're currently
working in, and put the prefetching into zap_pte_range, and
copy_pte_range (which does a similar pte walk to set up page tables
on fork()).

microbenchmark results are pretty good - but I wonder if anyone might
have a real-world use for it?

After applying the recent freepgt patchset from Hugh (on lkml), the
time to fork+exit a process mapping 64GB of address (32MB of page
tables) is 0.471s. With the prefetch patch, this drops to 0.357s.

--------------080107010700000706020804
Content-Type: text/plain;
 name="pte-prefetch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="pte-prefetch"

Index: linux-2.6/include/asm-generic/pgtable.h
===================================================================
--- linux-2.6.orig/include/asm-generic/pgtable.h	2005-03-24 10:43:38.000000000 +1100
+++ linux-2.6/include/asm-generic/pgtable.h	2005-03-24 12:08:57.000000000 +1100
@@ -160,6 +160,39 @@ static inline void ptep_set_wrprotect(st
 })
 #endif
 
+#define PTES_PER_LINE (L1_CACHE_BYTES / sizeof(pte_t))
+#define PTE_LINE_MASK (~(PTES_PER_LINE - 1))
+#define ADDR_PER_LINE (PTES_PER_LINE << PAGE_SHIFT)
+#define ADDR_LINE_MASK (~((PTES_PER_LINE << PAGE_SHIFT) - 1))
+
+#define pte_prefetch(pte, addr, end)					\
+({									\
+	unsigned long nextline = ((addr) + ADDR_PER_LINE) & ADDR_LINE_MASK; \
+	if (nextline < (end))						\
+		prefetch(pte + PTES_PER_LINE);				\
+})
+
+#define pte_prefetch_next(pte, addr, end)				\
+({									\
+	unsigned long _addr = (addr);					\
+	if (!(_addr & ~ADDR_LINE_MASK)) /* We hit a new cacheline */	\
+		pte_prefetch(pte, _addr, end);				\
+})
+
+#define pte_prefetchw(pte, addr, end)					\
+({									\
+	unsigned long nextline = ((addr) + ADDR_PER_LINE) & ADDR_LINE_MASK; \
+	if (nextline < (end))						\
+		prefetchw(pte + PTES_PER_LINE);				\
+})
+
+#define pte_prefetchw_next(pte, addr, end)				\
+({									\
+	unsigned long _addr = (addr);					\
+	if (!(_addr & ~ADDR_LINE_MASK)) /* We hit a new cacheline */	\
+		pte_prefetchw(pte, _addr, end);				\
+})
+
 #ifndef __ASSEMBLY__
 /*
  * When walking page tables, we usually want to skip any p?d_none entries;
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c	2005-03-24 12:08:43.000000000 +1100
+++ linux-2.6/mm/memory.c	2005-03-24 12:08:57.000000000 +1100
@@ -411,6 +411,7 @@ again:
 
 	progress = 0;
 	spin_lock(&src_mm->page_table_lock);
+	pte_prefetch(src_pte, addr, end);
 	do {
 		/*
 		 * We are holding two locks at this point - either of them
@@ -426,7 +427,9 @@ again:
 		}
 		copy_one_pte(dst_mm, src_mm, dst_pte, src_pte, vm_flags, addr);
 		progress += 8;
-	} while (dst_pte++, src_pte++, addr += PAGE_SIZE, addr != end);
+	} while (dst_pte++, src_pte++, addr += PAGE_SIZE,
+			pte_prefetch_next(src_pte, addr, end), addr != end);
+
 	spin_unlock(&src_mm->page_table_lock);
 
 	pte_unmap_nested(src_pte - 1);
@@ -512,6 +515,7 @@ static void zap_pte_range(struct mmu_gat
 	pte_t *pte;
 
 	pte = pte_offset_map(pmd, addr);
+	pte_prefetchw(pte, addr, end);
 	do {
 		pte_t ptent = *pte;
 		if (pte_none(ptent))
@@ -571,7 +575,8 @@ static void zap_pte_range(struct mmu_gat
 		if (!pte_file(ptent))
 			free_swap_and_cache(pte_to_swp_entry(ptent));
 		pte_clear(tlb->mm, addr, pte);
-	} while (pte++, addr += PAGE_SIZE, addr != end);
+	} while (pte++, addr += PAGE_SIZE,
+			pte_prefetchw_next(pte, addr, end), addr != end);
 	pte_unmap(pte - 1);
 }
 

--------------080107010700000706020804--

