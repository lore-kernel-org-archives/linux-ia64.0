From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 16 Jul 2004 18:24:08 +0000
Subject: final [hopefully] timer patches
Message-Id: <Pine.LNX.4.58.0407161057440.29976@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

I tested the patches on an ITC based system (HP RX2600) and it worked
fine. Interpolator accuracy with the old settings was just 100us (900Mhz
clock leads the interpolator to use 1 ns per tick after division and
therefore a 10% deviation from normal time!) and the clock jumped forward
100-200us in each tick. Finetuned that to a few hundred nsecs by scaling
the division. The only other changes from the last version are an update
of the comments hopefully now giving a clearer explanation of how the
interpolator works and an update of the debugging patch to allow tracing
of interpolator operations.

John: We do not have an IBM system with a cyclone timer here. Could you
test this with a cyclone timer? The interpolator shift may have to
be adjusted (See arch/ia64/cyclone.c). I set that to 32 to be as accurate
as possible but it may be  better to reduce the scaling depending on the
accuracy of the cyclone clock.

Note that the code will never allow time to go backward. This works
because the interpolator clock runs slightly slower than the standard
clock.  Corrections are obtained by either letting the interpolator clock
run (thereby gradually loosing nsecs) or by making time jump forward. The
shift factor allows a minimizing of that jump forward. It is possible to
obtain an accuracy <50ns with the patches (SGI systems have that accuracy
and ITC based systems can be tuned for it).

The patches make the following changes:

[timer_interpolator.patch]
- Simplify interpolator logic.
- Revise fastcall gettimeofday (~30% performance increase)
- Make fastcall work for all clock sources and not only for ITC based
clocking.
- Add fastcall for clock_gettime(REALTIME) (>50% performance increase)
  (the fastcall also returns nanoseconds instead of usecs*1000)
- Scalability improvements since no cmpxchg is used anymore. For
applications that continually "live" in gettimeofday on an SMP system this
will be a dramatic improvement.
- Ability to tune the accuracy of the interpolator. Its possible now to
reach an accuracy less than 100ns and to limit the time jumps forward.
- Generic interface. An interpolator can be easily setup by simply
  setting up a time_interpolator structure with the correct values.
  No coding of special functions needed.

[nanoseconds.patch]
- make clock_gettime REALTIME and CLOCK_MONOTONIC return nanosecond values
on all platforms. The current routine returns usecs*1000.
- in kernel interface getnstimeofday for access to a system clock with
nanosecond precision

[time_interpolator_debug.patch]
- Trace execution of interpolator by setting ti_debug

Signed-off-by: Christoph Lameter <clameter@sgi.com>

=3D=3D TIME INTERPOLATOR PATCH
%patch
Index: linux-2.6.7/arch/ia64/kernel/cyclone.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.7.orig/arch/ia64/kernel/cyclone.c
+++ linux-2.6.7/arch/ia64/kernel/cyclone.c
@@ -16,62 +16,10 @@
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
+	.source =3D	TIME_SOURCE_MMIO32,
+	.shift =3D	32,
 	.frequency =3D	CYCLONE_TIMER_FREQ,
 	.drift =3D	-100,
 };
@@ -82,6 +30,7 @@
 	u64 base;	/* saved cyclone base address */
 	u64 offset;	/* offset from pageaddr to cyclone_timer register */
 	int i;
+	u32* volatile cyclone_timer;	/* Cyclone MPMC0 register */

 	if (!use_cyclone)
 		return -ENODEV;
@@ -149,7 +98,7 @@
 		}
 	}
 	/* initialize last tick */
-	last_update_cyclone =3D readl(cyclone_timer);
+	cyclone_interpolator.addr =3D cyclone_timer;
 	register_time_interpolator(&cyclone_interpolator);

 	return 0;
Index: linux-2.6.7/arch/ia64/kernel/fsys.S
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.7.orig/arch/ia64/kernel/fsys.S
+++ linux-2.6.7/arch/ia64/kernel/fsys.S
@@ -8,6 +8,8 @@
  * 18-Feb-03 louisk	Implement fsys_gettimeofday().
  * 28-Feb-03 davidm	Fixed several bugs in fsys_gettimeofday().  Tuned it s=
ome more,
  *			probably broke it along the way... ;-)
+ * 13-Jul-04 clameter   Implement fsys_clock_gettime and revise fsys_getti=
meofday to make
+ *                      it capable of using memory based clocks without fa=
lling back to C code.
  */

 #include <asm/asmmacro.h>
@@ -144,195 +146,237 @@
 END(fsys_set_tid_address)

 /*
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
+ * Ensure that the time interpolator structure is compatible with the asm =
code
  */
-
+#if IA64_TIME_INTERPOLATOR_SOURCE_OFFSET !=3D0 || IA64_TIME_INTERPOLATOR_S=
HIFT_OFFSET !=3D 2 || IA64_TIME_INTERPOLATOR_NSEC_OFFSET !=3D 4
+#error fsys_gettimeofday incompatible with changes to struct time_interpol=
ator
+#endif
 ENTRY(fsys_gettimeofday)
