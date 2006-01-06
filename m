From: Dimitri Sivanich <sivanich@sgi.com>
Date: Fri, 06 Jan 2006 17:33:41 +0000
Subject: [PATCH] shrink mmtimer memory size
Message-Id: <20060106173341.GA14620@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch will greatly reduce the amount of memory used by mmtimer on
smaller machines with large values of MAX_COMPACT_NODES.

Signed-off-by: Dimitri Sivanich <sivanich@sgi.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---

Index: linux/drivers/char/mmtimer.c
=================================--- linux.orig/drivers/char/mmtimer.c	2006-01-02 21:21:10.000000000 -0600
+++ linux/drivers/char/mmtimer.c	2006-01-05 13:34:49.080296084 -0600
@@ -1,11 +1,11 @@
 /*
- * Intel Multimedia Timer device implementation for SGI SN platforms.
+ * Timer device implementation for SGI SN platforms.
  *
  * This file is subject to the terms and conditions of the GNU General Public
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2001-2004 Silicon Graphics, Inc.  All rights reserved.
+ * Copyright (c) 2001-2006 Silicon Graphics, Inc.  All rights reserved.
  *
  * This driver exports an API that should be supportable by any HPET or IA-PC
  * multimedia timer.  The code below is currently specific to the SGI Altix
@@ -45,7 +45,7 @@ MODULE_LICENSE("GPL");
 /* name of the device, usually in /dev */
 #define MMTIMER_NAME "mmtimer"
 #define MMTIMER_DESC "SGI Altix RTC Timer"
-#define MMTIMER_VERSION "2.0"
+#define MMTIMER_VERSION "2.1"
 
 #define RTC_BITS 55 /* 55 bits for this implementation */
 
@@ -227,10 +227,7 @@ typedef struct mmtimer {
 	struct tasklet_struct tasklet;
 } mmtimer_t;
 
