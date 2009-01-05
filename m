From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Mon, 05 Jan 2009 14:36:07 +0000
Subject: [PATCH 02/13] add dma_mapping_ops for SBA IOMMU
Message-Id: <1231166178-20050-3-git-send-email-fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1231166178-20050-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-2-git-send-email-fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <1231166178-20050-2-git-send-email-fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>

This is for IA64_HP_ZX1.

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 arch/ia64/hp/common/sba_iommu.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iommu.c
index d98f0f4..655b9a1 100644
--- a/arch/ia64/hp/common/sba_iommu.c
+++ b/arch/ia64/hp/common/sba_iommu.c
@@ -36,6 +36,7 @@
 #include <linux/bitops.h>         /* hweight64() */
 #include <linux/crash_dump.h>
 #include <linux/iommu-helper.h>
+#include <linux/dma-mapping.h>
 
 #include <asm/delay.h>		/* ia64_get_itc() */
 #include <asm/io.h>
@@ -2180,3 +2181,18 @@ EXPORT_SYMBOL(sba_dma_mapping_error);
 EXPORT_SYMBOL(sba_dma_supported);
 EXPORT_SYMBOL(sba_alloc_coherent);
 EXPORT_SYMBOL(sba_free_coherent);
+
+struct dma_mapping_ops sba_dma_ops = {
+	.alloc_coherent		= sba_alloc_coherent,
+	.free_coherent		= sba_free_coherent,
+	.map_single_attrs	= sba_map_single_attrs,
+	.unmap_single_attrs	= sba_unmap_single_attrs,
+	.map_sg_attrs		= sba_map_sg_attrs,
+	.unmap_sg_attrs		= sba_unmap_sg_attrs,
+	.sync_single_for_cpu	= machvec_dma_sync_single,
+	.sync_sg_for_cpu	= machvec_dma_sync_sg,
+	.sync_single_for_device	= machvec_dma_sync_single,
+	.sync_sg_for_device	= machvec_dma_sync_sg,
+	.dma_supported_op	= sba_dma_supported,
+	.mapping_error		= sba_dma_mapping_error,
+};
-- 
1.6.0.6

