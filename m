From: Christoph Hellwig <hch@lst.de>
Date: Mon, 30 Jul 2018 16:38:08 +0000
Subject: [PATCH 04/20] ia64: remove get_required_mask implementation
Message-Id: <20180730163824.10064-5-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180730163824.10064-1-hch@lst.de>
In-Reply-To: <20180730163824.10064-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Robin Murphy <robin.murphy@arm.com>, linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-ia64@vger.kernel.org

ia64 can use the generic implementation in general, and SN2 can just
override it in the dma_map_ops now.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/ia64/include/asm/dma-mapping.h  |  2 --
 arch/ia64/include/asm/machvec.h      |  7 -------
 arch/ia64/include/asm/machvec_init.h |  1 -
 arch/ia64/include/asm/machvec_sn2.h  |  2 --
 arch/ia64/pci/pci.c                  | 26 --------------------------
 arch/ia64/sn/pci/pci_dma.c           |  4 ++--
 6 files changed, 2 insertions(+), 40 deletions(-)

diff --git a/arch/ia64/include/asm/dma-mapping.h b/arch/ia64/include/asm/dma-mapping.h
index 76e4d6632d68..522745ae67bb 100644
--- a/arch/ia64/include/asm/dma-mapping.h
+++ b/arch/ia64/include/asm/dma-mapping.h
@@ -10,8 +10,6 @@
 #include <linux/scatterlist.h>
 #include <linux/dma-debug.h>
 
-#define ARCH_HAS_DMA_GET_REQUIRED_MASK
-
 extern const struct dma_map_ops *dma_ops;
 extern struct ia64_machine_vector ia64_mv;
 extern void set_iommu_machvec(void);
diff --git a/arch/ia64/include/asm/machvec.h b/arch/ia64/include/asm/machvec.h
index 267f4f170191..5133739966bc 100644
--- a/arch/ia64/include/asm/machvec.h
+++ b/arch/ia64/include/asm/machvec.h
@@ -44,7 +44,6 @@ typedef void ia64_mv_kernel_launch_event_t(void);
 
 /* DMA-mapping interface: */
 typedef void ia64_mv_dma_init (void);
