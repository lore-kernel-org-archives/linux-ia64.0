From: Anna-Maria Gleixner <anna-maria@linutronix.de>
Date: Mon, 02 May 2016 11:49:14 +0000
Subject: [PATCH] ia64: Remove superfluous SMP function call
Message-Id: <1462189754-66482-1-git-send-email-anna-maria@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: rt@linutronix.de, Anna-Maria Gleixner <anna-maria@linutronix.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

Since commit 3b9d6da67e11 ("cpu/hotplug: Fix rollback during error-out
in __cpu_disable()") it is ensured that callbacks of CPU_ONLINE and
CPU_DOWN_PREPARE are processed on the hotplugged CPU. Due to this SMP
function calls are no longer required.

Replace smp_call_function_single() with a direct call to
ia64_mca_cmc_vector_adjust(). The function itselfs handles disable and
enable interrupts, therefore the smp_call_function_single() calling
convention is not preserved.

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
Signed-off-by: Anna-Maria Gleixner <anna-maria@linutronix.de>
---
 arch/ia64/kernel/mca.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -1904,13 +1904,10 @@ static int mca_cpu_callback(struct notif
 				      unsigned long action,
 				      void *hcpu)
 {
-	int hotcpu = (unsigned long) hcpu;
-
 	switch (action) {
 	case CPU_ONLINE:
 	case CPU_ONLINE_FROZEN:
-		smp_call_function_single(hotcpu, ia64_mca_cmc_vector_adjust,
-					 NULL, 0);
+		ia64_mca_cmc_vector_adjust(NULL);
 		break;
 	}
 	return NOTIFY_OK;
