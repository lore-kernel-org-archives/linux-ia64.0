From: Sudeep Holla <sudeep.holla@arm.com>
Date: Mon, 23 Feb 2015 18:04:46 +0000
Subject: [PATCH RFT][RESEND] ia64: move cacheinfo sysfs to generic cacheinfo infrastructure
Message-Id: <1424714687-20262-1-git-send-email-sudeep.holla@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Sudeep Holla <sudeep.holla@arm.com>, linux-ia64@vger.kernel.org

This patch removes the redundant sysfs cacheinfo code by reusing
the newly introduced generic cacheinfo infrastructure through the
commit 246246cbde5e ("drivers: base: support cpu cache information
interface to userspace via sysfs")

Signed-off-by: Sudeep Holla <sudeep.holla@arm.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/kernel/topology.c | 419 ++++++++++++--------------------------------
 1 file changed, 111 insertions(+), 308 deletions(-)

Hi,

I don't have access to any IA64 machine, I would appreciate any testing.
It rebased on v4.0-rc1 this time.

Regards,
Sudeep

diff --git a/arch/ia64/kernel/topology.c b/arch/ia64/kernel/topology.c
index 965ab42fabb0..3d6749cb53ec 100644
--- a/arch/ia64/kernel/topology.c
+++ b/arch/ia64/kernel/topology.c
@@ -13,6 +13,7 @@
  *	Populate cpu cache entries in sysfs for cpu cache info
  */
 
+#include <linux/cacheinfo.h>
 #include <linux/cpu.h>
 #include <linux/kernel.h>
 #include <linux/mm.h>
@@ -21,7 +22,6 @@
 #include <linux/init.h>
 #include <linux/bootmem.h>
 #include <linux/nodemask.h>
-#include <linux/notifier.h>
 #include <linux/export.h>
 #include <asm/mmzone.h>
 #include <asm/numa.h>
@@ -103,60 +103,25 @@ subsys_initcall(topology_init);
 /*
  * Export cpu cache information through sysfs
  */
-
-/*
- *  A bunch of string array to get pretty printing
- */
-static const char *cache_types[] = {
-	"",			/* not used */
-	"Instruction",
-	"Data",
-	"Unified"	/* unified */
-};
-
-static const char *cache_mattrib[]={
-	"WriteThrough",
-	"WriteBack",
-	"",		/* reserved */
-	""		/* reserved */
-};
-
-struct cache_info {
-	pal_cache_config_info_t	cci;
-	cpumask_t shared_cpu_map;
-	int level;
-	int type;
-	struct kobject kobj;
-};
-
-struct cpu_cache_info {
-	struct cache_info *cache_leaves;
-	int	num_cache_leaves;
-	struct kobject kobj;
-};
-
-static struct cpu_cache_info	all_cpu_cache_info[NR_CPUS];
-#define LEAF_KOBJECT_PTR(x,y)    (&all_cpu_cache_info[x].cache_leaves[y])
-
 #ifdef CONFIG_SMP
-static void cache_shared_cpu_map_setup(unsigned int cpu,
-		struct cache_info * this_leaf)
+static int __cache_cpumap_setup(unsigned int cpu, struct cacheinfo *this_leaf)
 {
 	pal_cache_shared_info_t	csi;
-	int num_shared, i = 0;
-	unsigned int j;
+	int num_shared, i = 0, j;
+	enum cache_type type = this_leaf->type;
 
 	if (cpu_data(cpu)->threads_per_core <= 1 &&
 		cpu_data(cpu)->cores_per_socket <= 1) {
 		cpu_set(cpu, this_leaf->shared_cpu_map);
-		return;
+		return 0;
 	}
 
-	if (ia64_pal_cache_shared_info(this_leaf->level,
-					this_leaf->type,
-					0,
-					&csi) != PAL_STATUS_SUCCESS)
-		return;
+	if (type = CACHE_TYPE_UNIFIED)
+		type = CACHE_TYPE_DATA;
+
+	if (ia64_pal_cache_shared_info(this_leaf->level, type, 0,
+				       &csi) != PAL_STATUS_SUCCESS)
+		return -EIO;
 
 	num_shared = (int) csi.num_shared;
 	do {
@@ -168,303 +133,141 @@ static void cache_shared_cpu_map_setup(unsigned int cpu,
 
 		i++;
 	} while (i < num_shared &&
-		ia64_pal_cache_shared_info(this_leaf->level,
-				this_leaf->type,
-				i,
-				&csi) = PAL_STATUS_SUCCESS);
-}
-#else
-static void cache_shared_cpu_map_setup(unsigned int cpu,
-		struct cache_info * this_leaf)
-{
-	cpu_set(cpu, this_leaf->shared_cpu_map);
-	return;
-}
-#endif
-
-static ssize_t show_coherency_line_size(struct cache_info *this_leaf,
-					char *buf)
-{
-	return sprintf(buf, "%u\n", 1 << this_leaf->cci.pcci_line_size);
+		 ia64_pal_cache_shared_info(this_leaf->level, type, i,
+					    &csi) = PAL_STATUS_SUCCESS);
+	return 0;
 }
 
-static ssize_t show_ways_of_associativity(struct cache_info *this_leaf,
-					char *buf)
+static int cache_shared_cpu_map_setup(unsigned int cpu)
 {
-	return sprintf(buf, "%u\n", this_leaf->cci.pcci_assoc);
+	unsigned int idx;
+	int ret = 0;
+	struct cpu_cacheinfo *this_cpu_ci = get_cpu_cacheinfo(cpu);
+	struct cacheinfo *this_leaf = this_cpu_ci->info_list;
+
+	for (idx = 0; idx < this_cpu_ci->num_leaves; idx++, this_leaf++) {
+		ret = __cache_cpumap_setup(cpu, this_leaf);
+		if (ret)
+			break;
+	}
+	return ret;
 }
-
-static ssize_t show_attributes(struct cache_info *this_leaf, char *buf)
+#else
+static int cache_shared_cpu_map_setup(unsigned int cpu)
 {
-	return sprintf(buf,
-			"%s\n",
-			cache_mattrib[this_leaf->cci.pcci_cache_attr]);
-}
+	int idx;
+	struct cpu_cacheinfo *this_cpu_ci = get_cpu_cacheinfo(cpu);
+	struct cacheinfo *this_leaf = this_cpu_ci->info_list;
 
-static ssize_t show_size(struct cache_info *this_leaf, char *buf)
-{
-	return sprintf(buf, "%uK\n", this_leaf->cci.pcci_cache_size / 1024);
+	for (idx = 0; idx < this_cpu_ci->num_leaves; idx++, this_leaf++)
+		cpu_set(cpu, this_leaf->shared_cpu_map);
+	return 0;
 }
+#endif
 
-static ssize_t show_number_of_sets(struct cache_info *this_leaf, char *buf)
+static ssize_t attributes_show(struct device *dev,
+			       struct device_attribute *attr, char *buf)
 {
-	unsigned number_of_sets = this_leaf->cci.pcci_cache_size;
-	number_of_sets /= this_leaf->cci.pcci_assoc;
-	number_of_sets /= 1 << this_leaf->cci.pcci_line_size;
-
-	return sprintf(buf, "%u\n", number_of_sets);
+	struct cacheinfo *this_leaf = dev_get_drvdata(dev);
+	unsigned int ci_attr = this_leaf->attributes;
+	int n = 0;
+
+	if (ci_attr & CACHE_WRITE_THROUGH)
+		n = sprintf(buf, "WriteThrough\n");
+	else if (ci_attr & CACHE_WRITE_BACK)
+		n = sprintf(buf, "WriteBack\n");
+	return n;
 }
 
-static ssize_t show_shared_cpu_map(struct cache_info *this_leaf, char *buf)
-{
-	cpumask_t shared_cpu_map;
-
-	cpumask_and(&shared_cpu_map,
-				&this_leaf->shared_cpu_map, cpu_online_mask);
-	return scnprintf(buf, PAGE_SIZE, "%*pb\n",
-			 cpumask_pr_args(&shared_cpu_map));
-}
+static DEVICE_ATTR_RO(attributes);
 
-static ssize_t show_type(struct cache_info *this_leaf, char *buf)
+static umode_t
+cache_private_attrs_is_visible(struct kobject *kobj,
+			       struct attribute *attr, int unused)
 {
-	int type = this_leaf->type + this_leaf->cci.pcci_unified;
-	return sprintf(buf, "%s\n", cache_types[type]);
-}
+	struct device *dev = kobj_to_dev(kobj);
+	struct cacheinfo *this_leaf = dev_get_drvdata(dev);
 
-static ssize_t show_level(struct cache_info *this_leaf, char *buf)
-{
-	return sprintf(buf, "%u\n", this_leaf->level);
+	if ((attr = &dev_attr_attributes.attr) && this_leaf->attributes)
+		return attr->mode;
+	return 0;
 }
 
-struct cache_attr {
-	struct attribute attr;
-	ssize_t (*show)(struct cache_info *, char *);
-	ssize_t (*store)(struct cache_info *, const char *, size_t count);
-};
-
-#ifdef define_one_ro
-	#undef define_one_ro
-#endif
-#define define_one_ro(_name) \
-	static struct cache_attr _name = \
-__ATTR(_name, 0444, show_##_name, NULL)
-
-define_one_ro(level);
-define_one_ro(type);
-define_one_ro(coherency_line_size);
-define_one_ro(ways_of_associativity);
-define_one_ro(size);
-define_one_ro(number_of_sets);
-define_one_ro(shared_cpu_map);
-define_one_ro(attributes);
-
-static struct attribute * cache_default_attrs[] = {
-	&type.attr,
-	&level.attr,
-	&coherency_line_size.attr,
-	&ways_of_associativity.attr,
-	&attributes.attr,
-	&size.attr,
-	&number_of_sets.attr,
-	&shared_cpu_map.attr,
+static struct attribute *cache_priv_attrs[] = {
+	&dev_attr_attributes.attr,
 	NULL
 };
 
-#define to_object(k) container_of(k, struct cache_info, kobj)
-#define to_attr(a) container_of(a, struct cache_attr, attr)
-
-static ssize_t ia64_cache_show(struct kobject * kobj, struct attribute * attr, char * buf)
-{
-	struct cache_attr *fattr = to_attr(attr);
-	struct cache_info *this_leaf = to_object(kobj);
-	ssize_t ret;
-
-	ret = fattr->show ? fattr->show(this_leaf, buf) : 0;
-	return ret;
-}
-
-static const struct sysfs_ops cache_sysfs_ops = {
-	.show   = ia64_cache_show
-};
-
-static struct kobj_type cache_ktype = {
-	.sysfs_ops	= &cache_sysfs_ops,
-	.default_attrs	= cache_default_attrs,
-};
-
-static struct kobj_type cache_ktype_percpu_entry = {
-	.sysfs_ops	= &cache_sysfs_ops,
+static struct attribute_group cache_private_group = {
+	.attrs = cache_priv_attrs,
+	.is_visible = cache_private_attrs_is_visible,
 };
 
-static void cpu_cache_sysfs_exit(unsigned int cpu)
+const struct attribute_group *
+cache_get_priv_group(struct cacheinfo *this_leaf)
 {
-	kfree(all_cpu_cache_info[cpu].cache_leaves);
-	all_cpu_cache_info[cpu].cache_leaves = NULL;
-	all_cpu_cache_info[cpu].num_cache_leaves = 0;
-	memset(&all_cpu_cache_info[cpu].kobj, 0, sizeof(struct kobject));
-	return;
+	return &cache_private_group;
 }
 
-static int cpu_cache_sysfs_init(unsigned int cpu)
+static void ci_leaf_init(struct cacheinfo *this_leaf,
+			 pal_cache_config_info_t *cci,
+			 enum cache_type type, unsigned int level)
 {
-	unsigned long i, levels, unique_caches;
-	pal_cache_config_info_t cci;
-	int j;
-	long status;
-	struct cache_info *this_cache;
-	int num_cache_leaves = 0;
-
-	if ((status = ia64_pal_cache_summary(&levels, &unique_caches)) != 0) {
-		printk(KERN_ERR "ia64_pal_cache_summary=%ld\n", status);
-		return -1;
-	}
-
-	this_cache=kzalloc(sizeof(struct cache_info)*unique_caches,
-			GFP_KERNEL);
-	if (this_cache = NULL)
-		return -ENOMEM;
-
-	for (i=0; i < levels; i++) {
-		for (j=2; j >0 ; j--) {
-			if ((status=ia64_pal_cache_config_info(i,j, &cci)) !-					PAL_STATUS_SUCCESS)
-				continue;
-
-			this_cache[num_cache_leaves].cci = cci;
-			this_cache[num_cache_leaves].level = i + 1;
-			this_cache[num_cache_leaves].type = j;
-
-			cache_shared_cpu_map_setup(cpu,
-					&this_cache[num_cache_leaves]);
-			num_cache_leaves ++;
-		}
-	}
-
-	all_cpu_cache_info[cpu].cache_leaves = this_cache;
-	all_cpu_cache_info[cpu].num_cache_leaves = num_cache_leaves;
-
-	memset(&all_cpu_cache_info[cpu].kobj, 0, sizeof(struct kobject));
-
-	return 0;
+	unsigned number_of_sets = cci->pcci_cache_size;
+
+	number_of_sets /= cci->pcci_assoc;
+	number_of_sets /= 1 << cci->pcci_line_size;
+	this_leaf->level = level;
+	this_leaf->type = cci->pcci_unified ? CACHE_TYPE_UNIFIED : type;
+	this_leaf->coherency_line_size = cci->pcci_line_size;
+	this_leaf->ways_of_associativity = cci->pcci_assoc;
+	this_leaf->size = cci->pcci_cache_size;
+	this_leaf->attributes = cci->pcci_cache_attr;
+	this_leaf->number_of_sets = number_of_sets;
 }
 
-/* Add cache interface for CPU device */
-static int cache_add_dev(struct device *sys_dev)
+int init_cache_level(unsigned int cpu)
 {
-	unsigned int cpu = sys_dev->id;
-	unsigned long i, j;
-	struct cache_info *this_object;
-	int retval = 0;
-	cpumask_t oldmask;
-
-	if (all_cpu_cache_info[cpu].kobj.parent)
-		return 0;
-
-	oldmask = current->cpus_allowed;
-	retval = set_cpus_allowed_ptr(current, cpumask_of(cpu));
-	if (unlikely(retval))
-		return retval;
-
-	retval = cpu_cache_sysfs_init(cpu);
-	set_cpus_allowed_ptr(current, &oldmask);
-	if (unlikely(retval < 0))
-		return retval;
-
-	retval = kobject_init_and_add(&all_cpu_cache_info[cpu].kobj,
-				      &cache_ktype_percpu_entry, &sys_dev->kobj,
-				      "%s", "cache");
-	if (unlikely(retval < 0)) {
-		cpu_cache_sysfs_exit(cpu);
-		return retval;
-	}
-
-	for (i = 0; i < all_cpu_cache_info[cpu].num_cache_leaves; i++) {
-		this_object = LEAF_KOBJECT_PTR(cpu,i);
-		retval = kobject_init_and_add(&(this_object->kobj),
-					      &cache_ktype,
-					      &all_cpu_cache_info[cpu].kobj,
-					      "index%1lu", i);
-		if (unlikely(retval)) {
-			for (j = 0; j < i; j++) {
-				kobject_put(&(LEAF_KOBJECT_PTR(cpu,j)->kobj));
-			}
-			kobject_put(&all_cpu_cache_info[cpu].kobj);
-			cpu_cache_sysfs_exit(cpu);
-			return retval;
-		}
-		kobject_uevent(&(this_object->kobj), KOBJ_ADD);
-	}
-	kobject_uevent(&all_cpu_cache_info[cpu].kobj, KOBJ_ADD);
-	return retval;
-}
-
-/* Remove cache interface for CPU device */
-static int cache_remove_dev(struct device *sys_dev)
-{
-	unsigned int cpu = sys_dev->id;
-	unsigned long i;
+	struct cpu_cacheinfo *this_cpu_ci = get_cpu_cacheinfo(cpu);
+	unsigned long levels, unique_caches;
+	long status;
 
-	for (i = 0; i < all_cpu_cache_info[cpu].num_cache_leaves; i++)
-		kobject_put(&(LEAF_KOBJECT_PTR(cpu,i)->kobj));
+	if (!this_cpu_ci)
+		return -EINVAL;
 
-	if (all_cpu_cache_info[cpu].kobj.parent) {
-		kobject_put(&all_cpu_cache_info[cpu].kobj);
-		memset(&all_cpu_cache_info[cpu].kobj,
-			0,
-			sizeof(struct kobject));
+	status = ia64_pal_cache_summary(&levels, &unique_caches);
+	if (status != PAL_STATUS_SUCCESS) {
+		pr_err("ia64_pal_cache_summary = %ld\n", status);
+		return -EIO;
 	}
-
-	cpu_cache_sysfs_exit(cpu);
+	this_cpu_ci->num_levels = levels;
+	this_cpu_ci->num_leaves = unique_caches;
 
 	return 0;
 }
 
-/*
- * When a cpu is hot-plugged, do a check and initiate
- * cache kobject if necessary
- */
-static int cache_cpu_callback(struct notifier_block *nfb,
-		unsigned long action, void *hcpu)
-{
-	unsigned int cpu = (unsigned long)hcpu;
-	struct device *sys_dev;
-
-	sys_dev = get_cpu_device(cpu);
-	switch (action) {
-	case CPU_ONLINE:
-	case CPU_ONLINE_FROZEN:
-		cache_add_dev(sys_dev);
-		break;
-	case CPU_DEAD:
-	case CPU_DEAD_FROZEN:
-		cache_remove_dev(sys_dev);
-		break;
-	}
-	return NOTIFY_OK;
-}
-
-static struct notifier_block cache_cpu_notifier -{
-	.notifier_call = cache_cpu_callback
-};
-
-static int __init cache_sysfs_init(void)
+int populate_cache_leaves(unsigned int cpu)
 {
-	int i;
-
-	cpu_notifier_register_begin();
-
-	for_each_online_cpu(i) {
-		struct device *sys_dev = get_cpu_device((unsigned int)i);
-		cache_add_dev(sys_dev);
+	unsigned int level, idx;
+	s64 status;
+	pal_cache_config_info_t cci;
+	enum cache_type type;
+	struct cpu_cacheinfo *this_cpu_ci = get_cpu_cacheinfo(cpu);
+	struct cacheinfo *this_leaf = this_cpu_ci->info_list;
+
+	for (idx = 0, level = 1; level <= this_cpu_ci->num_levels &&
+	     idx < this_cpu_ci->num_leaves; idx++, level++) {
+		if (!this_leaf)
+			return -EINVAL;
+
+		type = CACHE_TYPE_INST;
+		status = ia64_pal_cache_config_info(level - 1, type, &cci);
+		if (status = PAL_STATUS_SUCCESS)
+			ci_leaf_init(this_leaf++, &cci, type, level);
+		type = CACHE_TYPE_DATA;
+		status = ia64_pal_cache_config_info(level - 1, type, &cci);
+		if (status = PAL_STATUS_SUCCESS)
+			ci_leaf_init(this_leaf++, &cci, type, level);
 	}
-
-	__register_hotcpu_notifier(&cache_cpu_notifier);
-
-	cpu_notifier_register_done();
-
-	return 0;
+	return cache_shared_cpu_map_setup(cpu);
 }
-
-device_initcall(cache_sysfs_init);
-
-- 
1.9.1