-typedef u64 ia64_mv_dma_get_required_mask (struct device *);
 typedef const struct dma_map_ops *ia64_mv_dma_get_ops(struct device *);
 
 /*
@@ -127,7 +126,6 @@ extern void machvec_tlb_migrate_finish (struct mm_struct *);
 #  define platform_global_tlb_purge	ia64_mv.global_tlb_purge
 #  define platform_tlb_migrate_finish	ia64_mv.tlb_migrate_finish
 #  define platform_dma_init		ia64_mv.dma_init
-#  define platform_dma_get_required_mask ia64_mv.dma_get_required_mask
 #  define platform_dma_get_ops		ia64_mv.dma_get_ops
 #  define platform_irq_to_vector	ia64_mv.irq_to_vector
 #  define platform_local_vector_to_irq	ia64_mv.local_vector_to_irq
@@ -171,7 +169,6 @@ struct ia64_machine_vector {
 	ia64_mv_global_tlb_purge_t *global_tlb_purge;
 	ia64_mv_tlb_migrate_finish_t *tlb_migrate_finish;
 	ia64_mv_dma_init *dma_init;
-	ia64_mv_dma_get_required_mask *dma_get_required_mask;
 	ia64_mv_dma_get_ops *dma_get_ops;
 	ia64_mv_irq_to_vector *irq_to_vector;
 	ia64_mv_local_vector_to_irq *local_vector_to_irq;
@@ -211,7 +208,6 @@ struct ia64_machine_vector {
 	platform_global_tlb_purge,		\
 	platform_tlb_migrate_finish,		\
 	platform_dma_init,			\
-	platform_dma_get_required_mask,		\
 	platform_dma_get_ops,			\
 	platform_irq_to_vector,			\
 	platform_local_vector_to_irq,		\
@@ -286,9 +282,6 @@ extern const struct dma_map_ops *dma_get_ops(struct device *);
 #ifndef platform_dma_get_ops
 # define platform_dma_get_ops		dma_get_ops
 #endif
-#ifndef platform_dma_get_required_mask
-# define  platform_dma_get_required_mask	ia64_dma_get_required_mask
-#endif
 #ifndef platform_irq_to_vector
 # define platform_irq_to_vector		__ia64_irq_to_vector
 #endif
diff --git a/arch/ia64/include/asm/machvec_init.h b/arch/ia64/include/asm/machvec_init.h
index 2b32fd06b7c6..2aafb69a3787 100644
--- a/arch/ia64/include/asm/machvec_init.h
+++ b/arch/ia64/include/asm/machvec_init.h
@@ -4,7 +4,6 @@
 
 extern ia64_mv_send_ipi_t ia64_send_ipi;
 extern ia64_mv_global_tlb_purge_t ia64_global_tlb_purge;
-extern ia64_mv_dma_get_required_mask ia64_dma_get_required_mask;
 extern ia64_mv_irq_to_vector __ia64_irq_to_vector;
 extern ia64_mv_local_vector_to_irq __ia64_local_vector_to_irq;
 extern ia64_mv_pci_get_legacy_mem_t ia64_pci_get_legacy_mem;
diff --git a/arch/ia64/include/asm/machvec_sn2.h b/arch/ia64/include/asm/machvec_sn2.h
index ece9fa85be88..b5153d300289 100644
--- a/arch/ia64/include/asm/machvec_sn2.h
+++ b/arch/ia64/include/asm/machvec_sn2.h
@@ -55,7 +55,6 @@ extern ia64_mv_readb_t __sn_readb_relaxed;
 extern ia64_mv_readw_t __sn_readw_relaxed;
 extern ia64_mv_readl_t __sn_readl_relaxed;
 extern ia64_mv_readq_t __sn_readq_relaxed;
-extern ia64_mv_dma_get_required_mask	sn_dma_get_required_mask;
 extern ia64_mv_dma_init			sn_dma_init;
 extern ia64_mv_migrate_t		sn_migrate;
 extern ia64_mv_kernel_launch_event_t	sn_kernel_launch_event;
@@ -100,7 +99,6 @@ extern ia64_mv_pci_fixup_bus_t		sn_pci_fixup_bus;
 #define platform_pci_get_legacy_mem	sn_pci_get_legacy_mem
 #define platform_pci_legacy_read	sn_pci_legacy_read
 #define platform_pci_legacy_write	sn_pci_legacy_write
-#define platform_dma_get_required_mask	sn_dma_get_required_mask
 #define platform_dma_init		sn_dma_init
 #define platform_migrate		sn_migrate
 #define platform_kernel_launch_event    sn_kernel_launch_event
diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
index 7ccc64d5fe3e..5d71800df431 100644
--- a/arch/ia64/pci/pci.c
+++ b/arch/ia64/pci/pci.c
@@ -568,32 +568,6 @@ static void __init set_pci_dfl_cacheline_size(void)
 	pci_dfl_cache_line_size = (1 << cci.pcci_line_size) / 4;
 }
 
-u64 ia64_dma_get_required_mask(struct device *dev)
-{
-	u32 low_totalram = ((max_pfn - 1) << PAGE_SHIFT);
-	u32 high_totalram = ((max_pfn - 1) >> (32 - PAGE_SHIFT));
-	u64 mask;
-
-	if (!high_totalram) {
-		/* convert to mask just covering totalram */
-		low_totalram = (1 << (fls(low_totalram) - 1));
-		low_totalram += low_totalram - 1;
-		mask = low_totalram;
-	} else {
-		high_totalram = (1 << (fls(high_totalram) - 1));
-		high_totalram += high_totalram - 1;
-		mask = (((u64)high_totalram) << 32) + 0xffffffff;
-	}
-	return mask;
-}
-EXPORT_SYMBOL_GPL(ia64_dma_get_required_mask);
-
-u64 dma_get_required_mask(struct device *dev)
-{
-	return platform_dma_get_required_mask(dev);
-}
-EXPORT_SYMBOL_GPL(dma_get_required_mask);
-
 static int __init pcibios_init(void)
 {
 	set_pci_dfl_cacheline_size();
diff --git a/arch/ia64/sn/pci/pci_dma.c b/arch/ia64/sn/pci/pci_dma.c
index 74c934a997bb..96eb2567718a 100644
--- a/arch/ia64/sn/pci/pci_dma.c
+++ b/arch/ia64/sn/pci/pci_dma.c
@@ -344,11 +344,10 @@ static int sn_dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
 	return 0;
 }
 
-u64 sn_dma_get_required_mask(struct device *dev)
+static u64 sn_dma_get_required_mask(struct device *dev)
 {
 	return DMA_BIT_MASK(64);
 }
-EXPORT_SYMBOL_GPL(sn_dma_get_required_mask);
 
 char *sn_pci_get_legacy_mem(struct pci_bus *bus)
 {
@@ -473,6 +472,7 @@ static struct dma_map_ops sn_dma_ops = {
 	.sync_sg_for_device	= sn_dma_sync_sg_for_device,
 	.mapping_error		= sn_dma_mapping_error,
 	.dma_supported		= sn_dma_supported,
+	.get_required_mask	= sn_dma_get_required_mask,
 };
 
 void sn_dma_init(void)
-- 
2.18.0

