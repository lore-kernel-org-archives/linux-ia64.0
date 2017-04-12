From: Thomas Gleixner <tglx@linutronix.de>
Date: Wed, 12 Apr 2017 20:07:29 +0000
Subject: [patch 03/13] ia64/salinfo: Replace racy task affinity logic
Message-Id: <20170412201042.341863457@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170412200726.941336635@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Sebastian Siewior <bigeasy@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "David S. Miller" <davem@davemloft.net>, Fenghua Yu <fenghua.yu@intel.com>, Herbert Xu <herbert@gondor.apana.org.au>, Lai Jiangshan <jiangshanlai@gmail.com>, Len Brown <lenb@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Tejun Heo <tj@kernel.org>, Tony Luck <tony.luck@intel.com>, Viresh Kumar <viresh.kumar@linaro.org>, linux-ia64@vger.kernel.org

Some of the file operations in /proc/sal require to run code on the
requested cpu. This is achieved by temporarily setting the affinity of the
calling user space thread to the requested CPU and reset it to the original
affinity afterwards.

That's racy vs. CPU hotplug and concurrent affinity settings for that
thread resulting in code executing on the wrong CPU and overwriting the
new affinity setting.

Replace it by using work_on_cpu_safe() which guarantees to run the code on
the requested CPU or to fail in case the CPU is offline.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/kernel/salinfo.c |   31 ++++++++++++-------------------
 1 file changed, 12 insertions(+), 19 deletions(-)

--- a/arch/ia64/kernel/salinfo.c
+++ b/arch/ia64/kernel/salinfo.c
@@ -179,14 +179,14 @@ struct salinfo_platform_oemdata_parms {
 	const u8 *efi_guid;
 	u8 **oemdata;
 	u64 *oemdata_size;
-	int ret;
 };
 
-static void
+static long
 salinfo_platform_oemdata_cpu(void *context)
 {
 	struct salinfo_platform_oemdata_parms *parms = context;
-	parms->ret = salinfo_platform_oemdata(parms->efi_guid, parms->oemdata, parms->oemdata_size);
+
+	return salinfo_platform_oemdata(parms->efi_guid, parms->oemdata, parms->oemdata_size);
 }
 
 static void
@@ -380,16 +380,7 @@ salinfo_log_release(struct inode *inode,
 	return 0;
 }
 
-static void
-call_on_cpu(int cpu, void (*fn)(void *), void *arg)
-{
-	cpumask_t save_cpus_allowed = current->cpus_allowed;
-	set_cpus_allowed_ptr(current, cpumask_of(cpu));
-	(*fn)(arg);
-	set_cpus_allowed_ptr(current, &save_cpus_allowed);
-}
-
-static void
+static long
 salinfo_log_read_cpu(void *context)
 {
 	struct salinfo_data *data = context;
@@ -399,6 +390,7 @@ salinfo_log_read_cpu(void *context)
 	/* Clear corrected errors as they are read from SAL */
 	if (rh->severity = sal_log_severity_corrected)
 		ia64_sal_clear_state_info(data->type);
+	return 0;
 }
 
 static void
@@ -430,7 +422,7 @@ salinfo_log_new_read(int cpu, struct sal
 	spin_unlock_irqrestore(&data_saved_lock, flags);
 
 	if (!data->saved_num)
-		call_on_cpu(cpu, salinfo_log_read_cpu, data);
+		work_on_cpu_safe(cpu, salinfo_log_read_cpu, data);
 	if (!data->log_size) {
 		data->state = STATE_NO_DATA;
 		cpumask_clear_cpu(cpu, &data->cpu_event);
@@ -459,11 +451,13 @@ salinfo_log_read(struct file *file, char
 	return simple_read_from_buffer(buffer, count, ppos, buf, bufsize);
 }
 
-static void
+static long
 salinfo_log_clear_cpu(void *context)
 {
 	struct salinfo_data *data = context;
+
 	ia64_sal_clear_state_info(data->type);
+	return 0;
 }
 
 static int
@@ -486,7 +480,7 @@ salinfo_log_clear(struct salinfo_data *d
 	rh = (sal_log_record_header_t *)(data->log_buffer);
 	/* Corrected errors have already been cleared from SAL */
 	if (rh->severity != sal_log_severity_corrected)
-		call_on_cpu(cpu, salinfo_log_clear_cpu, data);
+		work_on_cpu_safe(cpu, salinfo_log_clear_cpu, data);
 	/* clearing a record may make a new record visible */
 	salinfo_log_new_read(cpu, data);
 	if (data->state = STATE_LOG_RECORD) {
@@ -531,9 +525,8 @@ salinfo_log_write(struct file *file, con
 				.oemdata = &data->oemdata,
 				.oemdata_size = &data->oemdata_size
 			};
-			call_on_cpu(cpu, salinfo_platform_oemdata_cpu, &parms);
-			if (parms.ret)
-				count = parms.ret;
+			count = work_on_cpu_safe(cpu, salinfo_platform_oemdata_cpu,
+						 &parms);
 		} else
 			data->oemdata_size = 0;
 	} else


