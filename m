From: Tejun Heo <tj@kernel.org>
Date: Wed, 14 Oct 2009 06:02:00 +0000
Subject: [PATCH 11/16] percpu: make percpu symbols in ia64 unique
Message-Id: <1255500125-3210-12-git-send-email-tj@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1255500125-3210-1-git-send-email-tj@kernel.org>
In-Reply-To: <1255500125-3210-1-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, rusty@rustcorp.com.au, cl@linux-foundation.org, mingo@redhat.com, tglx@linutronix.de, akpm@linux-foundation.org, rostedt@goodmis.org, hpa@zytor.com, cebbert@redhat.com
Cc: Tejun Heo <tj@kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

This patch updates percpu related symbols in ia64 such that percpu
symbols are unique and don't clash with local symbols.  This serves
two purposes of decreasing the possibility of global percpu symbol
collision and allowing dropping per_cpu__ prefix from percpu symbols.

* arch/ia64/kernel/setup.c: s/cpu_info/ia64_cpu_info/

Partly based on Rusty Russell's "alloc_percpu: rename percpu vars
which cause name clashes" patch.

Signed-off-by: Tejun Heo <tj@kernel.org>
Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/include/asm/processor.h  |    6 +++---
 arch/ia64/kernel/head.S            |    4 ++--
 arch/ia64/kernel/ia64_ksyms.c      |    2 +-
 arch/ia64/kernel/mca_asm.S         |    2 +-
 arch/ia64/kernel/relocate_kernel.S |    2 +-
 arch/ia64/kernel/setup.c           |    4 ++--
 arch/ia64/mm/discontig.c           |    5 +++--
 arch/ia64/sn/kernel/sn2/sn2_smp.c  |    8 ++++----
 8 files changed, 17 insertions(+), 16 deletions(-)

diff --git a/arch/ia64/include/asm/processor.h b/arch/ia64/include/asm/processor.h
index 3eaeedf..7fa90f7 100644
--- a/arch/ia64/include/asm/processor.h
+++ b/arch/ia64/include/asm/processor.h
@@ -229,7 +229,7 @@ struct cpuinfo_ia64 {
 #endif
 };
 
-DECLARE_PER_CPU(struct cpuinfo_ia64, cpu_info);
+DECLARE_PER_CPU(struct cpuinfo_ia64, ia64_cpu_info);
 
 /*
  * The "local" data variable.  It refers to the per-CPU data of the currently executing
@@ -237,8 +237,8 @@ DECLARE_PER_CPU(struct cpuinfo_ia64, cpu_info);
  * Do not use the address of local_cpu_data, since it will be different from
  * cpu_data(smp_processor_id())!
  */
-#define local_cpu_data		(&__ia64_per_cpu_var(cpu_info))
-#define cpu_data(cpu)		(&per_cpu(cpu_info, cpu))
+#define local_cpu_data		(&__ia64_per_cpu_var(ia64_cpu_info))
+#define cpu_data(cpu)		(&per_cpu(ia64_cpu_info, cpu))
 
 extern void print_cpu_info (struct cpuinfo_ia64 *);
 
diff --git a/arch/ia64/kernel/head.S b/arch/ia64/kernel/head.S
index 696eff2..17a9fba 100644
--- a/arch/ia64/kernel/head.S
+++ b/arch/ia64/kernel/head.S
@@ -1051,7 +1051,7 @@ END(ia64_delay_loop)
  * intermediate precision so that we can produce a full 64-bit result.
  */
 GLOBAL_ENTRY(ia64_native_sched_clock)
-	addl r8=THIS_CPU(cpu_info) + IA64_CPUINFO_NSEC_PER_CYC_OFFSET,r0
+	addl r8=THIS_CPU(ia64_cpu_info) + IA64_CPUINFO_NSEC_PER_CYC_OFFSET,r0
 	mov.m r9=ar.itc		// fetch cycle-counter				(35 cyc)
 	;;
 	ldf8 f8=[r8]
@@ -1077,7 +1077,7 @@ sched_clock = ia64_native_sched_clock
 #ifdef CONFIG_VIRT_CPU_ACCOUNTING
 GLOBAL_ENTRY(cycle_to_cputime)
 	alloc r16=ar.pfs,1,0,0,0
-	addl r8=THIS_CPU(cpu_info) + IA64_CPUINFO_NSEC_PER_CYC_OFFSET,r0
+	addl r8=THIS_CPU(ia64_cpu_info) + IA64_CPUINFO_NSEC_PER_CYC_OFFSET,r0
 	;;
 	ldf8 f8=[r8]
 	;;
