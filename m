From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Mon, 05 Jan 2009 14:36:14 +0000
Subject: [PATCH 09/13] remove dma operations in struct ia64_machine_vector
Message-Id: <1231166178-20050-10-git-send-email-fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1231166178-20050-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-2-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-3-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-4-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-5-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-6-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-7-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-8-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-9-git-send-email-fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <1231166178-20050-9-git-send-email-fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>

We don't need dma operation hooks in struct ia64_machine_vector
now. This also removes unused ia64_mv_dma_* typedefs.

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 arch/ia64/hp/common/hwsw_iommu.c              |   20 ++++--
 arch/ia64/include/asm/machvec.h               |   89 -------------------------
 arch/ia64/include/asm/machvec_dig_vtd.h       |   20 ------
 arch/ia64/include/asm/machvec_hpzx1.h         |   20 ------
 arch/ia64/include/asm/machvec_hpzx1_swiotlb.h |   25 -------
 arch/ia64/include/asm/machvec_sn2.h           |   24 -------
 6 files changed, 12 insertions(+), 186 deletions(-)

diff --git a/arch/ia64/hp/common/hwsw_iommu.c b/arch/ia64/hp/common/hwsw_iommu.c
index 22145de..5cf750e 100644
--- a/arch/ia64/hp/common/hwsw_iommu.c
+++ b/arch/ia64/hp/common/hwsw_iommu.c
@@ -22,14 +22,18 @@ extern int swiotlb_late_init_with_default_size (size_t size);
 
 /* hwiommu declarations & definitions: */
 
-extern ia64_mv_dma_alloc_coherent	sba_alloc_coherent;
-extern ia64_mv_dma_free_coherent	sba_free_coherent;
-extern ia64_mv_dma_map_single_attrs	sba_map_single_attrs;
-extern ia64_mv_dma_unmap_single_attrs	sba_unmap_single_attrs;
-extern ia64_mv_dma_map_sg_attrs		sba_map_sg_attrs;
-extern ia64_mv_dma_unmap_sg_attrs	sba_unmap_sg_attrs;
-extern ia64_mv_dma_supported		sba_dma_supported;
-extern ia64_mv_dma_mapping_error	sba_dma_mapping_error;
+extern void *sba_alloc_coherent(struct device *, size_t, dma_addr_t *, gfp_t);
+extern void sba_free_coherent (struct device *, size_t, void *, dma_addr_t);
+extern dma_addr_t sba_map_single_attrs(struct device *, void *, size_t, int,
+				       struct dma_attrs *);
+extern void sba_unmap_single_attrs(struct device *, dma_addr_t, size_t, int,
+				   struct dma_attrs *);
+extern int sba_map_sg_attrs(struct device *, struct scatterlist *, int, int,
+			    struct dma_attrs *);
+extern void sba_unmap_sg_attrs(struct device *, struct scatterlist *, int, int,
+			       struct dma_attrs *);
+extern int sba_dma_supported (struct device *, u64);
+extern int sba_dma_mapping_error(struct device *, dma_addr_t);
 
 #define hwiommu_alloc_coherent		sba_alloc_coherent
 #define hwiommu_free_coherent		sba_free_coherent
diff --git a/arch/ia64/include/asm/machvec.h b/arch/ia64/include/asm/machvec.h
index d40722c..6be3010 100644
--- a/arch/ia64/include/asm/machvec.h
+++ b/arch/ia64/include/asm/machvec.h
@@ -45,23 +45,6 @@ typedef void ia64_mv_kernel_launch_event_t(void);
 
 /* DMA-mapping interface: */
 typedef void ia64_mv_dma_init (void);
