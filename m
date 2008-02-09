From: Dimitri Sivanich <sivanich@sgi.com>
Date: Sat, 09 Feb 2008 21:49:17 +0000
Subject: Re: [PATCH] SGI Altix mmtimer - allow larger number of timers per node
Message-Id: <20080209214917.GA31134@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080207213552.GA2658@sgi.com>
In-Reply-To: <20080207213552.GA2658@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Feb 07, 2008 at 02:08:59PM -0800, Andrew Morton wrote:
> 
> erk.  Please feed this diff (and all future diffs) through
> scripts/checkpatch.pl.  This patch sends it wild.

All checkpatch.pl complaints have been fixed.

> 
> hm.  Is the ____cacheline_aligned on a struct member actually meaningful
> and useful?  I guess it had some rationale when it was on a spinlock, but
> what's it there for now?

I decided that wasn't still needed.

> 
> While you're there, please consider removing the mmtimer_t typedef
> altogether and using "struct mmtimer" everywhere.

We're now consistently using 'struct mmtimer' and 'struct mmtimer_node'.

> 
> That's a linear search?  Experience tells us that each time we add an O(n)
> algorith to the kernel, _someone_ will manage to produce amazingly-large-n
> and their kernel sucks and we have to fix it.

For that special _someone_, I've switched to rbtrees.  Not sure about the
efficiency for small numbers of very short timers, but I've improved on
that by storing a pointer to the next timer to trigger, as hrtimer does.

> 
> Does (or will) ia64 support node hotplug?  If so, what are the implications?
> 

This code only supports Altix.  Altix, for the time being, will not.
A new patch will be submitted for this when/if needed.

Attached is the new patch.

____________________________________________________________________________

The purpose of this patch to the SGI Altix specific mmtimer (posix timer)
driver is to allow a virtually infinite number of timers to be set per node.

Timers will now be kept on a sorted per-node list and a single node-based
hardware comparator is used to trigger the next timer.

Signed-off-by: Dimitri Sivanich <sivanich@sgi.com>


Index: linux/drivers/char/mmtimer.c
=================================--- linux.orig/drivers/char/mmtimer.c	2008-02-09 12:58:02.000000000 -0600
+++ linux/drivers/char/mmtimer.c	2008-02-09 15:26:33.545348718 -0600
@@ -74,9 +74,8 @@ static const struct file_operations mmti
  * We only have comparison registers RTC1-4 currently available per
  * node.  RTC0 is used by SAL.
  */
-#define NUM_COMPARATORS 3
 /* Check for an RTC interrupt pending */
