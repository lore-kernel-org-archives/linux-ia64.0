From: Martin Pool <mbp@samba.org>
Date: Wed, 06 Aug 2003 06:52:45 +0000
Subject: [patch] fix "struct irq_desc"
Message-Id: <marc-linux-ia64-106015279501948@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In linux-2.6.0-test2-ia64-030729 configured for generic ia64,
asm-ia64/machvec.h returns a 'struct irq_desc'.  There is a forward
declaration for the struct, but it is never actually defined under
that name, only as irq_desc_t.

This means that the type of ia64_mv_irq_desc is wrong, which causes
the build to break in some files that are built with -Werror.  Really
this is incorrect even for non-generic builds although it does not
actually fail.

This patch puts in both the struct name and _t name:

--- linux-2.6.0test2-ia64/include/linux/irq.h.~1~	2003-07-29 12:05:34.000000000 +1000
+++ linux-2.6.0test2-ia64/include/linux/irq.h	2003-08-06 16:33:30.000000000 +1000
@@ -56,7 +56,7 @@ typedef struct hw_interrupt_type  hw_irq
  *
  * Pad this out to 32 bytes for cache and indexing reasons.
  */
-typedef struct {
+typedef struct irq_desc {
 	unsigned int status;		/* IRQ status */
 	hw_irq_controller *handler;
 	struct irqaction *action;	/* IRQ action list */

Perhaps it would be better to make everything use the irq_desc_t name?
That would require a somewhat larger rearrangement of the headers to
make it visible at that point, but I can do that if desired.

-- 
Martin 
