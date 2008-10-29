From: akpm@linux-foundation.org
Date: Wed, 29 Oct 2008 21:17:59 +0000
Subject: [patch 2/2] ia64: use common header for software IO/TLB
Message-Id: <200810292117.m9TLHx6n018432@imap1.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Joerg Roedel <joerg.roedel@amd.com>

Remove the swiotlb prototypes from the architecture code and use the
common header file instead.

Signed-off-by: Joerg Roedel <joerg.roedel@amd.com>
Cc: "Luck, Tony" <tony.luck@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/ia64/hp/common/hwsw_iommu.c |    9 +--------
 arch/ia64/include/asm/machvec.h  |   22 +---------------------
 2 files changed, 2 insertions(+), 29 deletions(-)

diff -puN arch/ia64/hp/common/hwsw_iommu.c~ia64-use-common-header-for-software-io-tlb arch/ia64/hp/common/hwsw_iommu.c
--- a/arch/ia64/hp/common/hwsw_iommu.c~ia64-use-common-header-for-software-io-tlb
+++ a/arch/ia64/hp/common/hwsw_iommu.c
@@ -13,19 +13,12 @@
  */
 
 #include <linux/device.h>
+#include <linux/swiotlb.h>
 
 #include <asm/machvec.h>
 
 /* swiotlb declarations & definitions: */
 extern int swiotlb_late_init_with_default_size (size_t size);
-extern ia64_mv_dma_alloc_coherent	swiotlb_alloc_coherent;
-extern ia64_mv_dma_free_coherent	swiotlb_free_coherent;
-extern ia64_mv_dma_map_single_attrs	swiotlb_map_single_attrs;
-extern ia64_mv_dma_unmap_single_attrs	swiotlb_unmap_single_attrs;
-extern ia64_mv_dma_map_sg_attrs		swiotlb_map_sg_attrs;
-extern ia64_mv_dma_unmap_sg_attrs	swiotlb_unmap_sg_attrs;
-extern ia64_mv_dma_supported		swiotlb_dma_supported;
-extern ia64_mv_dma_mapping_error	swiotlb_dma_mapping_error;
 
 /* hwiommu declarations & definitions: */
 
diff -puN arch/ia64/include/asm/machvec.h~ia64-use-common-header-for-software-io-tlb arch/ia64/include/asm/machvec.h
--- a/arch/ia64/include/asm/machvec.h~ia64-use-common-header-for-software-io-tlb
+++ a/arch/ia64/include/asm/machvec.h
@@ -11,6 +11,7 @@
 #define _ASM_IA64_MACHVEC_H
 
 #include <linux/types.h>
+#include <linux/swiotlb.h>
 
 /* forward declarations: */
 struct device;
@@ -298,27 +299,6 @@ extern void machvec_init_from_cmdline(co
 # endif /* CONFIG_IA64_GENERIC */
 
 /*
- * Declare default routines which aren't declared anywhere else:
- */
-extern ia64_mv_dma_init			swiotlb_init;
-extern ia64_mv_dma_alloc_coherent	swiotlb_alloc_coherent;
-extern ia64_mv_dma_free_coherent	swiotlb_free_coherent;
-extern ia64_mv_dma_map_single		swiotlb_map_single;
-extern ia64_mv_dma_map_single_attrs	swiotlb_map_single_attrs;
-extern ia64_mv_dma_unmap_single		swiotlb_unmap_single;
-extern ia64_mv_dma_unmap_single_attrs	swiotlb_unmap_single_attrs;
-extern ia64_mv_dma_map_sg		swiotlb_map_sg;
-extern ia64_mv_dma_map_sg_attrs		swiotlb_map_sg_attrs;
-extern ia64_mv_dma_unmap_sg		swiotlb_unmap_sg;
-extern ia64_mv_dma_unmap_sg_attrs	swiotlb_unmap_sg_attrs;
-extern ia64_mv_dma_sync_single_for_cpu	swiotlb_sync_single_for_cpu;
-extern ia64_mv_dma_sync_sg_for_cpu	swiotlb_sync_sg_for_cpu;
-extern ia64_mv_dma_sync_single_for_device swiotlb_sync_single_for_device;
-extern ia64_mv_dma_sync_sg_for_device	swiotlb_sync_sg_for_device;
-extern ia64_mv_dma_mapping_error	swiotlb_dma_mapping_error;
-extern ia64_mv_dma_supported		swiotlb_dma_supported;
-
-/*
  * Define default versions so we can extend machvec for new platforms without having
  * to update the machvec files for all existing platforms.
  */
_
