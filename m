From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 04 Aug 2004 16:42:34 +0000
Subject: Self-tuning logic for the time interpolators?
Message-Id: <Pine.LNX.4.58.0408040934080.14500@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This is an idea that I have been kicking around in the last days.

With the ability to increase the accuracy of the multiplication in the
time interpolator comes the danger that the interpolator clock may run too
fast on some others. On the other hand I have seen systems where the
interpolator clock runs too slow so that time is jumping forward in large
increments (0.1-0.5ms). We would like to have a continuous flow of time
though with only minimal time jumps.

The following patch implements logic that tunes time interpolators
by increasing or decreasing the speed of the interpolator clock if that
happens. With that I was able to reach an average skip of less than 10ns
per cycle. This patch also increases the precision returned by
clock_getres for CLOCK_REALTIME and CLOCK_MONOTONIC since I thought that
the accurate time interpolator would allow to justify that move.

The patch still needs some work but it is functional and allows
to see how self-tuning could work.

Index: linux-2.6.7/include/linux/timex.h
=================================--- linux-2.6.7.orig/include/linux/timex.h	2004-07-29 12:08:14.000000000 -0700
+++ linux-2.6.7/include/linux/timex.h	2004-08-04 00:34:58.000000000 -0700
@@ -327,6 +327,10 @@
 #define TIME_SOURCE_MMIO32 2
 #define TIME_SOURCE_FUNCTION 3

+/* Countdown to do the adjustment of the interpolators. 1 minute */
+#define TIME_ADJUST_COUNTDOWN (HZ*60)
+/* If we skip more than these number of nanoseconds per tick adjust interpolator clock */
+#define TIME_MAX_NS_SKIP_PER_TICK 10
 /* For proper operations time_interpolator clocks must run slightly slower
  * than the standard clock since the interpolator may only correct by having
  * time jump forward during a tick. A slower clock is usually a side effect
@@ -360,6 +364,9 @@
 	unsigned long last_cycle;	/* Last timer value if TIME_SOURCE_JITTER is set */
 	unsigned long frequency;	/* frequency in counts/second */
 	long drift;			/* drift in parts-per-million (or -1) */
+	unsigned long countdown;	/* cycles left to adjustments */
+	unsigned long count_resets;	/* How many resets happened */
+	unsigned long ns_skipped;	/* Nanoseconds that were skipped */
 	struct time_interpolator *next;
 };

@@ -418,6 +425,9 @@
 {
 	time_interpolator->offset = 0;
 	time_interpolator->last_counter = time_interpolator_get_counter();
+	time_interpolator->countdown=TIME_ADJUST_COUNTDOWN;
+	time_interpolator->count_resets=0;
+	time_interpolator->ns_skipped=0;
 }

 #define GET_TI_NSECS(count,i) ((((count) - i->last_counter) * i->nsec_per_cyc) >> i->shift)
@@ -443,9 +453,41 @@

 	if (delta_nsec < 0 || (unsigned long) delta_nsec < offset)
 		time_interpolator->offset = offset - delta_nsec;
-	else
+	else {
+		time_interpolator->ns_skipped+= delta_nsec-offset;
+		time_interpolator->count_resets++;
 		time_interpolator->offset = 0;			/* Early tick. Resync */
+	}
 	time_interpolator->last_counter = counter;
+	if (time_interpolator->countdown)
+		time_interpolator->countdown--;
+	else {
+		/* Check for the necessity to adjust every minute
+		 * Skip whatever happened in the first minute after bootup. We are only interested in the regular behavior of the
+		 * interpolator.
+		 * if (time_inteprolator->count_resets=0) time_interpolator->nsec_per_cyc--;
+	         * if (other cond) time_interpolator->nsec_per_cyc++;
+		 */
+		if (jiffies >= 2*TIME_ADJUST_COUNTDOWN) {
+			if (time_interpolator->count_resets=0)
+			{
+				/* Uhh... no resets. We are running too fast */
+				time_interpolator->nsec_per_cyc--;
+				printk(KERN_WARNING "time interpolator fast. nsec_per_cyc adjusted to %u\n",time_interpolator->nsec_per_cyc);
+			} else
+			if (time_interpolator->ns_skipped> TIME_MAX_NS_SKIP_PER_TICK*TIME_ADJUST_COUNTDOWN)
+			{
+				/* We are skipping more than 10usec per tick increase clock speed. */
+				time_interpolator->nsec_per_cyc++;
+				printk(KERN_WARNING "time interpolator slow. %lu nsecs skipped in %lu skips. nsec_per_cyc adjusted to %u\n",time_interpolator->ns_skipped,time_interpolator->count_resets,time_interpolator->nsec_per_cyc);
+
+			} else
+				printk(KERN_INFO "time_interpolator ok. %lu nsecs skipped in %lu skips.\n",time_interpolator->ns_skipped,time_interpolator->count_resets);
+		}
+		time_interpolator->count_resets=0;
+		time_interpolator->ns_skipped=0;
+		time_interpolator->countdown=TIME_ADJUST_COUNTDOWN;
+	}
 }

 #else /* !CONFIG_TIME_INTERPOLATION */
Index: linux-2.6.7/arch/ia64/sn/kernel/sn2/timer.c
=================================--- linux-2.6.7.orig/arch/ia64/sn/kernel/sn2/timer.c	2004-07-22 19:45:58.000000000 -0700
+++ linux-2.6.7/arch/ia64/sn/kernel/sn2/timer.c	2004-08-03 21:04:13.000000000 -0700
@@ -28,7 +28,7 @@
 {
 	sn2_interpolator.frequency = sn_rtc_cycles_per_second;
 	sn2_interpolator.drift = -1;	/* unknown */
-	sn2_interpolator.shift = 0;	/* RTC is 54 bits maximum shift is 10 */
+	sn2_interpolator.shift = 10;	/* RTC is 54 bits maximum shift is 10 */
 	sn2_interpolator.addr = RTC_COUNTER_ADDR;
 	sn2_interpolator.source = TIME_SOURCE_MMIO64;
 	register_time_interpolator(&sn2_interpolator);
Index: linux-2.6.7/kernel/posix-timers.c
=================================--- linux-2.6.7.orig/kernel/posix-timers.c	2004-07-22 19:40:09.000000000 -0700
+++ linux-2.6.7/kernel/posix-timers.c	2004-08-03 21:09:26.000000000 -0700
@@ -218,7 +218,10 @@
 		.clock_get = do_posix_clock_monotonic_gettime,
 		.clock_set = do_posix_clock_monotonic_settime
 	};
-
+#ifdef CONFIG_TIME_INTERPOLATION
+	/* Clocks are more accurate with time interpolators */
+	clock_realtime.res=clock_monotonic.res=time_interpolator->nsec_per_cyc;
+#endif
 	register_posix_clock(CLOCK_REALTIME, &clock_realtime);
 	register_posix_clock(CLOCK_MONOTONIC, &clock_monotonic);

