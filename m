From: Andrew Morton <akpm@osdl.org>
Date: Tue, 23 Mar 2004 18:17:56 +0000
Subject: Re: 2.6.5-rc2 lots of warnings for dma_error
Message-Id: <20040323101756.13f8442e.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <5631.1079924674@kao2.melbourne.sgi.com>
In-Reply-To: <5631.1079924674@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Andrew Morton <akpm@osdl.org> wrote:
>
> Andrew Morton <akpm@osdl.org> wrote:
>  >
>  > > But let's put the blame where it belongs: the name space was
>  >  > "polluted" by introducing dma_error().  It certainly must be
>  >  > legal to implement basic APIs using macros.
>  > 
>  >  yes, perhaps it's not too late to change it.  Anton, what will this break?
> 
>  Here's a completer patch.  I'll submit this I think.
> 
> 
> 
>  We're getting namespace collisions from the new dma_error().  Rename it to
>  dma_mapping_error().
> 

Updated ia64 patch:


 25-akpm/arch/ia64/hp/common/sba_iommu.c   |    7 +++++++
 25-akpm/arch/ia64/lib/swiotlb.c           |    7 +++++++
 25-akpm/arch/ia64/sn/io/machvec/pci_dma.c |    7 +++++++
 25-akpm/include/asm-ia64/dma-mapping.h    |    6 ++++++
 25-akpm/include/asm-ia64/machvec.h        |    8 ++++++++
 25-akpm/include/asm-ia64/machvec_hpzx1.h  |    2 ++
 25-akpm/include/asm-ia64/machvec_sn2.h    |    2 ++
 7 files changed, 39 insertions(+)

diff -puN arch/ia64/hp/common/sba_iommu.c~ia64-dma_mapping_error-fix arch/ia64/hp/common/sba_iommu.c
--- 25/arch/ia64/hp/common/sba_iommu.c~ia64-dma_mapping_error-fix	Mon Mar 22 14:34:46 2004
+++ 25-akpm/arch/ia64/hp/common/sba_iommu.c	Mon Mar 22 14:34:46 2004
@@ -1979,6 +1979,12 @@ sba_dma_supported (struct device *dev, u
 	return ((mask & 0xFFFFFFFFUL) = 0xFFFFFFFFUL);
 }
 
+int
+sba_dma_mapping_error (dma_addr_t dma_addr)
+{
+	return 0;
+}
+
 __setup("nosbagart", nosbagart);
 
 static int __init
@@ -2004,6 +2010,7 @@ sba_page_override(char *str)
 
 __setup("sbapagesize=",sba_page_override);
 
+EXPORT_SYMBOL(sba_dma_mapping_error);
 EXPORT_SYMBOL(sba_map_single);
 EXPORT_SYMBOL(sba_unmap_single);
 EXPORT_SYMBOL(sba_map_sg);
diff -puN arch/ia64/lib/swiotlb.c~ia64-dma_mapping_error-fix arch/ia64/lib/swiotlb.c
--- 25/arch/ia64/lib/swiotlb.c~ia64-dma_mapping_error-fix	Mon Mar 22 14:34:46 2004
+++ 25-akpm/arch/ia64/lib/swiotlb.c	Mon Mar 22 14:34:46 2004
@@ -498,6 +498,12 @@ swiotlb_sync_sg_for_device (struct devic
 			sync_single(hwdev, (void *) sg->dma_address, sg->dma_length, dir);
 }
 
