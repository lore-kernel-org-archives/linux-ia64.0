From: Petr Tesarik <ptesarik@suse.cz>
Date: Fri, 27 Aug 2010 13:37:33 +0000
Subject: Serious problem with ticket spinlocks on ia64
Message-Id: <201008271537.35709.ptesarik@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Hedi Berriche <hedi@sgi.com>

Hi everybody,

SGI has recently experienced failures with the new ticket spinlock
implementation. Hedi Berriche sent me a simple test case that can
trigger the failure on the siglock. To debug the issue, I wrote a
small module that watches writes to current->sighand->siglock and
records the values.

I observed that the __ticket_spin_lock() primitive fails when the
tail wraps around to zero. I reconstructed the following:

CPU 7 holds the spinlock
CPU 5 wants to acquire the spinlock
Spinlock value is 0xfffcffff
	 (now serving 0x7fffe, next ticket 0x7ffff)

CPU 7 executes st2.rel to release the spinlock.
At the same time CPU 5 executes a fetchadd4.acq.
The resulting lock value is 0xfffe0000 (correct), and CPU 5 has
recorded its ticket number (0x7fff).

Consequently, the first spinlock loop iteration succeeds, and CPU 5
now holds the spinlock.

Next, CPU 5 releases the spinlock with st2.rel, changing the lock
value to 0x0 (correct).

SO FAR SO GOOD.

Now, CPU 4, CPU 5 and CPU 7 all want to acquire the lock again.
Interestingly, CPU 5 and CPU 7 are both granted the same ticket,
and the spinlock value (as seen from the debug fault handler) is
0x0 after single-stepping over the fetchadd4.acq, in both cases.
CPU 4 correctly sets the spinlock value to 0x1.

I don't know if the simultaneos acquire attempt and release are
necessary to trigger the bug, but I noted it here.

I've only seen this happen when the spinlock wraps around to zero,
but I don't know whether it cannot happen otherwise.

In any case, there seems to be a serious problem with memory
ordering, and I'm not an expert to tell exactly what it is.

Any ideas?

Petr Tesarik
L3 International
Novell, Inc.
