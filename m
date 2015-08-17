From: Andrew Morton <akpm@linux-foundation.org>
Date: Mon, 17 Aug 2015 21:24:29 +0000
Subject: Re: provide more common DMA API functions V2
Message-Id: <20150817142429.95a3965e0b35d0f35d3c4cfe@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1439795216-32189-1-git-send-email-hch@lst.de>
In-Reply-To: <1439795216-32189-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: arnd@arndb.de, linux@arm.linux.org.uk, catalin.marinas@arm.com, will.deacon@arm.com, ysato@users.sourceforge.jp, monstr@monstr.eu, jonas@southpole.se, cmetcalf@ezchip.com, gxt@mprc.pku.edu.cn, x86@kernel.org, linux-alpha@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, 17 Aug 2015 09:06:51 +0200 Christoph Hellwig <hch@lst.de> wrote:

> Since 2009 we have a nice asm-generic header implementing lots of DMA API
> functions for architectures using struct dma_map_ops, but unfortunately
> it's still missing a lot of APIs that all architectures still have to
> duplicate.
> 
> This series consolidates the remaining functions, although we still
> need arch opt outs for two of them as a few architectures have very
> non-standard implementations.

Looks nice.

This sets us up for a mass deinlining.  I took a quick shot at that and
for x86-64 defconfig I'm seeing

   text    data     bss     dec            hex     filename
62851694   7016109 4483008 74350811        46e80db (TOTALS)
62741440   7016109 4483008 74240557        46cd22d (TOTALS)

110254 bytes saved, shrinking the kernel by a whopping 0.17%. 
Thoughts?


I'll merge these 5 patches for 4.3.  That means I'll release them into
linux-next after 4.2 is released.



--- a/include/asm-generic/dma-mapping-common.h~a
+++ a/include/asm-generic/dma-mapping-common.h
@@ -8,174 +8,53 @@
 #include <linux/dma-attrs.h>
 #include <asm-generic/dma-coherent.h>
 
-static inline dma_addr_t dma_map_single_attrs(struct device *dev, void *ptr,
+dma_addr_t dma_map_single_attrs(struct device *dev, void *ptr,
 					      size_t size,
 					      enum dma_data_direction dir,
-					      struct dma_attrs *attrs)
-{
-	struct dma_map_ops *ops = get_dma_ops(dev);
-	dma_addr_t addr;
-
-	kmemcheck_mark_initialized(ptr, size);
-	BUG_ON(!valid_dma_direction(dir));
-	addr = ops->map_page(dev, virt_to_page(ptr),
-			     (unsigned long)ptr & ~PAGE_MASK, size,
-			     dir, attrs);
-	debug_dma_map_page(dev, virt_to_page(ptr),
-			   (unsigned long)ptr & ~PAGE_MASK, size,
-			   dir, addr, true);
-	return addr;
-}
-
-static inline void dma_unmap_single_attrs(struct device *dev, dma_addr_t addr,
+					      struct dma_attrs *attrs);
+void dma_unmap_single_attrs(struct device *dev, dma_addr_t addr,
 					  size_t size,
 					  enum dma_data_direction dir,
-					  struct dma_attrs *attrs)
-{
-	struct dma_map_ops *ops = get_dma_ops(dev);
-
-	BUG_ON(!valid_dma_direction(dir));
-	if (ops->unmap_page)
-		ops->unmap_page(dev, addr, size, dir, attrs);
-	debug_dma_unmap_page(dev, addr, size, dir, true);
-}
-
+					  struct dma_attrs *attrs);
 /*
  * dma_maps_sg_attrs returns 0 on error and > 0 on success.
  * It should never return a value < 0.
  */
