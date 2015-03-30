From: Joe Perches <joe@perches.com>
Date: Mon, 30 Mar 2015 23:46:02 +0000
Subject: [PATCH 04/25] ia64: Use bool function return values of true/false not 1/0
Message-Id: <0cfd16159424272d82b9e3209070d2436c5d585a.1427759009.git.joe@perches.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1427759009.git.joe@perches.com>
In-Reply-To: <cover.1427759009.git.joe@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

Use the normal return values for bool functions

Signed-off-by: Joe Perches <joe@perches.com>
---
 arch/ia64/include/asm/dma-mapping.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/include/asm/dma-mapping.h b/arch/ia64/include/asm/dma-mapping.h
index cf3ab7e..1b0b192 100644
--- a/arch/ia64/include/asm/dma-mapping.h
+++ b/arch/ia64/include/asm/dma-mapping.h
@@ -80,7 +80,7 @@ dma_set_mask (struct device *dev, u64 mask)
 static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
 {
 	if (!dev->dma_mask)
-		return 0;
+		return false;
 
 	return addr + size - 1 <= *dev->dma_mask;
 }
-- 
2.1.2

