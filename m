From: Jack Steiner <steiner@sgi.com>
Date: Thu, 05 Feb 2004 21:12:07 +0000
Subject: Re: [PATCH] - Improve SN2 TLB flushing algorithms
Message-Id: <20040205211207.GA32057@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040128205912.GA27401@sgi.com>
In-Reply-To: <20040128205912.GA27401@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David - here is an updated patch for SN2 TLB flushing. 
In the previous patch, I forgot to delete the "#include <config.h> 
in mmu_context.h - not needed since the #ifdef's are gone....


diff -Naur linux_base/arch/ia64/sn/kernel/sn2/sn2_smp.c linux/arch/ia64/sn/kernel/sn2/sn2_smp.c
--- linux_base/arch/ia64/sn/kernel/sn2/sn2_smp.c	Thu Jan 29 18:14:23 2004
+++ linux/arch/ia64/sn/kernel/sn2/sn2_smp.c	Mon Feb  2 08:09:31 2004
@@ -5,7 +5,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 2000-2003 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (C) 2000-2004 Silicon Graphics, Inc. All rights reserved.
  */
 
 #include <linux/init.h>
@@ -26,6 +26,8 @@
 #include <asm/delay.h>
 #include <asm/io.h>
 #include <asm/smp.h>
+#include <asm/numa.h>
+#include <asm/bitops.h>
 #include <asm/hw_irq.h>
 #include <asm/current.h>
 #include <asm/sn/sn_cpuid.h>
@@ -66,14 +68,56 @@
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
+	short			nasids[NR_NODES], nix;
+	DECLARE_BITMAP(nodes_flushed, NR_NODES);
+
+	CLEAR_BITMAP(nodes_flushed, NR_NODES);
+
+	i = 0;
+
+	for_each_cpu_mask(cpu, mm->cpu_vm_mask) {
+		cnode = cpu_to_node(cpu);
+		__set_bit(cnode, nodes_flushed);
+		lcpu = cpu;
+		i++;
+	}
+
+	preempt_disable();
+
+	if (likely(i = 1 && lcpu = smp_processor_id())) {
+		do {
+			ia64_ptcl(start, nbits<<2);
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
@@ -83,20 +127,19 @@
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
 				ia64_ptcga(start, nbits<<2);
 				ia64_srlz_i();
 			} else {
-				nasid = cnodeid_to_nasid(cnode);
 				ptc0 = CHANGE_NASID(nasid, ptc0);
 				ptc1 = CHANGE_NASID(nasid, ptc1);
 				pio_atomic_phys_write_mmrs(ptc0, data0, ptc1, data1);
@@ -114,6 +157,7 @@
 
 	spin_unlock_irqrestore(&sn2_global_ptc_lock, flags);
 
+	preempt_enable();
 }
 
 /*
diff -Naur linux_base/include/asm-ia64/mmu_context.h linux/include/asm-ia64/mmu_context.h
--- linux_base/include/asm-ia64/mmu_context.h	Thu Jan 29 18:15:14 2004
+++ linux/include/asm-ia64/mmu_context.h	Sun Feb  1 12:38:13 2004
@@ -106,6 +106,7 @@
 		/* re-check, now that we've got the lock: */
 		context = mm->context;
 		if (context = 0) {
+			cpus_clear(mm->cpu_vm_mask);
 			if (ia64_ctx.next >= ia64_ctx.limit)
 				wrap_mmu_context(mm);
 			mm->context = context = ia64_ctx.next++;
@@ -170,6 +171,8 @@
 	do {
 		context = get_mmu_context(mm);
 		MMU_TRACE('A', smp_processor_id(), mm, context);
+		if (!cpu_isset(smp_processor_id(), mm->cpu_vm_mask))
+			cpu_set(smp_processor_id(), mm->cpu_vm_mask);
 		reload_context(context);
 		MMU_TRACE('a', smp_processor_id(), mm, context);
 		/* in the unlikely event of a TLB-flush by another thread, redo the load: */
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


