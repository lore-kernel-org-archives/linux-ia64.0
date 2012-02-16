From: Rusty Russell <rusty@rustcorp.com.au>
Date: Thu, 16 Feb 2012 03:53:06 +0000
Subject: [PATCH 4/5] documentation: remove references to cpu_*_map.
Message-Id: <1329364286.25917.rusty@rustcorp.com.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

From: Rusty Russell <rusty@rustcorp.com.au>

This has been obsolescent for a while, fix documentation and
misc comments.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 Documentation/cpu-hotplug.txt       |   22 +++++++++++-----------
 arch/ia64/kernel/acpi.c             |    2 +-
 arch/mips/cavium-octeon/smp.c       |    2 +-
 arch/mips/pmc-sierra/yosemite/smp.c |    2 +-
 arch/mips/sibyte/bcm1480/smp.c      |    2 +-
 arch/tile/kernel/setup.c            |    2 +-
 arch/x86/xen/enlighten.c            |    2 +-
 init/Kconfig                        |    4 ++--
 8 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/Documentation/cpu-hotplug.txt b/Documentation/cpu-hotplug.txt
--- a/Documentation/cpu-hotplug.txt
+++ b/Documentation/cpu-hotplug.txt
@@ -47,7 +47,7 @@ maxcpus=n    Restrict boot time cpus to 
              other cpus later online, read FAQ's for more info.
 
 additional_cpus=n (*)	Use this to limit hotpluggable cpus. This option sets
-  			cpu_possible_map = cpu_present_map + additional_cpus
+  			cpu_possible_mask = cpu_present_mask + additional_cpus
 
 cede_offline={"off","on"}  Use this option to disable/enable putting offlined
 		            processors to an extended H_CEDE state on
@@ -64,11 +64,11 @@ should only rely on this to count the # 
 on the apicid values in those tables for disabled apics. In the event
 BIOS doesn't mark such hot-pluggable cpus as disabled entries, one could
 use this parameter "additional_cpus=x" to represent those cpus in the
-cpu_possible_map.
+cpu_possible_mask.
 
 possible_cpus=n		[s390,x86_64] use this to set hotpluggable cpus.
 			This option sets possible_cpus bits in
-			cpu_possible_map. Thus keeping the numbers of bits set
+			cpu_possible_mask. Thus keeping the numbers of bits set
 			constant even if the machine gets rebooted.
 
 CPU maps and such
@@ -76,7 +76,7 @@ CPU maps and such
 [More on cpumaps and primitive to manipulate, please check
 include/linux/cpumask.h that has more descriptive text.]
 
-cpu_possible_map: Bitmap of possible CPUs that can ever be available in the
+cpu_possible_mask: Bitmap of possible CPUs that can ever be available in the
 system. This is used to allocate some boot time memory for per_cpu variables
 that aren't designed to grow/shrink as CPUs are made available or removed.
 Once set during boot time discovery phase, the map is static, i.e no bits
@@ -84,13 +84,13 @@ are added or removed anytime.  Trimming 
 upfront can save some boot time memory. See below for how we use heuristics
 in x86_64 case to keep this under check.
 
-cpu_online_map: Bitmap of all CPUs currently online. Its set in __cpu_up()
+cpu_online_mask: Bitmap of all CPUs currently online. Its set in __cpu_up()
 after a cpu is available for kernel scheduling and ready to receive
 interrupts from devices. Its cleared when a cpu is brought down using
 __cpu_disable(), before which all OS services including interrupts are
 migrated to another target CPU.
 
-cpu_present_map: Bitmap of CPUs currently present in the system. Not all
+cpu_present_mask: Bitmap of CPUs currently present in the system. Not all
 of them may be online. When physical hotplug is processed by the relevant
 subsystem (e.g ACPI) can change and new bit either be added or removed
 from the map depending on the event is hot-add/hot-remove. There are currently
@@ -99,22 +99,22 @@ at which time hotplug is disabled.
 
 You really dont need to manipulate any of the system cpu maps. They should
 be read-only for most use. When setting up per-cpu resources almost always use
-cpu_possible_map/for_each_possible_cpu() to iterate.
+cpu_possible_mask/for_each_possible_cpu() to iterate.
 
 Never use anything other than cpumask_t to represent bitmap of CPUs.
 
 	#include <linux/cpumask.h>
 
-	for_each_possible_cpu     - Iterate over cpu_possible_map
-	for_each_online_cpu       - Iterate over cpu_online_map
-	for_each_present_cpu      - Iterate over cpu_present_map
+	for_each_possible_cpu     - Iterate over cpu_possible_mask
+	for_each_online_cpu       - Iterate over cpu_online_mask
+	for_each_present_cpu      - Iterate over cpu_present_mask
 	for_each_cpu_mask(x,mask) - Iterate over some random collection of cpu mask.
 
 	#include <linux/cpu.h>
 	get_online_cpus() and put_online_cpus():
 
 The above calls are used to inhibit cpu hotplug operations. While the
