From: Simon Horman <horms@verge.net.au>
Date: Wed, 28 Nov 2007 09:21:21 +0000
Subject: [patch 4/4] ia64: remove gsi_to_vector
Message-Id: <20071128092247.671892943@vergenet.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

gsi_to_vector() is not used anywhere so it seems sensible
to remove it.

Signed-off-by: Simon Horman <horms@verge.net.au>

Index: linux-2.6/arch/ia64/kernel/iosapic.c
=================================--- linux-2.6.orig/arch/ia64/kernel/iosapic.c	2007-11-28 13:29:02.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/iosapic.c	2007-11-28 13:30:17.000000000 +0900
@@ -199,19 +199,6 @@ static inline int __gsi_to_irq(unsigned 
 	return -1;
 }
 
-/*
- * Translate GSI number to the corresponding IA-64 interrupt vector.  If no
- * entry exists, return -1.
- */
-inline int
-gsi_to_vector (unsigned int gsi)
-{
-	int irq = __gsi_to_irq(gsi);
-	if (check_irq_used(irq) < 0)
-		return -1;
-	return irq_to_vector(irq);
-}
-
 int
 gsi_to_irq (unsigned int gsi)
 {
Index: linux-2.6/include/asm-ia64/iosapic.h
=================================--- linux-2.6.orig/include/asm-ia64/iosapic.h	2007-11-28 13:29:02.000000000 +0900
+++ linux-2.6/include/asm-ia64/iosapic.h	2007-11-28 13:30:43.000000000 +0900
@@ -80,7 +80,6 @@ extern int iosapic_remove (unsigned int 
 #else
 #define iosapic_remove(gsi_base)				(-EINVAL)
 #endif /* CONFIG_HOTPLUG */
-extern int gsi_to_vector (unsigned int gsi);
 extern int gsi_to_irq (unsigned int gsi);
 extern int iosapic_register_intr (unsigned int gsi, unsigned long polarity,
 				  unsigned long trigger);

-- 

-- 
Horms

