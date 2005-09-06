From: Alex Williamson <alex.williamson@hp.com>
Date: Tue, 06 Sep 2005 17:20:49 +0000
Subject: [PATCH] more robust zx1/sx1000 machvec support
Message-Id: <1126027250.5426.48.camel@tdi>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


   Machine vector selection has always been a bit of a hack given how
early in system boot it needs to be done.  Services like ACPI namespace
are not available and there are non-trivial problems to moving them to
early boot.  However, there's no reason we can't change to a different
machvec later in boot when the services we need are available.  By
adding a entry point for later initialization of the swiotlb, we can add
an error path for the hpzx1 machevec initialization and fall back to the
DIG machine vector if IOMMU hardware isn't found in the system.  Since
ia64 uses 4GB for zone DMA (no ISA support), it's trivial to allocate a
contiguous range from the slab for bounce buffer usage.  Please apply,
thanks.

 arch/ia64/hp/common/hwsw_iommu.c         |   13 +++
 arch/ia64/hp/common/sba_iommu.c          |   45 +++++++++----
 arch/ia64/lib/swiotlb.c                  |  102 +++++++++++++++++++++++++++++++
 include/asm-ia64/machvec_hpzx1.h         |   21 +++---
 include/asm-ia64/machvec_hpzx1_swiotlb.h |    3 
 5 files changed, 156 insertions(+), 28 deletions(-)

Signed-off-by: Alex Williamson <alex.williamson@hp.com>

diff -r 645b32bbdbb7 arch/ia64/hp/common/hwsw_iommu.c
--- a/arch/ia64/hp/common/hwsw_iommu.c	Tue Sep  6 12:16:24 2005
+++ b/arch/ia64/hp/common/hwsw_iommu.c	Tue Sep  6 10:18:06 2005
@@ -17,7 +17,7 @@
 #include <asm/machvec.h>
 
 /* swiotlb declarations & definitions: */
-extern void swiotlb_init_with_default_size (size_t size);
+extern int swiotlb_late_init_with_default_size (size_t size);
 extern ia64_mv_dma_alloc_coherent	swiotlb_alloc_coherent;
 extern ia64_mv_dma_free_coherent	swiotlb_free_coherent;
 extern ia64_mv_dma_map_single		swiotlb_map_single;
@@ -67,7 +67,16 @@
 hwsw_init (void)
 {
 	/* default to a smallish 2MB sw I/O TLB */
-	swiotlb_init_with_default_size (2 * (1<<20));
+	if (swiotlb_late_init_with_default_size (2 * (1<<20)) != 0) {
+#ifdef CONFIG_IA64_GENERIC
+		/* Better to have normal DMA than panic */
+		printk(KERN_WARNING "%s: Failed to initialize software I/O TLB,"
+		       " reverting to hpzx1 platform vector\n", __FUNCTION__);
+		machvec_init("hpzx1");
+#else
+		panic("Unable to initialize software I/O TLB services");
+#endif
+	}
 }
 
 void *
