From: =?utf-8?q?S=2E=C3=87a=C4=9Flar=20Onur?= <caglar@pardus.org.tr>
Date: Thu, 14 Feb 2008 15:36:40 +0000
Subject: [PATCH 02/14] arch/ia64/kernel/: Use time_* macros
Message-Id: <1203003412-11594-3-git-send-email-caglar@pardus.org.tr>
List-Id: <linux-ia64.vger.kernel.org>
References: y
In-Reply-To: y
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: linux-kernel@vger.kernel.org
Cc: linux-ia64@vger.kernel.org, =?utf-8?q?S=2E=C3=87a=C4=9Flar=20Onur?= <caglar@pardus.org.tr>

The functions time_before, time_before_eq, time_after, and time_after_eq are more robust for comparing jiffies against other values.

So following patch implements usage of the time_after() & time_before() macros, defined at linux/jiffies.h, which deals with wrapping correctly

Cc: linux-ia64@vger.kernel.org
Signed-off-by: S.Çağlar Onur <caglar@pardus.org.tr>
---
 arch/ia64/kernel/irq_ia64.c  |    2 +-
 arch/ia64/kernel/mca.c       |    3 ++-
 arch/ia64/kernel/unaligned.c |    3 ++-
 3 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/kernel/irq_ia64.c b/arch/ia64/kernel/irq_ia64.c
index 0b52f19..5017a2d 100644
--- a/arch/ia64/kernel/irq_ia64.c
+++ b/arch/ia64/kernel/irq_ia64.c
@@ -405,7 +405,7 @@ ia64_handle_irq (ia64_vector vector, struct pt_regs *regs)
 			static unsigned char count;
 			static long last_time;
 
-			if (jiffies - last_time > 5*HZ)
+			if (time_after(jiffies, last_time + 5 * HZ))
 				count = 0;
 			if (++count < 5) {
 				last_time = jiffies;
diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index 6e17aed..9b03e32 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -69,6 +69,7 @@
  * 2007-04-27 Russ Anderson <rja@sgi.com>
  *	      Support multiple cpus going through OS_MCA in the same event.
  */
+#include <linux/jiffies.h>
 #include <linux/types.h>
 #include <linux/init.h>
 #include <linux/sched.h>
@@ -293,7 +294,7 @@ static void ia64_mlogbuf_dump_from_init(void)
 	if (mlogbuf_finished)
 		return;
 
-	if (mlogbuf_timestamp && (mlogbuf_timestamp + 30*HZ > jiffies)) {
+	if (mlogbuf_timestamp && time_before(jiffies, mlogbuf_timestamp + 30 * HZ)) {
 		printk(KERN_ERR "INIT: mlogbuf_dump is interrupted by INIT "
 			" and the system seems to be messed up.\n");
 		ia64_mlogbuf_finish(0);
diff --git a/arch/ia64/kernel/unaligned.c b/arch/ia64/kernel/unaligned.c
index 52f70bb..0bd0f46 100644
--- a/arch/ia64/kernel/unaligned.c
+++ b/arch/ia64/kernel/unaligned.c
@@ -13,6 +13,7 @@
  * 2001/08/13	Correct size of extended floats (float_fsz) from 16 to 10 bytes.
  * 2001/01/17	Add support emulation of unaligned kernel accesses.
  */
+#include <linux/jiffies.h>
 #include <linux/kernel.h>
 #include <linux/sched.h>
 #include <linux/tty.h>
@@ -1290,7 +1291,7 @@ within_logging_rate_limit (void)
 {
 	static unsigned long count, last_time;
 
-	if (jiffies - last_time > 5*HZ)
+	if (time_after(jiffies, last_time + 5 * HZ))
 		count = 0;
 	if (count < 5) {
 		last_time = jiffies;
-- 
1.5.3.7