+	// Register map
+	// r2,r3 =3D general short term
+	// r20 =3D initial sequence number
+	// r21 =3D result seconds
+	// r22 =3D result nanoseconds
+	// r23 =3D time interpolator first quad with sourcetype, shift, nsec_per_=
cyc
+	// r24 =3D time interpolator_last_counter
+	// r25 =3D new sequence number
+	// r28 =3D pointer to nsec portion of argument (r32+8)
+	// r29 =3D time interpolator counter address
+	// r30 =3D pointer to struct time_interpolator
+	// r31 =3D address of seqlock
+	// r32 =3D address of tv->sec (first argument)
 	.prologue
 	.altrp b6
 	.body
-	add r9=3DTI_FLAGS+IA64_TASK_SIZE,r16
-	addl r3=3DTHIS_CPU(cpu_info),r0
-
-	mov.m r31=3Dar.itc		// put time stamp into r31 (ITC) =3D now		(35 cyc)
-#ifdef CONFIG_SMP
-	movl r10=3D__per_cpu_offset
-	movl r2=3Dsal_platform_features
+	add r2 =3D TI_FLAGS+IA64_TASK_SIZE,r16
+	tnat.nz p6,p7 =3D r32             // guard against NaT argument
 	;;
-
-	ld8 r2=3D[r2]
-	movl r19=3Dxtime			// xtime is a timespec struct
-
-	ld8 r10=3D[r10]			// r10 <- __per_cpu_offset[0]
-	addl r21=3DTHIS_CPU(cpu_info),r0
+	ld4 r2 =3D [r2]
+	movl r31 =3D xtime_lock
+(p7)	tnat.nz p6,p0 =3D r33		// guard against NaT argument
+	movl r30 =3D time_interpolator
+	;;
+	ld8 r30 =3D [r30]
+	and r2 =3D TIF_ALLWORK_MASK,r2
+	;;
+(p6)    br.cond.spnt.few .fail_einval
+	add r28 =3D 8,r32
+	cmp.ne p6, p0 =3D 0, r2		// Fallback if work is scheduled
+(p6)    br.spnt.many fsys_fallback_syscall
+	;;
+.timeofday_retry:
+	ld8 r23 =3D [r30],IA64_TIME_INTERPOLATOR_ADDRESS_OFFSET	// time_interpola=
tor->source/shift/nsec_per_cyc
+	;;
+	extr r2 =3D r23,0,16	// time_interpolator->source
+	ld8 r29 =3D [r30],-IA64_TIME_INTERPOLATOR_ADDRESS_OFFSET
+	extr r3 =3D r23,32,32	// time_interpolator->nsec_per_cyc
+	;;
+	extr r23 =3D r23,16,16	// time_interpolator->shift
+	movl r24 =3D time_interpolator_last_counter
+	movl r21 =3D xtime
+	setf.sig f7 =3D r3
+	cmp4.eq p6, p0 =3D IA64_TIME_SOURCE_CPU, r2
+	cmp4.eq p7, p0 =3D IA64_TIME_SOURCE_MMIO64, r2
+	cmp4.eq p8, p0 =3D IA64_TIME_SOURCE_MMIO32, r2
+	cmp4.lt p9, p0 =3D IA64_TIME_SOURCE_MMIO32, r2
+	ld4.acq r20 =3D [r31]	//  xtime_lock.sequence
+	;;
+	.pred.rel.mutex p6,p7,p8,p9
+	ld8 r24 =3D [r24]		// time_interpolator_last_counter
+(p6)	mov r2 =3D ar.itc		// CPU_TIMER
+(p9)	br.spnt.many fsys_fallback_syscall
+(p7)	ld8 r2 =3D [r29]		// readq
+(p8)	ld4 r2 =3D [r29]		// readw
+	and r20 =3D ~1,r20	// Make sequence even to force retry if odd
+	add r22 =3D 8,r21
+	;;
+	sub r2 =3D r2, r24	// current_counter - last_counter
+ 	ld8 r21 =3D [r21]		// xtime.tv_sec
+	ld8 r22 =3D [r22]		// xtime.tv_nsec
+	;;
+	setf.sig f8 =3D r2
 	;;
-	add r10=3Dr21, r10		// r10 <- &cpu_data(time_keeper_id)
-	tbit.nz p8,p0 =3D r2, IA64_SAL_PLATFORM_FEATURE_ITC_DRIFT_BIT
-(p8)	br.spnt.many fsys_fallback_syscall
-#else
+	xmpy.l f8 =3D f8,f7	// nsec_per_cyc*(counter-last_counter)
 	;;
-	mov r10=3Dr3
-	movl r19=3Dxtime			// xtime is a timespec struct
-#endif
-	ld4 r9=3D[r9]
-	movl r17=3Dxtime_lock
+	getf.sig r2 =3D f8
+	movl r3 =3D time_interpolator_offset
 	;;
-
-	// r32, r33 should contain the 2 args of gettimeofday
-	adds r21=3DIA64_CPUINFO_ITM_NEXT_OFFSET, r10
-	mov r2=3D-1
-	tnat.nz p6,p7=3Dr32		// guard against NaT args
+	shr.u r2 =3D r2,r23
+	ld8 r3 =3D [r3]		// time_interpolator_offset
 	;;
