From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Thu, 03 Nov 2016 14:50:12 +0000
Subject: [PATCH 16/25] ia64/salinfo: Convert to hotplug state machine
Message-Id: <20161103145021.28528-17-bigeasy@linutronix.de>
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
 arch/ia64/kernel/salinfo.c | 83 ++++++++++++++++++----------------------------
 1 file changed, 32 insertions(+), 51 deletions(-)

diff --git a/arch/ia64/kernel/salinfo.c b/arch/ia64/kernel/salinfo.c
index 5313007d5423..bfbf07ed38dd 100644
--- a/arch/ia64/kernel/salinfo.c
+++ b/arch/ia64/kernel/salinfo.c
@@ -550,52 +550,40 @@ static const struct file_operations salinfo_data_fops = {
 	.llseek  = default_llseek,
 };
 
-static int
-salinfo_cpu_callback(struct notifier_block *nb, unsigned long action, void *hcpu)
+static int salinfo_cpu_online(unsigned int cpu)
 {
-	unsigned int i, cpu = (unsigned long)hcpu;
-	unsigned long flags;
+	unsigned int i, end = ARRAY_SIZE(salinfo_data);
 	struct salinfo_data *data;
-	switch (action) {
-	case CPU_ONLINE:
-	case CPU_ONLINE_FROZEN:
-		spin_lock_irqsave(&data_saved_lock, flags);
-		for (i = 0, data = salinfo_data;
-		     i < ARRAY_SIZE(salinfo_data);
-		     ++i, ++data) {
-			cpumask_set_cpu(cpu, &data->cpu_event);
-			wake_up_interruptible(&data->read_wait);
-		}
-		spin_unlock_irqrestore(&data_saved_lock, flags);
-		break;
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
-				if (data_saved->buffer && data_saved->cpu == cpu) {
-					shift1_data_saved(data, j);
-				}
-			}
-			cpumask_clear_cpu(cpu, &data->cpu_event);
-		}
-		spin_unlock_irqrestore(&data_saved_lock, flags);
-		break;
+
+	spin_lock_irq(&data_saved_lock);
+	for (i = 0, data = salinfo_data; i < end; ++i, ++data) {
+		cpumask_set_cpu(cpu, &data->cpu_event);
+		wake_up_interruptible(&data->read_wait);
 	}
-	return NOTIFY_OK;
+	spin_unlock_irq(&data_saved_lock);
+	return 0;
 }
 
-static struct notifier_block salinfo_cpu_notifier =
+static int salinfo_cpu_pre_down(unsigned int cpu)
 {
-	.notifier_call = salinfo_cpu_callback,
-	.priority = 0,
-};
+	unsigned int i, end = ARRAY_SIZE(salinfo_data);
+	struct salinfo_data *data;
+
+	spin_lock_irqsave(&data_saved_lock, flags);
+	for (i = 0, data = salinfo_data; i < end; ++i, ++data) {
+		struct salinfo_data_saved *data_saved;
+		int j = ARRAY_SIZE(data->data_saved) - 1;
+
+		for (data_saved = data->data_saved + j; j >= 0;
+		     --j, --data_saved) {
+			if (data_saved->buffer && data_saved->cpu == cpu)
+				shift1_data_saved(data, j);
+		}
+		cpumask_clear_cpu(cpu, &data->cpu_event);
+	}
+	spin_unlock_irqrestore(&data_saved_lock, flags);
+	return 0;
+}
 
 static int __init
 salinfo_init(void)
@@ -604,7 +592,7 @@ salinfo_init(void)
 	struct proc_dir_entry **sdir = salinfo_proc_entries; /* keeps track of every entry */
 	struct proc_dir_entry *dir, *entry;
 	struct salinfo_data *data;
-	int i, j;
+	int i;
 
 	salinfo_dir = proc_mkdir("sal", NULL);
 	if (!salinfo_dir)
@@ -617,8 +605,6 @@ salinfo_init(void)
 					   (void *)salinfo_entries[i].feature);
 	}
 
-	cpu_notifier_register_begin();
-
 	for (i = 0; i < ARRAY_SIZE(salinfo_log_name); i++) {
 		data = salinfo_data + i;
 		data->type = i;
@@ -639,10 +625,6 @@ salinfo_init(void)
 			continue;
 		*sdir++ = entry;
 
-		/* we missed any events before now */
-		for_each_online_cpu(j)
-			cpumask_set_cpu(j, &data->cpu_event);
-
 		*sdir++ = dir;
 	}
 
@@ -653,10 +635,9 @@ salinfo_init(void)
 	salinfo_timer.function = &salinfo_timeout;
 	add_timer(&salinfo_timer);
 
-	__register_hotcpu_notifier(&salinfo_cpu_notifier);
-
-	cpu_notifier_register_done();
-
+	i = cpuhp_setup_state(CPUHP_AP_ONLINE_DYN, "ia64/salinfo:online",
+			      salinfo_cpu_online, salinfo_cpu_pre_down);
+	WARN_ON(i < 0);
 	return 0;
 }
 
-- 
2.10.2

