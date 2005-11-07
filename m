From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 07 Nov 2005 19:55:27 +0000
Subject: [PATCH] ia64: drop arch-specific IDE MAX_HWIFS definition
Message-Id: <200511071255.27589.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

There's no reason MAX_HWIFS needs to be ia64-specific, so set MAX_HWIFS
from CONFIG_IDE_MAX_HWIFS.

This reduces the default from 10 to 4, but I don't think that's a problem.

Note: this depends on ide-move-config_ide_max_hwifs-into-linux-ideh.patch,
which is in 2.6.14-mm1, but not in Linus' tree yet.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

Index: work-vga2/include/asm-ia64/ide.h
=================================--- work-vga2.orig/include/asm-ia64/ide.h	2005-09-14 09:29:12.000000000 -0600
+++ work-vga2/include/asm-ia64/ide.h	2005-09-14 10:22:33.000000000 -0600
@@ -17,14 +17,6 @@
 
 #include <linux/irq.h>
 
-#ifndef MAX_HWIFS
-# ifdef CONFIG_PCI
-#define MAX_HWIFS	10
-# else
-#define MAX_HWIFS	6
-# endif
-#endif
-
 #define IDE_ARCH_OBSOLETE_DEFAULTS
 
 static inline int ide_default_irq(unsigned long base)
Index: work-vga2/drivers/ide/Kconfig
=================================--- work-vga2.orig/drivers/ide/Kconfig	2005-09-14 09:28:11.000000000 -0600
+++ work-vga2/drivers/ide/Kconfig	2005-09-14 10:24:30.000000000 -0600
@@ -52,9 +52,9 @@
 
 if IDE
 
-config IDE_MAX_HWIFS 
+config IDE_MAX_HWIFS
 	int "Max IDE interfaces"
-	depends on ALPHA || SUPERH
+	depends on ALPHA || SUPERH || IA64
 	default 4
 	help
 	  This is the maximum number of IDE hardware interfaces that will
