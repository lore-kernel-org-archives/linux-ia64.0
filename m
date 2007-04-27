From: Satoru Takeuchi <takeuchi_satoru@jp.fujitsu.com>
Date: Fri, 27 Apr 2007 06:46:36 +0000
Subject: [PATCH 2/2] unify iosapic regs definition
Message-Id: <873b2ms4ab.wl%takeuchi_satoru@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Unify iosapic regs definition.

Append unified prefix `IOSAPIC_REG_' to IOSAPIC registers. It has no
functional change.

Signed-off-by: Satoru Takeuchi <takeuchi_satoru@jp.fujitsu.com>

Index: linux-2.6.21/include/asm-ia64/iosapic.h
=================================--- linux-2.6.21.orig/include/asm-ia64/iosapic.h	2007-04-27 14:30:00.000000000 +0900
+++ linux-2.6.21/include/asm-ia64/iosapic.h	2007-04-27 15:03:19.000000000 +0900
@@ -2,10 +2,10 @@
 #define __ASM_IA64_IOSAPIC_H
 
 #define	IOSAPIC_REG_SELECT	0x0
-#define	IOSAPIC_WINDOW		0x10
-#define	IOSAPIC_EOI		0x40
+#define	IOSAPIC_REG_WINDOW	0x10
+#define	IOSAPIC_REG_EOI		0x40
 
-#define	IOSAPIC_VERSION		0x1
+#define	IOSAPIC_REG_VERSION	0x1
 
 /*
  * Redirection table entry
@@ -55,18 +55,18 @@
 static inline unsigned int iosapic_read(char __iomem *iosapic, unsigned int reg)
 {
 	writel(reg, iosapic + IOSAPIC_REG_SELECT);
-	return readl(iosapic + IOSAPIC_WINDOW);
+	return readl(iosapic + IOSAPIC_REG_WINDOW);
 }
 
 static inline void iosapic_write(char __iomem *iosapic, unsigned int reg, u32 val)
 {
 	writel(reg, iosapic + IOSAPIC_REG_SELECT);
-	writel(val, iosapic + IOSAPIC_WINDOW);
+	writel(val, iosapic + IOSAPIC_REG_WINDOW);
 }
 
 static inline void iosapic_eoi(char __iomem *iosapic, u32 vector)
 {
-	writel(vector, iosapic + IOSAPIC_EOI);
+	writel(vector, iosapic + IOSAPIC_REG_EOI);
 }
 
 extern void __init iosapic_system_init (int pcat_compat);
Index: linux-2.6.21/arch/ia64/kernel/iosapic.c
=================================--- linux-2.6.21.orig/arch/ia64/kernel/iosapic.c	2007-04-26 12:08:32.000000000 +0900
+++ linux-2.6.21/arch/ia64/kernel/iosapic.c	2007-04-27 15:08:14.000000000 +0900
@@ -520,7 +520,7 @@
 	 *	unsigned int reserved2 : 8;
 	 * }
 	 */
-	return iosapic_read(addr, IOSAPIC_VERSION);
+	return iosapic_read(addr, IOSAPIC_REG_VERSION);
 }
 
 static int iosapic_find_sharable_vector (unsigned long trigger,