-
-	adds r10=3DIA64_CPUINFO_ITM_DELTA_OFFSET, r10
-(p7)	tnat.nz p6,p0=3Dr33
-(p6)	br.cond.spnt.few .fail_einval
-
-	adds r8=3DIA64_CPUINFO_NSEC_PER_CYC_OFFSET, r3
-	movl r24#61183241434822607	// for division hack (only for / 1000)
+	mf
+	add r2 =3D r2,r3		// Add time interpolator offset
+	ld4 r25 =3D [r31]		// xtime_lock.sequence
 	;;
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
+	add r22 =3D r22,r2	// Add xtime.nsecs
+	cmp4.ne p6,p0 =3D r25,r20
+(p6)	br.cond.dpnt .timeofday_retry	// sequence number changed
+	//  now r21=3Dtv->tv_nsec and r22=3Dtv->tv_sec
+	movl r2 =3D 1000000000
 	;;
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
+.timeofday_checkagain:
+	cmp.ge p6,p0 =3D r22,r2
 	;;
-.retry:	// *** seq =3D read_seqbegin(&xtime_lock); ***
-	ld4.acq r23=3D[r17]		// since &xtime_lock =3D &xtime_lock->sequence
-	ld8 r14=3D[r25]			// r14 (old) =3D last_nsec_offset
-
-	ld8 r28=3D[r26]			// r28 =3D jiffies
-	ld8 r29=3D[r27]			// r29 =3D wall_jiffies
+(p6)	sub r22 =3D r22,r2
+(p6)	add r21 =3D 1,r21
+(p6)	br.cond.dpnt .timeofday_checkagain
 	;;
+	// now r21,r22 contain the normalized time

-	ldf8 f8=3D[r21]			// f8 now contains itm_next
-	sub r28=3Dr29, r28, 1		// r28 now contains "-(lost + 1)"
-	tbit.nz p9, p10=3Dr23, 0		// p9 <- is_odd(r23), p10 <- is_even(r23)
-	;;
-
-	ld8 r2=3D[r19]			// r2 =3D sec =3D xtime.tv_sec
-	ld8 r29=3D[r20]			// r29 =3D nsec =3D xtime.tv_nsec
+EX(.fail_efault, st8 [r32] =3D r21)			// tv->tv_sec =3D seconds

-	setf.sig f6=3Dr28			// f6 <- -(lost + 1)				(6 cyc)
+	// The only thing left to do is to divide nsecs in r22 by 1000. sigh
+	shr.u r22 =3D r22, 3
+	movl r3 =3D 2361183241434822607	// Prep for / 1000 hack
 	;;
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
+	// Divided by 8. Now divide by 125
+	// The compiler is able to do that with a multiply
+	// and a shift and we do the same
+	setf.sig f8 =3D r22
+	setf.sig f7 =3D r3
 	;;
-
-	mov r31=3Dar.itc			// re-read ITC in case we .retry		(35 cyc)
-	xma.l f8=F11, f8, f12	// f8 (elapsed_cycles) <- (-1*last_tick + now) =3D =
(now - last_tick)
-	nop 0
+	xmpy.hu f8 =3D f8, f7
 	;;
-
-	getf.sig r18=F8			// r18 <- (now - last_tick)
-	xmpy.l f8=F8, f10		// f8 <- elapsed_cycles*nsec_per_cyc (5 cyc)
-	add r3=3Dr29, r14			// r3 =3D (nsec + old)
+	getf.sig r2 =3D f8
 	;;
-
-	cmp.lt p7, p8=3Dr18, r0		// if now < last_tick, set p7 =3D 1, p8 =3D 0
-	getf.sig r18=F8			// r18 =3D elapsed_cycles*nsec_per_cyc		(6 cyc)
-	nop 0
+	shr.u r2 =3D r2, 4
 	;;
+EX(.fail_efault, st8 [r28] =3D r2)

-(p10)	cmp.ne p9, p0=3Dr23, r24		// if xtime_lock->sequence !=3D seq, set p9
-	shr.u r18=3Dr18, IA64_NSEC_PER_CYC_SHIFT	// r18 <- offset
-(p9)	br.spnt.many .retry
-	;;
+	mov r8 =3D r0
+	mov r10 =3D r0
+	FSYS_RETURN
+.fail_einval:
+	mov r8 =3D EINVAL
+	mov r10 =3D -1
+	FSYS_RETURN

-	mov ar.ccv=3Dr14			// ar.ccv =3D old					(1 cyc)
-	cmp.leu p7, p8=3Dr18, r14		// if (offset <=3D old), set p7 =3D 1, p8 =3D 0
-	;;
+.fail_efault:
+	mov r8 =3D EFAULT
+	mov r10 =3D -1
+	FSYS_RETURN
+END(fsys_gettimeofday)

-(p8)	cmpxchg8.rel r24=3D[r25], r18, ar.ccv	// compare-and-exchange (atomic=
!)
-(p8)	add r3=3Dr29, r18			// r3 =3D (nsec + offset)
-	;;
-	shr.u r3=3Dr3, 3			// initiate dividing r3 by 1000
-	;;
-	setf.sig f8=3Dr3			//						(6 cyc)
-	mov r10=1000000			// r10 =3D 1000000
+ENTRY(fsys_clock_gettime)
+	// Register map
+	// r2,r3 =3D scratch
+	// r20 =3D initial sequence number
+	// r21 =3D result seconds
+	// r22 =3D result nanoseconds
+	// r23 =3D time interpolator first quad with sourcetype, shift, nsec_per_=
cyc
+	// r24 =3D time interpolator_last_counter
+	// r25 =3D new sequence number
+	// r28 =3D pointer to nsec portion of timespec structure (r33+8)
+	// r29 =3D time interpolator counter address
+	// r30 =3D pointer to struct time_interpolator
+	// r31 =3D address of seqlock
+	// r32 =3D type of timer desired (argument 1)
+	// r33 =3D pointer to sec portion of timespec structure (argument 2)
+	.prologue
+	.altrp b6
+	.body
+	add r2 =3D TI_FLAGS+IA64_TASK_SIZE,r16
+	movl r30 =3D time_interpolator
 	;;
