From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Wed, 18 Jul 2007 15:13:40 +0000
Subject: [PATCH 3/3] fix ia64 clocksource : remove cmpxchg loop in gettimeofday
Message-Id: <469E2E24.7030409@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This is 3 of 3 patches for ia64 clocksource.

I have an unfinished business.

Please refer:
> [PATCH] ia64: Scalability improvement of gettimeofday with jitter compensation
> http://lkml.org/lkml/2007/6/11/402

So this is repost of above patch, rebased on clocksource code.

One additional change is:

  - remove "when holding the xtime write lock..." section in
    itc_get_cycles(). Since it allows itc_lastcycle to go past.

Following results show that:

> # separatejitter : default
> CPU  0:  1.50 (usecs) (0 errors / 6677159 iterations)
> CPU  1:  1.49 (usecs) (0 errors / 6697159 iterations)
> CPU  2:  1.50 (usecs) (0 errors / 6664672 iterations)
> CPU  3:  1.50 (usecs) (0 errors / 6668999 iterations)
> # separatejitter : nojitter
> CPU  0:  0.14 (usecs) (0 errors / 70580221 iterations)
> CPU  1:  0.14 (usecs) (0 errors / 71275618 iterations)
> CPU  2:  0.14 (usecs) (0 errors / 70626121 iterations)
> CPU  3:  0.14 (usecs) (0 errors / 70603364 iterations)
> # separatejitter : nolwsys
> CPU  0:  2.26 (usecs) (0 errors / 4417197 iterations)
> CPU  1:  2.26 (usecs) (0 errors / 4415829 iterations)
> CPU  2:  2.27 (usecs) (0 errors / 4402768 iterations)
> CPU  3:  2.27 (usecs) (0 errors / 4406101 iterations)

the scalability of gettimeofday is clearly improved.

> # clocksource (fixed) : default
> CPU  0:  1.33 (usecs) (0 errors / 7507837 iterations)
> CPU  1:  1.31 (usecs) (0 errors / 7621659 iterations)
> CPU  2:  1.27 (usecs) (0 errors / 7865412 iterations)
> CPU  3:  1.27 (usecs) (0 errors / 7863362 iterations)
> # clocksource (fixed) : nojitter
> CPU  0:  0.14 (usecs) (0 errors / 69608888 iterations)
> CPU  1:  0.14 (usecs) (0 errors / 70277433 iterations)
> CPU  2:  0.14 (usecs) (0 errors / 69632925 iterations)
> CPU  3:  0.14 (usecs) (0 errors / 69606531 iterations)
> # clocksource (fixed) : nolwsys
> CPU  0:  1.48 (usecs) (0 errors / 6770870 iterations)
> CPU  1:  1.48 (usecs) (0 errors / 6777897 iterations)
> CPU  2:  1.49 (usecs) (0 errors / 6728101 iterations)
> CPU  3:  1.49 (usecs) (0 errors / 6703961 iterations)

Thanks,
H.Seto

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
-----

 arch/ia64/kernel/fsys.S |   22 ++++++++++++----------
 arch/ia64/kernel/time.c |   39 +++++++++++++++++----------------------
 2 files changed, 29 insertions(+), 32 deletions(-)

Index: linux-2.6.22/arch/ia64/kernel/fsys.S
=================================--- linux-2.6.22.orig/arch/ia64/kernel/fsys.S
+++ linux-2.6.22/arch/ia64/kernel/fsys.S
@@ -231,7 +231,8 @@
 	add r26 = IA64_CLKSRC_CYCLE_LAST_OFFSET,r20 // clksrc_cycle_last
 	cmp.ne p6, p0 = 0, r2	// Fallback if work is scheduled
 (p6)    br.cond.spnt.many fsys_fallback_syscall
-	;; // get lock.seq here new code, outer loop2!
+	;;
+	// Begin critical section
 .time_redo:
 	ld4.acq r28 = [r20]	// gtod_lock.sequence, Must take first
 	;;
@@ -252,8 +253,7 @@
 	ld4 r23 = [r23]		// clocksource shift value
 	ld8 r24 = [r26]		// get clksrc_cycle_last value
 (p9)	cmp.eq p13,p0 = 0,r30	// if mmio_ptr, clear p13 jitter control
