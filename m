From: Andrew Morton <akpm@osdl.org>
Date: Mon, 22 Mar 2004 09:36:00 +0000
Subject: Re: 2.6.5-rc2 lots of warnings for dma_error
Message-Id: <20040322013600.0c6dc0dc.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <5631.1079924674@kao2.melbourne.sgi.com>
In-Reply-To: <5631.1079924674@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith Owens <kaos@sgi.com> wrote:
>
> 2.6.5-rc2 generic build, lots of warnings for dma_error.  Latest patch from
> http://www.kernel.org/pub/linux/kernel/ports/ia64/v2.6/testing/cset/cset-1.1661.1.156-to-1.1668.txt.gz
> makes no difference.
> 
> In file included from include/asm/pci.h:58,
>                  from include/linux/pci.h:720,
>                  from fs/compat_ioctl.c:58,
>                  from arch/ia64/ia32/ia32_ioctl.c:15:
> include/asm-generic/pci-dma-compat.h: In function `pci_dma_error':
> include/asm-generic/pci-dma-compat.h:104: warning: implicit declaration of function `dma_error'
> 

Yes, sorry, that patch was, umm, a little less complete than I had believed.

This adds the necessary stubs for ia64 and builds OK with my config, but it
needs a double-check.

---

 25-akpm/arch/ia64/lib/swiotlb.c           |    7 +++++++
 25-akpm/arch/ia64/sn/io/machvec/pci_dma.c |   13 +++++++++++++
 25-akpm/include/asm-ia64/dma-mapping.h    |    1 +
 25-akpm/include/asm-ia64/machvec.h        |    8 ++++++++
 25-akpm/include/asm-ia64/machvec_sn2.h    |    2 ++
 include/asm-ia64/machvec_hpzx1.h          |    0 
 6 files changed, 31 insertions(+)

diff -puN include/asm-ia64/dma-mapping.h~ia64-dma_error-fix include/asm-ia64/dma-mapping.h
--- 25/include/asm-ia64/dma-mapping.h~ia64-dma_error-fix	Mon Mar 22 03:49:29 2004
+++ 25-akpm/include/asm-ia64/dma-mapping.h	Mon Mar 22 03:50:06 2004
@@ -18,6 +18,7 @@
 #define dma_sync_sg_for_cpu	platform_dma_sync_sg_for_cpu
 #define dma_sync_single_for_device platform_dma_sync_single_for_device
 #define dma_sync_sg_for_device	platform_dma_sync_sg_for_device
+#define dma_error		platform_dma_error
 
 #define dma_map_page(dev, pg, off, size, dir)				\
 	dma_map_single(dev, page_address(pg) + (off), (size), (dir))
diff -puN include/asm-ia64/machvec.h~ia64-dma_error-fix include/asm-ia64/machvec.h
--- 25/include/asm-ia64/machvec.h~ia64-dma_error-fix	Mon Mar 22 03:50:26 2004
+++ 25-akpm/include/asm-ia64/machvec.h	Mon Mar 22 03:59:29 2004
@@ -46,6 +46,7 @@ typedef void ia64_mv_dma_sync_single_for
 typedef void ia64_mv_dma_sync_sg_for_cpu (struct device *, struct scatterlist *, int, int);
 typedef void ia64_mv_dma_sync_single_for_device (struct device *, dma_addr_t, size_t, int);
 typedef void ia64_mv_dma_sync_sg_for_device (struct device *, struct scatterlist *, int, int);
