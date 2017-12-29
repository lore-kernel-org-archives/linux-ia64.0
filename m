From: Christoph Hellwig <hch@lst.de>
Date: Fri, 29 Dec 2017 08:18:19 +0000
Subject: [PATCH 15/67] hexagon: use the generic dma_capable helper
Message-Id: <20171229081911.2802-16-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171229081911.2802-1-hch@lst.de>
In-Reply-To: <20171229081911.2802-1-hch-jcswGhMUV9g@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Guan Xuetao <gxt-TG0Ac1+ktVePQbnJrJN+5g@public.gmane.org>, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-c6x-dev-jPsnJVOj+W6hPH1hqNUYSQ@public.gmane.org, linux-hexagon-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-snps-arc-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, adi-buildroot-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-m68k-cunTk1MwBs8S/qaLPR03pWD2FQJk+8+b@public.gmane.org, patches-q3qR2WxjNRFS9aJRtSZj7A@public.gmane.org, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>, linux-parisc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-cris-kernel-VrBV9hrLPhE@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-alpha-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/hexagon/include/asm/dma-mapping.h | 7 -------
 arch/hexagon/kernel/dma.c              | 1 +
 2 files changed, 1 insertion(+), 7 deletions(-)

diff --git a/arch/hexagon/include/asm/dma-mapping.h b/arch/hexagon/include/asm/dma-mapping.h
index 5208de242e79..263f6acbfb0f 100644
--- a/arch/hexagon/include/asm/dma-mapping.h
+++ b/arch/hexagon/include/asm/dma-mapping.h
@@ -37,11 +37,4 @@ static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
 	return dma_ops;
 }
 
-static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
-{
-	if (!dev->dma_mask)
-		return 0;
-	return addr + size - 1 <= *dev->dma_mask;
-}
-
 #endif
diff --git a/arch/hexagon/kernel/dma.c b/arch/hexagon/kernel/dma.c
index 3683bb9c05a2..c1d24e37807c 100644
--- a/arch/hexagon/kernel/dma.c
+++ b/arch/hexagon/kernel/dma.c
@@ -19,6 +19,7 @@
  */
 
 #include <linux/dma-mapping.h>
+#include <linux/dma-direct.h>
 #include <linux/bootmem.h>
 #include <linux/genalloc.h>
 #include <asm/dma-mapping.h>
-- 
2.14.2

