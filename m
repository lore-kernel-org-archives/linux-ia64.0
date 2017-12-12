From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Date: Tue, 12 Dec 2017 07:34:53 +0000
Subject: [PATCHv2 11/13] irq debug: do not use print_symbol()
Message-Id: <20171212073453.21455-1-sergey.senozhatsky@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171211125025.2270-12-sergey.senozhatsky@gmail.com>
In-Reply-To: <20171211125025.2270-12-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

print_symbol() uses extra stack space to sprintf() symbol
information and then to feed that buffer to printk()

  char buffer[KSYM_SYMBOL_LEN];

  sprint_symbol(buffer, address);
  printk(fmt, buffer);

Replace print_symbol() with a direct printk("%pS") call.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
---
 kernel/irq/debug.h | 14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/kernel/irq/debug.h b/kernel/irq/debug.h
index 17f05ef8f575..7e06dd275c17 100644
--- a/kernel/irq/debug.h
+++ b/kernel/irq/debug.h
@@ -3,8 +3,6 @@
  * Debugging printout:
  */
 
-#include <linux/kallsyms.h>
-
 #define ___P(f) if (desc->status_use_accessors & f) printk("%14s set\n", #f)
 #define ___PS(f) if (desc->istate & f) printk("%14s set\n", #f)
 /* FIXME */
@@ -14,14 +12,14 @@ static inline void print_irq_desc(unsigned int irq, struct irq_desc *desc)
 {
 	printk("irq %d, desc: %p, depth: %d, count: %d, unhandled: %d\n",
 		irq, desc, desc->depth, desc->irq_count, desc->irqs_unhandled);
-	printk("->handle_irq():  %p, ", desc->handle_irq);
-	print_symbol("%s\n", (unsigned long)desc->handle_irq);
-	printk("->irq_data.chip(): %p, ", desc->irq_data.chip);
-	print_symbol("%s\n", (unsigned long)desc->irq_data.chip);
+	printk("->handle_irq():  %p, %pS\n",
+		desc->handle_irq, desc->handle_irq);
+	printk("->irq_data.chip(): %p, %pS\n",
+		desc->irq_data.chip, desc->irq_data.chip);
 	printk("->action(): %p\n", desc->action);
 	if (desc->action) {
-		printk("->action->handler(): %p, ", desc->action->handler);
-		print_symbol("%s\n", (unsigned long)desc->action->handler);
+		printk("->action->handler(): %p, %pS\n",
+			desc->action->handler, desc->action->handler);
 	}
 
 	___P(IRQ_LEVEL);
-- 
2.15.1