-(p8)	cmp.ne.unc p9, p0=3Dr24, r14
-	xmpy.hu f6=F8, f9		//						(5 cyc)
-(p9)	br.spnt.many .retry
+	ld4 r2 =3D [r2]
+	tnat.nz p6,p0 =3D r33
+	ld8 r30 =3D [r30]
+	;;
+	and r2 =3D TIF_ALLWORK_MASK,r2
+	add r28 =3D 8,r33
+(p6)    br.cond.spnt.few .fail_einval
+	;;
+	cmp.ne p6, p7 =3D 0, r2	// Fallback if work is scheduled
+	;;
+(p7)	cmp.ne p6, p0 =3D 0, r32	// Fallback if this is not CLOCK_REALTIME
+(p6)	br.spnt.many fsys_fallback_syscall
+	movl r31 =3D xtime_lock
+
+.gettime_retry:
+	ld8 r23 =3D [r30],IA64_TIME_INTERPOLATOR_ADDRESS_OFFSET	// time_interpola=
tor->source/shift/nsec_per_cyc
+	movl r24 =3D time_interpolator_last_counter
+	;;
+	ld8 r29 =3D [r30],-IA64_TIME_INTERPOLATOR_ADDRESS_OFFSET
+	extr r2 =3D r23,0,16
+	extr r3 =3D r23,32,32	// time_interpolator->nsec_per_cyc
+	ld4.acq r20 =3D [r31]	// xtime_lock.sequence
+	;;
+	ld8 r24 =3D [r24]		// time_interpolator_last_counter
+	extr r23 =3D r23,16,16	// time_interpolator->shift
+	cmp4.eq p6, p0 =3D IA64_TIME_SOURCE_CPU, r2
+	cmp4.eq p7, p0 =3D IA64_TIME_SOURCE_MMIO64, r2
+	cmp4.eq p8, p0 =3D IA64_TIME_SOURCE_MMIO32, r2
+	cmp4.lt p9, p0 =3D IA64_TIME_SOURCE_MMIO32, r2
+	and r20 =3D ~1,r20	// Make seq.number even to insure retry if odd
+	movl r21 =3D xtime
+	;;
+	.pred.rel.mutex p6,p7,p8,p9
+(p6)	mov r2 =3D ar.itc		// CPU_TIMER
+(p7)	ld8 r2 =3D [r29]		// readq
+(p8)	ld4 r2 =3D [r29]		// readw
+(p9)	br.spnt.many fsys_fallback_syscall	// Cannot do function call -> fall=
back
+	add r22 =3D 8,r21
+	;;
+	sub r2 =3D r2, r24
+ 	ld8 r21 =3D [r21]		// xtime.tv_sec
+	ld8 r22 =3D [r22]		// xtime.tv_nsec
+	;;
+	setf.sig f6 =3D r2
+	setf.sig f7 =3D r3
+	;;
+	xmpy.l f6 =3D f6,f7	// nsec_per_cyc*(timeval-last_counter)
 	;;
-
-	getf.sig r3=F6			//						(6 cyc)
+	getf.sig r2 =3D f6
+	movl r24 =3D time_interpolator_offset
 	;;
-	shr.u r3=3Dr3, 4			// end of division, r3 is divided by 1000 (=3Dusec)
+	ld8 r24 =3D [r24]		// time_interpolator_offset
+	shr.u r2 =3D r2,r23
 	;;
-
-1:	cmp.geu p7, p0=3Dr3, r10		// while (usec >=3D 1000000)
+	add r2 =3D r2,r24		// result plus interpolator_offset
+	mf
 	;;
-(p7)	sub r3=3Dr3, r10			// usec -=3D 1000000
-(p7)	adds r2=3D1, r2			// ++sec
-(p7)	br.spnt.many 1b
-
-	// finally: r2 =3D sec, r3 =3D usec
-EX(.fail_efault, st8 [r32]=3Dr2)
-	adds r9=3D8, r32
-	mov r8=3Dr0			// success
+	add r22 =3D r22,r2	// Add nsec
+	ld4 r2 =3D [r31]		// xtime_lock.sequence
 	;;
