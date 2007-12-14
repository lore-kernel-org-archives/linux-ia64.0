From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Fri, 14 Dec 2007 06:25:10 +0000
Subject: [PATCH] ia64: Adjust CMCI mask on CPU hotplug
Message-Id: <476221C6.8040703@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Currently CMCI mask of hot-added CPU is always disabled after CPU hotplug.
We should adjust this mask depending on CMC polling state.

Thanks,
H.Seto

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Signed-off-by: Satoru Takeuchi <takeuchi_satoru@jp.fujitsu.com>

---
Index: linux-2.6.24-rc5/arch/ia64/kernel/mca.c
=================================--- linux-2.6.24-rc5.orig/arch/ia64/kernel/mca.c
+++ linux-2.6.24-rc5/arch/ia64/kernel/mca.c
@@ -75,6 +75,7 @@
 #include <linux/workqueue.h>
 #include <linux/cpumask.h>
 #include <linux/kdebug.h>
+#include <linux/cpu.h>

 #include <asm/delay.h>
 #include <asm/machvec.h>
@@ -1813,6 +1814,36 @@
 							      PAGE_KERNEL));
 }

+static void __cpuinit ia64_mca_cmc_vector_adjust(void *dummy)
+{
+	unsigned long flags;
+
+	local_irq_save(flags);
+	if (!cmc_polling_enabled)
+		ia64_mca_cmc_vector_enable(NULL);
+	local_irq_restore(flags);
+}
+
+static int __cpuinit mca_cpu_callback(struct notifier_block *nfb,
+				      unsigned long action,
+				      void *hcpu)
+{
+	int hotcpu = (unsigned long) hcpu;
+
+	switch (action) {
+	case CPU_ONLINE:
+	case CPU_ONLINE_FROZEN:
+		smp_call_function_single(hotcpu, ia64_mca_cmc_vector_adjust,
+					 NULL, 1, 0);
+		break;
+	}
+	return NOTIFY_OK;
+}
+
+static struct notifier_block mca_cpu_notifier __cpuinitdata = {
+ 	.notifier_call = mca_cpu_callback
+};
+
 /*
  * ia64_mca_init
  *
@@ -1996,6 +2027,8 @@
 	if (!mca_init)
 		return 0;

+	register_hotcpu_notifier(&mca_cpu_notifier);
+
 	/* Setup the CMCI/P vector and handler */
 	init_timer(&cmc_poll_timer);
 	cmc_poll_timer.function = ia64_mca_cmc_poll;
