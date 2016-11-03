From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Thu, 03 Nov 2016 17:31:29 +0000
Subject: [PATCH 16/25 v2] ia64/salinfo: Convert to hotplug state machine
Message-Id: <20161103173128.xuulg4nius46dng5@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20161103145021.28528-17-bigeasy@linutronix.de>
 <201611032322.thr2cVQ1%fengguang.wu@intel.com>
In-Reply-To: <201611032322.thr2cVQ1%fengguang.wu@intel.com>
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
v1=E2=80=A6v2: non the save version. Noticed by kbuild test robot

 arch/ia64/kernel/salinfo.c | 83 ++++++++++++++++++------------------------=
----
 1 file changed, 32 insertions(+), 51 deletions(-)

diff --git a/arch/ia64/kernel/salinfo.c b/arch/ia64/kernel/salinfo.c
index 5313007d5423..aaf74f36cfa1 100644
--- a/arch/ia64/kernel/salinfo.c
+++ b/arch/ia64/kernel/salinfo.c
@@ -550,52 +550,40 @@ static const struct file_operations salinfo_data_fops=
 =3D {
 	.llseek  =3D default_llseek,
 };
=20
-static int
-salinfo_cpu_callback(struct notifier_block *nb, unsigned long action, void=
 *hcpu)
+static int salinfo_cpu_online(unsigned int cpu)
 {
-	unsigned int i, cpu =3D (unsigned long)hcpu;
-	unsigned long flags;
+	unsigned int i, end =3D ARRAY_SIZE(salinfo_data);
 	struct salinfo_data *data;
-	switch (action) {
-	case CPU_ONLINE:
-	case CPU_ONLINE_FROZEN:
-		spin_lock_irqsave(&data_saved_lock, flags);
-		for (i =3D 0, data =3D salinfo_data;
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
-		for (i =3D 0, data =3D salinfo_data;
-		     i < ARRAY_SIZE(salinfo_data);
-		     ++i, ++data) {
-			struct salinfo_data_saved *data_saved;
-			int j;
-			for (j =3D ARRAY_SIZE(data->data_saved) - 1, data_saved =3D data->data_=
saved + j;
-			     j >=3D 0;
-			     --j, --data_saved) {
-				if (data_saved->buffer && data_saved->cpu =3D cpu) {
-					shift1_data_saved(data, j);
-				}
-			}
-			cpumask_clear_cpu(cpu, &data->cpu_event);
-		}
-		spin_unlock_irqrestore(&data_saved_lock, flags);
-		break;
+
+	spin_lock_irq(&data_saved_lock);
+	for (i =3D 0, data =3D salinfo_data; i < end; ++i, ++data) {
+		cpumask_set_cpu(cpu, &data->cpu_event);
+		wake_up_interruptible(&data->read_wait);
 	}
-	return NOTIFY_OK;
+	spin_unlock_irq(&data_saved_lock);
+	return 0;
 }
=20
-static struct notifier_block salinfo_cpu_notifier +static int salinfo_cpu_=
pre_down(unsigned int cpu)
 {
-	.notifier_call =3D salinfo_cpu_callback,
-	.priority =3D 0,
-};
+	unsigned int i, end =3D ARRAY_SIZE(salinfo_data);
+	struct salinfo_data *data;
+
+	spin_lock_irq(&data_saved_lock);
+	for (i =3D 0, data =3D salinfo_data; i < end; ++i, ++data) {
+		struct salinfo_data_saved *data_saved;
+		int j =3D ARRAY_SIZE(data->data_saved) - 1;
+
+		for (data_saved =3D data->data_saved + j; j >=3D 0;
+		     --j, --data_saved) {
+			if (data_saved->buffer && data_saved->cpu =3D cpu)
+				shift1_data_saved(data, j);
+		}
+		cpumask_clear_cpu(cpu, &data->cpu_event);
+	}
+	spin_unlock_irq(&data_saved_lock);
+	return 0;
+}
=20
 static int __init
 salinfo_init(void)
@@ -604,7 +592,7 @@ salinfo_init(void)
 	struct proc_dir_entry **sdir =3D salinfo_proc_entries; /* keeps track of =
every entry */
 	struct proc_dir_entry *dir, *entry;
 	struct salinfo_data *data;
-	int i, j;
+	int i;
=20
 	salinfo_dir =3D proc_mkdir("sal", NULL);
 	if (!salinfo_dir)
@@ -617,8 +605,6 @@ salinfo_init(void)
 					   (void *)salinfo_entries[i].feature);
 	}
=20
-	cpu_notifier_register_begin();
-
 	for (i =3D 0; i < ARRAY_SIZE(salinfo_log_name); i++) {
 		data =3D salinfo_data + i;
 		data->type =3D i;
@@ -639,10 +625,6 @@ salinfo_init(void)
 			continue;
 		*sdir++ =3D entry;
=20
-		/* we missed any events before now */
-		for_each_online_cpu(j)
-			cpumask_set_cpu(j, &data->cpu_event);
-
 		*sdir++ =3D dir;
 	}
=20
@@ -653,10 +635,9 @@ salinfo_init(void)
 	salinfo_timer.function =3D &salinfo_timeout;
 	add_timer(&salinfo_timer);
=20
-	__register_hotcpu_notifier(&salinfo_cpu_notifier);
-
-	cpu_notifier_register_done();
-
+	i =3D cpuhp_setup_state(CPUHP_AP_ONLINE_DYN, "ia64/salinfo:online",
+			      salinfo_cpu_online, salinfo_cpu_pre_down);
+	WARN_ON(i < 0);
 	return 0;
 }
=20
--=20
2.10.2