-EX(.fail_efault, st8 [r9]=3Dr3)		// store them in the timeval struct
-	mov r10=3D0
+	cmp4.ne p6,p0 =3D r2,r20
+(p6)	br.cond.dpnt .gettime_retry
+	//  now r21=3Dtv->tv_nsec and r22=3Dtv->tv_sec
+	movl r2 =3D 1000000000
+	;;
+.gettime_checkagain:
+	cmp.ge p6,p0 =3D r22,r2
+	;;
+(p6)	sub r22 =3D r22,r2
+(p6)	add r21 =3D 1,r21
+(p6)	br.cond.dpnt .gettime_checkagain
+	;;
+	// now r21,r22 contain the normalized time
+EX(.fail_efault, st8 [r33] =3D r21)	// tv->tv_sec =3D seconds
+EX(.fail_efault, st8 [r28] =3D r22)	// tv->tv_nsec =3D nanosecs
+	mov r8 =3D r0
+	mov r10 =3D r0
 	FSYS_RETURN
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
-.fail_einval:
-	mov r8=3DEINVAL			// r8 =3D EINVAL
-	mov r10=3D-1			// r10 =3D -1
-	FSYS_RETURN
-
-.fail_efault:
-	mov r8=EFAULT			// r8 =3D EFAULT
-	mov r10=3D-1			// r10 =3D -1
-	FSYS_RETURN
-END(fsys_gettimeofday)
+END(fsys_gettime)

 /*
  * long fsys_rt_sigprocmask (int how, sigset_t *set, sigset_t *oset, size_=
t sigsetsize).
@@ -839,7 +883,7 @@
 	data8 0				// timer_getoverrun
 	data8 0				// timer_delete
 	data8 0				// clock_settime
-	data8 0				// clock_gettime
+	data8 fsys_clock_gettime	// clock_gettime
 	data8 0				// clock_getres		// 1255
 	data8 0				// clock_nanosleep
 	data8 0				// fstatfs64
Index: linux-2.6.7/arch/ia64/kernel/time.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.7.orig/arch/ia64/kernel/time.c
+++ linux-2.6.7/arch/ia64/kernel/time.c
@@ -45,46 +45,7 @@

 #endif

-static void
-itc_reset (void)
-{
-}
-
-/*
- * Adjust for the fact that xtime has been advanced by delta_nsec (may be =
negative and/or
- * larger than NSEC_PER_SEC.
- */
-static void
-itc_update (long delta_nsec)
-{
-}
-
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
-{
-	unsigned long elapsed_cycles, lost =3D jiffies - wall_jiffies;
-	unsigned long now =3D ia64_get_itc(), last_tick;
-
-	last_tick =3D (cpu_data(TIME_KEEPER_ID)->itm_next
-		     - (lost + 1)*cpu_data(TIME_KEEPER_ID)->itm_delta);
-
-	elapsed_cycles =3D now - last_tick;
-	return (elapsed_cycles*local_cpu_data->nsec_per_cyc) >> IA64_NSEC_PER_CYC=
_SHIFT;
-}
-
-static struct time_interpolator itc_interpolator =3D {
-	.get_offset =3D	itc_get_offset,
-	.update =3D	itc_update,
-	.reset =3D	itc_reset
-};
+static struct time_interpolator itc_interpolator;

 int
 do_settimeofday (struct timespec *tv)
@@ -127,53 +88,15 @@
 void
 do_gettimeofday (struct timeval *tv)
 {
-	unsigned long seq, nsec, usec, sec, old, offset;
-
-	while (1) {
+	unsigned long seq, nsec, usec, sec, offset;
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
+		offset =3D time_interpolator_get_offset();
+		sec =3D xtime.tv_sec;
+		nsec =3D xtime.tv_nsec;
+	} while (unlikely(read_seqretry(&xtime_lock, seq)));

-		/* someone else beat us to updating last_nsec_offset; try again */
-	}
-
-	usec =3D (nsec + offset) / 1000;
+       	usec =3D (nsec + offset) / 1000;

 	while (unlikely(usec >=3D USEC_PER_SEC)) {
 		usec -=3D USEC_PER_SEC;
@@ -385,7 +308,14 @@

 	if (!(sal_platform_features & IA64_SAL_PLATFORM_FEATURE_ITC_DRIFT)) {
 		itc_interpolator.frequency =3D local_cpu_data->itc_freq;
+		itc_interpolator.shift =3D 10;	/* accuracy ~200ns */
+		/* shift=16 yields a much better accuracy (~50ns) but runs
+		 * the risk of having the interpolator run too fast on some
+		 * systems
+		 */
 		itc_interpolator.drift =3D itc_drift;
+		itc_interpolator.source =3D TIME_SOURCE_CPU;
+		itc_interpolator.addr =3D NULL;
 		register_time_interpolator(&itc_interpolator);
 	}

Index: linux-2.6.7/arch/ia64/sn/kernel/sn2/timer.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.7.orig/arch/ia64/sn/kernel/sn2/timer.c
+++ linux-2.6.7/arch/ia64/sn/kernel/sn2/timer.c
@@ -20,57 +20,16 @@


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
+	sn2_interpolator.shift =3D 0;	/* RTC is 54 bits maximum shift is 10 */
+	sn2_interpolator.addr =3D RTC_COUNTER_ADDR;
+	sn2_interpolator.source =3D TIME_SOURCE_MMIO64;
 	register_time_interpolator(&sn2_interpolator);
-
-	rtc_per_timer_tick =3D sn_rtc_cycles_per_second / HZ;
-	rtc_nsecs_per_cycle =3D 1000000000 / sn_rtc_cycles_per_second;
-
-	last_wall_rtc =3D GET_RTC_COUNTER();
 }
Index: linux-2.6.7/include/linux/timex.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.7.orig/include/linux/timex.h
+++ linux-2.6.7/include/linux/timex.h
@@ -55,6 +55,7 @@
 #include <linux/compiler.h>

 #include <asm/param.h>