diff -r 645b32bbdbb7 arch/ia64/hp/common/sba_iommu.c
--- a/arch/ia64/hp/common/sba_iommu.c	Tue Sep  6 12:16:24 2005
+++ b/arch/ia64/hp/common/sba_iommu.c	Tue Sep  6 10:18:06 2005
@@ -2028,9 +2028,40 @@
 static int __init
 sba_init(void)
 {
+	if (!ia64_platform_is("hpzx1") && !ia64_platform_is("hpzx1_swiotlb"))
+		return 0;
+
 	acpi_bus_register_driver(&acpi_sba_ioc_driver);
-	if (!ioc_list)
+	if (!ioc_list) {
+#ifdef CONFIG_IA64_GENERIC
+		extern int swiotlb_late_init_with_default_size (size_t size);
+
+		/*
+		 * If we didn't find something sba_iommu can claim, we
+		 * need to setup the swiotlb and switch to the dig machvec.
+		 */
+		if (swiotlb_late_init_with_default_size(64 * (1<<20)) != 0)
+			panic("Unable to find SBA IOMMU or initialize "
+			      "software I/O TLB: Try machvec=dig boot option");
+		machvec_init("dig");
+#else
+		panic("Unable to find SBA IOMMU: Try a generic or DIG kernel");
+#endif
 		return 0;
+	}
+
+#if defined(CONFIG_IA64_GENERIC) || defined(CONFIG_IA64_HP_ZX1_SWIOTLB)
+	/*
+	 * hpzx1_swiotlb needs to have a fairly small swiotlb bounce
+	 * buffer setup to support devices with smaller DMA masks than
+	 * sba_iommu can handle.
+	 */
+	if (ia64_platform_is("hpzx1_swiotlb")) {
+		extern void hwsw_init(void);
+
+		hwsw_init();
+	}
+#endif
 
 #ifdef CONFIG_PCI
 	{
@@ -2047,18 +2078,6 @@
 }
 
 subsys_initcall(sba_init); /* must be initialized after ACPI etc., but before any drivers... */
-
-extern void dig_setup(char**);
-/*
- * MAX_DMA_ADDRESS needs to be setup prior to paging_init to do any good,
- * so we use the platform_setup hook to fix it up.
- */
-void __init
-sba_setup(char **cmdline_p)
-{
-	MAX_DMA_ADDRESS = ~0UL;
-	dig_setup(cmdline_p);
-}
 
 static int __init
 nosbagart(char *str)
diff -r 645b32bbdbb7 arch/ia64/lib/swiotlb.c
--- a/arch/ia64/lib/swiotlb.c	Tue Sep  6 12:16:24 2005
+++ b/arch/ia64/lib/swiotlb.c	Tue Sep  6 10:18:06 2005
@@ -49,6 +49,15 @@
  */
 #define IO_TLB_SHIFT 11
 
+#define SLABS_PER_PAGE (1 << (PAGE_SHIFT - IO_TLB_SHIFT))
+
+/*
+ * Minimum IO TLB size to bother booting with.  Systems with mainly
+ * 64bit capable cards will only lightly use the swiotlb.  If we can't
+ * allocate a contiguous 1MB, we're probably in trouble anyway.
+ */
+#define IO_TLB_MIN_SLABS ((1<<20) >> IO_TLB_SHIFT)
+
 int swiotlb_force;
 
 /*
@@ -152,6 +161,99 @@
 swiotlb_init (void)
 {
 	swiotlb_init_with_default_size(64 * (1<<20));	/* default to 64MB */
+}
+
+/*
+ * Systems with larger DMA zones (those that don't support ISA) can
+ * initialize the swiotlb later using the slab allocator if needed.
+ * This should be just like above, but with some error catching.
+ */
+int
+swiotlb_late_init_with_default_size (size_t default_size)
+{
+	unsigned long i, req_nslabs = io_tlb_nslabs;
+	unsigned int order;
+
+	if (!io_tlb_nslabs) {
+		io_tlb_nslabs = (default_size >> IO_TLB_SHIFT);
+		io_tlb_nslabs = ALIGN(io_tlb_nslabs, IO_TLB_SEGSIZE);
+	}
+
+	/*
+	 * Get IO TLB memory from the low pages
+	 */
+	order = get_order(io_tlb_nslabs * (1 << IO_TLB_SHIFT));
+	io_tlb_nslabs = SLABS_PER_PAGE << order;
+
+	while ((SLABS_PER_PAGE << order) > IO_TLB_MIN_SLABS) {
+		io_tlb_start = (char *)__get_free_pages(GFP_DMA | __GFP_NOWARN,
+		                                        order);
+		if (io_tlb_start)
+			break;
+		order--;
+	}
+
+	if (!io_tlb_start)
+		goto cleanup1;
+
+	if (order != get_order(io_tlb_nslabs * (1 << IO_TLB_SHIFT))) {
+		printk(KERN_WARNING "Warning: only able to allocate %ld MB "
+		       "for software IO TLB\n", (PAGE_SIZE << order) >> 20);
+		io_tlb_nslabs = SLABS_PER_PAGE << order;
+	}
+	io_tlb_end = io_tlb_start + io_tlb_nslabs * (1 << IO_TLB_SHIFT);
+	memset(io_tlb_start, 0, io_tlb_nslabs * (1 << IO_TLB_SHIFT));
+
+	/*
+	 * Allocate and initialize the free list array.  This array is used
+	 * to find contiguous free memory regions of size up to IO_TLB_SEGSIZE
+	 * between io_tlb_start and io_tlb_end.
+	 */
+	io_tlb_list = (unsigned int *)__get_free_pages(GFP_KERNEL,
+	                              get_order(io_tlb_nslabs * sizeof(int)));
+	if (!io_tlb_list)
+		goto cleanup2;
+
+	for (i = 0; i < io_tlb_nslabs; i++)
+ 		io_tlb_list[i] = IO_TLB_SEGSIZE - OFFSET(i, IO_TLB_SEGSIZE);
+	io_tlb_index = 0;
+
+	io_tlb_orig_addr = (unsigned char **)__get_free_pages(GFP_KERNEL,
+	                           get_order(io_tlb_nslabs * sizeof(char *)));
+	if (!io_tlb_orig_addr)
+		goto cleanup3;
+
+	memset(io_tlb_orig_addr, 0, io_tlb_nslabs * sizeof(char *));
+
+	/*
+	 * Get the overflow emergency buffer
+	 */
+	io_tlb_overflow_buffer = (void *)__get_free_pages(GFP_DMA,
+	                                          get_order(io_tlb_overflow));
+	if (!io_tlb_overflow_buffer)
+		goto cleanup4;
+
+	printk(KERN_INFO "Placing %ldMB software IO TLB between 0x%lx - "
+	       "0x%lx\n", (io_tlb_nslabs * (1 << IO_TLB_SHIFT)) >> 20,
+	       virt_to_phys(io_tlb_start), virt_to_phys(io_tlb_end));
+
+	return 0;
+
+cleanup4:
+	free_pages((unsigned long)io_tlb_orig_addr, get_order(io_tlb_nslabs *
+	                                                      sizeof(char *)));
+	io_tlb_orig_addr = NULL;
+cleanup3:
+	free_pages((unsigned long)io_tlb_list, get_order(io_tlb_nslabs *
+	                                                 sizeof(int)));
+	io_tlb_list = NULL;
+	io_tlb_end = NULL;
+cleanup2:
+	free_pages((unsigned long)io_tlb_start, order);
+	io_tlb_start = NULL;
+cleanup1:
+	io_tlb_nslabs = req_nslabs;
+	return -ENOMEM;
 }
 
 static inline int
