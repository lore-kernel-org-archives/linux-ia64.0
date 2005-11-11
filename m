From: Ashok Raj <ashok.raj@intel.com>
Date: Fri, 11 Nov 2005 22:32:40 +0000
Subject: IA64 support for BSP removal
Message-Id: <20051111143240.A3653@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Tony

here is the BSP removal support for IA64. Its pretty much the same thing that
was released a while back, but has your feedback incorporated.

- Removed CONFIG_BSP_REMOVE_WORKAROUND and associated cmdline param
- Fixed compile issue with sn2/zx1 due to a undefined fix_b0_for_bsp
- some formatting nits (whitespace etc)

This has been tested on tiger and long back by alex on hp systems as well.

Nanhai also tested his kexec with this patch, so he doesnt need the 
taskset to switch to different cpu for execution.

Tony, please consider for inclusion..

-- 
Cheers,
Ashok Raj
- Open Source Technology Center
-----------------------------------------------------

Support to remove boot cpu, requires a different time master to be choosen if
this is time_keeper cpu. Adds 2 config options.

PERMIT_BSP_REMOVE, FORCE_CPEI_RETARGET 

New cmdline options.

force_cpei:
-----------
This cmdline option assumes that the override flag
is set, which is true for tiger platforms today.

Signed-off-by: Ashok Raj <ashok.raj@intel.com>
-------------------------------------------
 arch/ia64/Kconfig                 |   19 ++++++
 arch/ia64/configs/tiger_defconfig |    2 
 arch/ia64/kernel/acpi.c           |   12 ++--
 arch/ia64/kernel/iosapic.c        |    6 ++
 arch/ia64/kernel/irq.c            |   13 ++++
 arch/ia64/kernel/mca.c            |    6 +-
 arch/ia64/kernel/perfmon.c        |    5 +
 arch/ia64/kernel/smpboot.c        |  114 ++++++++++++++++++++++++++++++++++++--
 arch/ia64/kernel/time.c           |    9 ++-
 arch/ia64/mm/contig.c             |    4 +
 arch/ia64/mm/discontig.c          |    9 ++-
 include/asm-ia64/mca.h            |    2 
 12 files changed, 183 insertions(+), 18 deletions(-)

Index: linux-2.6.14-mm1/arch/ia64/Kconfig
=================================--- linux-2.6.14-mm1.orig/arch/ia64/Kconfig
+++ linux-2.6.14-mm1/arch/ia64/Kconfig
@@ -284,6 +284,25 @@ config SCHED_SMT
 	  Intel IA64 chips with MultiThreading at a cost of slightly increased
 	  overhead in some places. If unsure say N here.
 
+config PERMIT_BSP_REMOVE
+	bool "Support removal of Bootstrap Processor"
+	depends on HOTPLUG_CPU
+	default n
+	---help---
+	Say Y here if your platform SAL will support removal of BSP with HOTPLUG_CPU
+	support. 
+
+config FORCE_CPEI_RETARGET
+	bool "Force assumption that CPEI can be re-targetted"
+	depends on PERMIT_BSP_REMOVE
+	default n
+	---help---
+	Say Y if you need to force the assumption that CPEI can be re-targetted to
+	any cpu in the system. This hint is available via ACPI 3.0 specifications.
+	Tiger4 systems are capable of re-directing CPEI to any CPU other than BSP.
+	This option it useful to enable this feature on older BIOS's as well.
+	You can also enable this by using boot command line option force_cpei=1.
+
 config PREEMPT
 	bool "Preemptible Kernel"
         help