+#include <asm/io.h>

 /*
  * The following defines establish the engineering parameters of the PLL
@@ -320,81 +321,96 @@

 #ifdef CONFIG_TIME_INTERPOLATION

+#define TIME_SOURCE_CPU 0
+#define TIME_SOURCE_MMIO64 1
+#define TIME_SOURCE_MMIO32 2
+#define TIME_SOURCE_FUNCTION 3
+
+/* For proper operations time_interpolator clocks must run slightly slower
+   than the standard clock since the interpolator may only correct by havi=
ng
+   time jump forward during a tick. A slower clock is usually a side effect
+   of the integer divide of the nanoseconds in a second by the frequency.
+   The accuracy of the division can be increased by specifying a shift.
+   However, this may cause the clock not to be slow enough. If that is the
+   case then either the scaling needs to be reduced or a lower frequency
+   specified to slow down the interpolator.
+   A too fast interpolator will result in a time_interpolator_offset
+   that does not go back to zero once in a while. The interpolator
+   clock will become the time source for the system and the
+   logic for time adjustments in kernel/time.c will no longer work.
+*/
 struct time_interpolator {
-	/* cache-hot stuff first: */
-	unsigned long (*get_offset) (void);
-	void (*update) (long);
-	void (*reset) (void);
-
-	/* cache-cold stuff follows here: */
-	struct time_interpolator *next;
+	unsigned short source;		/* type of time source */
+	unsigned short shift;		/* increases accuracy of multiply by shifting. */
+			/* Note that bits may be lost if shift is set too high */
+	unsigned nsec_per_cyc;		/* set by register_time_interpolator() */
+	void *addr;			/* address of counter or function */
 	unsigned long frequency;	/* frequency in counts/second */
 	long drift;			/* drift in parts-per-million (or -1) */
+	struct time_interpolator *next;
 };

-extern volatile unsigned long last_nsec_offset;
-#ifndef __HAVE_ARCH_CMPXCHG
-extern spin_lock_t last_nsec_offset_lock;
-#endif
 extern struct time_interpolator *time_interpolator;

-extern void register_time_interpolator(struct time_interpolator *);
-extern void unregister_time_interpolator(struct time_interpolator *);
-
-/* Called with xtime WRITE-lock acquired.  */
-static inline void
-time_interpolator_update(long delta_nsec)
+static inline unsigned long
+time_interpolator_get_counter(void)
 {
-	struct time_interpolator *ti =3D time_interpolator;
+	unsigned long (*x)(void);

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
+	switch (time_interpolator->source)
+	{
+		case TIME_SOURCE_FUNCTION:
+			x=3Dtime_interpolator->addr;
+			return x();
+
+		case TIME_SOURCE_MMIO64	: return readq(time_interpolator->addr);
+		case TIME_SOURCE_MMIO32	: return readl(time_interpolator->addr);
+		default: return get_cycles();
 	}
-
-	if (ti)
-		(*ti->update)(delta_nsec);
 }

-/* Called with xtime WRITE-lock acquired.  */
+/* Offset from last_counter in nsecs */
+extern unsigned long time_interpolator_offset;
+
+/* Counter value in units of the counter */
+extern unsigned long time_interpolator_last_counter;
+
+extern void register_time_interpolator(struct time_interpolator *);
+extern void unregister_time_interpolator(struct time_interpolator *);
+
 static inline void
 time_interpolator_reset(void)
 {
-	struct time_interpolator *ti =3D time_interpolator;
-
-	last_nsec_offset =3D 0;
-	if (ti)
-		(*ti->reset)();
+	time_interpolator_offset =3D 0;
+	time_interpolator_last_counter =3D time_interpolator_get_counter();
 }

-/* Called with xtime READ-lock acquired.  */
+#define GET_TI_NSECS(count,i) ((((count) - time_interpolator_last_counter)=
 * i->nsec_per_cyc) >> i->shift )
+
 static inline unsigned long
 time_interpolator_get_offset(void)
 {
-	struct time_interpolator *ti =3D time_interpolator;
-	if (ti)
-		return (*ti->get_offset)();
-	return last_nsec_offset;
+	return time_interpolator_offset +
+		GET_TI_NSECS(time_interpolator_get_counter(),time_interpolator);
+}
+
+static inline void time_interpolator_update(long delta_nsec)
+{
+	unsigned long counter=3Dtime_interpolator_get_counter();
+	unsigned long offset=3Dtime_interpolator_offset + GET_TI_NSECS(counter,ti=
me_interpolator);
+
+	/* The interpolator compensates for late ticks by accumulating
+         * the late time in interpolator_offset. A tick earlier than
+	 * expected will lead to a reset of the offset and a corresponding
+	 * jump of the clock forward. Again this only works if the
+	 * interpolator clock is running slightly slower than the regular clock.
+         */
+
+	if (delta_nsec < 0 || (unsigned long) delta_nsec < offset)
+		time_interpolator_offset =3D offset - delta_nsec;
+	else
+		time_interpolator_offset =3D 0;			/* Early tick. Resync */
+	time_interpolator_last_counter =3D counter;
 }

 #else /* !CONFIG_TIME_INTERPOLATION */
Index: linux-2.6.7/kernel/timer.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.7.orig/kernel/timer.c
+++ linux-2.6.7/kernel/timer.c
@@ -1425,31 +1425,33 @@
 }

 #ifdef CONFIG_TIME_INTERPOLATION
