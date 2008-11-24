From: John Keller <jpk@sgi.com>
Date: Mon, 24 Nov 2008 22:47:17 +0000
Subject: [RESEND] [PATCH] ia64: SN specific version of dma_get_required_mask()
Message-Id: <20081124224717.146112.95150.81843@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: fujita.tomonori@lab.ntt.co.jp, linux-kernel@vger.kernel.org, John Keller <jpk@sgi.com>

Create a platform specific version of dma_get_required_mask()
for ia64 SN Altix. All SN Altix platforms support 64 bit DMA
addressing regardless of the size of system memory.
Create an ia64 machvec for dma_get_required_mask, with the
SN version unconditionally returning DMA_64BIT_MASK.

Signed-off-by: John Keller <jpk@sgi.com>
---

Resend #1: Eliminate the need to #ifndef CONFIG_IA64
	   the "extern dma_get_required_mask" line in
	   linux/dma-mapping.h.

 Documentation/DMA-API.txt            |    9 +++-----
 arch/ia64/include/asm/dma-mapping.h  |    2 +
 arch/ia64/include/asm/machvec.h      |    7 ++++++
 arch/ia64/include/asm/machvec_init.h |    1 
 arch/ia64/include/asm/machvec_sn2.h  |    2 +
 arch/ia64/pci/pci.c                  |   27 +++++++++++++++++++++++++
 arch/ia64/sn/pci/pci_dma.c           |    6 +++++
 7 files changed, 49 insertions(+), 5 deletions(-)


Index: linux-2.6/arch/ia64/include/asm/machvec_sn2.h
=================================--- linux-2.6.orig/arch/ia64/include/asm/machvec_sn2.h	2008-11-20 13:35:14.633381799 -0600
+++ linux-2.6/arch/ia64/include/asm/machvec_sn2.h	2008-11-20 13:39:26.984955064 -0600
@@ -67,6 +67,7 @@ extern ia64_mv_dma_sync_single_for_devic
 extern ia64_mv_dma_sync_sg_for_device	sn_dma_sync_sg_for_device;
 extern ia64_mv_dma_mapping_error	sn_dma_mapping_error;
 extern ia64_mv_dma_supported		sn_dma_supported;
+extern ia64_mv_dma_get_required_mask	sn_dma_get_required_mask;
 extern ia64_mv_migrate_t		sn_migrate;
 extern ia64_mv_kernel_launch_event_t	sn_kernel_launch_event;
 extern ia64_mv_setup_msi_irq_t		sn_setup_msi_irq;
@@ -123,6 +124,7 @@ extern ia64_mv_pci_fixup_bus_t		sn_pci_f
 #define platform_dma_sync_sg_for_device	sn_dma_sync_sg_for_device
 #define platform_dma_mapping_error		sn_dma_mapping_error
 #define platform_dma_supported		sn_dma_supported
+#define platform_dma_get_required_mask	sn_dma_get_required_mask
 #define platform_migrate		sn_migrate
 #define platform_kernel_launch_event    sn_kernel_launch_event
 #ifdef CONFIG_PCI_MSI
Index: linux-2.6/Documentation/DMA-API.txt
=================================--- linux-2.6.orig/Documentation/DMA-API.txt	2008-11-20 13:35:14.633381799 -0600
+++ linux-2.6/Documentation/DMA-API.txt	2008-11-20 13:39:26.992956065 -0600
@@ -170,16 +170,15 @@ Returns: 0 if successful and a negative 
 u64
 dma_get_required_mask(struct device *dev)
 
-After setting the mask with dma_set_mask(), this API returns the
-actual mask (within that already set) that the platform actually
-requires to operate efficiently.  Usually this means the returned mask
+This API returns the mask that the platform requires to
+operate efficiently.  Usually this means the returned mask
 is the minimum required to cover all of memory.  Examining the
 required mask gives drivers with variable descriptor sizes the
 opportunity to use smaller descriptors as necessary.
 
 Requesting the required mask does not alter the current mask.  If you
-wish to take advantage of it, you should issue another dma_set_mask()
-call to lower the mask again.
+wish to take advantage of it, you should issue a dma_set_mask()
+call to set the mask to the value returned.
 
 
 Part Id - Streaming DMA mappings
Index: linux-2.6/arch/ia64/include/asm/dma-mapping.h
=================================--- linux-2.6.orig/arch/ia64/include/asm/dma-mapping.h	2008-11-20 13:35:14.633381799 -0600
+++ linux-2.6/arch/ia64/include/asm/dma-mapping.h	2008-11-20 13:39:27.012958568 -0600
@@ -9,6 +9,8 @@
 #include <linux/scatterlist.h>
 #include <asm/swiotlb.h>
 
