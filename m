From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 17 Jun 2004 05:12:00 +0000
Subject: Re: [draft] gettimeofday scalability: Moving cmpxchg into itc_get_offset
Message-Id: <Pine.LNX.4.58.0406162202290.4575@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0406161200460.6118@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0406161200460.6118@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Ok. Here is a draft of how the interface could be changed followed by a
version of gettimeofday in C with all refs resolved as a blueprint for the
asm changes.

Sadly the cyclone clock requires a 32bit read operation. So I had to
develop a couple of types of clocks. This is getting to be more clock
related rather than interpolation.

I tried to avoid the division by adding up various shifts of the value to
be divided. This will not result in an accurate result but will
approximate it. Hope that is accurate enough.

Doing a fast system call for clock_gettime could be difficult since
kernel/posix-timer.c has its own interface for various clock related
functions. I do not like the current code though since it uses
gettimeofday with ms resolution for CLOCK_REALTIME and CLOCK_MONOTONIC.
Do you think its ok to simply handle that on our own for IA64 bypassing
the posix clock registration code?

Note that the following patch is just a preview. I have not tested this
yet.

%patch
Index: linux-2.6.7/arch/ia64/kernel/cyclone.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.7.orig/arch/ia64/kernel/cyclone.c	200=
4-06-15 22:19:22.000000000 -0700
+++ linux-2.6.7/arch/ia64/kernel/cyclone.c	2004-06-16 19:27:13.000000000 -0=
700
@@ -16,62 +16,9 @@
 	return 1;
 }

-static u32* volatile cyclone_timer;	/* Cyclone MPMC0 register */
-static u32 last_update_cyclone;
-
-static unsigned long offset_base;
-
-static unsigned long get_offset_cyclone(void)
-{
-	u32 now;
-	unsigned long offset;
-
-	/* Read the cyclone timer */
-	now =3D readl(cyclone_timer);
-	/* .. relative to previous update*/
-	offset =3D now - last_update_cyclone;
-
-	/* convert cyclone ticks to nanoseconds */
-	offset =3D (offset*NSEC_PER_SEC)/CYCLONE_TIMER_FREQ;
-
-	/* our adjusted time in nanoseconds */
-	return offset_base + offset;
-}
-
-static void update_cyclone(long delta_nsec)
-{
-	u32 now;
-	unsigned long offset;
-
-	/* Read the cyclone timer */
-	now =3D readl(cyclone_timer);
-	/* .. relative to previous update*/
-	offset =3D now - last_update_cyclone;
-
-	/* convert cyclone ticks to nanoseconds */
-	offset =3D (offset*NSEC_PER_SEC)/CYCLONE_TIMER_FREQ;
-
-	offset +=3D offset_base;
-
-	/* Be careful about signed/unsigned comparisons here: */
-	if (delta_nsec < 0 || (unsigned long) delta_nsec < offset)
-		offset_base =3D offset - delta_nsec;
-	else
-		offset_base =3D 0;
-
-	last_update_cyclone =3D now;
-}
-
-static void reset_cyclone(void)
-{
-	offset_base =3D 0;
-	last_update_cyclone =3D readl(cyclone_timer);
-}

 struct time_interpolator cyclone_interpolator =3D {
-	.get_offset =3D	get_offset_cyclone,
-	.update =3D	update_cyclone,
-	.reset =3D	reset_cyclone,
+	.source =3D TIME_SOURCE_MEM32,
 	.frequency =3D	CYCLONE_TIMER_FREQ,
 	.drift =3D	-100,
 };
@@ -82,6 +29,7 @@
 	u64 base;	/* saved cyclone base address */
 	u64 offset;	/* offset from pageaddr to cyclone_timer register */
 	int i;
+	u32* volatile cyclone_timer;	/* Cyclone MPMC0 register */

 	if (!use_cyclone)
 		return -ENODEV;
@@ -149,7 +97,7 @@
 		}
 	}
 	/* initialize last tick */
