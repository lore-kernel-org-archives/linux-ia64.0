From: Horms <horms@verge.net.au>
Date: Mon, 05 Feb 2007 01:17:38 +0000
Subject: [PATCH] [IA64]: add return to PAL-code warning message
Message-Id: <20070205011737.GC31046@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Signed-off-by: Simon Horman <horms@verge.net.au>

Index: linux-2.6/arch/ia64/kernel/efi.c
=================================--- linux-2.6.orig/arch/ia64/kernel/efi.c	2007-01-31 16:54:43.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/efi.c	2007-01-31 16:54:46.000000000 +0900
@@ -380,7 +380,7 @@
 #endif
 		return __va(md->phys_addr);
 	}
-	printk(KERN_WARNING "%s: no PAL-code memory-descriptor found",
+	printk(KERN_WARNING "%s: no PAL-code memory-descriptor found\n",
 	       __FUNCTION__);
 	return NULL;
 }
