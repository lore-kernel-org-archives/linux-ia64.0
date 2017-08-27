From: Christoph Hellwig <hch@lst.de>
Date: Sun, 27 Aug 2017 16:10:22 +0000
Subject: [PATCH 02/12] mips: don't use dma_cache_sync to implement fd_cacheflush
Message-Id: <20170827161032.22772-3-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170827161032.22772-1-hch@lst.de>
In-Reply-To: <20170827161032.22772-1-hch-jcswGhMUV9g@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Chris Zankel <chris-YvXeqwSYzG2sTnJN9+BGXg@public.gmane.org>, Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Max Filippov <jcmvbkbc-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Guan Xuetao <gxt-TG0Ac1+ktVePQbnJrJN+5g@public.gmane.org>

The floppy drivers doesn't otherwise use the DMA API, so indirecting
through it just for cache flushing in MIPS-specific code just call
dma_cache_wback_inv directly.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/mips/include/asm/floppy.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/mips/include/asm/floppy.h b/arch/mips/include/asm/floppy.h
index d75aed36480a..021d09ae5670 100644
--- a/arch/mips/include/asm/floppy.h
+++ b/arch/mips/include/asm/floppy.h
@@ -10,11 +10,11 @@
 #ifndef _ASM_FLOPPY_H
 #define _ASM_FLOPPY_H
 
-#include <linux/dma-mapping.h>
+#include <asm/io.h>
 
 static inline void fd_cacheflush(char * addr, long size)
 {
-	dma_cache_sync(NULL, addr, size, DMA_BIDIRECTIONAL);
+	dma_cache_wback_inv((unsigned long)addr, size);
 }
 
 #define MAX_BUFFER_SECTORS 24
-- 
2.11.0

