From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 15 Oct 2003 01:17:32 +0000
Subject: Re: [BUG, RFC] do_gettimeofday going backwards
Message-Id: <marc-linux-ia64-106618067209620@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106497008007151@msgid-missing>
In-Reply-To: <marc-linux-ia64-106497008007151@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 30 Sep 2003 18:00:03 -0700 (PDT), John Hawkes <hawkes@babylon.engr.sgi.com> said:

  John> What's wrong?  Suppose that the timer interrupt occurs every
  John> 1000 usecs.  Suppose timer_bh executes at time RTC=t0, and
  John> that at that point we have xtime.tv_sec=0 and tv_usec=0.
  John> The SN2 hook remembers this t0 timestamp.  A subsequent call
  John> to do_gettimeofday() computes the offset (tCurrent - t0) and
  John> adds this to the xtime.tv_* value pair.  Thus, based upon this
  John> initial xtime value pair, do_gettimeofday() returns a nicely
  John> ascending TOD value.

  John> Now suppose the next timer interrupt occurs, but the timer_bh
  John> gets delayed by 100 useconds.  Just prior to timer_bh
  John> executing, a do_gettimeofday() computes an offset of 1099
  John> usecs, so it returns a TOD of tv_usec=(0+1099).  Then
  John> timer_bh executes and updates tv_usec=1000 and timestamps
  John> that at RTC time t1=(t0+1100).  Just *after* the timer_bh
  John> executes, a do_gettimeofday() computes an offset of zero, and
  John> thus computes tv_usec=(1000+0).  The TOD tv_usec just went
  John> backwards, from 1099 to 1000.

Then your time-interpolator is broken.  As I have expained on previous
occasions (in particular in a mail to Jes), last_nsec_offset must not
be _cleared_ on a timer-tick.  Instead, it needs to be decremented by
the timer tick period.  So in your case, last_nsec_offset would
decrease from 1099000 to 99000.

Somehow, I have a feeling you're looking at 2.4.  If so, please take a
look at the time-interpolator code in 2.6 (see
CONFIG_TIME_INTERPOLATION near the end of include/linux/timex.h).

	--david
