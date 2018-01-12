From: Christoph Hellwig <hch@lst.de>
Date: Fri, 12 Jan 2018 08:42:01 +0000
Subject: [PATCH 03/34] m32r: remove unused flush_write_buffers definition
Message-Id: <20180112084232.2857-4-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180112084232.2857-1-hch@lst.de>
In-Reply-To: <20180112084232.2857-1-hch-jcswGhMUV9g@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Konrad Rzeszutek Wilk <konrad-Gq0aWv8utHQdnm+yROfE0A@public.gmane.org>, linux-alpha-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-snps-arc-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-c6x-dev-jPsnJVOj+W6hPH1hqNUYSQ@public.gmane.org, linux-cris-kernel-VrBV9hrLPhE@public.gmane.org, linux-hexagon-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-m68k-cunTk1MwBs8S/qaLPR03pWD2FQJk+8+b@public.gmane.org, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, linux-parisc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, patches-q3qR2WxjNRFS9aJRtSZj7A@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Guan Xuetao <gxt-TG0Ac1+ktVePQbnJrJN+5g@public.gmane.org>, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/m32r/include/asm/io.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/arch/m32r/include/asm/io.h b/arch/m32r/include/asm/io.h
index 1b653bb16f9a..a4272d8f0d9c 100644
--- a/arch/m32r/include/asm/io.h
+++ b/arch/m32r/include/asm/io.h
@@ -191,8 +191,6 @@ static inline void _writel(unsigned long l, unsigned long addr)
 
 #define mmiowb()
 
-#define flush_write_buffers() do { } while (0)  /* M32R_FIXME */
-
 static inline void
 memset_io(volatile void __iomem *addr, unsigned char val, int count)
 {
-- 
2.14.2

