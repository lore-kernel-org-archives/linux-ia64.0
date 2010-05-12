From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 12 May 2010 16:37:27 +0000
Subject: [PATCH] Drop duplicated "config IOMMU_HELPER"
Message-Id: <4bead94723300c5da9@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

One entry for this in arch/ia64/Kconfig should be enough.

Reported-by: Christoph Egger <siccegge@cs.fau.de>
Signed-off-by: Tony Luck <tony.luck@intel.com>

---

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 4d4f418..9676100 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -59,9 +59,6 @@ config NEED_DMA_MAP_STATE
 config SWIOTLB
        bool
 
-config IOMMU_HELPER
-       bool
-
 config GENERIC_LOCKBREAK
 	def_bool n
 
