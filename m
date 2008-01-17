From: "stephane eranian" <eranian@googlemail.com>
Date: Thu, 17 Jan 2008 00:29:10 +0000
Subject: runqueue locks in schedule()
Message-Id: <7c86c4470801161629t3870da59hb6ac371c44126b07@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: ia64 <linux-ia64@vger.kernel.org>, Stephane Eranian <eranian@gmail.com>, Corey J Ashford <cjashfor@us.ibm.com>

Hello,

As suggested by people on this list, I have changed perfmon2 to use
the high resolution
timers as the interface to allow timeout-based event set multiplexing.
This works around
the problems I had with tickless-enabled kernels.

Multiplexing is supported in per-thread as well. In that case, the
timeout measures virtual
time. When the thread is context switched out, we need to save the
remainder of the timeout
and cancel the timer. When the thread is context switched in, we need
to reinstall the timer.
These timer save/restore operations have to be done in the switch_to()
code near the end
of schedule().

There are situations where hrtimer_start() may end up trying to
acquire the runqueue lock.
This happens on a context switch where the current thread is blocking
(not preempted) and
the new timeout happens to be either in the past or just expiring.
We've run into such situations
with simple tests.

On all architectures, but IA-64, it seems thet the runqueue lock is
held until the end of schedule().
On IA-64, the lock is released BEFORE switch_to() for some reason I
don't quite remember. That
may not even be needed anymore.

The early unlocking is controlled by a macro named __ARCH_WANT_UNLOCKED_CTXSW.
Defining this macros on X86 (or PPC) fixed our problem.

It is not clear to me why the runqueue lock needs to be held up until
the end of schedule() on some
platforms and not on others. Not that releasing the lock earlier does
not necessarily introduce
more overhead because the lock is never re-acquired later in the
schedule() function.

Question:
   - is it safe to release the lock before switch_to() on all architectures?

Thanks.
