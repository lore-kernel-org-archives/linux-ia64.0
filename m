From: Christoph Hellwig <hch@lst.de>
Date: Fri, 12 Jan 2018 08:42:15 +0000
Subject: [PATCH 17/34] microblaze: remove dma_nommu_dma_supported
Message-Id: <20180112084232.2857-18-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180112084232.2857-1-hch@lst.de>
In-Reply-To: <20180112084232.2857-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: Konrad Rzeszutek Wilk <konrad@darnok.org>, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-cris-kernel@axis.com, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-metag@vger.kernel.org, Michal Simek <monstr@monstr.eu>, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, patches@groups.riscv.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Guan Xuetao <gxt@mprc.pku.edu.cn>, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Always returning 1 is the same behavior as not supplying a method at all.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/microblaze/kernel/dma.c | 6 ------
 arch/parisc/kernel/pci-dma.c | 7 -------
 2 files changed, 13 deletions(-)

diff --git a/arch/microblaze/kernel/dma.c b/arch/microblaze/kernel/dma.c
index 450803e5731a..b45d8f8967af 100644
--- a/arch/microblaze/kernel/dma.c
+++ b/arch/microblaze/kernel/dma.c
@@ -89,11 +89,6 @@ static int dma_nommu_map_sg(struct device *dev, struct scatterlist *sgl,
 	return nents;
 }
 
-static int dma_nommu_dma_supported(struct device *dev, u64 mask)
-{
-	return 1;
-}
-
 static inline dma_addr_t dma_nommu_map_page(struct device *dev,
 					     struct page *page,
 					     unsigned long offset,
@@ -209,7 +204,6 @@ const struct dma_map_ops dma_nommu_ops = {
 	.free			= dma_nommu_free_coherent,
 	.mmap			= dma_nommu_mmap_coherent,
 	.map_sg			= dma_nommu_map_sg,
-	.dma_supported		= dma_nommu_dma_supported,
 	.map_page		= dma_nommu_map_page,
 	.unmap_page		= dma_nommu_unmap_page,
 	.sync_single_for_cpu	= dma_nommu_sync_single_for_cpu,
diff --git a/arch/parisc/kernel/pci-dma.c b/arch/parisc/kernel/pci-dma.c
index c0dfd892f70c..91bc0cac03a1 100644
--- a/arch/parisc/kernel/pci-dma.c
+++ b/arch/parisc/kernel/pci-dma.c
@@ -75,11 +75,6 @@ void dump_resmap(void)
 static inline void dump_resmap(void) {;}
 #endif
 
-static int pa11_dma_supported( struct device *dev, u64 mask)
-{
-	return 1;
-}
-
 static inline int map_pte_uncached(pte_t * pte,
 		unsigned long vaddr,
 		unsigned long size, unsigned long *paddr_ptr)
@@ -579,7 +574,6 @@ static void pa11_dma_cache_sync(struct device *dev, void *vaddr, size_t size,
 }
 
 const struct dma_map_ops pcxl_dma_ops = {
-	.dma_supported =	pa11_dma_supported,
 	.alloc =		pa11_dma_alloc,
 	.free =			pa11_dma_free,
 	.map_page =		pa11_dma_map_page,
@@ -616,7 +610,6 @@ static void pcx_dma_free(struct device *dev, size_t size, void *vaddr,
 }
 
 const struct dma_map_ops pcx_dma_ops = {
-	.dma_supported =	pa11_dma_supported,
 	.alloc =		pcx_dma_alloc,
 	.free =			pcx_dma_free,
 	.map_page =		pa11_dma_map_page,
-- 
2.14.2