diff --git a/arch/ia64/kernel/ia64_ksyms.c b/arch/ia64/kernel/ia64_ksyms.c
index 14d39e3..461b999 100644
--- a/arch/ia64/kernel/ia64_ksyms.c
+++ b/arch/ia64/kernel/ia64_ksyms.c
@@ -30,7 +30,7 @@ EXPORT_SYMBOL(max_low_pfn);	/* defined by bootmem.c, but not exported by generic
 #endif
 
 #include <asm/processor.h>
-EXPORT_SYMBOL(per_cpu__cpu_info);
+EXPORT_SYMBOL(per_cpu__ia64_cpu_info);
 #ifdef CONFIG_SMP
 EXPORT_SYMBOL(per_cpu__local_per_cpu_offset);
 #endif
diff --git a/arch/ia64/kernel/mca_asm.S b/arch/ia64/kernel/mca_asm.S
index 7461d25..d5bdf9d 100644
--- a/arch/ia64/kernel/mca_asm.S
+++ b/arch/ia64/kernel/mca_asm.S
@@ -59,7 +59,7 @@
 ia64_do_tlb_purge:
 #define O(member)	IA64_CPUINFO_##member##_OFFSET
 
-	GET_THIS_PADDR(r2, cpu_info)	// load phys addr of cpu_info into r2
+	GET_THIS_PADDR(r2, ia64_cpu_info) // load phys addr of cpu_info into r2
 	;;
 	addl r17=O(PTCE_STRIDE),r2
 	addl r2=O(PTCE_BASE),r2
diff --git a/arch/ia64/kernel/relocate_kernel.S b/arch/ia64/kernel/relocate_kernel.S
index 32f6fc1..c370e02 100644
--- a/arch/ia64/kernel/relocate_kernel.S
+++ b/arch/ia64/kernel/relocate_kernel.S
@@ -61,7 +61,7 @@ GLOBAL_ENTRY(relocate_new_kernel)
 
 	// purge all TC entries
 #define O(member)       IA64_CPUINFO_##member##_OFFSET
-        GET_THIS_PADDR(r2, cpu_info)    // load phys addr of cpu_info into r2
+        GET_THIS_PADDR(r2, ia64_cpu_info) // load phys addr of cpu_info into r2
         ;;
         addl r17=O(PTCE_STRIDE),r2
         addl r2=O(PTCE_BASE),r2
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index bc1ef4a..a1ea879 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -74,7 +74,7 @@ unsigned long __per_cpu_offset[NR_CPUS];
 EXPORT_SYMBOL(__per_cpu_offset);
 #endif
 
-DEFINE_PER_CPU(struct cpuinfo_ia64, cpu_info);
+DEFINE_PER_CPU(struct cpuinfo_ia64, ia64_cpu_info);
 DEFINE_PER_CPU(unsigned long, local_per_cpu_offset);
 unsigned long ia64_cycles_per_usec;
 struct ia64_boot_param *ia64_boot_param;
@@ -967,7 +967,7 @@ cpu_init (void)
 	 * depends on the data returned by identify_cpu().  We break the dependency by
 	 * accessing cpu_data() through the canonical per-CPU address.
 	 */
-	cpu_info = cpu_data + ((char *) &__ia64_per_cpu_var(cpu_info) - __per_cpu_start);
+	cpu_info = cpu_data + ((char *) &__ia64_per_cpu_var(ia64_cpu_info) - __per_cpu_start);
 	identify_cpu(cpu_info);
 
 #ifdef CONFIG_MCKINLEY
diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
index 40e4c1f..19c4b21 100644
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -450,7 +450,8 @@ static void __init initialize_pernode_data(void)
 	/* Set the node_data pointer for each per-cpu struct */
 	for_each_possible_early_cpu(cpu) {
 		node = node_cpuid[cpu].nid;
-		per_cpu(cpu_info, cpu).node_data = mem_data[node].node_data;
+		per_cpu(ia64_cpu_info, cpu).node_data +			mem_data[node].node_data;
 	}
 #else
 	{
@@ -458,7 +459,7 @@ static void __init initialize_pernode_data(void)
 		cpu = 0;
 		node = node_cpuid[cpu].nid;
 		cpu0_cpu_info = (struct cpuinfo_ia64 *)(__phys_per_cpu_start +
-			((char *)&per_cpu__cpu_info - __per_cpu_start));
+			((char *)&per_cpu__ia64_cpu_info - __per_cpu_start));
 		cpu0_cpu_info->node_data = mem_data[node].node_data;
 	}
 #endif /* CONFIG_SMP */
diff --git a/arch/ia64/sn/kernel/sn2/sn2_smp.c b/arch/ia64/sn/kernel/sn2/sn2_smp.c
index 1176506..e884ba4 100644
--- a/arch/ia64/sn/kernel/sn2/sn2_smp.c
+++ b/arch/ia64/sn/kernel/sn2/sn2_smp.c
@@ -496,13 +496,13 @@ static int sn2_ptc_seq_show(struct seq_file *file, void *data)
 		seq_printf(file, "cpu %d %ld %ld %ld %ld %ld %ld %ld %ld %ld %ld %ld %ld\n", cpu, stat->ptc_l,
 				stat->change_rid, stat->shub_ptc_flushes, stat->nodes_flushed,
 				stat->deadlocks,
-				1000 * stat->lock_itc_clocks / per_cpu(cpu_info, cpu).cyc_per_usec,
-				1000 * stat->shub_itc_clocks / per_cpu(cpu_info, cpu).cyc_per_usec,
-				1000 * stat->shub_itc_clocks_max / per_cpu(cpu_info, cpu).cyc_per_usec,
+				1000 * stat->lock_itc_clocks / per_cpu(ia64_cpu_info, cpu).cyc_per_usec,
+				1000 * stat->shub_itc_clocks / per_cpu(ia64_cpu_info, cpu).cyc_per_usec,
+				1000 * stat->shub_itc_clocks_max / per_cpu(ia64_cpu_info, cpu).cyc_per_usec,
 				stat->shub_ptc_flushes_not_my_mm,
 				stat->deadlocks2,
 				stat->shub_ipi_flushes,
-				1000 * stat->shub_ipi_flushes_itc_clocks / per_cpu(cpu_info, cpu).cyc_per_usec);
+				1000 * stat->shub_ipi_flushes_itc_clocks / per_cpu(ia64_cpu_info, cpu).cyc_per_usec);
 	}
 	return 0;
 }
-- 
1.6.4.2

