From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 15 Jun 2007 17:46:15 +0000
Subject: Re: [PATCH] ia64: Scalability improvement of gettimeofday with jitter
Message-Id: <Pine.LNX.4.64.0706151040180.9132@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <466E0FA4.2040405@jp.fujitsu.com>
In-Reply-To: <466E0FA4.2040405@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Cc: linux-ia64@vger.kernel.org, Linux Kernel list <linux-kernel@vger.kernel.org>

On Tue, 12 Jun 2007, Hidetoshi Seto wrote:

> 
> [arch/ia64/kernel/time.c]
> > #ifdef CONFIG_SMP
> >   /* On IA64 in an SMP configuration ITCs are never accurately synchronized.
> >    * Jitter compensation requires a cmpxchg which may limit
> >    * the scalability of the syscalls for retrieving time.
> >    * The ITC synchronization is usually successful to within a few
> >    * ITC ticks but this is not a sure thing. If you need to improve
> >    * timer performance in SMP situations then boot the kernel with the
> >    * "nojitter" option. However, doing so may result in time fluctuating (maybe
> >    * even going backward) if the ITC offsets between the individual CPUs
> >    * are too large.
> >    */
> >   if (!nojitter) itc_interpolator.jitter = 1;
> > #endif
> 
> ia64 uses jitter compensation to prevent time from going backward.
> 
> This jitter compensation logic which keep track of cycle value
> recently returned is provided as generic code (and copied to
> arch/ia64/kernel/fsys.S).
> It seems that there is no user (setting jitter = 1) other than ia64.

Yes there are only two users of time interpolators. The generic 
gettimeofday work by John Stultz will make time interpolators obsolete 
soon. I already saw a patch to remove them.

> The cmpxchg is known to take long time in an SMP environment but
> it is easy way to guarantee atomic operation.
> I think this is acceptable while there are no better alternatives.
> 
> OTOH, the do-while forces retry if cmpxchg fails (no exchanges).
> This means that if there are N threads trying to do cmpxchg at
> same time, only 1 can out from this loop and N-1 others will be
> trapped in the loop. This also means that a thread could loop
> N times in worst case.

Right.

> Obviously this is a scalability issue.
> To avoid this retry loop, I'd like to propose new logic that
> removes do-while here.

Booting with nojitter is the easiest way to solve this if one is willing 
to accept slightly inaccurate clocks.

> The basic idea is "use winner's cycle instead of retrying."
> Assuming that there are N threads trying to do cmpxchg, it also
> be assumed that they are trying to update last_cycle by its own
> new value while all values are almost same.
> Therefore, it will work that treating threads as a group and
> deciding a group's return value by picking up one from the group.
> 
> Fortunately, cmpxchg mechanism can help this logic. Only first
> one in group can exchange the last_cycle successfully, so this
> "winner" gets previous last_cycle as the return value of cmpxchg.
> The rests in group will fail to exchange since last_cycle is
> already updated by winner, so these "loser" gets current
> last_cycle on cmpxchg's return. This means that all thread in
> the group can know the winner's cycle.
> 
>   ret = cmpxchg(&last_cycle, last, new);
>   if (ret = last)
>     return new; /* you win! */
>   else
>     return ret; /* you lose. ret is winner's new */

Interesting solution. But there may be multiple updates of last happening. 
Which of the winners is the real winner?

> 
> I had a test running gettimeofday() processes at 1.5GHz*4way box.
> It shows followings:
> 
>  - x1 process:
>     0.15us / 1 gettimeofday() call
>     0.15us / 1 gettimeofday() call with patch
>  - x2 process:
>     0.31us / 1 gettimeofday() call
>     0.24us / 1 gettimeofday() call with patch
>  - x3 process:
>     1.59us / 1 gettimeofday() call
>     1.11us / 1 gettimeofday() call with patch
>  - x4 process:
>     2.34us / 1 gettimeofday() call
>     1.29us / 1 gettimeofday() call with patch
> 
> I know that this patch could not help quite huge system since
> such system like having 1024CPUs should have better clocksource
> instead of doing cmpxchg. Even though this patch will work good
> on middle-sized box (4~8way, possibly 16~64way?).

Our SGI machines have their own clock that is hardware replicated to all 
nodes.

This would certainly a nice improvement for SMP machines. It certainly 
works nicely for 2 way systems.