-typedef void *ia64_mv_dma_alloc_coherent (struct device *, size_t, dma_addr_t *, gfp_t);
-typedef void ia64_mv_dma_free_coherent (struct device *, size_t, void *, dma_addr_t);
-typedef dma_addr_t ia64_mv_dma_map_single (struct device *, void *, size_t, int);
-typedef void ia64_mv_dma_unmap_single (struct device *, dma_addr_t, size_t, int);
-typedef int ia64_mv_dma_map_sg (struct device *, struct scatterlist *, int, int);
-typedef void ia64_mv_dma_unmap_sg (struct device *, struct scatterlist *, int, int);
-typedef void ia64_mv_dma_sync_single_for_cpu (struct device *, dma_addr_t, size_t, int);
-typedef void ia64_mv_dma_sync_sg_for_cpu (struct device *, struct scatterlist *, int, int);
-typedef void ia64_mv_dma_sync_single_for_device (struct device *, dma_addr_t, size_t, int);
-typedef void ia64_mv_dma_sync_sg_for_device (struct device *, struct scatterlist *, int, int);
-typedef int ia64_mv_dma_mapping_error(struct device *, dma_addr_t dma_addr);
-typedef int ia64_mv_dma_supported (struct device *, u64);
-
-typedef dma_addr_t ia64_mv_dma_map_single_attrs (struct device *, void *, size_t, int, struct dma_attrs *);
-typedef void ia64_mv_dma_unmap_single_attrs (struct device *, dma_addr_t, size_t, int, struct dma_attrs *);
-typedef int ia64_mv_dma_map_sg_attrs (struct device *, struct scatterlist *, int, int, struct dma_attrs *);
-typedef void ia64_mv_dma_unmap_sg_attrs (struct device *, struct scatterlist *, int, int, struct dma_attrs *);
 
 /*
  * WARNING: The legacy I/O space is _architected_.  Platforms are
@@ -147,18 +130,6 @@ extern void machvec_tlb_migrate_finish (struct mm_struct *);
 #  define platform_global_tlb_purge	ia64_mv.global_tlb_purge
 #  define platform_tlb_migrate_finish	ia64_mv.tlb_migrate_finish
 #  define platform_dma_init		ia64_mv.dma_init
-#  define platform_dma_alloc_coherent	ia64_mv.dma_alloc_coherent
-#  define platform_dma_free_coherent	ia64_mv.dma_free_coherent
-#  define platform_dma_map_single_attrs	ia64_mv.dma_map_single_attrs
-#  define platform_dma_unmap_single_attrs	ia64_mv.dma_unmap_single_attrs
-#  define platform_dma_map_sg_attrs	ia64_mv.dma_map_sg_attrs
-#  define platform_dma_unmap_sg_attrs	ia64_mv.dma_unmap_sg_attrs
-#  define platform_dma_sync_single_for_cpu ia64_mv.dma_sync_single_for_cpu
-#  define platform_dma_sync_sg_for_cpu	ia64_mv.dma_sync_sg_for_cpu
-#  define platform_dma_sync_single_for_device ia64_mv.dma_sync_single_for_device
-#  define platform_dma_sync_sg_for_device ia64_mv.dma_sync_sg_for_device
-#  define platform_dma_mapping_error		ia64_mv.dma_mapping_error
-#  define platform_dma_supported	ia64_mv.dma_supported
 #  define platform_irq_to_vector	ia64_mv.irq_to_vector
 #  define platform_local_vector_to_irq	ia64_mv.local_vector_to_irq
 #  define platform_pci_get_legacy_mem	ia64_mv.pci_get_legacy_mem
@@ -201,18 +172,6 @@ struct ia64_machine_vector {
 	ia64_mv_global_tlb_purge_t *global_tlb_purge;
 	ia64_mv_tlb_migrate_finish_t *tlb_migrate_finish;
 	ia64_mv_dma_init *dma_init;
-	ia64_mv_dma_alloc_coherent *dma_alloc_coherent;
-	ia64_mv_dma_free_coherent *dma_free_coherent;
-	ia64_mv_dma_map_single_attrs *dma_map_single_attrs;
-	ia64_mv_dma_unmap_single_attrs *dma_unmap_single_attrs;
-	ia64_mv_dma_map_sg_attrs *dma_map_sg_attrs;
-	ia64_mv_dma_unmap_sg_attrs *dma_unmap_sg_attrs;
-	ia64_mv_dma_sync_single_for_cpu *dma_sync_single_for_cpu;
-	ia64_mv_dma_sync_sg_for_cpu *dma_sync_sg_for_cpu;
-	ia64_mv_dma_sync_single_for_device *dma_sync_single_for_device;
-	ia64_mv_dma_sync_sg_for_device *dma_sync_sg_for_device;
-	ia64_mv_dma_mapping_error *dma_mapping_error;
-	ia64_mv_dma_supported *dma_supported;
 	ia64_mv_irq_to_vector *irq_to_vector;
 	ia64_mv_local_vector_to_irq *local_vector_to_irq;
 	ia64_mv_pci_get_legacy_mem_t *pci_get_legacy_mem;
@@ -251,18 +210,6 @@ struct ia64_machine_vector {
 	platform_global_tlb_purge,		\
 	platform_tlb_migrate_finish,		\
 	platform_dma_init,			\
-	platform_dma_alloc_coherent,		\
-	platform_dma_free_coherent,		\
-	platform_dma_map_single_attrs,		\
-	platform_dma_unmap_single_attrs,	\
-	platform_dma_map_sg_attrs,		\
-	platform_dma_unmap_sg_attrs,		\
-	platform_dma_sync_single_for_cpu,	\
-	platform_dma_sync_sg_for_cpu,		\
-	platform_dma_sync_single_for_device,	\
-	platform_dma_sync_sg_for_device,	\
-	platform_dma_mapping_error,			\
-	platform_dma_supported,			\
 	platform_irq_to_vector,			\
 	platform_local_vector_to_irq,		\
 	platform_pci_get_legacy_mem,		\
@@ -332,42 +279,6 @@ extern void swiotlb_dma_init(void);
 #ifndef platform_dma_init
 # define platform_dma_init		swiotlb_dma_init
 #endif
-#ifndef platform_dma_alloc_coherent
-# define platform_dma_alloc_coherent	swiotlb_alloc_coherent
-#endif
-#ifndef platform_dma_free_coherent
-# define platform_dma_free_coherent	swiotlb_free_coherent
-#endif
-#ifndef platform_dma_map_single_attrs
-# define platform_dma_map_single_attrs	swiotlb_map_single_attrs
-#endif
-#ifndef platform_dma_unmap_single_attrs
-# define platform_dma_unmap_single_attrs	swiotlb_unmap_single_attrs
-#endif
-#ifndef platform_dma_map_sg_attrs
-# define platform_dma_map_sg_attrs	swiotlb_map_sg_attrs
-#endif
-#ifndef platform_dma_unmap_sg_attrs
-# define platform_dma_unmap_sg_attrs	swiotlb_unmap_sg_attrs
-#endif
-#ifndef platform_dma_sync_single_for_cpu
-# define platform_dma_sync_single_for_cpu	swiotlb_sync_single_for_cpu
-#endif
-#ifndef platform_dma_sync_sg_for_cpu
-# define platform_dma_sync_sg_for_cpu		swiotlb_sync_sg_for_cpu
-#endif
-#ifndef platform_dma_sync_single_for_device
-# define platform_dma_sync_single_for_device	swiotlb_sync_single_for_device
-#endif
-#ifndef platform_dma_sync_sg_for_device
-# define platform_dma_sync_sg_for_device	swiotlb_sync_sg_for_device
-#endif
-#ifndef platform_dma_mapping_error
-# define platform_dma_mapping_error		swiotlb_dma_mapping_error
-#endif
-#ifndef platform_dma_supported
-# define  platform_dma_supported	swiotlb_dma_supported
-#endif
 #ifndef platform_irq_to_vector
 # define platform_irq_to_vector		__ia64_irq_to_vector
 #endif
diff --git a/arch/ia64/include/asm/machvec_dig_vtd.h b/arch/ia64/include/asm/machvec_dig_vtd.h
index 3400b56..6ab1de5 100644
--- a/arch/ia64/include/asm/machvec_dig_vtd.h
+++ b/arch/ia64/include/asm/machvec_dig_vtd.h
@@ -2,14 +2,6 @@
 #define _ASM_IA64_MACHVEC_DIG_VTD_h
 
 extern ia64_mv_setup_t			dig_setup;
-extern ia64_mv_dma_alloc_coherent	vtd_alloc_coherent;
-extern ia64_mv_dma_free_coherent	vtd_free_coherent;
-extern ia64_mv_dma_map_single_attrs	vtd_map_single_attrs;
-extern ia64_mv_dma_unmap_single_attrs	vtd_unmap_single_attrs;
-extern ia64_mv_dma_map_sg_attrs		vtd_map_sg_attrs;
-extern ia64_mv_dma_unmap_sg_attrs	vtd_unmap_sg_attrs;
-extern ia64_mv_dma_supported		iommu_dma_supported;
-extern ia64_mv_dma_mapping_error	vtd_dma_mapping_error;
 extern ia64_mv_dma_init			pci_iommu_alloc;
 
 /*
@@ -22,17 +14,5 @@ extern ia64_mv_dma_init			pci_iommu_alloc;
 #define platform_name				"dig_vtd"
 #define platform_setup				dig_setup
 #define platform_dma_init			pci_iommu_alloc
-#define platform_dma_alloc_coherent		vtd_alloc_coherent
-#define platform_dma_free_coherent		vtd_free_coherent
-#define platform_dma_map_single_attrs		vtd_map_single_attrs
-#define platform_dma_unmap_single_attrs		vtd_unmap_single_attrs
-#define platform_dma_map_sg_attrs		vtd_map_sg_attrs
-#define platform_dma_unmap_sg_attrs		vtd_unmap_sg_attrs
-#define platform_dma_sync_single_for_cpu	machvec_dma_sync_single
-#define platform_dma_sync_sg_for_cpu		machvec_dma_sync_sg
-#define platform_dma_sync_single_for_device	machvec_dma_sync_single
-#define platform_dma_sync_sg_for_device		machvec_dma_sync_sg
-#define platform_dma_supported			iommu_dma_supported
-#define platform_dma_mapping_error		vtd_dma_mapping_error
 
 #endif /* _ASM_IA64_MACHVEC_DIG_VTD_h */
