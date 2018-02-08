From: Corentin Labbe <clabbe@baylibre.com>
Date: Thu, 08 Feb 2018 19:39:20 +0000
Subject: [PATCH] ia64: fix build failure with CONFIG_SWIOTLB
Message-Id: <1518118760-5224-1-git-send-email-clabbe@baylibre.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: fenghua.yu@intel.com, tony.luck@intel.com, hch@lst.de, christian.koenig@amd.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Corentin Labbe <clabbe@baylibre.com>

arch/ia64/kernel/pci-swiotlb.c is removed in commit 4fac8076df85 ("ia64: clean up swiotlb support")
but pci-swiotlb.o is still present in Makefile, and so build fail when
CONFIG_SWIOTLB is enabled.
Fix the build failure by removing pci-swiotlb.o from makefile

Fixes: 4fac8076df85 ("ia64: clean up swiotlb support")
Signed-off-by: Corentin Labbe <clabbe@baylibre.com>
---
 arch/ia64/kernel/Makefile | 1 -
 1 file changed, 1 deletion(-)

diff --git a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
index 0b4c65a1af25..498f3da3f225 100644
--- a/arch/ia64/kernel/Makefile
+++ b/arch/ia64/kernel/Makefile
@@ -41,7 +41,6 @@ ifneq ($(CONFIG_IA64_ESI),)
 obj-y				+= esi_stub.o	# must be in kernel proper
 endif
 obj-$(CONFIG_INTEL_IOMMU)	+= pci-dma.o
-obj-$(CONFIG_SWIOTLB)		+= pci-swiotlb.o
 
 obj-$(CONFIG_BINFMT_ELF)	+= elfcore.o
 
-- 
2.13.6

