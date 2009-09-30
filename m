From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 30 Sep 2009 02:56:47 +0000
Subject: Re: [git pull] ia64 changes
Message-Id: <alpine.LFD.2.01.0909291949290.6996@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



On Tue, 29 Sep 2009, Robin Holt wrote:
> 
> If I recall the problems correctly, it is typically a case where a lock
> is held for an extended period of time for "legitimate" reasons. That
> will cause interrupts to be disabled on key cpus for an unusually long
> period of time (cpu 0 has been extremely problematic in holding off
> timers, but I/O targeted interrupts have also caused difficult to diagnose
> erratic I/O patterns).

Sure. But that case has nothing to do with the lock itself - the long 
latencies are independent of locking mechanism.

Of course, they'll only happen on _that_ CPU while it is holding the lock, 
and ticket locks may end up transferring the latency to other CPU's too 
due to having interrupts disabled while waiting, but that doesn't actually 
affect the overall bad system latency as much as how often you hit the 
latency issue. The ticket locks can certainly cause you to hit it more 
often.

On the other hand, the kind of problems we _used_ to have (before ticket 
locks) was that even if the long-time holder tried to be nice, and 
released the lock for a short while (only to then immediately re-take it), 
it wouldn't help other CPU's. The ticket locks help that case: with ticket 
locks, you can basically have something like

	if (lock_contended(lock)) {
		unlock(lock);
		lock(lock);
	}

that acts as a preemption point, kind of like the "cond_resched()" calls 
we have sprinkled around for cases that otherwise might have long preempt 
latencies.

Without ticket locks, you can't sanely do the above. With them, it works 
(although you'd better have a damn good reason for crap like that).

			Linus
