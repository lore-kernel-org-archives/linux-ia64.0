From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 16 Jun 2004 19:15:09 +0000
Subject: [draft] gettimeofday scalability: Moving cmpxchg into itc_get_offset
Message-Id: <Pine.LNX.4.58.0406161200460.6118@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

The following patch against 2.6.7 moves the cmpxchg to itc_get_offset. By
doing that the scalability of gettimeofday increases dramatically if a
global clock (sn2, cyclone) is available. The patch removes all uses of
last_nsec_offset. It uses a static variable last_itc in itc_get_offset
instead to insure that the time obtained from ITC is monotonic. This
results in the timer code getting much simpler and having less overhead.

DRAFT! The patch currently removes the fast path
gettimeofday in IA64 assembly since it is designed to function like the
old gettimeofday C code. I will start to work on that but this may take
some time since this is my first encounter with IA64 assembly and the bazil=
lion of registers of that
CPU (anyone know how to do a 64 bit division in a simple way??).

However, the C code may be faster than the old assembly code for
platforms with global clocks since the new C routine does not use cmpxchg.
The old assembly routine used cmpxchg.

Any feedback appreciated.

I will be giving a talk at the LinuxTag 2004 in Karlsruhe at the end of
June and would be happy to meet any IA64 developers there.

%patch
Index: linux-2.6.6/arch/ia64/kernel/time.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.6.orig/arch/ia64/kernel/time.c	2004-0=
5-09 19:32:24.000000000 -0700
+++ linux-2.6.6/arch/ia64/kernel/time.c	2004-06-09 09:53:16.186815646 -0700
@@ -77,12 +77,30 @@
 unsigned long
 itc_get_offset (void)
 {
-	unsigned long elapsed_cycles, lost =3D jiffies - wall_jiffies;
-	unsigned long now =3D ia64_get_itc(), last_tick;
+	static unsigned long last_itc=3D0;
+	unsigned long elapsed_cycles, lost;
+	unsigned long now, last_tick;
+	unsigned long litc;

+	/* Determine ITC value that is >=3D than the last one used */
+	do {
+		litc=3Dlast_itc;
+		now =3D ia64_get_itc();
+
+		/* Make sure time does not run backwards */
+		if (last_itc && time_after(litc,now))
+		{
+			/* Time would be running backwards if we would use this ITC value.
+			 * Use the last ITC value instead.
+			 */
+			now=3Dlitc;
+			break;
+		}
+	} while (unlikely(cmpxchg(&last_itc,litc,now)!=3Dlitc));
+
+	lost =3D jiffies - wall_jiffies;
 	last_tick =3D (cpu_data(TIME_KEEPER_ID)->itm_next
 		     - (lost + 1)*cpu_data(TIME_KEEPER_ID)->itm_delta);
-
 	elapsed_cycles =3D now - last_tick;
 	return (elapsed_cycles*local_cpu_data->nsec_per_cyc) >> IA64_NSEC_PER_CYC=
_SHIFT;
 }
@@ -134,51 +152,14 @@
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

Index: linux-2.6.6/arch/ia64/kernel/fsys.S
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.6.orig/arch/ia64/kernel/fsys.S	2004-0=
5-09 19:33:22.000000000 -0700
+++ linux-2.6.6/arch/ia64/kernel/fsys.S	2004-06-09 11:55:38.429889766 -0700
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
@@ -676,7 +495,7 @@
 	data8 0				// setrlimit
 	data8 0				// getrlimit		// 1085
 	data8 0				// getrusage
-	data8 fsys_gettimeofday		// gettimeofday
+	data8 0 			// gettimeofday
 	data8 0				// settimeofday
 	data8 0				// select
 	data8 0				// poll			// 1090
Index: linux-2.6.6/include/linux/timex.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.6.orig/include/linux/timex.h	2004-05-=
09 19:31:59.000000000 -0700
+++ linux-2.6.6/include/linux/timex.h	2004-06-09 09:46:48.934867265 -0700
@@ -332,10 +332,6 @@
 	long drift;			/* drift in parts-per-million (or -1) */
 };

-extern volatile unsigned long last_nsec_offset;
-#ifndef __HAVE_ARCH_CMPXCHG
-extern spin_lock_t last_nsec_offset_lock;
-#endif
 extern struct time_interpolator *time_interpolator;

 extern void register_time_interpolator(struct time_interpolator *);
@@ -347,31 +343,6 @@
 {
 	struct time_interpolator *ti =3D time_interpolator;

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
-
 	if (ti)
 		(*ti->update)(delta_nsec);
 }
@@ -382,7 +353,6 @@
 {
 	struct time_interpolator *ti =3D time_interpolator;

-	last_nsec_offset =3D 0;
 	if (ti)
 		(*ti->reset)();
 }
@@ -394,7 +364,7 @@
 	struct time_interpolator *ti =3D time_interpolator;
 	if (ti)
 		return (*ti->get_offset)();
-	return last_nsec_offset;
+	return 0;
 }

 #else /* !CONFIG_TIME_INTERPOLATION */
Index: linux-2.6.6/kernel/timer.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.6.orig/kernel/timer.c	2004-06-09 09:4=
8:12.083303746 -0700
+++ linux-2.6.6/kernel/timer.c	2004-06-09 10:51:34.547124354 -0700
@@ -1391,10 +1391,6 @@
 }

 #ifdef CONFIG_TIME_INTERPOLATION
-volatile unsigned long last_nsec_offset;
-#ifndef __HAVE_ARCH_CMPXCHG
-spinlock_t last_nsec_offset_lock =3D SPIN_LOCK_UNLOCKED;
-#endif

 struct time_interpolator *time_interpolator;
 static struct time_interpolator *time_interpolator_list;

