From: Colin Ngam <cngam@sgi.com>
Date: Fri, 04 Mar 2005 21:47:31 +0000
Subject: [PATCH 2.6.11-rc3 0/0] Altix: Shub2 External Interrupt extensions.
Message-Id: <20050304214731.1202.68882.38694@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hi Tony,

Shub2 provides an addition of 2 External Interrupt events.  The following patch 
provides this support.

Thanks.

Signed-off-by: Colin Ngam <cngam@sgi.com>


=== arch/ia64/sn/kernel/irq.c 1.31 vs edited ==--- 1.31/arch/ia64/sn/kernel/irq.c	2005-01-22 17:54:50 -06:00
+++ edited/arch/ia64/sn/kernel/irq.c	2005-03-04 15:09:37 -06:00
@@ -82,20 +82,9 @@
 	nasid = get_nasid();
 	event_occurred  	    HUB_L((uint64_t *) GLOBAL_MMR_ADDR(nasid, SH_EVENT_OCCURRED));
-	if (event_occurred & SH_EVENT_OCCURRED_UART_INT_MASK) {
-		mask |= (1 << SH_EVENT_OCCURRED_UART_INT_SHFT);
-	}
-	if (event_occurred & SH_EVENT_OCCURRED_IPI_INT_MASK) {
-		mask |= (1 << SH_EVENT_OCCURRED_IPI_INT_SHFT);
-	}
-	if (event_occurred & SH_EVENT_OCCURRED_II_INT0_MASK) {
-		mask |= (1 << SH_EVENT_OCCURRED_II_INT0_SHFT);
-	}
-	if (event_occurred & SH_EVENT_OCCURRED_II_INT1_MASK) {
-		mask |= (1 << SH_EVENT_OCCURRED_II_INT1_SHFT);
-	}
+	mask = event_occurred & SH_ALL_INT_MASK;
 	HUB_S((uint64_t *) GLOBAL_MMR_ADDR(nasid, SH_EVENT_OCCURRED_ALIAS),
-	      mask);
+		 mask);
 	__set_bit(irq, (volatile void *)pda->sn_in_service_ivecs);
 
 	move_irq(irq);
=== include/asm-ia64/sn/shub_mmr.h 1.5 vs edited ==--- 1.5/include/asm-ia64/sn/shub_mmr.h	2004-12-10 15:04:21 -06:00
+++ edited/include/asm-ia64/sn/shub_mmr.h	2005-03-04 15:04:47 -06:00
@@ -129,6 +129,23 @@
 #define SH_EVENT_OCCURRED_II_INT1_SHFT           30
 #define SH_EVENT_OCCURRED_II_INT1_MASK           0x0000000040000000
 
+/*   SH2_EVENT_OCCURRED_EXTIO_INT2                                      */
+/*   Description:  Pending SHUB 2 EXT IO INT2                           */
+#define SH2_EVENT_OCCURRED_EXTIO_INT2_SHFT       33
+#define SH2_EVENT_OCCURRED_EXTIO_INT2_MASK       0x0000000200000000
+
+/*   SH2_EVENT_OCCURRED_EXTIO_INT3                                      */
+/*   Description:  Pending SHUB 2 EXT IO INT3                           */
+#define SH2_EVENT_OCCURRED_EXTIO_INT3_SHFT       34
+#define SH2_EVENT_OCCURRED_EXTIO_INT3_MASK       0x0000000400000000
+
+#define SH_ALL_INT_MASK \
+	(SH_EVENT_OCCURRED_UART_INT_MASK | SH_EVENT_OCCURRED_IPI_INT_MASK | \
+	 SH_EVENT_OCCURRED_II_INT0_MASK | SH_EVENT_OCCURRED_II_INT1_MASK | \
+	 SH_EVENT_OCCURRED_II_INT1_MASK | SH2_EVENT_OCCURRED_EXTIO_INT2_MASK | \
+	 SH2_EVENT_OCCURRED_EXTIO_INT3_MASK)
+
+
 /* ================================== */
 /*                         LEDS                                         */
 /* ================================== */
