From: Ashok Raj <ashok.raj@intel.com>
Date: Sat, 12 Feb 2005 15:14:17 +0000
Subject: CPU Hotplug - Support for BSP removal
Message-Id: <20050212071417.B26140@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi

This patch requires the cpei retarget patch posted earlier. 

CAVEAT: tiger4 BIOS does not have the right value for branch reg0 when handed
off to OS. I observed i could handoff the BSP to SAL, but due to incorrect jump
address in b0, it ends up in some while (1); loop later. So we cannot send 
another IPI to wakeup the bsp. The system seemed to run fine with rest of
the processors.

I had the luxury of using ITP, and manually fixed the b0 reg to be like what 
other AP's had. Seems like rest of the values are ok. With this one time fix
to b0, i was able to bring the BSP up/down. Future cpu_down had correct b0
values and worked fine.

- To test, please set PERMIT_BSP_REMOVAL via xconfig.
- force_cpei=1 boot option when booting. Only if CPEI can be received by
any cpu other than one marked in via acpi the platform interrupt source.  

You can also set the fore_cpei permanently via the xconfig option 
FORCE_CPEI_REMOVAL.

I havent done much with the cpep stuff.

Cheers,
ashok

---

Signed-off-by: Ashok Raj <ashok.raj@intel.com>

Depends on : cpei_override.patch

Support to remove boot cpu, requires a different time master to be choosen if
this is time_keeper cpu. Adds 2 config options.

PERMIT_BSP_REMOVE
	If your platform supports this, or you need to test, enable this 
	parameter in config. This is turned on automatically if you choose 
	tiger_defconfig

FORCE_CPEI_RETARGET
	ACPI 3.0 gives the flexibility to provide a hint that CPEI can be 
	re-targetted.  Most tiger systems the ability to re-target CPEI is 
	valid even for today's systems. You can enable this config option 
	to make force this assumption if this is true for your platform. 
	This option is automatically turned on for tiget_defconfig.
---
---

 release_work-araj/arch/ia64/Kconfig          |   23 ++++++
 release_work-araj/arch/ia64/kernel/acpi.c    |    4 -
 release_work-araj/arch/ia64/kernel/iosapic.c |    6 +
 release_work-araj/arch/ia64/kernel/irq.c     |   13 +++
 release_work-araj/arch/ia64/kernel/mca.c     |    8 +-
 release_work-araj/arch/ia64/kernel/perfmon.c |    5 +
 release_work-araj/arch/ia64/kernel/smpboot.c |   92 +++++++++++++++++++++++++--
 release_work-araj/arch/ia64/kernel/time.c    |    9 ++
 release_work-araj/arch/ia64/mm/contig.c      |    4 -
 release_work-araj/arch/ia64/mm/discontig.c   |    4 -
 release_work-araj/include/asm-ia64/mca.h     |    2 
 11 files changed, 155 insertions(+), 15 deletions(-)

diff -puN arch/ia64/Kconfig~ia64_bsp_remove arch/ia64/Kconfig
--- release_work/arch/ia64/Kconfig~ia64_bsp_remove	2005-02-11 14:19:39.000000000 -0800
+++ release_work-araj/arch/ia64/Kconfig	2005-02-11 14:19:39.000000000 -0800
@@ -260,6 +260,29 @@ config HOTPLUG_CPU
 	  can be controlled through /sys/devices/system/cpu/cpu#.
 	  Say N if you want to disable CPU hotplug.
 
+config PERMIT_BSP_REMOVE
+	bool "Support removal of Bootstrap Processor"
+	depends on HOTPLUG_CPU
+	default n
+	---help---
+	Say Y here if your platform SAL will support removal of BSP with HOTPLUG_CPU
+	support. Many of today's BIOS's still seem to be buggy and dont handle
+	BSP removal correctly when handed off from OS using mechanism's described
+	in SAL specification Section 3.2.5 OS_BOOT_RENDEZ. It appears to work fine
+	for Application processors. On tiger-4, you can remove BSP using this
+	option, but cannot bring it back up like other AP's.
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
diff -puN arch/ia64/kernel/irq.c~ia64_bsp_remove arch/ia64/kernel/irq.c
--- release_work/arch/ia64/kernel/irq.c~ia64_bsp_remove	2005-02-11 14:19:39.000000000 -0800
+++ release_work-araj/arch/ia64/kernel/irq.c	2005-02-11 14:19:39.000000000 -0800
@@ -191,8 +191,19 @@ void fixup_irqs(void)
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
diff -puN arch/ia64/kernel/smpboot.c~ia64_bsp_remove arch/ia64/kernel/smpboot.c
--- release_work/arch/ia64/kernel/smpboot.c~ia64_bsp_remove	2005-02-11 14:19:39.000000000 -0800
+++ release_work-araj/arch/ia64/kernel/smpboot.c	2005-02-11 14:19:39.000000000 -0800
@@ -60,6 +60,12 @@
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
@@ -94,7 +100,7 @@ struct sal_to_os_boot *sal_state_for_boo
 /*
  * ITC synchronization related stuff:
  */
