From: Thomas Gleixner <tglx@linutronix.de>
Date: Fri, 25 Mar 2011 21:14:58 +0000
Subject: [patch 22/23 -v2] ia64: Use generic show_interrupts()
Message-Id: <20110325211246.355789847@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>

So much for doing last minute changes :(

---
 arch/ia64/Kconfig      |    1 +
 arch/ia64/kernel/irq.c |   42 ++----------------------------------------
 2 files changed, 3 insertions(+), 40 deletions(-)

Index: linux-2.6-tip/arch/ia64/Kconfig
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6-tip.orig/arch/ia64/Kconfig
+++ linux-2.6-tip/arch/ia64/Kconfig
@@ -26,6 +26,7 @@ config IA64
 	select GENERIC_IRQ_PROBE
 	select GENERIC_PENDING_IRQ if SMP
 	select IRQ_PER_CPU
+	select GENERIC_IRQ_SHOW
 	default y
 	help
 	  The Itanium Processor Family is Intel's 64-bit successor to
Index: linux-2.6-tip/arch/ia64/kernel/irq.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6-tip.orig/arch/ia64/kernel/irq.c
+++ linux-2.6-tip/arch/ia64/kernel/irq.c
@@ -53,47 +53,9 @@ atomic_t irq_err_count;
 /*
  * /proc/interrupts printing:
  */
-
-int show_interrupts(struct seq_file *p, void *v)
+int arch_show_interrupts(struct seq_file *p, int prec)
 {
-	int i =3D *(loff_t *) v, j;
-	struct irqaction * action;
-	unsigned long flags;
-
-	if (i =3D 0) {
-		char cpuname[16];
-		seq_printf(p, "     ");
-		for_each_online_cpu(j) {
-			snprintf(cpuname, 10, "CPU%d", j);
-			seq_printf(p, "%10s ", cpuname);
-		}
-		seq_putc(p, '\n');
-	}
-
-	if (i < NR_IRQS) {
-		raw_spin_lock_irqsave(&irq_desc[i].lock, flags);
-		action =3D irq_desc[i].action;
-		if (!action)
-			goto skip;
-		seq_printf(p, "%3d: ",i);
-#ifndef CONFIG_SMP
-		seq_printf(p, "%10u ", kstat_irqs(i));
-#else
-		for_each_online_cpu(j) {
-			seq_printf(p, "%10u ", kstat_irqs_cpu(i, j));
-		}
-#endif
-		seq_printf(p, " %14s", irq_desc[i].chip->name);
-		seq_printf(p, "  %s", action->name);
-
-		for (action=ACtion->next; action; action =3D action->next)
-			seq_printf(p, ", %s", action->name);
-
-		seq_putc(p, '\n');
-skip:
-		raw_spin_unlock_irqrestore(&irq_desc[i].lock, flags);
-	} else if (i =3D NR_IRQS)
-		seq_printf(p, "ERR: %10u\n", atomic_read(&irq_err_count));
+	seq_printf(p, "ERR: %10u\n", atomic_read(&irq_err_count));
 	return 0;
 }
=20