diff -r 645b32bbdbb7 include/asm-ia64/machvec_hpzx1.h
--- a/include/asm-ia64/machvec_hpzx1.h	Tue Sep  6 12:16:24 2005
+++ b/include/asm-ia64/machvec_hpzx1.h	Tue Sep  6 10:18:06 2005
@@ -1,8 +1,7 @@
 #ifndef _ASM_IA64_MACHVEC_HPZX1_h
 #define _ASM_IA64_MACHVEC_HPZX1_h
 
-extern ia64_mv_setup_t dig_setup;
-extern ia64_mv_setup_t			sba_setup;
+extern ia64_mv_setup_t			dig_setup;
 extern ia64_mv_dma_alloc_coherent	sba_alloc_coherent;
 extern ia64_mv_dma_free_coherent	sba_free_coherent;
 extern ia64_mv_dma_map_single		sba_map_single;
@@ -19,15 +18,15 @@
  * platform's machvec structure.  When compiling a non-generic kernel,
  * the macros are used directly.
  */
-#define platform_name			"hpzx1"
-#define platform_setup			sba_setup
-#define platform_dma_init		machvec_noop
-#define platform_dma_alloc_coherent	sba_alloc_coherent
-#define platform_dma_free_coherent	sba_free_coherent
-#define platform_dma_map_single		sba_map_single
-#define platform_dma_unmap_single	sba_unmap_single
-#define platform_dma_map_sg		sba_map_sg
-#define platform_dma_unmap_sg		sba_unmap_sg
+#define platform_name				"hpzx1"
+#define platform_setup				dig_setup
+#define platform_dma_init			machvec_noop
+#define platform_dma_alloc_coherent		sba_alloc_coherent
+#define platform_dma_free_coherent		sba_free_coherent
+#define platform_dma_map_single			sba_map_single
+#define platform_dma_unmap_single		sba_unmap_single
+#define platform_dma_map_sg			sba_map_sg
+#define platform_dma_unmap_sg			sba_unmap_sg
 #define platform_dma_sync_single_for_cpu	machvec_dma_sync_single
 #define platform_dma_sync_sg_for_cpu		machvec_dma_sync_sg
 #define platform_dma_sync_single_for_device	machvec_dma_sync_single
diff -r 645b32bbdbb7 include/asm-ia64/machvec_hpzx1_swiotlb.h
--- a/include/asm-ia64/machvec_hpzx1_swiotlb.h	Tue Sep  6 12:16:24 2005
+++ b/include/asm-ia64/machvec_hpzx1_swiotlb.h	Tue Sep  6 10:18:06 2005
@@ -2,7 +2,6 @@
 #define _ASM_IA64_MACHVEC_HPZX1_SWIOTLB_h
 
 extern ia64_mv_setup_t				dig_setup;
-extern ia64_mv_dma_init				hwsw_init;
 extern ia64_mv_dma_alloc_coherent		hwsw_alloc_coherent;
 extern ia64_mv_dma_free_coherent		hwsw_free_coherent;
 extern ia64_mv_dma_map_single			hwsw_map_single;
@@ -26,7 +25,7 @@
 #define platform_name				"hpzx1_swiotlb"
 
 #define platform_setup				dig_setup
-#define platform_dma_init			hwsw_init
+#define platform_dma_init			machvec_noop
 #define platform_dma_alloc_coherent		hwsw_alloc_coherent
 #define platform_dma_free_coherent		hwsw_free_coherent
 #define platform_dma_map_single			hwsw_map_single



