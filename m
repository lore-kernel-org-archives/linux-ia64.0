From: Dimitri Sivanich <sivanich@sgi.com>
Date: Thu, 07 Feb 2008 21:35:52 +0000
Subject: [PATCH] SGI Altix mmtimer - allow larger number of timers per node
Message-Id: <20080207213552.GA2658@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch to the SGI Altix specific mmtimer driver is to allow a
virtually infinite number of timers to be set per node.

Timers will now be kept on a sorted per-node list and a single node-based
hardware comparator is used to trigger the next timer.

Signed-off-by: Dimitri Sivanich <sivanich@sgi.com>


Index: linux/drivers/char/mmtimer.c
=================================--- linux.orig/drivers/char/mmtimer.c	2008-01-24 16:58:37.000000000 -0600
+++ linux/drivers/char/mmtimer.c	2008-02-07 14:51:15.158550577 -0600
@@ -74,7 +74,6 @@ static const struct file_operations mmti
  * We only have comparison registers RTC1-4 currently available per
  * node.  RTC0 is used by SAL.
  */
-#define NUM_COMPARATORS 3
 /* Check for an RTC interrupt pending */
 static int inline mmtimer_int_pending(int comparator)
 {
@@ -92,7 +91,7 @@ static void inline mmtimer_clr_int_pendi
 }
 
 /* Setup timer on comparator RTC1 */