-static inline int dma_map_sg_attrs(struct device *dev, struct scatterlist *sg,
+int dma_map_sg_attrs(struct device *dev, struct scatterlist *sg,
 				   int nents, enum dma_data_direction dir,
-				   struct dma_attrs *attrs)
-{
-	struct dma_map_ops *ops = get_dma_ops(dev);
-	int i, ents;
-	struct scatterlist *s;
-
-	for_each_sg(sg, s, nents, i)
-		kmemcheck_mark_initialized(sg_virt(s), s->length);
-	BUG_ON(!valid_dma_direction(dir));
-	ents = ops->map_sg(dev, sg, nents, dir, attrs);
-	BUG_ON(ents < 0);
-	debug_dma_map_sg(dev, sg, nents, ents, dir);
-
-	return ents;
-}
-
-static inline void dma_unmap_sg_attrs(struct device *dev, struct scatterlist *sg,
+				   struct dma_attrs *attrs);
+void dma_unmap_sg_attrs(struct device *dev, struct scatterlist *sg,
 				      int nents, enum dma_data_direction dir,
-				      struct dma_attrs *attrs)
-{
-	struct dma_map_ops *ops = get_dma_ops(dev);
-
-	BUG_ON(!valid_dma_direction(dir));
-	debug_dma_unmap_sg(dev, sg, nents, dir);
-	if (ops->unmap_sg)
-		ops->unmap_sg(dev, sg, nents, dir, attrs);
-}
-
-static inline dma_addr_t dma_map_page(struct device *dev, struct page *page,
+				      struct dma_attrs *attrs);
+dma_addr_t dma_map_page(struct device *dev, struct page *page,
 				      size_t offset, size_t size,
-				      enum dma_data_direction dir)
-{
-	struct dma_map_ops *ops = get_dma_ops(dev);
-	dma_addr_t addr;
-
-	kmemcheck_mark_initialized(page_address(page) + offset, size);
-	BUG_ON(!valid_dma_direction(dir));
-	addr = ops->map_page(dev, page, offset, size, dir, NULL);
-	debug_dma_map_page(dev, page, offset, size, dir, addr, false);
-
-	return addr;
-}
-
-static inline void dma_unmap_page(struct device *dev, dma_addr_t addr,
-				  size_t size, enum dma_data_direction dir)
-{
-	struct dma_map_ops *ops = get_dma_ops(dev);
-
-	BUG_ON(!valid_dma_direction(dir));
-	if (ops->unmap_page)
-		ops->unmap_page(dev, addr, size, dir, NULL);
-	debug_dma_unmap_page(dev, addr, size, dir, false);
-}
-
-static inline void dma_sync_single_for_cpu(struct device *dev, dma_addr_t addr,
+				      enum dma_data_direction dir);
+void dma_unmap_page(struct device *dev, dma_addr_t addr,
+				  size_t size, enum dma_data_direction dir);
+void dma_sync_single_for_cpu(struct device *dev, dma_addr_t addr,
 					   size_t size,
-					   enum dma_data_direction dir)
-{
-	struct dma_map_ops *ops = get_dma_ops(dev);
-
-	BUG_ON(!valid_dma_direction(dir));
-	if (ops->sync_single_for_cpu)
-		ops->sync_single_for_cpu(dev, addr, size, dir);
-	debug_dma_sync_single_for_cpu(dev, addr, size, dir);
-}
+					   enum dma_data_direction dir);
 
-static inline void dma_sync_single_for_device(struct device *dev,
+void dma_sync_single_for_device(struct device *dev,
 					      dma_addr_t addr, size_t size,
-					      enum dma_data_direction dir)
-{
-	struct dma_map_ops *ops = get_dma_ops(dev);
-
-	BUG_ON(!valid_dma_direction(dir));
-	if (ops->sync_single_for_device)
-		ops->sync_single_for_device(dev, addr, size, dir);
-	debug_dma_sync_single_for_device(dev, addr, size, dir);
-}
-
-static inline void dma_sync_single_range_for_cpu(struct device *dev,
+					      enum dma_data_direction dir);
+void dma_sync_single_range_for_cpu(struct device *dev,
 						 dma_addr_t addr,
 						 unsigned long offset,
 						 size_t size,
-						 enum dma_data_direction dir)
-{
-	const struct dma_map_ops *ops = get_dma_ops(dev);
-
-	BUG_ON(!valid_dma_direction(dir));
-	if (ops->sync_single_for_cpu)
-		ops->sync_single_for_cpu(dev, addr + offset, size, dir);
-	debug_dma_sync_single_range_for_cpu(dev, addr, offset, size, dir);
-}
-
-static inline void dma_sync_single_range_for_device(struct device *dev,
-						    dma_addr_t addr,
-						    unsigned long offset,
-						    size_t size,
-						    enum dma_data_direction dir)
-{
-	const struct dma_map_ops *ops = get_dma_ops(dev);
-
-	BUG_ON(!valid_dma_direction(dir));
-	if (ops->sync_single_for_device)
-		ops->sync_single_for_device(dev, addr + offset, size, dir);
-	debug_dma_sync_single_range_for_device(dev, addr, offset, size, dir);
-}
+						 enum dma_data_direction dir);
 
