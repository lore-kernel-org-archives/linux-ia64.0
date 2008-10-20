From: Mike Travis <travis@sgi.com>
Date: Mon, 20 Oct 2008 17:03:48 +0000
Subject: [PATCH 29/35] cpumask: Use accessors code.
Message-Id: <20081020170323.602974000@polaris-admin.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081020170319.539427000@polaris-admin.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>, Rusty Russell <rusty@rustcorp.com.au>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, davej@codemonkey.org.uk, David Miller <davem@davemloft.net>, Eric Dumazet <dada1@cosmosbay.com>, Jack Steiner <steiner@sgi.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Jes Sorensen <jes@sgi.com>, "H. Peter Anvin" <hpa@zytor.com>, peterz@infradead.org, Thomas Gleixner <tglx@linutronix.de>, Yinghai Lu <yhlu.kernel@gmail.com>, IA64 <linux-ia64@vger.kernel.org>, PowerPC <linuxppc-dev@ozlabs.org>, S390 <linux-s390@vger.kernel.org>, SPARC <sparclinux@vger.kernel.org>, linux-kernel@vger.kernel.org

Use the accessors rather than frobbing bits directly.  Most of this is
in arch code I haven't even compiled, but is straightforward.

From: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Mike Travis <travis@sgi.com>
---
 arch/arm/mach-realview/platsmp.c        |    2 +-
 arch/cris/arch-v32/kernel/smp.c         |    4 ++--
 arch/ia64/kernel/acpi.c                 |    2 +-
 arch/ia64/kernel/smpboot.c              |   17 +++++++----------
 arch/m32r/kernel/smpboot.c              |    2 +-
 arch/mips/kernel/smp-cmp.c              |    6 ++++--
 arch/mips/kernel/smp.c                  |    2 +-
 arch/powerpc/kernel/setup-common.c      |    4 ++--
 arch/powerpc/platforms/powermac/setup.c |    2 +-
 arch/s390/kernel/smp.c                  |    5 ++---
 arch/sh/kernel/cpu/sh4a/smp-shx3.c      |    5 ++---
 arch/sh/kernel/smp.c                    |    6 +++---
 arch/sparc64/kernel/mdesc.c             |    2 +-
 arch/sparc64/kernel/prom.c              |    4 ++--
 arch/um/kernel/smp.c                    |    2 +-
 arch/x86/kernel/apic.c                  |    4 ++--
 16 files changed, 33 insertions(+), 36 deletions(-)

--- linux-2.6.28.orig/arch/arm/mach-realview/platsmp.c
+++ linux-2.6.28/arch/arm/mach-realview/platsmp.c
@@ -193,7 +193,7 @@ void __init smp_init_cpus(void)
 	unsigned int i, ncores = get_core_count();
 
 	for (i = 0; i < ncores; i++)
-		cpu_set(i, cpu_possible_map);
+		set_cpu_possible(i, true);
 }
 
 void __init smp_prepare_cpus(unsigned int max_cpus)
--- linux-2.6.28.orig/arch/cris/arch-v32/kernel/smp.c
+++ linux-2.6.28/arch/cris/arch-v32/kernel/smp.c
@@ -102,9 +102,9 @@ void __devinit smp_prepare_boot_cpu(void
 	SUPP_BANK_SEL(2);
 	SUPP_REG_WR(RW_MM_TLB_PGD, pgd);
 
-	cpu_set(0, cpu_online_map);
+	set_cpu_online(0, true);
 	cpu_set(0, phys_cpu_present_map);
-	cpu_set(0, cpu_possible_map);
+	set_cpu_possible(0, true);
 }
 
 void __init smp_cpus_done(unsigned int max_cpus)
--- linux-2.6.28.orig/arch/ia64/kernel/acpi.c
+++ linux-2.6.28/arch/ia64/kernel/acpi.c
@@ -845,7 +845,7 @@ __init void prefill_possible_map(void)
 		possible, max((possible - available_cpus), 0));
 
 	for (i = 0; i < possible; i++)
-		cpu_set(i, cpu_possible_map);
+		set_cpu_possible(i, true);
 }
 
 int acpi_map_lsapic(acpi_handle handle, int *pcpu)
--- linux-2.6.28.orig/arch/ia64/kernel/smpboot.c
+++ linux-2.6.28/arch/ia64/kernel/smpboot.c
@@ -587,14 +587,14 @@ smp_build_cpu_map (void)
 
 	ia64_cpu_to_sapicid[0] = boot_cpu_id;
 	cpus_clear(cpu_present_map);
