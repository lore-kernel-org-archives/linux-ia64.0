From: "Bob Picco" <bob.picco@hp.com>
Date: Sat, 14 Jul 2007 00:25:25 +0000
Subject: [PATCH 2/2] ia64 - remove time interpolator
Message-Id: <20070714002525.GK2317@localhost>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Remove time_interpolator code.


Signed-off-by: Bob Picco <bob.picco@hp.com>
Signed-off-by: John Stultz <johnstul@us.ibm.com>
Signed-off-by: Peter Keilty <peter.keilty@hp.com>

 include/linux/timex.h     |   60 --------------
 kernel/time.c             |   75 ------------------
 kernel/time/ntp.c         |   10 --
 kernel/time/timekeeping.c |    4 
 kernel/timer.c            |  188 ----------------------------------------------
 5 files changed, 337 deletions(-)

Index: linux-2.6.22/include/linux/timex.h
=================================--- linux-2.6.22.orig/include/linux/timex.h	2007-07-09 06:18:44.000000000 -0400
+++ linux-2.6.22/include/linux/timex.h	2007-07-09 06:26:51.000000000 -0400
@@ -224,66 +224,6 @@ static inline int ntp_synced(void)
 	__x < 0 ? -(-__x >> __s) : __x >> __s;	\
 })
 
-
-#ifdef CONFIG_TIME_INTERPOLATION
-
-#define TIME_SOURCE_CPU 0
-#define TIME_SOURCE_MMIO64 1
-#define TIME_SOURCE_MMIO32 2
-#define TIME_SOURCE_FUNCTION 3
-
-/* For proper operations time_interpolator clocks must run slightly slower
- * than the standard clock since the interpolator may only correct by having
- * time jump forward during a tick. A slower clock is usually a side effect
- * of the integer divide of the nanoseconds in a second by the frequency.
- * The accuracy of the division can be increased by specifying a shift.
- * However, this may cause the clock not to be slow enough.
- * The interpolator will self-tune the clock by slowing down if no
- * resets occur or speeding up if the time jumps per analysis cycle
- * become too high.
- *
- * Setting jitter compensates for a fluctuating timesource by comparing
- * to the last value read from the timesource to insure that an earlier value
- * is not returned by a later call. The price to pay
- * for the compensation is that the timer routines are not as scalable anymore.
- */
-
-struct time_interpolator {
-	u16 source;			/* time source flags */
-	u8 shift;			/* increases accuracy of multiply by shifting. */
-				/* Note that bits may be lost if shift is set too high */
-	u8 jitter;			/* if set compensate for fluctuations */
-	u32 nsec_per_cyc;		/* set by register_time_interpolator() */
-	void *addr;			/* address of counter or function */
-	cycles_t mask;			/* mask the valid bits of the counter */
-	unsigned long offset;		/* nsec offset at last update of interpolator */
-	u64 last_counter;		/* counter value in units of the counter at last update */
-	cycles_t last_cycle;		/* Last timer value if TIME_SOURCE_JITTER is set */
-	u64 frequency;			/* frequency in counts/second */
-	long drift;			/* drift in parts-per-million (or -1) */
-	unsigned long skips;		/* skips forward */
-	unsigned long ns_skipped;	/* nanoseconds skipped */
-	struct time_interpolator *next;
-};
-
-extern void register_time_interpolator(struct time_interpolator *);
-extern void unregister_time_interpolator(struct time_interpolator *);
-extern void time_interpolator_reset(void);
-extern unsigned long time_interpolator_get_offset(void);
-extern void time_interpolator_update(long delta_nsec);
-
-#else /* !CONFIG_TIME_INTERPOLATION */
-
-static inline void time_interpolator_reset(void)
-{
-}
-
-static inline void time_interpolator_update(long delta_nsec)
-{
-}
-
-#endif /* !CONFIG_TIME_INTERPOLATION */
-
 #define TICK_LENGTH_SHIFT	32
 
 #ifdef CONFIG_NO_HZ
Index: linux-2.6.22/kernel/time.c
=================================--- linux-2.6.22.orig/kernel/time.c	2007-07-09 06:19:13.000000000 -0400
+++ linux-2.6.22/kernel/time.c	2007-07-09 06:26:51.000000000 -0400
@@ -133,7 +133,6 @@ static inline void warp_clock(void)
 	write_seqlock_irq(&xtime_lock);
 	wall_to_monotonic.tv_sec -= sys_tz.tz_minuteswest * 60;
 	xtime.tv_sec += sys_tz.tz_minuteswest * 60;
