From: Satoru Takeuchi <takeuchi_satoru@jp.fujitsu.com>
Date: Fri, 27 Oct 2006 10:49:53 +0000
Subject: [BUGFIX] [PATCH 1/2] cpu-hotplug: Fixing confliction between CPU hot-add and IPI
Message-Id: <87mz7ivxri.wl%takeuchi_satoru@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64 <linux-ia64@vger.kernel.org>, Linux Kernel <linux-kernel@vger.kernel.org>
Cc: Ashok Raj <ashok.raj@intel.com>, "Luck, Tony" <tony.luck@intel.com>, Andrew Morton <akpm@osdl.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>, Satoru Takeuchi <takeuchi_satoru@jp.fujitsu.com>

From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>

---
Fixing the confliction between CPU hot-add and IPI.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Acked-by: Satoru Takeuchi <takeuchi_satoru@jp.fujitsu.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: linux-2.6.19-rc3/arch/ia64/kernel/smp.c
=================================--- linux-2.6.19-rc3.orig/arch/ia64/kernel/smp.c	2006-10-27 18:40:47.000000000 +0900
+++ linux-2.6.19-rc3/arch/ia64/kernel/smp.c	2006-10-27 18:49:48.000000000 +0900
@@ -328,10 +328,14 @@
 smp_call_function (void (*func) (void *info), void *info, int nonatomic, int wait)
 {
 	struct call_data_struct data;
-	int cpus = num_online_cpus()-1;
+	int cpus;
 
-	if (!cpus)
+	spin_lock(&call_lock);
+	cpus = num_online_cpus() - 1;
+	if (!cpus) {
+		spin_unlock(&call_lock);
 		return 0;
+	}
 
 	/* Can deadlock when called with interrupts disabled */
 	WARN_ON(irqs_disabled());
@@ -343,8 +347,6 @@
 	if (wait)
 		atomic_set(&data.finished, 0);
 
-	spin_lock(&call_lock);
-
 	call_data = &data;
 	mb();	/* ensure store to call_data precedes setting of IPI_CALL_FUNC */
 	send_IPI_allbutself(IPI_CALL_FUNC);
