From: Sudeep Holla <sudeep.holla@arm.com>
Date: Fri, 07 Feb 2014 16:49:17 +0000
Subject: [PATCH RFC/RFT v2 2/8] ia64: move cacheinfo sysfs to generic cacheinfo infrastructure
Message-Id: <1391791763-28518-3-git-send-email-sudeep.holla@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1391791763-28518-1-git-send-email-sudeep.holla@arm.com>
In-Reply-To: <1391791763-28518-1-git-send-email-sudeep.holla@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: sudeep.holla@arm.com, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

From: Sudeep Holla <sudeep.holla@arm.com>

This patch removes the redundant sysfs cacheinfo code by making use of
the newly introduced generic cacheinfo infrastructure.

Signed-off-by: Sudeep Holla <sudeep.holla@arm.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/kernel/topology.c | 399 +++++++++-----------------------------------
 1 file changed, 79 insertions(+), 320 deletions(-)

diff --git a/arch/ia64/kernel/topology.c b/arch/ia64/kernel/topology.c
index ca69a5a..78cdeda 100644
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
+static int __cache_cpumap_setup(unsigned int cpu, struct cache_info *this_leaf)
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
@@ -168,301 +133,95 @@ static void cache_shared_cpu_map_setup(unsigned int cpu,
 
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
-}
-
-static ssize_t show_ways_of_associativity(struct cache_info *this_leaf,
-					char *buf)
-{
-	return sprintf(buf, "%u\n", this_leaf->cci.pcci_assoc);
-}
-
-static ssize_t show_attributes(struct cache_info *this_leaf, char *buf)
-{
-	return sprintf(buf,
-			"%s\n",
-			cache_mattrib[this_leaf->cci.pcci_cache_attr]);
-}
-
-static ssize_t show_size(struct cache_info *this_leaf, char *buf)
-{
-	return sprintf(buf, "%uK\n", this_leaf->cci.pcci_cache_size / 1024);
-}
-
-static ssize_t show_number_of_sets(struct cache_info *this_leaf, char *buf)
-{
-	unsigned number_of_sets = this_leaf->cci.pcci_cache_size;
-	number_of_sets /= this_leaf->cci.pcci_assoc;
-	number_of_sets /= 1 << this_leaf->cci.pcci_line_size;
-
-	return sprintf(buf, "%u\n", number_of_sets);
-}
-
-static ssize_t show_shared_cpu_map(struct cache_info *this_leaf, char *buf)
-{
-	ssize_t	len;
-	cpumask_t shared_cpu_map;
-
-	cpumask_and(&shared_cpu_map,
-				&this_leaf->shared_cpu_map, cpu_online_mask);
-	len = cpumask_scnprintf(buf, NR_CPUS+1, &shared_cpu_map);
-	len += sprintf(buf+len, "\n");
-	return len;
-}
-
-static ssize_t show_type(struct cache_info *this_leaf, char *buf)
-{
-	int type = this_leaf->type + this_leaf->cci.pcci_unified;
-	return sprintf(buf, "%s\n", cache_types[type]);
-}
-
-static ssize_t show_level(struct cache_info *this_leaf, char *buf)
-{
-	return sprintf(buf, "%u\n", this_leaf->level);
+		 ia64_pal_cache_shared_info(this_leaf->level, type, i,
+					    &csi) = PAL_STATUS_SUCCESS);
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
-	NULL
-};
-
-#define to_object(k) container_of(k, struct cache_info, kobj)
-#define to_attr(a) container_of(a, struct cache_attr, attr)
-
-static ssize_t ia64_cache_show(struct kobject * kobj, struct attribute * attr, char * buf)
+static int cache_shared_cpu_map_setup(unsigned int cpu)
 {
-	struct cache_attr *fattr = to_attr(attr);
-	struct cache_info *this_leaf = to_object(kobj);
-	ssize_t ret;
-
-	ret = fattr->show ? fattr->show(this_leaf, buf) : 0;
+	unsigned int idx;
+	int ret = 0;
+	struct cpu_cacheinfo *this_cpu_ci = get_cpu_cacheinfo(cpu);
+	struct cache_info *this_leaf = this_cpu_ci->info_list;
+	for (idx = 0; idx < this_cpu_ci->num_leaves; idx++, this_leaf++) {
+		ret = __cache_cpumap_setup(cpu, this_leaf);
+		if (ret)
+			break;
+	}
 	return ret;
 }
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
-};
-
-static void cpu_cache_sysfs_exit(unsigned int cpu)
-{
-	kfree(all_cpu_cache_info[cpu].cache_leaves);
-	all_cpu_cache_info[cpu].cache_leaves = NULL;
-	all_cpu_cache_info[cpu].num_cache_leaves = 0;
-	memset(&all_cpu_cache_info[cpu].kobj, 0, sizeof(struct kobject));
-	return;
-}
-
-static int cpu_cache_sysfs_init(unsigned int cpu)
+#else
+static int cache_shared_cpu_map_setup(unsigned int cpu)
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
+	int idx;
+	struct cpu_cacheinfo *this_cpu_ci = get_cpu_cacheinfo(cpu);
+	struct cache_info *this_leaf = this_cpu_ci->info_list;
+	for (idx = 0; idx < this_cpu_ci->num_leaves; idx++, this_leaf++)
+		cpu_set(cpu, this_leaf->shared_cpu_map);
 	return 0;
 }
+#endif
 
-/* Add cache interface for CPU device */
-static int cache_add_dev(struct device *sys_dev)
+static void ci_leaf_init(struct cache_info *this_leaf,
+			 pal_cache_config_info_t *cci,
+			 enum cache_type type, unsigned int level)
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
+	unsigned number_of_sets = cci->pcci_cache_size;
+	number_of_sets /= cci->pcci_assoc;
+	number_of_sets /= 1 << cci->pcci_line_size;
 
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
+	this_leaf->level = level;
+	this_leaf->type = cci->pcci_unified ? CACHE_TYPE_UNIFIED : type;
+	this_leaf->coherency_line_size = cci->pcci_line_size;
+	this_leaf->ways_of_associativity = cci->pcci_assoc;
+	this_leaf->size = cci->pcci_cache_size;
+	this_leaf->attributes = cci->pcci_cache_attr;
+	this_leaf->number_of_sets = number_of_sets;
 }
 
-/* Remove cache interface for CPU device */
-static int cache_remove_dev(struct device *sys_dev)
+int init_cache_level(unsigned int cpu)
 {
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
-static struct notifier_block cache_cpu_notifier +int populate_cache_leaves(unsigned int cpu)
 {
-	.notifier_call = cache_cpu_callback
-};
-
-static int __init cache_sysfs_init(void)
-{
-	int i;
-
-	for_each_online_cpu(i) {
-		struct device *sys_dev = get_cpu_device((unsigned int)i);
-		cache_add_dev(sys_dev);
+	unsigned int level, idx;
+	s64 status;
+	pal_cache_config_info_t cci;
+	enum cache_type type;
+	struct cpu_cacheinfo *this_cpu_ci = get_cpu_cacheinfo(cpu);
+	struct cache_info *this_leaf = this_cpu_ci->info_list;
+
+	for (idx = 0, level = 1; level <= this_cpu_ci->num_levels &&
+			idx < this_cpu_ci->num_leaves; idx++, level++) {
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
-	register_hotcpu_notifier(&cache_cpu_notifier);
-
-	return 0;
+	return cache_shared_cpu_map_setup(cpu);
 }
-
-device_initcall(cache_sysfs_init);
-
-- 
1.8.3.2