-	last_update_cyclone =3D readl(cyclone_timer);
+	cyclone_interpolator.addr=3Dcyclone_timer;
 	register_time_interpolator(&cyclone_interpolator);

 	return 0;
Index: linux-2.6.7/arch/ia64/kernel/fsys.S
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.7.orig/arch/ia64/kernel/fsys.S	2004-0=
6-15 22:20:26.000000000 -0700
+++ linux-2.6.7/arch/ia64/kernel/fsys.S	2004-06-16 18:39:10.000000000 -0700
@@ -143,186 +143,6 @@
 	FSYS_RETURN
 END(fsys_set_tid_address)

-/*
- * Note 1: This routine uses floating-point registers, but only with regis=
ters that
- *	   operate on integers.  Because of that, we don't need to set ar.fpsr =
to the
- *	   kernel default value.
- *
- * Note 2: For now, we will assume that all CPUs run at the same clock-fre=
quency.
- *	   If that wasn't the case, we would have to disable preemption (e.g.,
- *	   by disabling interrupts) between reading the ITC and reading
- *	   local_cpu_data->nsec_per_cyc.
- *
- * Note 3: On platforms where the ITC-drift bit is set in the SAL feature =
vector,
- *	   we ought to either skip the ITC-based interpolation or run an ntp-li=
ke
- *	   daemon to keep the ITCs from drifting too far apart.
- */
-
-ENTRY(fsys_gettimeofday)
-	.prologue
-	.altrp b6
-	.body
-	add r9=3DTI_FLAGS+IA64_TASK_SIZE,r16
-	addl r3=3DTHIS_CPU(cpu_info),r0
-
-	mov.m r31=3Dar.itc		// put time stamp into r31 (ITC) =3D now		(35 cyc)
-#ifdef CONFIG_SMP
-	movl r10=3D__per_cpu_offset
-	movl r2=3Dsal_platform_features
-	;;
-
-	ld8 r2=3D[r2]
-	movl r19=3Dxtime			// xtime is a timespec struct
-
-	ld8 r10=3D[r10]			// r10 <- __per_cpu_offset[0]
-	addl r21=3DTHIS_CPU(cpu_info),r0
-	;;
-	add r10=3Dr21, r10		// r10 <- &cpu_data(time_keeper_id)
-	tbit.nz p8,p0 =3D r2, IA64_SAL_PLATFORM_FEATURE_ITC_DRIFT_BIT
-(p8)	br.spnt.many fsys_fallback_syscall
-#else
-	;;
-	mov r10=3Dr3
-	movl r19=3Dxtime			// xtime is a timespec struct
-#endif
-	ld4 r9=3D[r9]
-	movl r17=3Dxtime_lock
-	;;
-
-	// r32, r33 should contain the 2 args of gettimeofday
-	adds r21=3DIA64_CPUINFO_ITM_NEXT_OFFSET, r10
-	mov r2=3D-1
-	tnat.nz p6,p7=3Dr32		// guard against NaT args
-	;;
-
-	adds r10=3DIA64_CPUINFO_ITM_DELTA_OFFSET, r10
-(p7)	tnat.nz p6,p0=3Dr33
-(p6)	br.cond.spnt.few .fail_einval
-
-	adds r8=3DIA64_CPUINFO_NSEC_PER_CYC_OFFSET, r3
-	movl r24#61183241434822607	// for division hack (only for / 1000)
-	;;
-
-	ldf8 f7=3D[r10]			// f7 now contains itm_delta
-	setf.sig f11=3Dr2
-	adds r10=3D8, r32
-
-	adds r20=3DIA64_TIMESPEC_TV_NSEC_OFFSET, r19	// r20 =3D &xtime->tv_nsec
-	movl r26=3Djiffies
-
-	setf.sig f9=3Dr24			// f9 is used for division hack
-	movl r27=3Dwall_jiffies
-
-	and r9=3DTIF_ALLWORK_MASK,r9
-	movl r25=3Dlast_nsec_offset
-	;;
-
-	/*
-	 * Verify that we have permission to write to struct timeval.  Note:
-	 * Another thread might unmap the mapping before we actually get
-	 * to store the result.  That's OK as long as the stores are also
-	 * protect by EX().
-	 */
-EX(.fail_efault, probe.w.fault r32, 3)		// this must come _after_ NaT-check
-EX(.fail_efault, probe.w.fault r10, 3)		// this must come _after_ NaT-check
-	nop 0
-
-	ldf8 f10=3D[r8]			// f10 <- local_cpu_data->nsec_per_cyc value
-	cmp.ne p8, p0=3D0, r9
-(p8)	br.spnt.many fsys_fallback_syscall
-	;;
-.retry:	// *** seq =3D read_seqbegin(&xtime_lock); ***
-	ld4.acq r23=3D[r17]		// since &xtime_lock =3D &xtime_lock->sequence
-	ld8 r14=3D[r25]			// r14 (old) =3D last_nsec_offset
-
-	ld8 r28=3D[r26]			// r28 =3D jiffies
-	ld8 r29=3D[r27]			// r29 =3D wall_jiffies
-	;;
-
-	ldf8 f8=3D[r21]			// f8 now contains itm_next
-	sub r28=3Dr29, r28, 1		// r28 now contains "-(lost + 1)"
-	tbit.nz p9, p10=3Dr23, 0		// p9 <- is_odd(r23), p10 <- is_even(r23)
-	;;
-
-	ld8 r2=3D[r19]			// r2 =3D sec =3D xtime.tv_sec
-	ld8 r29=3D[r20]			// r29 =3D nsec =3D xtime.tv_nsec
-
-	setf.sig f6=3Dr28			// f6 <- -(lost + 1)				(6 cyc)
-	;;
-
-	mf
-	xma.l f8=F6, f7, f8	// f8 (last_tick) <- -(lost + 1)*itm_delta + itm_next=
	(5 cyc)
