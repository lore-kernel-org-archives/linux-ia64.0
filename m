From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Thu, 03 Nov 2016 17:33:53 +0000
Subject: [PATCH 17/25 v2] ia64/topology: Convert to hotplug state machine
Message-Id: <20161103173353.dudhkpioitghd74x@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20161103145021.28528-18-bigeasy@linutronix.de>
 <201611032345.KOBMysTk%fengguang.wu@intel.com>
In-Reply-To: <201611032345.KOBMysTk%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, rt@linutronix.de, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>

Install the callbacks via the state machine and let the core invoke
the callbacks on the already online CPUs.

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
v1=E2=80=A6v2: remove unused variable. Noticed by kbuild test robot

 arch/ia64/kernel/topology.c | 54 ++++++-----------------------------------=
----
 1 file changed, 7 insertions(+), 47 deletions(-)

diff --git a/arch/ia64/kernel/topology.c b/arch/ia64/kernel/topology.c
index c01fe8991244..1a68f012a6dc 100644
--- a/arch/ia64/kernel/topology.c
+++ b/arch/ia64/kernel/topology.c
@@ -349,9 +349,9 @@ static int cpu_cache_sysfs_init(unsigned int cpu)
 }
=20
 /* Add cache interface for CPU device */
-static int cache_add_dev(struct device *sys_dev)
+static int cache_add_dev(unsigned int cpu)
 {
-	unsigned int cpu =3D sys_dev->id;
+	struct device *sys_dev =3D get_cpu_device(cpu);
 	unsigned long i, j;
 	struct cache_info *this_object;
 	int retval =3D 0;
@@ -399,9 +399,8 @@ static int cache_add_dev(struct device *sys_dev)
 }
=20
 /* Remove cache interface for CPU device */
-static int cache_remove_dev(struct device *sys_dev)
+static int cache_remove_dev(unsigned int cpu)
 {
-	unsigned int cpu =3D sys_dev->id;
 	unsigned long i;
=20
 	for (i =3D 0; i < all_cpu_cache_info[cpu].num_cache_leaves; i++)
@@ -419,52 +418,13 @@ static int cache_remove_dev(struct device *sys_dev)
 	return 0;
 }
=20
-/*
- * When a cpu is hot-plugged, do a check and initiate
- * cache kobject if necessary
- */
-static int cache_cpu_callback(struct notifier_block *nfb,
-		unsigned long action, void *hcpu)
-{
-	unsigned int cpu =3D (unsigned long)hcpu;
-	struct device *sys_dev;
-
-	sys_dev =3D get_cpu_device(cpu);
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
-	.notifier_call =3D cache_cpu_callback
-};
-
 static int __init cache_sysfs_init(void)
 {
-	int i;
-
-	cpu_notifier_register_begin();
-
-	for_each_online_cpu(i) {
-		struct device *sys_dev =3D get_cpu_device((unsigned int)i);
-		cache_add_dev(sys_dev);
-	}
-
-	__register_hotcpu_notifier(&cache_cpu_notifier);
-
-	cpu_notifier_register_done();
+	int ret;
=20
+	ret =3D cpuhp_setup_state(CPUHP_AP_ONLINE_DYN, "ia64/topology:online",
+				cache_add_dev, cache_remove_dev);
+	WARN_ON(ret < 0);
 	return 0;
 }
-
 device_initcall(cache_sysfs_init);
-
--=20
2.10.2

