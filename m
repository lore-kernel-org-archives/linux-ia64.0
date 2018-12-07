From: Christoph Hellwig <hch@lst.de>
Date: Fri, 07 Dec 2018 19:07:14 +0000
Subject: [PATCH 09/15] dma-mapping: move various slow path functions out of line
Message-Id: <20181207190720.18517-10-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181207190720.18517-1-hch@lst.de>
In-Reply-To: <20181207190720.18517-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Tariq Toukan <tariqt@mellanox.com>, Ilias Apalodimas <ilias.apalodimas@linaro.org>, =?UTF-8?q?Toke=20H=C3=B8iland-J=C3=B8rgensen?= <toke@toke.dk>, Robin Murphy <robin.murphy@arm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Keith Busch <keith.busch@intel.com>, Jonathan Derrick <jonathan.derrick@intel.com>, linux-pci@vger.kernel.org, linux-ia64@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org

There is no need to have all setup and coherent allocation / freeing
routines inline.  Move them out of line to keep the implemeation
nicely encapsulated and save some kernel text size.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/powerpc/include/asm/dma-mapping.h |   1 -
 include/linux/dma-mapping.h            | 150 +++----------------------
 kernel/dma/mapping.c                   | 140 ++++++++++++++++++++++-
 3 files changed, 151 insertions(+), 140 deletions(-)

diff --git a/arch/powerpc/include/asm/dma-mapping.h b/arch/powerpc/include/asm/dma-mapping.h
index 8fa394520af6..5201f2b7838c 100644
--- a/arch/powerpc/include/asm/dma-mapping.h
+++ b/arch/powerpc/include/asm/dma-mapping.h
@@ -108,7 +108,6 @@ static inline void set_dma_offset(struct device *dev, dma_addr_t off)
 }
 
 #define HAVE_ARCH_DMA_SET_MASK 1
-extern int dma_set_mask(struct device *dev, u64 dma_mask);
 
 extern u64 __dma_get_required_mask(struct device *dev);
 
diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index 3b431cc58794..0bbce52606c2 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -440,107 +440,24 @@ bool dma_in_atomic_pool(void *start, size_t size);
 void *dma_alloc_from_pool(size_t size, struct page **ret_page, gfp_t flags);
 bool dma_free_from_pool(void *start, size_t size);
 
-/**
- * dma_mmap_attrs - map a coherent DMA allocation into user space
- * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
- * @vma: vm_area_struct describing requested user mapping
- * @cpu_addr: kernel CPU-view address returned from dma_alloc_attrs
- * @handle: device-view address returned from dma_alloc_attrs
- * @size: size of memory originally requested in dma_alloc_attrs
- * @attrs: attributes of mapping properties requested in dma_alloc_attrs
- *
- * Map a coherent DMA buffer previously allocated by dma_alloc_attrs
- * into user space.  The coherent DMA buffer must not be freed by the
- * driver until the user space mapping has been released.
- */
-static inline int
-dma_mmap_attrs(struct device *dev, struct vm_area_struct *vma, void *cpu_addr,
-	       dma_addr_t dma_addr, size_t size, unsigned long attrs)
-{
-	const struct dma_map_ops *ops = get_dma_ops(dev);
-	BUG_ON(!ops);
-	if (ops->mmap)
-		return ops->mmap(dev, vma, cpu_addr, dma_addr, size, attrs);
-	return dma_common_mmap(dev, vma, cpu_addr, dma_addr, size, attrs);
-}
-
+int dma_mmap_attrs(struct device *dev, struct vm_area_struct *vma,
+		void *cpu_addr, dma_addr_t dma_addr, size_t size,
+		unsigned long attrs);
 #define dma_mmap_coherent(d, v, c, h, s) dma_mmap_attrs(d, v, c, h, s, 0)
 
 int
 dma_common_get_sgtable(struct device *dev, struct sg_table *sgt, void *cpu_addr,
 		dma_addr_t dma_addr, size_t size, unsigned long attrs);
 