-cpu_hotplug.refcount is non zero, the cpu_online_map will not change.
+cpu_hotplug.refcount is non zero, the cpu_online_mask will not change.
 If you merely need to avoid cpus going away, you could also use
 preempt_disable() and preempt_enable() for those sections.
 Just remember the critical section cannot call any
diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -840,7 +840,7 @@ static __init int setup_additional_cpus(
 early_param("additional_cpus", setup_additional_cpus);
 
 /*
- * cpu_possible_map should be static, it cannot change as CPUs
+ * cpu_possible_mask should be static, it cannot change as CPUs
  * are onlined, or offlined. The reason is per-cpu data-structures
  * are allocated by some modules at init time, and dont expect to
  * do this dynamically on cpu arrival/departure.
diff --git a/arch/mips/cavium-octeon/smp.c b/arch/mips/cavium-octeon/smp.c
--- a/arch/mips/cavium-octeon/smp.c
+++ b/arch/mips/cavium-octeon/smp.c
@@ -78,7 +78,7 @@ static inline void octeon_send_ipi_mask(
 }
 
 /**
- * Detect available CPUs, populate cpu_possible_map
+ * Detect available CPUs, populate cpu_possible_mask
  */
 static void octeon_smp_hotplug_setup(void)
 {
diff --git a/arch/mips/pmc-sierra/yosemite/smp.c b/arch/mips/pmc-sierra/yosemite/smp.c
--- a/arch/mips/pmc-sierra/yosemite/smp.c
+++ b/arch/mips/pmc-sierra/yosemite/smp.c
@@ -146,7 +146,7 @@ static void __cpuinit yos_boot_secondary
 }
 
 /*
- * Detect available CPUs, populate cpu_possible_map before smp_init
+ * Detect available CPUs, populate cpu_possible_mask before smp_init
  *
  * We don't want to start the secondary CPU yet nor do we have a nice probing
  * feature in PMON so we just assume presence of the secondary core.
diff --git a/arch/mips/sibyte/bcm1480/smp.c b/arch/mips/sibyte/bcm1480/smp.c
--- a/arch/mips/sibyte/bcm1480/smp.c
+++ b/arch/mips/sibyte/bcm1480/smp.c
@@ -138,7 +138,7 @@ static void __cpuinit bcm1480_boot_secon
 
 /*
  * Use CFE to find out how many CPUs are available, setting up
- * cpu_possible_map and the logical/physical mappings.
+ * cpu_possible_mask and the logical/physical mappings.
  * XXXKW will the boot CPU ever not be physical 0?
  *
  * Common setup before any secondaries are started
diff --git a/arch/tile/kernel/setup.c b/arch/tile/kernel/setup.c
--- a/arch/tile/kernel/setup.c
+++ b/arch/tile/kernel/setup.c
@@ -1100,7 +1100,7 @@ EXPORT_SYMBOL(hash_for_home_map);
 
 /*
  * cpu_cacheable_map lists all the cpus whose caches the hypervisor can
- * flush on our behalf.  It is set to cpu_possible_map OR'ed with
+ * flush on our behalf.  It is set to cpu_possible_mask OR'ed with
  * hash_for_home_map, and it is what should be passed to
  * hv_flush_remote() to flush all caches.  Note that if there are
  * dedicated hypervisor driver tiles that have authorized use of their
diff --git a/arch/x86/xen/enlighten.c b/arch/x86/xen/enlighten.c
--- a/arch/x86/xen/enlighten.c
+++ b/arch/x86/xen/enlighten.c
@@ -876,7 +876,7 @@ void xen_setup_shared_info(void)
 	xen_setup_mfn_list_list();
 }
 
-/* This is called once we have the cpu_possible_map */
+/* This is called once we have the cpu_possible_mask */
 void xen_setup_vcpu_info_placement(void)
 {
 	int cpu;
diff --git a/init/Kconfig b/init/Kconfig
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1423,8 +1423,8 @@ endif # MODULES
 config INIT_ALL_POSSIBLE
 	bool
 	help
-	  Back when each arch used to define their own cpu_online_map and
-	  cpu_possible_map, some of them chose to initialize cpu_possible_map
+	  Back when each arch used to define their own cpu_online_mask and
+	  cpu_possible_mask, some of them chose to initialize cpu_possible_mask
 	  with all 1s, and others with all 0s.  When they were centralised,
 	  it was better to provide this option than to break all the archs
 	  and have several arch maintainers pursuing me down dark alleys.

