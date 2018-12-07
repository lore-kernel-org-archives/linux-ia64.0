From: Christoph Hellwig <hch@lst.de>
Date: Fri, 07 Dec 2018 19:07:15 +0000
Subject: [PATCH 10/15] dma-mapping: move dma_cache_sync out of line
Message-Id: <20181207190720.18517-11-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181207190720.18517-1-hch@lst.de>
In-Reply-To: <20181207190720.18517-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Tariq Toukan <tariqt@mellanox.com>, Ilias Apalodimas <ilias.apalodimas@linaro.org>, =?UTF-8?q?Toke=20H=C3=B8iland-J=C3=B8rgensen?= <toke@toke.dk>, Robin Murphy <robin.murphy@arm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Keith Busch <keith.busch@intel.com>, Jonathan Derrick <jonathan.derrick@intel.com>, linux-pci@vger.kernel.org, linux-ia64@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org

This isn't exactly a slow path routine, but it is not super critical
either, and moving it out of line will help to keep the include chain
clean for the following DMA indirection bypass work.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/dma-mapping.h | 12 ++----------
 kernel/dma/mapping.c        | 11 +++++++++++
 2 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index 0bbce52606c2..0f0078490df4 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -411,16 +411,8 @@ dma_sync_sg_for_device(struct device *dev, struct scatterlist *sg,
 #define dma_map_page(d, p, o, s, r) dma_map_page_attrs(d, p, o, s, r, 0)
 #define dma_unmap_page(d, a, s, r) dma_unmap_page_attrs(d, a, s, r, 0)
 
-static inline void
-dma_cache_sync(struct device *dev, void *vaddr, size_t size,
-		enum dma_data_direction dir)
-{
-	const struct dma_map_ops *ops = get_dma_ops(dev);
-
-	BUG_ON(!valid_dma_direction(dir));
-	if (ops->cache_sync)
-		ops->cache_sync(dev, vaddr, size, dir);
-}
+void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
+		enum dma_data_direction dir);
 
 extern int dma_common_mmap(struct device *dev, struct vm_area_struct *vma,
 		void *cpu_addr, dma_addr_t dma_addr, size_t size,
diff --git a/kernel/dma/mapping.c b/kernel/dma/mapping.c
index 176ae3e08916..0b18cfbdde95 100644
--- a/kernel/dma/mapping.c
+++ b/kernel/dma/mapping.c
@@ -430,3 +430,14 @@ int dma_set_coherent_mask(struct device *dev, u64 mask)
 }
 EXPORT_SYMBOL(dma_set_coherent_mask);
 #endif
+
+void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
+		enum dma_data_direction dir)
+{
+	const struct dma_map_ops *ops = get_dma_ops(dev);
+
+	BUG_ON(!valid_dma_direction(dir));
+	if (ops->cache_sync)
+		ops->cache_sync(dev, vaddr, size, dir);
+}
+EXPORT_SYMBOL(dma_cache_sync);
-- 
2.19.1