diff --git a/arch/ia64/include/asm/machvec_hpzx1.h b/arch/ia64/include/asm/machvec_hpzx1.h
index dd4140b..3bd83d7 100644
--- a/arch/ia64/include/asm/machvec_hpzx1.h
+++ b/arch/ia64/include/asm/machvec_hpzx1.h
@@ -3,14 +3,6 @@
 
 extern ia64_mv_setup_t			dig_setup;
 extern ia64_mv_dma_init			sba_dma_init;
-extern ia64_mv_dma_alloc_coherent	sba_alloc_coherent;
-extern ia64_mv_dma_free_coherent	sba_free_coherent;
-extern ia64_mv_dma_map_single_attrs	sba_map_single_attrs;
-extern ia64_mv_dma_unmap_single_attrs	sba_unmap_single_attrs;
-extern ia64_mv_dma_map_sg_attrs		sba_map_sg_attrs;
-extern ia64_mv_dma_unmap_sg_attrs	sba_unmap_sg_attrs;
-extern ia64_mv_dma_supported		sba_dma_supported;
-extern ia64_mv_dma_mapping_error	sba_dma_mapping_error;
 
 /*
  * This stuff has dual use!
@@ -22,17 +14,5 @@ extern ia64_mv_dma_mapping_error	sba_dma_mapping_error;
 #define platform_name				"hpzx1"
 #define platform_setup				dig_setup
 #define platform_dma_init			sba_dma_init
-#define platform_dma_alloc_coherent		sba_alloc_coherent
-#define platform_dma_free_coherent		sba_free_coherent
-#define platform_dma_map_single_attrs		sba_map_single_attrs
-#define platform_dma_unmap_single_attrs		sba_unmap_single_attrs
-#define platform_dma_map_sg_attrs		sba_map_sg_attrs
-#define platform_dma_unmap_sg_attrs		sba_unmap_sg_attrs
-#define platform_dma_sync_single_for_cpu	machvec_dma_sync_single
-#define platform_dma_sync_sg_for_cpu		machvec_dma_sync_sg
-#define platform_dma_sync_single_for_device	machvec_dma_sync_single
-#define platform_dma_sync_sg_for_device		machvec_dma_sync_sg
-#define platform_dma_supported			sba_dma_supported
-#define platform_dma_mapping_error		sba_dma_mapping_error
 
 #endif /* _ASM_IA64_MACHVEC_HPZX1_h */