-volatile unsigned long last_nsec_offset;
-#ifndef __HAVE_ARCH_CMPXCHG
-spinlock_t last_nsec_offset_lock =3D SPIN_LOCK_UNLOCKED;
-#endif

 struct time_interpolator *time_interpolator;
 static struct time_interpolator *time_interpolator_list;
 static spinlock_t time_interpolator_lock =3D SPIN_LOCK_UNLOCKED;
+unsigned long time_interpolator_offset;
+unsigned long time_interpolator_last_counter;

 static inline int
 is_better_time_interpolator(struct time_interpolator *new)
 {
 	if (!time_interpolator)
 		return 1;
-	return new->frequency > 2*time_interpolator->frequency ||
+	return new->frequency > 2 * time_interpolator->frequency ||
 	    (unsigned long)new->drift < (unsigned long)time_interpolator->drift;
 }

 void
 register_time_interpolator(struct time_interpolator *ti)
 {
+	ti->nsec_per_cyc =3D (NSEC_PER_SEC << ti->shift) / ti->frequency;
 	spin_lock(&time_interpolator_lock);
 	write_seqlock_irq(&xtime_lock);
 	if (is_better_time_interpolator(ti))
+	{
 		time_interpolator =3D ti;
+		time_interpolator_reset();
+	}
 	write_sequnlock_irq(&xtime_lock);

 	ti->next =3D time_interpolator_list;
@@ -1480,6 +1482,7 @@
 		for (curr =3D time_interpolator_list; curr; curr =3D curr->next)
 			if (is_better_time_interpolator(curr))
 				time_interpolator =3D curr;
+		time_interpolator_reset();
 	}
 	write_sequnlock_irq(&xtime_lock);
 	spin_unlock(&time_interpolator_lock);
Index: linux-2.6.7/arch/ia64/kernel/asm-offsets.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.7.orig/arch/ia64/kernel/asm-offsets.c
+++ linux-2.6.7/arch/ia64/kernel/asm-offsets.c
@@ -208,4 +208,12 @@
 	BLANK();
 	DEFINE(IA64_MCA_TLB_INFO_SIZE, sizeof (struct ia64_mca_tlb_info));

+	BLANK();
+	DEFINE(IA64_TIME_INTERPOLATOR_ADDRESS_OFFSET, offsetof (struct time_inter=
polator, addr));
+	DEFINE(IA64_TIME_INTERPOLATOR_SOURCE_OFFSET, offsetof (struct time_interp=
olator, source));
+	DEFINE(IA64_TIME_INTERPOLATOR_SHIFT_OFFSET, offsetof (struct time_interpo=
lator, shift));
+	DEFINE(IA64_TIME_INTERPOLATOR_NSEC_OFFSET, offsetof (struct time_interpol=
ator, nsec_per_cyc));
+	DEFINE(IA64_TIME_SOURCE_CPU, TIME_SOURCE_CPU);
+	DEFINE(IA64_TIME_SOURCE_MMIO64, TIME_SOURCE_MMIO64);
+	DEFINE(IA64_TIME_SOURCE_MMIO32, TIME_SOURCE_MMIO32);
 }


=3D=3D NANOSECONDS PATH
Index: linux-2.6.7/kernel/timer.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.7.orig/kernel/timer.c
+++ linux-2.6.7/kernel/timer.c
@@ -1241,8 +1241,7 @@
 		 * too.
 		 */

-		do_gettimeofday((struct timeval *)&tp);
-		tp.tv_nsec *=3D NSEC_PER_USEC;
+		getnstimeofday(&tp);
 		tp.tv_sec +=3D wall_to_monotonic.tv_sec;
 		tp.tv_nsec +=3D wall_to_monotonic.tv_nsec;
 		if (tp.tv_nsec - NSEC_PER_SEC >=3D 0) {
Index: linux-2.6.7/kernel/posix-timers.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.7.orig/kernel/posix-timers.c
+++ linux-2.6.7/kernel/posix-timers.c
@@ -1168,15 +1168,10 @@
  */
 static int do_posix_gettime(struct k_clock *clock, struct timespec *tp)
 {
-	struct timeval tv;
-
 	if (clock->clock_get)
 		return clock->clock_get(tp);

-	do_gettimeofday(&tv);
-	tp->tv_sec =3D tv.tv_sec;
-	tp->tv_nsec =3D tv.tv_usec * NSEC_PER_USEC;
-
+	getnstimeofday(tp);
 	return 0;
 }

@@ -1192,24 +1187,16 @@
 	struct timespec *tp, struct timespec *mo)
 {
 	u64 jiff;
-	struct timeval tpv;
 	unsigned int seq;

 	do {
 		seq =3D read_seqbegin(&xtime_lock);
-		do_gettimeofday(&tpv);
+		getnstimeofday(tp);
 		*mo =3D wall_to_monotonic;
 		jiff =3D jiffies_64;

 	} while(read_seqretry(&xtime_lock, seq));

-	/*
-	 * Love to get this before it is converted to usec.
-	 * It would save a div AND a mpy.
-	 */
-	tp->tv_sec =3D tpv.tv_sec;
-	tp->tv_nsec =3D tpv.tv_usec * NSEC_PER_USEC;
-
 	return jiff;
 }