-static inline void
+void dma_sync_single_range_for_device(struct device *dev,
+					dma_addr_t addr,
+					unsigned long offset,
+					size_t size,
+					enum dma_data_direction dir);
+void
 dma_sync_sg_for_cpu(struct device *dev, struct scatterlist *sg,
-		    int nelems, enum dma_data_direction dir)
-{
-	struct dma_map_ops *ops = get_dma_ops(dev);
-
-	BUG_ON(!valid_dma_direction(dir));
-	if (ops->sync_sg_for_cpu)
-		ops->sync_sg_for_cpu(dev, sg, nelems, dir);
-	debug_dma_sync_sg_for_cpu(dev, sg, nelems, dir);
-}
-
-static inline void
+		    int nelems, enum dma_data_direction dir);
+void
 dma_sync_sg_for_device(struct device *dev, struct scatterlist *sg,
-		       int nelems, enum dma_data_direction dir)
-{
-	struct dma_map_ops *ops = get_dma_ops(dev);
-
-	BUG_ON(!valid_dma_direction(dir));
-	if (ops->sync_sg_for_device)
-		ops->sync_sg_for_device(dev, sg, nelems, dir);
-	debug_dma_sync_sg_for_device(dev, sg, nelems, dir);
-
-}
+		       int nelems, enum dma_data_direction dir);
 
 #define dma_map_single(d, a, s, r) dma_map_single_attrs(d, a, s, r, NULL)
 #define dma_unmap_single(d, a, s, r) dma_unmap_single_attrs(d, a, s, r, NULL)
@@ -194,29 +73,9 @@ void *dma_common_pages_remap(struct page
 			const void *caller);
 void dma_common_free_remap(void *cpu_addr, size_t size, unsigned long vm_flags);
 
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
+int
 dma_mmap_attrs(struct device *dev, struct vm_area_struct *vma, void *cpu_addr,
-	       dma_addr_t dma_addr, size_t size, struct dma_attrs *attrs)
-{
-	struct dma_map_ops *ops = get_dma_ops(dev);
-	BUG_ON(!ops);
-	if (ops->mmap)
-		return ops->mmap(dev, vma, cpu_addr, dma_addr, size, attrs);
-	return dma_common_mmap(dev, vma, cpu_addr, dma_addr, size);
-}
+	       dma_addr_t dma_addr, size_t size, struct dma_attrs *attrs);
 
 #define dma_mmap_coherent(d, v, c, h, s) dma_mmap_attrs(d, v, c, h, s, NULL)
 
@@ -224,17 +83,9 @@ int
 dma_common_get_sgtable(struct device *dev, struct sg_table *sgt,
 		       void *cpu_addr, dma_addr_t dma_addr, size_t size);
 
-static inline int
+int
 dma_get_sgtable_attrs(struct device *dev, struct sg_table *sgt, void *cpu_addr,
-		      dma_addr_t dma_addr, size_t size, struct dma_attrs *attrs)
-{
-	struct dma_map_ops *ops = get_dma_ops(dev);
-	BUG_ON(!ops);
-	if (ops->get_sgtable)
-		return ops->get_sgtable(dev, sgt, cpu_addr, dma_addr, size,
-					attrs);
-	return dma_common_get_sgtable(dev, sgt, cpu_addr, dma_addr, size);
-}
+		dma_addr_t dma_addr, size_t size, struct dma_attrs *attrs);
 
 #define dma_get_sgtable(d, t, v, h, s) dma_get_sgtable_attrs(d, t, v, h, s, NULL)
 
