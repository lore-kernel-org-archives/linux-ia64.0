From: Christoph Hellwig <hch@lst.de>
Date: Tue, 16 Nov 2004 09:14:08 +0000
Subject: [PATCH] remove dead wood from asm-ia64/hardirq.h
Message-Id: <20041116091408.GA3050@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

syscall_count, ksoftirqd_task, local_syscall_count, local_ksoftirqd_task
and local_nmi_count are totally unused (and gone from other
architectures aswell)

nmi_count() is a stub only used once in arch/ia64/kernel/irq.c, so we
can use 0 directly there.  I suspect it was added to keep irq.c in sync
with i386, but even the CONFIG_GENERIC_HARDIRQS code (<hint>which IA64
needs to be converted to</hint>) leaves /proc/interrupts output to the
architecture because it's so different over the architectures.


Signed-off-by: Christoph Hellwig <hch@lst.de>


--- 1.51/arch/ia64/kernel/irq.c	2004-10-20 10:37:14 +02:00
+++ edited/arch/ia64/kernel/irq.c	2004-11-14 12:17:09 +01:00
@@ -215,10 +215,11 @@ int show_interrupts(struct seq_file *p, 
 skip:
 		spin_unlock_irqrestore(&idesc->lock, flags);
 	} else if (i = NR_IRQS) {
+		/* XXX: why do we even print the NMI count if it's always 0? */
 		seq_puts(p, "NMI: ");
 		for (j = 0; j < NR_CPUS; j++)
 			if (cpu_online(j))
-				seq_printf(p, "%10u ", nmi_count(j));
+				seq_printf(p, "%10u ", 0);
 		seq_putc(p, '\n');
 #ifdef CONFIG_X86_LOCAL_APIC
 		seq_puts(p, "LOC: ");
--- 1.18/include/asm-ia64/hardirq.h	2004-11-08 03:08:14 +01:00
+++ edited/include/asm-ia64/hardirq.h	2004-11-14 12:19:42 +01:00
@@ -20,14 +20,7 @@
 #define __ARCH_IRQ_STAT	1
 
 #define softirq_pending(cpu)		(cpu_data(cpu)->softirq_pending)
-#define syscall_count(cpu)		/* unused on IA-64 */
-#define ksoftirqd_task(cpu)		(cpu_data(cpu)->ksoftirqd)
-#define nmi_count(cpu)			0
-
 #define local_softirq_pending()		(local_cpu_data->softirq_pending)
-#define local_syscall_count()		/* unused on IA-64 */
-#define local_ksoftirqd_task()		(local_cpu_data->ksoftirqd)
-#define local_nmi_count()		0
 
 #define HARDIRQ_BITS	14
 