-static int inline mmtimer_int_pending(int comparator)
+static int mmtimer_int_pending(int comparator)
 {
 	if (HUB_L((unsigned long *)LOCAL_MMR_ADDR(SH_EVENT_OCCURRED)) &
 			SH_EVENT_OCCURRED_RTC1_INT_MASK << comparator)
@@ -84,15 +83,16 @@ static int inline mmtimer_int_pending(in
 	else
 		return 0;
 }
+
 /* Clear the RTC interrupt pending bit */
-static void inline mmtimer_clr_int_pending(int comparator)
+static void mmtimer_clr_int_pending(int comparator)
 {
 	HUB_S((u64 *)LOCAL_MMR_ADDR(SH_EVENT_OCCURRED_ALIAS),
 		SH_EVENT_OCCURRED_RTC1_INT_MASK << comparator);
 }
 
 /* Setup timer on comparator RTC1 */
-static void inline mmtimer_setup_int_0(u64 expires)
+static void mmtimer_setup_int_0(int cpu, u64 expires)
 {
 	u64 val;
 
@@ -106,7 +106,7 @@ static void inline mmtimer_setup_int_0(u
 	mmtimer_clr_int_pending(0);
 
 	val = ((u64)SGI_MMTIMER_VECTOR << SH_RTC1_INT_CONFIG_IDX_SHFT) |
-		((u64)cpu_physical_id(smp_processor_id()) <<
+		((u64)cpu_physical_id(cpu) <<
 			SH_RTC1_INT_CONFIG_PID_SHFT);
 
 	/* Set configuration */
@@ -122,7 +122,7 @@ static void inline mmtimer_setup_int_0(u
 }
 
 /* Setup timer on comparator RTC2 */
-static void inline mmtimer_setup_int_1(u64 expires)
+static void mmtimer_setup_int_1(int cpu, u64 expires)
 {
 	u64 val;
 
@@ -133,7 +133,7 @@ static void inline mmtimer_setup_int_1(u
 	mmtimer_clr_int_pending(1);
 
 	val = ((u64)SGI_MMTIMER_VECTOR << SH_RTC2_INT_CONFIG_IDX_SHFT) |
-		((u64)cpu_physical_id(smp_processor_id()) <<
+		((u64)cpu_physical_id(cpu) <<
 			SH_RTC2_INT_CONFIG_PID_SHFT);
 
 	HUB_S((u64 *)LOCAL_MMR_ADDR(SH_RTC2_INT_CONFIG), val);
@@ -144,7 +144,7 @@ static void inline mmtimer_setup_int_1(u
 }
 
 /* Setup timer on comparator RTC3 */
-static void inline mmtimer_setup_int_2(u64 expires)
+static void mmtimer_setup_int_2(int cpu, u64 expires)
 {
 	u64 val;
 
@@ -155,7 +155,7 @@ static void inline mmtimer_setup_int_2(u
 	mmtimer_clr_int_pending(2);
 
 	val = ((u64)SGI_MMTIMER_VECTOR << SH_RTC3_INT_CONFIG_IDX_SHFT) |
-		((u64)cpu_physical_id(smp_processor_id()) <<
+		((u64)cpu_physical_id(cpu) <<
 			SH_RTC3_INT_CONFIG_PID_SHFT);
 
 	HUB_S((u64 *)LOCAL_MMR_ADDR(SH_RTC3_INT_CONFIG), val);
@@ -170,22 +170,22 @@ static void inline mmtimer_setup_int_2(u
  * in order to insure that the setup succeeds in a deterministic time frame.
  * It will check if the interrupt setup succeeded.
  */
-static int inline mmtimer_setup(int comparator, unsigned long expires)
+static int mmtimer_setup(int cpu, int comparator, unsigned long expires)
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
-	if (rtc_time() < expires)
+	if (rtc_time() <= expires)
 		return 1;
 
 	/*
@@ -195,7 +195,7 @@ static int inline mmtimer_setup(int comp
 	return mmtimer_int_pending(comparator);
 }
 
-static int inline mmtimer_disable_int(long nasid, int comparator)
+static int mmtimer_disable_int(long nasid, int comparator)
 {
 	switch (comparator) {
 	case 0:
@@ -216,18 +216,124 @@ static int inline mmtimer_disable_int(lo
 	return 0;
 }
 
-#define TIMER_OFF 0xbadcabLL
+#define COMPARATOR	1		/* The comparator to use */
 
-/* There is one of these for each comparator */
-typedef struct mmtimer {
-	spinlock_t lock ____cacheline_aligned;
+#define TIMER_OFF	0xbadcabLL	/* Timer is not setup */
+#define TIMER_SET	0		/* Comparator is set for this timer */
+
+/* There is one of these for each timer */
+struct mmtimer {
+	struct rb_node list;
 	struct k_itimer *timer;
-	int i;
 	int cpu;
+};
+
+struct mmtimer_node {
+	spinlock_t lock ____cacheline_aligned;
+	struct rb_root timer_head;
+	struct rb_node *next;
 	struct tasklet_struct tasklet;
-} mmtimer_t;
+};
+static struct mmtimer_node *timers;
 
-static mmtimer_t ** timers;
+
+/*
+ * Add a new mmtimer struct to the node's mmtimer list.
+ * This function assumes the struct mmtimer_node is locked.
+ */
+void mmtimer_add_list(struct mmtimer *n)
+{
+	int nodeid = n->timer->it.mmtimer.node;
+	unsigned long expires = n->timer->it.mmtimer.expires;
+	struct rb_node **link = &timers[nodeid].timer_head.rb_node;
+	struct rb_node *parent = NULL;
+	struct mmtimer *x;
+
+	/*
+	 * Find the right place in the rbtree:
+	 */
+	while (*link) {
+		parent = *link;
+		x = rb_entry(parent, struct mmtimer, list);
+
+		if (expires < x->timer->it.mmtimer.expires)
+			link = &(*link)->rb_left;
+		else
+			link = &(*link)->rb_right;
+	}
+
+	/*
+	 * Insert the timer to the rbtree and check whether it
+	 * replaces the first pending timer
+	 */
+	rb_link_node(&n->list, parent, link);
+	rb_insert_color(&n->list, &timers[nodeid].timer_head);
+
+	if (!timers[nodeid].next || expires < rb_entry(timers[nodeid].next,
+			struct mmtimer, list)->timer->it.mmtimer.expires)
+		timers[nodeid].next = &n->list;
+}
+
+/*
+ * Set the comparator for the next timer.
+ * This function assumes the struct mmtimer_node is locked.
+ */
+void mmtimer_set_next_timer(int nodeid)
+{
+	struct mmtimer_node *n = &timers[nodeid];
+	struct mmtimer *x;
+	struct k_itimer *t;
+	int o;
+
+restart:
+	if (n->next = NULL)
+		return;
+
+	x = rb_entry(n->next, struct mmtimer, list);
+	t = x->timer;
+	if (!t->it.mmtimer.incr) {
+		/* Not an interval timer */
+		if (!mmtimer_setup(x->cpu, COMPARATOR,
+					t->it.mmtimer.expires)) {
+			/* Late setup, fire now */
+			tasklet_schedule(&n->tasklet);
+		}
+		return;
+	}
+
+	/* Interval timer */
+	o = 0;
+	while (!mmtimer_setup(x->cpu, COMPARATOR, t->it.mmtimer.expires)) {
+		unsigned long e, e1;
+		struct rb_node *next;
+		t->it.mmtimer.expires += t->it.mmtimer.incr << o;
+		t->it_overrun += 1 << o;
+		o++;
+		if (o > 20) {
+			printk(KERN_ALERT "mmtimer: cannot reschedule timer\n");
+			t->it.mmtimer.clock = TIMER_OFF;
+			n->next = rb_next(&x->list);
+			rb_erase(&x->list, &n->timer_head);
+			kfree(x);
+			goto restart;
+		}
+
+		e = t->it.mmtimer.expires;
+		next = rb_next(&x->list);
+
+		if (next = NULL)
+			continue;
+
+		e1 = rb_entry(next, struct mmtimer, list)->
+			timer->it.mmtimer.expires;
+		if (e > e1) {
+			n->next = next;
+			rb_erase(&x->list, &n->timer_head);
+			mmtimer_add_list(x);
+			goto restart;
+		}
+	}
+}
 
 /**
  * mmtimer_ioctl - ioctl interface for /dev/mmtimer
@@ -390,35 +496,6 @@ static int sgi_clock_set(clockid_t clock
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
@@ -435,71 +512,75 @@ static int inline reschedule_periodic_ti
 static irqreturn_t
 mmtimer_interrupt(int irq, void *dev_id)
 {
-	int i;
 	unsigned long expires = 0;
 	int result = IRQ_NONE;
 	unsigned indx = cpu_to_node(smp_processor_id());
+	struct mmtimer *base;
 
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
+	base = rb_entry(timers[indx].next, struct mmtimer, list);
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
+			(expires && (expires <= rtc_time()))) {
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
 
-void mmtimer_tasklet(unsigned long data) {
-	mmtimer_t *x = (mmtimer_t *)data;
-	struct k_itimer *t = x->timer;
+void mmtimer_tasklet(unsigned long data)
+{
+	int nodeid = data;
+	struct mmtimer_node *mn = &timers[nodeid];
+	struct mmtimer *x = rb_entry(mn->next, struct mmtimer, list);
+	struct k_itimer *t;
 	unsigned long flags;
 
-	if (t = NULL)
-		return;
-
 	/* Send signal and deal with periodic signals */
-	spin_lock_irqsave(&t->it_lock, flags);
-	spin_lock(&x->lock);
-	/* If timer was deleted between interrupt and here, leave */
-	if (t != x->timer)
+	spin_lock_irqsave(&mn->lock, flags);
+	if (!mn->next)
 		goto out;
-	t->it_overrun = 0;
 
-	if (posix_timer_event(t, 0) != 0) {
+	x = rb_entry(mn->next, struct mmtimer, list);
+	t = x->timer;
+
+	if (t->it.mmtimer.clock = TIMER_OFF)
+		goto out;
+
+	t->it_overrun = 0;
 
-		// printk(KERN_WARNING "mmtimer: cannot deliver signal.\n");
+	mn->next = rb_next(&x->list);
+	rb_erase(&x->list, &mn->timer_head);
 
+	if (posix_timer_event(t, 0) != 0)
 		t->it_overrun++;
-	}
+
 	if(t->it.mmtimer.incr) {
-		/* Periodic timer */
-		if (reschedule_periodic_timer(x)) {
-			printk(KERN_WARNING "mmtimer: unable to reschedule\n");
-			x->timer = NULL;
-		}
+		t->it.mmtimer.expires += t->it.mmtimer.incr;
+		mmtimer_add_list(x);
 	} else {
 		/* Ensure we don't false trigger in mmtimer_interrupt */
+		t->it.mmtimer.clock = TIMER_OFF;
 		t->it.mmtimer.expires = 0;
+		kfree(x);
 	}
+	/* Set comparator for next timer, if there is one */
+	mmtimer_set_next_timer(nodeid);
+
 	t->it_overrun_last = t->it_overrun;
 out:
-	spin_unlock(&x->lock);
-	spin_unlock_irqrestore(&t->it_lock, flags);
+	spin_unlock_irqrestore(&mn->lock, flags);
 }
 
 static int sgi_timer_create(struct k_itimer *timer)
@@ -516,19 +597,50 @@ static int sgi_timer_create(struct k_iti
  */
 static int sgi_timer_del(struct k_itimer *timr)
 {
-	int i = timr->it.mmtimer.clock;
 	cnodeid_t nodeid = timr->it.mmtimer.node;
-	mmtimer_t *t = timers[nodeid] + i;
 	unsigned long irqflags;
 
-	if (i != TIMER_OFF) {
-		spin_lock_irqsave(&t->lock, irqflags);
-		mmtimer_disable_int(cnodeid_to_nasid(nodeid),i);
-		t->timer = NULL;
+	spin_lock_irqsave(&timers[nodeid].lock, irqflags);
+	if (timr->it.mmtimer.clock != TIMER_OFF) {
+		unsigned long expires = timr->it.mmtimer.expires;
+		struct rb_node *n = timers[nodeid].timer_head.rb_node;
+		struct mmtimer *t;
+		int r = 0;
+
 		timr->it.mmtimer.clock = TIMER_OFF;
 		timr->it.mmtimer.expires = 0;
-		spin_unlock_irqrestore(&t->lock, irqflags);
+
+		while (n) {
+			t = rb_entry(n, struct mmtimer, list);
+			if (t->timer = timr)
+				break;
+
+			if (expires < t->timer->it.mmtimer.expires)
+				n = n->rb_left;
+			else
+				n = n->rb_right;
+		}
+
+		if (!n) {
+			spin_unlock_irqrestore(&timers[nodeid].lock, irqflags);
+			return 0;
+		}
+
+		if (timers[nodeid].next = n) {
+			timers[nodeid].next = rb_next(n);
+			r = 1;
+		}
+
+		rb_erase(n, &timers[nodeid].timer_head);
+		kfree(t);
+
+		if (r) {
+			mmtimer_disable_int(cnodeid_to_nasid(nodeid),
+				COMPARATOR);
+			mmtimer_set_next_timer(nodeid);
+		}
 	}
+	spin_unlock_irqrestore(&timers[nodeid].lock, irqflags);
 	return 0;
 }
 
@@ -557,12 +669,11 @@ static int sgi_timer_set(struct k_itimer
 	struct itimerspec * new_setting,
 	struct itimerspec * old_setting)
 {
-
-	int i;
 	unsigned long when, period, irqflags;
 	int err = 0;
 	cnodeid_t nodeid;
-	mmtimer_t *base;
+	struct mmtimer *base;
+	struct rb_node *n;
 
 	if (old_setting)
 		sgi_timer_get(timr, old_setting);
@@ -575,6 +686,10 @@ static int sgi_timer_set(struct k_itimer
 		/* Clear timer */
 		return 0;
 
+	base = kmalloc(sizeof(struct mmtimer), GFP_KERNEL);
+	if (base = NULL)
+		return -ENOMEM;
+
 	if (flags & TIMER_ABSTIME) {
 		struct timespec n;
 		unsigned long now;
@@ -604,47 +719,38 @@ static int sgi_timer_set(struct k_itimer
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
+	timr->it.mmtimer.clock = TIMER_SET;
 	timr->it.mmtimer.node = nodeid;
 	timr->it.mmtimer.incr = period;
 	timr->it.mmtimer.expires = when;
 
-	if (period = 0) {
-		if (!mmtimer_setup(i, when)) {
-			mmtimer_disable_int(-1, i);
-			posix_timer_event(timr, 0);
-			timr->it.mmtimer.expires = 0;
-		}
-	} else {
-		timr->it.mmtimer.expires -= period;
-		if (reschedule_periodic_timer(base))
-			err = -EINVAL;
+	n = timers[nodeid].next;
+
+	/* Add the new struct mmtimer to node's timer list */
+	mmtimer_add_list(base);
+
+	if (timers[nodeid].next = n) {
+		/* No need to reprogram comparator for now */
+		spin_unlock_irqrestore(&timers[nodeid].lock, irqflags);
+		preempt_enable();
+		return err;
 	}
 
-	spin_unlock_irqrestore(&base->lock, irqflags);
+	/* We need to reprogram the comparator */
+	if (n)
+		mmtimer_disable_int(cnodeid_to_nasid(nodeid), COMPARATOR);
+
+	mmtimer_set_next_timer(nodeid);
+
+	/* Unlock the node timer structure */
+	spin_unlock_irqrestore(&timers[nodeid].lock, irqflags);
 
 	preempt_enable();
 
@@ -669,7 +775,6 @@ static struct k_clock sgi_clock = {
  */
 static int __init mmtimer_init(void)
 {
-	unsigned i;
 	cnodeid_t node, maxn = -1;
 
 	if (!ia64_platform_is("sn2"))
@@ -706,31 +811,18 @@ static int __init mmtimer_init(void)
 	maxn++;
 
 	/* Allocate list of node ptrs to mmtimer_t's */
-	timers = kzalloc(sizeof(mmtimer_t *)*maxn, GFP_KERNEL);
+	timers = kzalloc(sizeof(struct mmtimer_node)*maxn, GFP_KERNEL);
 	if (timers = NULL) {
 		printk(KERN_ERR "%s: failed to allocate memory for device\n",
 				MMTIMER_NAME);
 		goto out3;
 	}
 
-	/* Allocate mmtimer_t's for each online node */
+	/* Initialize struct mmtimer's for each online node */
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
+		spin_lock_init(&timers[node].lock);
+		tasklet_init(&timers[node].tasklet, mmtimer_tasklet,
+			(unsigned long) node);
 	}
 
 	sgi_clock_period = sgi_clock.res = NSEC_PER_SEC / sn_rtc_cycles_per_second;
@@ -741,11 +833,8 @@ static int __init mmtimer_init(void)
 
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
@@ -754,4 +843,3 @@ out1:
 }
 
 module_init(mmtimer_init);
-