-static inline int
-dma_get_sgtable_attrs(struct device *dev, struct sg_table *sgt, void *cpu_addr,
-		      dma_addr_t dma_addr, size_t size,
-		      unsigned long attrs)
-{
-	const struct dma_map_ops *ops = get_dma_ops(dev);
-	BUG_ON(!ops);
-	if (ops->get_sgtable)
-		return ops->get_sgtable(dev, sgt, cpu_addr, dma_addr, size,
-					attrs);
-	return dma_common_get_sgtable(dev, sgt, cpu_addr, dma_addr, size,
-			attrs);
-}
-
+int dma_get_sgtable_attrs(struct device *dev, struct sg_table *sgt,
+		void *cpu_addr, dma_addr_t dma_addr, size_t size,
+		unsigned long attrs);
 #define dma_get_sgtable(d, t, v, h, s) dma_get_sgtable_attrs(d, t, v, h, s, 0)
 
-#ifndef arch_dma_alloc_attrs
-#define arch_dma_alloc_attrs(dev)	(true)
-#endif
-
-static inline void *dma_alloc_attrs(struct device *dev, size_t size,
-				       dma_addr_t *dma_handle, gfp_t flag,
-				       unsigned long attrs)
-{
-	const struct dma_map_ops *ops = get_dma_ops(dev);
-	void *cpu_addr;
-
-	BUG_ON(!ops);
-	WARN_ON_ONCE(dev && !dev->coherent_dma_mask);
-
-	if (dma_alloc_from_dev_coherent(dev, size, dma_handle, &cpu_addr))
-		return cpu_addr;
-
-	/* let the implementation decide on the zone to allocate from: */
-	flag &= ~(__GFP_DMA | __GFP_DMA32 | __GFP_HIGHMEM);
-
-	if (!arch_dma_alloc_attrs(&dev))
-		return NULL;
-	if (!ops->alloc)
-		return NULL;
-
-	cpu_addr = ops->alloc(dev, size, dma_handle, flag, attrs);
-	debug_dma_alloc_coherent(dev, size, *dma_handle, cpu_addr);
-	return cpu_addr;
-}
-
-static inline void dma_free_attrs(struct device *dev, size_t size,
-				     void *cpu_addr, dma_addr_t dma_handle,
-				     unsigned long attrs)
-{
-	const struct dma_map_ops *ops = get_dma_ops(dev);
-
-	BUG_ON(!ops);
-
-	if (dma_release_from_dev_coherent(dev, get_order(size), cpu_addr))
-		return;
-	/*
-	 * On non-coherent platforms which implement DMA-coherent buffers via
-	 * non-cacheable remaps, ops->free() may call vunmap(). Thus getting
-	 * this far in IRQ context is a) at risk of a BUG_ON() or trying to
-	 * sleep on some machines, and b) an indication that the driver is
-	 * probably misusing the coherent API anyway.
-	 */
-	WARN_ON(irqs_disabled());
-
-	if (!ops->free || !cpu_addr)
-		return;
-
-	debug_dma_free_coherent(dev, size, cpu_addr, dma_handle);
-	ops->free(dev, size, cpu_addr, dma_handle, attrs);
-}
+void *dma_alloc_attrs(struct device *dev, size_t size, dma_addr_t *dma_handle,
+		gfp_t flag, unsigned long attrs);
+void dma_free_attrs(struct device *dev, size_t size, void *cpu_addr,
+		dma_addr_t dma_handle, unsigned long attrs);
 
 static inline void *dma_alloc_coherent(struct device *dev, size_t size,
 		dma_addr_t *dma_handle, gfp_t gfp)
@@ -565,35 +482,9 @@ static inline int dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
 	return 0;
 }
 
