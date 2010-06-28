From: Christoph Egger <siccegge@cs.fau.de>
Date: Mon, 28 Jun 2010 13:41:42 +0000
Subject: [PATCH 2/2] Removing dead CONFIG_IOMMU_DEBUG
Message-Id: <79a9f3d21c0b49be4278179357311731ab7ece5c.1277731915.git.siccegge@cs.fau.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1277731915.git.siccegge@cs.fau.de>
In-Reply-To: <cover.1277731915.git.siccegge@cs.fau.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: vamos@i4.informatik.uni-erlangen.de

CONFIG_IOMMU_DEBUG doesn't exist in Kconfig, therefore removing all
references for it from the source code.

Signed-off-by: Christoph Egger <siccegge@cs.fau.de>
---
 arch/ia64/kernel/pci-dma.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/arch/ia64/kernel/pci-dma.c b/arch/ia64/kernel/pci-dma.c
index f6b1ff0..b70d53a 100644
--- a/arch/ia64/kernel/pci-dma.c
+++ b/arch/ia64/kernel/pci-dma.c
@@ -26,11 +26,7 @@ EXPORT_SYMBOL(bad_dma_address);
 static int iommu_sac_force __read_mostly;
 
 int no_iommu __read_mostly;
-#ifdef CONFIG_IOMMU_DEBUG
-int force_iommu __read_mostly = 1;
-#else
 int force_iommu __read_mostly;
-#endif
 
 int iommu_pass_through;
 
-- 
1.7.0.4

