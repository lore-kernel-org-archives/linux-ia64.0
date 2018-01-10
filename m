From: Christoph Hellwig <hch@lst.de>
Date: Wed, 10 Jan 2018 08:00:25 +0000
Subject: [PATCH 31/33] dma-direct: reject too small dma masks
Message-Id: <20180110080027.13879-32-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180110080027.13879-1-hch@lst.de>
In-Reply-To: <20180110080027.13879-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: Konrad Rzeszutek Wilk <konrad@darnok.org>, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-cris-kernel@axis.com, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-metag@vger.kernel.org, Michal Simek <monstr@monstr.eu>, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, patches@groups.riscv.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Guan Xuetao <gxt@mprc.pku.edu.cn>, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/dma-direct.h |  1 +
 lib/dma-direct.c           | 19 +++++++++++++++++++
 2 files changed, 20 insertions(+)

diff --git a/include/linux/dma-direct.h b/include/linux/dma-direct.h
index 4788bf0bf683..bcdb1a3e4b1f 100644
--- a/include/linux/dma-direct.h
+++ b/include/linux/dma-direct.h
@@ -42,5 +42,6 @@ void *dma_direct_alloc(struct device *dev, size_t size, dma_addr_t *dma_handle,
 		gfp_t gfp, unsigned long attrs);
 void dma_direct_free(struct device *dev, size_t size, void *cpu_addr,
 		dma_addr_t dma_addr, unsigned long attrs);
+int dma_direct_supported(struct device *dev, u64 mask);
 
 #endif /* _LINUX_DMA_DIRECT_H */
diff --git a/lib/dma-direct.c b/lib/dma-direct.c
index 784a68dfdbe3..40b1f92f2214 100644
--- a/lib/dma-direct.c
+++ b/lib/dma-direct.c
@@ -122,6 +122,24 @@ static int dma_direct_map_sg(struct device *dev, struct scatterlist *sgl,
 	return nents;
 }
 
+int dma_direct_supported(struct device *dev, u64 mask)
+{
+#ifdef CONFIG_ZONE_DMA
+	if (mask < DMA_BIT_MASK(ARCH_ZONE_DMA_BITS))
+		return 0;
+#else
+	/*
+	 * Because 32-bit DMA masks are so common we expect every architecture
+	 * to be able to satisfy them - either by not supporting more physical
+	 * memory, or by providing a ZONE_DMA32.  If neither is the case, the
+	 * architecture needs to use an IOMMU instead of the direct mapping.
+	 */
+	if (mask < DMA_BIT_MASK(32))
+		return 0;
+#endif
+	return 1;
+}
+
 static int dma_direct_mapping_error(struct device *dev, dma_addr_t dma_addr)
 {
 	return dma_addr = DIRECT_MAPPING_ERROR;
@@ -132,6 +150,7 @@ const struct dma_map_ops dma_direct_ops = {
 	.free			= dma_direct_free,
 	.map_page		= dma_direct_map_page,
 	.map_sg			= dma_direct_map_sg,
+	.dma_supported		= dma_direct_supported,
 	.mapping_error		= dma_direct_mapping_error,
 };
 EXPORT_SYMBOL(dma_direct_ops);
-- 
2.14.2

