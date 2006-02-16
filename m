From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Date: Thu, 16 Feb 2006 05:12:24 +0000
Subject: Export cpu cache info by sysfs
Message-Id: <1140066744.13438.27.camel@ymzhang-perf.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Zhang, Yanmin <yanmin.zhang@intel.com>

This patch exports cpu cache info which is similar to
/proc/pal/cpuX/cache_info. One important new item is shared_cpu_map.
shared_cpu_map showes the cpu map sharing the cache.

The items (attributes) are:
	level
	type
	coherency_line_size
	stride
	ways_of_associativity
	store_latency
	load_latency
	store_hints
	load_hints
	alias_boundary
	tag_lsb
	tag_msb
	size
	shared_cpu_map
	attributes

The patch is against kernel 2.6.16-rc3.

Signed-off-by: Zhang Yanmin <yanmin.zhang@intel.com>

#diffstat
 arch/ia64/kernel/topology.c |  460 ++++++++++++++++++++++++++++++++++++++++++++
 include/asm-ia64/pal.h      |   28 ++
 2 files changed, 488 insertions(+)

---

diff -Nraup linux-2.6.16-rc3/arch/ia64/kernel/topology.c linux-2.6.16-rc3_fix/arch/ia64/kernel/topology.c
--- linux-2.6.16-rc3/arch/ia64/kernel/topology.c	2006-02-14 16:43:47.000000000 +0800
+++ linux-2.6.16-rc3_fix/arch/ia64/kernel/topology.c	2006-02-17 02:54:01.000000000 +0800
@@ -9,6 +9,8 @@
  * 		2002/08/07 Erich Focht <efocht@ess.nec.de>
  * Populate cpu entries in sysfs for non-numa systems as well
  *  	Intel Corporation - Ashok Raj
+ * 01/05/2006 Zhang, Yanmin
+ *	Populate cpu cache entries in sysfs for cpu cache info
  */
 
 #include <linux/config.h>
@@ -19,6 +21,7 @@
 #include <linux/init.h>
 #include <linux/bootmem.h>
 #include <linux/nodemask.h>
+#include <linux/notifier.h>
 #include <asm/mmzone.h>
 #include <asm/numa.h>
 #include <asm/cpu.h>
@@ -101,3 +104,460 @@ out:
 }
 
 subsys_initcall(topology_init);