-	cpu_set(0, cpu_present_map);
-	cpu_set(0, cpu_possible_map);
+	set_cpu_present(0, true);
+	set_cpu_possible(0, true);
 	for (cpu = 1, i = 0; i < smp_boot_data.cpu_count; i++) {
 		sapicid = smp_boot_data.cpu_phys_id[i];
 		if (sapicid = boot_cpu_id)
 			continue;
-		cpu_set(cpu, cpu_present_map);
-		cpu_set(cpu, cpu_possible_map);
+		set_cpu_present(cpu, true);
+		set_cpu_possible(cpu, true);
 		ia64_cpu_to_sapicid[cpu] = sapicid;
 		cpu++;
 	}
@@ -632,12 +632,9 @@ smp_prepare_cpus (unsigned int max_cpus)
 	 */
 	if (!max_cpus) {
 		printk(KERN_INFO "SMP mode deactivated.\n");
-		cpus_clear(cpu_online_map);
-		cpus_clear(cpu_present_map);
-		cpus_clear(cpu_possible_map);
-		cpu_set(0, cpu_online_map);
-		cpu_set(0, cpu_present_map);
-		cpu_set(0, cpu_possible_map);
+		init_cpu_online(cpumask_of(0));
+		init_cpu_present(cpumask_of(0));
+		init_cpu_possible(cpumask_of(0));
 		return;
 	}
 }
--- linux-2.6.28.orig/arch/m32r/kernel/smpboot.c
+++ linux-2.6.28/arch/m32r/kernel/smpboot.c
@@ -183,7 +183,7 @@ void __init smp_prepare_cpus(unsigned in
 	for (phys_id = 0 ; phys_id < nr_cpu ; phys_id++)
 		physid_set(phys_id, phys_cpu_present_map);
 #ifndef CONFIG_HOTPLUG_CPU
-	cpu_present_map = cpu_possible_map;
+	init_cpu_present(&cpu_possible_map);
 #endif
 
 	show_mp_info(nr_cpu);
--- linux-2.6.28.orig/arch/mips/kernel/smp-cmp.c
+++ linux-2.6.28/arch/mips/kernel/smp-cmp.c
@@ -52,8 +52,10 @@ static int __init allowcpus(char *str)
 
 	cpus_clear(cpu_allow_map);
 	if (cpulist_parse(str, &cpu_allow_map) = 0) {
-		cpu_set(0, cpu_allow_map);
-		cpus_and(cpu_possible_map, cpu_possible_map, cpu_allow_map);
+		unsigned int i;
+		for (i = 1; i < nr_cpu_ids; i++)
+			if (!cpumask_test_cpu(i, cpu_allow_map))
+				set_cpu_possible(i, false);
 		len = cpulist_scnprintf(buf, sizeof(buf)-1, &cpu_possible_map);
 		buf[len] = '\0';
 		pr_debug("Allowable CPUs: %s\n", buf);
--- linux-2.6.28.orig/arch/mips/kernel/smp.c
+++ linux-2.6.28/arch/mips/kernel/smp.c
@@ -186,7 +186,7 @@ void __init smp_prepare_cpus(unsigned in
 	mp_ops->prepare_cpus(max_cpus);
 	set_cpu_sibling_map(0);
 #ifndef CONFIG_HOTPLUG_CPU
-	cpu_present_map = cpu_possible_map;
+	init_cpu_present(&cpu_possible_map);
 #endif
 }
 
--- linux-2.6.28.orig/arch/powerpc/kernel/setup-common.c
+++ linux-2.6.28/arch/powerpc/kernel/setup-common.c
@@ -413,7 +413,7 @@ void __init smp_setup_cpu_maps(void)
 			    j, cpu, intserv[j]);
 			cpu_set(cpu, cpu_present_map);
 			set_hard_smp_processor_id(cpu, intserv[j]);
-			cpu_set(cpu, cpu_possible_map);
+			set_cpu_possible(cpu, true);
 			cpu++;
 		}
 	}
@@ -459,7 +459,7 @@ void __init smp_setup_cpu_maps(void)
 			       maxcpus);
 
 		for (cpu = 0; cpu < maxcpus; cpu++)
-			cpu_set(cpu, cpu_possible_map);
+			set_cpu_possible(cpu, true);
 	out:
 		of_node_put(dn);
 	}
--- linux-2.6.28.orig/arch/powerpc/platforms/powermac/setup.c
+++ linux-2.6.28/arch/powerpc/platforms/powermac/setup.c
@@ -366,7 +366,7 @@ static void __init pmac_setup_arch(void)
 		int cpu;
 
 		for (cpu = 1; cpu < 4 && cpu < nr_cpu_ids; ++cpu)
-			cpu_set(cpu, cpu_possible_map);
+			set_cpu_possible(cpu, true);
 		smp_ops = &psurge_smp_ops;
 	}
 #endif