diff --git a/arch/ia64/include/asm/machvec_hpzx1_swiotlb.h b/arch/ia64/include/asm/machvec_hpzx1_swiotlb.h
index a842cdd..48c3a35 100644
--- a/arch/ia64/include/asm/machvec_hpzx1_swiotlb.h
+++ b/arch/ia64/include/asm/machvec_hpzx1_swiotlb.h
@@ -2,18 +2,6 @@
 #define _ASM_IA64_MACHVEC_HPZX1_SWIOTLB_h
 
 extern ia64_mv_setup_t				dig_setup;
-extern ia64_mv_dma_alloc_coherent		hwsw_alloc_coherent;
-extern ia64_mv_dma_free_coherent		hwsw_free_coherent;
-extern ia64_mv_dma_map_single_attrs		hwsw_map_single_attrs;
-extern ia64_mv_dma_unmap_single_attrs		hwsw_unmap_single_attrs;
-extern ia64_mv_dma_map_sg_attrs			hwsw_map_sg_attrs;
-extern ia64_mv_dma_unmap_sg_attrs		hwsw_unmap_sg_attrs;
-extern ia64_mv_dma_supported			hwsw_dma_supported;
-extern ia64_mv_dma_mapping_error		hwsw_dma_mapping_error;
-extern ia64_mv_dma_sync_single_for_cpu		hwsw_sync_single_for_cpu;
-extern ia64_mv_dma_sync_sg_for_cpu		hwsw_sync_sg_for_cpu;
-extern ia64_mv_dma_sync_single_for_device	hwsw_sync_single_for_device;
-extern ia64_mv_dma_sync_sg_for_device		hwsw_sync_sg_for_device;
 
 /*
  * This stuff has dual use!
@@ -23,20 +11,7 @@ extern ia64_mv_dma_sync_sg_for_device		hwsw_sync_sg_for_device;
  * the macros are used directly.
  */
 #define platform_name				"hpzx1_swiotlb"