-	nop 0
-
-	setf.sig f12=3Dr31		// f12 <- ITC					(6 cyc)
-	// *** if (unlikely(read_seqretry(&xtime_lock, seq))) continue; ***
-	ld4 r24=3D[r17]			// r24 =3D xtime_lock->sequence (re-read)
-	nop 0
-	;;
-
-	mov r31=3Dar.itc			// re-read ITC in case we .retry		(35 cyc)
-	xma.l f8=F11, f8, f12	// f8 (elapsed_cycles) <- (-1*last_tick + now) =3D =
(now - last_tick)
-	nop 0
-	;;
-
-	getf.sig r18=F8			// r18 <- (now - last_tick)
-	xmpy.l f8=F8, f10		// f8 <- elapsed_cycles*nsec_per_cyc (5 cyc)
-	add r3=3Dr29, r14			// r3 =3D (nsec + old)
-	;;
-
-	cmp.lt p7, p8=3Dr18, r0		// if now < last_tick, set p7 =3D 1, p8 =3D 0
-	getf.sig r18=F8			// r18 =3D elapsed_cycles*nsec_per_cyc		(6 cyc)
-	nop 0
-	;;
-
-(p10)	cmp.ne p9, p0=3Dr23, r24		// if xtime_lock->sequence !=3D seq, set p9
-	shr.u r18=3Dr18, IA64_NSEC_PER_CYC_SHIFT	// r18 <- offset
-(p9)	br.spnt.many .retry
-	;;
-
-	mov ar.ccv=3Dr14			// ar.ccv =3D old					(1 cyc)
-	cmp.leu p7, p8=3Dr18, r14		// if (offset <=3D old), set p7 =3D 1, p8 =3D 0
-	;;
-
-(p8)	cmpxchg8.rel r24=3D[r25], r18, ar.ccv	// compare-and-exchange (atomic=
!)
-(p8)	add r3=3Dr29, r18			// r3 =3D (nsec + offset)
-	;;
-	shr.u r3=3Dr3, 3			// initiate dividing r3 by 1000
-	;;
-	setf.sig f8=3Dr3			//						(6 cyc)
-	mov r10=1000000			// r10 =3D 1000000
-	;;
-(p8)	cmp.ne.unc p9, p0=3Dr24, r14
-	xmpy.hu f6=F8, f9		//						(5 cyc)
-(p9)	br.spnt.many .retry
-	;;
-
-	getf.sig r3=F6			//						(6 cyc)
-	;;
-	shr.u r3=3Dr3, 4			// end of division, r3 is divided by 1000 (=3Dusec)
-	;;
-
-1:	cmp.geu p7, p0=3Dr3, r10		// while (usec >=3D 1000000)
-	;;
-(p7)	sub r3=3Dr3, r10			// usec -=3D 1000000
-(p7)	adds r2=3D1, r2			// ++sec
-(p7)	br.spnt.many 1b
-
-	// finally: r2 =3D sec, r3 =3D usec
-EX(.fail_efault, st8 [r32]=3Dr2)
-	adds r9=3D8, r32
-	mov r8=3Dr0			// success
-	;;
-EX(.fail_efault, st8 [r9]=3Dr3)		// store them in the timeval struct
-	mov r10=3D0
-	FSYS_RETURN
-	/*
-	 * Note: We are NOT clearing the scratch registers here.  Since the only =
things
-	 *	 in those registers are time-related variables and some addresses (whi=
ch
-	 *	 can be obtained from System.map), none of this should be security-sen=
sitive
-	 *	 and we should be fine.
-	 */
-
 .fail_einval:
 	mov r8=3DEINVAL			// r8 =3D EINVAL
 	mov r10=3D-1			// r10 =3D -1
