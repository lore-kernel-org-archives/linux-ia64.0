From: John Hawkes <hawkes@babylon.engr.sgi.com>
Date: Wed, 01 Oct 2003 01:00:03 +0000
Subject: [BUG, RFC] do_gettimeofday going backwards
Message-Id: <marc-linux-ia64-106497008007151@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I believe that the non-default "unsynchronized clock" gettimeoffset schemes
(for ia64 SN2 and for any other "drifty clock" platform) in both 2.4 and
2.6 are both fundamentally flawed and will occasionally allow
do_gettimeofday() to produce a time-going-backwards value, and more
frequently produce a time-standing-still value.  Both 2.4 and 2.6 share
the same design approach, even if their implementations differ in the
details.

In essence, the non-default "unsynchronized clock" design is this:
When the timer bottom-half or do_settimeofday() updates the xtime value
pair, it calls a platform-specific hook to timestamp this event.  Presumably
this timestamp is captured using a globally synchronized clock that is
independent of each CPU's clock.  For SN2 this is the "RTC clock."  Then,
when do_gettimeofday() wants to compute an accurate time-of-day, it takes
the last xtime value pair and adds an offset adjustment.  For SN2 that
adjustment is calculated as the interval of time between now and the
previous time the xtime value pair changed, using that RTC clock as a time
base.

This algorithm produces an accurate time-since-xtime-was-last-updated, but
it does not produce an accurate time-of-day.

What's wrong?  Suppose that the timer interrupt occurs every 1000 usecs.
Suppose timer_bh executes at time RTC=t0, and that at that point we have
xtime.tv_sec=0 and tv_usec=0.  The SN2 hook remembers this t0 timestamp.
A subsequent call to do_gettimeofday() computes the offset (tCurrent - t0)
and adds this to the xtime.tv_* value pair.  Thus, based upon this initial
xtime value pair, do_gettimeofday() returns a nicely ascending TOD value.

Now suppose the next timer interrupt occurs, but the timer_bh gets delayed
by 100 useconds.  Just prior to timer_bh executing, a do_gettimeofday()
computes an offset of 1099 usecs, so it returns a TOD of tv_usec=(0+1099).
Then timer_bh executes and updates tv_usec=1000 and timestamps that at
RTC time t1=(t0+1100).  Just *after* the timer_bh executes, a
do_gettimeofday() computes an offset of zero, and thus computes
tv_usec=(1000+0).  The TOD tv_usec just went backwards, from 1099 to 1000.

In ia64, gettimeoffset works correctly in a system with globally
synchronized ITC clocks because 2.4's gettimeoffset() and 2.6's
itc_get_offset() have the advantage of being able to look at
cpu_data(...)->itm_next and determine precisely when jiffies should have
been updated by the last timer interrupt.  The SN2 platform has no such
capability.  It only knows when the timer_bh updated the xtime value pair,
not when timer_interrupt() executed (or even better, when it should have
executed had the interrupt been instantaneously serviced).

SGI has solved this problem with 2.4-based kernels using a hook in
timer_interrupt() to record an RTC timestamp that is functionally equivalent
to the timestamp that a global-ITC system can compute in gettimeoffset():
                }
                do_timer(regs);
                local_cpu_data->itm_next = new_itm;
+
+               if (ia64_platform_timer_interrupt)
+                       (*ia64_platform_timer_interrupt)();
        } else
                local_cpu_data->itm_next = new_itm;

where the SN2 timer interrupt hook does:
+       long last_rtc_delta +           ( ((long)local_cpu_data->itm_next - (long)ia64_get_itc())
+            * (long)sn_rtc_per_itc) >> SN_RTC_PER_ITC_SHIFT;
+       sn_last_adj_rtc_val = last_rtc_delta + GET_RTC_COUNTER();

Two possible solutions come to my mind for 2.6.  One is to have SN2 register
an additional timer interrupt callback that would capture that RTC
timestamp.  I believe this ought to work, even though this second callback
captures the ia64_get_itc() at a time that is somewhat distant from the time
the main timer interrupt handler executes.  Another solution is to have SN2
register an alternative timer interrupt callback that would replicate what
the default interrupt handler does, plus do the special SN2 RTC
timestamping.  This alternative is more efficient, but it has the
disadvantage of replicating code that needs to remain identical to the
default handler.

Comments?

John Hawkes
