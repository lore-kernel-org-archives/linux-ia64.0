From: Hanjun Guo <guohanjun@huawei.com>
Date: Wed, 10 Apr 2013 10:22:59 +0000
Subject: [PATCH 2/4] cpufreq: Fix sysfs deadlock with concurrent hotplug/frequency switch
Message-Id: <1365589381-5624-3-git-send-email-guohanjun@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1365589381-5624-1-git-send-email-guohanjun@huawei.com>
In-Reply-To: <1365589381-5624-1-git-send-email-guohanjun@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kernel.openeuler@huawei.com
Cc: Toshi Kani <toshi.kani@hp.com>, Jiang Liu <jiang.liu@huawei.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

From: Stephen Boyd <sboyd@codeaurora.org>

mainline inclusion
from mainline-3.6
upstream commit a9144436271583115a2230db15d0b6ae2c481d3c
category: bugfix

As cpu offline/online and DVFS will be used in the actual
production environment, this patch is worth to be backported.

--------------------------------------------------------

Running one program that continuously hotplugs and replugs a cpu
concurrently with another program that continuously writes to the
scaling_setspeed node eventually deadlocks with:

======================[ INFO: possible recursive locking detected ]
3.4.0 #37 Tainted: G        W
---------------------------------------------
filemonkey/122 is trying to acquire lock:
 (s_active#13){++++.+}, at: [<c01a3d28>] sysfs_remove_dir+0x9c/0xb4

but task is already holding lock:
 (s_active#13){++++.+}, at: [<c01a22f0>] sysfs_write_file+0xe8/0x140

other info that might help us debug this:
 Possible unsafe locking scenario:

       CPU0
       ----
  lock(s_active#13);
  lock(s_active#13);

 *** DEADLOCK ***

 May be due to missing lock nesting notation

2 locks held by filemonkey/122:
 #0:  (&buffer->mutex){+.+.+.}, at: [<c01a2230>] sysfs_write_file+0x28/0x140
 #1:  (s_active#13){++++.+}, at: [<c01a22f0>] sysfs_write_file+0xe8/0x140

stack backtrace:
[<c0014fcc>] (unwind_backtrace+0x0/0x120) from [<c00ca600>] (validate_chain+0x6f8/0x1054)
[<c00ca600>] (validate_chain+0x6f8/0x1054) from [<c00cb778>] (__lock_acquire+0x81c/0x8d8)
[<c00cb778>] (__lock_acquire+0x81c/0x8d8) from [<c00cb9c0>] (lock_acquire+0x18c/0x1e8)
[<c00cb9c0>] (lock_acquire+0x18c/0x1e8) from [<c01a3ba8>] (sysfs_addrm_finish+0xd0/0x180)
[<c01a3ba8>] (sysfs_addrm_finish+0xd0/0x180) from [<c01a3d28>] (sysfs_remove_dir+0x9c/0xb4)
[<c01a3d28>] (sysfs_remove_dir+0x9c/0xb4) from [<c02d0e5c>] (kobject_del+0x10/0x38)
[<c02d0e5c>] (kobject_del+0x10/0x38) from [<c02d0f74>] (kobject_release+0xf0/0x194)
[<c02d0f74>] (kobject_release+0xf0/0x194) from [<c0565a98>] (cpufreq_cpu_put+0xc/0x24)
[<c0565a98>] (cpufreq_cpu_put+0xc/0x24) from [<c05683f0>] (store+0x6c/0x74)
[<c05683f0>] (store+0x6c/0x74) from [<c01a2314>] (sysfs_write_file+0x10c/0x140)
[<c01a2314>] (sysfs_write_file+0x10c/0x140) from [<c014af44>] (vfs_write+0xb0/0x128)
[<c014af44>] (vfs_write+0xb0/0x128) from [<c014b06c>] (sys_write+0x3c/0x68)
[<c014b06c>] (sys_write+0x3c/0x68) from [<c000e0e0>] (ret_fast_syscall+0x0/0x3c)

This is because store() in cpufreq.c indirectly calls
kobject_get() via cpufreq_cpu_get() and is the last one to call
kobject_put() via cpufreq_cpu_put(). Sysfs code should not call
kobject_get() or kobject_put() directly (see the comment around
sysfs_schedule_callback() for more information).

Fix this deadlock by introducing two new functions:

	struct cpufreq_policy *cpufreq_cpu_get_sysfs(unsigned int cpu)
	void cpufreq_cpu_put_sysfs(struct cpufreq_policy *data)

which do the same thing as cpufreq_cpu_{get,put}() but don't call
kobject functions.

To easily trigger this deadlock you can insert an msleep() with a
reasonably large value right after the fail label at the bottom
of the store() function in cpufreq.c and then write
scaling_setspeed in one task and offline the cpu in another. The
first task will hang and be detected by the hung task detector.

Signed-off-by: Stephen Boyd <sboyd@codeaurora.org>
Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
Integrated-by: Hanjun Guo <guohanjun@huawei.com>
---
 drivers/cpufreq/cpufreq.c |   35 +++++++++++++++++++++++++++--------
 1 files changed, 27 insertions(+), 8 deletions(-)

diff --git a/drivers/cpufreq/cpufreq.c b/drivers/cpufreq/cpufreq.c
index 7f2f149..fb8a527 100644
--- a/drivers/cpufreq/cpufreq.c
+++ b/drivers/cpufreq/cpufreq.c
@@ -138,7 +138,7 @@ void disable_cpufreq(void)
 static LIST_HEAD(cpufreq_governor_list);
 static DEFINE_MUTEX(cpufreq_governor_mutex);
 
-struct cpufreq_policy *cpufreq_cpu_get(unsigned int cpu)
+static struct cpufreq_policy *__cpufreq_cpu_get(unsigned int cpu, bool sysfs)
 {
 	struct cpufreq_policy *data;
 	unsigned long flags;
@@ -162,7 +162,7 @@ struct cpufreq_policy *cpufreq_cpu_get(unsigned int cpu)
 	if (!data)
 		goto err_out_put_module;
 
-	if (!kobject_get(&data->kobj))
+	if (!sysfs && !kobject_get(&data->kobj))
 		goto err_out_put_module;
 
 	spin_unlock_irqrestore(&cpufreq_driver_lock, flags);
@@ -175,16 +175,35 @@ err_out_unlock:
 err_out:
 	return NULL;
 }
+
+struct cpufreq_policy *cpufreq_cpu_get(unsigned int cpu)
+{
+	return __cpufreq_cpu_get(cpu, false);
+}
 EXPORT_SYMBOL_GPL(cpufreq_cpu_get);
 
+static struct cpufreq_policy *cpufreq_cpu_get_sysfs(unsigned int cpu)
+{
+	return __cpufreq_cpu_get(cpu, true);
+}
 
-void cpufreq_cpu_put(struct cpufreq_policy *data)
+static void __cpufreq_cpu_put(struct cpufreq_policy *data, bool sysfs)
 {
-	kobject_put(&data->kobj);
+	if (!sysfs)
+		kobject_put(&data->kobj);
 	module_put(cpufreq_driver->owner);
 }
+
+void cpufreq_cpu_put(struct cpufreq_policy *data)
+{
+	__cpufreq_cpu_put(data, false);
+}
 EXPORT_SYMBOL_GPL(cpufreq_cpu_put);
 
+static void cpufreq_cpu_put_sysfs(struct cpufreq_policy *data)
+{
+	__cpufreq_cpu_put(data, true);
+}
 
 /*********************************************************************
  *            EXTERNALLY AFFECTING FREQUENCY CHANGES                 *
@@ -617,7 +636,7 @@ static ssize_t show(struct kobject *kobj, struct attribute *attr, char *buf)
 	struct cpufreq_policy *policy = to_policy(kobj);
 	struct freq_attr *fattr = to_attr(attr);
 	ssize_t ret = -EINVAL;
-	policy = cpufreq_cpu_get(policy->cpu);
+	policy = cpufreq_cpu_get_sysfs(policy->cpu);
 	if (!policy)
 		goto no_policy;
 
@@ -631,7 +650,7 @@ static ssize_t show(struct kobject *kobj, struct attribute *attr, char *buf)
 
 	unlock_policy_rwsem_read(policy->cpu);
 fail:
-	cpufreq_cpu_put(policy);
+	cpufreq_cpu_put_sysfs(policy);
 no_policy:
 	return ret;
 }
@@ -642,7 +661,7 @@ static ssize_t store(struct kobject *kobj, struct attribute *attr,
 	struct cpufreq_policy *policy = to_policy(kobj);
 	struct freq_attr *fattr = to_attr(attr);
 	ssize_t ret = -EINVAL;
-	policy = cpufreq_cpu_get(policy->cpu);
+	policy = cpufreq_cpu_get_sysfs(policy->cpu);
 	if (!policy)
 		goto no_policy;
 
@@ -656,7 +675,7 @@ static ssize_t store(struct kobject *kobj, struct attribute *attr,
 
 	unlock_policy_rwsem_write(policy->cpu);
 fail:
-	cpufreq_cpu_put(policy);
+	cpufreq_cpu_put_sysfs(policy);
 no_policy:
 	return ret;
 }
-- 
1.6.0.2


