From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 23 Jan 2004 16:57:55 +0000
Subject: [PATCH] remove MCA (MicroChannel) cruft
Message-Id: <200401230957.55116.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

MCA_bus is now referenced only when CONFIG_MCA is set,
so we should be able to remove the definition from ia64.

=== include/asm-ia64/processor.h 1.53 vs edited ==--- 1.53/include/asm-ia64/processor.h	Wed Dec 31 02:10:03 2003
+++ edited/include/asm-ia64/processor.h	Fri Jan 23 09:28:11 2004
@@ -53,12 +53,6 @@
  */
 #define TASK_UNMAPPED_BASE	(current->thread.map_base)
 
-/*
- * Bus types
- */
-#define MCA_bus 0
-#define MCA_bus__is_a_macro /* for versions in ksyms.c */
-
 #define IA64_THREAD_FPH_VALID	(__IA64_UL(1) << 0)	/* floating-point high state valid? */
 #define IA64_THREAD_DBG_VALID	(__IA64_UL(1) << 1)	/* debug registers valid? */
 #define IA64_THREAD_PM_VALID	(__IA64_UL(1) << 2)	/* performance registers valid? */

