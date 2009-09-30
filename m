From: Robin Holt <holt@sgi.com>
Date: Wed, 30 Sep 2009 02:46:48 +0000
Subject: Re: [git pull] ia64 changes
Message-Id: <20090930024648.GH8934@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Sep 29, 2009 at 06:30:02PM -0700, Linus Torvalds wrote:
> Just to continue on that point: with the old locks on x86, we had test 
> loads that had basically 10,000:1 factors of unfairness, where one CPU 
> would continually get the lock because it was hot in _its_ caches, and all 
> other CPU's would almost always fail.
> 
> In that situation, re-enabling interrupts can be critical, just because 
> they might be disabled for many thousands of iterations of the spinlock 
> being busy on another CPU.
> 
> With the ticket locks, you'd need to have a _huge_ machine in order to 
> ever see that kind of situation (ie now you'd need to see thousands of 
> CPU's all trying to get that lock in order to see latencies that are a 
> thousand iterations of whatever happens inside the spinlock). And in 
> practice, with good locking, you should never see that. If you actually 
> have thousands of CPU's (or even hundreds) all wanting the same lock at 
> the same time, you're just going to have to fix the locking.

If I recall the problems correctly, it is typically a case where a lock
is held for an extended period of time for "legitimate" reasons. That
will cause interrupts to be disabled on key cpus for an unusually long
period of time (cpu 0 has been extremely problematic in holding off
timers, but I/O targeted interrupts have also caused difficult to diagnose
erratic I/O patterns).

NOTE: I put "legitimate" in quotes because I realize legitimate is often
being used as a synonym for either a) the maintainer of that part of
the kernel refuses to allow their code to be restructured for a minor
sub-arch because it makes their code more complex or b) the people seeing
the issue don't have the time to diagnose and fix the problem right now.
"Legitimate", therefore, is in the eyes of the beholder.

Thanks,
Robin
