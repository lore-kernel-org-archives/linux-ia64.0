From: Ashok Raj <ashok.raj@intel.com>
Date: Wed, 28 Apr 2004 01:01:33 +0000
Subject: Updated CPU hotplug patches for IA64 [Patch 2/7]
Message-Id: <20040427180132.C29377@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040427180033.B29377@unix-os.sc.intel.com>
In-Reply-To: <20040427180033.B29377@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



Name: ia64_init_removal.patch
Author: Ashok Raj (Intel Corporation)
Status: Experimental

D: Contains changes from __init to __devinit to support cpu hotplug
D: Changes only arch/ia64 portions of the kernel tree.


---

 linux-2.6.5-lhcs-root/arch/ia64/kernel/setup.c   |    2 +-
 linux-2.6.5-lhcs-root/arch/ia64/kernel/smpboot.c |   12 ++++++------
 linux-2.6.5-lhcs-root/arch/ia64/kernel/time.c    |    2 +-
 linux-2.6.5-lhcs-root/arch/ia64/mm/init.c        |    4 ++--
 linux-2.6.5-lhcs-root/arch/ia64/mm/tlb.c         |    2 +-
 linux-2.6.5-lhcs-root/include/asm-ia64/smp.h     |    3 ++-
 6 files changed, 13 insertions(+), 12 deletions(-)

diff -puN arch/ia64/kernel/setup.c~init_removal_ia64 arch/ia64/kernel/setup.c
--- linux-2.6.5-lhcs/arch/ia64/kernel/setup.c~init_removal_ia64	2004-04-26 22:15:29.923885511 -0700
+++ linux-2.6.5-lhcs-root/arch/ia64/kernel/setup.c	2004-04-26 22:15:29.932674578 -0700
@@ -575,7 +575,7 @@ get_max_cacheline_size (void)
 void
 cpu_init (void)
 {
-	extern void __init ia64_mmu_init (void *);
+	extern void __devinit ia64_mmu_init (void *);
 	unsigned long num_phys_stacked;
 	pal_vm_info_2_u_t vmi;
 	unsigned int max_ctx;
diff -puN arch/ia64/kernel/smpboot.c~init_removal_ia64 arch/ia64/kernel/smpboot.c
--- linux-2.6.5-lhcs/arch/ia64/kernel/smpboot.c~init_removal_ia64	2004-04-26 22:15:29.925838637 -0700
+++ linux-2.6.5-lhcs-root/arch/ia64/kernel/smpboot.c	2004-04-26 22:15:29.933651141 -0700
@@ -69,7 +69,7 @@ static volatile unsigned long go[SLAVE +
 
 #define DEBUG_ITC_SYNC	0
 
-extern void __init calibrate_delay (void);
+extern void __devinit calibrate_delay (void);
 extern void start_ap (void);
 extern unsigned long ia64_iobase;
 
@@ -262,12 +262,12 @@ ia64_sync_itc (unsigned int master)
 /*
  * Ideally sets up per-cpu profiling hooks.  Doesn't do much now...
  */
-static inline void __init
+static inline void __devinit
 smp_setup_percpu_timer (void)
 {
 }
 
-static void __init
+static void __devinit
 smp_callin (void)
 {
 	int cpuid, phys_id;
@@ -333,7 +333,7 @@ smp_callin (void)
 /*
  * Activate a secondary processor.  head.S calls this.
  */
-int __init
+int __devinit
 start_secondary (void *unused)
 {
 	extern int cpu_idle (void);
@@ -346,7 +346,7 @@ start_secondary (void *unused)
 	return cpu_idle();
 }
 
-static struct task_struct * __init
+static struct task_struct * __devinit
 fork_by_hand (void)
 {
 	/*
@@ -356,7 +356,7 @@ fork_by_hand (void)
 	return copy_process(CLONE_VM|CLONE_IDLETASK, 0, 0, 0, NULL, NULL);
 }
 
-static int __init
+static int __devinit
 do_boot_cpu (int sapicid, int cpu)
 {
 	struct task_struct *idle;
diff -puN arch/ia64/kernel/time.c~init_removal_ia64 arch/ia64/kernel/time.c
--- linux-2.6.5-lhcs/arch/ia64/kernel/time.c~init_removal_ia64	2004-04-26 22:15:29.926815200 -0700
+++ linux-2.6.5-lhcs-root/arch/ia64/kernel/time.c	2004-04-26 22:15:29.933651141 -0700
@@ -326,7 +326,7 @@ ia64_cpu_local_tick (void)
 	ia64_set_itm(local_cpu_data->itm_next);
 }
 
-void __init
+void __devinit
 ia64_init_itm (void)
 {
 	unsigned long platform_base_freq, itc_freq;
diff -puN arch/ia64/mm/init.c~init_removal_ia64 arch/ia64/mm/init.c
--- linux-2.6.5-lhcs/arch/ia64/mm/init.c~init_removal_ia64	2004-04-26 22:15:29.928768326 -0700
+++ linux-2.6.5-lhcs-root/arch/ia64/mm/init.c	2004-04-26 22:15:29.933651141 -0700
@@ -274,11 +274,11 @@ setup_gate (void)
 	ia64_patch_gate();
 }
 
-void __init
+void __devinit
 ia64_mmu_init (void *my_cpu_data)
 {
 	unsigned long psr, pta, impl_va_bits;
-	extern void __init tlb_init (void);
+	extern void __devinit tlb_init (void);
 	int cpu;
 
 #ifdef CONFIG_DISABLE_VHPT
diff -puN arch/ia64/mm/tlb.c~init_removal_ia64 arch/ia64/mm/tlb.c
--- linux-2.6.5-lhcs/arch/ia64/mm/tlb.c~init_removal_ia64	2004-04-26 22:15:29.929744889 -0700
+++ linux-2.6.5-lhcs-root/arch/ia64/mm/tlb.c	2004-04-26 22:15:29.934627704 -0700
@@ -166,7 +166,7 @@ flush_tlb_range (struct vm_area_struct *
 }
 EXPORT_SYMBOL(flush_tlb_range);
 
-void __init
+void __devinit
 ia64_tlb_init (void)
 {
 	ia64_ptce_info_t ptce_info;
diff -puN include/asm-ia64/smp.h~init_removal_ia64 include/asm-ia64/smp.h
--- linux-2.6.5-lhcs/include/asm-ia64/smp.h~init_removal_ia64	2004-04-26 22:15:29.930721452 -0700
+++ linux-2.6.5-lhcs-root/include/asm-ia64/smp.h	2004-04-26 22:15:29.934627704 -0700
@@ -36,7 +36,7 @@ extern struct smp_boot_data {
 	int cpu_phys_id[NR_CPUS];
 } smp_boot_data __initdata;
 
-extern char no_int_routing __initdata;
+extern char no_int_routing __devinitdata;
 
 extern cpumask_t phys_cpu_present_map;
 extern cpumask_t cpu_online_map;
@@ -113,6 +113,7 @@ hard_smp_processor_id (void)
 /* Upping and downing of CPUs */
 extern int __cpu_disable (void);
 extern void __cpu_die (unsigned int cpu);
+extern void cpu_die (void) __attribute__ ((noreturn));
 extern int __cpu_up (unsigned int cpu);
 extern void __init smp_build_cpu_map(void);
 

_
