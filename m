From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Date: Fri, 24 Feb 2006 08:56:13 +0000
Subject: RE: Export cpu cache info by sysfs
Message-Id: <1140771373.15670.19.camel@ymzhang-perf.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1140066744.13438.27.camel@ymzhang-perf.sh.intel.com>
In-Reply-To: <1140066744.13438.27.camel@ymzhang-perf.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2006-02-24 at 10:19, Zhang, Yanmin wrote:
> On Fri, 2006-02-24 at 04:17, Luck, Tony wrote:
> > > This patch exports cpu cache info which is similar to
> > > /proc/pal/cpuX/cache_info.
> > 
> > But is it similar to what i386/x86_64/anyone-else has already
> > done?
> Yes. The one on i386/x86_64 has attributes:
> 1) level
> 2) type
> 3) coherency_line_size
> 4) ways_of_associativity
> 5) size
> 6) shared_cpu_map
> 7) physical_line_partition
> 8) number_of_sets
> 
> My patch doesn't have the last 2 attributes, but it has other 9
> attributes.
> 
> > 
> > > One important new item is shared_cpu_map.
> > > shared_cpu_map showes the cpu map sharing the cache.
> > 
> > Looks like this could be useful for applications that want to
> > pin tasks to specific cpus (or set of cpus).
> > 
> > Some of the attributes print in a somewhat unsysfs way ... e.g.
> > do we really need " cycle(s)" after the load_latency and store_latency
> > value (could it ever be anything else?).  Similarly "load_hints" and
> > "store_hints" look unnecessarily complex for a program to parse.
> > Printing sizes as 16K, 256K etc. is also good for human readability
> > but worse for programs to parse.
> On i386/x86_64, size also has 'K' and type is also a string. Perhaps
> I could delete some attibutes, such like 
> load_hints/store_hints/tag_lsb/tag_msb/alias_boundary/stride,
> and delete 'cycle(s)' from the output of store_latency/load_latency?
> 
> 
> 
> > 
> > Finally, I count 65 new nodes in /sys per cpu on my 4-way Madison
> > box (the "cache" directory, "index0" .. "index3", and then 15 attributes
> > per cache level).
From sysfs implementation point of view, attribute couldn't be counted as
node, so there is 5 nodes per cpu on your 4-way Madison box.



>   So when SGI start making use of the CONFIG_NR_CPUS24
> > that we recently added, they can look forward to 66560[1] more nodes
So there would be 5*1024 nodes on SGI machine.


> > in /sys ... is this the best way to export this information?  Do we
> > really need to add all of these to the user-kernel API (see long
> > discussion thread on LKML about how you can't change this once you
> > add it).
Should we keep ia64 consistent with i386/x86_64? i386/x86_64 already exports
cache info by the same approach.


> It's a problem. It could be mitigated by deleting some attributes,
> but couldn't be resolved thoroughly.
I deleted 7 attributes which also save some spaces.


> > 
> > [1] Actually it will be worse than this as Montecito has split I&D
> > cache at the mid-level instead of combined, so there will be five
> > "index" directories and a total of 81 nodes/cpu => 82944 total.
If don't count attributes, there would be 6 nodes/cpu => 6*1024 total on Montecito.


Bebow new patch exports 8 attributes:
1) level
2) type
3) coherency_line_size
4) ways_of_associativity
5) size
6) shared_cpu_map
7) stride
8) attributes

Signed-off-by: Zhang Yanmin <yanmin.zhang@intel.com>

---

diff -Nraup linux-2.6.16-rc4/arch/ia64/kernel/topology.c linux-2.6.16-rc4_fix/arch/ia64/kernel/topology.c
--- linux-2.6.16-rc4/arch/ia64/kernel/topology.c	2006-02-18 03:53:15.000000000 +0800
+++ linux-2.6.16-rc4_fix/arch/ia64/kernel/topology.c	2006-02-18 04:02:48.000000000 +0800
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
@@ -101,3 +104,367 @@ out:
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
+	&attributes.attr,
+	&size.attr,
+	&shared_cpu_map.attr,
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
diff -Nraup linux-2.6.16-rc4/include/asm-ia64/pal.h linux-2.6.16-rc4_fix/include/asm-ia64/pal.h
--- linux-2.6.16-rc4/include/asm-ia64/pal.h	2006-02-18 03:53:14.000000000 +0800
+++ linux-2.6.16-rc4_fix/include/asm-ia64/pal.h	2006-02-18 03:55:00.000000000 +0800
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


