From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 11 Apr 2008 22:32:05 +0000
Subject: RE: [PATCH] NUMA memory configuration issue
Message-Id: <1FE6DD409037234FAB833C420AA843EC010D5BC1@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <47FE313B.2010600@bull.net>
In-Reply-To: <47FE313B.2010600@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

You missed a spot:

diff --git a/arch/ia64/mm/contig.c b/arch/ia64/mm/contig.c
index 0479661..798bf98 100644
--- a/arch/ia64/mm/contig.c
+++ b/arch/ia64/mm/contig.c
@@ -253,7 +253,7 @@ paging_init (void)
 	max_zone_pfns[ZONE_NORMAL] = max_low_pfn;
 
 #ifdef CONFIG_VIRTUAL_MEM_MAP
-	efi_memmap_walk(register_active_ranges, NULL);
+	efi_memmap_walk(filter_memory, register_active_ranges);
 	efi_memmap_walk(find_largest_hole, (u64 *)&max_gap);
 	if (max_gap < LARGE_GAP) {
 		vmem_map = (struct page *) 0;


But otherwise this looks plausible.  My non-numa system still
boots.

-Tony
