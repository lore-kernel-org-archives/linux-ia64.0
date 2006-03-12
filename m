From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Sun, 12 Mar 2006 01:38:02 +0000
Subject: [patch] more __init declaration in setup.c
Message-Id: <200603120138.k2C1c0g23350@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

More __init and __devinit declaration for setup related functions.


Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>

--- ./arch/ia64/kernel/setup.c.orig	2006-03-11 17:47:21.491177127 -0800
+++ ./arch/ia64/kernel/setup.c	2006-03-11 17:57:22.897419760 -0800
@@ -358,7 +358,7 @@ mark_bsp_online (void)
 }
 
 #ifdef CONFIG_SMP
-static void
+static void __init
 check_for_logical_procs (void)
 {
 	pal_logical_to_physical_t info;
@@ -611,7 +611,7 @@ struct seq_operations cpuinfo_op = {
 	.show =		show_cpuinfo
 };
 
-void
+static void __devinit
 identify_cpu (struct cpuinfo_ia64 *c)
 {
 	union {
@@ -685,7 +685,7 @@ setup_per_cpu_areas (void)
  * In addition, the minimum of the i-cache stride sizes is calculated for
  * "flush_icache_range()".
  */
-static void
+static void __devinit
 get_max_cacheline_size (void)
 {
 	unsigned long line_size, max = 1;
@@ -742,7 +742,7 @@ get_max_cacheline_size (void)
  * cpu_init() initializes state that is per-CPU.  This function acts
  * as a 'CPU state barrier', nothing should get across.
  */
-void
+void __devinit
 cpu_init (void)
 {
 	extern void __devinit ia64_mmu_init (void *);
@@ -864,7 +864,7 @@ cpu_init (void)
 	pm_idle = default_idle;
 }
 
-void
+void __init
 check_bugs (void)
 {
 	ia64_patch_mckinley_e9((unsigned long) __start___mckinley_e9_bundles,