-/*
- * Total number of comparators is comparators/node * MAX nodes/running kernel
- */
-static mmtimer_t timers[NUM_COMPARATORS*MAX_COMPACT_NODES];
+static mmtimer_t ** timers;
 
 /**
  * mmtimer_ioctl - ioctl interface for /dev/mmtimer
@@ -441,29 +438,29 @@ static irqreturn_t
 mmtimer_interrupt(int irq, void *dev_id, struct pt_regs *regs)
 {
 	int i;
-	mmtimer_t *base = timers + cpu_to_node(smp_processor_id()) *
-						NUM_COMPARATORS;
 	unsigned long expires = 0;
 	int result = IRQ_NONE;
+	unsigned indx = cpu_to_node(smp_processor_id());
 
 	/*
 	 * Do this once for each comparison register
 	 */
 	for (i = 0; i < NUM_COMPARATORS; i++) {
+		mmtimer_t *base = timers[indx] + i;
 		/* Make sure this doesn't get reused before tasklet_sched */
-		spin_lock(&base[i].lock);
-		if (base[i].cpu = smp_processor_id()) {
-			if (base[i].timer)
-				expires = base[i].timer->it.mmtimer.expires;
+		spin_lock(&base->lock);
+		if (base->cpu = smp_processor_id()) {
+			if (base->timer)
+				expires = base->timer->it.mmtimer.expires;
 			/* expires test won't work with shared irqs */
 			if ((mmtimer_int_pending(i) > 0) ||
 				(expires && (expires < rtc_time()))) {
 				mmtimer_clr_int_pending(i);
-				tasklet_schedule(&base[i].tasklet);
+				tasklet_schedule(&base->tasklet);
 				result = IRQ_HANDLED;
 			}
 		}
-		spin_unlock(&base[i].lock);
+		spin_unlock(&base->lock);
 		expires = 0;
 	}
 	return result;
@@ -523,7 +520,7 @@ static int sgi_timer_del(struct k_itimer
 {
 	int i = timr->it.mmtimer.clock;
 	cnodeid_t nodeid = timr->it.mmtimer.node;
-	mmtimer_t *t = timers + nodeid * NUM_COMPARATORS +i;
+	mmtimer_t *t = timers[nodeid] + i;
 	unsigned long irqflags;
 
 	if (i != TIMER_OFF) {
@@ -609,11 +606,11 @@ static int sgi_timer_set(struct k_itimer
 	preempt_disable();
 
 	nodeid =  cpu_to_node(smp_processor_id());
-	base = timers + nodeid * NUM_COMPARATORS;
 retry:
 	/* Don't use an allocated timer, or a deleted one that's pending */
 	for(i = 0; i< NUM_COMPARATORS; i++) {
-		if (!base[i].timer && !base[i].tasklet.state) {
+		base = timers[nodeid] + i;
+		if (!base->timer && !base->tasklet.state) {
 			break;
 		}
 	}
@@ -623,14 +620,14 @@ retry:
 		return -EBUSY;
 	}
 
-	spin_lock_irqsave(&base[i].lock, irqflags);
+	spin_lock_irqsave(&base->lock, irqflags);
 
-	if (base[i].timer || base[i].tasklet.state != 0) {
-		spin_unlock_irqrestore(&base[i].lock, irqflags);
+	if (base->timer || base->tasklet.state != 0) {
+		spin_unlock_irqrestore(&base->lock, irqflags);
 		goto retry;
 	}
-	base[i].timer = timr;
-	base[i].cpu = smp_processor_id();
+	base->timer = timr;
+	base->cpu = smp_processor_id();
 
 	timr->it.mmtimer.clock = i;
 	timr->it.mmtimer.node = nodeid;
@@ -645,11 +642,11 @@ retry:
 		}
 	} else {
 		timr->it.mmtimer.expires -= period;
-		if (reschedule_periodic_timer(base+i))
+		if (reschedule_periodic_timer(base))
 			err = -EINVAL;
 	}
 
-	spin_unlock_irqrestore(&base[i].lock, irqflags);
+	spin_unlock_irqrestore(&base->lock, irqflags);
 
 	preempt_enable();
 
@@ -675,6 +672,7 @@ static struct k_clock sgi_clock = {
 static int __init mmtimer_init(void)
 {
 	unsigned i;
+	cnodeid_t node, maxn = -1;
 
 	if (!ia64_platform_is("sn2"))
 		return -1;
@@ -691,14 +689,6 @@ static int __init mmtimer_init(void)
 	mmtimer_femtoperiod = ((unsigned long)1E15 + sn_rtc_cycles_per_second /
 			       2) / sn_rtc_cycles_per_second;
 
-	for (i=0; i< NUM_COMPARATORS*MAX_COMPACT_NODES; i++) {
-		spin_lock_init(&timers[i].lock);
-		timers[i].timer = NULL;
-		timers[i].cpu = 0;
-		timers[i].i = i % NUM_COMPARATORS;
-		tasklet_init(&timers[i].tasklet, mmtimer_tasklet, (unsigned long) (timers+i));
-	}
-
 	if (request_irq(SGI_MMTIMER_VECTOR, mmtimer_interrupt, SA_PERCPU_IRQ, MMTIMER_NAME, NULL)) {
 		printk(KERN_WARNING "%s: unable to allocate interrupt.",
 			MMTIMER_NAME);
@@ -712,6 +702,40 @@ static int __init mmtimer_init(void)
 		return -1;
 	}
 
+	/* Get max numbered node, calculate slots needed */
+	for_each_online_node(node) {
+		maxn = node;
+	}
+	maxn++;
+
+	/* Allocate list of node ptrs to mmtimer_t's */
+	timers = kmalloc(sizeof(mmtimer_t *)*maxn, GFP_KERNEL);
+	if (timers = NULL) {
+		printk(KERN_ERR "%s: failed to allocate memory for device\n",
+				MMTIMER_NAME);
+		return -1;
+	}
+
+	/* Allocate mmtimer_t's for each online node */
+	for_each_online_node(node) {
+		timers[node] = kmalloc_node(sizeof(mmtimer_t)*NUM_COMPARATORS, GFP_KERNEL, node);
+		if (timers[node] = NULL) {
+			printk(KERN_ERR "%s: failed to allocate memory for device\n",
+				MMTIMER_NAME);
+			return -1;
+		}
+		for (i=0; i< NUM_COMPARATORS; i++) {
+			mmtimer_t * base = timers[node] + i;
+
+			spin_lock_init(&base->lock);
+			base->timer = NULL;
+			base->cpu = 0;
+			base->i = i;
+			tasklet_init(&base->tasklet, mmtimer_tasklet,
+				(unsigned long) (base));
+		}
+	}
+
 	sgi_clock_period = sgi_clock.res = NSEC_PER_SEC / sn_rtc_cycles_per_second;
 	register_posix_clock(CLOCK_SGI_CYCLE, &sgi_clock);
 
