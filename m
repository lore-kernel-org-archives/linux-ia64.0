From: Mike Rapoport <rppt@kernel.org>
Date: Tue, 27 Oct 2020 11:29:45 +0000
Subject: [PATCH 03/13] ia64: remove 'ifdef CONFIG_ZONE_DMA32' statements
Message-Id: <20201027112955.14157-4-rppt@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201027112955.14157-1-rppt@kernel.org>
In-Reply-To: <20201027112955.14157-1-rppt@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexey Dobriyan <adobriyan@gmail.com>, Catalin Marinas <catalin.marinas@arm.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, Jonathan Corbet <corbet@lwn.net>, Matt Turner <mattst88@gmail.com>, Meelis Roos <mroos@linux.ee>, Michael Schmitz <schmitzmic@gmail.com>, Mike Rapoport <rppt@kernel.org>, Mike Rapoport <rppt@linux.ibm.com>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, Will Deacon <will@kernel.org>, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mm@kvack.org, linux-snps-arc@lists.infradead.org

From: Mike Rapoport <rppt@linux.ibm.com>

After the removal of SN2 platform (commit cf07cb1ff4ea ("ia64: remove
support for the SGI SN2 platform") IA-64 always has ZONE_DMA32 and there is
no point to guard code with this configuration option.

Remove ifdefery associated with CONFIG_ZONE_DMA32

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/ia64/mm/contig.c    | 2 --
 arch/ia64/mm/discontig.c | 2 --
 2 files changed, 4 deletions(-)

diff --git a/arch/ia64/mm/contig.c b/arch/ia64/mm/contig.c
index e30e360beef8..2491aaeca90c 100644
--- a/arch/ia64/mm/contig.c
+++ b/arch/ia64/mm/contig.c
@@ -177,10 +177,8 @@ paging_init (void)
 	unsigned long max_zone_pfns[MAX_NR_ZONES];
 
 	memset(max_zone_pfns, 0, sizeof(max_zone_pfns));
-#ifdef CONFIG_ZONE_DMA32
 	max_dma = virt_to_phys((void *) MAX_DMA_ADDRESS) >> PAGE_SHIFT;
 	max_zone_pfns[ZONE_DMA32] = max_dma;
-#endif
 	max_zone_pfns[ZONE_NORMAL] = max_low_pfn;
 
 #ifdef CONFIG_VIRTUAL_MEM_MAP
diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
index dbe829fc5298..d255596f52c6 100644
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -621,9 +621,7 @@ void __init paging_init(void)
 	}
 
 	memset(max_zone_pfns, 0, sizeof(max_zone_pfns));
-#ifdef CONFIG_ZONE_DMA32
 	max_zone_pfns[ZONE_DMA32] = max_dma;
-#endif
 	max_zone_pfns[ZONE_NORMAL] = max_pfn;
 	free_area_init(max_zone_pfns);
 
-- 
2.28.0