-static void inline mmtimer_setup_int_0(u64 expires)
+static void inline mmtimer_setup_int_0(int cpu, u64 expires)
 {
 	u64 val;
 
@@ -106,7 +105,7 @@ static void inline mmtimer_setup_int_0(u
 	mmtimer_clr_int_pending(0);
 
 	val = ((u64)SGI_MMTIMER_VECTOR << SH_RTC1_INT_CONFIG_IDX_SHFT) |
-		((u64)cpu_physical_id(smp_processor_id()) <<
+		((u64)cpu_physical_id(cpu) <<
 			SH_RTC1_INT_CONFIG_PID_SHFT);
 
 	/* Set configuration */
@@ -122,7 +121,7 @@ static void inline mmtimer_setup_int_0(u
 }
 
 /* Setup timer on comparator RTC2 */
-static void inline mmtimer_setup_int_1(u64 expires)
+static void inline mmtimer_setup_int_1(int cpu, u64 expires)
 {
 	u64 val;
 
@@ -133,7 +132,7 @@ static void inline mmtimer_setup_int_1(u
 	mmtimer_clr_int_pending(1);
 
 	val = ((u64)SGI_MMTIMER_VECTOR << SH_RTC2_INT_CONFIG_IDX_SHFT) |
-		((u64)cpu_physical_id(smp_processor_id()) <<
+		((u64)cpu_physical_id(cpu) <<
 			SH_RTC2_INT_CONFIG_PID_SHFT);
 
 	HUB_S((u64 *)LOCAL_MMR_ADDR(SH_RTC2_INT_CONFIG), val);
@@ -144,7 +143,7 @@ static void inline mmtimer_setup_int_1(u
 }
 
 /* Setup timer on comparator RTC3 */
-static void inline mmtimer_setup_int_2(u64 expires)
+static void inline mmtimer_setup_int_2(int cpu, u64 expires)
 {
 	u64 val;
 
@@ -155,7 +154,7 @@ static void inline mmtimer_setup_int_2(u
 	mmtimer_clr_int_pending(2);
 
 	val = ((u64)SGI_MMTIMER_VECTOR << SH_RTC3_INT_CONFIG_IDX_SHFT) |
-		((u64)cpu_physical_id(smp_processor_id()) <<
+		((u64)cpu_physical_id(cpu) <<
 			SH_RTC3_INT_CONFIG_PID_SHFT);
 
 	HUB_S((u64 *)LOCAL_MMR_ADDR(SH_RTC3_INT_CONFIG), val);
@@ -170,18 +169,18 @@ static void inline mmtimer_setup_int_2(u
  * in order to insure that the setup succeeds in a deterministic time frame.
  * It will check if the interrupt setup succeeded.
  */
-static int inline mmtimer_setup(int comparator, unsigned long expires)
+static int inline mmtimer_setup(int cpu, int comparator, unsigned long expires)
 {
 
 	switch (comparator) {
 	case 0:
-		mmtimer_setup_int_0(expires);
+		mmtimer_setup_int_0(cpu, expires);
 		break;
 	case 1:
-		mmtimer_setup_int_1(expires);
+		mmtimer_setup_int_1(cpu, expires);
 		break;
 	case 2:
-		mmtimer_setup_int_2(expires);
+		mmtimer_setup_int_2(cpu, expires);
 		break;
 	}
 	/* We might've missed our expiration time */
@@ -216,18 +215,100 @@ static int inline mmtimer_disable_int(lo
 	return 0;
 }
 
-#define TIMER_OFF 0xbadcabLL
+#define COMPARATOR	1		/* The comparator to use */
 
-/* There is one of these for each comparator */
+#define TIMER_OFF	0xbadcabLL	/* Timer is not setup */
+#define TIMER_LIST	-1		/* Timer is on a node list */
+#define TIMER_SET	0		/* Comparator is set for this timer */
+
+/* There is one of these for each timer */
 typedef struct mmtimer {
-	spinlock_t lock ____cacheline_aligned;
+	struct list_head list ____cacheline_aligned;
 	struct k_itimer *timer;
-	int i;
 	int cpu;
-	struct tasklet_struct tasklet;
 } mmtimer_t;
 
-static mmtimer_t ** timers;
+typedef struct mmtimer_node {
+	spinlock_t lock ____cacheline_aligned;
+	mmtimer_t timer_head;
+	mmtimer_t * ctimer;
+	struct tasklet_struct tasklet;
+} mmtimer_node_t;
+static mmtimer_node_t * timers;
+
+
+/*
+ * Add a new mmtimer_t to the node's mmtimer list.
+ * This function assumes the mmtimer_node_t is locked.
+ */
+void mmtimer_add_list(mmtimer_t * n) {
+	mmtimer_t * x = NULL;
+	unsigned long expires = n->timer->it.mmtimer.expires;
+	int nodeid = n->timer->it.mmtimer.node;
+
+	/* Add the new mmtimer_t to node's timer list */
+	if (list_empty(&timers[nodeid].timer_head.list)) {
+		/* Add to head of the list. */
+		list_add(&n->list, &timers[nodeid].timer_head.list);
+		return;
+	}
+
+	list_for_each_entry(x, &timers[nodeid].timer_head.list, list) {
+		struct k_itimer * tt = x->timer;
+		if (expires < tt->it.mmtimer.expires) {
+			list_add_tail(&n->list, &x->list);
+			return;
+		}
+		if (list_is_last(&x->list, &timers[nodeid].timer_head.list)) {
+			list_add(&n->list, &x->list);
+			return;
+		}
+	}
+}
+
+/*
+ * Set the comparator for the next timer.
+ * This function assumes the mmtimer_node_t is locked.
+ */
+void mmtimer_set_next_timer(int nodeid) {
+	mmtimer_node_t * n = &timers[nodeid];
+	mmtimer_t * x, * y;
+	struct k_itimer *t;
+
+	/* Set comparator for next timer, if there is one */
+	list_for_each_entry_safe(x, y, &n->timer_head.list, list) {
+		int o = 0;
+
+		n->ctimer = x;
+		t = x->timer;
+		t->it.mmtimer.clock = TIMER_SET;
+		if (!t->it.mmtimer.incr) {
+			/* Not an interval timer */
+			if (!mmtimer_setup(x->cpu, COMPARATOR,
+						t->it.mmtimer.expires)) {
+					/* Late setup, fire now */
+					tasklet_schedule(&n->tasklet);
+			}
+			break;
+		}
+
+		/* Interval timer */
+		while (!mmtimer_setup(x->cpu, COMPARATOR,
+				t->it.mmtimer.expires)) {
+			t->it.mmtimer.expires += t->it.mmtimer.incr << o;
+			t->it_overrun += 1 << o;
+			o++;
+			if (o > 20) {
+				printk(KERN_ALERT "mmtimer: cannot reschedule interval timer\n");
+				n->ctimer = NULL;
+				t->it.mmtimer.clock = TIMER_OFF;
+				list_del(&x->list);
+				break;
+			}
+		}
+		if (o <= 20) break;
+	}
+}
 
 /**
  * mmtimer_ioctl - ioctl interface for /dev/mmtimer
@@ -390,35 +471,6 @@ static int sgi_clock_set(clockid_t clock
 	return 0;
 }
 
-/*
- * Schedule the next periodic interrupt. This function will attempt
- * to schedule a periodic interrupt later if necessary. If the scheduling
- * of an interrupt fails then the time to skip is lengthened
- * exponentially in order to ensure that the next interrupt
- * can be properly scheduled..
- */
-static int inline reschedule_periodic_timer(mmtimer_t *x)
-{
-	int n;
-	struct k_itimer *t = x->timer;
-
-	t->it.mmtimer.clock = x->i;
-	t->it_overrun--;
-
-	n = 0;
-	do {
-
-		t->it.mmtimer.expires += t->it.mmtimer.incr << n;
-		t->it_overrun += 1 << n;
-		n++;
-		if (n > 20)
-			return 1;
-
-	} while (!mmtimer_setup(x->i, t->it.mmtimer.expires));
-
-	return 0;
-}
-
 /**
  * mmtimer_interrupt - timer interrupt handler
  * @irq: irq received
@@ -435,70 +487,84 @@ static int inline reschedule_periodic_ti
 static irqreturn_t
 mmtimer_interrupt(int irq, void *dev_id)
 {
-	int i;
 	unsigned long expires = 0;
 	int result = IRQ_NONE;
 	unsigned indx = cpu_to_node(smp_processor_id());
+	mmtimer_t *base;
 
-	/*
-	 * Do this once for each comparison register
-	 */
-	for (i = 0; i < NUM_COMPARATORS; i++) {
-		mmtimer_t *base = timers[indx] + i;
-		/* Make sure this doesn't get reused before tasklet_sched */
-		spin_lock(&base->lock);
-		if (base->cpu = smp_processor_id()) {
-			if (base->timer)
-				expires = base->timer->it.mmtimer.expires;
-			/* expires test won't work with shared irqs */
-			if ((mmtimer_int_pending(i) > 0) ||
-				(expires && (expires < rtc_time()))) {
-				mmtimer_clr_int_pending(i);
-				tasklet_schedule(&base->tasklet);
-				result = IRQ_HANDLED;
-			}
+	spin_lock(&timers[indx].lock);
+	base = timers[indx].ctimer;
+
+	if (base = NULL) {
+		spin_unlock(&timers[indx].lock);
+		return result;
+	}
+
+	if (base->cpu = smp_processor_id()) {
+		if (base->timer)
+			expires = base->timer->it.mmtimer.expires;
+		/* expires test won't work with shared irqs */
+		if ((mmtimer_int_pending(COMPARATOR) > 0) ||
+			(expires && (expires < rtc_time()))) {
+			mmtimer_clr_int_pending(COMPARATOR);
+			tasklet_schedule(&timers[indx].tasklet);
+			result = IRQ_HANDLED;
 		}
-		spin_unlock(&base->lock);
-		expires = 0;
 	}
+	spin_unlock(&timers[indx].lock);
 	return result;
 }
 
 void mmtimer_tasklet(unsigned long data) {
-	mmtimer_t *x = (mmtimer_t *)data;
-	struct k_itimer *t = x->timer;
+	int nodeid = data;
+	mmtimer_node_t * mn = &timers[nodeid];
+	mmtimer_t *x = mn->ctimer;
+	struct k_itimer *t;
 	unsigned long flags;
 
+	if (x = NULL)
+		return;
+
+	t = x->timer;
 	if (t = NULL)
 		return;
 
 	/* Send signal and deal with periodic signals */
 	spin_lock_irqsave(&t->it_lock, flags);
-	spin_lock(&x->lock);
-	/* If timer was deleted between interrupt and here, leave */
-	if (t != x->timer)
+	spin_lock(&mn->lock);
+	if (mn->ctimer != x)
 		goto out;
-	t->it_overrun = 0;
 
-	if (posix_timer_event(t, 0) != 0) {
+	if (x->timer != t || t->it.mmtimer.clock = TIMER_OFF)
+		goto out;
 
-		// printk(KERN_WARNING "mmtimer: cannot deliver signal.\n");
+	t->it_overrun = 0;
+
+	mn->ctimer = NULL;
+	list_del(&x->list);
+	spin_unlock(&mn->lock);
 
+	if (posix_timer_event(t, 0) != 0) {
 		t->it_overrun++;
 	}
+
 	if(t->it.mmtimer.incr) {
-		/* Periodic timer */
-		if (reschedule_periodic_timer(x)) {
-			printk(KERN_WARNING "mmtimer: unable to reschedule\n");
-			x->timer = NULL;
-		}
+		t->it.mmtimer.expires += t->it.mmtimer.incr;
+		spin_lock(&mn->lock);
+		mmtimer_add_list(x);
 	} else {
 		/* Ensure we don't false trigger in mmtimer_interrupt */
+		t->it.mmtimer.clock = TIMER_OFF;
 		t->it.mmtimer.expires = 0;
+		kfree(x);
+		spin_lock(&mn->lock);
 	}
+	/* Set comparator for next timer, if there is one */
+	mmtimer_set_next_timer(nodeid);
+
 	t->it_overrun_last = t->it_overrun;
 out:
-	spin_unlock(&x->lock);
+	spin_unlock(&mn->lock);
 	spin_unlock_irqrestore(&t->it_lock, flags);
 }
 
@@ -516,19 +582,33 @@ static int sgi_timer_create(struct k_iti
  */
 static int sgi_timer_del(struct k_itimer *timr)
 {
-	int i = timr->it.mmtimer.clock;
+	int clock = timr->it.mmtimer.clock;
 	cnodeid_t nodeid = timr->it.mmtimer.node;
-	mmtimer_t *t = timers[nodeid] + i;
+	mmtimer_t *t;
 	unsigned long irqflags;
 
-	if (i != TIMER_OFF) {
-		spin_lock_irqsave(&t->lock, irqflags);
-		mmtimer_disable_int(cnodeid_to_nasid(nodeid),i);
-		t->timer = NULL;
+	spin_lock_irqsave(&timers[nodeid].lock, irqflags);
+	if (clock != TIMER_OFF) {
+		list_for_each_entry(t, &timers[nodeid].timer_head.list, list) {
+			if (t->timer = timr)
+				break;
+		}
+		if (t->timer != timr) {
+			spin_unlock_irqrestore(&timers[nodeid].lock, irqflags);
+			return 0;
+		}
+		list_del(&t->list);
+		kfree(t);
 		timr->it.mmtimer.clock = TIMER_OFF;
 		timr->it.mmtimer.expires = 0;
-		spin_unlock_irqrestore(&t->lock, irqflags);
+		if (clock = TIMER_SET) {
+			mmtimer_disable_int(cnodeid_to_nasid(nodeid),
+				COMPARATOR);
+			timers[nodeid].ctimer = NULL;
+			mmtimer_set_next_timer(nodeid);
+		}
 	}
+	spin_unlock_irqrestore(&timers[nodeid].lock, irqflags);
 	return 0;
 }
 
@@ -557,8 +637,7 @@ static int sgi_timer_set(struct k_itimer
 	struct itimerspec * new_setting,
 	struct itimerspec * old_setting)
 {
-
-	int i;
+	int o = 0;
 	unsigned long when, period, irqflags;
 	int err = 0;
 	cnodeid_t nodeid;
@@ -575,6 +654,10 @@ static int sgi_timer_set(struct k_itimer
 		/* Clear timer */
 		return 0;
 
+	base = kmalloc(sizeof(mmtimer_t), GFP_KERNEL);
+	if (base = NULL)
+		return -ENOMEM;
+
 	if (flags & TIMER_ABSTIME) {
 		struct timespec n;
 		unsigned long now;
@@ -604,47 +687,60 @@ static int sgi_timer_set(struct k_itimer
 	preempt_disable();
 
 	nodeid =  cpu_to_node(smp_processor_id());
-retry:
-	/* Don't use an allocated timer, or a deleted one that's pending */
-	for(i = 0; i< NUM_COMPARATORS; i++) {
-		base = timers[nodeid] + i;
-		if (!base->timer && !base->tasklet.state) {
-			break;
-		}
-	}
 
-	if (i = NUM_COMPARATORS) {
-		preempt_enable();
-		return -EBUSY;
-	}
-
-	spin_lock_irqsave(&base->lock, irqflags);
+	/* Lock the node timer structure */
+	spin_lock_irqsave(&timers[nodeid].lock, irqflags);
 
-	if (base->timer || base->tasklet.state != 0) {
-		spin_unlock_irqrestore(&base->lock, irqflags);
-		goto retry;
-	}
 	base->timer = timr;
 	base->cpu = smp_processor_id();
 
-	timr->it.mmtimer.clock = i;
+	timr->it.mmtimer.clock = TIMER_LIST;
 	timr->it.mmtimer.node = nodeid;
 	timr->it.mmtimer.incr = period;
 	timr->it.mmtimer.expires = when;
 
+	/* Add the new mmtimer_t to node's timer list */
+	mmtimer_add_list(base);
+
+	if ((mmtimer_t *)timers[nodeid].timer_head.list.next != base) {
+		/* No need to reprogram comparator for now */
+		preempt_enable();
+		spin_unlock_irqrestore(&timers[nodeid].lock, irqflags);
+		return err;
+	}
+
+	/* We need to reprogram the comparator */
+	if (!list_is_last(&base->list, &timers[nodeid].timer_head.list)) {
+		/* There was a previous entry */
+		mmtimer_disable_int(cnodeid_to_nasid(nodeid), COMPARATOR);
+		timers[nodeid].ctimer->timer->it.mmtimer.clock = TIMER_LIST;
+	}
+
+	timers[nodeid].ctimer = base;
+	timr->it.mmtimer.clock = TIMER_SET;
+
 	if (period = 0) {
-		if (!mmtimer_setup(i, when)) {
-			mmtimer_disable_int(-1, i);
-			posix_timer_event(timr, 0);
-			timr->it.mmtimer.expires = 0;
+		if (!mmtimer_setup(base->cpu, COMPARATOR, when)) {
+			tasklet_schedule(&timers[nodeid].tasklet);
 		}
-	} else {
-		timr->it.mmtimer.expires -= period;
-		if (reschedule_periodic_timer(base))
+	} else while (!mmtimer_setup(base->cpu, COMPARATOR,
+			timr->it.mmtimer.expires)) {
+		/* Interval timer */
+		timr->it.mmtimer.expires += timr->it.mmtimer.incr << o;
+		timr->it_overrun += 1 << o;
+		o++;
+		if (o > 20) {
+			printk(KERN_ALERT "mmtimer: cannot reschedule interval timer\n");
+			timers[nodeid].ctimer = NULL;
+			timr->it.mmtimer.clock = TIMER_OFF;
+			list_del(&base->list);
 			err = -EINVAL;
+			break;
+		}
 	}
 
-	spin_unlock_irqrestore(&base->lock, irqflags);
+	/* Unlock the node timer structure */
+	spin_unlock_irqrestore(&timers[nodeid].lock, irqflags);
 
 	preempt_enable();
 
@@ -669,7 +765,6 @@ static struct k_clock sgi_clock = {
  */
 static int __init mmtimer_init(void)
 {
-	unsigned i;
 	cnodeid_t node, maxn = -1;
 
 	if (!ia64_platform_is("sn2"))
@@ -706,7 +801,7 @@ static int __init mmtimer_init(void)
 	maxn++;
 
 	/* Allocate list of node ptrs to mmtimer_t's */
-	timers = kzalloc(sizeof(mmtimer_t *)*maxn, GFP_KERNEL);
+	timers = kzalloc(sizeof(mmtimer_node_t)*maxn, GFP_KERNEL);
 	if (timers = NULL) {
 		printk(KERN_ERR "%s: failed to allocate memory for device\n",
 				MMTIMER_NAME);
@@ -715,22 +810,14 @@ static int __init mmtimer_init(void)
 
 	/* Allocate mmtimer_t's for each online node */
 	for_each_online_node(node) {
-		timers[node] = kmalloc_node(sizeof(mmtimer_t)*NUM_COMPARATORS, GFP_KERNEL, node);
-		if (timers[node] = NULL) {
-			printk(KERN_ERR "%s: failed to allocate memory for device\n",
-				MMTIMER_NAME);
-			goto out4;
-		}
-		for (i=0; i< NUM_COMPARATORS; i++) {
-			mmtimer_t * base = timers[node] + i;
-
-			spin_lock_init(&base->lock);
-			base->timer = NULL;
-			base->cpu = 0;
-			base->i = i;
-			tasklet_init(&base->tasklet, mmtimer_tasklet,
-				(unsigned long) (base));
-		}
+		mmtimer_t * base = &timers[node].timer_head;
+		timers[node].ctimer = NULL;
+		spin_lock_init(&timers[node].lock);
+		INIT_LIST_HEAD(&base->list);
+		base->timer = NULL;
+		base->cpu = 0;
+		tasklet_init(&timers[node].tasklet, mmtimer_tasklet,
+			(unsigned long) node);
 	}
 
 	sgi_clock_period = sgi_clock.res = NSEC_PER_SEC / sn_rtc_cycles_per_second;
@@ -741,11 +828,8 @@ static int __init mmtimer_init(void)
 
 	return 0;
 
-out4:
-	for_each_online_node(node) {
-		kfree(timers[node]);
-	}
 out3:
+	kfree(timers);
 	misc_deregister(&mmtimer_miscdev);
 out2:
 	free_irq(SGI_MMTIMER_VECTOR, NULL);
@@ -754,4 +838,3 @@ out1:
 }
 
 module_init(mmtimer_init);
-
