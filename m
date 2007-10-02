From: akpm@linux-foundation.org
Date: Tue, 02 Oct 2007 20:39:45 +0000
Subject: [patch 1/2] ia64 tree-wide: Misc __cpu{initdata, init, exit} annotations
Message-Id: <200710022039.l92KdkN4021181@imap1.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Satyam Sharma <satyam@infradead.org>

* palinfo.c:

palinfo_cpu_notifier is a CPU hotplug notifier_block, and can be
marked __cpuinitdata, and the callback function palinfo_cpu_callback()
itself can be marked __cpuinit. create_palinfo_proc_entries() is only
called from __cpuinit callback or general __init code, therefore a
candidate for __cpuinit itself. remove_palinfo_proc_entries() is only
called from __cpuinit callback or general __exit code, therefore a
candidate for __cpuexit.

* salinfo.c:

The CPU hotplug notifier_block can be __cpuinitdata. The callback
salinfo_cpu_callback() is incorrectly marked __devinit -- it must
be __cpuinit instead.

* topology.c:

cache_sysfs_init() is only called at device_initcall() time so marking
it as __cpuinit is wrong and wasteful. It should be unconditionally
__init. Also cleanup reference to hotplug notifier callback function
from this function and replace with cache_add_dev(), which could also
enable us to use other tricks to replace __cpuinit{data} annotations,
as recently discussed on this list.

cache_shared_cpu_map_setup() is only ever called from __cpuinit-marked
functions hence both its definitions (SMP or !SMP) are candidates for
__cpuinit itself. Also all_cpu_cache_info can be __cpuinitdata because
only referenced from __cpuinit code.

Signed-off-by: Satyam Sharma <satyam@infradead.org>
Cc: "Luck, Tony" <tony.luck@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/ia64/kernel/palinfo.c  |    6 +++---
 arch/ia64/kernel/salinfo.c  |    4 ++--
 arch/ia64/kernel/topology.c |   12 ++++++------
 3 files changed, 11 insertions(+), 11 deletions(-)

diff -puN arch/ia64/kernel/palinfo.c~ia64-tree-wide-misc-__cpuinitdata-init-exit arch/ia64/kernel/palinfo.c
--- a/arch/ia64/kernel/palinfo.c~ia64-tree-wide-misc-__cpuinitdata-init-exit
+++ a/arch/ia64/kernel/palinfo.c
@@ -907,7 +907,7 @@ palinfo_read_entry(char *page, char **st
 	return len;
 }
 
-static void
+static void __cpuinit
 create_palinfo_proc_entries(unsigned int cpu)
 {
 #	define CPUSTR	"cpu%d"
@@ -968,7 +968,7 @@ remove_palinfo_proc_entries(unsigned int
 	}
 }
 
-static int palinfo_cpu_callback(struct notifier_block *nfb,
+static int __cpuinit palinfo_cpu_callback(struct notifier_block *nfb,
 					unsigned long action, void *hcpu)
 {
 	unsigned int hotcpu = (unsigned long)hcpu;
@@ -986,7 +986,7 @@ static int palinfo_cpu_callback(struct n
 	return NOTIFY_OK;
 }
 
-static struct notifier_block palinfo_cpu_notifier +static struct notifier_block palinfo_cpu_notifier __cpuinitdata  {
 	.notifier_call = palinfo_cpu_callback,
 	.priority = 0,
diff -puN arch/ia64/kernel/salinfo.c~ia64-tree-wide-misc-__cpuinitdata-init-exit arch/ia64/kernel/salinfo.c
--- a/arch/ia64/kernel/salinfo.c~ia64-tree-wide-misc-__cpuinitdata-init-exit
+++ a/arch/ia64/kernel/salinfo.c
@@ -574,7 +574,7 @@ static const struct file_operations sali
 	.write   = salinfo_log_write,
 };
 
-static int __devinit
+static int __cpuinit
 salinfo_cpu_callback(struct notifier_block *nb, unsigned long action, void *hcpu)
 {
 	unsigned int i, cpu = (unsigned long)hcpu;
@@ -615,7 +615,7 @@ salinfo_cpu_callback(struct notifier_blo
 	return NOTIFY_OK;
 }
 
-static struct notifier_block salinfo_cpu_notifier +static struct notifier_block salinfo_cpu_notifier __cpuinitdata  {
 	.notifier_call = salinfo_cpu_callback,
 	.priority = 0,
diff -puN arch/ia64/kernel/topology.c~ia64-tree-wide-misc-__cpuinitdata-init-exit arch/ia64/kernel/topology.c
--- a/arch/ia64/kernel/topology.c~ia64-tree-wide-misc-__cpuinitdata-init-exit
+++ a/arch/ia64/kernel/topology.c
@@ -118,11 +118,11 @@ struct cpu_cache_info {
 	struct kobject kobj;
 };
 
-static struct cpu_cache_info	all_cpu_cache_info[NR_CPUS];
+static struct cpu_cache_info	all_cpu_cache_info[NR_CPUS] __cpuinitdata;
 #define LEAF_KOBJECT_PTR(x,y)    (&all_cpu_cache_info[x].cache_leaves[y])
 
 #ifdef CONFIG_SMP
-static void cache_shared_cpu_map_setup( unsigned int cpu,
+static void __cpuinit cache_shared_cpu_map_setup( unsigned int cpu,
 		struct cache_info * this_leaf)
 {
 	pal_cache_shared_info_t	csi;
@@ -157,7 +157,7 @@ static void cache_shared_cpu_map_setup( 
 				&csi) = PAL_STATUS_SUCCESS);
 }
 #else
-static void cache_shared_cpu_map_setup(unsigned int cpu,
+static void __cpuinit cache_shared_cpu_map_setup(unsigned int cpu,
 		struct cache_info * this_leaf)
 {
 	cpu_set(cpu, this_leaf->shared_cpu_map);
@@ -428,13 +428,13 @@ static struct notifier_block __cpuinitda
 	.notifier_call = cache_cpu_callback
 };
 
-static int __cpuinit cache_sysfs_init(void)
+static int __init cache_sysfs_init(void)
 {
 	int i;
 
 	for_each_online_cpu(i) {
-		cache_cpu_callback(&cache_cpu_notifier, CPU_ONLINE,
-				(void *)(long)i);
+		struct sys_device *sys_dev = get_cpu_sysdev((unsigned int)i);
+		cache_add_dev(sys_dev);
 	}
 
 	register_hotcpu_notifier(&cache_cpu_notifier);
_