@@ -332,7 +152,6 @@
 	mov r8=EFAULT			// r8 =3D EFAULT
 	mov r10=3D-1			// r10 =3D -1
 	FSYS_RETURN
-END(fsys_gettimeofday)

 /*
  * long fsys_rt_sigprocmask (int how, sigset_t *set, sigset_t *oset, size_=
t sigsetsize).
@@ -672,7 +491,7 @@
 	data8 0				// setrlimit
 	data8 0				// getrlimit		// 1085
 	data8 0				// getrusage
-	data8 fsys_gettimeofday		// gettimeofday
+	data8 0 			// gettimeofday
 	data8 0				// settimeofday
 	data8 0				// select
 	data8 0				// poll			// 1090
Index: linux-2.6.7/arch/ia64/kernel/time.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.7.orig/arch/ia64/kernel/time.c	2004-0=
6-15 22:19:01.000000000 -0700
+++ linux-2.6.7/arch/ia64/kernel/time.c	2004-06-16 20:06:41.000000000 -0700
@@ -45,46 +45,44 @@

 #endif

-static void
-itc_reset (void)
-{
-}
-
+#ifdef SMP
 /*
- * Adjust for the fact that xtime has been advanced by delta_nsec (may be =
negative and/or
- * larger than NSEC_PER_SEC.
+ * Return the value of the CPU ITC timer making sure
+ * that time never runs backward. ITCs may not be fully synchronized
+ * on SMP systems which may result in time seemingly running backward.
  */
-static void
-itc_update (long delta_nsec)
+unsigned long get_itc_counter(void)
 {
+	static unsigned long last_itc=3D0;
+	unsigned long litc;
+
+	/* Determine ITC value that is >=3D than the last one used */
+	do {
+		litc=3Dlast_itc;
+		now =3D ia64_get_itc();
+
+		/* Make sure time does not run backwards */
+		if (litc && time_after(litc,now))
+		{
+			/* Time would be running backwards if we would use this ITC value.
+			 * Use the last ITC value instead.
+			 */
+			now=3Dlitc;
+			break;
+		}
+	} while (unlikely(cmpxchg(&last_itc,litc,now)!=3Dlitc));
+
+	return now;
 }

