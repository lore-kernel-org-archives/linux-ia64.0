From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Fri, 27 Feb 2004 02:18:56 +0000
Subject: [Patch] speed up interrupt handling
Message-Id: <16446.43280.853544.583305@wombat.disy.cse.unsw.edu.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hi David,
   The attached patch makes enable_irq() disappear from the profile.
From ~4000 cycles per call, it's gone down to around 260 cycles.
I've only tested on UP; however, the iosapic lock is held around all
the manipulations of the new field.

This also incidentally increases the performance of the gigabit
network driver: it drops fewer packets.

Patch against 2.6.3.

=== arch/ia64/kernel/iosapic.c 1.34 vs edited ==--- 1.34/arch/ia64/kernel/iosapic.c	Wed Jan 28 16:19:56 2004
+++ edited/arch/ia64/kernel/iosapic.c	Fri Feb 27 11:39:48 2004
@@ -103,6 +103,7 @@
 
 static struct iosapic_intr_info {
 	char		*addr;		/* base address of IOSAPIC */
+	u32		low32;		/* current value of low word of Redirection table entry */
 	unsigned int	gsi_base;	/* first GSI assigned to this IOSAPIC */
 	char		rte_index;	/* IOSAPIC RTE index (-1 => not an IOSAPIC interrupt) */
 	unsigned char	dmode	: 3;	/* delivery mode (see iosapic.h) */
@@ -213,6 +214,7 @@
 	writel(high32, addr + IOSAPIC_WINDOW);
 	writel(IOSAPIC_RTE_LOW(rte_index), addr + IOSAPIC_REG_SELECT);
 	writel(low32, addr + IOSAPIC_WINDOW);
+	iosapic_intr_info[vector].low32 = low32;
 }
 
 static void
@@ -239,9 +241,10 @@
 	spin_lock_irqsave(&iosapic_lock, flags);
 	{
 		writel(IOSAPIC_RTE_LOW(rte_index), addr + IOSAPIC_REG_SELECT);
-		low32 = readl(addr + IOSAPIC_WINDOW);
 
-		low32 |= (1 << IOSAPIC_MASK_SHIFT);    /* set only the mask bit */
+		/* set only the mask bit */
+		low32 = iosapic_intr_info[vec].low32 |= IOSAPIC_MASK;
+
 		writel(low32, addr + IOSAPIC_WINDOW);
 	}
 	spin_unlock_irqrestore(&iosapic_lock, flags);
@@ -264,9 +267,7 @@
 	spin_lock_irqsave(&iosapic_lock, flags);
 	{
 		writel(IOSAPIC_RTE_LOW(rte_index), addr + IOSAPIC_REG_SELECT);
-		low32 = readl(addr + IOSAPIC_WINDOW);
-
-		low32 &= ~(1 << IOSAPIC_MASK_SHIFT);    /* clear only the mask bit */
+		low32 = iosapic_intr_info[vec].low32 &= ~IOSAPIC_MASK;
 		writel(low32, addr + IOSAPIC_WINDOW);
 	}
 	spin_unlock_irqrestore(&iosapic_lock, flags);
@@ -307,9 +308,7 @@
 	{
 		/* get current delivery mode by reading the low32 */
 		writel(IOSAPIC_RTE_LOW(rte_index), addr + IOSAPIC_REG_SELECT);
-		low32 = readl(addr + IOSAPIC_WINDOW);
-
-		low32 &= ~(7 << IOSAPIC_DELIVERY_SHIFT);
+		low32 = iosapic_intr_info[vec].low32 & ~(7 << IOSAPIC_DELIVERY_SHIFT);
 		if (redir)
 		        /* change delivery mode to lowest priority */
 			low32 |= (IOSAPIC_LOWEST_PRIORITY << IOSAPIC_DELIVERY_SHIFT);
@@ -317,6 +316,7 @@
 		        /* change delivery mode to fixed */
 			low32 |= (IOSAPIC_FIXED << IOSAPIC_DELIVERY_SHIFT);
 
+		iosapic_intr_info[vec].low32 = low32;
 		writel(IOSAPIC_RTE_HIGH(rte_index), addr + IOSAPIC_REG_SELECT);
 		writel(high32, addr + IOSAPIC_WINDOW);
 		writel(IOSAPIC_RTE_LOW(rte_index), addr + IOSAPIC_REG_SELECT);
 
=== include/asm-ia64/iosapic.h 1.12 vs edited ==--- 1.12/include/asm-ia64/iosapic.h	Tue Jan 13 12:30:32 2004
+++ edited/include/asm-ia64/iosapic.h	Fri Feb 27 11:39:17 2004
@@ -45,9 +45,9 @@
 /*
  * Mask bit
  */
+
 #define	IOSAPIC_MASK_SHIFT		16
-#define	IOSAPIC_UNMASK			0
-#define	IOSAPIC_MSAK			1
+#define	IOSAPIC_MASK			(1<<IOSAPIC_MASK_SHIFT)
 
 #ifndef __ASSEMBLY__
 
