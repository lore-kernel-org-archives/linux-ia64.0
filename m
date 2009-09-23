From: Tejun Heo <tj@kernel.org>
Date: Wed, 23 Sep 2009 05:06:18 +0000
Subject: [PATCH 1/5] ia64: don't alias VMALLOC_END to vmalloc_end
Message-Id: <1253682382-24740-2-git-send-email-tj@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1253682382-24740-1-git-send-email-tj@kernel.org>
In-Reply-To: <1253682382-24740-1-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Piggin <npiggin@suse.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64 <linux-ia64@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Rusty Russell <rusty@rustcorp.com.au>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64 <linux-ia64@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>

If CONFIG_VIRTUAL_MEM_MAP is enabled, ia64 defines macro VMALLOC_END
as unsigned long variable vmalloc_end which is adjusted to prepare
room for vmemmap.  This becomes probnlematic if a local variables
vmalloc_end is defined in some function (not very unlikely) and
VMALLOC_END is used in the function - the function thinks its
referencing the global VMALLOC_END value but would be referencing its
own local vmalloc_end variable.

There's no reason VMALLOC_END should be a macro.  Just define it as an
unsigned long variable if CONFIG_VIRTUAL_MEM_MAP is set to avoid nasty
surprises.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64 <linux-ia64@vger.kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>
---
 arch/ia64/include/asm/meminit.h |    2 +-
 arch/ia64/include/asm/pgtable.h |    3 +--
 arch/ia64/mm/contig.c           |    4 ++--
 arch/ia64/mm/discontig.c        |    4 ++--
 arch/ia64/mm/init.c             |    4 ++--
 5 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/arch/ia64/include/asm/meminit.h b/arch/ia64/include/asm/meminit.h
index 688a812..61c7b17 100644
--- a/arch/ia64/include/asm/meminit.h
+++ b/arch/ia64/include/asm/meminit.h
@@ -61,7 +61,7 @@ extern int register_active_ranges(u64 start, u64 len, int nid);
 
 #ifdef CONFIG_VIRTUAL_MEM_MAP
 # define LARGE_GAP	0x40000000 /* Use virtual mem map if hole is > than this */
-  extern unsigned long vmalloc_end;
+  extern unsigned long VMALLOC_END;
   extern struct page *vmem_map;
   extern int find_largest_hole(u64 start, u64 end, void *arg);
   extern int create_mem_map_page_table(u64 start, u64 end, void *arg);
diff --git a/arch/ia64/include/asm/pgtable.h b/arch/ia64/include/asm/pgtable.h
index 8840a69..69bf138 100644
--- a/arch/ia64/include/asm/pgtable.h
+++ b/arch/ia64/include/asm/pgtable.h
@@ -228,8 +228,7 @@ ia64_phys_addr_valid (unsigned long addr)
 #define VMALLOC_START		(RGN_BASE(RGN_GATE) + 0x200000000UL)
 #ifdef CONFIG_VIRTUAL_MEM_MAP
 # define VMALLOC_END_INIT	(RGN_BASE(RGN_GATE) + (1UL << (4*PAGE_SHIFT - 9)))
-# define VMALLOC_END		vmalloc_end
-  extern unsigned long vmalloc_end;
+extern unsigned long VMALLOC_END;
 #else
 #if defined(CONFIG_SPARSEMEM) && defined(CONFIG_SPARSEMEM_VMEMMAP)
 /* SPARSEMEM_VMEMMAP uses half of vmalloc... */
diff --git a/arch/ia64/mm/contig.c b/arch/ia64/mm/contig.c
index 2f724d2..1341437 100644
--- a/arch/ia64/mm/contig.c
+++ b/arch/ia64/mm/contig.c
@@ -270,8 +270,8 @@ paging_init (void)
 
 		map_size = PAGE_ALIGN(ALIGN(max_low_pfn, MAX_ORDER_NR_PAGES) *
 			sizeof(struct page));
-		vmalloc_end -= map_size;
-		vmem_map = (struct page *) vmalloc_end;
+		VMALLOC_END -= map_size;
+		vmem_map = (struct page *) VMALLOC_END;
 		efi_memmap_walk(create_mem_map_page_table, NULL);
 
 		/*
diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
index d85ba98..9f24b3c 100644
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -666,9 +666,9 @@ void __init paging_init(void)
 	sparse_init();
 
 #ifdef CONFIG_VIRTUAL_MEM_MAP
-	vmalloc_end -= PAGE_ALIGN(ALIGN(max_low_pfn, MAX_ORDER_NR_PAGES) *
+	VMALLOC_END -= PAGE_ALIGN(ALIGN(max_low_pfn, MAX_ORDER_NR_PAGES) *
 		sizeof(struct page));
-	vmem_map = (struct page *) vmalloc_end;
+	vmem_map = (struct page *) VMALLOC_END;
 	efi_memmap_walk(create_mem_map_page_table, NULL);
 	printk("Virtual mem_map starts at 0x%p\n", vmem_map);
 #endif
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 1d28624..f301071 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -44,8 +44,8 @@ extern void ia64_tlb_init (void);
 unsigned long MAX_DMA_ADDRESS = PAGE_OFFSET + 0x100000000UL;
 
 #ifdef CONFIG_VIRTUAL_MEM_MAP
-unsigned long vmalloc_end = VMALLOC_END_INIT;
-EXPORT_SYMBOL(vmalloc_end);
+unsigned long VMALLOC_END = VMALLOC_END_INIT;
+EXPORT_SYMBOL(VMALLOC_END);
 struct page *vmem_map;
 EXPORT_SYMBOL(vmem_map);
 #endif
-- 
1.6.4.2

