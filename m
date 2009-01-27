From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Tue, 27 Jan 2009 14:43:59 +0000
Subject: [PATCH -tip] IA64: fix the compile error on IA64_DIG_VTD
Message-Id: <20090127233530U.fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, mingo@elte.hu
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Sorry about fallout from my dma mapping ops unification.

From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: [PATCH] IA64: fix the compile error on IA64_DIG_VTD

This moves iommu_detected to arch/ia64/kernel/dma-mapping.c from
arch/ia64/kernel/pci-swiotlb.c to fix the following error on on
IA64_DIG_VTD:

arch/ia64/kernel/built-in.o: In function `pci_iommu_init':
pci-dma.c:(.init.text+0xa021): undefined reference to `iommu_detected'
pci-dma.c:(.init.text+0xa030): undefined reference to `iommu_detected'
drivers/built-in.o: In function `detect_intel_iommu':
(.init.text+0x11c0): undefined reference to `iommu_detected'
drivers/built-in.o: In function `detect_intel_iommu':
(.init.text+0x11e1): undefined reference to `iommu_detected'

iommu_detected is used to handle IOMMUs so I guess that
arch/ia64/kernel/dma-mapping.c is ok (there might be a better place
for it though).

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 arch/ia64/kernel/dma-mapping.c |    3 +++
 arch/ia64/kernel/pci-swiotlb.c |    3 ---
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/kernel/dma-mapping.c b/arch/ia64/kernel/dma-mapping.c
index 7060e13..086a2ae 100644
--- a/arch/ia64/kernel/dma-mapping.c
+++ b/arch/ia64/kernel/dma-mapping.c
@@ -1,5 +1,8 @@
 #include <linux/dma-mapping.h>
 
+/* Set this to 1 if there is a HW IOMMU in the system */
+int iommu_detected __read_mostly;
+
 struct dma_map_ops *dma_ops;
 EXPORT_SYMBOL(dma_ops);
 
diff --git a/arch/ia64/kernel/pci-swiotlb.c b/arch/ia64/kernel/pci-swiotlb.c
index d21dea4..717ad4f 100644
--- a/arch/ia64/kernel/pci-swiotlb.c
+++ b/arch/ia64/kernel/pci-swiotlb.c
@@ -13,9 +13,6 @@
 int swiotlb __read_mostly;
 EXPORT_SYMBOL(swiotlb);
 
-/* Set this to 1 if there is a HW IOMMU in the system */
-int iommu_detected __read_mostly;
-
 struct dma_map_ops swiotlb_dma_ops = {
 	.alloc_coherent = swiotlb_alloc_coherent,
 	.free_coherent = swiotlb_free_coherent,
-- 
1.6.0.6

