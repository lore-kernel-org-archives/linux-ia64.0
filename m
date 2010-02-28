From: Akinobu Mita <akinobu.mita@gmail.com>
Date: Sun, 28 Feb 2010 10:58:14 +0000
Subject: [PATCH] ia64: use __ratelimit
Message-Id: <1267354697-6456-2-git-send-email-akinobu.mita@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1267354697-6456-1-git-send-email-akinobu.mita@gmail.com>
In-Reply-To: <1267354697-6456-1-git-send-email-akinobu.mita@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Akinobu Mita <akinobu.mita@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

Replace open-coded rate limiting logic with __ratelimit().

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/kernel/irq_ia64.c  |    9 +++------
 arch/ia64/kernel/unaligned.c |   24 +++++-------------------
 2 files changed, 8 insertions(+), 25 deletions(-)

diff --git a/arch/ia64/kernel/irq_ia64.c b/arch/ia64/kernel/irq_ia64.c
index d4093a1..d5150d0 100644
--- a/arch/ia64/kernel/irq_ia64.c
+++ b/arch/ia64/kernel/irq_ia64.c
@@ -30,6 +30,7 @@
 #include <linux/threads.h>
 #include <linux/bitops.h>
 #include <linux/irq.h>
+#include <linux/ratelimit.h>
 
 #include <asm/delay.h>
 #include <asm/intrinsics.h>
@@ -468,13 +469,9 @@ ia64_handle_irq (ia64_vector vector, struct pt_regs *regs)
 		sp = ia64_getreg(_IA64_REG_SP);
 
 		if ((sp - bsp) < 1024) {
-			static unsigned char count;
-			static long last_time;
+			static DEFINE_RATELIMIT_STATE(ratelimit, 5 * HZ, 5);
 
-			if (time_after(jiffies, last_time + 5 * HZ))
-				count = 0;
-			if (++count < 5) {
-				last_time = jiffies;
+			if (__ratelimit(&ratelimit)) {
 				printk("ia64_handle_irq: DANGER: less than "
 				       "1KB of free stack space!!\n"
 				       "(bsp=0x%lx, sp=%lx)\n", bsp, sp);
diff --git a/arch/ia64/kernel/unaligned.c b/arch/ia64/kernel/unaligned.c
index 776dd40..622772b 100644
--- a/arch/ia64/kernel/unaligned.c
+++ b/arch/ia64/kernel/unaligned.c
@@ -17,6 +17,7 @@
 #include <linux/kernel.h>
 #include <linux/sched.h>
 #include <linux/tty.h>
+#include <linux/ratelimit.h>
 
 #include <asm/intrinsics.h>
 #include <asm/processor.h>
@@ -1283,24 +1284,9 @@ emulate_store_float (unsigned long ifa, load_store_t ld, struct pt_regs *regs)
 /*
  * Make sure we log the unaligned access, so that user/sysadmin can notice it and
  * eventually fix the program.  However, we don't want to do that for every access so we
- * pace it with jiffies.  This isn't really MP-safe, but it doesn't really have to be
- * either...
+ * pace it with jiffies.
  */
-static int
-within_logging_rate_limit (void)
-{
-	static unsigned long count, last_time;
-
-	if (time_after(jiffies, last_time + 5 * HZ))
-		count = 0;
-	if (count < 5) {
-		last_time = jiffies;
-		count++;
-		return 1;
-	}
-	return 0;
-
-}
+static DEFINE_RATELIMIT_STATE(logging_rate_limit, 5 * HZ, 5);
 
 void
 ia64_handle_unaligned (unsigned long ifa, struct pt_regs *regs)
@@ -1337,7 +1323,7 @@ ia64_handle_unaligned (unsigned long ifa, struct pt_regs *regs)
 
 		if (!no_unaligned_warning &&
 		    !(current->thread.flags & IA64_THREAD_UAC_NOPRINT) &&
-		    within_logging_rate_limit())
+		    __ratelimit(&logging_rate_limit))
 		{
 			char buf[200];	/* comm[] is at most 16 bytes... */
 			size_t len;
@@ -1370,7 +1356,7 @@ ia64_handle_unaligned (unsigned long ifa, struct pt_regs *regs)
 			}
 		}
 	} else {
-		if (within_logging_rate_limit()) {
+		if (__ratelimit(&logging_rate_limit)) {
 			printk(KERN_WARNING "kernel unaligned access to 0x%016lx, ip=0x%016lx\n",
 			       ifa, regs->cr_iip + ipsr->ri);
 			if (unaligned_dump_stack)
-- 
1.6.0.6