+
+
+#ifdef	CONFIG_SYSFS
+
+/*
+ * Export cpu cache information through sysfs
+ */
+
+/*
+ *  A bunch of string array to get pretty printing
+ */
+static const char *cache_types[] = {
+	"",			/* not used */
+	"Instruction",
+	"Data",
+	"Data/Instruction"	/* unified */
+};
+
+static const char *cache_mattrib[]={
+	"WriteThrough",
+	"WriteBack",
+	"",		/* reserved */
+	""		/* reserved */
+};
+
+static const char *cache_st_hints[]={
+	"Temporal, level 1",
+	"Reserved",
+	"Reserved",
+	"Non-temporal, all levels",
+	"Reserved",
+	"Reserved",
+	"Reserved",
+	"Reserved"
+};
+
+static const char *cache_ld_hints[]={
+	"Temporal, level 1",
+	"Non-temporal, level 1",
+	"Reserved",
+	"Non-temporal, all levels",
+	"Reserved",
+	"Reserved",
+	"Reserved",
+	"Reserved"
+};
+
+struct cache_info {
+	pal_cache_config_info_t	cci;
+	cpumask_t shared_cpu_map;
+	int level;
+	int type;
+	struct kobject kobj;
+};
+
+struct cpu_cache_info {
+	struct cache_info *cache_leaves;
+	int	num_cache_leaves;
+	struct kobject kobj;
+};
+
+static struct cpu_cache_info	all_cpu_cache_info[NR_CPUS];
+#define LEAF_KOBJECT_PTR(x,y)    (&all_cpu_cache_info[x].cache_leaves[y])
+
+#ifdef CONFIG_SMP
+static void cache_shared_cpu_map_setup( unsigned int cpu,
+		struct cache_info * this_leaf)
+{
+	pal_cache_shared_info_t	csi;
+	int num_shared, i = 0;
+	unsigned int j;
+
+	if (cpu_data(cpu)->threads_per_core <= 1 &&
+		cpu_data(cpu)->cores_per_socket <= 1) {
+		cpu_set(cpu, this_leaf->shared_cpu_map);
+		return;
+	}
+
+	if (ia64_pal_cache_shared_info(this_leaf->level,
+					this_leaf->type,
+					0,
+					&csi) != PAL_STATUS_SUCCESS)
+		return;
+
+	num_shared = (int) csi.num_shared;
+	do {
+		for_each_cpu(j)
+			if (cpu_data(cpu)->socket_id = cpu_data(j)->socket_id
+				&& cpu_data(j)->core_id = csi.log1_cid
+				&& cpu_data(j)->thread_id = csi.log1_tid)
+				cpu_set(j, this_leaf->shared_cpu_map);
+
+		i++;
+	} while (i < num_shared &&
+		ia64_pal_cache_shared_info(this_leaf->level,
+				this_leaf->type,
+				i,
+				&csi) = PAL_STATUS_SUCCESS);
+}
+#else
+static void cache_shared_cpu_map_setup(unsigned int cpu,
+		struct cache_info * this_leaf)
+{
+	cpu_set(cpu, this_leaf->shared_cpu_map);
+	return;
+}
+#endif
+
+static ssize_t show_coherency_line_size(struct cache_info *this_leaf,
+					char *buf)
+{
+	return sprintf(buf, "%u\n", 1 << this_leaf->cci.pcci_line_size);
+}
+
+static ssize_t show_ways_of_associativity(struct cache_info *this_leaf,
+					char *buf)
+{
+	return sprintf(buf, "%u\n", this_leaf->cci.pcci_assoc);
+}
+
+static ssize_t show_store_latency(struct cache_info *this_leaf, char *buf)
+{
+	return sprintf(buf, "%u cycle(s)\n", this_leaf->cci.pcci_st_latency);
+}
+
+static ssize_t show_load_latency(struct cache_info *this_leaf, char *buf)
+{
+	return sprintf(buf, "%u cycle(s)\n", this_leaf->cci.pcci_ld_latency);
+}
+
+static ssize_t show_store_hints(struct cache_info *this_leaf, char *buf)
+{
+	int k;
+	char *p = buf;
+	u8 st_hints = this_leaf->cci.pcci_st_hints;
+
+	p[0] = '\0';
+	for (k = 0; k < 8; k ++) {
+		if (st_hints & 0x1)
+			p += sprintf(p, "[%s]", cache_st_hints[k]);
+		st_hints >>= 1;
+	}
+	p += sprintf(p, "\n");
+	return p - buf;
+}
+
+static ssize_t show_load_hints(struct cache_info *this_leaf, char *buf)
+{
+	int k;
+	char *p = buf;
+	u8 ld_hints = this_leaf->cci.pcci_ld_hints;
+
+	p[0] = '\0';
+	for(k = 0; k < 8; k ++) {
+		if (ld_hints & 0x1)
+			p += sprintf(p, "[%s]", cache_ld_hints[k]);
+		ld_hints >>= 1;
+	}
+	p += sprintf(p, "\n");
+	return p - buf;
+}
+
+static ssize_t show_alias_boundary(struct cache_info *this_leaf, char *buf)
+{
+	return sprintf(buf, "%d\n", 1 << this_leaf->cci.pcci_alias_boundary);
+}
+
+static ssize_t show_stride(struct cache_info *this_leaf, char *buf)
+{
+	return sprintf(buf, "%d\n", 1 << this_leaf->cci.pcci_stride);
+}
+
+static ssize_t show_attributes(struct cache_info *this_leaf, char *buf)
+{
+	return sprintf(buf,
+			"%s\n",
+			cache_mattrib[this_leaf->cci.pcci_cache_attr]);
+}
+
+static ssize_t show_tag_lsb(struct cache_info *this_leaf, char *buf)
+{
+	return sprintf(buf, "%d\n", this_leaf->cci.pcci_tag_lsb);
+}
+
+static ssize_t show_tag_msb(struct cache_info *this_leaf, char *buf)
+{
+	return sprintf(buf, "%d\n", this_leaf->cci.pcci_tag_msb);
+}
+
+static ssize_t show_size(struct cache_info *this_leaf, char *buf)
+{
+	return sprintf(buf, "%luK\n", this_leaf->cci.pcci_cache_size / 1024);
+}
+
+static ssize_t show_shared_cpu_map(struct cache_info *this_leaf, char *buf)
+{
+	ssize_t	len;
+	cpumask_t shared_cpu_map;
+
+	cpus_and(shared_cpu_map, this_leaf->shared_cpu_map, cpu_online_map);
+	len = cpumask_scnprintf(buf, NR_CPUS+1, shared_cpu_map);
+	len += sprintf(buf+len, "\n");
+	return len;
+}
+
+static ssize_t show_type(struct cache_info *this_leaf, char *buf)
+{
+	int type = this_leaf->type + this_leaf->cci.pcci_unified;
+	return sprintf(buf, "%s\n", cache_types[type]);
+}
+
+static ssize_t show_level(struct cache_info *this_leaf, char *buf)
+{
+	return sprintf(buf, "%u\n", this_leaf->level);
+}
+
+struct cache_attr {
+	struct attribute attr;
+	ssize_t (*show)(struct cache_info *, char *);
+	ssize_t (*store)(struct cache_info *, const char *, size_t count);
+};
+
+#ifdef define_one_ro
+	#undef define_one_ro
+#endif
+#define define_one_ro(_name) \
+	static struct cache_attr _name = \
+__ATTR(_name, 0444, show_##_name, NULL)
+
+define_one_ro(level);
+define_one_ro(type);
+define_one_ro(coherency_line_size);
+define_one_ro(stride);
+define_one_ro(ways_of_associativity);
+define_one_ro(store_latency);
+define_one_ro(load_latency);
+define_one_ro(store_hints);
+define_one_ro(load_hints);
+define_one_ro(alias_boundary);
+define_one_ro(tag_lsb);
+define_one_ro(tag_msb);
+define_one_ro(size);
+define_one_ro(shared_cpu_map);
+define_one_ro(attributes);
+
+static struct attribute * cache_default_attrs[] = {
+	&type.attr,
+	&level.attr,
+	&coherency_line_size.attr,
+	&stride.attr,
+	&ways_of_associativity.attr,
+	&store_latency.attr,
+	&load_latency.attr,
+	&alias_boundary.attr,
+	&tag_lsb.attr,
+	&tag_msb.attr,
+	&attributes.attr,
+	&size.attr,
+	&shared_cpu_map.attr,
+	&store_hints.attr,
+	&load_hints.attr,
+	NULL
+};
+
+#define to_object(k) container_of(k, struct cache_info, kobj)
+#define to_attr(a) container_of(a, struct cache_attr, attr)
+
+static ssize_t cache_show(struct kobject * kobj, struct attribute * attr, char * buf)
+{
+	struct cache_attr *fattr = to_attr(attr);
+	struct cache_info *this_leaf = to_object(kobj);
+	ssize_t ret;
+
+	ret = fattr->show ? fattr->show(this_leaf, buf) : 0;
+	return ret;
+}
+
+static struct sysfs_ops cache_sysfs_ops = {
+	.show   = cache_show
+};
+
+static struct kobj_type cache_ktype = {
+	.sysfs_ops	= &cache_sysfs_ops,
+	.default_attrs	= cache_default_attrs,
+};
+
+static struct kobj_type cache_ktype_percpu_entry = {
+	.sysfs_ops	= &cache_sysfs_ops,
+};
+
+static void __cpuinit cpu_cache_sysfs_exit(unsigned int cpu)
+{
+	if (all_cpu_cache_info[cpu].cache_leaves) {
+		kfree(all_cpu_cache_info[cpu].cache_leaves);
+		all_cpu_cache_info[cpu].cache_leaves = NULL;
+	}
+	all_cpu_cache_info[cpu].num_cache_leaves = 0;
+	memset(&all_cpu_cache_info[cpu].kobj, 0, sizeof(struct kobject));
+
+	return;
+}
+
+static int __cpuinit cpu_cache_sysfs_init(unsigned int cpu)
+{
+	u64 i, levels, unique_caches;
+	pal_cache_config_info_t cci;
+	int j;
+	s64 status;
+	struct cache_info *this_cache;
+	int num_cache_leaves = 0;
+
+	if ((status = ia64_pal_cache_summary(&levels, &unique_caches)) != 0) {
+		printk(KERN_ERR "ia64_pal_cache_summary=%ld\n", status);
+		return -1;
+	}
+
+	this_cache=kzalloc(sizeof(struct cache_info)*unique_caches,
+			GFP_KERNEL);
+	if (this_cache = NULL)
+		return -ENOMEM;
+
+	for (i=0; i < levels; i++) {
+		for (j=2; j >0 ; j--) {
+			if ((status=ia64_pal_cache_config_info(i,j, &cci)) !+					PAL_STATUS_SUCCESS)
+				continue;
+
+			this_cache[num_cache_leaves].cci = cci;
+			this_cache[num_cache_leaves].level = i;
+			this_cache[num_cache_leaves].type = j;
+
+			cache_shared_cpu_map_setup(cpu,
+					&this_cache[num_cache_leaves]);
+			num_cache_leaves ++;
+		}
+	}
+
+	all_cpu_cache_info[cpu].cache_leaves = this_cache;
+	all_cpu_cache_info[cpu].num_cache_leaves = num_cache_leaves;
+
+	memset(&all_cpu_cache_info[cpu].kobj, 0, sizeof(struct kobject));
+
+	return 0;
+}
+
+/* Add cache interface for CPU device */
+static int __cpuinit cache_add_dev(struct sys_device * sys_dev)
+{
+	unsigned int cpu = sys_dev->id;
+	unsigned long i, j;
+	struct cache_info *this_object;
+	int retval = 0;
+	cpumask_t oldmask;
+
+	if (all_cpu_cache_info[cpu].kobj.parent)
+		return 0;
+
+	oldmask = current->cpus_allowed;
+	retval = set_cpus_allowed(current, cpumask_of_cpu(cpu));
+	if (unlikely(retval))
+		return retval;
+
+	retval = cpu_cache_sysfs_init(cpu);
+	set_cpus_allowed(current, oldmask);
+	if (unlikely(retval < 0))
+		return retval;
+
+	all_cpu_cache_info[cpu].kobj.parent = &sys_dev->kobj;
+	kobject_set_name(&all_cpu_cache_info[cpu].kobj, "%s", "cache");
+	all_cpu_cache_info[cpu].kobj.ktype = &cache_ktype_percpu_entry;
+	retval = kobject_register(&all_cpu_cache_info[cpu].kobj);
+
+	for (i = 0; i < all_cpu_cache_info[cpu].num_cache_leaves; i++) {
+		this_object = LEAF_KOBJECT_PTR(cpu,i);
+		this_object->kobj.parent = &all_cpu_cache_info[cpu].kobj;
+		kobject_set_name(&(this_object->kobj), "index%1lu", i);
+		this_object->kobj.ktype = &cache_ktype;
+		retval = kobject_register(&(this_object->kobj));
+		if (unlikely(retval)) {
+			for (j = 0; j < i; j++) {
+				kobject_unregister(
+					&(LEAF_KOBJECT_PTR(cpu,j)->kobj));
+			}
+			kobject_unregister(&all_cpu_cache_info[cpu].kobj);
+			cpu_cache_sysfs_exit(cpu);
+			break;
+		}
+	}
+	return retval;
+}
+
+/* Remove cache interface for CPU device */
+static int __cpuinit cache_remove_dev(struct sys_device * sys_dev)
+{
+	unsigned int cpu = sys_dev->id;
+	unsigned long i;
+
+	for (i = 0; i < all_cpu_cache_info[cpu].num_cache_leaves; i++)
+		kobject_unregister(&(LEAF_KOBJECT_PTR(cpu,i)->kobj));
+
+	if (all_cpu_cache_info[cpu].kobj.parent) {
+		kobject_unregister(&all_cpu_cache_info[cpu].kobj);
+		memset(&all_cpu_cache_info[cpu].kobj,
+			0,
+			sizeof(struct kobject));
+	}
+
+	cpu_cache_sysfs_exit(cpu);
+
+	return 0;
+}
+
+/*
+ * When a cpu is hot-plugged, do a check and initiate
+ * cache kobject if necessary
+ */
+static int __cpuinit cache_cpu_callback(struct notifier_block *nfb,
+		unsigned long action, void *hcpu)
+{
+	unsigned int cpu = (unsigned long)hcpu;
+	struct sys_device *sys_dev;
+
+	sys_dev = get_cpu_sysdev(cpu);
+	switch (action) {
+	case CPU_ONLINE:
+		cache_add_dev(sys_dev);
+		break;
+	case CPU_DEAD:
+		cache_remove_dev(sys_dev);
+		break;
+	}
+	return NOTIFY_OK;
+}
+
+static struct notifier_block cache_cpu_notifier +{
+	.notifier_call = cache_cpu_callback
+};
+
+static int __cpuinit cache_sysfs_init(void)
+{
+	int i;
+
+	for_each_online_cpu(i) {
+		cache_cpu_callback(&cache_cpu_notifier, CPU_ONLINE,
+				(void *)(long)i);
+	}
+
+	register_cpu_notifier(&cache_cpu_notifier);
+
+	return 0;
+}
+
+device_initcall(cache_sysfs_init);
+
+#endif	//CONFIG_SYSFS
+
diff -Nraup linux-2.6.16-rc3/include/asm-ia64/pal.h linux-2.6.16-rc3_fix/include/asm-ia64/pal.h
--- linux-2.6.16-rc3/include/asm-ia64/pal.h	2006-02-14 16:43:50.000000000 +0800
+++ linux-2.6.16-rc3_fix/include/asm-ia64/pal.h	2006-02-17 02:17:42.000000000 +0800
@@ -68,6 +68,7 @@
 #define PAL_SHUTDOWN		40	/* enter processor shutdown state */
 #define PAL_PREFETCH_VISIBILITY	41	/* Make Processor Prefetches Visible */
 #define PAL_LOGICAL_TO_PHYSICAL 42	/* returns information on logical to physical processor mapping */
+#define PAL_CACHE_SHARED_INFO	43	/* returns information on caches shared by logical processor */
 
 #define PAL_COPY_PAL		256	/* relocate PAL procedures and PAL PMI */
 #define PAL_HALT_INFO		257	/* return the low power capabilities of processor */
@@ -1648,6 +1649,33 @@ ia64_pal_logical_to_phys(u64 proc_number
 
 	return iprv.status;
 }
+
+typedef struct pal_cache_shared_info_s
+{
+	u64 num_shared;
+	pal_proc_n_log_info1_t ppli1;
+	pal_proc_n_log_info2_t ppli2;
+} pal_cache_shared_info_t;
+
+/* Get information on logical to physical processor mappings. */
+static inline s64
+ia64_pal_cache_shared_info(u64 level,
+		u64 type,
+		u64 proc_number,
+		pal_cache_shared_info_t *info)
+{
+	struct ia64_pal_retval iprv;
+
+	PAL_CALL(iprv, PAL_CACHE_SHARED_INFO, level, type, proc_number);
+
+	if (iprv.status = PAL_STATUS_SUCCESS) {
+		info->num_shared = iprv.v0;
+		info->ppli1.ppli1_data = iprv.v1;
+		info->ppli2.ppli2_data = iprv.v2;
+	}
+
+	return iprv.status;
+}
 #endif /* __ASSEMBLY__ */
 
 #endif /* _ASM_IA64_PAL_H */


