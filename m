From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Thu, 03 Nov 2016 14:50:13 +0000
Subject: [PATCH 17/25] ia64/topology: Convert to hotplug state machine
Message-Id: <20161103145021.28528-18-bigeasy@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20161103145021.28528-1-bigeasy@linutronix.de>
In-Reply-To: <20161103145021.28528-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: rt@linutronix.de, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>

Install the callbacks via the state machine and let the core invoke
the callbacks on the already online CPUs.

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/ia64/kernel/topology.c | 55 +++++++--------------------------------------
 1 file changed, 8 insertions(+), 47 deletions(-)

diff --git a/arch/ia64/kernel/topology.c b/arch/ia64/kernel/topology.c
index c01fe8991244..9102cad408b8 100644
--- a/arch/ia64/kernel/topology.c
+++ b/arch/ia64/kernel/topology.c
@@ -349,9 +349,9 @@ static int cpu_cache_sysfs_init(unsigned int cpu)
 }
 
 /* Add cache interface for CPU device */
-static int cache_add_dev(struct device *sys_dev)
+static int cache_add_dev(unsigned int cpu)
 {
-	unsigned int cpu = sys_dev->id;
+	struct device *sys_dev = get_cpu_device(cpu);
 	unsigned long i, j;
 	struct cache_info *this_object;
 	int retval = 0;
@@ -399,9 +399,9 @@ static int cache_add_dev(struct device *sys_dev)
 }
 
 /* Remove cache interface for CPU device */
-static int cache_remove_dev(struct device *sys_dev)
+static int cache_remove_dev(unsigned int cpu)
 {
-	unsigned int cpu = sys_dev->id;
+	struct device *sys_dev = get_cpu_device(cpu);
 	unsigned long i;
 
 	for (i = 0; i < all_cpu_cache_info[cpu].num_cache_leaves; i++)
@@ -419,52 +419,13 @@ static int cache_remove_dev(struct device *sys_dev)
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
-static struct notifier_block cache_cpu_notifier =
-{
-	.notifier_call = cache_cpu_callback
-};
-
 static int __init cache_sysfs_init(void)
 {
-	int i;
-
-	cpu_notifier_register_begin();
-
-	for_each_online_cpu(i) {
-		struct device *sys_dev = get_cpu_device((unsigned int)i);
-		cache_add_dev(sys_dev);
-	}
-
-	__register_hotcpu_notifier(&cache_cpu_notifier);
-
-	cpu_notifier_register_done();
+	int ret;
 
+	ret = cpuhp_setup_state(CPUHP_AP_ONLINE_DYN, "ia64/topology:online",
+				cache_add_dev, cache_remove_dev);
+	WARN_ON(ret < 0);
 	return 0;
 }
-
 device_initcall(cache_sysfs_init);
-
-- 
2.10.2

