From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 06 Apr 2004 22:30:20 +0000
Subject: [PATCH] ISA stubs for ia64
Message-Id: <200404061630.20264.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

These stubs allow us to build all the old drivers that assume
ISA is present.  (Many of these support both ISA and PCI adapters,
so we do actually want them.)

With this patch and the others I just posted (hw_random, simscsi,
gen_rtc), we can build allmodconfig on ia64.

=== include/asm-ia64/dma.h 1.3 vs edited ==--- 1.3/include/asm-ia64/dma.h	Mon Aug 12 21:47:44 2002
+++ edited/include/asm-ia64/dma.h	Tue Apr  6 15:43:16 2004
@@ -18,6 +18,29 @@
 # define isa_dma_bridge_buggy 	(0)
 #endif
 
-#define free_dma(x)
+/* if drivers used CONFIG_ISA, we wouldn't need this stuff */
+
+#define DMA_MODE_READ		0
+#define DMA_MODE_WRITE		0
+#define DMA_MODE_CASCADE	0
+#define DMA_AUTOINIT		0
+
+#define MAX_DMA_CHANNELS	0
+
+static inline int
+unsupported_isa_dma_interface(void)
+{
+	BUG();
+	return 0;
+}
+
+#define request_dma(dmanr,id)		unsupported_isa_dma_interface()
+#define enable_dma(dmanr)		unsupported_isa_dma_interface()
+#define disable_dma(dmanr)		unsupported_isa_dma_interface()
+#define set_dma_mode(dmanr,mode)	unsupported_isa_dma_interface()
+#define claim_dma_lock()		unsupported_isa_dma_interface()
+#define release_dma_lock(flags)		unsupported_isa_dma_interface()
+#define clear_dma_ff(chan)		unsupported_isa_dma_interface()
+#define free_dma(dmanr)			unsupported_isa_dma_interface()
 
 #endif /* _ASM_IA64_DMA_H */
=== include/asm-ia64/io.h 1.19 vs edited ==--- 1.19/include/asm-ia64/io.h	Tue Feb  3 22:31:10 2004
+++ edited/include/asm-ia64/io.h	Tue Apr  6 15:41:40 2004
@@ -431,6 +431,20 @@
 #define dma_cache_wback(_start,_size)           do { } while (0)
 #define dma_cache_wback_inv(_start,_size)       do { } while (0)
 
+/* if drivers used CONFIG_ISA, we wouldn't need this stuff */
+
+static inline int
+unsupported_isa_interface(void)
+{
+	BUG();
+	return 0;
+}
+
+#define isa_virt_to_bus(address)		unsupported_isa_interface()
+#define isa_readb(address)			unsupported_isa_interface()
+#define isa_memcpy_fromio(to,from,count)	unsupported_isa_interface()
+#define isa_check_signature(io,sig,len)		unsupported_isa_interface()
+
 # endif /* __KERNEL__ */
 
 /*