-/*
- * Return the number of nano-seconds that elapsed since the last
- * update to jiffy.  It is quite possible that the timer interrupt
- * will interrupt this and result in a race for any of jiffies,
- * wall_jiffies or itm_next.  Thus, the xtime_lock must be at least
- * read synchronised when calling this routine (see do_gettimeofday()
- * below for an example).
- */
-unsigned long
-itc_get_offset (void)
+#else
+unsigned long get_itc_counter(void)
 {
-	unsigned long elapsed_cycles, lost =3D jiffies - wall_jiffies;
-	unsigned long now =3D ia64_get_itc(), last_tick;
-
-	last_tick =3D (cpu_data(TIME_KEEPER_ID)->itm_next
-		     - (lost + 1)*cpu_data(TIME_KEEPER_ID)->itm_delta);
-
-	elapsed_cycles =3D now - last_tick;
-	return (elapsed_cycles*local_cpu_data->nsec_per_cyc) >> IA64_NSEC_PER_CYC=
_SHIFT;
+	return ia64_get_itc();
 }
+#endif

-static struct time_interpolator itc_interpolator =3D {
-	.get_offset =3D	itc_get_offset,
-	.update =3D	itc_update,
-	.reset =3D	itc_reset
-};
+static struct time_interpolator itc_interpolator;

 int
 do_settimeofday (struct timespec *tv)
