From: Christoph Hellwig <hch@lst.de>
Date: Tue, 03 Oct 2017 10:43:01 +0000
Subject: [PATCH 01/11] floppy: consolidate the dummy fd_cacheflush definition
Message-Id: <20171003104311.10058-2-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171003104311.10058-1-hch@lst.de>
In-Reply-To: <20171003104311.10058-1-hch-jcswGhMUV9g@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Chris Zankel <chris-YvXeqwSYzG2sTnJN9+BGXg@public.gmane.org>, Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Max Filippov <jcmvbkbc-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Guan Xuetao <gxt-TG0Ac1+ktVePQbnJrJN+5g@public.gmane.org>

Only mips defines this helper, so remove all the other arch definitions.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/alpha/include/asm/floppy.h    | 2 --
 arch/powerpc/include/asm/floppy.h  | 2 --
 arch/sparc/include/asm/floppy_32.h | 1 -
 arch/sparc/include/asm/floppy_64.h | 1 -
 drivers/block/floppy.c             | 4 ++++
 5 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/arch/alpha/include/asm/floppy.h b/arch/alpha/include/asm/floppy.h
index bae97eb19d26..942924756cf2 100644
--- a/arch/alpha/include/asm/floppy.h
+++ b/arch/alpha/include/asm/floppy.h
@@ -24,7 +24,6 @@
 #define fd_set_dma_count(count) set_dma_count(FLOPPY_DMA,count)
 #define fd_enable_irq()         enable_irq(FLOPPY_IRQ)
 #define fd_disable_irq()        disable_irq(FLOPPY_IRQ)
-#define fd_cacheflush(addr,size) /* nothing */
 #define fd_request_irq()        request_irq(FLOPPY_IRQ, floppy_interrupt,\
 					    0, "floppy", NULL)
 #define fd_free_irq()           free_irq(FLOPPY_IRQ, NULL)
@@ -62,7 +61,6 @@ alpha_fd_dma_setup(char *addr, unsigned long size, int mode, int io)
 	prev_dir = dir;
 
 	fd_clear_dma_ff();
-	fd_cacheflush(addr, size);
 	fd_set_dma_mode(mode);
 	set_dma_addr(FLOPPY_DMA, bus_addr);
 	fd_set_dma_count(size);
diff --git a/arch/powerpc/include/asm/floppy.h b/arch/powerpc/include/asm/floppy.h
index 936a904ae78c..167c44b58848 100644
--- a/arch/powerpc/include/asm/floppy.h
+++ b/arch/powerpc/include/asm/floppy.h
@@ -25,7 +25,6 @@
 #define fd_get_dma_residue()    fd_ops->_get_dma_residue(FLOPPY_DMA)
 #define fd_enable_irq()         enable_irq(FLOPPY_IRQ)
 #define fd_disable_irq()        disable_irq(FLOPPY_IRQ)
-#define fd_cacheflush(addr,size) /* nothing */
 #define fd_free_irq()           free_irq(FLOPPY_IRQ, NULL);
 
 #include <linux/pci.h>
@@ -152,7 +151,6 @@ static int hard_dma_setup(char *addr, unsigned long size, int mode, int io)
 	prev_dir = dir;
 
 	fd_clear_dma_ff();
-	fd_cacheflush(addr, size);
 	fd_set_dma_mode(mode);
 	set_dma_addr(FLOPPY_DMA, bus_addr);
 	fd_set_dma_count(size);
diff --git a/arch/sparc/include/asm/floppy_32.h b/arch/sparc/include/asm/floppy_32.h
index 071b83e52f15..dab58525229e 100644
--- a/arch/sparc/include/asm/floppy_32.h
+++ b/arch/sparc/include/asm/floppy_32.h
@@ -70,7 +70,6 @@ static struct sun_floppy_ops sun_fdops;
 #define fd_set_dma_count(count)   sun_fd_set_dma_count(count)
 #define fd_enable_irq()           /* nothing... */
 #define fd_disable_irq()          /* nothing... */
-#define fd_cacheflush(addr, size) /* nothing... */
 #define fd_request_irq()          sun_fd_request_irq()
 #define fd_free_irq()             /* nothing... */
 #if 0  /* P3: added by Alain, these cause a MMU corruption. 19960524 XXX */
diff --git a/arch/sparc/include/asm/floppy_64.h b/arch/sparc/include/asm/floppy_64.h
index 625756406a7e..a1db35a22c99 100644
--- a/arch/sparc/include/asm/floppy_64.h
+++ b/arch/sparc/include/asm/floppy_64.h
@@ -72,7 +72,6 @@ static struct sun_floppy_ops sun_fdops;
 #define fd_set_dma_addr(addr)     sun_fdops.fd_set_dma_addr(addr)
 #define fd_set_dma_count(count)   sun_fdops.fd_set_dma_count(count)
 #define get_dma_residue(x)        sun_fdops.get_dma_residue()
-#define fd_cacheflush(addr, size) /* nothing... */
 #define fd_request_irq()          sun_fdops.fd_request_irq()
 #define fd_free_irq()             sun_fdops.fd_free_irq()
 #define fd_eject(drive)           sun_fdops.fd_eject(drive)
diff --git a/drivers/block/floppy.c b/drivers/block/floppy.c
index 60c086a53609..a54183935aa1 100644
--- a/drivers/block/floppy.c
+++ b/drivers/block/floppy.c
@@ -275,6 +275,10 @@ static int set_next_request(void);
 #define fd_dma_mem_alloc(size) __get_dma_pages(GFP_KERNEL, get_order(size))
 #endif
 
+#ifndef fd_cacheflush
+#define fd_cacheflush(addr, size) /* nothing... */
+#endif
+
 static inline void fallback_on_nodma_alloc(char **addr, size_t l)
 {
 #ifdef FLOPPY_CAN_FALLBACK_ON_NODMA
-- 
2.14.1

