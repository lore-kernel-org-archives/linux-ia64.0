From: Keith Owens <kaos@sgi.com>
Date: Wed, 30 Jun 2004 03:34:55 +0000
Subject: [patch 2.6.7] Rename local move_irq to sn_move_irq
Message-Id: <4655.1088566495@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Rename SN local function move_irq to sn_move_irq to remove conflict
with global move_irq.  Needed since ashok.raj moved move_irq() from
iosapic.c to irq.c.

Signed-off-by: Keith Owens <kaos@sgi.com>

Index: linux/arch/ia64/sn/kernel/irq.c
=================================--- linux.orig/arch/ia64/sn/kernel/irq.c	Wed Jun 30 13:25:04 2004
+++ linux/arch/ia64/sn/kernel/irq.c	Wed Jun 30 13:31:06 2004
@@ -72,7 +72,7 @@ sn_enable_irq(unsigned int irq)
 {
 }
 
-static inline void move_irq(int irq)
+static inline void sn_move_irq(int irq)
 {
 	/* note - we hold desc->lock */
 	cpumask_t tmp;
@@ -110,7 +110,7 @@ sn_ack_irq(unsigned int irq)
 	}
 	HUB_S((unsigned long *)GLOBAL_MMR_ADDR(nasid, SH_EVENT_OCCURRED_ALIAS), mask );
 	__set_bit(irq, (volatile void *)pda->sn_in_service_ivecs);
-	move_irq(irq);
+	sn_move_irq(irq);
 }
 
 static void