@@ -242,46 +93,13 @@ dma_get_sgtable_attrs(struct device *dev
 #define arch_dma_alloc_attrs(dev, flag)	(true)
 #endif
 
-static inline void *dma_alloc_attrs(struct device *dev, size_t size,
+void *dma_alloc_attrs(struct device *dev, size_t size,
 				       dma_addr_t *dma_handle, gfp_t flag,
-				       struct dma_attrs *attrs)
-{
-	struct dma_map_ops *ops = get_dma_ops(dev);
-	void *cpu_addr;
-
-	BUG_ON(!ops);
-
-	if (dma_alloc_from_coherent(dev, size, dma_handle, &cpu_addr))
-		return cpu_addr;
-
-	if (!arch_dma_alloc_attrs(&dev, &flag))
-		return NULL;
-	if (!ops->alloc)
-		return NULL;
-
-	cpu_addr = ops->alloc(dev, size, dma_handle, flag, attrs);
-	debug_dma_alloc_coherent(dev, size, *dma_handle, cpu_addr);
-	return cpu_addr;
-}
+				       struct dma_attrs *attrs);
 
-static inline void dma_free_attrs(struct device *dev, size_t size,
+void dma_free_attrs(struct device *dev, size_t size,
 				     void *cpu_addr, dma_addr_t dma_handle,
-				     struct dma_attrs *attrs)
-{
-	struct dma_map_ops *ops = get_dma_ops(dev);
-
-	BUG_ON(!ops);
-	WARN_ON(irqs_disabled());
-
-	if (dma_release_from_coherent(dev, get_order(size), cpu_addr))
-		return;
-
-	if (!ops->free)
-		return;
-
-	debug_dma_free_coherent(dev, size, cpu_addr, dma_handle);
-	ops->free(dev, size, cpu_addr, dma_handle, attrs);
-}
+				     struct dma_attrs *attrs);
 
 static inline void *dma_alloc_coherent(struct device *dev, size_t size,
 		dma_addr_t *dma_handle, gfp_t flag)
@@ -295,37 +113,13 @@ static inline void dma_free_coherent(str
 	return dma_free_attrs(dev, size, cpu_addr, dma_handle, NULL);
 }
 
-static inline void *dma_alloc_noncoherent(struct device *dev, size_t size,
-		dma_addr_t *dma_handle, gfp_t gfp)
-{
-	DEFINE_DMA_ATTRS(attrs);
+void *dma_alloc_noncoherent(struct device *dev, size_t size,
+		dma_addr_t *dma_handle, gfp_t gfp);
 
-	dma_set_attr(DMA_ATTR_NON_CONSISTENT, &attrs);
-	return dma_alloc_attrs(dev, size, dma_handle, gfp, &attrs);
-}
+void dma_free_noncoherent(struct device *dev, size_t size,
+		void *cpu_addr, dma_addr_t dma_handle);
 
-static inline void dma_free_noncoherent(struct device *dev, size_t size,
-		void *cpu_addr, dma_addr_t dma_handle)
-{
-	DEFINE_DMA_ATTRS(attrs);
-
-	dma_set_attr(DMA_ATTR_NON_CONSISTENT, &attrs);
-	dma_free_attrs(dev, size, cpu_addr, dma_handle, &attrs);
-}
-
-static inline int dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
-{
-	debug_dma_mapping_error(dev, dma_addr);
-
-	if (get_dma_ops(dev)->mapping_error)
-		return get_dma_ops(dev)->mapping_error(dev, dma_addr);
-
-#ifdef DMA_ERROR_CODE
-	return dma_addr = DMA_ERROR_CODE;
-#else
-	return 0;
-#endif
-}
+int dma_mapping_error(struct device *dev, dma_addr_t dma_addr);
 
 #ifndef HAVE_ARCH_DMA_SUPPORTED
 static inline int dma_supported(struct device *dev, u64 mask)
diff -puN /dev/null /dev/null
diff -puN lib/Kconfig~a lib/Kconfig
diff -puN lib/Makefile~a lib/Makefile
diff -puN drivers/base/dma-mapping.c~a drivers/base/dma-mapping.c
--- a/drivers/base/dma-mapping.c~a
+++ a/drivers/base/dma-mapping.c
@@ -339,3 +339,300 @@ void dma_common_free_remap(void *cpu_add
 	vunmap(cpu_addr);
 }
 #endif
+
+dma_addr_t dma_map_single_attrs(struct device *dev, void *ptr,
+					      size_t size,
+					      enum dma_data_direction dir,
+					      struct dma_attrs *attrs)
+{
+	struct dma_map_ops *ops = get_dma_ops(dev);
+	dma_addr_t addr;
+
+	kmemcheck_mark_initialized(ptr, size);
+	BUG_ON(!valid_dma_direction(dir));
+	addr = ops->map_page(dev, virt_to_page(ptr),
+			     (unsigned long)ptr & ~PAGE_MASK, size,
+			     dir, attrs);
+	debug_dma_map_page(dev, virt_to_page(ptr),
+			   (unsigned long)ptr & ~PAGE_MASK, size,
+			   dir, addr, true);
+	return addr;
+}
+EXPORT_SYMBOL(dma_map_single_attrs);
+
+void dma_unmap_single_attrs(struct device *dev, dma_addr_t addr,
+					  size_t size,
+					  enum dma_data_direction dir,
+					  struct dma_attrs *attrs)
+{
+	struct dma_map_ops *ops = get_dma_ops(dev);
+
+	BUG_ON(!valid_dma_direction(dir));
+	if (ops->unmap_page)
+		ops->unmap_page(dev, addr, size, dir, attrs);
+	debug_dma_unmap_page(dev, addr, size, dir, true);
+}
+EXPORT_SYMBOL(dma_unmap_single_attrs);
+
+/*
+ * dma_maps_sg_attrs returns 0 on error and > 0 on success.
+ * It should never return a value < 0.
+ */
+int dma_map_sg_attrs(struct device *dev, struct scatterlist *sg,
+				   int nents, enum dma_data_direction dir,
+				   struct dma_attrs *attrs)
+{
+	struct dma_map_ops *ops = get_dma_ops(dev);
+	int i, ents;
+	struct scatterlist *s;
+
+	for_each_sg(sg, s, nents, i)
+		kmemcheck_mark_initialized(sg_virt(s), s->length);
+	BUG_ON(!valid_dma_direction(dir));
+	ents = ops->map_sg(dev, sg, nents, dir, attrs);
+	BUG_ON(ents < 0);
+	debug_dma_map_sg(dev, sg, nents, ents, dir);
+
+	return ents;
+}
+EXPORT_SYMBOL(dma_map_sg_attrs);
+
+void dma_unmap_sg_attrs(struct device *dev, struct scatterlist *sg,
+				      int nents, enum dma_data_direction dir,
+				      struct dma_attrs *attrs)
+{
+	struct dma_map_ops *ops = get_dma_ops(dev);
+
+	BUG_ON(!valid_dma_direction(dir));
+	debug_dma_unmap_sg(dev, sg, nents, dir);
+	if (ops->unmap_sg)
+		ops->unmap_sg(dev, sg, nents, dir, attrs);
+}
+EXPORT_SYMBOL(dma_unmap_sg_attrs);
+
+dma_addr_t dma_map_page(struct device *dev, struct page *page,
+				      size_t offset, size_t size,
+				      enum dma_data_direction dir)
+{
+	struct dma_map_ops *ops = get_dma_ops(dev);
+	dma_addr_t addr;
+
+	kmemcheck_mark_initialized(page_address(page) + offset, size);
+	BUG_ON(!valid_dma_direction(dir));
+	addr = ops->map_page(dev, page, offset, size, dir, NULL);
+	debug_dma_map_page(dev, page, offset, size, dir, addr, false);
+
+	return addr;
+}
+EXPORT_SYMBOL(dma_map_page);
+
+void dma_unmap_page(struct device *dev, dma_addr_t addr,
+				  size_t size, enum dma_data_direction dir)
+{
+	struct dma_map_ops *ops = get_dma_ops(dev);
+
+	BUG_ON(!valid_dma_direction(dir));
+	if (ops->unmap_page)
+		ops->unmap_page(dev, addr, size, dir, NULL);
+	debug_dma_unmap_page(dev, addr, size, dir, false);
+}
+EXPORT_SYMBOL(dma_unmap_page);
+
+void dma_sync_single_for_cpu(struct device *dev, dma_addr_t addr,
+					   size_t size,
+					   enum dma_data_direction dir)
+{
+	struct dma_map_ops *ops = get_dma_ops(dev);
+
+	BUG_ON(!valid_dma_direction(dir));
+	if (ops->sync_single_for_cpu)
+		ops->sync_single_for_cpu(dev, addr, size, dir);
+	debug_dma_sync_single_for_cpu(dev, addr, size, dir);
+}
+EXPORT_SYMBOL(dma_sync_single_for_cpu);
+
+void dma_sync_single_for_device(struct device *dev,
+					      dma_addr_t addr, size_t size,
+					      enum dma_data_direction dir)
+{
+	struct dma_map_ops *ops = get_dma_ops(dev);
+
+	BUG_ON(!valid_dma_direction(dir));
+	if (ops->sync_single_for_device)
+		ops->sync_single_for_device(dev, addr, size, dir);
+	debug_dma_sync_single_for_device(dev, addr, size, dir);
+}
+EXPORT_SYMBOL(dma_sync_single_for_device);
+
+void dma_sync_single_range_for_cpu(struct device *dev,
+						 dma_addr_t addr,
+						 unsigned long offset,
+						 size_t size,
+						 enum dma_data_direction dir)
+{
+	const struct dma_map_ops *ops = get_dma_ops(dev);
+
+	BUG_ON(!valid_dma_direction(dir));
+	if (ops->sync_single_for_cpu)
+		ops->sync_single_for_cpu(dev, addr + offset, size, dir);
+	debug_dma_sync_single_range_for_cpu(dev, addr, offset, size, dir);
+}
+EXPORT_SYMBOL(dma_sync_single_range_for_cpu);
+
+void dma_sync_single_range_for_device(struct device *dev,
+						    dma_addr_t addr,
+						    unsigned long offset,
+						    size_t size,
+						    enum dma_data_direction dir)
+{
+	const struct dma_map_ops *ops = get_dma_ops(dev);
+
+	BUG_ON(!valid_dma_direction(dir));
+	if (ops->sync_single_for_device)
+		ops->sync_single_for_device(dev, addr + offset, size, dir);
+	debug_dma_sync_single_range_for_device(dev, addr, offset, size, dir);
+}
+EXPORT_SYMBOL(dma_sync_single_range_for_device);
+
+void
+dma_sync_sg_for_cpu(struct device *dev, struct scatterlist *sg,
+		    int nelems, enum dma_data_direction dir)
+{
+	struct dma_map_ops *ops = get_dma_ops(dev);
+
+	BUG_ON(!valid_dma_direction(dir));
+	if (ops->sync_sg_for_cpu)
+		ops->sync_sg_for_cpu(dev, sg, nelems, dir);
+	debug_dma_sync_sg_for_cpu(dev, sg, nelems, dir);
+}
+EXPORT_SYMBOL(dma_sync_sg_for_cpu);
+
+void
+dma_sync_sg_for_device(struct device *dev, struct scatterlist *sg,
+		       int nelems, enum dma_data_direction dir)
+{
+	struct dma_map_ops *ops = get_dma_ops(dev);
+
+	BUG_ON(!valid_dma_direction(dir));
+	if (ops->sync_sg_for_device)
+		ops->sync_sg_for_device(dev, sg, nelems, dir);
+	debug_dma_sync_sg_for_device(dev, sg, nelems, dir);
+
+}
+EXPORT_SYMBOL(dma_sync_sg_for_device);
+
+/**
+ * dma_mmap_attrs - map a coherent DMA allocation into user space
+ * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
+ * @vma: vm_area_struct describing requested user mapping
+ * @cpu_addr: kernel CPU-view address returned from dma_alloc_attrs
+ * @handle: device-view address returned from dma_alloc_attrs
+ * @size: size of memory originally requested in dma_alloc_attrs
+ * @attrs: attributes of mapping properties requested in dma_alloc_attrs
+ *
+ * Map a coherent DMA buffer previously allocated by dma_alloc_attrs
+ * into user space.  The coherent DMA buffer must not be freed by the
+ * driver until the user space mapping has been released.
+ */
+int
+dma_mmap_attrs(struct device *dev, struct vm_area_struct *vma, void *cpu_addr,
+	       dma_addr_t dma_addr, size_t size, struct dma_attrs *attrs)
+{
+	struct dma_map_ops *ops = get_dma_ops(dev);
+	BUG_ON(!ops);
+	if (ops->mmap)
+		return ops->mmap(dev, vma, cpu_addr, dma_addr, size, attrs);
+	return dma_common_mmap(dev, vma, cpu_addr, dma_addr, size);
+}
+EXPORT_SYMBOL(dma_mmap_attrs);
+
+int
+dma_get_sgtable_attrs(struct device *dev, struct sg_table *sgt, void *cpu_addr,
+		      dma_addr_t dma_addr, size_t size, struct dma_attrs *attrs)
+{
+	struct dma_map_ops *ops = get_dma_ops(dev);
+	BUG_ON(!ops);
+	if (ops->get_sgtable)
+		return ops->get_sgtable(dev, sgt, cpu_addr, dma_addr, size,
+					attrs);
+	return dma_common_get_sgtable(dev, sgt, cpu_addr, dma_addr, size);
+}
+EXPORT_SYMBOL(dma_get_sgtable_attrs);
+
+void *dma_alloc_attrs(struct device *dev, size_t size,
+				       dma_addr_t *dma_handle, gfp_t flag,
+				       struct dma_attrs *attrs)
+{
+	struct dma_map_ops *ops = get_dma_ops(dev);
+	void *cpu_addr;
+
+	BUG_ON(!ops);
+
+	if (dma_alloc_from_coherent(dev, size, dma_handle, &cpu_addr))
+		return cpu_addr;
+
+	if (!arch_dma_alloc_attrs(&dev, &flag))
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
+void dma_free_attrs(struct device *dev, size_t size,
+				     void *cpu_addr, dma_addr_t dma_handle,
+				     struct dma_attrs *attrs)
+{
+	struct dma_map_ops *ops = get_dma_ops(dev);
+
+	BUG_ON(!ops);
+	WARN_ON(irqs_disabled());
+
+	if (dma_release_from_coherent(dev, get_order(size), cpu_addr))
+		return;
+
+	if (!ops->free)
+		return;
+
+	debug_dma_free_coherent(dev, size, cpu_addr, dma_handle);
+	ops->free(dev, size, cpu_addr, dma_handle, attrs);
+}
+EXPORT_SYMBOL(dma_free_attrs);
+
+void *dma_alloc_noncoherent(struct device *dev, size_t size,
+		dma_addr_t *dma_handle, gfp_t gfp)
+{
+	DEFINE_DMA_ATTRS(attrs);
+
+	dma_set_attr(DMA_ATTR_NON_CONSISTENT, &attrs);
+	return dma_alloc_attrs(dev, size, dma_handle, gfp, &attrs);
+}
+EXPORT_SYMBOL(dma_alloc_noncoherent);
+
+void dma_free_noncoherent(struct device *dev, size_t size,
+		void *cpu_addr, dma_addr_t dma_handle)
+{
+	DEFINE_DMA_ATTRS(attrs);
+
+	dma_set_attr(DMA_ATTR_NON_CONSISTENT, &attrs);
+	dma_free_attrs(dev, size, cpu_addr, dma_handle, &attrs);
+}
+EXPORT_SYMBOL(dma_free_noncoherent);
+
+int dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
+{
+	debug_dma_mapping_error(dev, dma_addr);
+
+	if (get_dma_ops(dev)->mapping_error)
+		return get_dma_ops(dev)->mapping_error(dev, dma_addr);
+
+#ifdef DMA_ERROR_CODE
+	return dma_addr = DMA_ERROR_CODE;
+#else
+	return 0;
+#endif
+}
+EXPORT_SYMBOL(dma_mapping_error);
_

