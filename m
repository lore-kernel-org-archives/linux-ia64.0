From: "Robert P. J. Day" <rpjday@crashcourse.ca>
Date: Sat, 29 Mar 2008 14:05:30 +0000
Subject: [PATCH] IA64: Replace explicit jiffies tests with time_* macros.
Message-Id: <alpine.LFD.1.00.0803291003500.21459@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Signed-off-by: Robert P. J. Day <rpjday@crashcourse.ca>

---

  not compile tested, but the transformations look pretty
straightforward.


 arch/ia64/sn/kernel/xpc_main.c      |    8 ++++----
 arch/ia64/sn/kernel/xpc_partition.c |    2 +-
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/arch/ia64/sn/kernel/xpc_main.c b/arch/ia64/sn/kernel/xpc_main.c
index 81785b7..9e0b164 100644
--- a/arch/ia64/sn/kernel/xpc_main.c
+++ b/arch/ia64/sn/kernel/xpc_main.c
@@ -199,7 +199,7 @@ xpc_timeout_partition_disengage_request(unsigned long data)
 	struct xpc_partition *part = (struct xpc_partition *) data;


-	DBUG_ON(jiffies < part->disengage_request_timeout);
+	DBUG_ON(time_before(jiffies, part->disengage_request_timeout));

 	(void) xpc_partition_disengaged(part);

@@ -230,7 +230,7 @@ xpc_hb_beater(unsigned long dummy)
 {
 	xpc_vars->heartbeat++;

-	if (jiffies >= xpc_hb_check_timeout) {
+	if (time_after_eq(jiffies, xpc_hb_check_timeout)) {
 		wake_up_interruptible(&xpc_act_IRQ_wq);
 	}

@@ -270,7 +270,7 @@ xpc_hb_checker(void *ignore)


 		/* checking of remote heartbeats is skewed by IRQ handling */
-		if (jiffies >= xpc_hb_check_timeout) {
+		if (time_after_eq(jiffies, xpc_hb_check_timeout)) {
 			dev_dbg(xpc_part, "checking remote heartbeats\n");
 			xpc_check_remote_hb();

@@ -305,7 +305,7 @@ xpc_hb_checker(void *ignore)
 		/* wait for IRQ or timeout */
 		(void) wait_event_interruptible(xpc_act_IRQ_wq,
 			    (last_IRQ_count < atomic_read(&xpc_act_IRQ_rcvd) ||
-					jiffies >= xpc_hb_check_timeout ||
+					time_after_eq(jiffies, xpc_hb_check_timeout) ||
 						(volatile int) xpc_exiting));
 	}

diff --git a/arch/ia64/sn/kernel/xpc_partition.c b/arch/ia64/sn/kernel/xpc_partition.c
index 7ba4032..9e97c26 100644
--- a/arch/ia64/sn/kernel/xpc_partition.c
+++ b/arch/ia64/sn/kernel/xpc_partition.c
@@ -877,7 +877,7 @@ xpc_partition_disengaged(struct xpc_partition *part)
 	disengaged = (xpc_partition_engaged(1UL << partid) = 0);
 	if (part->disengage_request_timeout) {
 		if (!disengaged) {
-			if (jiffies < part->disengage_request_timeout) {
+			if (time_before(jiffies, part->disengage_request_timeout)) {
 				/* timelimit hasn't been reached yet */
 				return 0;
 			}

====================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry:
    Have classroom, will lecture.

http://crashcourse.ca                          Waterloo, Ontario, CANADA
====================================
