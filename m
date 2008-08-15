From: Robin Holt <holt@sgi.com>
Date: Fri, 15 Aug 2008 14:21:24 +0000
Subject: [Patch] Shrink shadow_flush_counts to a short array to save 8k of
Message-Id: <20080815142124.GO6824@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Making allmodconfig will break the current build.  This patch shrinks
the per_cpu__shadow_flush_counts from 16k to 8k which frees enough space
to allow allmodconfig to successfully complete.

Signed-off-by: Robin Holt <holt@sgi.com>
Acked-by: Jack Steiner <steiner@sgi.com>

---

I realize this is not as clean as it might be.  We were concerned both
about moving the shadow_flush_counts[] to be an allocation and then
causing additional TLB (albeit slight) pressure.  This seemed like a
reasonable compromise.  I don't think I personally have any additional
time to put into this issue for this kernel release.

Robin


Index: reduce_per_cpu_usage/arch/ia64/kernel/smp.c
=================================--- reduce_per_cpu_usage.orig/arch/ia64/kernel/smp.c	2008-08-15 09:04:39.434143449 -0500
+++ reduce_per_cpu_usage/arch/ia64/kernel/smp.c	2008-08-15 09:10:22.436964745 -0500
@@ -58,7 +58,7 @@ static struct local_tlb_flush_counts {
 	unsigned int count;
 } __attribute__((__aligned__(32))) local_tlb_flush_counts[NR_CPUS];
 
-static DEFINE_PER_CPU(unsigned int, shadow_flush_counts[NR_CPUS]) ____cacheline_aligned;
+static DEFINE_PER_CPU(unsigned short, shadow_flush_counts[NR_CPUS]) ____cacheline_aligned;
 
 #define IPI_CALL_FUNC		0
 #define IPI_CPU_STOP		1
@@ -254,7 +254,7 @@ smp_local_flush_tlb(void)
 void
 smp_flush_tlb_cpumask(cpumask_t xcpumask)
 {
-	unsigned int *counts = __ia64_per_cpu_var(shadow_flush_counts);
+	unsigned short *counts = __ia64_per_cpu_var(shadow_flush_counts);
 	cpumask_t cpumask = xcpumask;
 	int mycpu, cpu, flush_mycpu = 0;
 
@@ -262,7 +262,7 @@ smp_flush_tlb_cpumask(cpumask_t xcpumask
 	mycpu = smp_processor_id();
 
 	for_each_cpu_mask(cpu, cpumask)
-		counts[cpu] = local_tlb_flush_counts[cpu].count;
+		counts[cpu] = local_tlb_flush_counts[cpu].count & 0xffff;
 
 	mb();
 	for_each_cpu_mask(cpu, cpumask) {
@@ -276,7 +276,7 @@ smp_flush_tlb_cpumask(cpumask_t xcpumask
 		smp_local_flush_tlb();
 
 	for_each_cpu_mask(cpu, cpumask)
-		while(counts[cpu] = local_tlb_flush_counts[cpu].count)
+		while(counts[cpu] = (local_tlb_flush_counts[cpu].count & 0xffff))
 			udelay(FLUSH_DELAY);
 
 	preempt_enable();
