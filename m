From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Tue, 12 Jun 2007 03:14:44 +0000
Subject: [PATCH] ia64: Scalability improvement of gettimeofday with jitter
Message-Id: <466E0FA4.2040405@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>

Hi all,

This is a proposal with a patch to improve scalability
of time handling.

As described in comment at arch/ia64/kernel/time.c:

[arch/ia64/kernel/time.c]
> #ifdef CONFIG_SMP
>   /* On IA64 in an SMP configuration ITCs are never accurately synchronized.
>    * Jitter compensation requires a cmpxchg which may limit
>    * the scalability of the syscalls for retrieving time.
>    * The ITC synchronization is usually successful to within a few
>    * ITC ticks but this is not a sure thing. If you need to improve
>    * timer performance in SMP situations then boot the kernel with the
>    * "nojitter" option. However, doing so may result in time fluctuating (maybe
>    * even going backward) if the ITC offsets between the individual CPUs
>    * are too large.
>    */
>   if (!nojitter) itc_interpolator.jitter = 1;
> #endif

ia64 uses jitter compensation to prevent time from going backward.

This jitter compensation logic which keep track of cycle value
recently returned is provided as generic code (and copied to
arch/ia64/kernel/fsys.S).
It seems that there is no user (setting jitter = 1) other than ia64.

[kernel/timer.c]
> static inline u64 time_interpolator_get_counter(int writelock)
> {
>   unsigned int src = time_interpolator->source;
>
>   if (time_interpolator->jitter)
>   {
>     cycles_t lcycle;
>     cycles_t now;
>
>     do {
>       lcycle = time_interpolator->last_cycle;
>       now = time_interpolator_get_cycles(src);
>       if (lcycle && time_after(lcycle, now))
>         return lcycle;
>
>       /* When holding the xtime write lock, there's no need
>        * to add the overhead of the cmpxchg.  Readers are
>        * force to retry until the write lock is released.
>        */
>       if (writelock) {
>         time_interpolator->last_cycle = now;
>         return now;
>       }
>       /* Keep track of the last timer value returned. The use of cmpxchg here
>        * will cause contention in an SMP environment.
>        */
>     } while (unlikely(cmpxchg(&time_interpolator->last_cycle, lcycle, now) != lcycle));
>     return now;
>   }
>   else
>     return time_interpolator_get_cycles(src);
> }

The current logic is consist of do-while loop with cmpxchg.

The cmpxchg is known to take long time in an SMP environment but
it is easy way to guarantee atomic operation.
I think this is acceptable while there are no better alternatives.

OTOH, the do-while forces retry if cmpxchg fails (no exchanges).
This means that if there are N threads trying to do cmpxchg at
same time, only 1 can out from this loop and N-1 others will be
trapped in the loop. This also means that a thread could loop
N times in worst case.

Obviously this is a scalability issue.
To avoid this retry loop, I'd like to propose new logic that
removes do-while here.

The basic idea is "use winner's cycle instead of retrying."
Assuming that there are N threads trying to do cmpxchg, it also
be assumed that they are trying to update last_cycle by its own
new value while all values are almost same.
Therefore, it will work that treating threads as a group and
deciding a group's return value by picking up one from the group.

Fortunately, cmpxchg mechanism can help this logic. Only first
one in group can exchange the last_cycle successfully, so this
"winner" gets previous last_cycle as the return value of cmpxchg.
The rests in group will fail to exchange since last_cycle is
already updated by winner, so these "loser" gets current
last_cycle on cmpxchg's return. This means that all thread in
the group can know the winner's cycle.

  ret = cmpxchg(&last_cycle, last, new);
  if (ret = last)
    return new; /* you win! */
  else
    return ret; /* you lose. ret is winner's new */

I had a test running gettimeofday() processes at 1.5GHz*4way box.
It shows followings:

 - x1 process:
    0.15us / 1 gettimeofday() call
    0.15us / 1 gettimeofday() call with patch
 - x2 process:
    0.31us / 1 gettimeofday() call
    0.24us / 1 gettimeofday() call with patch
 - x3 process:
    1.59us / 1 gettimeofday() call
    1.11us / 1 gettimeofday() call with patch
 - x4 process:
    2.34us / 1 gettimeofday() call
    1.29us / 1 gettimeofday() call with patch

I know that this patch could not help quite huge system since
such system like having 1024CPUs should have better clocksource
instead of doing cmpxchg. Even though this patch will work good
on middle-sized box (4~8way, possibly 16~64way?).

