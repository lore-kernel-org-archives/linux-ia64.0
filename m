From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Sun, 12 Mar 2006 17:00:13 +0000
Subject: [patch 2/6] add init declaration to cpu initialization functions
Message-Id: <200603121700.k2CH0Bg10078@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Add init declaration to cpu initialization functions.


Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>

--- ./arch/ia64/kernel/setup.c.orig	2006-03-12 01:23:18.000000000 -0800
+++ ./arch/ia64/kernel/setup.c	2006-03-12 09:02:44.095973075 -0800
@@ -362,7 +362,7 @@ mark_bsp_online (void)
 }
 
 #ifdef CONFIG_SMP
-static void
+static void __init
 check_for_logical_procs (void)
 {
 	pal_logical_to_physical_t info;
@@ -623,7 +623,7 @@ struct seq_operations cpuinfo_op = {
 	.show =		show_cpuinfo
 };
 
-void
+static void __cpuinit
 identify_cpu (struct cpuinfo_ia64 *c)
 {
 	union {
@@ -700,7 +700,7 @@ setup_per_cpu_areas (void)
  * In addition, the minimum of the i-cache stride sizes is calculated for
  * "flush_icache_range()".
  */
-static void
+static void __cpuinit
 get_max_cacheline_size (void)
 {
 	unsigned long line_size, max = 1;
@@ -763,10 +763,10 @@ get_max_cacheline_size (void)
  * cpu_init() initializes state that is per-CPU.  This function acts
  * as a 'CPU state barrier', nothing should get across.
  */
-void
+void __cpuinit
 cpu_init (void)
 {
-	extern void __devinit ia64_mmu_init (void *);
+	extern void __cpuinit ia64_mmu_init (void *);
 	unsigned long num_phys_stacked;
 	pal_vm_info_2_u_t vmi;
 	unsigned int max_ctx;
@@ -894,7 +894,7 @@ void sched_cacheflush(void)
 	ia64_sal_cache_flush(3);
 }
 
-void
+void __init
 check_bugs (void)
 {
 	ia64_patch_mckinley_e9((unsigned long) __start___mckinley_e9_bundles,
--- ./arch/ia64/mm/contig.c.orig	2006-01-02 19:21:10.000000000 -0800
+++ ./arch/ia64/mm/contig.c	2006-03-12 09:02:33.840113826 -0800
@@ -176,7 +176,7 @@ find_memory (void)
  *
  * Allocate and setup per-cpu data areas.
  */
-void *
+void * __cpuinit
 per_cpu_init (void)
 {
 	void *cpu_data;
--- ./arch/ia64/mm/discontig.c.orig	2006-01-02 19:21:10.000000000 -0800
+++ ./arch/ia64/mm/discontig.c	2006-03-12 09:02:33.841090388 -0800
@@ -525,7 +525,7 @@ void __init find_memory(void)
  * find_pernode_space() does most of this already, we just need to set
  * local_per_cpu_offset
  */
-void *per_cpu_init(void)
+void __cpuinit *per_cpu_init(void)
 {
 	int cpu;
 
--- ./include/asm-ia64/processor.h.orig	2006-03-12 01:23:21.000000000 -0800
+++ ./include/asm-ia64/processor.h	2006-03-12 09:02:33.841090388 -0800
@@ -180,7 +180,6 @@ DECLARE_PER_CPU(struct cpuinfo_ia64, cpu
 #define local_cpu_data		(&__ia64_per_cpu_var(cpu_info))
 #define cpu_data(cpu)		(&per_cpu(cpu_info, cpu))
 
-extern void identify_cpu (struct cpuinfo_ia64 *);
 extern void print_cpu_info (struct cpuinfo_ia64 *);
 
 typedef struct {