-
 #define platform_setup				dig_setup
 #define platform_dma_init			machvec_noop
-#define platform_dma_alloc_coherent		hwsw_alloc_coherent
-#define platform_dma_free_coherent		hwsw_free_coherent
-#define platform_dma_map_single_attrs		hwsw_map_single_attrs
-#define platform_dma_unmap_single_attrs		hwsw_unmap_single_attrs
-#define platform_dma_map_sg_attrs		hwsw_map_sg_attrs
-#define platform_dma_unmap_sg_attrs		hwsw_unmap_sg_attrs
-#define platform_dma_supported			hwsw_dma_supported
-#define platform_dma_mapping_error		hwsw_dma_mapping_error
-#define platform_dma_sync_single_for_cpu	hwsw_sync_single_for_cpu
-#define platform_dma_sync_sg_for_cpu		hwsw_sync_sg_for_cpu
-#define platform_dma_sync_single_for_device	hwsw_sync_single_for_device
-#define platform_dma_sync_sg_for_device		hwsw_sync_sg_for_device
 
 #endif /* _ASM_IA64_MACHVEC_HPZX1_SWIOTLB_h */
diff --git a/arch/ia64/include/asm/machvec_sn2.h b/arch/ia64/include/asm/machvec_sn2.h
index c1f6f87..afd029b 100644
--- a/arch/ia64/include/asm/machvec_sn2.h
+++ b/arch/ia64/include/asm/machvec_sn2.h
@@ -56,18 +56,6 @@ extern ia64_mv_readw_t __sn_readw_relaxed;
 extern ia64_mv_readl_t __sn_readl_relaxed;
 extern ia64_mv_readq_t __sn_readq_relaxed;
 extern ia64_mv_dma_init			sn_dma_init;
-extern ia64_mv_dma_alloc_coherent	sn_dma_alloc_coherent;
-extern ia64_mv_dma_free_coherent	sn_dma_free_coherent;
-extern ia64_mv_dma_map_single_attrs	sn_dma_map_single_attrs;
-extern ia64_mv_dma_unmap_single_attrs	sn_dma_unmap_single_attrs;
-extern ia64_mv_dma_map_sg_attrs		sn_dma_map_sg_attrs;
-extern ia64_mv_dma_unmap_sg_attrs	sn_dma_unmap_sg_attrs;
-extern ia64_mv_dma_sync_single_for_cpu	sn_dma_sync_single_for_cpu;
-extern ia64_mv_dma_sync_sg_for_cpu	sn_dma_sync_sg_for_cpu;
-extern ia64_mv_dma_sync_single_for_device sn_dma_sync_single_for_device;
-extern ia64_mv_dma_sync_sg_for_device	sn_dma_sync_sg_for_device;
-extern ia64_mv_dma_mapping_error	sn_dma_mapping_error;
-extern ia64_mv_dma_supported		sn_dma_supported;
 extern ia64_mv_migrate_t		sn_migrate;
 extern ia64_mv_kernel_launch_event_t	sn_kernel_launch_event;
 extern ia64_mv_setup_msi_irq_t		sn_setup_msi_irq;
@@ -112,18 +100,6 @@ extern ia64_mv_pci_fixup_bus_t		sn_pci_fixup_bus;
 #define platform_pci_legacy_read	sn_pci_legacy_read
 #define platform_pci_legacy_write	sn_pci_legacy_write
 #define platform_dma_init		sn_dma_init
-#define platform_dma_alloc_coherent	sn_dma_alloc_coherent
-#define platform_dma_free_coherent	sn_dma_free_coherent
-#define platform_dma_map_single_attrs	sn_dma_map_single_attrs
-#define platform_dma_unmap_single_attrs	sn_dma_unmap_single_attrs
-#define platform_dma_map_sg_attrs	sn_dma_map_sg_attrs
-#define platform_dma_unmap_sg_attrs	sn_dma_unmap_sg_attrs
-#define platform_dma_sync_single_for_cpu sn_dma_sync_single_for_cpu
-#define platform_dma_sync_sg_for_cpu	sn_dma_sync_sg_for_cpu
-#define platform_dma_sync_single_for_device sn_dma_sync_single_for_device
-#define platform_dma_sync_sg_for_device	sn_dma_sync_sg_for_device
-#define platform_dma_mapping_error		sn_dma_mapping_error
-#define platform_dma_supported		sn_dma_supported
 #define platform_migrate		sn_migrate
 #define platform_kernel_launch_event    sn_kernel_launch_event
 #ifdef CONFIG_PCI_MSI
-- 
1.6.0.6