Index: linux-2.6.14-mm1/arch/ia64/kernel/irq.c
=================================--- linux-2.6.14-mm1.orig/arch/ia64/kernel/irq.c
+++ linux-2.6.14-mm1/arch/ia64/kernel/irq.c
@@ -163,8 +163,19 @@ void fixup_irqs(void)
 {
 	unsigned int irq;
 	extern void ia64_process_pending_intr(void);
+	extern void ia64_disable_timer(void);
+	extern volatile int time_keeper_id;
+
+	ia64_disable_timer();
+
+	/*
+	 * Find a new timesync master
+	 */
+	if (smp_processor_id() = time_keeper_id) {
+		time_keeper_id = first_cpu(cpu_online_map);
+		printk ("CPU %d is now promoted to time-keeper master\n", time_keeper_id);
+	}
 
-	ia64_set_itv(1<<16);
 	/*
 	 * Phase 1: Locate irq's bound to this cpu and
 	 * relocate them for cpu removal.
Index: linux-2.6.14-mm1/arch/ia64/kernel/smpboot.c
=================================--- linux-2.6.14-mm1.orig/arch/ia64/kernel/smpboot.c
+++ linux-2.6.14-mm1/arch/ia64/kernel/smpboot.c
@@ -70,6 +70,12 @@
 #endif
 
 #ifdef CONFIG_HOTPLUG_CPU
+#ifdef CONFIG_PERMIT_BSP_REMOVE
+#define bsp_remove_ok	1
+#else
+#define bsp_remove_ok	0
+#endif
+
 /*
  * Store all idle threads, this can be reused instead of creating
  * a new thread. Also avoids complicated thread destroy functionality
@@ -104,7 +110,7 @@ struct sal_to_os_boot *sal_state_for_boo
 /*
  * ITC synchronization related stuff:
  */
-#define MASTER	0
+#define MASTER	(0)
 #define SLAVE	(SMP_CACHE_BYTES/8)
 
 #define NUM_ROUNDS	64	/* magic value */
@@ -151,6 +157,27 @@ char __initdata no_int_routing;
 
 unsigned char smp_int_redirect; /* are INT and IPI redirectable by the chipset? */
 
+#ifdef CONFIG_FORCE_CPEI_RETARGET
+#define CPEI_OVERRIDE_DEFAULT	(1)
+#else
+#define CPEI_OVERRIDE_DEFAULT	(0)
+#endif
+
+unsigned int force_cpei_retarget = CPEI_OVERRIDE_DEFAULT;
+
+static int __init
+cmdl_force_cpei(char *str)
+{
+	int value=0;
+
+	get_option (&str, &value);
+	force_cpei_retarget = value;
+
+	return 1;
+}
+
+__setup("force_cpei=", cmdl_force_cpei);
+
 static int __init
 nointroute (char *str)
 {
@@ -161,6 +188,27 @@ nointroute (char *str)
 
 __setup("nointroute", nointroute);
 
+static void fix_b0_for_bsp(void)
+{
+#ifdef CONFIG_HOTPLUG_CPU
+	int cpuid;
+	static int fix_bsp_b0 = 1;
+
+	cpuid = smp_processor_id();
+
+	/*
+	 * Cache the b0 value on the first AP that comes up
+	 */
+	if (!(fix_bsp_b0 && cpuid))
+		return;
+
+	sal_boot_rendez_state[0].br[0] = sal_boot_rendez_state[cpuid].br[0];
+	printk ("Fixed BSP b0 value from CPU %d\n", cpuid);
+
+	fix_bsp_b0 = 0;
+#endif
+}
+
 void
 sync_master (void *arg)
 {
@@ -327,8 +375,9 @@ smp_setup_percpu_timer (void)
 static void __devinit
 smp_callin (void)
 {
-	int cpuid, phys_id;
+	int cpuid, phys_id, itc_master;
 	extern void ia64_init_itm(void);
+	extern volatile int time_keeper_id;
 
 #ifdef CONFIG_PERFMON
 	extern void pfm_init_percpu(void);
@@ -336,6 +385,7 @@ smp_callin (void)
 
 	cpuid = smp_processor_id();
 	phys_id = hard_smp_processor_id();
+	itc_master = time_keeper_id;
 
 	if (cpu_online(cpuid)) {
 		printk(KERN_ERR "huh, phys CPU#0x%x, CPU#0x%x already present??\n",
@@ -343,6 +393,8 @@ smp_callin (void)
 		BUG();
 	}
 
+	fix_b0_for_bsp();
+
 	lock_ipi_calllock();
 	cpu_set(cpuid, cpu_online_map);
 	unlock_ipi_calllock();
@@ -365,8 +417,8 @@ smp_callin (void)
 		 * calls spin_unlock_bh(), which calls spin_unlock_bh(), which calls
 		 * local_bh_enable(), which bugs out if irqs are not enabled...
 		 */
-		Dprintk("Going to syncup ITC with BP.\n");
-		ia64_sync_itc(0);
+		Dprintk("Going to syncup ITC with ITC Master.\n");
+		ia64_sync_itc(itc_master);
 	}
 
 	/*
@@ -637,6 +689,47 @@ remove_siblinginfo(int cpu)
 }
 
 extern void fixup_irqs(void);
+
+int migrate_platform_irqs(unsigned int cpu)
+{
+	int new_cpei_cpu;
+	irq_desc_t *desc = NULL;
+	cpumask_t 	mask;
+	int 		retval = 0;
+
+	/*
+	 * dont permit CPEI target to removed.
+	 */
+	if (cpe_vector > 0 && is_cpu_cpei_target(cpu)) {
+		printk ("CPU (%d) is CPEI Target\n", cpu);
+		if (can_cpei_retarget()) {
+			/*
+			 * Now re-target the CPEI to a different processor
+			 */
+			new_cpei_cpu = any_online_cpu(cpu_online_map);
+			mask = cpumask_of_cpu(new_cpei_cpu);
+			set_cpei_target_cpu(new_cpei_cpu);
+			desc = irq_descp(ia64_cpe_irq);
+			/*
+			 * Switch for now, immediatly, we need to do fake intr
+			 * as other interrupts, but need to study CPEI behaviour with
+			 * polling before making changes.
+			 */
+			if (desc) {
+				desc->handler->disable(ia64_cpe_irq);
+				desc->handler->set_affinity(ia64_cpe_irq, mask);
+				desc->handler->enable(ia64_cpe_irq);
+				printk ("Re-targetting CPEI to cpu %d\n", new_cpei_cpu);
+			}
+		}
+		if (!desc) {
+			printk ("Unable to retarget CPEI, offline cpu [%d] failed\n", cpu);
+			retval = -EBUSY;
+		}
+	}
+	return retval;
+}
+
 /* must be called with cpucontrol mutex held */
 int __cpu_disable(void)
 {
@@ -645,8 +738,17 @@ int __cpu_disable(void)
 	/*
 	 * dont permit boot processor for now
 	 */
-	if (cpu = 0)
-		return -EBUSY;
+	if (cpu = 0 && !bsp_remove_ok) {
+		printk ("Your platform does not support removal of BSP\n");
+		return (-EBUSY);
+	}
+
+	cpu_clear(cpu, cpu_online_map);
+
+	if (migrate_platform_irqs(cpu)) {
+		cpu_set(cpu, cpu_online_map);
+		return (-EBUSY);
+	}
 
 	remove_siblinginfo(cpu);
 	cpu_clear(cpu, cpu_online_map);
Index: linux-2.6.14-mm1/arch/ia64/kernel/time.c
=================================--- linux-2.6.14-mm1.orig/arch/ia64/kernel/time.c
+++ linux-2.6.14-mm1/arch/ia64/kernel/time.c
@@ -36,7 +36,7 @@ u64 jiffies_64 __cacheline_aligned_in_sm
 
 EXPORT_SYMBOL(jiffies_64);
 
-#define TIME_KEEPER_ID	0	/* smp_processor_id() of time-keeper */
+volatile int time_keeper_id = 0; /* smp_processor_id() of time-keeper */
 
 #ifdef CONFIG_IA64_DEBUG_IRQ
 
@@ -75,7 +75,7 @@ timer_interrupt (int irq, void *dev_id, 
 
 		new_itm += local_cpu_data->itm_delta;
 
-		if (smp_processor_id() = TIME_KEEPER_ID) {
+		if (smp_processor_id() = time_keeper_id) {
 			/*
 			 * Here we are in the timer irq handler. We have irqs locally
 			 * disabled, but we don't know if the timer_bh is running on
@@ -240,6 +240,11 @@ static struct irqaction timer_irqaction 
 	.name =		"timer"
 };
 
+void __devinit ia64_disable_timer(void)
+{
+	ia64_set_itv(1 << 16);
+}
+
 void __init
 time_init (void)
 {
Index: linux-2.6.14-mm1/arch/ia64/kernel/mca.c
=================================--- linux-2.6.14-mm1.orig/arch/ia64/kernel/mca.c
+++ linux-2.6.14-mm1/arch/ia64/kernel/mca.c
@@ -278,6 +278,7 @@ ia64_mca_log_sal_error_record(int sal_in
 #ifdef CONFIG_ACPI
 
 int cpe_vector = -1;
+int ia64_cpe_irq = -1;
 
 static irqreturn_t
 ia64_mca_cpe_int_handler (int cpe_irq, void *arg, struct pt_regs *ptregs)
@@ -1384,11 +1385,13 @@ void __devinit
 ia64_mca_cpu_init(void *cpu_data)
 {
 	void *pal_vaddr;
+	static int first_time = 1;
 
-	if (smp_processor_id() = 0) {
+	if (first_time) {
 		void *mca_data;
 		int cpu;
 
+		first_time = 0;
 		mca_data = alloc_bootmem(sizeof(struct ia64_mca_cpu)
 					 * NR_CPUS + KERNEL_STACK_SIZE);
 		mca_data = (void *)(((unsigned long)mca_data +
@@ -1636,6 +1639,7 @@ ia64_mca_late_init(void)
 					desc = irq_descp(irq);
 					desc->status |= IRQ_PER_CPU;
 					setup_irq(irq, &mca_cpe_irqaction);
+					ia64_cpe_irq = irq;
 				}
 			ia64_mca_register_cpev(cpe_vector);
 			IA64_MCA_DEBUG("%s: CPEI/P setup and enabled.\n", __FUNCTION__);
Index: linux-2.6.14-mm1/include/asm-ia64/mca.h
=================================--- linux-2.6.14-mm1.orig/include/asm-ia64/mca.h
+++ linux-2.6.14-mm1/include/asm-ia64/mca.h
@@ -131,6 +131,8 @@ struct ia64_mca_cpu {
 /* Array of physical addresses of each CPU's MCA area.  */
 extern unsigned long __per_cpu_mca[NR_CPUS];
 
+extern int cpe_vector;
+extern int ia64_cpe_irq;
 extern void ia64_mca_init(void);
 extern void ia64_mca_cpu_init(void *);
 extern void ia64_os_mca_dispatch(void);
Index: linux-2.6.14-mm1/arch/ia64/kernel/iosapic.c
=================================--- linux-2.6.14-mm1.orig/arch/ia64/kernel/iosapic.c
+++ linux-2.6.14-mm1/arch/ia64/kernel/iosapic.c
@@ -631,6 +631,7 @@ get_target_cpu (unsigned int gsi, int ve
 {
 #ifdef CONFIG_SMP
 	static int cpu = -1;
+	extern int cpe_vector;
 
 	/*
 	 * In case of vector shared by multiple RTEs, all RTEs that
@@ -653,6 +654,11 @@ get_target_cpu (unsigned int gsi, int ve
 	if (!cpu_online(smp_processor_id()))
 		return cpu_physical_id(smp_processor_id());
 
+#ifdef CONFIG_ACPI
+		if (cpe_vector > 0 && vector = IA64_CPEP_VECTOR)
+			return get_cpei_target_cpu();
+#endif
+
 #ifdef CONFIG_NUMA
 	{
 		int num_cpus, cpu_index, iosapic_index, numa_cpu, i = 0;
Index: linux-2.6.14-mm1/arch/ia64/kernel/acpi.c
=================================--- linux-2.6.14-mm1.orig/arch/ia64/kernel/acpi.c
+++ linux-2.6.14-mm1/arch/ia64/kernel/acpi.c
@@ -287,16 +287,20 @@ acpi_parse_plat_int_src(acpi_table_entry
 unsigned int can_cpei_retarget(void)
 {
 	extern int cpe_vector;
+	extern unsigned int force_cpei_retarget;
 
 	/*
 	 * Only if CPEI is supported and the override flag
 	 * is present, otherwise return that its re-targettable
 	 * if we are in polling mode.
 	 */
-	if (cpe_vector > 0 && !acpi_cpei_override)
-		return 0;
-	else
-		return 1;
+	if (cpe_vector > 0) {
+		if (acpi_cpei_override || force_cpei_retarget)
+			return 1;
+		else
+			return 0;
+	}
+	return 1;
 }
 
 unsigned int is_cpu_cpei_target(unsigned int cpu)
Index: linux-2.6.14-mm1/arch/ia64/mm/contig.c
=================================--- linux-2.6.14-mm1.orig/arch/ia64/mm/contig.c
+++ linux-2.6.14-mm1/arch/ia64/mm/contig.c
@@ -181,13 +181,15 @@ per_cpu_init (void)
 {
 	void *cpu_data;
 	int cpu;
+	static int first_time=1;
 
 	/*
 	 * get_free_pages() cannot be used before cpu_init() done.  BSP
 	 * allocates "NR_CPUS" pages for all CPUs to avoid that AP calls
 	 * get_zeroed_page().
 	 */
-	if (smp_processor_id() = 0) {
+	if (first_time) {
+		first_time=0;
 		cpu_data = __alloc_bootmem(PERCPU_PAGE_SIZE * NR_CPUS,
 					   PERCPU_PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
 		for (cpu = 0; cpu < NR_CPUS; cpu++) {
Index: linux-2.6.14-mm1/arch/ia64/mm/discontig.c
=================================--- linux-2.6.14-mm1.orig/arch/ia64/mm/discontig.c
+++ linux-2.6.14-mm1/arch/ia64/mm/discontig.c
@@ -496,12 +496,17 @@ void __init find_memory(void)
 void *per_cpu_init(void)
 {
 	int cpu;
+	static int first_time = 1;
+
 
 	if (smp_processor_id() != 0)
 		return __per_cpu_start + __per_cpu_offset[smp_processor_id()];
 
-	for (cpu = 0; cpu < NR_CPUS; cpu++)
-		per_cpu(local_per_cpu_offset, cpu) = __per_cpu_offset[cpu];
+	if (first_time) {
+		first_time = 0;
+		for (cpu = 0; cpu < NR_CPUS; cpu++)
+			per_cpu(local_per_cpu_offset, cpu) = __per_cpu_offset[cpu];
+	}
 
 	return __per_cpu_start + __per_cpu_offset[smp_processor_id()];
 }
Index: linux-2.6.14-mm1/arch/ia64/kernel/perfmon.c
=================================--- linux-2.6.14-mm1.orig/arch/ia64/kernel/perfmon.c
+++ linux-2.6.14-mm1/arch/ia64/kernel/perfmon.c
@@ -6717,6 +6717,7 @@ __initcall(pfm_init);
 void
 pfm_init_percpu (void)
 {
+	static int first_time=1;
 	/*
 	 * make sure no measurement is active
 	 * (may inherit programmed PMCs from EFI).
@@ -6729,8 +6730,10 @@ pfm_init_percpu (void)
 	 */
 	pfm_unfreeze_pmu();
 
-	if (smp_processor_id() = 0)
+	if (first_time) {
 		register_percpu_irq(IA64_PERFMON_VECTOR, &perfmon_irqaction);
+		first_time=0;
+	}
 
 	ia64_setreg(_IA64_REG_CR_PMV, IA64_PERFMON_VECTOR);
 	ia64_srlz_d();
Index: linux-2.6.14-mm1/arch/ia64/configs/tiger_defconfig
=================================--- linux-2.6.14-mm1.orig/arch/ia64/configs/tiger_defconfig
+++ linux-2.6.14-mm1/arch/ia64/configs/tiger_defconfig
@@ -95,6 +95,8 @@ CONFIG_FORCE_MAX_ZONEORDER
 CONFIG_SMP=y
 CONFIG_NR_CPUS=4
 CONFIG_HOTPLUG_CPU=y
+CONFIG_PERMIT_BSP_REMOVE=y
+CONFIG_FORCE_CPEI_RETARGET=y
 # CONFIG_SCHED_SMT is not set
 # CONFIG_PREEMPT is not set
 CONFIG_SELECT_MEMORY_MODEL=y
