From: akpm@osdl.org
Date: Mon, 28 Mar 2005 22:47:11 +0000
Subject: [patch 140/245] Fix irq_affinity write from /proc for ia64
Message-Id: <200503282247.j2SMlKqn009940@shell0.pdx.osdl.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


From: Ashok Raj <ashok.raj@intel.com>

Made GENERIC_HARDIRQ mechanism work for ia64 and CPU hotplug.  When write
to /proc/irq is handled it is not appropriate to perform set_rte
immediatly, since there is a race when the interrupt is asserted while the
re-program is happening.  Hence such programming is only safe when we do
the re-program at the time of servicing an interrupt.  This got broken when
GENERIC_HARDIRQ got introduced for ia64.

- added CONFIG_PENDING_IRQ so default /proc/irq write handler can do the right 
  thing.

TBD: We currently dont handle redirectable hint either in the display, or
when we handle writes to /proc/irq/XX/smp_affinity.  We need an arch
specific way to account for the presence of "r" hint when we handle the
proc write.

Signed-off-by: Ashok Raj <ashok.raj@intel.com>
Cc: <linux-ia64@vger.kernel.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/arch/ia64/kernel/irq.c |   12 ++++++++++--
 25-akpm/kernel/irq/proc.c      |   10 ++++++++--
 2 files changed, 18 insertions(+), 4 deletions(-)

diff -puN arch/ia64/kernel/irq.c~fix-irq_affinity-write-from-proc-for-ia64 arch/ia64/kernel/irq.c
--- 25/arch/ia64/kernel/irq.c~fix-irq_affinity-write-from-proc-for-ia64	2005-03-28 14:21:37.000000000 -0800
+++ 25-akpm/arch/ia64/kernel/irq.c	2005-03-28 14:21:37.000000000 -0800
@@ -94,12 +94,20 @@ skip:
 /*
  * This is updated when the user sets irq affinity via /proc
  */
-cpumask_t __cacheline_aligned pending_irq_cpumask[NR_IRQS];
+static cpumask_t __cacheline_aligned pending_irq_cpumask[NR_IRQS];
 static unsigned long pending_irq_redir[BITS_TO_LONGS(NR_IRQS)];
 
-static cpumask_t irq_affinity [NR_IRQS] = { [0 ... NR_IRQS-1] = CPU_MASK_ALL };
 static char irq_redir [NR_IRQS]; // = { [0 ... NR_IRQS-1] = 1 };
 
+/*
+ * Arch specific routine for deferred write to iosapic rte to reprogram
+ * intr destination.
+ */
+void proc_set_irq_affinity(unsigned int irq, cpumask_t mask_val)
+{
+	pending_irq_cpumask[irq] = mask_val;
+}
+
 void set_irq_affinity_info (unsigned int irq, int hwid, int redir)
 {
 	cpumask_t mask = CPU_MASK_NONE;
diff -puN kernel/irq/proc.c~fix-irq_affinity-write-from-proc-for-ia64 kernel/irq/proc.c
--- 25/kernel/irq/proc.c~fix-irq_affinity-write-from-proc-for-ia64	2005-03-28 14:21:37.000000000 -0800
+++ 25-akpm/kernel/irq/proc.c	2005-03-28 14:21:37.000000000 -0800
@@ -19,6 +19,13 @@ static struct proc_dir_entry *root_irq_d
  */
 static struct proc_dir_entry *smp_affinity_entry[NR_IRQS];
 
+void __attribute__((weak))
+proc_set_irq_affinity(unsigned int irq, cpumask_t mask_val)
+{
+	irq_affinity[irq] = mask_val;
+	irq_desc[irq].handler->set_affinity(irq, mask_val);
+}
+
 static int irq_affinity_read_proc(char *page, char **start, off_t off,
 				  int count, int *eof, void *data)
 {
@@ -53,8 +60,7 @@ static int irq_affinity_write_proc(struc
 	if (cpus_empty(tmp))
 		return -EINVAL;
 
-	irq_affinity[irq] = new_value;
-	irq_desc[irq].handler->set_affinity(irq, new_value);
+	proc_set_irq_affinity(irq, new_value);
 
 	return full_count;
 }
_
