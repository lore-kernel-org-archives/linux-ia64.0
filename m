From: Sergei Trofimovich <slyfox@gentoo.org>
Date: Sun, 28 Mar 2021 20:24:39 +0000
Subject: [PATCH v2] ia64: simplify code flow around swiotlb init
Message-Id: <20210328202439.403601-1-slyfox@gentoo.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <d0f37f22-1d2a-50f5-886b-5e4b9892b921@physik.fu-berlin.de>
In-Reply-To: <d0f37f22-1d2a-50f5-886b-5e4b9892b921@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, inux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Sergei Trofimovich <slyfox@gentoo.org>, linux-ia64@vger.kernel.org

Before the change CONFIG_INTEL_IOMMU && !CONFIG_SWIOTLB && !CONFIG_FLATMEM
could skip `set_max_mapnr(max_low_pfn);` if iommu is not present on system.

CC: Andrew Morton <akpm@linux-foundation.org>
CC: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
CC: linux-ia64@vger.kernel.org
Signed-off-by: Sergei Trofimovich <slyfox@gentoo.org>
---
Change since v1: fixed a typo in commit mesage.

 arch/ia64/mm/init.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 16d0d7d22657..a63585db94fe 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -644,13 +644,16 @@ mem_init (void)
 	 * _before_ any drivers that may need the PCI DMA interface are
 	 * initialized or bootmem has been freed.
 	 */
+	do {
 #ifdef CONFIG_INTEL_IOMMU
-	detect_intel_iommu();
-	if (!iommu_detected)
+		detect_intel_iommu();
+		if (iommu_detected)
+			break;
 #endif
 #ifdef CONFIG_SWIOTLB
 		swiotlb_init(1);
 #endif
+	} while (0);
 
 #ifdef CONFIG_FLATMEM
 	BUG_ON(!mem_map);
-- 
2.31.1
