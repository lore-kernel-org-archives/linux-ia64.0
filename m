From: Nishanth Aravamudan <nacc@us.ibm.com>
Date: Mon, 15 Aug 2005 18:12:47 +0000
Subject: [-mm PATCH 09/32] ia64: fix-up schedule_timeout() usage
Message-Id: <20050815181247.GL2854@us.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Description: Use schedule_timeout_interruptible() instead of
set_current_state()/schedule_timeout() to reduce kernel size.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

---

 arch/ia64/hp/sim/simserial.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff -urpN 2.6.13-rc5-mm1/arch/ia64/hp/sim/simserial.c 2.6.13-rc5-mm1-dev/arch/ia64/hp/sim/simserial.c
--- 2.6.13-rc5-mm1/arch/ia64/hp/sim/simserial.c	2005-08-07 09:57:44.000000000 -0700
+++ 2.6.13-rc5-mm1-dev/arch/ia64/hp/sim/simserial.c	2005-08-08 13:53:42.000000000 -0700
@@ -642,10 +642,8 @@ static void rs_close(struct tty_struct *
 	info->event = 0;
 	info->tty = 0;
 	if (info->blocked_open) {
-		if (info->close_delay) {
-			current->state = TASK_INTERRUPTIBLE;
-			schedule_timeout(info->close_delay);
-		}
+		if (info->close_delay)
+			schedule_timeout_interruptible(info->close_delay);
 		wake_up_interruptible(&info->open_wait);
 	}
 	info->flags &= ~(ASYNC_NORMAL_ACTIVE|ASYNC_CLOSING);
