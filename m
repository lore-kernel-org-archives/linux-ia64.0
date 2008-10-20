From: Mike Travis <travis@sgi.com>
Date: Mon, 20 Oct 2008 17:03:26 +0000
Subject: [PATCH 07/35] cpumask: change cpumask_scnprintf, cpumask_parse_user, cpulist_parse, and cpulist_scnp
Message-Id: <20081020170320.575735000@polaris-admin.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081020170319.539427000@polaris-admin.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>, Rusty Russell <rusty@rustcorp.com.au>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, davej@codemonkey.org.uk, David Miller <davem@davemloft.net>, Eric Dumazet <dada1@cosmosbay.com>, Jack Steiner <steiner@sgi.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Jes Sorensen <jes@sgi.com>, "H. Peter Anvin" <hpa@zytor.com>, peterz@infradead.org, Thomas Gleixner <tglx@linutronix.de>, Yinghai Lu <yhlu.kernel@gmail.com>, IA64 <linux-ia64@vger.kernel.org>, PowerPC <linuxppc-dev@ozlabs.org>, S390 <linux-s390@vger.kernel.org>, SPARC <sparclinux@vger.kernel.org>, linux-kernel@vger.kernel.org

We want to move cpumasks off the stack: no local decls, no passing by
copy.

Most cpumask functions started with cpus_: these have been replaced by
cpumask_ ones which take struct cpumask pointers as expected, and macro
stubs used for the transition.

These four functions don't have good replacement names; fortunately
they're rarely used, so we just change them over.

From: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Mike Travis <travis@sgi.com>
---
 arch/ia64/kernel/topology.c           |    2 +-
 arch/mips/kernel/smp-cmp.c            |    4 ++--
 arch/powerpc/platforms/pseries/xics.c |    2 +-
 arch/x86/kernel/cpu/intel_cacheinfo.c |    4 ++--
 arch/x86/kernel/setup_percpu.c        |    2 +-
 drivers/base/cpu.c                    |    2 +-
 drivers/base/node.c                   |    4 ++--
 drivers/base/topology.c               |    4 ++--
 drivers/pci/pci-sysfs.c               |    4 ++--
 drivers/pci/probe.c                   |    4 ++--
 include/linux/cpumask.h               |   21 +++++++--------------
 kernel/cpuset.c                       |    8 ++++----
 kernel/irq/proc.c                     |    4 ++--
 kernel/profile.c                      |    4 ++--
 kernel/sched.c                        |    4 ++--
 kernel/sched_stats.h                  |    2 +-
 kernel/taskstats.c                    |    2 +-
 kernel/trace/trace.c                  |    4 ++--
 mm/slub.c                             |    2 +-
 19 files changed, 38 insertions(+), 45 deletions(-)

--- test-compile.orig/arch/ia64/kernel/topology.c
+++ test-compile/arch/ia64/kernel/topology.c
@@ -217,7 +217,7 @@ static ssize_t show_shared_cpu_map(struc
 	cpumask_t shared_cpu_map;
 
 	cpus_and(shared_cpu_map, this_leaf->shared_cpu_map, cpu_online_map);
-	len = cpumask_scnprintf(buf, NR_CPUS+1, shared_cpu_map);
+	len = cpumask_scnprintf(buf, NR_CPUS+1, &shared_cpu_map);
 	len += sprintf(buf+len, "\n");
 	return len;
 }
--- test-compile.orig/arch/mips/kernel/smp-cmp.c
+++ test-compile/arch/mips/kernel/smp-cmp.c
@@ -51,10 +51,10 @@ static int __init allowcpus(char *str)
 	int len;
 
 	cpus_clear(cpu_allow_map);
