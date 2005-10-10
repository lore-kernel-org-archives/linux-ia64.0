From: hawkes@sgi.com
Date: Mon, 10 Oct 2005 15:43:26 +0000
Subject: [PATCH] 2.6.14-rc3: wider use of for_each_cpu_mask() in arch/ia64
Message-Id: <20051010154326.15701.89844.sendpatchset@tomahawk.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051008174331.27208.6062.sendpatchset@tomahawk.engr.sgi.com>
In-Reply-To: <20051008174331.27208.6062.sendpatchset@tomahawk.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Retry with fixes:

In arch/ia64 change the explicit use of for-loops and NR_CPUS into the
general for_each_cpu() or for_each_online_cpu() constructs, as
appropriate.  This widens the scope of potential future optimizations
of the general constructs, as well as takes advantage of the existing
optimizations of first_cpu() and next_cpu().

Signed-off-by: John Hawkes <hawkes@sgi.com>

Index: linux/arch/ia64/mm/tlb.c
=================================--- linux.orig/arch/ia64/mm/tlb.c	2005-10-10 08:27:31.000000000 -0700
+++ linux/arch/ia64/mm/tlb.c	2005-10-10 08:32:03.000000000 -0700
@@ -77,9 +77,10 @@
 	/* can't call flush_tlb_all() here because of race condition with O(1) scheduler [EF] */
 	{
 		int cpu = get_cpu(); /* prevent preemption/migration */
-		for (i = 0; i < NR_CPUS; ++i)
-			if (cpu_online(i) && (i != cpu))
+		for_each_online_cpu(i) {
+			if (i != cpu)
 				per_cpu(ia64_need_tlb_flush, i) = 1;
+		}
 		put_cpu();
 	}
 	local_flush_tlb_all();
Index: linux/arch/ia64/kernel/module.c
=================================--- linux.orig/arch/ia64/kernel/module.c	2005-10-10 08:27:31.000000000 -0700
+++ linux/arch/ia64/kernel/module.c	2005-10-10 08:32:47.000000000 -0700
@@ -947,8 +947,8 @@
 percpu_modcopy (void *pcpudst, const void *src, unsigned long size)
 {
 	unsigned int i;
-	for (i = 0; i < NR_CPUS; i++)
-		if (cpu_possible(i))
-			memcpy(pcpudst + __per_cpu_offset[i], src, size);
+	for_each_cpu(i) {
+		memcpy(pcpudst + __per_cpu_offset[i], src, size);
+	}
 }
 #endif /* CONFIG_SMP */
Index: linux/arch/ia64/kernel/smpboot.c
=================================--- linux.orig/arch/ia64/kernel/smpboot.c	2005-10-10 08:27:31.000000000 -0700
+++ linux/arch/ia64/kernel/smpboot.c	2005-10-10 08:33:18.000000000 -0700
@@ -694,9 +694,9 @@
 	 * Allow the user to impress friends.
 	 */
 
-	for (cpu = 0; cpu < NR_CPUS; cpu++)
-		if (cpu_online(cpu))
-			bogosum += cpu_data(cpu)->loops_per_jiffy;
+	for_each_online_cpu(cpu) {
+		bogosum += cpu_data(cpu)->loops_per_jiffy;
+	}
 
 	printk(KERN_INFO "Total of %d processors activated (%lu.%02lu BogoMIPS).\n",
 	       (int)num_online_cpus(), bogosum/(500000/HZ), (bogosum/(5000/HZ))%100);
Index: linux/arch/ia64/kernel/irq.c
=================================--- linux.orig/arch/ia64/kernel/irq.c	2005-10-10 08:27:31.000000000 -0700
+++ linux/arch/ia64/kernel/irq.c	2005-10-10 08:34:09.000000000 -0700
@@ -57,9 +57,9 @@
 
 	if (i = 0) {
 		seq_printf(p, "           ");
-		for (j=0; j<NR_CPUS; j++)
-			if (cpu_online(j))
-				seq_printf(p, "CPU%d       ",j);
+		for_each_online_cpu(j) {
+			seq_printf(p, "CPU%d       ",j);
+		}
 		seq_putc(p, '\n');
 	}
 
@@ -72,9 +72,9 @@
 #ifndef CONFIG_SMP
 		seq_printf(p, "%10u ", kstat_irqs(i));
 #else
-		for (j = 0; j < NR_CPUS; j++)
-			if (cpu_online(j))
-				seq_printf(p, "%10u ", kstat_cpu(j).irqs[i]);
+		for_each_online_cpu(j) {
+			seq_printf(p, "%10u ", kstat_cpu(j).irqs[i]);
+		}
 #endif
 		seq_printf(p, " %14s", irq_desc[i].handler->typename);
 		seq_printf(p, "  %s", action->name);
Index: linux/arch/ia64/kernel/smp.c
=================================--- linux.orig/arch/ia64/kernel/smp.c	2005-10-10 08:27:31.000000000 -0700
+++ linux/arch/ia64/kernel/smp.c	2005-10-10 08:34:50.000000000 -0700
@@ -200,8 +200,8 @@
 {
 	unsigned int i;
 
-	for (i = 0; i < NR_CPUS; i++) {
-		if (cpu_online(i) && i != smp_processor_id())
+	for_each_online_cpu(i) {
+		if (i != smp_processor_id())
 			send_IPI_single(i, op);
 	}
 }
@@ -214,9 +214,9 @@
 {
 	int i;
 
-	for (i = 0; i < NR_CPUS; i++)
-		if (cpu_online(i))
-			send_IPI_single(i, op);
+	for_each_online_cpu(i) {
+		send_IPI_single(i, op);
+	}
 }
 
 /*
