From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Date: Wed, 05 Feb 2014 22:17:55 +0000
Subject: [PATCH 07/51] ia64, err-inject: Fix CPU hotplug callback registration
Message-Id: <20140205220554.19080.62392.stgit@srivatsabhat.in.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20140205220251.19080.92336.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20140205220251.19080.92336.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: paulus@samba.org, oleg@redhat.com, rusty@rustcorp.com.au, peterz@infradead.org, tglx@linutronix.de, akpm@linux-foundation.org
Cc: mingo@kernel.org, paulmck@linux.vnet.ibm.com, tj@kernel.org, walken@google.com, ego@linux.vnet.ibm.com, linux@arm.linux.org.uk, linux-kernel@vger.kernel.org, srivatsa.bhat@linux.vnet.ibm.com, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>

Subsystems that want to register CPU hotplug callbacks, as well as perform
initialization for the CPUs that are already online, often do it as shown
below:

	get_online_cpus();

	for_each_online_cpu(cpu)
		init_cpu(cpu);

	register_cpu_notifier(&foobar_cpu_notifier);

	put_online_cpus();

This is wrong, since it is prone to ABBA deadlocks involving the
cpu_add_remove_lock and the cpu_hotplug.lock (when running concurrently
with CPU hotplug operations).

Instead, the correct and race-free way of performing the callback
registration is:

	cpu_maps_update_begin();

	for_each_online_cpu(cpu)
		init_cpu(cpu);

	/* Note the use of the double underscored version of the API */
	__register_cpu_notifier(&foobar_cpu_notifier);

	cpu_maps_update_done();


Fix the error injection code in ia64 by using this latter form of callback
registration.

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 arch/ia64/kernel/err_inject.c |   15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/kernel/err_inject.c b/arch/ia64/kernel/err_inject.c
index f59c0b8..b7b1403 100644
--- a/arch/ia64/kernel/err_inject.c
+++ b/arch/ia64/kernel/err_inject.c
@@ -269,12 +269,17 @@ err_inject_init(void)
 #ifdef ERR_INJ_DEBUG
 	printk(KERN_INFO "Enter error injection driver.\n");
 #endif
+
+	cpu_maps_update_begin();
+
 	for_each_online_cpu(i) {
 		err_inject_cpu_callback(&err_inject_cpu_notifier, CPU_ONLINE,
 				(void *)(long)i);
 	}
 
-	register_hotcpu_notifier(&err_inject_cpu_notifier);
+	__register_hotcpu_notifier(&err_inject_cpu_notifier);
+
+	cpu_maps_update_done();
 
 	return 0;
 }
@@ -288,11 +293,17 @@ err_inject_exit(void)
 #ifdef ERR_INJ_DEBUG
 	printk(KERN_INFO "Exit error injection driver.\n");
 #endif
+
+	cpu_maps_update_begin();
+
 	for_each_online_cpu(i) {
 		sys_dev = get_cpu_device(i);
 		sysfs_remove_group(&sys_dev->kobj, &err_inject_attr_group);
 	}
-	unregister_hotcpu_notifier(&err_inject_cpu_notifier);
+
+	__unregister_hotcpu_notifier(&err_inject_cpu_notifier);
+
+	cpu_maps_update_done();
 }
 
 module_init(err_inject_init);

