From: Christoph Hellwig <hch@lst.de>
Date: Mon, 30 Jul 2018 16:38:14 +0000
Subject: [PATCH 10/20] powerpc/dma-noncoherent: don't disable irqs over kmap_atomic
Message-Id: <20180730163824.10064-11-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180730163824.10064-1-hch@lst.de>
In-Reply-To: <20180730163824.10064-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Robin Murphy <robin.murphy@arm.com>, linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-ia64@vger.kernel.org

The requirement to disable local irqs over kmap_atomic is long gone,
so remove those calls.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/powerpc/mm/dma-noncoherent.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/arch/powerpc/mm/dma-noncoherent.c b/arch/powerpc/mm/dma-noncoherent.c
index 382528475433..d1c16456abac 100644
--- a/arch/powerpc/mm/dma-noncoherent.c
+++ b/arch/powerpc/mm/dma-noncoherent.c
@@ -357,12 +357,10 @@ static inline void __dma_sync_page_highmem(struct page *page,
 {
 	size_t seg_size = min((size_t)(PAGE_SIZE - offset), size);
 	size_t cur_size = seg_size;
-	unsigned long flags, start, seg_offset = offset;
+	unsigned long start, seg_offset = offset;
 	int nr_segs = 1 + ((size - seg_size) + PAGE_SIZE - 1)/PAGE_SIZE;
 	int seg_nr = 0;
 
-	local_irq_save(flags);
-
 	do {
 		start = (unsigned long)kmap_atomic(page + seg_nr) + seg_offset;
 
@@ -378,8 +376,6 @@ static inline void __dma_sync_page_highmem(struct page *page,
 		cur_size += seg_size;
 		seg_offset = 0;
 	} while (seg_nr < nr_segs);
-
-	local_irq_restore(flags);
 }
 #endif /* CONFIG_HIGHMEM */
 
-- 
2.18.0

