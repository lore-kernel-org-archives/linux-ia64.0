From: Ashok Raj <ashok.raj@intel.com>
Date: Tue, 14 Feb 2006 23:01:11 +0000
Subject: [patch 1/2] Dont set NR_CPUS for cpu_possible_map when CPU hotplug is enabled.
Message-Id: <20060214230622.236017529@csdlinux-2.jf.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Do not set cpu_possible_map for NR_CPUS when ACPI_CONFIG_HOTPLUG_CPU is set.

Signed-off-by: Ashok Raj <ashok.raj@intel.com>
---------------------------------------------------------------------
 arch/ia64/kernel/smpboot.c |    5 +----
 1 files changed, 1 insertion(+), 4 deletions(-)

Index: linux-2.6.16-rc3-mm1/arch/ia64/kernel/smpboot.c
=================================--- linux-2.6.16-rc3-mm1.orig/arch/ia64/kernel/smpboot.c
+++ linux-2.6.16-rc3-mm1/arch/ia64/kernel/smpboot.c
@@ -135,7 +135,7 @@ DEFINE_PER_CPU(int, cpu_state);
 /* Bitmasks of currently online, and possible CPUs */
 cpumask_t cpu_online_map;
 EXPORT_SYMBOL(cpu_online_map);
-cpumask_t cpu_possible_map;
+cpumask_t cpu_possible_map = CPU_MASK_NONE;
 EXPORT_SYMBOL(cpu_possible_map);
 
 cpumask_t cpu_core_map[NR_CPUS] __cacheline_aligned;
@@ -558,9 +558,6 @@ smp_build_cpu_map (void)
 
 	for (cpu = 0; cpu < NR_CPUS; cpu++) {
 		ia64_cpu_to_sapicid[cpu] = -1;
-#ifdef CONFIG_HOTPLUG_CPU
-		cpu_set(cpu, cpu_possible_map);
-#endif
 	}
 
 	ia64_cpu_to_sapicid[0] = boot_cpu_id;

--

