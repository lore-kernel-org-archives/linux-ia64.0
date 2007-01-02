From: "Jan Beulich" <jbeulich@novell.com>
Date: Tue, 02 Jan 2007 16:22:27 +0000
Subject: [PATCH] ia64: missing exports hwsw_sync_...
Message-Id: <459A94D3.76E4.0078.0@novell.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org

This patch adds missing exports to allow several drivers to be built as
module with CONFIG_IA64_HP_ZX1_SWIOTLB.

Signed-off-by: Jan Beulich <jbeulich@novell.com>

--- linux-2.6.20-rc3/arch/ia64/hp/common/hwsw_iommu.c	2006-11-29 22:57:37.000000000 +0100
+++ 2.6.20-rc3-ia64-zx1-swiotlb/arch/ia64/hp/common/hwsw_iommu.c	2007-01-02 08:24:22.000000000 +0100
@@ -192,3 +192,7 @@ EXPORT_SYMBOL(hwsw_unmap_sg);
 EXPORT_SYMBOL(hwsw_dma_supported);
 EXPORT_SYMBOL(hwsw_alloc_coherent);
 EXPORT_SYMBOL(hwsw_free_coherent);
+EXPORT_SYMBOL(hwsw_sync_single_for_cpu);
+EXPORT_SYMBOL(hwsw_sync_single_for_device);
+EXPORT_SYMBOL(hwsw_sync_sg_for_cpu);
+EXPORT_SYMBOL(hwsw_sync_sg_for_device);

