From: Ashok Raj <ashok.raj@intel.com>
Date: Wed, 28 Apr 2004 01:08:04 +0000
Subject: Updated CPU hotplug patches for IA64 [Patch 7/7]
Message-Id: <20040427180804.H29377@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040427180033.B29377@unix-os.sc.intel.com>
In-Reply-To: <20040427180033.B29377@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



Name: cpu_present_map.patch
Author: Ashok Raj (Intel Corporation)
D: This patch adds cpu_present_map, cpu_present() and for_each_cpu_present()
D: to distinguish between possible cpu's in a system and cpu's physically
D: present in a system. Before cpu hotplug was introduced cpu_possible()
D: represented cpu's physically present in the system. With hotplug capable
D: Kernel, there is a requirement to distinguish a cpu as possible verses a 
D: CPU physically present in the system. This is required so thta when
D: smp_init() attempts to start all cpu's it should now only attempt
D: to start cpu's present in the system. When a hotplug cpu is
D: physically inserted cpu_present_map will have bits updated
D: dynamically.


---

 arch/ia64/kernel/smp.c                           |    0 
 linux-2.6.5-lhcs-root/arch/ia64/kernel/smpboot.c |   21 +++++++++++++++++++--
 linux-2.6.5-lhcs-root/fs/proc/proc_misc.c        |    4 ++--
 linux-2.6.5-lhcs-root/include/asm-ia64/cpumask.h |    1 +
 linux-2.6.5-lhcs-root/include/asm-ia64/smp.h     |    5 +++++
 linux-2.6.5-lhcs-root/include/linux/cpumask.h    |   16 ++++++++++++++++
 linux-2.6.5-lhcs-root/init/main.c                |    2 +-
 linux-2.6.5-lhcs-root/kernel/cpu.c               |    2 +-
 8 files changed, 45 insertions(+), 6 deletions(-)

