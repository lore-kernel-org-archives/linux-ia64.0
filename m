From: Jiang Liu <liuj97@gmail.com>
Date: Wed, 11 Sep 2013 16:07:12 +0000
Subject: [RFC PATCH v2 08/25] smp, IA64: kill SMP single function call interrupt
Message-Id: <1378915649-16395-9-git-send-email-liuj97@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1378915649-16395-1-git-send-email-liuj97@gmail.com>
In-Reply-To: <1378915649-16395-1-git-send-email-liuj97@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Shaohua Li <shli@kernel.org>
Cc: liuj97@gmail.com, Jiang Liu <jiang.liu@huawei.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Steven Rostedt <rostedt@goodmis.org>, Jiri Kosina <trivial@kernel.org>, Wang YanQing <udknight@gmail.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org

From: Jiang Liu <jiang.liu@huawei.com>

Commit 9a46ad6d6df3b54 "smp: make smp_call_function_many() use logic
similar to smp_call_function_single()" has unified the way to handle
single and multiple cross-CPU function calls. Now only one interrupt
is needed for architecture specific code to support generic SMP function
call interfaces, so kill the redundant single function call interrupt.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Jiang Liu <liuj97@gmail.com>
---
 arch/ia64/kernel/smp.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/arch/ia64/kernel/smp.c b/arch/ia64/kernel/smp.c
index 9fcd4e6..0532909 100644
--- a/arch/ia64/kernel/smp.c
+++ b/arch/ia64/kernel/smp.c
@@ -62,8 +62,7 @@ static DEFINE_PER_CPU_SHARED_ALIGNED(unsigned short [NR_CPUS],
 
 #define IPI_CALL_FUNC		0
 #define IPI_CPU_STOP		1
-#define IPI_CALL_FUNC_SINGLE	2
-#define IPI_KDUMP_CPU_STOP	3
+#define IPI_KDUMP_CPU_STOP	2
 
 /* This needs to be cacheline aligned because it is written to by *other* CPUs.  */
 static DEFINE_PER_CPU_SHARED_ALIGNED(unsigned long, ipi_operation);
@@ -116,9 +115,6 @@ handle_IPI (int irq, void *dev_id)
 			case IPI_CALL_FUNC:
 				generic_smp_call_function_interrupt();
 				break;
-			case IPI_CALL_FUNC_SINGLE:
-				generic_smp_call_function_single_interrupt();
-				break;
 #ifdef CONFIG_KEXEC
 			case IPI_KDUMP_CPU_STOP:
 				unw_init_running(kdump_cpu_freeze, NULL);
@@ -318,7 +314,7 @@ smp_flush_tlb_mm (struct mm_struct *mm)
 
 void arch_send_call_function_single_ipi(int cpu)
 {
-	send_IPI_single(cpu, IPI_CALL_FUNC_SINGLE);
+	send_IPI_single(cpu, IPI_CALL_FUNC);
 }
 
 void arch_send_call_function_ipi_mask(const struct cpumask *mask)
-- 
1.8.1.2