-#define MASTER	0
+#define MASTER	(0)
 #define SLAVE	(SMP_CACHE_BYTES/8)
 
 #define NUM_ROUNDS	64	/* magic value */
@@ -136,6 +142,28 @@ char __initdata no_int_routing;
 
 unsigned char smp_int_redirect; /* are INT and IPI redirectable by the chipset? */
 
+
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
@@ -309,8 +337,9 @@ smp_setup_percpu_timer (void)
 static void __devinit
 smp_callin (void)
 {
-	int cpuid, phys_id;
+	int cpuid, phys_id, itc_master;
 	extern void ia64_init_itm(void);
+	extern volatile int time_keeper_id;
 
 #ifdef CONFIG_PERFMON
 	extern void pfm_init_percpu(void);
@@ -318,6 +347,7 @@ smp_callin (void)
 
 	cpuid = smp_processor_id();
 	phys_id = hard_smp_processor_id();
+	itc_master = time_keeper_id;
 
 	if (cpu_online(cpuid)) {
 		printk(KERN_ERR "huh, phys CPU#0x%x, CPU#0x%x already present??\n",
@@ -346,8 +376,8 @@ smp_callin (void)
 		 * calls spin_unlock_bh(), which calls spin_unlock_bh(), which calls
 		 * local_bh_enable(), which bugs out if irqs are not enabled...
 		 */
-		Dprintk("Going to syncup ITC with BP.\n");
-		ia64_sync_itc(0);
+		Dprintk("Going to syncup ITC with ITC Master.\n");
+		ia64_sync_itc(itc_master);
 	}
 
 	/*
@@ -612,6 +642,47 @@ void __devinit smp_prepare_boot_cpu(void
 
 #ifdef CONFIG_HOTPLUG_CPU
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
@@ -620,8 +691,17 @@ int __cpu_disable(void)
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
 
 	fixup_irqs();
 	local_flush_tlb_all();
diff -puN arch/ia64/kernel/time.c~ia64_bsp_remove arch/ia64/kernel/time.c
--- release_work/arch/ia64/kernel/time.c~ia64_bsp_remove	2005-02-11 14:19:39.000000000 -0800
+++ release_work-araj/arch/ia64/kernel/time.c	2005-02-11 14:19:39.000000000 -0800
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
diff -puN arch/ia64/kernel/mca.c~ia64_bsp_remove arch/ia64/kernel/mca.c
--- release_work/arch/ia64/kernel/mca.c~ia64_bsp_remove	2005-02-11 14:19:39.000000000 -0800
+++ release_work-araj/arch/ia64/kernel/mca.c	2005-02-12 06:13:04.482743077 -0800
@@ -271,7 +271,8 @@ ia64_mca_log_sal_error_record(int sal_in
 
 #ifdef CONFIG_ACPI
 
-static int cpe_vector = -1;
+int cpe_vector = -1;
+int ia64_cpe_irq = -1;
 
 static irqreturn_t
 ia64_mca_cpe_int_handler (int cpe_irq, void *arg, struct pt_regs *ptregs)
@@ -1208,11 +1209,13 @@ void __devinit
 ia64_mca_cpu_init(void *cpu_data)
 {
 	void *pal_vaddr;
+	static int first_time=1;
 
-	if (smp_processor_id() = 0) {
+	if (first_time) {
 		void *mca_data;
 		int cpu;
 
+		first_time=0;
 		mca_data = alloc_bootmem(sizeof(struct ia64_mca_cpu)
 					 * NR_CPUS);
 		for (cpu = 0; cpu < NR_CPUS; cpu++) {
@@ -1451,6 +1454,7 @@ ia64_mca_late_init(void)
 					desc = irq_descp(irq);
 					desc->status |= IRQ_PER_CPU;
 					setup_irq(irq, &mca_cpe_irqaction);
+					ia64_cpe_irq = irq;
 				}
 			ia64_mca_register_cpev(cpe_vector);
 			IA64_MCA_DEBUG("%s: CPEI/P setup and enabled.\n", __FUNCTION__);
diff -puN include/asm-ia64/mca.h~ia64_bsp_remove include/asm-ia64/mca.h
--- release_work/include/asm-ia64/mca.h~ia64_bsp_remove	2005-02-11 14:19:39.000000000 -0800
+++ release_work-araj/include/asm-ia64/mca.h	2005-02-11 14:19:39.000000000 -0800
@@ -117,6 +117,8 @@ struct ia64_mca_cpu {
 /* Array of physical addresses of each CPU's MCA area.  */
 extern unsigned long __per_cpu_mca[NR_CPUS];
 
+extern int cpe_vector;
+extern int ia64_cpe_irq;
 extern void ia64_mca_init(void);
 extern void ia64_mca_cpu_init(void *);
 extern void ia64_os_mca_dispatch(void);
diff -puN arch/ia64/kernel/iosapic.c~ia64_bsp_remove arch/ia64/kernel/iosapic.c
--- release_work/arch/ia64/kernel/iosapic.c~ia64_bsp_remove	2005-02-11 14:19:39.000000000 -0800
+++ release_work-araj/arch/ia64/kernel/iosapic.c	2005-02-11 14:19:39.000000000 -0800
@@ -493,6 +493,7 @@ get_target_cpu (unsigned int gsi, int ve
 {
 #ifdef CONFIG_SMP
 	static int cpu = -1;
+	extern int cpe_vector;
 
 	/*
 	 * If the platform supports redirection via XTP, let it
@@ -508,6 +509,11 @@ get_target_cpu (unsigned int gsi, int ve
 	if (!cpu_online(smp_processor_id()))
 		return hard_smp_processor_id();
 
+#ifdef CONFIG_ACPI
+		if (cpe_vector > 0 && vector = IA64_CPEP_VECTOR)
+			return get_cpei_target_cpu();
+#endif
+
 #ifdef CONFIG_NUMA
 	{
 		int num_cpus, cpu_index, iosapic_index, numa_cpu, i = 0;
diff -puN arch/ia64/kernel/acpi.c~ia64_bsp_remove arch/ia64/kernel/acpi.c
--- release_work/arch/ia64/kernel/acpi.c~ia64_bsp_remove	2005-02-11 14:19:39.000000000 -0800
+++ release_work-araj/arch/ia64/kernel/acpi.c	2005-02-11 14:19:39.000000000 -0800
@@ -288,7 +288,9 @@ acpi_parse_plat_int_src (
 
 unsigned int can_cpei_retarget(void)
 {
-	return (1 ? (acpi_cpei_override) : 0);
+	extern unsigned int force_cpei_retarget;
+
+	return (1 ? (acpi_cpei_override || force_cpei_retarget) : 0);
 }
 
 unsigned int is_cpu_cpei_target(unsigned int cpu)
diff -puN arch/ia64/mm/contig.c~ia64_bsp_remove arch/ia64/mm/contig.c
--- release_work/arch/ia64/mm/contig.c~ia64_bsp_remove	2005-02-12 06:10:46.123369772 -0800
+++ release_work-araj/arch/ia64/mm/contig.c	2005-02-12 06:12:47.047196416 -0800
@@ -180,13 +180,15 @@ per_cpu_init (void)
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
diff -puN arch/ia64/mm/discontig.c~ia64_bsp_remove arch/ia64/mm/discontig.c
--- release_work/arch/ia64/mm/discontig.c~ia64_bsp_remove	2005-02-12 06:11:52.179033026 -0800
+++ release_work-araj/arch/ia64/mm/discontig.c	2005-02-12 06:12:30.515946619 -0800
@@ -528,8 +528,10 @@ void __init find_memory(void)
 void *per_cpu_init(void)
 {
 	int cpu;
+	static int first_time=1;
 
-	if (smp_processor_id() = 0) {
+	if (first_time) {
+		first_time=0;
 		for (cpu = 0; cpu < NR_CPUS; cpu++) {
 			per_cpu(local_per_cpu_offset, cpu)  				__per_cpu_offset[cpu];
diff -puN arch/ia64/kernel/perfmon.c~ia64_bsp_remove arch/ia64/kernel/perfmon.c
--- release_work/arch/ia64/kernel/perfmon.c~ia64_bsp_remove	2005-02-12 06:15:14.771803981 -0800
+++ release_work-araj/arch/ia64/kernel/perfmon.c	2005-02-12 06:15:59.182936250 -0800
@@ -6548,6 +6548,7 @@ __initcall(pfm_init);
 void
 pfm_init_percpu (void)
 {
+	static int first_time=1;
 	/*
 	 * make sure no measurement is active
 	 * (may inherit programmed PMCs from EFI).
@@ -6560,8 +6561,10 @@ pfm_init_percpu (void)
 	 */
 	pfm_unfreeze_pmu();
 
-	if (smp_processor_id() = 0)
+	if (first_time) {
 		register_percpu_irq(IA64_PERFMON_VECTOR, &perfmon_irqaction);
+		first_time=0;
+	}
 
 	ia64_setreg(_IA64_REG_CR_PMV, IA64_PERFMON_VECTOR);
 	ia64_srlz_d();
_
