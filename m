From: Dimitri Sivanich <sivanich@sgi.com>
Date: Thu, 07 Oct 2010 14:39:41 +0000
Subject: [PATCH] SGI Altix IA64 mmtimer: Eliminate long interval timer
Message-Id: <20101007143941.GA10653@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch for SGI Altix/IA64 eliminates interval long timer holdoffs in
cases where we don't start an interval timer before the expiration time.
This sometimes happens when a number of interval timers on the same shub
with the same interval run simultaneously.

Signed-off-by: Dimitri Sivanich <sivanich@sgi.com>

---
 drivers/char/mmtimer.c |   55 ++++++++++++++++++++++-----------------------
 1 file changed, 27 insertions(+), 28 deletions(-)

Index: linux-2.6/drivers/char/mmtimer.c
=================================--- linux-2.6.orig/drivers/char/mmtimer.c	2010-10-07 09:34:29.837725250 -0500
+++ linux-2.6/drivers/char/mmtimer.c	2010-10-07 09:34:31.609948769 -0500
@@ -174,9 +174,8 @@ static void mmtimer_setup_int_2(int cpu,
  * in order to insure that the setup succeeds in a deterministic time frame.
  * It will check if the interrupt setup succeeded.
  */
-static int mmtimer_setup(int cpu, int comparator, unsigned long expires)
+static int mmtimer_setup(int cpu, int comparator, unsigned long expires, u64 *r)
 {
-
 	switch (comparator) {
 	case 0:
 		mmtimer_setup_int_0(cpu, expires);
@@ -189,7 +188,8 @@ static int mmtimer_setup(int cpu, int co
 		break;
 	}
 	/* We might've missed our expiration time */
-	if (rtc_time() <= expires)
+	*r = rtc_time();
+	if (*r <= expires)
 		return 1;
 
 	/*
@@ -225,6 +225,8 @@ static int mmtimer_disable_int(long nasi
 #define TIMER_OFF	0xbadcabLL	/* Timer is not setup */
 #define TIMER_SET	0		/* Comparator is set for this timer */
 
+#define MMTIMER_INTRVL_RETRY_INCR_DEFAULT 40
+
 /* There is one of these for each timer */
 struct mmtimer {
 	struct rb_node list;
@@ -240,6 +242,10 @@ struct mmtimer_node {
 };
 static struct mmtimer_node *timers;
 
+static unsigned mmtimer_intrvl_retry_incr = MMTIMER_INTRVL_RETRY_INCR_DEFAULT;
+module_param(mmtimer_intrvl_retry_incr, uint, 0644);
+MODULE_PARM_DESC(mmtimer_intrvl_retry_incr,
+	"RTC ticks to add to expiration on interval retry (default 40)");
 
 /*
  * Add a new mmtimer struct to the node's mmtimer list.
@@ -287,7 +293,8 @@ static void mmtimer_set_next_timer(int n
 	struct mmtimer_node *n = &timers[nodeid];
 	struct mmtimer *x;
 	struct k_itimer *t;
-	int o;
+	u64 expires, exp, r;
+	int i;
 
 restart:
 	if (n->next = NULL)
@@ -298,7 +305,7 @@ restart:
 	if (!t->it.mmtimer.incr) {
 		/* Not an interval timer */
 		if (!mmtimer_setup(x->cpu, COMPARATOR,
-					t->it.mmtimer.expires)) {
+					t->it.mmtimer.expires, &r)) {
 			/* Late setup, fire now */
 			tasklet_schedule(&n->tasklet);
 		}
@@ -306,14 +313,21 @@ restart:
 	}
 
 	/* Interval timer */
-	o = 0;
-	while (!mmtimer_setup(x->cpu, COMPARATOR, t->it.mmtimer.expires)) {
-		unsigned long e, e1;
-		struct rb_node *next;
-		t->it.mmtimer.expires += t->it.mmtimer.incr << o;
-		t->it_overrun += 1 << o;
-		o++;
-		if (o > 20) {
+	i = 0;
+	expires = exp = t->it.mmtimer.expires;
+	while (!mmtimer_setup(x->cpu, COMPARATOR, expires, &r)) {
+		int to;
+
+		i++;
+		expires = r + mmtimer_intrvl_retry_incr + (1 << i);
+		/* Calculate overruns as we go. */
+		to = ((u64)(expires - exp) / t->it.mmtimer.incr);
+		if (to) {
+			t->it_overrun += to;
+			t->it.mmtimer.expires += t->it.mmtimer.incr * to;
+			exp = t->it.mmtimer.expires;
+		}
+		if (i > 20) {
 			printk(KERN_ALERT "mmtimer: cannot reschedule timer\n");
 			t->it.mmtimer.clock = TIMER_OFF;
 			n->next = rb_next(&x->list);
@@ -321,21 +335,6 @@ restart:
 			kfree(x);
 			goto restart;
 		}
-
-		e = t->it.mmtimer.expires;
-		next = rb_next(&x->list);
-
-		if (next = NULL)
-			continue;
-
-		e1 = rb_entry(next, struct mmtimer, list)->
-			timer->it.mmtimer.expires;
-		if (e > e1) {
-			n->next = next;
-			rb_erase(&x->list, &n->timer_head);
-			mmtimer_add_list(x);
-			goto restart;
-		}
 	}
 }
 
