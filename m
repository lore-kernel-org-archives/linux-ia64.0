From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Mon, 05 Jan 2009 14:36:08 +0000
Subject: [PATCH 03/13] add dma_mapping_ops for SWIOTLB and SBA IOMMU
Message-Id: <1231166178-20050-4-git-send-email-fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1231166178-20050-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-2-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-3-git-send-email-fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <1231166178-20050-3-git-send-email-fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>

This is for IA64_HP_ZX1_SWIOTLB.

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 arch/ia64/hp/common/hwsw_iommu.c |   17 ++++++++++++++++-
 1 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/hp/common/hwsw_iommu.c b/arch/ia64/hp/common/hwsw_iommu.c
index 2769dbf..a40dcdd 100644
--- a/arch/ia64/hp/common/hwsw_iommu.c
+++ b/arch/ia64/hp/common/hwsw_iommu.c
@@ -13,8 +13,8 @@
  */
 
 #include <linux/device.h>
+#include <linux/dma-mapping.h>
 #include <linux/swiotlb.h>
-
 #include <asm/machvec.h>
 
 /* swiotlb declarations & definitions: */
@@ -193,3 +193,18 @@ EXPORT_SYMBOL(hwsw_sync_single_for_cpu);
 EXPORT_SYMBOL(hwsw_sync_single_for_device);
 EXPORT_SYMBOL(hwsw_sync_sg_for_cpu);
 EXPORT_SYMBOL(hwsw_sync_sg_for_device);
+
+struct dma_mapping_ops hwsw_dma_ops = {
+	.alloc_coherent		= hwsw_alloc_coherent,
+	.free_coherent		= hwsw_free_coherent,
+	.map_single_attrs	= hwsw_map_single_attrs,
+	.unmap_single_attrs	= hwsw_unmap_single_attrs,
+	.map_sg_attrs		= hwsw_map_sg_attrs,
+	.unmap_sg_attrs		= hwsw_unmap_sg_attrs,
+	.sync_single_for_cpu	= hwsw_sync_single_for_cpu,
+	.sync_sg_for_cpu	= hwsw_sync_sg_for_cpu,
+	.sync_single_for_device	= hwsw_sync_single_for_device,
+	.sync_sg_for_device	= hwsw_sync_sg_for_device,
+	.dma_supported_op	= hwsw_dma_supported,
+	.mapping_error		= hwsw_dma_mapping_error,
+};
-- 
1.6.0.6

