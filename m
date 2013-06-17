From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Mon, 17 Jun 2013 19:51:20 +0000
Subject: [PATCH] ia64: delete __cpuinit usage from all ia64 users
Message-Id: <1371498680-19317-1-git-send-email-paul.gortmaker@windriver.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The __cpuinit type of throwaway sections might have made sense
some time ago when RAM was more constrained, but now the savings
do not offset the cost and complications.  For example, the fix in
commit 5e427ec2d0 ("x86: Fix bit corruption at CPU resume time")
is a good example of the nasty type of bugs that can be created
with improper use of the various __init prefixes.

After a discussion on LKML[1] it was decided that cpuinit should go
the way of devinit and be phased out.  Once all the users are gone,
we can then finally remove the macros themselves from linux/init.h.

This removes all the ia64 uses of the __cpuinit macros.

[1] https://lkml.org/lkml/2013/5/20/589

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---

[This was generated against today's linux-next tree ; I'm assuming all
 pending ia64 changes are in there currently.]

 arch/ia64/kernel/acpi.c       |  4 ++--
 arch/ia64/kernel/err_inject.c |  8 ++++----
 arch/ia64/kernel/mca.c        | 12 ++++++------
 arch/ia64/kernel/numa.c       |  4 ++--
 arch/ia64/kernel/palinfo.c    |  4 ++--
 arch/ia64/kernel/salinfo.c    |  4 ++--
 arch/ia64/kernel/setup.c      | 10 +++++-----
 arch/ia64/kernel/smpboot.c    |  8 ++++----
 arch/ia64/kernel/topology.c   | 18 +++++++++---------
 arch/ia64/mm/contig.c         |  3 +--
 arch/ia64/mm/discontig.c      |  2 +-
 arch/ia64/mm/numa.c           |  2 +-
 arch/ia64/sn/kernel/setup.c   |  8 ++++----
 arch/ia64/xen/hypervisor.c    |  2 +-
 14 files changed, 44 insertions(+), 45 deletions(-)

diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index 335eb07..5eb71d2 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -807,7 +807,7 @@ int acpi_isa_irq_to_gsi(unsigned isa_irq, u32 *gsi)
  *  ACPI based hotplug CPU support
  */
 #ifdef CONFIG_ACPI_HOTPLUG_CPU
-static __cpuinit
+static
 int acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
 {
 #ifdef CONFIG_ACPI_NUMA
@@ -882,7 +882,7 @@ __init void prefill_possible_map(void)
 		set_cpu_possible(i, true);
 }
 
