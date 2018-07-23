From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Date: Mon, 23 Jul 2018 05:56:55 +0000
Subject: [PATCH 1/4] ia64: contig/paging_init: reduce code duplication
Message-Id: <1532325418-22617-2-git-send-email-rppt@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1532325418-22617-1-git-send-email-rppt@linux.vnet.ibm.com>
In-Reply-To: <1532325418-22617-1-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-ia64@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

The FLATMEM version of paging_init has calls to free_area_init_nodes() in
the end of every branch of 'if' and 'ifdef' statements.

Let's call this function outside the 'ifdef' and 'if' statements instead.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 arch/ia64/mm/contig.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/arch/ia64/mm/contig.c b/arch/ia64/mm/contig.c
index 7d64b30..1835144 100644
--- a/arch/ia64/mm/contig.c
+++ b/arch/ia64/mm/contig.c
@@ -248,7 +248,6 @@ paging_init (void)
 	efi_memmap_walk(find_largest_hole, (u64 *)&max_gap);
 	if (max_gap < LARGE_GAP) {
 		vmem_map = (struct page *) 0;
-		free_area_init_nodes(max_zone_pfns);
 	} else {
 		unsigned long map_size;
 
@@ -266,13 +265,12 @@ paging_init (void)
 		 */
 		NODE_DATA(0)->node_mem_map = vmem_map +
 			find_min_pfn_with_active_regions();
-		free_area_init_nodes(max_zone_pfns);
 
 		printk("Virtual mem_map starts at 0x%p\n", mem_map);
 	}
 #else /* !CONFIG_VIRTUAL_MEM_MAP */
 	memblock_add_node(0, PFN_PHYS(max_low_pfn), 0);
-	free_area_init_nodes(max_zone_pfns);
 #endif /* !CONFIG_VIRTUAL_MEM_MAP */
+	free_area_init_nodes(max_zone_pfns);
 	zero_page_memmap_ptr = virt_to_page(ia64_imva(empty_zero_page));
 }
-- 
2.7.4