--- linux-2.6.28.orig/arch/s390/kernel/smp.c
+++ linux-2.6.28/arch/s390/kernel/smp.c
@@ -732,9 +732,8 @@ static int __init setup_possible_cpus(ch
 	int pcpus, cpu;
 
 	pcpus = simple_strtoul(s, NULL, 0);
-	cpu_possible_map = cpumask_of_cpu(0);
-	for (cpu = 1; cpu < pcpus && cpu < nr_cpu_ids; cpu++)
-		cpu_set(cpu, cpu_possible_map);
+	for (cpu = 0; cpu < pcpus && cpu < nr_cpu_ids; cpu++)
+		set_cpu_possible(cpu, true);
 	return 0;
 }
 early_param("possible_cpus", setup_possible_cpus);
--- linux-2.6.28.orig/arch/sh/kernel/cpu/sh4a/smp-shx3.c
+++ linux-2.6.28/arch/sh/kernel/cpu/sh4a/smp-shx3.c
@@ -19,8 +19,7 @@ void __init plat_smp_setup(void)
 	unsigned int cpu = 0;
 	int i, num;
 
-	cpus_clear(cpu_possible_map);
-	cpu_set(cpu, cpu_possible_map);
+	init_cpu_possible(cpumask_of(cpu));
 
 	__cpu_number_map[0] = 0;
 	__cpu_logical_map[0] = 0;
@@ -30,7 +29,7 @@ void __init plat_smp_setup(void)
 	 * for the total number of cores.
 	 */
 	for (i = 1, num = 0; i < NR_CPUS; i++) {
-		cpu_set(i, cpu_possible_map);
+		set_cpu_possible(i, true);
 		__cpu_number_map[i] = ++num;
 		__cpu_logical_map[num] = i;
 	}
--- linux-2.6.28.orig/arch/sh/kernel/smp.c
+++ linux-2.6.28/arch/sh/kernel/smp.c
@@ -52,7 +52,7 @@ void __init smp_prepare_cpus(unsigned in
 	plat_prepare_cpus(max_cpus);
 
 #ifndef CONFIG_HOTPLUG_CPU
-	cpu_present_map = cpu_possible_map;
+	init_cpu_present(&cpu_possible_map);
 #endif
 }
 
@@ -63,8 +63,8 @@ void __devinit smp_prepare_boot_cpu(void
 	__cpu_number_map[0] = cpu;
 	__cpu_logical_map[0] = cpu;
 
-	cpu_set(cpu, cpu_online_map);
-	cpu_set(cpu, cpu_possible_map);
+	set_cpu_online(cpu, true);
+	set_cpu_possible(cpu, true);
 }
 
 asmlinkage void __cpuinit start_secondary(void)
--- linux-2.6.28.orig/arch/sparc64/kernel/mdesc.c
+++ linux-2.6.28/arch/sparc64/kernel/mdesc.c
@@ -566,7 +566,7 @@ static void __init report_platform_prope
 			max_cpu = NR_CPUS;
 		}
 		for (i = 0; i < max_cpu; i++)
-			cpu_set(i, cpu_possible_map);
+			set_cpu_possible(i, true);
 	}
 #endif
 
--- linux-2.6.28.orig/arch/sparc64/kernel/prom.c
+++ linux-2.6.28/arch/sparc64/kernel/prom.c
@@ -1601,8 +1601,8 @@ static void __init of_fill_in_cpu_data(v
 		}
 
 #ifdef CONFIG_SMP
-		cpu_set(cpuid, cpu_present_map);
-		cpu_set(cpuid, cpu_possible_map);
+		set_cpu_present(cpuid, true);
+		set_cpu_possible(cpuid, true);
 #endif
 	}
 
--- linux-2.6.28.orig/arch/um/kernel/smp.c
+++ linux-2.6.28/arch/um/kernel/smp.c
@@ -118,7 +118,7 @@ void smp_prepare_cpus(unsigned int maxcp
 	int i;
 
 	for (i = 0; i < ncpus; ++i)
-		cpu_set(i, cpu_possible_map);
+		set_cpu_possible(i, true);
 
 	cpu_clear(me, cpu_online_map);
 	cpu_set(me, cpu_online_map);
--- linux-2.6.28.orig/arch/x86/kernel/apic.c
+++ linux-2.6.28/arch/x86/kernel/apic.c
@@ -1903,8 +1903,8 @@ void __cpuinit generic_processor_info(in
 	}
 #endif
 
-	cpu_set(cpu, cpu_possible_map);
-	cpu_set(cpu, cpu_present_map);
+	set_cpu_possible(cpu, true);
+	set_cpu_present(cpu, true);
 }
 
 #ifdef CONFIG_X86_64

-- 
