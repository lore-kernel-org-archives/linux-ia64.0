From: Avi Kivity <avi@qumranet.com>
Date: Thu, 19 Jul 2007 15:32:43 +0000
Subject: [PATCH] ia64: Allow smp_call_function_single() to current cpu
Message-Id: <11848591631239-git-send-email-avi@qumranet.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, kvm-devel@lists.sourceforge.net, Avi Kivity <avi@qumranet.com>

This removes the requirement for callers to get_cpu() to check in simple
cases.  i386 and x86_64 already received a similar treatment.

Signed-off-by: Avi Kivity <avi@qumranet.com>
---
 arch/ia64/kernel/smp.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/kernel/smp.c b/arch/ia64/kernel/smp.c
index b3a47f9..381f9bf 100644
--- a/arch/ia64/kernel/smp.c
+++ b/arch/ia64/kernel/smp.c
@@ -346,7 +346,7 @@ smp_flush_tlb_mm (struct mm_struct *mm)
 }
 
 /*
- * Run a function on another CPU
+ * Run a function on a specific CPU
  *  <func>	The function to run. This must be fast and non-blocking.
  *  <info>	An arbitrary pointer to pass to the function.
  *  <nonatomic>	Currently unused.
@@ -366,9 +366,11 @@ smp_call_function_single (int cpuid, void (*func) (void *info), void *info, int
 	int me = get_cpu(); /* prevent preemption and reschedule on another processor */
 
 	if (cpuid = me) {
-		printk(KERN_INFO "%s: trying to call self\n", __FUNCTION__);
+		local_irq_disable();
+		func(info);
+		local_irq_enable();
 		put_cpu();
-		return -EBUSY;
+		return 0;
 	}
 
 	data.func = func;
-- 
1.5.2.4

