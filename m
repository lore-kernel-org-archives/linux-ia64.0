From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Thu, 03 Nov 2016 14:50:10 +0000
Subject: [PATCH 14/25] ia64/err-inject: Convert to hotplug state machine
Message-Id: <20161103145021.28528-15-bigeasy@linutronix.de>
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

The removal of the files happens now in the prepare down stage as there is
no reason to keep them around until the cpu has actually died.

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/ia64/kernel/err_inject.c | 78 +++++++++++--------------------------------
 1 file changed, 19 insertions(+), 59 deletions(-)

diff --git a/arch/ia64/kernel/err_inject.c b/arch/ia64/kernel/err_inject.c
index 5ed0ea92c5bf..85bba43e7d5d 100644
--- a/arch/ia64/kernel/err_inject.c
+++ b/arch/ia64/kernel/err_inject.c
@@ -224,85 +224,45 @@ static struct attribute_group err_inject_attr_group = {
 	.name = "err_inject"
 };
 /* Add/Remove err_inject interface for CPU device */
-static int err_inject_add_dev(struct device *sys_dev)
+static int err_inject_add_dev(unsigned int cpu)
 {
+	struct device *sys_dev = get_cpu_device(cpu);
+
 	return sysfs_create_group(&sys_dev->kobj, &err_inject_attr_group);
 }
 
-static int err_inject_remove_dev(struct device *sys_dev)
+static int err_inject_remove_dev(unsigned int cpu)
 {
+	struct device *sys_dev = get_cpu_device(cpu);
+
 	sysfs_remove_group(&sys_dev->kobj, &err_inject_attr_group);
 	return 0;
 }
-static int err_inject_cpu_callback(struct notifier_block *nfb,
-		unsigned long action, void *hcpu)
+
+static enum cpuhp_state hp_online;
+
+static int __init err_inject_init(void)
 {
-	unsigned int cpu = (unsigned long)hcpu;
-	struct device *sys_dev;
-
-	sys_dev = get_cpu_device(cpu);
-	switch (action) {
-	case CPU_ONLINE:
-	case CPU_ONLINE_FROZEN:
-		err_inject_add_dev(sys_dev);
-		break;
-	case CPU_DEAD:
-	case CPU_DEAD_FROZEN:
-		err_inject_remove_dev(sys_dev);
-		break;
-	}
-
-	return NOTIFY_OK;
-}
-
-static struct notifier_block err_inject_cpu_notifier =
-{
-	.notifier_call = err_inject_cpu_callback,
-};
-
-static int __init
-err_inject_init(void)
-{
-	int i;
-
+	int ret;
 #ifdef ERR_INJ_DEBUG
 	printk(KERN_INFO "Enter error injection driver.\n");
 #endif
 
-	cpu_notifier_register_begin();
-
-	for_each_online_cpu(i) {
-		err_inject_cpu_callback(&err_inject_cpu_notifier, CPU_ONLINE,
-				(void *)(long)i);
+	ret = cpuhp_setup_state(CPUHP_AP_ONLINE_DYN, "ia64/err_inj:online",
+				err_inject_add_dev, err_inject_remove_dev);
+	if (ret >= 0) {
+		hp_online = ret;
+		ret = 0;
 	}
-
-	__register_hotcpu_notifier(&err_inject_cpu_notifier);
-
-	cpu_notifier_register_done();
-
-	return 0;
+	return ret;
 }
 
-static void __exit
-err_inject_exit(void)
+static void __exit err_inject_exit(void)
 {
-	int i;
-	struct device *sys_dev;
-
 #ifdef ERR_INJ_DEBUG
 	printk(KERN_INFO "Exit error injection driver.\n");
 #endif
-
-	cpu_notifier_register_begin();
-
-	for_each_online_cpu(i) {
-		sys_dev = get_cpu_device(i);
-		sysfs_remove_group(&sys_dev->kobj, &err_inject_attr_group);
-	}
-
-	__unregister_hotcpu_notifier(&err_inject_cpu_notifier);
-
-	cpu_notifier_register_done();
+	cpuhp_remove_state(hp_online);
 }
 
 module_init(err_inject_init);
-- 
2.10.2