-	time_interpolator_reset();
 	write_sequnlock_irq(&xtime_lock);
 	clock_was_set();
 }
@@ -306,79 +305,6 @@ struct timespec timespec_trunc(struct ti
 }
 EXPORT_SYMBOL(timespec_trunc);
 
-#ifdef CONFIG_TIME_INTERPOLATION
-void getnstimeofday (struct timespec *tv)
-{
-	unsigned long seq,sec,nsec;
-
-	do {
-		seq = read_seqbegin(&xtime_lock);
-		sec = xtime.tv_sec;
-		nsec = xtime.tv_nsec+time_interpolator_get_offset();
-	} while (unlikely(read_seqretry(&xtime_lock, seq)));
-
-	while (unlikely(nsec >= NSEC_PER_SEC)) {
-		nsec -= NSEC_PER_SEC;
-		++sec;
-	}
-	tv->tv_sec = sec;
-	tv->tv_nsec = nsec;
-}
-EXPORT_SYMBOL_GPL(getnstimeofday);
-
-int do_settimeofday (struct timespec *tv)
-{
-	time_t wtm_sec, sec = tv->tv_sec;
-	long wtm_nsec, nsec = tv->tv_nsec;
-
-	if ((unsigned long)tv->tv_nsec >= NSEC_PER_SEC)
-		return -EINVAL;
-
-	write_seqlock_irq(&xtime_lock);
-	{
-		wtm_sec  = wall_to_monotonic.tv_sec + (xtime.tv_sec - sec);
-		wtm_nsec = wall_to_monotonic.tv_nsec + (xtime.tv_nsec - nsec);
-
-		set_normalized_timespec(&xtime, sec, nsec);
-		set_normalized_timespec(&wall_to_monotonic, wtm_sec, wtm_nsec);
-
-		time_adjust = 0;		/* stop active adjtime() */
-		time_status |= STA_UNSYNC;
-		time_maxerror = NTP_PHASE_LIMIT;
-		time_esterror = NTP_PHASE_LIMIT;
-		time_interpolator_reset();
-	}
-	write_sequnlock_irq(&xtime_lock);
-	clock_was_set();
-	return 0;
-}
-EXPORT_SYMBOL(do_settimeofday);
-
-void do_gettimeofday (struct timeval *tv)
-{
-	unsigned long seq, nsec, usec, sec, offset;
-	do {
-		seq = read_seqbegin(&xtime_lock);
-		offset = time_interpolator_get_offset();
-		sec = xtime.tv_sec;
-		nsec = xtime.tv_nsec;
-	} while (unlikely(read_seqretry(&xtime_lock, seq)));
-
-	usec = (nsec + offset) / 1000;
-
-	while (unlikely(usec >= USEC_PER_SEC)) {
-		usec -= USEC_PER_SEC;
-		++sec;
-	}
-
-	tv->tv_sec = sec;
-	tv->tv_usec = usec;
-}
-
-EXPORT_SYMBOL(do_gettimeofday);
-
-
-#else
 #ifndef CONFIG_GENERIC_TIME
 /*
  * Simulate gettimeofday using do_gettimeofday which only allows a timeval
@@ -394,7 +320,6 @@ void getnstimeofday(struct timespec *tv)
 }
 EXPORT_SYMBOL_GPL(getnstimeofday);
 #endif
-#endif
 
 /* Converts Gregorian date to seconds since 1970-01-01 00:00:00.
  * Assumes input in normal date format, i.e. 1980-12-31 23:59:59
Index: linux-2.6.22/kernel/time/timekeeping.c
=================================--- linux-2.6.22.orig/kernel/time/timekeeping.c	2007-07-09 06:19:13.000000000 -0400
+++ linux-2.6.22/kernel/time/timekeeping.c	2007-07-09 06:26:51.000000000 -0400
@@ -456,10 +456,6 @@ void update_wall_time(void)
 			second_overflow();
 		}
 
-		/* interpolator bits */
-		time_interpolator_update(clock->xtime_interval
-						>> clock->shift);
-
 		/* accumulate error between NTP and clock interval */
 		clock->error += current_tick_length();
 		clock->error -= clock->xtime_interval << (TICK_LENGTH_SHIFT - clock->shift);
