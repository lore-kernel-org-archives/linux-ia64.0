From: Jack Steiner <steiner@sgi.com>
Date: Wed, 28 Jan 2004 20:59:12 +0000
Subject: [PATCH] - Improve SN2 TLB flushing algorithms
Message-Id: <20040128205912.GA27401@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The SGI NUMA platform does not use the hardware "ptc" instruction
to flush TLBs. Instead, it has to write an MMR on the chipset on each
node to cause a TLB flush transaction to be placed on the bus. On
large systems, the overhead to broadcast the TLB flush to every node
in the system is one of the hot spots in the kernel.

In most cases, the TLB context being flushed has been loaded into
a small subset of the nodes. Flushing every node is unnecessary.

This patch uses the cpu_vm_mask to track cpus that have loaded a context. 
TLB's are flushed only on these nodes.


(This patch is an update to a patch proposed in Dec. It incorporates
suggestions from David M that substantially improves the patch).




--- linux.base/./include/asm-ia64/mmu_context.h	Fri Jan  9 00:59:09 2004
+++ linux/./include/asm-ia64/mmu_context.h	Tue Jan 27 12:56:13 2004
@@ -21,6 +21,7 @@
 
 # ifndef __ASSEMBLY__
 
+#include <linux/config.h>
 #include <linux/compiler.h>
 #include <linux/percpu.h>
 #include <linux/sched.h>