Thanks,
H.Seto

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>

-----
 arch/ia64/kernel/fsys.S |   10 +++++++---
 kernel/timer.c          |   45 +++++++++++++++++++++++++--------------------
 2 files changed, 32 insertions(+), 23 deletions(-)

Index: linux-2.6.21/arch/ia64/kernel/fsys.S
=================================--- linux-2.6.21.orig/arch/ia64/kernel/fsys.S
+++ linux-2.6.21/arch/ia64/kernel/fsys.S
@@ -271,18 +271,22 @@
 (p6)	sub r10 = r25,r26	// time we got was less than last_cycle
 (p7)	mov ar.ccv = r25	// more than last_cycle. Prep for cmpxchg
 	;;
+(p7)	cmpxchg8.rel r3 = [r23],r2,ar.ccv
+	;;
+(p7)	cmp.ne p7,p0 = r25,r3	// if cmpxchg not successful, neighbor updated last_cycle.
+	;;
+(p7)	sub r10 = r3,r26	// use new last_cycle instead
+	;;
 	and r10 = r10,r14	// Apply mask
 	;;
 	setf.sig f8 = r10
 	nop.i 123
 	;;
-(p7)	cmpxchg8.rel r3 = [r23],r2,ar.ccv
 EX(.fail_efault, probe.w.fault r31, 3)	// This takes 5 cycles and we have spare time
 	xmpy.l f8 = f8,f7	// nsec_per_cyc*(counter-last_counter)
 (p15)	add r9 = r9,r17		// Add wall to monotonic.secs to result secs
 	;;
 (p15)	ld8 r17 = [r19],-IA64_TIMESPEC_TV_NSEC_OFFSET
-(p7)	cmp.ne p7,p0 = r25,r3	// if cmpxchg not successful redo
 	// simulate tbit.nz.or p7,p0 = r28,0
 	and r28 = ~1,r28	// Make sequence even to force retry if odd
 	getf.sig r2 = f8
@@ -295,7 +299,7 @@
 	;;		// overloaded 3 bundles!
 	// End critical section.
 	add r8 = r8,r2		// Add xtime.nsecs
-	cmp4.ne.or p7,p0 = r28,r10
+	cmp4.ne p7,p0 = r28,r10
 (p7)	br.cond.dpnt.few .time_redo	// sequence number changed ?
 	// Now r8=tv->tv_nsec and r9=tv->tv_sec
 	mov r10 = r0
Index: linux-2.6.21/kernel/timer.c
=================================--- linux-2.6.21.orig/kernel/timer.c
+++ linux-2.6.21/kernel/timer.c
@@ -1762,27 +1762,32 @@

 	if (time_interpolator->jitter)
 	{
-		cycles_t lcycle;
-		cycles_t now;
+		cycles_t lcycle, now, ret;
+
+		lcycle = time_interpolator->last_cycle;
+		now = time_interpolator_get_cycles(src);
+		if (lcycle && time_after(lcycle, now))
+			return lcycle;
+
+		/* When holding the xtime write lock, there's no need
+		 * to add the overhead of the cmpxchg.  Readers are
+		 * force to retry until the write lock is released.
+		 */
+		if (writelock) {
+			time_interpolator->last_cycle = now;
+			return now;
+		}
+
+		/*
+		 * Keep track of the last timer value returned.
+		 * In an SMP environment, you could lose out in contention of
+		 * cmpxchg. If so, your cmpxchg returns new value which the
+		 * winner of contention updated to. Use the new value instead.
+		 */
+		ret = cmpxchg(&time_interpolator->last_cycle, lcycle, now);
+		if (unlikely(ret != lcycle))
+			return ret;

-		do {
-			lcycle = time_interpolator->last_cycle;
-			now = time_interpolator_get_cycles(src);
-			if (lcycle && time_after(lcycle, now))
-				return lcycle;
-
-			/* When holding the xtime write lock, there's no need
-			 * to add the overhead of the cmpxchg.  Readers are
-			 * force to retry until the write lock is released.
-			 */
-			if (writelock) {
-				time_interpolator->last_cycle = now;
-				return now;
-			}
-			/* Keep track of the last timer value returned. The use of cmpxchg here
-			 * will cause contention in an SMP environment.
-			 */
-		} while (unlikely(cmpxchg(&time_interpolator->last_cycle, lcycle, now) != lcycle));
 		return now;
 	}
 	else