+int
+swiotlb_dma_mapping_error(dma_addr_t dma_addr)
+{
+	return 0;
+}
+
 /*
  * Return whether the given PCI device DMA address mask can be supported properly.  For
  * example, if your device can only drive the low 24-bits during PCI bus mastering, then
@@ -518,6 +524,7 @@ EXPORT_SYMBOL(swiotlb_sync_single_for_cp
 EXPORT_SYMBOL(swiotlb_sync_single_for_device);
 EXPORT_SYMBOL(swiotlb_sync_sg_for_cpu);
 EXPORT_SYMBOL(swiotlb_sync_sg_for_device);
+EXPORT_SYMBOL(swiotlb_dma_mapping_error);
 EXPORT_SYMBOL(swiotlb_alloc_coherent);
 EXPORT_SYMBOL(swiotlb_free_coherent);
 EXPORT_SYMBOL(swiotlb_dma_supported);
diff -puN arch/ia64/sn/io/machvec/pci_dma.c~ia64-dma_mapping_error-fix arch/ia64/sn/io/machvec/pci_dma.c
--- 25/arch/ia64/sn/io/machvec/pci_dma.c~ia64-dma_mapping_error-fix	Mon Mar 22 14:34:46 2004
+++ 25-akpm/arch/ia64/sn/io/machvec/pci_dma.c	Mon Mar 22 14:34:46 2004
@@ -652,6 +652,13 @@ sn_dma_sync_sg_for_device(struct device 
 }
 EXPORT_SYMBOL(sn_dma_sync_sg_for_device);
 
+int
+sn_dma_mapping_error(dma_addr_t dma_addr)
+{
+	return 0;
+}
+
+EXPORT_SYMBOL(sn_dma_mapping_error);
 EXPORT_SYMBOL(sn_pci_unmap_single);
 EXPORT_SYMBOL(sn_pci_map_single);
 EXPORT_SYMBOL(sn_pci_dma_sync_single_for_cpu);
diff -puN include/asm-ia64/dma-mapping.h~ia64-dma_mapping_error-fix include/asm-ia64/dma-mapping.h
--- 25/include/asm-ia64/dma-mapping.h~ia64-dma_mapping_error-fix	Mon Mar 22 14:34:46 2004
+++ 25-akpm/include/asm-ia64/dma-mapping.h	Mon Mar 22 14:35:03 2004
@@ -19,6 +19,12 @@
 #define dma_sync_single_for_device platform_dma_sync_single_for_device
 #define dma_sync_sg_for_device	platform_dma_sync_sg_for_device
 
+/* inline function to avoid namespace pollution */
+static inline int dma_mapping_error (dma_addr_t dma_addr)
+{
+	return platform_dma_mapping_error(dma_addr);
+}
+
 #define dma_map_page(dev, pg, off, size, dir)				\
 	dma_map_single(dev, page_address(pg) + (off), (size), (dir))
 #define dma_unmap_page(dev, dma_addr, size, dir)			\
diff -puN include/asm-ia64/machvec.h~ia64-dma_mapping_error-fix include/asm-ia64/machvec.h
--- 25/include/asm-ia64/machvec.h~ia64-dma_mapping_error-fix	Mon Mar 22 14:34:46 2004
+++ 25-akpm/include/asm-ia64/machvec.h	Mon Mar 22 14:34:46 2004
@@ -46,6 +46,7 @@ typedef void ia64_mv_dma_sync_single_for
 typedef void ia64_mv_dma_sync_sg_for_cpu (struct device *, struct scatterlist *, int, int);
 typedef void ia64_mv_dma_sync_single_for_device (struct device *, dma_addr_t, size_t, int);
 typedef void ia64_mv_dma_sync_sg_for_device (struct device *, struct scatterlist *, int, int);