-static inline void dma_check_mask(struct device *dev, u64 mask)
-{
-	if (sme_active() && (mask < (((u64)sme_get_me_mask() << 1) - 1)))
-		dev_warn(dev, "SME is active, device will require DMA bounce buffers\n");
-}
-
-static inline int dma_supported(struct device *dev, u64 mask)
-{
-	const struct dma_map_ops *ops = get_dma_ops(dev);
-
-	if (!ops)
-		return 0;
-	if (!ops->dma_supported)
-		return 1;
-	return ops->dma_supported(dev, mask);
-}
-
-#ifndef HAVE_ARCH_DMA_SET_MASK
-static inline int dma_set_mask(struct device *dev, u64 mask)
-{
-	if (!dev->dma_mask || !dma_supported(dev, mask))
-		return -EIO;
-
-	dma_check_mask(dev, mask);
-
-	*dev->dma_mask = mask;
-	return 0;
-}
-#endif
+int dma_supported(struct device *dev, u64 mask);
+int dma_set_mask(struct device *dev, u64 mask);
+int dma_set_coherent_mask(struct device *dev, u64 mask);
 
 static inline u64 dma_get_mask(struct device *dev)
 {
@@ -602,21 +493,6 @@ static inline u64 dma_get_mask(struct device *dev)
 	return DMA_BIT_MASK(32);
 }
 
-#ifdef CONFIG_ARCH_HAS_DMA_SET_COHERENT_MASK
-int dma_set_coherent_mask(struct device *dev, u64 mask);
-#else
-static inline int dma_set_coherent_mask(struct device *dev, u64 mask)
-{
-	if (!dma_supported(dev, mask))
-		return -EIO;
-
-	dma_check_mask(dev, mask);
-
-	dev->coherent_dma_mask = mask;
-	return 0;
-}
-#endif
-
 /*
  * Set both the DMA mask and the coherent DMA mask to the same thing.
  * Note that we don't check the return value from dma_set_coherent_mask()
diff --git a/kernel/dma/mapping.c b/kernel/dma/mapping.c
index dfe29d18dba1..176ae3e08916 100644
--- a/kernel/dma/mapping.c
+++ b/kernel/dma/mapping.c
@@ -223,7 +223,20 @@ int dma_common_get_sgtable(struct device *dev, struct sg_table *sgt,
 		sg_set_page(sgt->sgl, page, PAGE_ALIGN(size), 0);
 	return ret;
 }
-EXPORT_SYMBOL(dma_common_get_sgtable);
+
+int dma_get_sgtable_attrs(struct device *dev, struct sg_table *sgt,
+		void *cpu_addr, dma_addr_t dma_addr, size_t size,
+		unsigned long attrs)
+{
+	const struct dma_map_ops *ops = get_dma_ops(dev);
+	BUG_ON(!ops);
+	if (ops->get_sgtable)
+		return ops->get_sgtable(dev, sgt, cpu_addr, dma_addr, size,
+					attrs);
+	return dma_common_get_sgtable(dev, sgt, cpu_addr, dma_addr, size,
+			attrs);
+}
+EXPORT_SYMBOL(dma_get_sgtable_attrs);
 
 /*
  * Create userspace mapping for the DMA-coherent memory.
@@ -261,7 +274,31 @@ int dma_common_mmap(struct device *dev, struct vm_area_struct *vma,
 	return -ENXIO;
 #endif /* !CONFIG_ARCH_NO_COHERENT_DMA_MMAP */
 }
-EXPORT_SYMBOL(dma_common_mmap);
+
+/**
+ * dma_mmap_attrs - map a coherent DMA allocation into user space
+ * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
+ * @vma: vm_area_struct describing requested user mapping
+ * @cpu_addr: kernel CPU-view address returned from dma_alloc_attrs
+ * @dma_addr: device-view address returned from dma_alloc_attrs
+ * @size: size of memory originally requested in dma_alloc_attrs
+ * @attrs: attributes of mapping properties requested in dma_alloc_attrs
+ *
+ * Map a coherent DMA buffer previously allocated by dma_alloc_attrs into user
+ * space.  The coherent DMA buffer must not be freed by the driver until the
+ * user space mapping has been released.
+ */
+int dma_mmap_attrs(struct device *dev, struct vm_area_struct *vma,
+		void *cpu_addr, dma_addr_t dma_addr, size_t size,
+		unsigned long attrs)
+{
+	const struct dma_map_ops *ops = get_dma_ops(dev);
+	BUG_ON(!ops);
+	if (ops->mmap)
+		return ops->mmap(dev, vma, cpu_addr, dma_addr, size, attrs);
+	return dma_common_mmap(dev, vma, cpu_addr, dma_addr, size, attrs);
+}
+EXPORT_SYMBOL(dma_mmap_attrs);
 
 #ifndef ARCH_HAS_DMA_GET_REQUIRED_MASK
 static u64 dma_default_get_required_mask(struct device *dev)