-static int __cpuinit _acpi_map_lsapic(acpi_handle handle, int *pcpu)
+static int _acpi_map_lsapic(acpi_handle handle, int *pcpu)
 {
 	struct acpi_buffer buffer = { ACPI_ALLOCATE_BUFFER, NULL };
 	union acpi_object *obj;
diff --git a/arch/ia64/kernel/err_inject.c b/arch/ia64/kernel/err_inject.c
index 2d67317..f59c0b8 100644
--- a/arch/ia64/kernel/err_inject.c
+++ b/arch/ia64/kernel/err_inject.c
@@ -225,17 +225,17 @@ static struct attribute_group err_inject_attr_group = {
 	.name = "err_inject"
 };
 /* Add/Remove err_inject interface for CPU device */
-static int __cpuinit err_inject_add_dev(struct device * sys_dev)
+static int err_inject_add_dev(struct device *sys_dev)
 {
 	return sysfs_create_group(&sys_dev->kobj, &err_inject_attr_group);
 }
 
-static int __cpuinit err_inject_remove_dev(struct device * sys_dev)
+static int err_inject_remove_dev(struct device *sys_dev)
 {
 	sysfs_remove_group(&sys_dev->kobj, &err_inject_attr_group);
 	return 0;
 }
-static int __cpuinit err_inject_cpu_callback(struct notifier_block *nfb,
+static int err_inject_cpu_callback(struct notifier_block *nfb,
 		unsigned long action, void *hcpu)
 {
 	unsigned int cpu = (unsigned long)hcpu;
@@ -256,7 +256,7 @@ static int __cpuinit err_inject_cpu_callback(struct notifier_block *nfb,
 	return NOTIFY_OK;
 }
 
-static struct notifier_block __cpuinitdata err_inject_cpu_notifier +static struct notifier_block err_inject_cpu_notifier  {
 	.notifier_call = err_inject_cpu_callback,
 };
diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index d7396db..b8edfa7 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -631,7 +631,7 @@ ia64_mca_register_cpev (int cpev)
  * Outputs
  *	None
  */
-void __cpuinit
+void
 ia64_mca_cmc_vector_setup (void)
 {
 	cmcv_reg_t	cmcv;
@@ -1814,7 +1814,7 @@ static struct irqaction mca_cpep_irqaction = {
  * format most of the fields.
  */
 
-static void __cpuinit
+static void
 format_mca_init_stack(void *mca_data, unsigned long offset,
 		const char *type, int cpu)
 {
@@ -1844,7 +1844,7 @@ static void * __init_refok mca_bootmem(void)
 }
 
 /* Do per-CPU MCA-related initialization.  */
-void __cpuinit
+void
 ia64_mca_cpu_init(void *cpu_data)
 {
 	void *pal_vaddr;
@@ -1896,7 +1896,7 @@ ia64_mca_cpu_init(void *cpu_data)
 							      PAGE_KERNEL));
 }
 
-static void __cpuinit ia64_mca_cmc_vector_adjust(void *dummy)
+static void ia64_mca_cmc_vector_adjust(void *dummy)
 {
 	unsigned long flags;
 
@@ -1906,7 +1906,7 @@ static void __cpuinit ia64_mca_cmc_vector_adjust(void *dummy)
 	local_irq_restore(flags);
 }
 
-static int __cpuinit mca_cpu_callback(struct notifier_block *nfb,
+static int mca_cpu_callback(struct notifier_block *nfb,
 				      unsigned long action,
 				      void *hcpu)
 {
@@ -1922,7 +1922,7 @@ static int __cpuinit mca_cpu_callback(struct notifier_block *nfb,
 	return NOTIFY_OK;
 }
 
-static struct notifier_block mca_cpu_notifier __cpuinitdata = {
+static struct notifier_block mca_cpu_notifier = {
 	.notifier_call = mca_cpu_callback
 };
 
diff --git a/arch/ia64/kernel/numa.c b/arch/ia64/kernel/numa.c
index c93420c..d288cde 100644
--- a/arch/ia64/kernel/numa.c
+++ b/arch/ia64/kernel/numa.c
@@ -30,7 +30,7 @@ EXPORT_SYMBOL(cpu_to_node_map);
 cpumask_t node_to_cpu_mask[MAX_NUMNODES] __cacheline_aligned;
 EXPORT_SYMBOL(node_to_cpu_mask);
 
-void __cpuinit map_cpu_to_node(int cpu, int nid)
+void map_cpu_to_node(int cpu, int nid)
 {
 	int oldnid;
 	if (nid < 0) { /* just initialize by zero */
@@ -51,7 +51,7 @@ void __cpuinit map_cpu_to_node(int cpu, int nid)
 	return;
 }
 
-void __cpuinit unmap_cpu_from_node(int cpu, int nid)
+void unmap_cpu_from_node(int cpu, int nid)
 {
 	WARN_ON(!cpu_isset(cpu, node_to_cpu_mask[nid]));
 	WARN_ON(cpu_to_node_map[cpu] != nid);
diff --git a/arch/ia64/kernel/palinfo.c b/arch/ia64/kernel/palinfo.c
index 2b3c2d7..ab33328 100644
--- a/arch/ia64/kernel/palinfo.c
+++ b/arch/ia64/kernel/palinfo.c
@@ -932,7 +932,7 @@ static const struct file_operations proc_palinfo_fops = {
 	.release	= single_release,
 };
 
-static void __cpuinit
+static void
 create_palinfo_proc_entries(unsigned int cpu)
 {
 	pal_func_cpu_u_t f;
@@ -962,7 +962,7 @@ remove_palinfo_proc_entries(unsigned int hcpu)
 	remove_proc_subtree(cpustr, palinfo_dir);
 }
 
-static int __cpuinit palinfo_cpu_callback(struct notifier_block *nfb,
+static int palinfo_cpu_callback(struct notifier_block *nfb,
 					unsigned long action, void *hcpu)
 {
 	unsigned int hotcpu = (unsigned long)hcpu;
diff --git a/arch/ia64/kernel/salinfo.c b/arch/ia64/kernel/salinfo.c
index 4bc580a..960a396 100644
--- a/arch/ia64/kernel/salinfo.c
+++ b/arch/ia64/kernel/salinfo.c
@@ -568,7 +568,7 @@ static const struct file_operations salinfo_data_fops = {
 	.llseek  = default_llseek,
 };
 
-static int __cpuinit
+static int
 salinfo_cpu_callback(struct notifier_block *nb, unsigned long action, void *hcpu)
 {
 	unsigned int i, cpu = (unsigned long)hcpu;
@@ -609,7 +609,7 @@ salinfo_cpu_callback(struct notifier_block *nb, unsigned long action, void *hcpu
 	return NOTIFY_OK;
 }
 
-static struct notifier_block salinfo_cpu_notifier __cpuinitdata +static struct notifier_block salinfo_cpu_notifier  {
 	.notifier_call = salinfo_cpu_callback,
 	.priority = 0,
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index 13bfdd2..4fc2e95 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -748,7 +748,7 @@ const struct seq_operations cpuinfo_op = {
 #define MAX_BRANDS	8
 static char brandname[MAX_BRANDS][128];
 
-static char * __cpuinit
+static char *
 get_model_name(__u8 family, __u8 model)
 {
 	static int overflow;
@@ -778,7 +778,7 @@ get_model_name(__u8 family, __u8 model)
 	return "Unknown";
 }
 
-static void __cpuinit
+static void
 identify_cpu (struct cpuinfo_ia64 *c)
 {
 	union {
@@ -850,7 +850,7 @@ identify_cpu (struct cpuinfo_ia64 *c)
  * 2. the minimum of the i-cache stride sizes for "flush_icache_range()".
  * 3. the minimum of the cache stride sizes for "clflush_cache_range()".
  */
-static void __cpuinit
+static void
 get_cache_info(void)
 {
 	unsigned long line_size, max = 1;
@@ -915,10 +915,10 @@ get_cache_info(void)
  * cpu_init() initializes state that is per-CPU.  This function acts
  * as a 'CPU state barrier', nothing should get across.
  */
-void __cpuinit
+void
 cpu_init (void)
 {
-	extern void __cpuinit ia64_mmu_init (void *);
+	extern void ia64_mmu_init(void *);
 	static unsigned long max_num_phys_stacked = IA64_NUM_PHYS_STACK_REG;
 	unsigned long num_phys_stacked;
 	pal_vm_info_2_u_t vmi;
diff --git a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
index 8d87168..547a48d 100644
--- a/arch/ia64/kernel/smpboot.c
+++ b/arch/ia64/kernel/smpboot.c
@@ -351,7 +351,7 @@ static inline void smp_setup_percpu_timer(void)
 {
 }
 
-static void __cpuinit
+static void
 smp_callin (void)
 {
 	int cpuid, phys_id, itc_master;
@@ -442,7 +442,7 @@ smp_callin (void)
 /*
  * Activate a secondary processor.  head.S calls this.
  */
-int __cpuinit
+int
 start_secondary (void *unused)
 {
 	/* Early console may use I/O ports */
@@ -459,7 +459,7 @@ start_secondary (void *unused)
 	return 0;
 }
 
-static int __cpuinit
+static int
 do_boot_cpu (int sapicid, int cpu, struct task_struct *idle)
 {
 	int timeout;
@@ -728,7 +728,7 @@ static inline void set_cpu_sibling_map(int cpu)
 	}
 }
 
-int __cpuinit
+int
 __cpu_up(unsigned int cpu, struct task_struct *tidle)
 {
 	int ret;
diff --git a/arch/ia64/kernel/topology.c b/arch/ia64/kernel/topology.c
index dc00b2c..ca69a5a 100644
--- a/arch/ia64/kernel/topology.c
+++ b/arch/ia64/kernel/topology.c
@@ -135,11 +135,11 @@ struct cpu_cache_info {
 	struct kobject kobj;
 };
 
-static struct cpu_cache_info	all_cpu_cache_info[NR_CPUS] __cpuinitdata;
+static struct cpu_cache_info	all_cpu_cache_info[NR_CPUS];
 #define LEAF_KOBJECT_PTR(x,y)    (&all_cpu_cache_info[x].cache_leaves[y])
 
 #ifdef CONFIG_SMP
-static void __cpuinit cache_shared_cpu_map_setup( unsigned int cpu,
+static void cache_shared_cpu_map_setup(unsigned int cpu,
 		struct cache_info * this_leaf)
 {
 	pal_cache_shared_info_t	csi;
@@ -174,7 +174,7 @@ static void __cpuinit cache_shared_cpu_map_setup( unsigned int cpu,
 				&csi) = PAL_STATUS_SUCCESS);
 }
 #else
-static void __cpuinit cache_shared_cpu_map_setup(unsigned int cpu,
+static void cache_shared_cpu_map_setup(unsigned int cpu,
 		struct cache_info * this_leaf)
 {
 	cpu_set(cpu, this_leaf->shared_cpu_map);
@@ -298,7 +298,7 @@ static struct kobj_type cache_ktype_percpu_entry = {
 	.sysfs_ops	= &cache_sysfs_ops,
 };
 
-static void __cpuinit cpu_cache_sysfs_exit(unsigned int cpu)
+static void cpu_cache_sysfs_exit(unsigned int cpu)
 {
 	kfree(all_cpu_cache_info[cpu].cache_leaves);
 	all_cpu_cache_info[cpu].cache_leaves = NULL;
@@ -307,7 +307,7 @@ static void __cpuinit cpu_cache_sysfs_exit(unsigned int cpu)
 	return;
 }
 
-static int __cpuinit cpu_cache_sysfs_init(unsigned int cpu)
+static int cpu_cache_sysfs_init(unsigned int cpu)
 {
 	unsigned long i, levels, unique_caches;
 	pal_cache_config_info_t cci;
@@ -351,7 +351,7 @@ static int __cpuinit cpu_cache_sysfs_init(unsigned int cpu)
 }
 
 /* Add cache interface for CPU device */
-static int __cpuinit cache_add_dev(struct device * sys_dev)
+static int cache_add_dev(struct device *sys_dev)
 {
 	unsigned int cpu = sys_dev->id;
 	unsigned long i, j;
@@ -401,7 +401,7 @@ static int __cpuinit cache_add_dev(struct device * sys_dev)
 }
 
 /* Remove cache interface for CPU device */
-static int __cpuinit cache_remove_dev(struct device * sys_dev)
+static int cache_remove_dev(struct device *sys_dev)
 {
 	unsigned int cpu = sys_dev->id;
 	unsigned long i;
@@ -425,7 +425,7 @@ static int __cpuinit cache_remove_dev(struct device * sys_dev)
  * When a cpu is hot-plugged, do a check and initiate
  * cache kobject if necessary
  */
-static int __cpuinit cache_cpu_callback(struct notifier_block *nfb,
+static int cache_cpu_callback(struct notifier_block *nfb,
 		unsigned long action, void *hcpu)
 {
 	unsigned int cpu = (unsigned long)hcpu;
@@ -445,7 +445,7 @@ static int __cpuinit cache_cpu_callback(struct notifier_block *nfb,
 	return NOTIFY_OK;
 }
 
-static struct notifier_block __cpuinitdata cache_cpu_notifier +static struct notifier_block cache_cpu_notifier  {
 	.notifier_call = cache_cpu_callback
 };
diff --git a/arch/ia64/mm/contig.c b/arch/ia64/mm/contig.c
index e4a6a536..da5237d 100644
--- a/arch/ia64/mm/contig.c
+++ b/arch/ia64/mm/contig.c
@@ -156,8 +156,7 @@ static void *cpu_data;
  *
  * Allocate and setup per-cpu data areas.
  */
-void * __cpuinit
-per_cpu_init (void)
+void *per_cpu_init(void)
 {
 	static bool first_time = true;
 	void *cpu0_data = __cpu0_per_cpu;
diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
index 58550b8..2de08f4 100644
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -592,7 +592,7 @@ void __init find_memory(void)
  * find_pernode_space() does most of this already, we just need to set
  * local_per_cpu_offset
  */
-void __cpuinit *per_cpu_init(void)
+void *per_cpu_init(void)
 {
 	int cpu;
 	static int first_time = 1;
diff --git a/arch/ia64/mm/numa.c b/arch/ia64/mm/numa.c
index 4248492..ea21d4c 100644
--- a/arch/ia64/mm/numa.c
+++ b/arch/ia64/mm/numa.c
@@ -86,7 +86,7 @@ int __meminit __early_pfn_to_nid(unsigned long pfn)
 	return -1;
 }
 
-void __cpuinit numa_clear_node(int cpu)
+void numa_clear_node(int cpu)
 {
 	unmap_cpu_from_node(cpu, NUMA_NO_NODE);
 }
diff --git a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
index f82e7b4..53b01b8 100644
--- a/arch/ia64/sn/kernel/setup.c
+++ b/arch/ia64/sn/kernel/setup.c
@@ -192,7 +192,7 @@ void __init early_sn_setup(void)
 }
 
 extern int platform_intr_list[];
-static int __cpuinitdata shub_1_1_found;
+static int shub_1_1_found;
 
 /*
  * sn_check_for_wars
@@ -200,7 +200,7 @@ static int __cpuinitdata shub_1_1_found;
  * Set flag for enabling shub specific wars
  */
 
-static inline int __cpuinit is_shub_1_1(int nasid)
+static inline int is_shub_1_1(int nasid)
 {
 	unsigned long id;
 	int rev;
@@ -212,7 +212,7 @@ static inline int __cpuinit is_shub_1_1(int nasid)
 	return rev <= 2;
 }
 
-static void __cpuinit sn_check_for_wars(void)
+static void sn_check_for_wars(void)
 {
 	int cnode;
 
@@ -558,7 +558,7 @@ static void __init sn_init_pdas(char **cmdline_p)
  * Also sets up a few fields in the nodepda.  Also known as
  * platform_cpu_init() by the ia64 machvec code.
  */
-void __cpuinit sn_cpu_init(void)
+void sn_cpu_init(void)
 {
 	int cpuid;
 	int cpuphyid;
diff --git a/arch/ia64/xen/hypervisor.c b/arch/ia64/xen/hypervisor.c
index 52172ee..fab6252 100644
--- a/arch/ia64/xen/hypervisor.c
+++ b/arch/ia64/xen/hypervisor.c
@@ -74,7 +74,7 @@ void __init xen_setup_vcpu_info_placement(void)
 		xen_vcpu_setup(cpu);
 }
 
-void __cpuinit
+void
 xen_cpu_init(void)
 {
 	xen_smp_intr_init();
-- 
1.8.1.2