Index: linux-2.6.7/include/linux/time.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.7.orig/include/linux/time.h
+++ linux-2.6.7/include/linux/time.h
@@ -348,6 +348,7 @@
 struct itimerval;
 extern int do_setitimer(int which, struct itimerval *value, struct itimerv=
al *ovalue);
 extern int do_getitimer(int which, struct itimerval *value);
+extern void getnstimeofday (struct timespec *tv);

 static inline void
 set_normalized_timespec (struct timespec *ts, time_t sec, long nsec)
Index: linux-2.6.7/kernel/time.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.7.orig/kernel/time.c
+++ linux-2.6.7/kernel/time.c
@@ -22,6 +22,9 @@
  *	"A Kernel Model for Precision Timekeeping" by Dave Mills
  *	Allow time_constant larger than MAXTC(6) for NTP v4 (MAXTC =3D 10)
  *	(Even though the technical memorandum forbids it)
+ * 2004-07-14	 Christoph Lameter
+ *	Added getnstimeofday to allow the posix timer functions to return
+ *	with nanosecond accuracy
  */

 #include <linux/module.h>
@@ -421,6 +424,41 @@

 EXPORT_SYMBOL(current_kernel_time);

+#ifdef CONFIG_TIME_INTERPOLATION
+void getnstimeofday (struct timespec *tv)
+{
+	unsigned long seq,sec,nsec;
+
+	do {
+		seq =3D read_seqbegin(&xtime_lock);
+		sec =3D xtime.tv_sec;
+		nsec =3D xtime.tv_nsec+time_interpolator_get_offset();
+	} while (unlikely(read_seqretry(&xtime_lock, seq)));
+
+	while (unlikely(nsec >=3D NSEC_PER_SEC)) {
+		nsec -=3D NSEC_PER_SEC;
+		++sec;
+	}
+	tv->tv_sec =3D sec;
+	tv->tv_nsec =3D nsec;
+}
+#else
+/*
+ * Simulate gettimeofday using do_gettimeofday which only allows a timeval
+ * and therefore only yields usec accuracy
+ */
+void getnstimeofday(struct timespec *tv)
+{
+	struct timeval x;
+
+	do_gettimeofday(&x);
+	tv->tv_sec =3D x.tv_sec;
+	tv->tv_nsec =3D x.tv_usec * NSEC_PER_USEC;
+}
+#endif
+
+EXPORT_SYMBOL(getnstimeofday);
+
 #if (BITS_PER_LONG < 64)
 u64 get_jiffies_64(void)
 {

=3D=3D TIME_INTERPOLATOR DEBUG PATCH

Index: linux-2.6.7/include/linux/timex.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.7.orig/include/linux/timex.h
+++ linux-2.6.7/include/linux/timex.h
@@ -394,6 +394,8 @@
 		GET_TI_NSECS(time_interpolator_get_counter(),time_interpolator);
 }

+extern int ti_debug;
+
 static inline void time_interpolator_update(long delta_nsec)
 {
 	unsigned long counter=3Dtime_interpolator_get_counter();
@@ -406,10 +408,19 @@
 	 * interpolator clock is running slightly slower than the regular clock.
          */

-	if (delta_nsec < 0 || (unsigned long) delta_nsec < offset)
+	if (delta_nsec < 0 || (unsigned long) delta_nsec < offset) {
+		if (ti_debug)
+			printk(KERN_INFO "continue O=3D%lu delta=3D%ld offset=3D%lu ti_offset=
=3D%lu set to %ld nanoseconds.\n",
+				GET_TI_NSECS(counter,time_interpolator),delta_nsec,offset,
+				time_interpolator_offset,offset - delta_nsec);
 		time_interpolator_offset =3D offset - delta_nsec;
-	else
+	} else {
+		if (ti_debug)
+			printk(KERN_INFO "reset O=3D%lu delta=3D%ld offset=3D%lu ti_offset=3D%l=
u skipping %ld nanoseconds.\n",
+				GET_TI_NSECS(counter,time_interpolator),delta_nsec,offset,
+				time_interpolator_offset,delta_nsec-offset);
 		time_interpolator_offset =3D 0;			/* Early tick. Resync */
+	}
 	time_interpolator_last_counter =3D counter;
 }

Index: linux-2.6.7/kernel/timer.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.7.orig/kernel/timer.c
+++ linux-2.6.7/kernel/timer.c
@@ -1431,6 +1431,7 @@
 static spinlock_t time_interpolator_lock =3D SPIN_LOCK_UNLOCKED;
 unsigned long time_interpolator_offset;
 unsigned long time_interpolator_last_counter;
+unsigned long ti_debug;

 static inline int
 is_better_time_interpolator(struct time_interpolator *new)
@@ -1445,6 +1446,7 @@
 register_time_interpolator(struct time_interpolator *ti)
 {
 	ti->nsec_per_cyc =3D (NSEC_PER_SEC << ti->shift) / ti->frequency;
+	printk(KERN_INFO "new time_interpolator: freq=3D%ld cyc=3D%d ns short by=
=3D%d ns.\n",ti->frequency,ti->nsec_per_cyc, (NSEC_PER_SEC << ti->shift) % =
ti->frequency);
 	spin_lock(&time_interpolator_lock);
 	write_seqlock_irq(&xtime_lock);
 	if (is_better_time_interpolator(ti))