Index: linux-2.6.22/kernel/time/ntp.c
=================================--- linux-2.6.22.orig/kernel/time/ntp.c	2007-07-09 06:19:13.000000000 -0400
+++ linux-2.6.22/kernel/time/ntp.c	2007-07-09 06:26:51.000000000 -0400
@@ -116,11 +116,6 @@ void second_overflow(void)
 		if (xtime.tv_sec % 86400 = 0) {
 			xtime.tv_sec--;
 			wall_to_monotonic.tv_sec++;
-			/*
-			 * The timer interpolator will make time change
-			 * gradually instead of an immediate jump by one second
-			 */
-			time_interpolator_update(-NSEC_PER_SEC);
 			time_state = TIME_OOP;
 			printk(KERN_NOTICE "Clock: inserting leap second "
 					"23:59:60 UTC\n");
@@ -130,11 +125,6 @@ void second_overflow(void)
 		if ((xtime.tv_sec + 1) % 86400 = 0) {
 			xtime.tv_sec++;
 			wall_to_monotonic.tv_sec--;
-			/*
-			 * Use of time interpolator for a gradual change of
-			 * time
-			 */
-			time_interpolator_update(NSEC_PER_SEC);
 			time_state = TIME_WAIT;
 			printk(KERN_NOTICE "Clock: deleting leap second "
 					"23:59:59 UTC\n");
Index: linux-2.6.22/kernel/timer.c
=================================--- linux-2.6.22.orig/kernel/timer.c	2007-07-09 06:19:13.000000000 -0400
+++ linux-2.6.22/kernel/timer.c	2007-07-09 06:26:51.000000000 -0400
@@ -1334,194 +1334,6 @@ void __init init_timers(void)
 	open_softirq(TIMER_SOFTIRQ, run_timer_softirq, NULL);
 }
 
-#ifdef CONFIG_TIME_INTERPOLATION
-
-struct time_interpolator *time_interpolator __read_mostly;
-static struct time_interpolator *time_interpolator_list __read_mostly;
-static DEFINE_SPINLOCK(time_interpolator_lock);
-
-static inline cycles_t time_interpolator_get_cycles(unsigned int src)
-{
-	unsigned long (*x)(void);
-
-	switch (src)
-	{
-		case TIME_SOURCE_FUNCTION:
-			x = time_interpolator->addr;
-			return x();
-
-		case TIME_SOURCE_MMIO64	:
-			return readq_relaxed((void __iomem *)time_interpolator->addr);
-
-		case TIME_SOURCE_MMIO32	:
-			return readl_relaxed((void __iomem *)time_interpolator->addr);
-
-		default: return get_cycles();
-	}
-}
-
-static inline u64 time_interpolator_get_counter(int writelock)
-{
-	unsigned int src = time_interpolator->source;
-
-	if (time_interpolator->jitter)
-	{
-		cycles_t lcycle;
-		cycles_t now;
-
-		do {
-			lcycle = time_interpolator->last_cycle;
-			now = time_interpolator_get_cycles(src);
-			if (lcycle && time_after(lcycle, now))
-				return lcycle;
-
-			/* When holding the xtime write lock, there's no need
-			 * to add the overhead of the cmpxchg.  Readers are
-			 * force to retry until the write lock is released.
-			 */
-			if (writelock) {
-				time_interpolator->last_cycle = now;
-				return now;
-			}
-			/* Keep track of the last timer value returned. The use of cmpxchg here
-			 * will cause contention in an SMP environment.
-			 */
-		} while (unlikely(cmpxchg(&time_interpolator->last_cycle, lcycle, now) != lcycle));
-		return now;
-	}
-	else
-		return time_interpolator_get_cycles(src);
-}
-
-void time_interpolator_reset(void)
-{
-	time_interpolator->offset = 0;
-	time_interpolator->last_counter = time_interpolator_get_counter(1);
-}
-
-#define GET_TI_NSECS(count,i) (((((count) - i->last_counter) & (i)->mask) * (i)->nsec_per_cyc) >> (i)->shift)
-
-unsigned long time_interpolator_get_offset(void)
-{
-	/* If we do not have a time interpolator set up then just return zero */
-	if (!time_interpolator)
-		return 0;
-
-	return time_interpolator->offset +
-		GET_TI_NSECS(time_interpolator_get_counter(0), time_interpolator);
-}
-
-#define INTERPOLATOR_ADJUST 65536
-#define INTERPOLATOR_MAX_SKIP 10*INTERPOLATOR_ADJUST
-
-void time_interpolator_update(long delta_nsec)
-{
-	u64 counter;
-	unsigned long offset;
-
-	/* If there is no time interpolator set up then do nothing */
-	if (!time_interpolator)
-		return;
-
-	/*
-	 * The interpolator compensates for late ticks by accumulating the late
-	 * time in time_interpolator->offset. A tick earlier than expected will
-	 * lead to a reset of the offset and a corresponding jump of the clock
-	 * forward. Again this only works if the interpolator clock is running
-	 * slightly slower than the regular clock and the tuning logic insures
-	 * that.
-	 */
-
-	counter = time_interpolator_get_counter(1);
-	offset = time_interpolator->offset +
-			GET_TI_NSECS(counter, time_interpolator);
-
-	if (delta_nsec < 0 || (unsigned long) delta_nsec < offset)
-		time_interpolator->offset = offset - delta_nsec;
-	else {
-		time_interpolator->skips++;
-		time_interpolator->ns_skipped += delta_nsec - offset;
-		time_interpolator->offset = 0;
-	}
-	time_interpolator->last_counter = counter;
-
-	/* Tuning logic for time interpolator invoked every minute or so.
-	 * Decrease interpolator clock speed if no skips occurred and an offset is carried.
-	 * Increase interpolator clock speed if we skip too much time.
-	 */
-	if (jiffies % INTERPOLATOR_ADJUST = 0)
-	{
-		if (time_interpolator->skips = 0 && time_interpolator->offset > tick_nsec)
-			time_interpolator->nsec_per_cyc--;
-		if (time_interpolator->ns_skipped > INTERPOLATOR_MAX_SKIP && time_interpolator->offset = 0)
-			time_interpolator->nsec_per_cyc++;
-		time_interpolator->skips = 0;
-		time_interpolator->ns_skipped = 0;
-	}
-}
-
-static inline int
-is_better_time_interpolator(struct time_interpolator *new)
-{
-	if (!time_interpolator)
-		return 1;
-	return new->frequency > 2*time_interpolator->frequency ||
-	    (unsigned long)new->drift < (unsigned long)time_interpolator->drift;
-}
-
-void
-register_time_interpolator(struct time_interpolator *ti)
-{
-	unsigned long flags;
-
-	/* Sanity check */
-	BUG_ON(ti->frequency = 0 || ti->mask = 0);
-
-	ti->nsec_per_cyc = ((u64)NSEC_PER_SEC << ti->shift) / ti->frequency;
-	spin_lock(&time_interpolator_lock);
-	write_seqlock_irqsave(&xtime_lock, flags);
-	if (is_better_time_interpolator(ti)) {
-		time_interpolator = ti;
-		time_interpolator_reset();
-	}
-	write_sequnlock_irqrestore(&xtime_lock, flags);
-
-	ti->next = time_interpolator_list;
-	time_interpolator_list = ti;
-	spin_unlock(&time_interpolator_lock);
-}
-
-void
-unregister_time_interpolator(struct time_interpolator *ti)
-{
-	struct time_interpolator *curr, **prev;
-	unsigned long flags;
-
-	spin_lock(&time_interpolator_lock);
-	prev = &time_interpolator_list;
-	for (curr = *prev; curr; curr = curr->next) {
-		if (curr = ti) {
-			*prev = curr->next;
-			break;
-		}
-		prev = &curr->next;
-	}
-
-	write_seqlock_irqsave(&xtime_lock, flags);
-	if (ti = time_interpolator) {
-		/* we lost the best time-interpolator: */
-		time_interpolator = NULL;
-		/* find the next-best interpolator */
-		for (curr = time_interpolator_list; curr; curr = curr->next)
-			if (is_better_time_interpolator(curr))
-				time_interpolator = curr;
-		time_interpolator_reset();
-	}
-	write_sequnlock_irqrestore(&xtime_lock, flags);
-	spin_unlock(&time_interpolator_lock);
-}
-#endif /* CONFIG_TIME_INTERPOLATION */
-
 /**
  * msleep - sleep safely even with waitqueue interruptions
  * @msecs: Time in milliseconds to sleep for
