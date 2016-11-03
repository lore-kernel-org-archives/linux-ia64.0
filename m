From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Thu, 03 Nov 2016 14:50:11 +0000
Subject: [PATCH 15/25] ia64/palinfo: Convert to hotplug state machine
Message-Id: <20161103145021.28528-16-bigeasy@linutronix.de>
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
 arch/ia64/kernel/palinfo.c | 60 +++++++++++++---------------------------------
 1 file changed, 16 insertions(+), 44 deletions(-)

diff --git a/arch/ia64/kernel/palinfo.c b/arch/ia64/kernel/palinfo.c
index c39c3cd3ac34..b6e597860888 100644
--- a/arch/ia64/kernel/palinfo.c
+++ b/arch/ia64/kernel/palinfo.c
@@ -932,8 +932,7 @@ static const struct file_operations proc_palinfo_fops = {
 	.release	= single_release,
 };
 
-static void
-create_palinfo_proc_entries(unsigned int cpu)
+static int palinfo_add_proc(unsigned int cpu)
 {
 	pal_func_cpu_u_t f;
 	struct proc_dir_entry *cpu_dir;
@@ -943,7 +942,7 @@ create_palinfo_proc_entries(unsigned int cpu)
 
 	cpu_dir = proc_mkdir(cpustr, palinfo_dir);
 	if (!cpu_dir)
-		return;
+		return -EINVAL;
 
 	f.req_cpu = cpu;
 
@@ -952,42 +951,21 @@ create_palinfo_proc_entries(unsigned int cpu)
 		proc_create_data(palinfo_entries[j].name, 0, cpu_dir,
 				 &proc_palinfo_fops, (void *)f.value);
 	}
+	return 0;
 }
 
-static void
-remove_palinfo_proc_entries(unsigned int hcpu)
+static int palinfo_del_proc(unsigned int hcpu)
 {
 	char cpustr[3+4+1];	/* cpu numbers are up to 4095 on itanic */
+
 	sprintf(cpustr, "cpu%d", hcpu);
 	remove_proc_subtree(cpustr, palinfo_dir);
+	return 0;
 }
 
-static int palinfo_cpu_callback(struct notifier_block *nfb,
-					unsigned long action, void *hcpu)
-{
-	unsigned int hotcpu = (unsigned long)hcpu;
+static enum cpuhp_state hp_online;
 
-	switch (action) {
-	case CPU_ONLINE:
-	case CPU_ONLINE_FROZEN:
-		create_palinfo_proc_entries(hotcpu);
-		break;
-	case CPU_DEAD:
-	case CPU_DEAD_FROZEN:
-		remove_palinfo_proc_entries(hotcpu);
-		break;
-	}
-	return NOTIFY_OK;
-}
-
-static struct notifier_block __refdata palinfo_cpu_notifier =
-{
-	.notifier_call = palinfo_cpu_callback,
-	.priority = 0,
-};
-
-static int __init
-palinfo_init(void)
+static int __init palinfo_init(void)
 {
 	int i = 0;
 
@@ -996,25 +974,19 @@ palinfo_init(void)
 	if (!palinfo_dir)
 		return -ENOMEM;
 
-	cpu_notifier_register_begin();
-
-	/* Create palinfo dirs in /proc for all online cpus */
-	for_each_online_cpu(i) {
-		create_palinfo_proc_entries(i);
+	i = cpuhp_setup_state(CPUHP_AP_ONLINE_DYN, "ia64/palinfo:online",
+			      palinfo_add_proc, palinfo_del_proc);
+	if (i < 0) {
+		remove_proc_subtree("pal", NULL);
+		return i;
 	}
-
-	/* Register for future delivery via notify registration */
-	__register_hotcpu_notifier(&palinfo_cpu_notifier);
-
-	cpu_notifier_register_done();
-
+	hp_online = i;
 	return 0;
 }
 
-static void __exit
-palinfo_exit(void)
+static void __exit palinfo_exit(void)
 {
-	unregister_hotcpu_notifier(&palinfo_cpu_notifier);
+	cpuhp_remove_state(hp_online);
 	remove_proc_subtree("pal", NULL);
 }
 
-- 
2.10.2

