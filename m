From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Mon, 25 Jul 2016 22:09:21 +0000
Subject: [PATCH] ia64: salinfo: drop the CPU_DEAD event
Message-Id: <1469484561-29309-1-git-send-email-bigeasy@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The CPU_DEAD event drops all events for the CPU that goes offline which
were recorded earlier. I don't think that this makes sense because the
"problem" that was recorded is not resovled just because the CPU went
offline.
I *think* it makes sense to keep that event for later once userland is
able to fetch it.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 arch/ia64/kernel/salinfo.c | 19 -------------------
 1 file changed, 19 deletions(-)

diff --git a/arch/ia64/kernel/salinfo.c b/arch/ia64/kernel/salinfo.c
index 5313007d5423..d4f5168bdc6c 100644
--- a/arch/ia64/kernel/salinfo.c
+++ b/arch/ia64/kernel/salinfo.c
@@ -568,25 +568,6 @@ salinfo_cpu_callback(struct notifier_block *nb, unsigned long action, void *hcpu
 		}
 		spin_unlock_irqrestore(&data_saved_lock, flags);
 		break;
-	case CPU_DEAD:
-	case CPU_DEAD_FROZEN:
-		spin_lock_irqsave(&data_saved_lock, flags);
-		for (i = 0, data = salinfo_data;
-		     i < ARRAY_SIZE(salinfo_data);
-		     ++i, ++data) {
-			struct salinfo_data_saved *data_saved;
-			int j;
-			for (j = ARRAY_SIZE(data->data_saved) - 1, data_saved = data->data_saved + j;
-			     j >= 0;
-			     --j, --data_saved) {
-				if (data_saved->buffer && data_saved->cpu = cpu) {
-					shift1_data_saved(data, j);
-				}
-			}
-			cpumask_clear_cpu(cpu, &data->cpu_event);
-		}
-		spin_unlock_irqrestore(&data_saved_lock, flags);
-		break;
 	}
 	return NOTIFY_OK;
 }
-- 
2.8.1

