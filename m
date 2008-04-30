From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Wed, 30 Apr 2008 09:55:48 +0000
Subject: [PATCH] ia64: smp.c coding style fix
Message-Id: <48184224.5020308@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Fix indenting of switch statement to follow CodingStyle, and
pull out handling of call_data into an inlined function.

I confirmed that applying this fix doesn't affect assembled code.

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
---
 arch/ia64/kernel/smp.c |   68 ++++++++++++++++++++++++-----------------------
 1 files changed, 35 insertions(+), 33 deletions(-)

diff --git a/arch/ia64/kernel/smp.c b/arch/ia64/kernel/smp.c
index 9a9d4c4..983296f 100644
--- a/arch/ia64/kernel/smp.c
+++ b/arch/ia64/kernel/smp.c
@@ -98,8 +98,33 @@ unlock_ipi_calllock(void)
 	spin_unlock_irq(&call_lock);
 }
 
+static inline void
+handle_call_data(void)
+{
+	struct call_data_struct *data;
+	void (*func)(void *info);
+	void *info;
+	int wait;
+
+	/* release the 'pointer lock' */
+	data = (struct call_data_struct *)call_data;
+	func = data->func;
+	info = data->info;
+	wait = data->wait;
+
+	mb();
+	atomic_inc(&data->started);
+	/* At this point the structure may be gone unless wait is true. */
+	(*func)(info);
+
+	/* Notify the sending CPU that the task is done. */
+	mb();
+	if (wait)
+		atomic_inc(&data->finished);
+}
+
 static void
-stop_this_cpu (void)
+stop_this_cpu(void)
 {
 	/*
 	 * Remove this CPU:
@@ -138,44 +163,21 @@ handle_IPI (int irq, void *dev_id)
 			ops &= ~(1 << which);
 
 			switch (which) {
-			      case IPI_CALL_FUNC:
-			      {
-				      struct call_data_struct *data;
-				      void (*func)(void *info);
-				      void *info;
-				      int wait;
-
-				      /* release the 'pointer lock' */
-				      data = (struct call_data_struct *) call_data;
-				      func = data->func;
-				      info = data->info;
-				      wait = data->wait;
-
-				      mb();
-				      atomic_inc(&data->started);
-				      /*
-				       * At this point the structure may be gone unless
-				       * wait is true.
-				       */
-				      (*func)(info);
-
-				      /* Notify the sending CPU that the task is done.  */
-				      mb();
-				      if (wait)
-					      atomic_inc(&data->finished);
-			      }
-			      break;
-
-			      case IPI_CPU_STOP:
+			case IPI_CALL_FUNC:
+				handle_call_data();
+				break;
+
+			case IPI_CPU_STOP:
 				stop_this_cpu();
 				break;
 #ifdef CONFIG_KEXEC
-			      case IPI_KDUMP_CPU_STOP:
+			case IPI_KDUMP_CPU_STOP:
 				unw_init_running(kdump_cpu_freeze, NULL);
 				break;
 #endif
-			      default:
-				printk(KERN_CRIT "Unknown IPI on CPU %d: %lu\n", this_cpu, which);
+			default:
+				printk(KERN_CRIT "Unknown IPI on CPU %d: %lu\n",
+						this_cpu, which);
 				break;
 			}
 		} while (ops);