@@ -127,51 +125,14 @@
 void
 do_gettimeofday (struct timeval *tv)
 {
-	unsigned long seq, nsec, usec, sec, old, offset;
+	unsigned long seq, nsec, usec, sec, offset;

-	while (1) {
+	do {
 		seq =3D read_seqbegin(&xtime_lock);
-		{
-			old =3D last_nsec_offset;
-			offset =3D time_interpolator_get_offset();
-			sec =3D xtime.tv_sec;
-			nsec =3D xtime.tv_nsec;
-		}
-		if (unlikely(read_seqretry(&xtime_lock, seq)))
-			continue;
-		/*
-		 * Ensure that for any pair of causally ordered gettimeofday() calls, ti=
me
-		 * never goes backwards (even when ITC on different CPUs are not perfect=
ly
-		 * synchronized).  (A pair of concurrent calls to gettimeofday() is by
-		 * definition non-causal and hence it makes no sense to talk about
-		 * time-continuity for such calls.)
-		 *
-		 * Doing this in a lock-free and race-free manner is tricky.  Here is why
-		 * it works (most of the time): read_seqretry() just succeeded, which
-		 * implies we calculated a consistent (valid) value for "offset".  If the
-		 * cmpxchg() below succeeds, we further know that last_nsec_offset still
-		 * has the same value as at the beginning of the loop, so there was
-		 * presumably no timer-tick or other updates to last_nsec_offset in the
-		 * meantime.  This isn't 100% true though: there _is_ a possibility of a
-		 * timer-tick occurring right right after read_seqretry() and then getti=
ng
-		 * zero or more other readers which will set last_nsec_offset to the same
-		 * value as the one we read at the beginning of the loop.  If this
-		 * happens, we'll end up returning a slightly newer time than we ought to
-		 * (the jump forward is at most "offset" nano-seconds).  There is no
-		 * danger of causing time to go backwards, though, so we are safe in that
-		 * sense.  We could make the probability of this unlucky case occurring
-		 * arbitrarily small by encoding a version number in last_nsec_offset, b=
ut
-		 * even without versioning, the probability of this unlucky case should =
be
-		 * so small that we won't worry about it.
-		 */
-		if (offset <=3D old) {
-			offset =3D old;
-			break;
-		} else if (likely(cmpxchg(&last_nsec_offset, old, offset) =3D old))
-			break;
-
-		/* someone else beat us to updating last_nsec_offset; try again */
-	}
+		offset =3D time_interpolator_get_offset();
+		sec =3D xtime.tv_sec;
+		nsec =3D xtime.tv_nsec;
+	} while (unlikely(read_seqretry(&xtime_lock, seq)));

 	usec =3D (nsec + offset) / 1000;

@@ -386,6 +347,8 @@
 	if (!(sal_platform_features & IA64_SAL_PLATFORM_FEATURE_ITC_DRIFT)) {
 		itc_interpolator.frequency =3D local_cpu_data->itc_freq;
 		itc_interpolator.drift =3D itc_drift;
+		itc_interpolator.source=3D TIME_SOURCE_FUNCTION;
+		itc_interpolator.addr =3D get_itc_counter;
 		register_time_interpolator(&itc_interpolator);
 	}

Index: linux-2.6.7/arch/ia64/sn/kernel/sn2/timer.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.7.orig/arch/ia64/sn/kernel/sn2/timer.=
c	2004-06-16 18:01:13.000000000 -0700
+++ linux-2.6.7/arch/ia64/sn/kernel/sn2/timer.c	2004-06-16 20:05:14.0000000=
00 -0700
@@ -20,57 +20,15 @@


 extern unsigned long sn_rtc_cycles_per_second;
-static volatile unsigned long last_wall_rtc;

-static unsigned long rtc_offset;	/* updated only when xtime write-lock is =
held! */
-static long rtc_nsecs_per_cycle;
-static long rtc_per_timer_tick;
-
-static unsigned long
-getoffset(void)
-{
-	return rtc_offset + (GET_RTC_COUNTER() - last_wall_rtc)*rtc_nsecs_per_cyc=
le;
-}
-
-
-static void
-update(long delta_nsec)
-{
-	unsigned long rtc_counter =3D GET_RTC_COUNTER();
-	unsigned long offset =3D rtc_offset + (rtc_counter - last_wall_rtc)*rtc_n=
secs_per_cycle;
-
-	/* Be careful about signed/unsigned comparisons here: */
-	if (delta_nsec < 0 || (unsigned long) delta_nsec < offset)
-		rtc_offset =3D offset - delta_nsec;
-	else
-		rtc_offset =3D 0;
-	last_wall_rtc =3D rtc_counter;
-}
-
-
-static void
-reset(void)
-{
-	rtc_offset =3D 0;
-	last_wall_rtc =3D GET_RTC_COUNTER();
-}
-
-
-static struct time_interpolator sn2_interpolator =3D {
-	.get_offset =3D	getoffset,
-	.update =3D	update,
-	.reset =3D	reset
-};
+static struct time_interpolator sn2_interpolator;

 void __init
 sn_timer_init(void)
 {
 	sn2_interpolator.frequency =3D sn_rtc_cycles_per_second;
 	sn2_interpolator.drift =3D -1;	/* unknown */
+	sn2_interpolator.addr=3DRTC_COUNTER_ADDR;
+	sn2_interpolator.source=3DTIME_SOURCE_MEM64;
 	register_time_interpolator(&sn2_interpolator);
-
-	rtc_per_timer_tick =3D sn_rtc_cycles_per_second / HZ;
-	rtc_nsecs_per_cycle =3D 1000000000 / sn_rtc_cycles_per_second;
-
-	last_wall_rtc =3D GET_RTC_COUNTER();
 }
Index: linux-2.6.7/include/linux/timex.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.7.orig/include/linux/timex.h	2004-06-=
15 22:18:56.000000000 -0700
+++ linux-2.6.7/include/linux/timex.h	2004-06-16 22:02:01.000000000 -0700
@@ -320,82 +320,61 @@

 #ifdef CONFIG_TIME_INTERPOLATION

-struct time_interpolator {
-	/* cache-hot stuff first: */
-	unsigned long (*get_offset) (void);
-	void (*update) (long);
-	void (*reset) (void);
+/* Offset in nanoseconds to add to the hardware clock */
+extern unsigned long hwclock_offset;
+
+/* Value read from the counter at the last tick */
+extern unsigned long hwclock_last_tick;

-	/* cache-cold stuff follows here: */
+struct time_interpolator {
+	/* counter_addr is either a pointer to a memory mapped
+	 * global clock or NULL which means use a CPU counter register
+	 * retrived via do_hwclock_get_counter (which may be an inline)
+	 */
+	void *addr;
+	unsigned source;
+	unsigned nanoseconds_per_tick;
 	struct time_interpolator *next;
 	unsigned long frequency;	/* frequency in counts/second */
 	long drift;			/* drift in parts-per-million (or -1) */
 };

-extern volatile unsigned long last_nsec_offset;
-#ifndef __HAVE_ARCH_CMPXCHG
-extern spin_lock_t last_nsec_offset_lock;
-#endif
+#define TIME_SOURCE_CPU 0
+#define TIME_SOURCE_MEM64 1
+#define TIME_SOURCE_MEM32 2
+#define TIME_SOURCE_FUNCTION 3
+
+/* This needs to really be defined in asm-xxx */
+#define CPU_TIMER ia64_getreg(_IA64_REG_AR_ITC)
+
 extern struct time_interpolator *time_interpolator;

 extern void register_time_interpolator(struct time_interpolator *);
 extern void unregister_time_interpolator(struct time_interpolator *);

-/* Called with xtime WRITE-lock acquired.  */
-static inline void
-time_interpolator_update(long delta_nsec)
-{
-	struct time_interpolator *ti =3D time_interpolator;
+extern unsigned long do_hwclock_get_counter(void);

-	if (last_nsec_offset > 0) {
-#ifdef __HAVE_ARCH_CMPXCHG
-		unsigned long new, old;
-
-		do {
-			old =3D last_nsec_offset;
-			if (old > delta_nsec)
-				new =3D old - delta_nsec;
-			else
-				new =3D 0;
-		} while (cmpxchg(&last_nsec_offset, old, new) !=3D old);
-#else
-		/*
-		 * This really hurts, because it serializes gettimeofday(), but without =
an
-		 * atomic single-word compare-and-exchange, there isn't all that much el=
se
-		 * we can do.
-		 */
-		spin_lock(&last_nsec_offset_lock);
-		{
-			last_nsec_offset -=3D min(last_nsec_offset, delta_nsec);
-		}
-		spin_unlock(&last_nsec_offset_lock);
-#endif
-	}
+static inline unsigned long
+hwclock_get_counter(void)
+{
+	unsigned long (*x)(void);

-	if (ti)
-		(*ti->update)(delta_nsec);
-}
+	switch (time_interpolator->source)
+	{
+		case TIME_SOURCE_CPU: return CPU_TIMER;

-/* Called with xtime WRITE-lock acquired.  */
-static inline void
-time_interpolator_reset(void)
-{
-	struct time_interpolator *ti =3D time_interpolator;
+		case TIME_SOURCE_FUNCTION:
+			x=3Dtime_interpolator->addr;
+			return x();

-	last_nsec_offset =3D 0;
-	if (ti)
-		(*ti->reset)();
+		case TIME_SOURCE_MEM64	: return *((u64 *)time_interpolator->addr);
+		case TIME_SOURCE_MEM32	: return *((u32 *)time_interpolator->addr);
+	}
 }

-/* Called with xtime READ-lock acquired.  */
-static inline unsigned long
-time_interpolator_get_offset(void)
-{
-	struct time_interpolator *ti =3D time_interpolator;
-	if (ti)
-		return (*ti->get_offset)();
-	return last_nsec_offset;
-}
+#define time_interpolator_update(x) { hwclock_offset +=3D (x); }
+#define time_interpolator_reset() { hwclock_offset=3Dhwclock_get_counter()=
; }
+#define time_interpolator_get_offset() ((hwclock_get_counter()-hwclock_las=
t_tick)*time_interpolator->nanoseconds_per_tick)

 #else /* !CONFIG_TIME_INTERPOLATION */