-	if (cpulist_parse(str, cpu_allow_map) = 0) {
+	if (cpulist_parse(str, &cpu_allow_map) = 0) {
 		cpu_set(0, cpu_allow_map);
 		cpus_and(cpu_possible_map, cpu_possible_map, cpu_allow_map);
-		len = cpulist_scnprintf(buf, sizeof(buf)-1, cpu_possible_map);
+		len = cpulist_scnprintf(buf, sizeof(buf)-1, &cpu_possible_map);
 		buf[len] = '\0';
 		pr_debug("Allowable CPUs: %s\n", buf);
 		return 1;
--- test-compile.orig/arch/powerpc/platforms/pseries/xics.c
+++ test-compile/arch/powerpc/platforms/pseries/xics.c
@@ -358,7 +358,7 @@ static void xics_set_affinity(unsigned i
 	irq_server = get_irq_server(virq, 1);
 	if (irq_server = -1) {
 		char cpulist[128];
-		cpumask_scnprintf(cpulist, sizeof(cpulist), cpumask);
+		cpumask_scnprintf(cpulist, sizeof(cpulist), &cpumask);
 		printk(KERN_WARNING
 			"%s: No online cpus in the mask %s for irq %d\n",
 			__func__, cpulist, virq);
--- test-compile.orig/arch/x86/kernel/cpu/intel_cacheinfo.c
+++ test-compile/arch/x86/kernel/cpu/intel_cacheinfo.c
@@ -626,8 +626,8 @@ static ssize_t show_shared_cpu_map_func(
 		cpumask_t *mask = &this_leaf->shared_cpu_map;
 
 		n = type?
-			cpulist_scnprintf(buf, len-2, *mask):
-			cpumask_scnprintf(buf, len-2, *mask);
+			cpulist_scnprintf(buf, len-2, mask) :
+			cpumask_scnprintf(buf, len-2, mask);
 		buf[n++] = '\n';
 		buf[n] = '\0';
 	}
--- test-compile.orig/arch/x86/kernel/setup_percpu.c
+++ test-compile/arch/x86/kernel/setup_percpu.c
@@ -282,7 +282,7 @@ static void __cpuinit numa_set_cpumask(i
 	else
 		cpu_clear(cpu, *mask);
 
-	cpulist_scnprintf(buf, sizeof(buf), *mask);
+	cpulist_scnprintf(buf, sizeof(buf), mask);
 	printk(KERN_DEBUG "%s cpu %d node %d: mask now %s\n",
 		enable? "numa_add_cpu":"numa_remove_cpu", cpu, node, buf);
  }
--- test-compile.orig/drivers/base/cpu.c
+++ test-compile/drivers/base/cpu.c
@@ -109,7 +109,7 @@ static SYSDEV_ATTR(crash_notes, 0400, sh
  */
 static ssize_t print_cpus_map(char *buf, cpumask_t *map)
 {
-	int n = cpulist_scnprintf(buf, PAGE_SIZE-2, *map);
+	int n = cpulist_scnprintf(buf, PAGE_SIZE-2, map);
 
 	buf[n++] = '\n';
 	buf[n] = '\0';
--- test-compile.orig/drivers/base/node.c
+++ test-compile/drivers/base/node.c
@@ -29,8 +29,8 @@ static ssize_t node_read_cpumap(struct s
 	BUILD_BUG_ON((NR_CPUS/32 * 9) > (PAGE_SIZE-1));
 
 	len = type?
-		cpulist_scnprintf(buf, PAGE_SIZE-2, *mask):
-		cpumask_scnprintf(buf, PAGE_SIZE-2, *mask);
+		cpulist_scnprintf(buf, PAGE_SIZE-2, mask) :
+		cpumask_scnprintf(buf, PAGE_SIZE-2, mask);
  	buf[len++] = '\n';
  	buf[len] = '\0';
 	return len;
--- test-compile.orig/drivers/base/topology.c
+++ test-compile/drivers/base/topology.c
@@ -49,8 +49,8 @@ static ssize_t show_cpumap(int type, cpu
 
 	if (len > 1) {
 		n = type?
-			cpulist_scnprintf(buf, len-2, *mask):
-			cpumask_scnprintf(buf, len-2, *mask);
+			cpulist_scnprintf(buf, len-2, mask) :
+			cpumask_scnprintf(buf, len-2, mask);
 		buf[n++] = '\n';
 		buf[n] = '\0';
 	}
--- test-compile.orig/drivers/pci/pci-sysfs.c
+++ test-compile/drivers/pci/pci-sysfs.c
@@ -74,7 +74,7 @@ static ssize_t local_cpus_show(struct de
 	int len;
 
 	mask = pcibus_to_cpumask(to_pci_dev(dev)->bus);
-	len = cpumask_scnprintf(buf, PAGE_SIZE-2, mask);
+	len = cpumask_scnprintf(buf, PAGE_SIZE-2, &mask);
 	buf[len++] = '\n';
 	buf[len] = '\0';
 	return len;
@@ -88,7 +88,7 @@ static ssize_t local_cpulist_show(struct
 	int len;
 
 	mask = pcibus_to_cpumask(to_pci_dev(dev)->bus);
-	len = cpulist_scnprintf(buf, PAGE_SIZE-2, mask);
+	len = cpulist_scnprintf(buf, PAGE_SIZE-2, &mask);
 	buf[len++] = '\n';
 	buf[len] = '\0';
 	return len;
--- test-compile.orig/drivers/pci/probe.c
+++ test-compile/drivers/pci/probe.c
@@ -123,8 +123,8 @@ static ssize_t pci_bus_show_cpuaffinity(
 
 	cpumask = pcibus_to_cpumask(to_pci_bus(dev));
 	ret = type?
-		cpulist_scnprintf(buf, PAGE_SIZE-2, cpumask):
-		cpumask_scnprintf(buf, PAGE_SIZE-2, cpumask);
+		cpulist_scnprintf(buf, PAGE_SIZE-2, &cpumask) :
+		cpumask_scnprintf(buf, PAGE_SIZE-2, &cpumask);
 	buf[ret++] = '\n';
 	buf[ret] = '\0';
 	return ret;
--- test-compile.orig/include/linux/cpumask.h
+++ test-compile/include/linux/cpumask.h
@@ -175,13 +175,6 @@ extern cpumask_t _unused_cpumask_arg_;
 			cpumask_shift_right(&(dst), &(src), (n))
 #define cpus_shift_left(dst, src, n) \
 			cpumask_shift_left(&(dst), &(src), (n))
-#define cpumask_scnprintf(buf, len, src) \
-			__cpumask_scnprintf((buf), (len), &(src))
-#define cpumask_parse_user(ubuf, ulen, dst) \
-			__cpumask_parse_user((ubuf), (ulen), &(dst))
-#define cpulist_scnprintf(buf, len, src) \
-			__cpulist_scnprintf((buf), (len), &(src))
-#define cpulist_parse(buf, dst) __cpulist_parse((buf), &(dst))
 #define cpu_remap(oldbit, old, new) \
 		cpumask_cpuremap((oldbit), &(old), &(new))
 #define cpus_remap(dst, src, old, new) \
@@ -304,25 +297,25 @@ static inline void cpumask_shift_left(st
 	bitmap_shift_left(dstp->bits, srcp->bits, n, NR_CPUS);
 }
 
-static inline int __cpumask_scnprintf(char *buf, int len,
-				      const struct cpumask *srcp)
+static inline int cpumask_scnprintf(char *buf, int len,
+				    const struct cpumask *srcp)
 {
 	return bitmap_scnprintf(buf, len, srcp->bits, NR_CPUS);
 }
 
-static inline int __cpumask_parse_user(const char __user *buf, int len,
-				       struct cpumask *dstp)
+static inline int cpumask_parse_user(const char __user *buf, int len,
+				     struct cpumask *dstp)
 {
 	return bitmap_parse_user(buf, len, dstp->bits, NR_CPUS);
 }
 
-static inline int __cpulist_scnprintf(char *buf, int len,
-				      const struct cpumask *srcp)
+static inline int cpulist_scnprintf(char *buf, int len,
+				    const struct cpumask *srcp)
 {
 	return bitmap_scnlistprintf(buf, len, srcp->bits, NR_CPUS);
 }
 
-static inline int __cpulist_parse(const char *buf, struct cpumask *dstp)
+static inline int cpulist_parse(const char *buf, struct cpumask *dstp)
 {
 	return bitmap_parselist(buf, dstp->bits, NR_CPUS);
 }
--- test-compile.orig/kernel/cpuset.c
+++ test-compile/kernel/cpuset.c
@@ -891,7 +891,7 @@ static int update_cpumask(struct cpuset 
 	if (!*buf) {
 		cpus_clear(trialcs.cpus_allowed);
 	} else {
-		retval = cpulist_parse(buf, trialcs.cpus_allowed);
+		retval = cpulist_parse(buf, &trialcs.cpus_allowed);
 		if (retval < 0)
 			return retval;
 
@@ -1478,7 +1478,7 @@ static int cpuset_sprintf_cpulist(char *
 	mask = cs->cpus_allowed;
 	mutex_unlock(&callback_mutex);
 
-	return cpulist_scnprintf(page, PAGE_SIZE, mask);
+	return cpulist_scnprintf(page, PAGE_SIZE, &mask);
 }
 
 static int cpuset_sprintf_memlist(char *page, struct cpuset *cs)
@@ -2438,11 +2438,11 @@ void cpuset_task_status_allowed(struct s
 {
 	seq_printf(m, "Cpus_allowed:\t");
 	m->count += cpumask_scnprintf(m->buf + m->count, m->size - m->count,
-					task->cpus_allowed);
+					&task->cpus_allowed);
 	seq_printf(m, "\n");
 	seq_printf(m, "Cpus_allowed_list:\t");
 	m->count += cpulist_scnprintf(m->buf + m->count, m->size - m->count,
-					task->cpus_allowed);
+					&task->cpus_allowed);
 	seq_printf(m, "\n");
 	seq_printf(m, "Mems_allowed:\t");
 	m->count += nodemask_scnprintf(m->buf + m->count, m->size - m->count,
--- test-compile.orig/kernel/irq/proc.c
+++ test-compile/kernel/irq/proc.c
@@ -47,7 +47,7 @@ static ssize_t irq_affinity_proc_write(s
 	    irq_balancing_disabled(irq))
 		return -EIO;
 
-	err = cpumask_parse_user(buffer, count, new_value);
+	err = cpumask_parse_user(buffer, count, &new_value);
 	if (err)
 		return err;
 
@@ -95,7 +95,7 @@ static ssize_t default_affinity_write(st
 	cpumask_t new_value;
 	int err;
 
-	err = cpumask_parse_user(buffer, count, new_value);
+	err = cpumask_parse_user(buffer, count, &new_value);
 	if (err)
 		return err;
 
--- test-compile.orig/kernel/profile.c
+++ test-compile/kernel/profile.c
@@ -442,7 +442,7 @@ void profile_tick(int type)
 static int prof_cpu_mask_read_proc(char *page, char **start, off_t off,
 			int count, int *eof, void *data)
 {
-	int len = cpumask_scnprintf(page, count, *(cpumask_t *)data);
+	int len = cpumask_scnprintf(page, count, (cpumask_t *)data);
 	if (count - len < 2)
 		return -EINVAL;
 	len += sprintf(page + len, "\n");
@@ -456,7 +456,7 @@ static int prof_cpu_mask_write_proc(stru
 	unsigned long full_count = count, err;
 	cpumask_t new_value;
 
-	err = cpumask_parse_user(buffer, count, new_value);
+	err = cpumask_parse_user(buffer, count, &new_value);
 	if (err)
 		return err;
 
--- test-compile.orig/kernel/sched.c
+++ test-compile/kernel/sched.c
@@ -6641,7 +6641,7 @@ static int sched_domain_debug_one(struct
 	struct sched_group *group = sd->groups;
 	char str[256];
 
-	cpulist_scnprintf(str, sizeof(str), sd->span);
+	cpulist_scnprintf(str, sizeof(str), &sd->span);
 	cpus_clear(*groupmask);
 
 	printk(KERN_DEBUG "%*s domain %d: ", level, "", level);
@@ -6695,7 +6695,7 @@ static int sched_domain_debug_one(struct
 
 		cpus_or(*groupmask, *groupmask, group->cpumask);
 
-		cpulist_scnprintf(str, sizeof(str), group->cpumask);
+		cpulist_scnprintf(str, sizeof(str), &group->cpumask);
 		printk(KERN_CONT " %s", str);
 
 		group = group->next;
--- test-compile.orig/kernel/sched_stats.h
+++ test-compile/kernel/sched_stats.h
@@ -42,7 +42,7 @@ static int show_schedstat(struct seq_fil
 		for_each_domain(cpu, sd) {
 			enum cpu_idle_type itype;
 
-			cpumask_scnprintf(mask_str, mask_len, sd->span);
+			cpumask_scnprintf(mask_str, mask_len, &sd->span);
 			seq_printf(seq, "domain%d %s", dcount++, mask_str);
 			for (itype = CPU_IDLE; itype < CPU_MAX_IDLE_TYPES;
 					itype++) {
--- test-compile.orig/kernel/taskstats.c
+++ test-compile/kernel/taskstats.c
@@ -352,7 +352,7 @@ static int parse(struct nlattr *na, cpum
 	if (!data)
 		return -ENOMEM;
 	nla_strlcpy(data, na, len);
-	ret = cpulist_parse(data, *mask);
+	ret = cpulist_parse(data, mask);
 	kfree(data);
 	return ret;
 }
--- test-compile.orig/kernel/trace/trace.c
+++ test-compile/kernel/trace/trace.c
@@ -2117,7 +2117,7 @@ tracing_cpumask_read(struct file *filp, 
 
 	mutex_lock(&tracing_cpumask_update_lock);
 
-	len = cpumask_scnprintf(mask_str, count, tracing_cpumask);
+	len = cpumask_scnprintf(mask_str, count, &tracing_cpumask);
 	if (count - len < 2) {
 		count = -EINVAL;
 		goto out_err;
@@ -2138,7 +2138,7 @@ tracing_cpumask_write(struct file *filp,
 	int err, cpu;
 
 	mutex_lock(&tracing_cpumask_update_lock);
-	err = cpumask_parse_user(ubuf, count, tracing_cpumask_new);
+	err = cpumask_parse_user(ubuf, count, &tracing_cpumask_new);
 	if (err)
 		goto err_unlock;
 
--- test-compile.orig/mm/slub.c
+++ test-compile/mm/slub.c
@@ -3637,7 +3637,7 @@ static int list_locations(struct kmem_ca
 				len < PAGE_SIZE - 60) {
 			len += sprintf(buf + len, " cpus=");
 			len += cpulist_scnprintf(buf + len, PAGE_SIZE - len - 50,
-					l->cpus);
+					&l->cpus);
 		}
 
 		if (num_online_nodes() > 1 && !nodes_empty(l->nodes) &&

-- 
