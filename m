From: akpm@linux-foundation.org
Date: Tue, 06 Feb 2007 00:20:03 +0000
Subject: [patch 07/13] ia64: missing exports hwsw_sync_...
Message-Id: <200702060021.l160L6Wj004201@shell0.pdx.osdl.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: "Jan Beulich" <jbeulich@novell.com>

Add missing exports to allow several drivers to be built as module with
CONFIG_IA64_HP_ZX1_SWIOTLB.

Signed-off-by: Jan Beulich <jbeulich@novell.com>
Cc: "Luck, Tony" <tony.luck@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/ia64/hp/common/hwsw_iommu.c |    4 ++++
 1 file changed, 4 insertions(+)

diff -puN arch/ia64/hp/common/hwsw_iommu.c~ia64-missing-exports-hwsw_sync_ arch/ia64/hp/common/hwsw_iommu.c
--- a/arch/ia64/hp/common/hwsw_iommu.c~ia64-missing-exports-hwsw_sync_
+++ a/arch/ia64/hp/common/hwsw_iommu.c
@@ -192,3 +192,7 @@ EXPORT_SYMBOL(hwsw_unmap_sg);
 EXPORT_SYMBOL(hwsw_dma_supported);
 EXPORT_SYMBOL(hwsw_alloc_coherent);
 EXPORT_SYMBOL(hwsw_free_coherent);
+EXPORT_SYMBOL(hwsw_sync_single_for_cpu);
+EXPORT_SYMBOL(hwsw_sync_single_for_device);
+EXPORT_SYMBOL(hwsw_sync_sg_for_cpu);
+EXPORT_SYMBOL(hwsw_sync_sg_for_device);
_