-	;; // old position for lock seq, new inner loop1!
-.cmpxchg_redo:
+	;;
 	.pred.rel.mutex p8,p9
 (p8)	mov r2 = ar.itc		// CPU_TIMER. 36 clocks latency!!!
 (p9)	ld8 r2 = [r30]		// MMIO_TIMER. Could also have latency issues..
@@ -270,19 +270,21 @@
 (p6)	sub r10 = r25,r24	// time we got was less than last_cycle
 (p7)	mov ar.ccv = r25	// more than last_cycle. Prep for cmpxchg
 	;;
+(p7)	cmpxchg8.rel r3 = [r19],r2,ar.ccv
+	;;
+(p7)	cmp.ne p7,p0 = r25,r3	// if cmpxchg not successful
+	;;
+(p7)	sub r10 = r3,r24	// then use new last_cycle instead
+	;;
 	and r10 = r10,r14	// Apply mask
 	;;
 	setf.sig f8 = r10
 	nop.i 123
 	;;
-(p7)	cmpxchg8.rel r3 = [r19],r2,ar.ccv
 	// fault check takes 5 cycles and we have spare time
 EX(.fail_efault, probe.w.fault r31, 3)
 	xmpy.l f8 = f8,f7	// nsec_per_cyc*(counter-last_counter)
 	;;
-	// End cmpxchg critical section loop1
-(p7)	cmp.ne p7,p0 = r25,r3	// if cmpxchg not successful redo
-(p7)	br.cond.dpnt.few .cmpxchg_redo	// inner loop1
 	// ? simulate tbit.nz.or p7,p0 = r28,0
 	getf.sig r2 = f8
 	mf
@@ -290,10 +292,10 @@
 	ld4 r10 = [r20]		// gtod_lock.sequence
 	shr.u r2 = r2,r23	// shift by factor
 	;;		// ? overloaded 3 bundles!
-	// End critical section.
 	add r8 = r8,r2		// Add xtime.nsecs
-	cmp4.ne.or p7,p0 = r28,r10
-(p7)	br.cond.dpnt.few .time_redo	// sequence number changed, outer loop2
+	cmp4.ne p7,p0 = r28,r10
+(p7)	br.cond.dpnt.few .time_redo	// sequence number changed, redo
+	// End critical section.
 	// Now r8=tv->tv_nsec and r9=tv->tv_sec
 	mov r10 = r0
 	movl r2 = 1000000000
Index: linux-2.6.22/arch/ia64/kernel/time.c
=================================--- linux-2.6.22.orig/arch/ia64/kernel/time.c
+++ linux-2.6.22/arch/ia64/kernel/time.c
@@ -257,31 +257,26 @@

 static cycle_t itc_get_cycles()
 {
-	u64 lcycle;
-	u64 now;
+	u64 lcycle, now, ret;

 	if (!itc_jitter_data.itc_jitter)
 		return get_cycles();
-	do {
-		lcycle = itc_jitter_data.itc_lastcycle;
-		now = get_cycles();
-		if (lcycle && time_after(lcycle, now))
-			return lcycle;
-
-		/* When holding the xtime write lock, there's no need
-		 * to add the overhead of the cmpxchg.  Readers are
-		 * force to retry until the write lock is released.
-		 */
-		if (spin_is_locked(&xtime_lock.lock)) {
-			itc_jitter_data.itc_lastcycle = now;
-			return now;
-		}
-		/* Keep track of the last timer value returned.
-		 * The use of cmpxchg here will cause contention in
-		 * an SMP environment.
-		 */
-	} while (likely(cmpxchg(&itc_jitter_data.itc_lastcycle,
-				lcycle, now) != lcycle));
+
+	lcycle = itc_jitter_data.itc_lastcycle;
+	now = get_cycles();
+	if (lcycle && time_after(lcycle, now))
+		return lcycle;
+
+	/*
+	 * Keep track of the last timer value returned.
+	 * In an SMP environment, you could lose out in contention of
+	 * cmpxchg. If so, your cmpxchg returns new value which the
+	 * winner of contention updated to. Use the new value instead.
+	 */
+	ret = cmpxchg(&itc_jitter_data.itc_lastcycle, lcycle, now);
+	if (unlikely(ret != lcycle))
+		return ret;
+
 	return now;
 }


