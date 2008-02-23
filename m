From: Peter Zijlstra <peterz@infradead.org>
Date: Sat, 23 Feb 2008 20:40:42 +0000
Subject: Re: runqueue locks in schedule()
Message-Id: <1203799242.6242.108.camel@lappy>
List-Id: <linux-ia64.vger.kernel.org>
References: <7c86c4470801161629t3870da59hb6ac371c44126b07@mail.gmail.com>
	 <1200576266.28661.27.camel@twins>
	 <7c86c4470802230650l1605db93o3c9b38ec52bcba89@mail.gmail.com>
In-Reply-To: <7c86c4470802230650l1605db93o3c9b38ec52bcba89@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: stephane eranian <eranian@googlemail.com>
Cc: linux-kernel@vger.kernel.org, ia64 <linux-ia64@vger.kernel.org>, Stephane Eranian <eranian@gmail.com>, Corey J Ashford <cjashfor@us.ibm.com>, Ingo Molnar <mingo@elte.hu>


On Sat, 2008-02-23 at 15:50 +0100, stephane eranian wrote:
> Peter,
> 
> >  On Wed, 2008-01-16 at 16:29 -0800, stephane eranian wrote:
> >  > Hello,
> >  >
> >  > As suggested by people on this list, I have changed perfmon2 to use
> >  > the high resolution timers as the interface to allow timeout-based
> >  > event set multiplexing. This works around the problems I had with
> >  > tickless-enabled kernels.
> >  >
> >  > Multiplexing is supported in per-thread as well. In that case, the
> >  > timeout measures virtual time. When the thread is context switched
> >  > out, we need to save the remainder of the timeout and cancel the
> >  > timer. When the thread is context switched in, we need to reinstall
> >  > the timer. These timer save/restore operations have to be done in the
> >  > switch_to() code near the end of schedule().
> >  >
> >  > There are situations where hrtimer_start() may end up trying to
> >  > acquire the runqueue lock. This happens on a context switch where the
> >  > current thread is blocking (not preempted) and the new timeout happens
> >  > to be either in the past or just expiring. We've run into such
> >  > situations with simple tests.
> >  >
> >  > On all architectures, but IA-64, it seems thet the runqueue lock is
> >  > held until the end of schedule(). On IA-64, the lock is released
> >  > BEFORE switch_to() for some reason I don't quite remember. That may
> >  > not even be needed anymore.
> >  >
> >  > The early unlocking is controlled by a macro named
> >  > __ARCH_WANT_UNLOCKED_CTXSW. Defining this macros on X86 (or PPC) fixed
> >  > our problem.
> >  >
> >  > It is not clear to me why the runqueue lock needs to be held up until
> >  > the end of schedule() on some platforms and not on others. Not that
> >  > releasing the lock earlier does not necessarily introduce more
> >  > overhead because the lock is never re-acquired later in the schedule()
> >  > function.
> >  >
> >  > Question:
> >  >    - is it safe to release the lock before switch_to() on all architectures?
> >
> >  I had similar problem when using hrtimers from the scheduler, I extended
> >  the HRTIMER_CB_IRQSAFE_NO_SOFTIRQ time type to run with cpu_base->lock
> >  unlocked.
> >
> I am running into an issue when enabling this flag. Basically, the
> timer never fires
> when it gets into this situation where in hrtimer_start() the timer
> ends up being the
> next one to fire. In this mode,  hrtimer_enqueue_reprogram() become a NOP. But
> then nobody never inserts the time into any queue. There is a comment that
> says "caller site takes care of this". Could you elaborate on this?

That would mean the timer already expired by the time you get to program
it.

The way to handle these is:

for (;;) {
	if (hrtimer_active(timer))
		break;

	now = hrtimer_cb_get_time(timer);
	hrtimer_forward(timer, now, period);
	hrtimer_start(timer, timer->expires, HRTIMER_MODE_ABS);
}

You could use the return value from hrtimer_forward() to determine how
many events you missed if that is needed. The timer function needs a
similar loop if it wants to use HRTIMER_RESTART.

Single shot timers can handle it like in kernel/hrtimer.c:do_nanosleep()

  hrtimer_start(timer, ...);
  if (!hrtimer_active(timer))
	/* handle the missed expiration */



