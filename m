From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Thu, 14 Jun 2007 02:08:53 +0000
Subject: Re: [PATCH] ia64: Scalability improvement of gettimeofday with jitter
Message-Id: <4670A335.6020801@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <466E0FA4.2040405@jp.fujitsu.com> <20070613122019.GI11999@localhost>
In-Reply-To: <20070613122019.GI11999@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bob Picco <bob.picco@hp.com>
Cc: linux-ia64@vger.kernel.org, Linux Kernel list <linux-kernel@vger.kernel.org>

Bob Picco wrote:
> I will be pushing Peter Keilty's clocksource ia64 patches within the next
> week or so.  At that time I'll ask for inclusion into -mm. Please see:
> http://marc.info/?t7881585500001&r=1&w=2
> You'll notice that the time interpolator is removed.

I see. Your patch will replace the time interpolator to clocksource.
This is a conversion of structure which contains data related to time.
There will be no drastic change on logic, right?

What I want to do is removing the cmpxchg loop.
Your patch pointed it out that there are 2 loops in fsys.S, outer loop
with lock.seq and inner loop with cmpxchg.

If your patch successfully removes cmpxchg from generic code, then my
patch will be ia64 specific and be compact like following.

Thanks,
H.Seto

---
  arch/ia64/kernel/fsys.S |   18 ++++++++++--------
  1 files changed, 10 insertions(+), 8 deletions(-)

Index: linux-2.6.21/arch/ia64/kernel/fsys.S
=================================--- linux-2.6.21.orig/arch/ia64/kernel/fsys.S
+++ linux-2.6.21/arch/ia64/kernel/fsys.S
@@ -224,7 +224,7 @@
  	add r26 = IA64_CLKSRC_CYCLE_LAST_OFFSET,r20 // clksrc_cycle_last
  	cmp.ne p6, p0 = 0, r2	// Fallback if work is scheduled
  (p6)    br.cond.spnt.many fsys_fallback_syscall
-	;; // get lock.seq here new code, outer loop2!
+	;;
  .time_redo:
  	ld4.acq r28 = [r20]	// gtod_lock.sequence, Must be first in struct
  	ld8 r30 = [r21]		// clocksource->mmio_ptr
@@ -242,8 +242,7 @@
  	ld4 r23 = [r23]		// clocksource shift value
  	ld8 r24 = [r26]		// get clksrc_cycle_last value
  (p9)	cmp.eq p13,p0 = 0,r30	// if mmio_ptr, clear p13 jitter control
-	;; // old position for lock seq, new inner loop1!
-.cmpxchg_redo:
+	;;
  	.pred.rel.mutex p8,p9
  (p8)	mov r2 = ar.itc		// CPU_TIMER. 36 clocks latency!!!
  (p9)	ld8 r2 = [r30]		// readq(ti->address). Could also have latency issues..
@@ -261,20 +260,23 @@
  (p6)	sub r10 = r25,r24	// time we got was less than last_cycle
  (p7)	mov ar.ccv = r25	// more than last_cycle. Prep for cmpxchg
  	;;
+(p7)	cmpxchg8.rel r3 = [r19],r2,ar.ccv
+	;;
+(p7)	cmp.ne p7,p0 = r25,r3	// if cmpxchg not successful, neighbor updated last_cycle
+	;;
+(p7)	sub r10 = r3,r24	// use new last_cycle instead
+	;;
  	and r10 = r10,r14	// Apply mask
  	;;
  	setf.sig f8 = r10
  	nop.i 123
  	;;
-(p7)	cmpxchg8.rel r3 = [r19],r2,ar.ccv
  EX(.fail_efault, probe.w.fault r31, 3)	// This takes 5 cycles and we have spare time
  	xmpy.l f8 = f8,f7	// nsec_per_cyc*(counter-last_counter)
  (p15)	add r9 = r9,r17		// Add wall to monotonic.secs to result secs
  	;;
  	// End cmpxchg critical section loop1
  (p15)	ld8 r17 = [r22],-IA64_TIMESPEC_TV_NSEC_OFFSET
-(p7)	cmp.ne p7,p0 = r25,r3	// if cmpxchg not successful redo
-(p7)	br.cond.dpnt.few .cmpxchg_redo	// inner loop1
  	// simulate tbit.nz.or p7,p0 = r28,0
  	and r28 = ~1,r28	// Make sequence even to force retry if odd
  	getf.sig r2 = f8
@@ -286,8 +288,8 @@
  	;;		// overloaded 3 bundles!
  	// End critical section.
  	add r8 = r8,r2		// Add xtime.nsecs
-	cmp4.ne.or p7,p0 = r28,r10
-(p7)	br.cond.dpnt.few .time_redo	// sequence number changed, outer loop2
+	cmp4.ne p7,p0 = r28,r10
+(p7)	br.cond.dpnt.few .time_redo	// sequence number changed ?
  	// Now r8=tv->tv_nsec and r9=tv->tv_sec
  	mov r10 = r0
  	movl r2 = 1000000000

