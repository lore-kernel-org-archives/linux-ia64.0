From: Ashok Raj <ashok.raj@intel.com>
Date: Fri, 28 Jan 2005 00:13:41 +0000
Subject: fix_smp_affinity_info - Fix /proc/irq/XX/smp_affinity to work with GENERIC_HARDIRQ
Message-Id: <20050127161341.A7684@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Tony

attached is a patch to fix the smp_affinity write. This was fixed earlier, 
but got undone in the GENERIC_HARDIRQ merges. 

-- 
Cheers,
Ashok Raj



---
fix_smp_affinity_info - Make GENERIC_HARDIRQ work for IPF and CPU Hotplug

Signed-off-by: Ashok Raj <ashok.raj@intel.com>

Made GENERIC_HARDIRQ mechanism work for IPF and CPU hotplug. When write to 
/proc/irq is handled it is not appropriate to perform set_rte immediatly, 
since there is a race when the interrupt is asserted while the re-program is 
happening. Hence such programming is only safe when we do the re-program at 
the time of servicing an interrupt. This got broken when GENERIC_HARDIRQ got 
introduced for IPF.

- Removed unnecessary static definition left over from tonys tree.
- added CONFIG_PENDING_IRQ so default /proc/irq write handler can do the 
  right thing.

TBD: We currently dont handle redirectable hint either in the display, or when
we handle writes to /proc/irq/XX/smp_affinity. We need an arch specific way 
to account for the presence of "r" hint when we handle the proc write.
---

 linux-ia64-release-2.6.11-araj/arch/ia64/Kconfig      |    4 ++++
 linux-ia64-release-2.6.11-araj/arch/ia64/kernel/irq.c |    1 -
 linux-ia64-release-2.6.11-araj/kernel/irq/proc.c      |   18 ++++++++++++++++--
 3 files changed, 20 insertions(+), 3 deletions(-)

diff -puN arch/ia64/kernel/irq.c~fix_smp_affinity arch/ia64/kernel/irq.c
--- linux-ia64-release-2.6.11/arch/ia64/kernel/irq.c~fix_smp_affinity	2005-01-27 15:22:14.895758210 -0800
+++ linux-ia64-release-2.6.11-araj/arch/ia64/kernel/irq.c	2005-01-27 15:26:54.195559476 -0800
@@ -97,7 +97,6 @@ skip:
 cpumask_t __cacheline_aligned pending_irq_cpumask[NR_IRQS];
 static unsigned long pending_irq_redir[BITS_TO_LONGS(NR_IRQS)];
 
-static cpumask_t irq_affinity [NR_IRQS] = { [0 ... NR_IRQS-1] = CPU_MASK_ALL };
 static char irq_redir [NR_IRQS]; // = { [0 ... NR_IRQS-1] = 1 };
 
 void set_irq_affinity_info (unsigned int irq, int hwid, int redir)
diff -puN kernel/irq/proc.c~fix_smp_affinity kernel/irq/proc.c
--- linux-ia64-release-2.6.11/kernel/irq/proc.c~fix_smp_affinity	2005-01-27 15:22:14.899664460 -0800
+++ linux-ia64-release-2.6.11-araj/kernel/irq/proc.c	2005-01-27 15:22:14.913336335 -0800
@@ -21,6 +21,21 @@ static struct proc_dir_entry *smp_affini
 
 cpumask_t irq_affinity[NR_IRQS] = { [0 ... NR_IRQS-1] = CPU_MASK_ALL };
 
+#ifndef CONFIG_PENDING_IRQ
+#define proc_set_irq_affinity(irq, new_value) 	\
+{												\
+	irq_affinity[irq] = new_value;				\
+	irq_desc[irq].handler->set_affinity(irq, new_value);	\
+}
+#else
+extern cpumask_t pending_irq_cpumask[];
+
+#define proc_set_irq_affinity(irq, new_value)	\
+{	\
+	pending_irq_cpumask[irq] = new_value;	\
+}
+#endif
+
 static int irq_affinity_read_proc(char *page, char **start, off_t off,
 				  int count, int *eof, void *data)
 {
@@ -55,8 +70,7 @@ static int irq_affinity_write_proc(struc
 	if (cpus_empty(tmp))
 		return -EINVAL;
 
-	irq_affinity[irq] = new_value;
-	irq_desc[irq].handler->set_affinity(irq, new_value);
+	proc_set_irq_affinity(irq, new_value);
 
 	return full_count;
 }
diff -puN arch/ia64/Kconfig~fix_smp_affinity arch/ia64/Kconfig
--- linux-ia64-release-2.6.11/arch/ia64/Kconfig~fix_smp_affinity	2005-01-27 15:22:14.904547273 -0800
+++ linux-ia64-release-2.6.11-araj/arch/ia64/Kconfig	2005-01-27 15:22:14.914312897 -0800
@@ -416,6 +416,10 @@ config GENERIC_IRQ_PROBE
 	bool
 	default y
 
+config PENDING_IRQ
+	bool
+	default y
+
 source "arch/ia64/hp/sim/Kconfig"
 
 source "arch/ia64/oprofile/Kconfig"
_