+typedef int ia64_mv_dma_error (dma_addr_t dma_addr);
 typedef int ia64_mv_dma_supported (struct device *, u64);
 
 /*
@@ -110,6 +111,7 @@ extern void machvec_memory_fence (void);
 #  define platform_dma_sync_sg_for_cpu	ia64_mv.dma_sync_sg_for_cpu
 #  define platform_dma_sync_single_for_device ia64_mv.dma_sync_single_for_device
 #  define platform_dma_sync_sg_for_device ia64_mv.dma_sync_sg_for_device
+#  define platform_dma_error		ia64_mv.dma_error
 #  define platform_dma_supported	ia64_mv.dma_supported
 #  define platform_irq_desc		ia64_mv.irq_desc
 #  define platform_irq_to_vector	ia64_mv.irq_to_vector
@@ -158,6 +160,7 @@ struct ia64_machine_vector {
 	ia64_mv_dma_sync_sg_for_cpu *dma_sync_sg_for_cpu;
 	ia64_mv_dma_sync_single_for_device *dma_sync_single_for_device;
 	ia64_mv_dma_sync_sg_for_device *dma_sync_sg_for_device;
+	ia64_mv_dma_error *dma_error
 	ia64_mv_dma_supported *dma_supported;
 	ia64_mv_irq_desc *irq_desc;
 	ia64_mv_irq_to_vector *irq_to_vector;
@@ -202,6 +205,7 @@ struct ia64_machine_vector {
 	platform_dma_sync_sg_for_cpu,		\
 	platform_dma_sync_single_for_device,	\
 	platform_dma_sync_sg_for_device,	\
+	platform_dma_error,			\
 	platform_dma_supported,			\
 	platform_irq_desc,			\
 	platform_irq_to_vector,			\
@@ -243,6 +247,7 @@ extern ia64_mv_dma_sync_single_for_cpu	s
 extern ia64_mv_dma_sync_sg_for_cpu	swiotlb_sync_sg_for_cpu;
 extern ia64_mv_dma_sync_single_for_device swiotlb_sync_single_for_device;
 extern ia64_mv_dma_sync_sg_for_device	swiotlb_sync_sg_for_device;
+extern ia64_mv_dma_error		swiotlb_dma_error;
 extern ia64_mv_dma_supported		swiotlb_dma_supported;
 
 /*
@@ -312,6 +317,9 @@ extern ia64_mv_dma_supported		swiotlb_dm
 #ifndef platform_dma_sync_sg_for_device
 # define platform_dma_sync_sg_for_device	swiotlb_sync_sg_for_device
 #endif
+#ifndef platform_dma_error
+# define platform_dma_error		swiotlb_dma_error
+#endif
 #ifndef platform_dma_supported
 # define  platform_dma_supported	swiotlb_dma_supported
 #endif
diff -puN include/asm-ia64/machvec_hpzx1.h~ia64-dma_error-fix include/asm-ia64/machvec_hpzx1.h
diff -puN include/asm-ia64/machvec_sn2.h~ia64-dma_error-fix include/asm-ia64/machvec_sn2.h
--- 25/include/asm-ia64/machvec_sn2.h~ia64-dma_error-fix	Mon Mar 22 03:50:39 2004
+++ 25-akpm/include/asm-ia64/machvec_sn2.h	Mon Mar 22 03:55:46 2004
@@ -66,6 +66,7 @@ extern ia64_mv_dma_sync_single_for_cpu	s
 extern ia64_mv_dma_sync_sg_for_cpu	sn_dma_sync_sg_for_cpu;
 extern ia64_mv_dma_sync_single_for_device sn_dma_sync_single_for_device;
 extern ia64_mv_dma_sync_sg_for_device	sn_dma_sync_sg_for_device;
+extern ia64_mv_dma_error	sn_dma_error;
 extern ia64_mv_dma_supported		sn_dma_supported;
 
 /*
@@ -111,6 +112,7 @@ extern ia64_mv_dma_supported		sn_dma_sup
 #define platform_dma_sync_sg_for_cpu	sn_dma_sync_sg_for_cpu
 #define platform_dma_sync_single_for_device sn_dma_sync_single_for_device
 #define platform_dma_sync_sg_for_device	sn_dma_sync_sg_for_device
+#define platform_dma_error		sn_dma_error
 #define platform_dma_supported		sn_dma_supported
 
 #include <asm/sn/sn2/io.h>
diff -puN arch/ia64/lib/swiotlb.c~ia64-dma_error-fix arch/ia64/lib/swiotlb.c
--- 25/arch/ia64/lib/swiotlb.c~ia64-dma_error-fix	Mon Mar 22 03:56:01 2004
+++ 25-akpm/arch/ia64/lib/swiotlb.c	Mon Mar 22 04:05:44 2004
@@ -498,6 +498,12 @@ swiotlb_sync_sg_for_device (struct devic
 			sync_single(hwdev, (void *) sg->dma_address, sg->dma_length, dir);
 }
 
+int
+swiotlb_dma_error(dma_addr_t dma_addr)
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
+EXPORT_SYMBOL(swiotlb_dma_error);
 EXPORT_SYMBOL(swiotlb_alloc_coherent);
 EXPORT_SYMBOL(swiotlb_free_coherent);
 EXPORT_SYMBOL(swiotlb_dma_supported);
diff -puN arch/ia64/sn/io/machvec/pci_dma.c~ia64-dma_error-fix arch/ia64/sn/io/machvec/pci_dma.c
--- 25/arch/ia64/sn/io/machvec/pci_dma.c~ia64-dma_error-fix	Mon Mar 22 03:56:05 2004
+++ 25-akpm/arch/ia64/sn/io/machvec/pci_dma.c	Mon Mar 22 03:57:44 2004
@@ -483,6 +483,12 @@ sn_pci_dma_sync_sg_for_device(struct pci
 	return;
 }
 
+int
+sn_dma_error(dma_addr_t dma_addr)
+{
+	return 0;
+}
+
 /**
  * sn_dma_supported - test a DMA mask
  * @hwdev: device to test
@@ -652,6 +658,13 @@ sn_dma_sync_sg_for_device(struct device 
 }
 EXPORT_SYMBOL(sn_dma_sync_sg_for_device);
 
+void
+sn_dma_error(dma_addr_t dma_addr)
+{
+	return 0;
+}
+
+EXPORT_SYMBOL(sn_dma_error);
 EXPORT_SYMBOL(sn_pci_unmap_single);
 EXPORT_SYMBOL(sn_pci_map_single);
 EXPORT_SYMBOL(sn_pci_dma_sync_single_for_cpu);

_