+#define ARCH_HAS_DMA_GET_REQUIRED_MASK
+
 struct dma_mapping_ops {
 	int             (*mapping_error)(struct device *dev,
 					 dma_addr_t dma_addr);
Index: linux-2.6/arch/ia64/include/asm/machvec.h
=================================--- linux-2.6.orig/arch/ia64/include/asm/machvec.h	2008-11-20 13:35:14.633381799 -0600
+++ linux-2.6/arch/ia64/include/asm/machvec.h	2008-11-20 13:39:27.028960570 -0600
@@ -62,6 +62,7 @@ typedef dma_addr_t ia64_mv_dma_map_singl
 typedef void ia64_mv_dma_unmap_single_attrs (struct device *, dma_addr_t, size_t, int, struct dma_attrs *);
 typedef int ia64_mv_dma_map_sg_attrs (struct device *, struct scatterlist *, int, int, struct dma_attrs *);
 typedef void ia64_mv_dma_unmap_sg_attrs (struct device *, struct scatterlist *, int, int, struct dma_attrs *);
+typedef u64 ia64_mv_dma_get_required_mask (struct device *);
 
 /*
  * WARNING: The legacy I/O space is _architected_.  Platforms are
@@ -159,6 +160,7 @@ extern void machvec_tlb_migrate_finish (
 #  define platform_dma_sync_sg_for_device ia64_mv.dma_sync_sg_for_device
 #  define platform_dma_mapping_error		ia64_mv.dma_mapping_error
 #  define platform_dma_supported	ia64_mv.dma_supported
+#  define platform_dma_get_required_mask ia64_mv.dma_get_required_mask
 #  define platform_irq_to_vector	ia64_mv.irq_to_vector
 #  define platform_local_vector_to_irq	ia64_mv.local_vector_to_irq
 #  define platform_pci_get_legacy_mem	ia64_mv.pci_get_legacy_mem
@@ -213,6 +215,7 @@ struct ia64_machine_vector {
 	ia64_mv_dma_sync_sg_for_device *dma_sync_sg_for_device;
 	ia64_mv_dma_mapping_error *dma_mapping_error;
 	ia64_mv_dma_supported *dma_supported;
+	ia64_mv_dma_get_required_mask *dma_get_required_mask;
 	ia64_mv_irq_to_vector *irq_to_vector;
 	ia64_mv_local_vector_to_irq *local_vector_to_irq;
 	ia64_mv_pci_get_legacy_mem_t *pci_get_legacy_mem;
@@ -263,6 +266,7 @@ struct ia64_machine_vector {
 	platform_dma_sync_sg_for_device,	\
 	platform_dma_mapping_error,			\
 	platform_dma_supported,			\
+	platform_dma_get_required_mask,		\
 	platform_irq_to_vector,			\
 	platform_local_vector_to_irq,		\
 	platform_pci_get_legacy_mem,		\
@@ -366,6 +370,9 @@ extern void machvec_init_from_cmdline(co
 #ifndef platform_dma_supported
 # define  platform_dma_supported	swiotlb_dma_supported
 #endif
+#ifndef platform_dma_get_required_mask
+# define  platform_dma_get_required_mask	ia64_dma_get_required_mask
+#endif
 #ifndef platform_irq_to_vector
 # define platform_irq_to_vector		__ia64_irq_to_vector
 #endif
Index: linux-2.6/arch/ia64/sn/pci/pci_dma.c
=================================--- linux-2.6.orig/arch/ia64/sn/pci/pci_dma.c	2008-11-20 13:35:14.633381799 -0600
+++ linux-2.6/arch/ia64/sn/pci/pci_dma.c	2008-11-20 13:39:27.048963072 -0600
@@ -356,6 +356,12 @@ int sn_dma_mapping_error(struct device *
 }
 EXPORT_SYMBOL(sn_dma_mapping_error);
 
+u64 sn_dma_get_required_mask(struct device *dev)
+{
+	return DMA_64BIT_MASK;
+}
+EXPORT_SYMBOL_GPL(sn_dma_get_required_mask);
+
 char *sn_pci_get_legacy_mem(struct pci_bus *bus)
 {
 	if (!SN_PCIBUS_BUSSOFT(bus))
Index: linux-2.6/arch/ia64/pci/pci.c
=================================--- linux-2.6.orig/arch/ia64/pci/pci.c	2008-11-20 13:35:14.633381799 -0600
+++ linux-2.6/arch/ia64/pci/pci.c	2008-11-20 13:39:27.064965074 -0600
@@ -19,6 +19,7 @@
 #include <linux/ioport.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
+#include <linux/bootmem.h>
 
 #include <asm/machvec.h>
 #include <asm/page.h>
@@ -748,6 +749,32 @@ static void __init set_pci_cacheline_siz
 	pci_cache_line_size = (1 << cci.pcci_line_size) / 4;
 }
 
+u64 ia64_dma_get_required_mask(struct device *dev)
+{
+	u32 low_totalram = ((max_pfn - 1) << PAGE_SHIFT);
+	u32 high_totalram = ((max_pfn - 1) >> (32 - PAGE_SHIFT));
+	u64 mask;
+
+	if (!high_totalram) {
+		/* convert to mask just covering totalram */
+		low_totalram = (1 << (fls(low_totalram) - 1));
+		low_totalram += low_totalram - 1;
+		mask = low_totalram;
+	} else {
+		high_totalram = (1 << (fls(high_totalram) - 1));
+		high_totalram += high_totalram - 1;
+		mask = (((u64)high_totalram) << 32) + 0xffffffff;
+	}
+	return mask;
+}
+EXPORT_SYMBOL_GPL(ia64_dma_get_required_mask);
+
+u64 dma_get_required_mask(struct device *dev)
+{
+	return platform_dma_get_required_mask(dev);
+}
+EXPORT_SYMBOL_GPL(dma_get_required_mask);
+
 static int __init pcibios_init(void)
 {
 	set_pci_cacheline_size();
Index: linux-2.6/arch/ia64/include/asm/machvec_init.h
=================================--- linux-2.6.orig/arch/ia64/include/asm/machvec_init.h	2008-11-20 13:35:14.633381799 -0600
+++ linux-2.6/arch/ia64/include/asm/machvec_init.h	2008-11-20 13:39:27.084967577 -0600
@@ -3,6 +3,7 @@
 
 extern ia64_mv_send_ipi_t ia64_send_ipi;
 extern ia64_mv_global_tlb_purge_t ia64_global_tlb_purge;
+extern ia64_mv_dma_get_required_mask ia64_dma_get_required_mask;
 extern ia64_mv_irq_to_vector __ia64_irq_to_vector;
 extern ia64_mv_local_vector_to_irq __ia64_local_vector_to_irq;
 extern ia64_mv_pci_get_legacy_mem_t ia64_pci_get_legacy_mem;
