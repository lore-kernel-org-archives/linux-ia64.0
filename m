From: Thomas Gleixner <tglx@linutronix.de>
Date: Wed, 12 Apr 2017 20:07:30 +0000
Subject: [patch 04/13] ia64/sn/hwperf: Replace racy task affinity logic
Message-Id: <20170412201042.421132173@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170412200726.941336635@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Sebastian Siewior <bigeasy@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "David S. Miller" <davem@davemloft.net>, Fenghua Yu <fenghua.yu@intel.com>, Herbert Xu <herbert@gondor.apana.org.au>, Lai Jiangshan <jiangshanlai@gmail.com>, Len Brown <lenb@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Tejun Heo <tj@kernel.org>, Tony Luck <tony.luck@intel.com>, Viresh Kumar <viresh.kumar@linaro.org>, linux-ia64@vger.kernel.org

sn_hwperf_op_cpu() which is invoked from an ioctl requires to run code on
the requested cpu. This is achieved by temporarily setting the affinity of
the calling user space thread to the requested CPU and reset it to the
original affinity afterwards.

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
 arch/ia64/sn/kernel/sn2/sn_hwperf.c |   16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

--- a/arch/ia64/sn/kernel/sn2/sn_hwperf.c
+++ b/arch/ia64/sn/kernel/sn2/sn_hwperf.c
@@ -598,6 +598,12 @@ static void sn_hwperf_call_sal(void *inf
 	op_info->ret = r;
 }
 
+static long sn_hwperf_call_sal_work(void *info)
+{
+	sn_hwperf_call_sal(info);
+	return 0;
+}
+
 static int sn_hwperf_op_cpu(struct sn_hwperf_op_info *op_info)
 {
 	u32 cpu;
@@ -629,13 +635,9 @@ static int sn_hwperf_op_cpu(struct sn_hw
 			/* use an interprocessor interrupt to call SAL */
 			smp_call_function_single(cpu, sn_hwperf_call_sal,
 				op_info, 1);
-		}
-		else {
-			/* migrate the task before calling SAL */ 
-			save_allowed = current->cpus_allowed;
-			set_cpus_allowed_ptr(current, cpumask_of(cpu));
-			sn_hwperf_call_sal(op_info);
-			set_cpus_allowed_ptr(current, &save_allowed);
+		} else {
+			/* Call on the target CPU */
+			work_on_cpu_safe(cpu, sn_hwperf_call_sal, op_info);
 		}
 	}
 	r = op_info->ret;


