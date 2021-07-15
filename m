From: Logan Gunthorpe <logang@deltatee.com>
Date: Thu, 15 Jul 2021 16:45:29 +0000
Subject: [PATCH v1 01/16] dma-mapping: Allow map_sg() ops to return negative error codes
Message-Id: <20210715164544.6827-2-logang@deltatee.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210715164544.6827-1-logang@deltatee.com>
In-Reply-To: <20210715164544.6827-1-logang@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, iommu@lists.linux-foundation.org, linux-parisc@vger.kernel.org, xen-devel@lists.xenproject.org
Cc: Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>, Stephen Bates <sbates@raithlin.com>, Martin Oliveira <martin.oliveira@eideticom.com>, Logan Gunthorpe <logang@deltatee.com>

Allow dma_map_sgtable() to pass errors from the map_sg() ops. This
will be required for returning appropriate error codes when mapping
P2PDMA memory.

Introduce __dma_map_sg_attrs() which will return the raw error code
from the map_sg operation (whether it be negative or zero). Then add a
dma_map_sg_attrs() wrapper to convert any negative errors to zero to
satisfy the existing calling convention.

dma_map_sgtable() will convert a zero error return for old map_sg() ops
into a -EINVAL return and return any negative errors as reported.

This allows map_sg implementations to start returning multiple
negative error codes. Legacy map_sg implementations can continue
to return zero until they are all converted.

Signed-off-by: Logan Gunthorpe <logang@deltatee.com>
---
 include/linux/dma-map-ops.h |  8 +++-
 include/linux/dma-mapping.h | 35 ++++--------------
 kernel/dma/mapping.c        | 73 +++++++++++++++++++++++++++++++++----
 3 files changed, 78 insertions(+), 38 deletions(-)

diff --git a/include/linux/dma-map-ops.h b/include/linux/dma-map-ops.h
index 0d53a96a3d64..eaa969be8284 100644
--- a/include/linux/dma-map-ops.h
+++ b/include/linux/dma-map-ops.h
@@ -41,8 +41,12 @@ struct dma_map_ops {
 			size_t size, enum dma_data_direction dir,
 			unsigned long attrs);
 	/*
-	 * map_sg returns 0 on error and a value > 0 on success.
-	 * It should never return a value < 0.
+	 * map_sg should return a negative error code on error.
+	 * dma_map_sgtable() will return the error code returned and convert
+	 * a zero return (for legacy implementations) into -EINVAL.
+	 *
+	 * dma_map_sg() will always return zero on any negative or zero
+	 * return to satisfy its own calling convention.
 	 */
 	int (*map_sg)(struct device *dev, struct scatterlist *sg, int nents,
 			enum dma_data_direction dir, unsigned long attrs);
diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index 183e7103a66d..daa1e360f0ee 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -110,6 +110,8 @@ int dma_map_sg_attrs(struct device *dev, struct scatterlist *sg, int nents,
 void dma_unmap_sg_attrs(struct device *dev, struct scatterlist *sg,
 				      int nents, enum dma_data_direction dir,
 				      unsigned long attrs);
+int dma_map_sgtable(struct device *dev, struct sg_table *sgt,
+		enum dma_data_direction dir, unsigned long attrs);
 dma_addr_t dma_map_resource(struct device *dev, phys_addr_t phys_addr,
 		size_t size, enum dma_data_direction dir, unsigned long attrs);
 void dma_unmap_resource(struct device *dev, dma_addr_t addr, size_t size,
@@ -174,6 +176,11 @@ static inline void dma_unmap_sg_attrs(struct device *dev,
 		unsigned long attrs)
 {
 }
+static inline int dma_map_sgtable(struct device *dev, struct sg_table *sgt,
+		enum dma_data_direction dir, unsigned long attrs)
+{
+	return -EOPNOTSUPP;
+}
 static inline dma_addr_t dma_map_resource(struct device *dev,
 		phys_addr_t phys_addr, size_t size, enum dma_data_direction dir,
 		unsigned long attrs)
@@ -343,34 +350,6 @@ static inline void dma_sync_single_range_for_device(struct device *dev,
 	return dma_sync_single_for_device(dev, addr + offset, size, dir);
 }
 
-/**
- * dma_map_sgtable - Map the given buffer for DMA
- * @dev:	The device for which to perform the DMA operation
- * @sgt:	The sg_table object describing the buffer
- * @dir:	DMA direction
- * @attrs:	Optional DMA attributes for the map operation
- *
- * Maps a buffer described by a scatterlist stored in the given sg_table
- * object for the @dir DMA operation by the @dev device. After success the
- * ownership for the buffer is transferred to the DMA domain.  One has to
- * call dma_sync_sgtable_for_cpu() or dma_unmap_sgtable() to move the
- * ownership of the buffer back to the CPU domain before touching the
- * buffer by the CPU.
- *
- * Returns 0 on success or -EINVAL on error during mapping the buffer.
- */
-static inline int dma_map_sgtable(struct device *dev, struct sg_table *sgt,
-		enum dma_data_direction dir, unsigned long attrs)
-{
-	int nents;
-
-	nents = dma_map_sg_attrs(dev, sgt->sgl, sgt->orig_nents, dir, attrs);
-	if (nents <= 0)
-		return -EINVAL;
-	sgt->nents = nents;
-	return 0;
-}
-
 /**
  * dma_unmap_sgtable - Unmap the given buffer for DMA
  * @dev:	The device for which to perform the DMA operation
diff --git a/kernel/dma/mapping.c b/kernel/dma/mapping.c
index 2b06a809d0b9..30f89d244566 100644
--- a/kernel/dma/mapping.c
+++ b/kernel/dma/mapping.c
@@ -177,12 +177,8 @@ void dma_unmap_page_attrs(struct device *dev, dma_addr_t addr, size_t size,
 }
 EXPORT_SYMBOL(dma_unmap_page_attrs);
 
-/*
- * dma_maps_sg_attrs returns 0 on error and > 0 on success.
- * It should never return a value < 0.
- */
-int dma_map_sg_attrs(struct device *dev, struct scatterlist *sg, int nents,
-		enum dma_data_direction dir, unsigned long attrs)
+static int __dma_map_sg_attrs(struct device *dev, struct scatterlist *sg,
+	 int nents, enum dma_data_direction dir, unsigned long attrs)
 {
 	const struct dma_map_ops *ops = get_dma_ops(dev);
 	int ents;
@@ -197,13 +193,74 @@ int dma_map_sg_attrs(struct device *dev, struct scatterlist *sg, int nents,
 		ents = dma_direct_map_sg(dev, sg, nents, dir, attrs);
 	else
 		ents = ops->map_sg(dev, sg, nents, dir, attrs);
-	BUG_ON(ents < 0);
-	debug_dma_map_sg(dev, sg, nents, ents, dir);
+
+	if (ents > 0)
+		debug_dma_map_sg(dev, sg, nents, ents, dir);
 
 	return ents;
 }
+
+/**
+ * dma_map_sg_attrs - Map the given buffer for DMA
+ * @dev:	The device for which to perform the DMA operation
+ * @sg:	The sg_table object describing the buffer
+ * @dir:	DMA direction
+ * @attrs:	Optional DMA attributes for the map operation
+ *
+ * Maps a buffer described by a scatterlist passed in the sg argument with
+ * nents segments for the @dir DMA operation by the @dev device.
+ *
+ * Returns the number of mapped entries (which can be less than nents)
+ * on success. Zero is returned for any error.
+ *
+ * dma_unmap_sg_attrs() should be used to unmap the buffer with the
+ * original sg and original nents (not the value returned by this funciton).
+ */
+int dma_map_sg_attrs(struct device *dev, struct scatterlist *sg,
+		    int nents, enum dma_data_direction dir, unsigned long attrs)
+{
+	int ret;
+
+	ret = __dma_map_sg_attrs(dev, sg, nents, dir, attrs);
+	if (ret < 0)
+		ret = 0;
+
+	return ret;
+}
 EXPORT_SYMBOL(dma_map_sg_attrs);
 
+/**
+ * dma_map_sgtable - Map the given buffer for DMA
+ * @dev:	The device for which to perform the DMA operation
+ * @sgt:	The sg_table object describing the buffer
+ * @dir:	DMA direction
+ * @attrs:	Optional DMA attributes for the map operation
+ *
+ * Maps a buffer described by a scatterlist stored in the given sg_table
+ * object for the @dir DMA operation by the @dev device. After success, the
+ * ownership for the buffer is transferred to the DMA domain.  One has to
+ * call dma_sync_sgtable_for_cpu() or dma_unmap_sgtable() to move the
+ * ownership of the buffer back to the CPU domain before touching the
+ * buffer by the CPU.
+ *
+ * Returns 0 on success or a negative error code on error
+ */
+int dma_map_sgtable(struct device *dev, struct sg_table *sgt,
+		    enum dma_data_direction dir, unsigned long attrs)
+{
+	int nents;
+
+	nents = __dma_map_sg_attrs(dev, sgt->sgl, sgt->orig_nents, dir, attrs);
+	if (nents = 0)
+		return -EINVAL;
+	else if (nents < 0)
+		return nents;
+
+	sgt->nents = nents;
+	return 0;
+}
+EXPORT_SYMBOL(dma_map_sgtable);
+
 void dma_unmap_sg_attrs(struct device *dev, struct scatterlist *sg,
 				      int nents, enum dma_data_direction dir,
 				      unsigned long attrs)
-- 
2.20.1