@@ -294,3 +331,102 @@ u64 dma_get_required_mask(struct device *dev)
 EXPORT_SYMBOL_GPL(dma_get_required_mask);
 #endif
 
+#ifndef arch_dma_alloc_attrs
+#define arch_dma_alloc_attrs(dev)	(true)
+#endif
+
+void *dma_alloc_attrs(struct device *dev, size_t size, dma_addr_t *dma_handle,
+		gfp_t flag, unsigned long attrs)
+{
+	const struct dma_map_ops *ops = get_dma_ops(dev);
+	void *cpu_addr;
+
+	BUG_ON(!ops);
+	WARN_ON_ONCE(dev && !dev->coherent_dma_mask);
+
+	if (dma_alloc_from_dev_coherent(dev, size, dma_handle, &cpu_addr))
+		return cpu_addr;
+
+	/* let the implementation decide on the zone to allocate from: */
+	flag &= ~(__GFP_DMA | __GFP_DMA32 | __GFP_HIGHMEM);
+
+	if (!arch_dma_alloc_attrs(&dev))
+		return NULL;
+	if (!ops->alloc)
+		return NULL;
+
+	cpu_addr = ops->alloc(dev, size, dma_handle, flag, attrs);
+	debug_dma_alloc_coherent(dev, size, *dma_handle, cpu_addr);
+	return cpu_addr;
+}
+EXPORT_SYMBOL(dma_alloc_attrs);
+
+void dma_free_attrs(struct device *dev, size_t size, void *cpu_addr,
+		dma_addr_t dma_handle, unsigned long attrs)
+{
+	const struct dma_map_ops *ops = get_dma_ops(dev);
+
+	BUG_ON(!ops);
+
+	if (dma_release_from_dev_coherent(dev, get_order(size), cpu_addr))
+		return;
+	/*
+	 * On non-coherent platforms which implement DMA-coherent buffers via
+	 * non-cacheable remaps, ops->free() may call vunmap(). Thus getting
+	 * this far in IRQ context is a) at risk of a BUG_ON() or trying to
+	 * sleep on some machines, and b) an indication that the driver is
+	 * probably misusing the coherent API anyway.
+	 */
+	WARN_ON(irqs_disabled());
+
+	if (!ops->free || !cpu_addr)
+		return;
+
+	debug_dma_free_coherent(dev, size, cpu_addr, dma_handle);
+	ops->free(dev, size, cpu_addr, dma_handle, attrs);
+}
+EXPORT_SYMBOL(dma_free_attrs);
+
+static inline void dma_check_mask(struct device *dev, u64 mask)
+{
+	if (sme_active() && (mask < (((u64)sme_get_me_mask() << 1) - 1)))
+		dev_warn(dev, "SME is active, device will require DMA bounce buffers\n");
+}
+
+int dma_supported(struct device *dev, u64 mask)
+{
+	const struct dma_map_ops *ops = get_dma_ops(dev);
+
+	if (!ops)
+		return 0;
+	if (!ops->dma_supported)
+		return 1;
+	return ops->dma_supported(dev, mask);
+}
+EXPORT_SYMBOL(dma_supported);
+
+#ifndef HAVE_ARCH_DMA_SET_MASK
+int dma_set_mask(struct device *dev, u64 mask)
+{
+	if (!dev->dma_mask || !dma_supported(dev, mask))
+		return -EIO;
+
+	dma_check_mask(dev, mask);
+	*dev->dma_mask = mask;
+	return 0;
+}
+EXPORT_SYMBOL(dma_set_mask);
+#endif
+
+#ifndef CONFIG_ARCH_HAS_DMA_SET_COHERENT_MASK
+int dma_set_coherent_mask(struct device *dev, u64 mask)
+{
+	if (!dma_supported(dev, mask))
+		return -EIO;
+
+	dma_check_mask(dev, mask);
+	dev->coherent_dma_mask = mask;
+	return 0;
+}
+EXPORT_SYMBOL(dma_set_coherent_mask);
+#endif
-- 
2.19.1
