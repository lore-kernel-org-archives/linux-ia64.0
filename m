From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 23 Jun 2004 21:54:39 +0000
Subject: [PATCH] minor IOSAPIC cleanup
Message-Id: <200406231554.39387.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Introduce iosapic_{read,write,eoi} to hide the IOSAPIC REG_SELECT
stuff.  i386 and x86_64 already do this for io_apic_{read,write}.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

=== arch/ia64/kernel/iosapic.c 1.45 vs edited ==--- 1.45/arch/ia64/kernel/iosapic.c	2004-06-19 08:48:59 -06:00
+++ edited/arch/ia64/kernel/iosapic.c	2004-06-23 14:55:47 -06:00
@@ -217,10 +217,8 @@
 
 	spin_lock_irqsave(&iosapic_lock, flags);
 	{
-		writel(IOSAPIC_RTE_HIGH(rte_index), addr + IOSAPIC_REG_SELECT);
-		writel(high32, addr + IOSAPIC_WINDOW);
-		writel(IOSAPIC_RTE_LOW(rte_index), addr + IOSAPIC_REG_SELECT);
-		writel(low32, addr + IOSAPIC_WINDOW);
+		iosapic_write(addr, IOSAPIC_RTE_HIGH(rte_index), high32);
+		iosapic_write(addr, IOSAPIC_RTE_LOW(rte_index), low32);
 		iosapic_intr_info[vector].low32 = low32;
 	}
 	spin_unlock_irqrestore(&iosapic_lock, flags);
@@ -249,12 +247,9 @@
 
 	spin_lock_irqsave(&iosapic_lock, flags);
 	{
-		writel(IOSAPIC_RTE_LOW(rte_index), addr + IOSAPIC_REG_SELECT);
-
 		/* set only the mask bit */
 		low32 = iosapic_intr_info[vec].low32 |= IOSAPIC_MASK;
-
-		writel(low32, addr + IOSAPIC_WINDOW);
+		iosapic_write(addr, IOSAPIC_RTE_LOW(rte_index), low32);
 	}
 	spin_unlock_irqrestore(&iosapic_lock, flags);
 }
@@ -275,9 +270,8 @@
 
 	spin_lock_irqsave(&iosapic_lock, flags);
 	{
-		writel(IOSAPIC_RTE_LOW(rte_index), addr + IOSAPIC_REG_SELECT);
 		low32 = iosapic_intr_info[vec].low32 &= ~IOSAPIC_MASK;
-		writel(low32, addr + IOSAPIC_WINDOW);
+		iosapic_write(addr, IOSAPIC_RTE_LOW(rte_index), low32);
 	}
 	spin_unlock_irqrestore(&iosapic_lock, flags);
 }
@@ -325,10 +319,8 @@
 			low32 |= (IOSAPIC_FIXED << IOSAPIC_DELIVERY_SHIFT);
 
 		iosapic_intr_info[vec].low32 = low32;
-		writel(IOSAPIC_RTE_HIGH(rte_index), addr + IOSAPIC_REG_SELECT);
-		writel(high32, addr + IOSAPIC_WINDOW);
-		writel(IOSAPIC_RTE_LOW(rte_index), addr + IOSAPIC_REG_SELECT);
-		writel(low32, addr + IOSAPIC_WINDOW);
+		iosapic_write(addr, IOSAPIC_RTE_HIGH(rte_index), high32);
+		iosapic_write(addr, IOSAPIC_RTE_LOW(rte_index), low32);
 	}
 	spin_unlock_irqrestore(&iosapic_lock, flags);
 #endif
@@ -351,7 +343,7 @@
 	ia64_vector vec = irq_to_vector(irq);
 
 	move_irq(irq);
-	writel(vec, iosapic_intr_info[vec].addr + IOSAPIC_EOI);
+	iosapic_eoi(iosapic_intr_info[vec].addr, vec);
 }
 
 #define iosapic_shutdown_level_irq	mask_irq
@@ -428,8 +420,7 @@
 	 *	unsigned int reserved2 : 8;
 	 * }
 	 */
-	writel(IOSAPIC_VERSION, addr + IOSAPIC_REG_SELECT);
-	return readl(IOSAPIC_WINDOW + addr);
+	return iosapic_read(addr, IOSAPIC_VERSION);
 }
 
 /*
=== include/asm-ia64/iosapic.h 1.14 vs edited ==--- 1.14/include/asm-ia64/iosapic.h	2004-05-24 23:32:34 -06:00
+++ edited/include/asm-ia64/iosapic.h	2004-06-23 14:52:16 -06:00
@@ -1,13 +1,11 @@
 #ifndef __ASM_IA64_IOSAPIC_H
 #define __ASM_IA64_IOSAPIC_H
 
-#define	IOSAPIC_DEFAULT_ADDR	0xFEC00000
-
 #define	IOSAPIC_REG_SELECT	0x0
 #define	IOSAPIC_WINDOW		0x10
 #define	IOSAPIC_EOI		0x40
 
-#define	IOSAPIC_VERSION	0x1
+#define	IOSAPIC_VERSION		0x1
 
 /*
  * Redirection table entry
@@ -54,6 +52,23 @@
 #ifdef CONFIG_IOSAPIC
 
 #define NR_IOSAPICS			256
+
+static inline unsigned int iosapic_read(char *iosapic, unsigned int reg)
+{
+	writel(reg, iosapic + IOSAPIC_REG_SELECT);
+	return readl(iosapic + IOSAPIC_WINDOW);
+}
+
+static inline void iosapic_write(char *iosapic, unsigned int reg, u32 val)
+{
+	writel(reg, iosapic + IOSAPIC_REG_SELECT);
+	writel(val, iosapic + IOSAPIC_WINDOW);
+}
+
+static inline void iosapic_eoi(char *iosapic, u32 vector)
+{
+	writel(vector, iosapic + IOSAPIC_EOI);
+}
 
 extern void __init iosapic_system_init (int pcat_compat);
 extern void __init iosapic_init (unsigned long address,