diff -puN include/asm-ia64/smp.h~cpu_present include/asm-ia64/smp.h
--- linux-2.6.5-lhcs/include/asm-ia64/smp.h~cpu_present	2004-04-27 17:43:43.994567168 -0700
+++ linux-2.6.5-lhcs-root/include/asm-ia64/smp.h	2004-04-27 17:43:44.006285924 -0700
@@ -48,7 +48,12 @@ extern volatile int ia64_cpu_to_sapicid[
 
 extern unsigned long ap_wakeup_vector;
 
+#ifdef CONFIG_HOTPLUG_CPU
+extern cpumask_t cpu_possible_map;
+#define cpu_present_map phys_cpu_present_map
+#else
 #define cpu_possible_map phys_cpu_present_map
+#endif
 
 /*
  * Function to map hard smp processor id to logical id.  Slow, so don't use this in
diff -puN arch/ia64/kernel/smpboot.c~cpu_present arch/ia64/kernel/smpboot.c
--- linux-2.6.5-lhcs/arch/ia64/kernel/smpboot.c~cpu_present	2004-04-27 17:43:43.995543731 -0700
+++ linux-2.6.5-lhcs-root/arch/ia64/kernel/smpboot.c	2004-04-27 17:43:44.007262487 -0700
@@ -87,9 +87,15 @@ DEFINE_PER_CPU(int, cpu_state);
 /* Bitmask of currently online CPUs */
 cpumask_t cpu_online_map;
 EXPORT_SYMBOL(cpu_online_map);
+
 cpumask_t phys_cpu_present_map;
 EXPORT_SYMBOL(phys_cpu_present_map);
 
+#ifdef CONFIG_HOTPLUG_CPU
+cpumask_t cpu_possible_map;
+EXPORT_SYMBOL(cpu_possible_map);
+#endif
+
 /* which logical CPU number maps to which CPU (physical APIC ID) */
 volatile int ia64_cpu_to_sapicid[NR_CPUS];
 EXPORT_SYMBOL(ia64_cpu_to_sapicid);
@@ -108,6 +114,7 @@ static int __init
 nointroute (char *str)
 {
 	no_int_routing = 1;
+	printk ("no_int_routing on\n");
 	return 1;
 }
 
@@ -472,13 +479,23 @@ smp_build_cpu_map (void)
 	int sapicid, cpu, i;
 	int boot_cpu_id = hard_smp_processor_id();
 
-	for (cpu = 0; cpu < NR_CPUS; cpu++)
+	/*
+	 * Since ACPI does not give us whats MAX cpu's
+	 * possible in the entire platform, we will just have to use
+	 * NR_CPUS set for possible map. cpu_present_map a.k.a
+	 * phys_cpu_present_map can grow based on a new cpu
+	 * becomming available to the system.
+	 */
+	cpus_clear(cpu_possible_map);
+	for (cpu=0; cpu < NR_CPUS; cpu++) {
 		ia64_cpu_to_sapicid[cpu] = -1;
+		cpu_set(cpu, cpu_possible_map);
+	}
 
 	ia64_cpu_to_sapicid[0] = boot_cpu_id;
+
 	cpus_clear(phys_cpu_present_map);
 	cpu_set(0, phys_cpu_present_map);
-
 	for (cpu = 1, i = 0; i < smp_boot_data.cpu_count; i++) {
 		sapicid = smp_boot_data.cpu_phys_id[i];
 		if (sapicid = boot_cpu_id)
diff -puN include/linux/cpumask.h~cpu_present include/linux/cpumask.h
--- linux-2.6.5-lhcs/include/linux/cpumask.h~cpu_present	2004-04-27 17:43:43.997496857 -0700
+++ linux-2.6.5-lhcs-root/include/linux/cpumask.h	2004-04-27 17:43:44.007262487 -0700
@@ -16,6 +16,16 @@ extern cpumask_t cpu_possible_map;
 #define cpu_online(cpu)			cpu_isset(cpu, cpu_online_map)
 #define cpu_possible(cpu)		cpu_isset(cpu, cpu_possible_map)
 
+#ifdef ARCH_HAS_CPU_PRESENT_MAP
+extern cpumask_t cpu_present_map;
+#define cpu_present(cpu)		cpu_isset(cpu, cpu_present_map)
+#define num_present_cpus()		cpus_weight(cpu_present_map)
+#else
+#define cpu_present_map			cpu_possible_map
+#define cpu_present(x)			cpu_possible(x)
+#define num_present_cpus()		num_possible_cpus()
+#endif
+
 #define for_each_cpu_mask(cpu, mask)					\
 	for (cpu = first_cpu_const(mk_cpumask_const(mask));		\
 		cpu < NR_CPUS;						\
@@ -23,13 +33,19 @@ extern cpumask_t cpu_possible_map;
 
 #define for_each_cpu(cpu) for_each_cpu_mask(cpu, cpu_possible_map)
 #define for_each_online_cpu(cpu) for_each_cpu_mask(cpu, cpu_online_map)
+#define for_each_present_cpu(cpu) for_each_cpu_mask(cpu, cpu_present_map)
 #else
 #define	cpu_online_map			cpumask_of_cpu(0)
 #define	cpu_possible_map		cpumask_of_cpu(0)
+#define cpu_present_map			cpumask_of_cpu(0)
+
 #define num_online_cpus()		1
 #define num_possible_cpus()		1
+#define num_present_cpus		1
+
 #define cpu_online(cpu)			({ BUG_ON((cpu) != 0); 1; })
 #define cpu_possible(cpu)		({ BUG_ON((cpu) != 0); 1; })
+#define cpu_present(cpu)		({ BUG_ON((cpu) != 0); 1; })
 
 #define for_each_cpu(cpu) for (cpu = 0; cpu < 1; cpu++)
 #define for_each_online_cpu(cpu) for (cpu = 0; cpu < 1; cpu++)
diff -puN init/main.c~cpu_present init/main.c
--- linux-2.6.5-lhcs/init/main.c~cpu_present	2004-04-27 17:43:43.999449983 -0700
+++ linux-2.6.5-lhcs-root/init/main.c	2004-04-27 17:43:44.007262487 -0700
@@ -360,7 +360,7 @@ static void __init smp_init(void)
 	for (i = 0; i < NR_CPUS; i++) {
 		if (num_online_cpus() >= max_cpus)
 			break;
-		if (cpu_possible(i) && !cpu_online(i)) {
+		if (cpu_possible(i) && !cpu_online(i) && cpu_present(i)) {
 			cpu_up(i);
 			j++;
 		}
diff -puN kernel/cpu.c~cpu_present kernel/cpu.c
--- linux-2.6.5-lhcs/kernel/cpu.c~cpu_present	2004-04-27 17:43:44.000426546 -0700
+++ linux-2.6.5-lhcs-root/kernel/cpu.c	2004-04-27 17:43:44.008239050 -0700
@@ -169,7 +169,7 @@ int __devinit cpu_up(unsigned int cpu)
 	if ((ret = down_interruptible(&cpucontrol)) != 0)
 		return ret;
 
-	if (cpu_online(cpu)) {
+	if (cpu_online(cpu) || !cpu_present(cpu)) {
 		ret = -EINVAL;
 		goto out;
 	}
diff -puN arch/ia64/kernel/smp.c~cpu_present arch/ia64/kernel/smp.c
diff -puN fs/proc/proc_misc.c~cpu_present fs/proc/proc_misc.c
--- linux-2.6.5-lhcs/fs/proc/proc_misc.c~cpu_present	2004-04-27 17:43:44.003356235 -0700
+++ linux-2.6.5-lhcs-root/fs/proc/proc_misc.c	2004-04-27 17:43:44.008239050 -0700
@@ -368,7 +368,7 @@ int show_stat(struct seq_file *p, void *
 	if (wall_to_monotonic.tv_nsec)
 		--jif;
 
-	for_each_cpu(i) {
+	for_each_online_cpu(i) {
 		int j;
 
 		user += kstat_cpu(i).cpustat.user;
@@ -390,7 +390,7 @@ int show_stat(struct seq_file *p, void *
 		(unsigned long long)jiffies_64_to_clock_t(iowait),
 		(unsigned long long)jiffies_64_to_clock_t(irq),
 		(unsigned long long)jiffies_64_to_clock_t(softirq));
-	for_each_cpu(i) {
+	for_each_online_cpu(i) {
 
 		/* Copy values here to work around gcc-2.95.3, gcc-2.96 */
 		user = kstat_cpu(i).cpustat.user;
diff -puN include/asm-ia64/cpumask.h~cpu_present include/asm-ia64/cpumask.h
--- linux-2.6.5-lhcs/include/asm-ia64/cpumask.h~cpu_present	2004-04-27 17:43:44.004332798 -0700
+++ linux-2.6.5-lhcs-root/include/asm-ia64/cpumask.h	2004-04-27 17:43:44.008239050 -0700
@@ -1,6 +1,7 @@
 #ifndef _ASM_IA64_CPUMASK_H
 #define _ASM_IA64_CPUMASK_H
 
+#define ARCH_HAS_CPU_PRESENT_MAP
 #include <asm-generic/cpumask.h>
 
 #endif /* _ASM_IA64_CPUMASK_H */

_
