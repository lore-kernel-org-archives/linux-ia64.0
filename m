From: Christoph Lameter <clameter@sgi.com>
Date: Tue, 08 Jun 2004 04:08:10 +0000
Subject: Re: Scalability enhancements for gettimeofday
Message-Id: <Pine.LNX.4.58.0406072104340.17375@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405201205.57930.clameter@sgi.com>
In-Reply-To: <200405201205.57930.clameter@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 7 Jun 2004, David Mosberger wrote:

> >>>>> On Mon, 7 Jun 2004 15:48:57 -0700 (PDT), Christoph Lameter <clameter@sgi.com> said:
>
>   >>  Eh, you need to worry about races.  There can be a timer-tick
>   >> while get_offset is running.
>
>   Christoph> get_offset is invoked from gettimeofday with a
>   Christoph> seqlock. In that case it would repeat its actions. I can
>   Christoph> put an explicit seqlock into get_offset?
>
> I guess I wasn't clear enough: if you update "last_nsec_offset" in
> get_offset(), then you might have committed a "bad" value into a
> global variable.  Bad.  The seq-lock won't help you there, because the
> global variable alreayd has been polluted with a bad value.

Here is the patch with the use of cmpxchg to update last_itc:

Index: linux-2.6.6/arch/ia64/kernel/time.c
=================================--- linux-2.6.6.orig/arch/ia64/kernel/time.c	2004-05-09 19:32:24.000000000 -0700
+++ linux-2.6.6/arch/ia64/kernel/time.c	2004-06-07 21:03:42.551491629 -0700
@@ -77,12 +77,30 @@
 unsigned long
 itc_get_offset (void)
 {
-	unsigned long elapsed_cycles, lost = jiffies - wall_jiffies;
-	unsigned long now = ia64_get_itc(), last_tick;
+	static unsigned long last_itc=0;
+	unsigned long elapsed_cycles, lost;
+	unsigned long now, last_tick;
+	unsigned long litc;

-	last_tick = (cpu_data(TIME_KEEPER_ID)->itm_next
+	/* Determine ITC value that is >= than the last one used */
+	do {
+		litc=last_itc;
+		now = ia64_get_itc();
+		lost = jiffies - wall_jiffies;
+		last_tick = (cpu_data(TIME_KEEPER_ID)->itm_next
 		     - (lost + 1)*cpu_data(TIME_KEEPER_ID)->itm_delta);
-
+
+		/* Make sure time does not run backwards but allow warparound */
+		if (last_itc && now<last_itc && last_itc-now<0x8000000000000000UL)
+		{
+			/* Time would be running backwards if we would use this ITC value.
+			 * Use the last ITC value instead.
+			 */
+			now=litc;
+			break;
+		}
+	} while (unlikely(cmpxchg(&last_itc,litc,now)));
+
 	elapsed_cycles = now - last_tick;
 	return (elapsed_cycles*local_cpu_data->nsec_per_cyc) >> IA64_NSEC_PER_CYC_SHIFT;
 }
@@ -134,51 +152,14 @@
 void
 do_gettimeofday (struct timeval *tv)
 {
-	unsigned long seq, nsec, usec, sec, old, offset;
+	unsigned long seq, nsec, usec, sec, offset;

-	while (1) {
+	do {
 		seq = read_seqbegin(&xtime_lock);
-		{
-			old = last_nsec_offset;
-			offset = time_interpolator_get_offset();
-			sec = xtime.tv_sec;
-			nsec = xtime.tv_nsec;
-		}
-		if (unlikely(read_seqretry(&xtime_lock, seq)))
-			continue;
-		/*
-		 * Ensure that for any pair of causally ordered gettimeofday() calls, time
-		 * never goes backwards (even when ITC on different CPUs are not perfectly
-		 * synchronized).  (A pair of concurrent calls to gettimeofday() is by
-		 * definition non-causal and hence it makes no sense to talk about
-		 * time-continuity for such calls.)
-		 *
-		 * Doing this in a lock-free and race-free manner is tricky.  Here is why
-		 * it works (most of the time): read_seqretry() just succeeded, which
-		 * implies we calculated a consistent (valid) value for "offset".  If the
-		 * cmpxchg() below succeeds, we further know that last_nsec_offset still
-		 * has the same value as at the beginning of the loop, so there was
-		 * presumably no timer-tick or other updates to last_nsec_offset in the
-		 * meantime.  This isn't 100% true though: there _is_ a possibility of a
-		 * timer-tick occurring right right after read_seqretry() and then getting
-		 * zero or more other readers which will set last_nsec_offset to the same
-		 * value as the one we read at the beginning of the loop.  If this
-		 * happens, we'll end up returning a slightly newer time than we ought to
-		 * (the jump forward is at most "offset" nano-seconds).  There is no
-		 * danger of causing time to go backwards, though, so we are safe in that
-		 * sense.  We could make the probability of this unlucky case occurring
-		 * arbitrarily small by encoding a version number in last_nsec_offset, but
-		 * even without versioning, the probability of this unlucky case should be
-		 * so small that we won't worry about it.
-		 */
-		if (offset <= old) {
-			offset = old;
-			break;
-		} else if (likely(cmpxchg(&last_nsec_offset, old, offset) = old))
-			break;
-
-		/* someone else beat us to updating last_nsec_offset; try again */
-	}
+		offset = time_interpolator_get_offset();
+		sec = xtime.tv_sec;
+		nsec = xtime.tv_nsec;
+	} while (unlikely(read_seqretry(&xtime_lock, seq)));

 	usec = (nsec + offset) / 1000;

