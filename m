From: Christoph Hellwig <hch@lst.de>
Date: Mon, 17 Sep 2018 17:10:26 +0000
Subject: [PATCH 4/9] ia64: remove the unused bad_dma_address symbol
Message-Id: <20180917171031.3853-5-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/ia64/kernel/pci-dma.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/arch/ia64/kernel/pci-dma.c b/arch/ia64/kernel/pci-dma.c
index 3c2884bef3d4..924966e5aa25 100644
--- a/arch/ia64/kernel/pci-dma.c
+++ b/arch/ia64/kernel/pci-dma.c
@@ -15,9 +15,6 @@
 #include <linux/kernel.h>
 #include <asm/page.h>
 
-dma_addr_t bad_dma_address __read_mostly;
-EXPORT_SYMBOL(bad_dma_address);
-
 int no_iommu __read_mostly;
 #ifdef CONFIG_IOMMU_DEBUG
 int force_iommu __read_mostly = 1;
-- 
2.18.0
