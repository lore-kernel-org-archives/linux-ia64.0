From: Jason Uhlenkott <jasonuhl@sgi.com>
Date: Wed, 18 Feb 2004 22:13:03 +0000
Subject: [PATCH] 2.4.25: BUG(): Use guard page instead of page 0
Message-Id: <20040218221302.GA87364@dragonfly.csd.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The ia64 BUG macro deliberately writes to address 0 in order to
trigger a page fault and an Oops.  This won't work if the process has
mapped something into page zero:  We'll just print the "kernel BUG"
message and continue (after having stomped on whatever user memory was
at address 0).

A solution is to write to the guard page in region 5, which is
guaranteed to trigger a page fault.


--- linux-2.4.25.orig/include/asm-ia64/page.h	Wed Feb 18 05:36:32 2004
+++ linux-2.4.25/include/asm-ia64/page.h	Wed Feb 18 13:59:10 2004
@@ -120,7 +120,7 @@
 #define is_invalid_hugepage_range(addr, len) 0
 #endif
 
-#define BUG() do { printk("kernel BUG at %s:%d!\n", __FILE__, __LINE__); *(int *)0=0; } while (0)
+#define BUG() do { printk("kernel BUG at %s:%d!\n", __FILE__, __LINE__); *(int *)0xa000000000000000=0; } while (0)
 #define PAGE_BUG(page) do { BUG(); } while (0)
 
 static __inline__ int