+typedef int ia64_mv_dma_mapping_error (dma_addr_t dma_addr);
 typedef int ia64_mv_dma_supported (struct device *, u64);
 
 /*
@@ -110,6 +111,7 @@ extern void machvec_memory_fence (void);
 #  define platform_dma_sync_sg_for_cpu	ia64_mv.dma_sync_sg_for_cpu
 #  define platform_dma_sync_single_for_device ia64_mv.dma_sync_single_for_device
 #  define platform_dma_sync_sg_for_device ia64_mv.dma_sync_sg_for_device
+#  define platform_dma_mapping_error		ia64_mv.dma_mapping_error
 #  define platform_dma_supported	ia64_mv.dma_supported
 #  define platform_irq_desc		ia64_mv.irq_desc
 #  define platform_irq_to_vector	ia64_mv.irq_to_vector
@@ -158,6 +160,7 @@ struct ia64_machine_vector {
 	ia64_mv_dma_sync_sg_for_cpu *dma_sync_sg_for_cpu;
 	ia64_mv_dma_sync_single_for_device *dma_sync_single_for_device;
 	ia64_mv_dma_sync_sg_for_device *dma_sync_sg_for_device;
+	ia64_mv_dma_mapping_error *dma_mapping_error;
 	ia64_mv_dma_supported *dma_supported;
 	ia64_mv_irq_desc *irq_desc;
 	ia64_mv_irq_to_vector *irq_to_vector;
@@ -202,6 +205,7 @@ struct ia64_machine_vector {
 	platform_dma_sync_sg_for_cpu,		\
 	platform_dma_sync_single_for_device,	\
 	platform_dma_sync_sg_for_device,	\
+	platform_dma_mapping_error,			\
 	platform_dma_supported,			\
 	platform_irq_desc,			\
 	platform_irq_to_vector,			\
@@ -243,6 +247,7 @@ extern ia64_mv_dma_sync_single_for_cpu	s
 extern ia64_mv_dma_sync_sg_for_cpu	swiotlb_sync_sg_for_cpu;
 extern ia64_mv_dma_sync_single_for_device swiotlb_sync_single_for_device;
 extern ia64_mv_dma_sync_sg_for_device	swiotlb_sync_sg_for_device;
+extern ia64_mv_dma_mapping_error		swiotlb_dma_mapping_error;
 extern ia64_mv_dma_supported		swiotlb_dma_supported;
 
 /*
@@ -312,6 +317,9 @@ extern ia64_mv_dma_supported		swiotlb_dm
 #ifndef platform_dma_sync_sg_for_device
 # define platform_dma_sync_sg_for_device	swiotlb_sync_sg_for_device
 #endif
+#ifndef platform_dma_mapping_error
+# define platform_dma_mapping_error		swiotlb_dma_mapping_error
+#endif
 #ifndef platform_dma_supported
 # define  platform_dma_supported	swiotlb_dma_supported
 #endif
diff -puN include/asm-ia64/machvec_hpzx1.h~ia64-dma_mapping_error-fix include/asm-ia64/machvec_hpzx1.h
--- 25/include/asm-ia64/machvec_hpzx1.h~ia64-dma_mapping_error-fix	Mon Mar 22 14:34:46 2004
+++ 25-akpm/include/asm-ia64/machvec_hpzx1.h	Mon Mar 22 14:34:46 2004
@@ -9,6 +9,7 @@ extern ia64_mv_dma_unmap_single		sba_unm
 extern ia64_mv_dma_map_sg		sba_map_sg;
 extern ia64_mv_dma_unmap_sg		sba_unmap_sg;
 extern ia64_mv_dma_supported		sba_dma_supported;
+extern ia64_mv_dma_mapping_error		sba_dma_mapping_error;
 
 /*
  * This stuff has dual use!
@@ -31,5 +32,6 @@ extern ia64_mv_dma_supported		sba_dma_su
 #define platform_dma_sync_single_for_device ((ia64_mv_dma_sync_single_for_device *) machvec_memory_fence)
 #define platform_dma_sync_sg_for_device	((ia64_mv_dma_sync_sg_for_device *) machvec_memory_fence)
 #define platform_dma_supported		sba_dma_supported
+#define platform_dma_mapping_error		sba_dma_mapping_error
 
 #endif /* _ASM_IA64_MACHVEC_HPZX1_h */
diff -puN include/asm-ia64/machvec_sn2.h~ia64-dma_mapping_error-fix include/asm-ia64/machvec_sn2.h
--- 25/include/asm-ia64/machvec_sn2.h~ia64-dma_mapping_error-fix	Mon Mar 22 14:34:46 2004
+++ 25-akpm/include/asm-ia64/machvec_sn2.h	Mon Mar 22 14:34:46 2004
@@ -66,6 +66,7 @@ extern ia64_mv_dma_sync_single_for_cpu	s
 extern ia64_mv_dma_sync_sg_for_cpu	sn_dma_sync_sg_for_cpu;
 extern ia64_mv_dma_sync_single_for_device sn_dma_sync_single_for_device;
 extern ia64_mv_dma_sync_sg_for_device	sn_dma_sync_sg_for_device;
+extern ia64_mv_dma_mapping_error	sn_dma_mapping_error;
 extern ia64_mv_dma_supported		sn_dma_supported;
 
 /*
@@ -111,6 +112,7 @@ extern ia64_mv_dma_supported		sn_dma_sup
 #define platform_dma_sync_sg_for_cpu	sn_dma_sync_sg_for_cpu
 #define platform_dma_sync_single_for_device sn_dma_sync_single_for_device
 #define platform_dma_sync_sg_for_device	sn_dma_sync_sg_for_device
+#define platform_dma_mapping_error		sn_dma_mapping_error
 #define platform_dma_supported		sn_dma_supported
 
 #include <asm/sn/sn2/io.h>

_

