From: Christoph Lameter <clameter@sgi.com>
Date: Mon, 07 Jun 2004 20:24:45 +0000
Subject: Re: Scalability enhancements for gettimeofday
Message-Id: <Pine.LNX.4.58.0406071314480.5172@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405201205.57930.clameter@sgi.com>
In-Reply-To: <200405201205.57930.clameter@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 7 Jun 2004, David Mosberger wrote:

> >>>>> On Mon, 7 Jun 2004 10:46:41 -0700 (PDT), Christoph Lameter <clameter@sgi.com> said:
>
>   Christoph> Would it be possible to avoid any changes to arch
>   Christoph> independent code by changing get_offset fir the ITC clock
>   Christoph> to never return an earlier offset in the same tick?
>
> I didn't think so.  The problem is that for ITC-interpolation, we
> basically need a two-phase protocol: get an offset and if everything
> is consistent, commit to the new offset.  You're welcome to try,
> though.

How would you like the following patch? It simply uses a static variable
to insure that the ITC value used in get_offset never goes backward.
gettimeofday then becomes much simpler.

This still needs the following improvements that I probably should not
waste time with if this is not acceptable:
- last_itc should really be updated with cmpxchg
- the gettimeofday fast path assembly code would have to be updated.

Index: linux-2.6.6/arch/ia64/kernel/time.c
=================================--- linux-2.6.6.orig/arch/ia64/kernel/time.c	2004-05-09 19:32:24.000000000 -0700
+++ linux-2.6.6/arch/ia64/kernel/time.c	2004-06-07 13:11:05.817463999 -0700
@@ -77,9 +77,17 @@
 unsigned long
 itc_get_offset (void)
 {
+	static unsigned long last_itc=0;
 	unsigned long elapsed_cycles, lost = jiffies - wall_jiffies;
 	unsigned long now = ia64_get_itc(), last_tick;

+
+	/* Make sure time does not run backwards but allow warparound */
+	if (last_itc && now<last_itc && last_itc-now<0x8000000000000000UL)
+	       now=last_itc;
+        else
+	       last_itc=now;
+
 	last_tick = (cpu_data(TIME_KEEPER_ID)->itm_next
 		     - (lost + 1)*cpu_data(TIME_KEEPER_ID)->itm_delta);

@@ -134,51 +142,14 @@
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

