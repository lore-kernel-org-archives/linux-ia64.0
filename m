From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Wed, 07 Sep 2005 05:04:14 +0000
Subject: [PATCH 2.6.13 1/3] Minor cleanups - remove unnecessary function prototype
Message-Id: <431E74CE.2090305@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The function prototype for handl_IRQ_event() in include/asm-ia64/irq.h
is no longer needed. This patch removes it.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>

---

 include/asm-ia64/irq.h |    4 ----
 1 files changed, 4 deletions(-)

diff -puN include/asm-ia64/irq.h~ia64-cleanup-remove-handle_IRQ_event include/asm-ia64/irq.h
--- linux-2.6.13/include/asm-ia64/irq.h~ia64-cleanup-remove-handle_IRQ_event	2005-09-07 11:53:11.000000000 +0900
+++ linux-2.6.13-kanesige/include/asm-ia64/irq.h	2005-09-07 11:53:11.000000000 +0900
@@ -36,8 +36,4 @@ extern void move_irq(int irq);
 #define move_irq(irq)
 #endif
 
-struct irqaction;
-struct pt_regs;
-int handle_IRQ_event(unsigned int, struct pt_regs *, struct irqaction *);
-
 #endif /* _ASM_IA64_IRQ_H */
_