@@ -106,6 +107,9 @@
 		/* re-check, now that we've got the lock: */
 		context = mm->context;
 		if (context = 0) {
+#ifdef CONFIG_NUMA
+			cpus_clear(mm->cpu_vm_mask);
+#endif
 			if (ia64_ctx.next >= ia64_ctx.limit)
 				wrap_mmu_context(mm);
 			mm->context = context = ia64_ctx.next++;
@@ -170,6 +174,10 @@
 	do {
 		context = get_mmu_context(mm);
 		MMU_TRACE('A', smp_processor_id(), mm, context);
+#ifdef CONFIG_NUMA
+		if (!cpu_isset(smp_processor_id(), mm->cpu_vm_mask))
+			cpu_set(smp_processor_id(), mm->cpu_vm_mask);
+#endif
 		reload_context(context);
 		MMU_TRACE('a', smp_processor_id(), mm, context);
 		/* in the unlikely event of a TLB-flush by another thread, redo the load: */



--- linux.base/./arch/ia64/sn/kernel/sn2/sn2_smp.c	Mon Jan 26 17:06:03 2004
+++ linux/./arch/ia64/sn/kernel/sn2/sn2_smp.c	Tue Jan 27 10:28:30 2004
@@ -26,6 +26,8 @@
 #include <asm/delay.h>
 #include <asm/io.h>
 #include <asm/smp.h>
+#include <asm/numa.h>
+#include <asm/bitops.h>
 #include <asm/hw_irq.h>
 #include <asm/current.h>
 #include <asm/sn/sn_cpuid.h>
@@ -34,6 +36,13 @@
 #include <asm/sn/nodepda.h>
 #include <asm/sn/rw_mmr.h>
 
+/* When nodemask_t is available, delete the following definitions */
+#define NODEMASK_WORDCOUNT       ((NR_NODES+(BITS_PER_LONG-1))/BITS_PER_LONG)
+#define NODE_MASK_ALL    { [0 ... ((NR_NODES+BITS_PER_LONG-1)/BITS_PER_LONG)-1] = ~0UL }
+#define NODE_MASK_NONE   { [0 ... ((NR_NODES+BITS_PER_LONG-1)/BITS_PER_LONG)-1] = 0 }
+typedef unsigned long   nodemask_t[NODEMASK_WORDCOUNT];
+
+
 void sn2_ptc_deadlock_recovery(unsigned long data0, unsigned long data1);
 
 
@@ -66,14 +75,52 @@
  *
  * Purges the translation caches of all processors of the given virtual address
  * range.
+ *
+ * Note:
+ * 	- cpu_vm_mask is a bit mask that indicates which cpus have loaded the context.
+ * 	- cpu_vm_mask is converted into a nodemask of the nodes containing the
+ * 	  cpus in cpu_vm_mask.
+ *	- if only one bit is set in cpu_vm_mask & it is the current cpu,
+ *	  then only the local TLB needs to be flushed. This flushing can be done
+ *	  using ptc.l. This is the common case & avoids the global spinlock.
+ *	- if multiple cpus have loaded the context, then flushing has to be
+ *	  done with ptc.g/MMRs under protection of the global ptc_lock.
  */
 
 void
 sn2_global_tlb_purge (unsigned long start, unsigned long end, unsigned long nbits)
 {
-	int			cnode, mycnode, nasid, flushed=0;
+	int			i, cnode, mynasid, cpu, lcpu=0, nasid, flushed=0;
 	volatile unsigned	long	*ptc0, *ptc1;
 	unsigned long		flags=0, data0, data1;
+	struct mm_struct	*mm=current->active_mm;
+	nodemask_t		nodes_flushed=NODE_MASK_NONE;
+	short			nasids[NR_NODES], nix;
+
+	for (i=0, cpu=find_first_bit(&mm->cpu_vm_mask, NR_CPUS); cpu < NR_CPUS;
+			i++, cpu=find_next_bit(&mm->cpu_vm_mask, NR_CPUS, ++cpu)) {
+		cnode = cpu_to_node(cpu);
+		__set_bit(cnode, nodes_flushed);
+		lcpu = cpu;
+	}
+
+	preempt_disable();
+
+	if (likely(i = 1 && lcpu = smp_processor_id())) {
+		do {
+			asm volatile ("ptc.l %0,%1" :: "r"(start), "r"(nbits<<2) : "memory");
+			start += (1UL << nbits);
+		} while (start < end);
+		ia64_srlz_i();
+		preempt_enable();
+		return;
+	}
+
+	nix = 0;
+	for (cnode=find_first_bit(&nodes_flushed, NR_NODES); cnode < NR_NODES; 
+			cnode=find_next_bit(&nodes_flushed, NR_NODES, ++cnode))
+		nasids[nix++] = cnodeid_to_nasid(cnode);
+
 
 	data0 = (1UL<<SH_PTC_0_A_SHFT) |
 		(nbits<<SH_PTC_0_PS_SHFT) |
@@ -83,19 +130,18 @@
 	ptc0 = (long*)GLOBAL_MMR_PHYS_ADDR(0, SH_PTC_0);
 	ptc1 = (long*)GLOBAL_MMR_PHYS_ADDR(0, SH_PTC_1);
 
-	mycnode = numa_node_id();
+
+	mynasid = smp_physical_node_id();
 
 	spin_lock_irqsave(&sn2_global_ptc_lock, flags);
 
 	do {
 		data1 = start | (1UL<<SH_PTC_1_START_SHFT);
-		for (cnode = 0; cnode < numnodes; cnode++) {
-			if (is_headless_node(cnode))
-				continue;
-			if (cnode = mycnode) {
+		for (i=0; i<nix; i++) {
+			nasid = nasids[i];
+			if (likely(nasid = mynasid)) {
 				asm volatile ("ptc.ga %0,%1;;srlz.i;;" :: "r"(start), "r"(nbits<<2) : "memory");
 			} else {
-				nasid = cnodeid_to_nasid(cnode);
 				ptc0 = CHANGE_NASID(nasid, ptc0);
 				ptc1 = CHANGE_NASID(nasid, ptc1);
 				pio_atomic_phys_write_mmrs(ptc0, data0, ptc1, data1);
@@ -113,6 +159,7 @@
 
 	spin_unlock_irqrestore(&sn2_global_ptc_lock, flags);
 
+	preempt_enable();
 }
 
 /*
@@ -218,3 +265,4 @@
 
 	sn_send_IPI_phys(physid, vector, delivery_mode);
 }
+EXPORT_SYMBOL(sn2_send_IPI);
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