Index: linux-2.6.7/kernel/timer.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.7.orig/kernel/timer.c	2004-06-15 22:1=
9:52.000000000 -0700
+++ linux-2.6.7/kernel/timer.c	2004-06-16 18:43:25.000000000 -0700
@@ -1426,14 +1426,13 @@
 }

 #ifdef CONFIG_TIME_INTERPOLATION
-volatile unsigned long last_nsec_offset;
-#ifndef __HAVE_ARCH_CMPXCHG
-spinlock_t last_nsec_offset_lock =3D SPIN_LOCK_UNLOCKED;
-#endif

 struct time_interpolator *time_interpolator;
 static struct time_interpolator *time_interpolator_list;
 static spinlock_t time_interpolator_lock =3D SPIN_LOCK_UNLOCKED;
+unsigned long hwclock_offset;
+unsigned long hwclock_last_tick;
+

 static inline int
 is_better_time_interpolator(struct time_interpolator *new)
@@ -1447,6 +1446,7 @@
 void
 register_time_interpolator(struct time_interpolator *ti)
 {
+	ti->nanoseconds_per_tick=3DNSEC_PER_SEC/ti->frequency;
 	spin_lock(&time_interpolator_lock);
 	write_seqlock_irq(&xtime_lock);
 	if (is_better_time_interpolator(ti))



--- C gettimeofday function

void
do_gettimeofday (struct timeval *tv)
{
        unsigned long seq, nsec, usec, sec, offset;

        do {
                seq =3D read_seqbegin(&xtime_lock);
                offset =3D time_interpolator_get_offset();
                sec =3D xtime.tv_sec;
                nsec =3D xtime.tv_nsec;
        } while (unlikely(read_seqretry(&xtime_lock, seq)));

        usec =3D (nsec + offset) / 1000;

        while (unlikely(usec >=3D USEC_PER_SEC)) {
                usec -=3D USEC_PER_SEC;
                ++sec;
        }

        tv->tv_sec =3D sec;
        tv->tv_usec =3D usec;
}

--- gettimeofday expanded to avoid any function calls as a blueprint for
asm:


#define USEC_PER_SEC (1000000L)
extern unsigned long last_itc;

extern struct time_interpolator
{
	void *addr;
	unsigned source;
	unsigned nanoseconds_per_tick;
} *time_interpolator;

struct timeval {
        long tv_sec;         /* seconds */
        long tv_usec;        /* microseconds */
};

void
sys_gettimeofday (struct timeval *tv)
{
        unsigned long seq, nsec, usec, sec, offset,counter,litc;

        do {
                seq =3D xtime_lock->sequence;
        	ia64_mf();		//.Do we really need this? If seq is crap then we will=
 find out after the next ia64_mf.

	        switch (time_interpolator->source)
		{
			case TIME_SOURCE_MEM64; counter=3D*(u64 *)time_interpolator->addr;
			case TIME_SOURCE_MEM32: counter=3D*(u32 *)time_interpolator->addr;
			case TIME_SOURCE_CPU: counter=3Dia64_get_itc();
			default: fall back to full function call.
		}

		offset=3D((counter-hwclock_last_tick)*time_interpolator->nanoseconds_per_=
tick);

                sec =3D xtime.tv_sec;
                nsec =3D xtime.tv_nsec;
		ia64_mf();
        } while (unlikely((seq & 1) | (xtime_lock->sequence ^ seq)));

	/* avoid division by using shifts.
	 * 1/(2^10) + 1/2^16 + 1/(2^17) + 1/(2^21) + 1/(2^24) +1/(2^27) + 1/(2^28)
	 * =3D0.00099999830126762389 0.000169% error off by 1600ns per sec.
	 * which is probably accurate enough. But this may still be too complicated
	 * approximate by
	 * 1/(2^10) + 1/2^16 + 1/(2^17) =3D.00099945068359375000 (0.05% error off =
by 5ns in 10ms intervals)
	 * or simply
	 * 1/(2^10) + 1/2^15 =3D .00100708007812500000 (8.1% error off by 810ns in=
 10ms interval)
	 */

	counter=3Dnsec + offset;

	usec=3Dcounter>>10+counter>>16+counter>>17+counter>>21+counter>>24+counter=
>>27+counter>>28;

        while (unlikely(usec >=3D USEC_PER_SEC)) {
                usec -=3D USEC_PER_SEC;
                ++sec;
        }

        tv->tv_sec =3D sec;
        tv->tv_usec =3D usec;
}

