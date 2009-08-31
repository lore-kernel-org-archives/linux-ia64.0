From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 31 Aug 2009 23:54:03 +0000
Subject: Fix warning in dma-mapping.c
Message-Id: <4a9c629b21804ea624@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

arch/ia64/kernel/dma-mapping.c:14: warning: control reaches end of non-void function
arch/ia64/kernel/dma-mapping.c:14: warning: no return statement in function returning non-void

This warning was introduced by commit: 390bd132b2831a2ad0268e84bffbfc0680debfe5
	Add dma_debug_init() for ia64

Signed-off-by: Tony Luck <tony.luck@intel.com>

---

diff --git a/arch/ia64/kernel/dma-mapping.c b/arch/ia64/kernel/dma-mapping.c
index 39a3cd0..f2c1600 100644
--- a/arch/ia64/kernel/dma-mapping.c
+++ b/arch/ia64/kernel/dma-mapping.c
@@ -10,7 +10,9 @@ EXPORT_SYMBOL(dma_ops);
 
 static int __init dma_init(void)
 {
-       dma_debug_init(PREALLOC_DMA_DEBUG_ENTRIES);
+	dma_debug_init(PREALLOC_DMA_DEBUG_ENTRIES);
+
+	return 0;
 }
 fs_initcall(dma_init);
 
