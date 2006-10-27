From: Satoru Takeuchi <takeuchi_satoru@jp.fujitsu.com>
Date: Fri, 27 Oct 2006 10:49:54 +0000
Subject: [BUGFIX] [PATH 2/2] cpu-hotplug: Releasing `workqueue_mutex' properly on CPU hot-remove
Message-Id: <87lkn2vxrh.wl%takeuchi_satoru@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64 <linux-ia64@vger.kernel.org>, Linux Kernel <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@osdl.org>, Rusty Russell <rusty@rustycorp.com.au>, Srivatsa Vaddagiri <vatsa@in.ibm.com>, Satoru Takeuchi <takeuchi_satoru@jp.fujitsu.com>

Releasing `workqueue_mutex' properly on CPU hot-remove.

_cpu_down() acquires `workqueue_mutex' on its process, but doen't release it
if __cpu_disable() fails.

Signed-off-by: Satoru Takeuchi <takeuchi_satoru@jp.fujitsu.com>

Index: linux-2.6.19-rc3/kernel/cpu.c
=================================--- linux-2.6.19-rc3.orig/kernel/cpu.c	2006-10-24 14:01:39.000000000 +0900
+++ linux-2.6.19-rc3/kernel/cpu.c	2006-10-27 19:38:14.000000000 +0900
@@ -150,18 +150,18 @@
 	p = __stop_machine_run(take_cpu_down, NULL, cpu);
 	mutex_unlock(&cpu_bitmask_lock);
 
-	if (IS_ERR(p)) {
+	if (IS_ERR(p) || cpu_online(cpu)) {
 		/* CPU didn't die: tell everyone.  Can't complain. */
 		if (raw_notifier_call_chain(&cpu_chain, CPU_DOWN_FAILED,
 				(void *)(long)cpu) = NOTIFY_BAD)
 			BUG();
 
-		err = PTR_ERR(p);
-		goto out_allowed;
-	}
-
-	if (cpu_online(cpu))
+		if (IS_ERR(p)) {
+			err = PTR_ERR(p);
+			goto out_allowed;
+		}
 		goto out_thread;
+	}
 
 	/* Wait for it to sleep (leaving idle task). */
 	while (!idle_cpu(cpu))
