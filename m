From: "H. J. Lu" <hjl@lucon.org>
Date: Thu, 07 Aug 2003 07:22:26 +0000
Subject: 2.6 PATCH: Fix include/asm-ia64/machvec.h
Message-Id: <marc-linux-ia64-106024096120438@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

include/asm-ia64/machvec.h has

/* forward declarations: */
...
struct irq_desc;
...
typedef struct irq_desc *ia64_mv_irq_desc (unsigned int);

But struct irq_desc is never declared anywhere. Here is a patch to
fix it.


H.J.
---
--- linux/include/linux/irq.h.irq	Sun Jul 27 10:01:10 2003
+++ linux/include/linux/irq.h	Wed Aug  6 23:39:47 2003
@@ -56,7 +56,7 @@ typedef struct hw_interrupt_type  hw_irq
  *
  * Pad this out to 32 bytes for cache and indexing reasons.
  */
-typedef struct {
+typedef struct irq_desc {
 	unsigned int status;		/* IRQ status */
 	hw_irq_controller *handler;
 	struct irqaction *action;	/* IRQ action list */

