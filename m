From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Mon, 05 Jan 2009 14:36:09 +0000
Subject: [PATCH 04/13] add dma_mapping_ops for intel-iommu
Message-Id: <1231166178-20050-5-git-send-email-fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1231166178-20050-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-2-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-3-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-4-git-send-email-fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <1231166178-20050-4-git-send-email-fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>

This is for IA64_DIG_VTD.

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 arch/ia64/dig/dig_vtd_iommu.c |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/dig/dig_vtd_iommu.c b/arch/ia64/dig/dig_vtd_iommu.c
index 1c8a079..fdb8ba9 100644
--- a/arch/ia64/dig/dig_vtd_iommu.c
+++ b/arch/ia64/dig/dig_vtd_iommu.c
@@ -1,6 +1,7 @@
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
+#include <linux/dma-mapping.h>
 #include <linux/intel-iommu.h>
 
 void *
@@ -57,3 +58,20 @@ vtd_dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
 	return 0;
 }
 EXPORT_SYMBOL_GPL(vtd_dma_mapping_error);
+
+extern int iommu_dma_supported(struct device *dev, u64 mask);
+
+struct dma_mapping_ops vtd_dma_ops = {
+	.alloc_coherent		= vtd_alloc_coherent,
+	.free_coherent		= vtd_free_coherent,
+	.map_single_attrs	= vtd_map_single_attrs,
+	.unmap_single_attrs	= vtd_unmap_single_attrs,
+	.map_sg_attrs		= vtd_map_sg_attrs,
+	.unmap_sg_attrs		= vtd_unmap_sg_attrs,
+	.sync_single_for_cpu	= machvec_dma_sync_single,
+	.sync_sg_for_cpu	= machvec_dma_sync_sg,
+	.sync_single_for_device	= machvec_dma_sync_single,
+	.sync_sg_for_device	= machvec_dma_sync_sg,
+	.dma_supported_op	= iommu_dma_supported,
+	.mapping_error		= vtd_dma_mapping_error,
+};
-- 
1.6.0.6

