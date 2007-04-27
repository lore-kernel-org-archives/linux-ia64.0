From: Satoru Takeuchi <takeuchi_satoru@jp.fujitsu.com>
Date: Fri, 27 Apr 2007 06:40:27 +0000
Subject: [PATCH 1/2] cleanup iosapic header file
Message-Id: <874pn2s4kk.wl%takeuchi_satoru@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Cleanup iosapic header file

 - Align some macros definition.
 - Remove extra line.
 - Add comment to `#endif' corresponding to '#ifdef CONFIG_IOSAPIC`
   for readability.

Signed-off-by: Satoru Takeuchi <takeuchi_satoru@jp.fujitsu.com>

Index: linux-2.6.21/include/asm-ia64/iosapic.h
=================================--- linux-2.6.21.orig/include/asm-ia64/iosapic.h	2007-04-26 12:08:32.000000000 +0900
+++ linux-2.6.21/include/asm-ia64/iosapic.h	2007-04-27 14:30:00.000000000 +0900
@@ -20,7 +20,7 @@
  */
 #define	IOSAPIC_DELIVERY_SHIFT		8
 #define	IOSAPIC_FIXED			0x0
-#define	IOSAPIC_LOWEST_PRIORITY	0x1
+#define	IOSAPIC_LOWEST_PRIORITY		0x1
 #define	IOSAPIC_PMI			0x2
 #define	IOSAPIC_NMI			0x4
 #define	IOSAPIC_INIT			0x5
@@ -31,7 +31,7 @@
  */
 #define	IOSAPIC_POLARITY_SHIFT		13
 #define	IOSAPIC_POL_HIGH		0
-#define	IOSAPIC_POL_LOW		1
+#define	IOSAPIC_POL_LOW			1
 
 /*
  * Trigger mode
@@ -43,7 +43,6 @@
 /*
  * Mask bit
  */
-
 #define	IOSAPIC_MASK_SHIFT		16
 #define	IOSAPIC_MASK			(1<<IOSAPIC_MASK_SHIFT)
 
@@ -106,7 +105,7 @@
 #define iosapic_override_isa_irq(isa_irq,gsi,polarity,trigger)	do { } while (0)
 #define iosapic_register_platform_intr(type,gsi,pmi,eid,id, \
 	polarity,trigger)					(gsi)
-#endif
+#endif /* CONFIG_IOSAPIC */
 
 # endif /* !__ASSEMBLY__ */
 #endif /* __ASM_IA64_IOSAPIC_H */
