From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 30 Jul 2004 03:52:49 +0000
Subject: Timer updates revision 7 (asm sets predicates/various fixes)
Message-Id: <Pine.LNX.4.58.0407292044500.3633@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Here is an update of the patches that does not rely on bit patterns in C
to set predicates. Various other issues were fixed as well. New code is
now 2 or 3 cycles faster than the old code.

Testing on an HP RX2600 (2x IA64 900 Mhz) yields:

Old Code:

singsing:/usr/src/noship-tests # ./dmt
gettimeofday cycles: 3250 215 215 215 215 215 215 215 215 215
clock_gettime(REAL) cycles: 3335 571 561 559 570 570 552 552 552 553
clock_gettime(MONO) cycles: 953 609 605 605 605 605 607 605 605 605

singsing:/usr/src/noship-tests # ./todscale
 CPUS       WALL  WALL/CPUS
    1      0.187      0.187
    2      0.848      0.424

New Code:

singsing:/usr/src/noship-tests # ./dmt
gettimeofday cycles: 3312 212 213 213 212 212 213 213 213 213
clock_gettime(REAL) cycles: 2880 224 210 210 210 210 210 210 210 210
clock_gettime(MONO) cycles: 285 233 226 219 219 219 219 219 219 219

singsing:/usr/src/noship-tests # ./todscale
 CPUS       WALL  WALL/CPUS
    1      0.187      0.187
    2      0.746      0.373

(The number of cycles seems to depend on the ITC frequency which may
vary between systems)

%patch
Index: linux-2.6.7/arch/ia64/kernel/cyclone.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.7.orig/arch/ia64/kernel/cyclone.c	200=
4-06-15 22:19:22.000000000 -0700
+++ linux-2.6.7/arch/ia64/kernel/cyclone.c	2004-07-22 19:45:57.000000000 -0=
700
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
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.7.orig/arch/ia64/kernel/fsys.S	2004-0=
7-22 19:34:15.000000000 -0700
+++ linux-2.6.7/arch/ia64/kernel/fsys.S	2004-07-29 15:32:14.000000000 -0700
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
@@ -144,195 +146,206 @@
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
+#if IA64_TIME_INTERPOLATOR_SOURCE_OFFSET !=3D0 || IA64_TIME_INTERPOLATOR_S=
HIFT_OFFSET !=3D 2 \
+	|| IA64_TIME_INTERPOLATOR_JITTER_OFFSET !=3D 3 || IA64_TIME_INTERPOLATOR_=
NSEC_OFFSET !=3D 4
+#error fsys_gettimeofday incompatible with changes to struct time_interpol=
ator
+#endif
+#define CLOCK_REALTIME 0
+#define CLOCK_MONOTONIC 1
+#define CLOCK_DIVIDE_BY_1000 0x4000
+#define CLOCK_ADD_MONOTONIC 0x8000

 ENTRY(fsys_gettimeofday)
 	.prologue
 	.altrp b6
 	.body
-	add r9=3DTI_FLAGS+IA64_TASK_SIZE,r16
-	addl r3=3DTHIS_CPU(cpu_info),r0
-
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
-	mov.m r31=3Dar.itc		// put time stamp into r31 (ITC) =3D now
-	sub r28=3Dr29, r28, 1		// r28 now contains "-(lost + 1)"
-	;;
-
-	ld8 r2=3D[r19]			// r2 =3D sec =3D xtime.tv_sec
-	ld8 r29=3D[r20]			// r29 =3D nsec =3D xtime.tv_nsec
-	tbit.nz p9, p10=3Dr23, 0		// p9 <- is_odd(r23), p10 <- is_even(r23)
-
-	setf.sig f6=3Dr28			// f6 <- -(lost + 1)				(6 cyc)
-	;;
-
+	mov r31 =3D r32
+	tnat.nz p6,p0 =3D r33		// guard against NaT argument
+(p6)    br.cond.spnt.few .fail_einval
+	mov r30 =3D CLOCK_DIVIDE_BY_1000
+	;;
+.gettime:
+	// Register map
+	// Incoming r31 =3D pointer to address where to place result
+	//          r30 =3D flags determining how time is processed
+	// r2,r3 =3D temp r4-r7 preserved
+	// r8 =3D result nanoseconds
+	// r9 =3D result seconds
+	// r10 =3D temporary storage for clock difference
+	// r11 =3D preserved: saved ar.pfs
+	// r12 =3D preserved: memory stack
+	// r13 =3D preserved: thread pointer
+	// r14 =3D debug pointer / usable
+	// r15 =3D preserved: system call number
+	// r16 =3D preserved: current task pointer
+	// r17 =3D wall to monotonic use
+	// r18 =3D time_interpolator->offset
+	// r19 =3D address of wall_to_monotonic
+	// r20 =3D pointer to struct time_interpolator / pointer to time_interpol=
ator->address
+	// r21 =3D shift factor
+	// r22 =3D address of time interpolator->last_counter
+	// r23 =3D address of time_interpolator->last_cycle
+	// r24 =3D adress of time_interpolator->offset
+	// r25 =3D last_cycle value
+	// r26 =3D last_counter value
+	// r27 =3D pointer to xtime
+	// r28 =3D sequence number at the beginning of critcal section
+	// r29 =3D address of seqlock
+	// r30 =3D time processing flags / memory address
+	// r31 =3D pointer to result
+	// Predicates
+	// p6,p7 short term use
+	// p8 =3D timesource ar.itc
+	// p9 =3D timesource mmio64
+	// p10 =3D timesource mmio32
+	// p11 =3D timesource not to be handled by asm code
+	// p12 =3D memory time source ( =3D p9 | p10)
+	// p13 =3D do cmpxchg with time_interpolator_last_cycle
+	// p14 =3D Divide by 1000
+	// p15 =3D Add monotonic
+	//
+	// Note that instructions are optimized for McKinley. McKinley can proces=
s two
+	// bundles simultaneously and therefore we continuously try to feed the C=
PU
+	// two bundles and then a stop.
+	tnat.nz p6,p0 =3D r31	// branch deferred since it does not fit into bundl=
e structure
+	mov pr =3D r30,0xc000	// Set predicates according to function
+	add r2 =3D TI_FLAGS+IA64_TASK_SIZE,r16
+	movl r20 =3D time_interpolator
+	;;
+	ld8 r20 =3D [r20]		// get pointer to time_interpolator structure
+	movl r29 =3D xtime_lock
+	ld4 r2 =3D [r2]		// process work pending flags
+	movl r27 =3D xtime
+	;;	// only one bundle here
+	ld8 r21 =3D [r20]		// first quad with control information
+	and r2 =3D TIF_ALLWORK_MASK,r2
+(p6)    br.cond.spnt.few .fail_einval	// deferred branch
+	;;
+	add r10 =3D IA64_TIME_INTERPOLATOR_ADDRESS_OFFSET,r20
+	extr r3 =3D r21,32,32	// time_interpolator->nsec_per_cyc
+	extr r8 =3D r21,0,16	// time_interpolator->source
+	nop.i 123
+	cmp.ne p6, p0 =3D 0, r2	// Fallback if work is scheduled
+(p6)    br.cond.spnt.many fsys_fallback_syscall
+	;;
+	cmp.eq p8,p12 =3D 0,r8	// Check for cpu timer
+	cmp.eq p9,p0 =3D 1,r8	// MMIO64 ?
+	extr r2 =3D r21,24,8	// time_interpolator->jitter
+	cmp.eq p10,p0 =3D 2,r8	// MMIO32 ?
+	cmp.lt p11,p0 =3D 2,r8	// function?
+(p11)	br.cond.spnt.many fsys_fallback_syscall
+	;;
+	setf.sig f7 =3D r3	// Setup for scaling of counter
+(p15)	movl r19 =3D wall_to_monotonic
+(p12)	ld8 r30 =3D [r10]
+	cmp.ne p13,p0 =3D r2,r0	// need jitter compensation?
+	extr r21 =3D r21,16,8	// shift factor
+	;;
+.time_redo:
+	.pred.rel.mutex p8,p9,p10
+	ld4.acq r28 =3D [r29]	// xtime_lock.sequence. Must come first for locking=
 purposes
+(p8)	mov r2 =3D ar.itc		// CPU_TIMER. 36 clocks latency!!!
+	add r22 =3D IA64_TIME_INTERPOLATOR_LAST_COUNTER_OFFSET,r20
+(p9)	ld8 r2 =3D [r30]		// readq(ti->address). Could also have latency issu=
es..
+(p10)	ld4 r2 =3D [r30]		// readw(ti->address)
+(p13)	add r23 =3D IA64_TIME_INTERPOLATOR_LAST_CYCLE_OFFSET,r20
+	;;			// could be removed by moving the last add upward
+	ld8 r26 =3D [r22]		// time_interpolator->last_counter
+(p13)	ld8 r25 =3D [r23]		// time interpolator->last_cycle
+	add r24 =3D IA64_TIME_INTERPOLATOR_OFFSET_OFFSET,r20
+(p15)	ld8 r17 =3D [r19],IA64_TIMESPEC_TV_NSEC_OFFSET
+ 	ld8 r9 =3D [r27],IA64_TIMESPEC_TV_NSEC_OFFSET
+	nop.i 123
+	;;
+	ld8 r18 =3D [r24]		// time_interpolator->offset
+	ld8 r8 =3D [r27],-IA64_TIMESPEC_TV_NSEC_OFFSET	// xtime.tv_nsec
+(p13)	sub r3 =3D r25,r2	// Diff needed before comparison (thanks davidm)
+	;;
+(p13)	cmp.gt.unc p6,p7 =3D r3,r0	// check if it is less than last. p6,p7 c=
leared
+	sub r10 =3D r2,r26	// current_counter - last_counter
+	;;
+(p6)	sub r10 =3D r25,r26	// time we got was less than last_cycle
+(p7)	mov ar.ccv =3D r25	// more than last_cycle. Prep for cmpxchg
+	;;
+	setf.sig f8 =3D r10
+	nop.i 123
+	;;
+(p7)	cmpxchg8.rel r3 =3D [r23],r2,ar.ccv
+EX(.fail_efault, probe.w.fault r31, 3)	// This takes 5 cycles and we have =
spare time
+	xmpy.l f8 =3D f8,f7	// nsec_per_cyc*(counter-last_counter)
+(p15)	add r9 =3D r9,r17		// Add wall to monotonic.secs to result secs
+	;;
+(p15)	ld8 r17 =3D [r19],-IA64_TIMESPEC_TV_NSEC_OFFSET
+(p7)	cmp.ne p7,p0 =3D r25,r3	// if cmpxchg not successful redo
+	// simulate tbit.nz.or p7,p0 =3D r28,0
+	and r28 =3D ~1,r28	// Make sequence even to force retry if odd
+	getf.sig r2 =3D f8
 	mf
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
+	add r8 =3D r8,r18		// Add time interpolator offset
 	;;
-
-(p8)	cmpxchg8.rel r24=3D[r25], r18, ar.ccv	// compare-and-exchange (atomic=
!)
-(p8)	add r3=3Dr29, r18			// r3 =3D (nsec + offset)
-	;;
-	shr.u r3=3Dr3, 3			// initiate dividing r3 by 1000
-	;;
-	setf.sig f8=3Dr3			//						(6 cyc)
-	mov r10=1000000			// r10 =3D 1000000
+	ld4 r10 =3D [r29]		// xtime_lock.sequence
+(p15)	add r8 =3D r8, r17	// Add monotonic.nsecs to nsecs
+	shr.u r2 =3D r2,r21
+	;;		// overloaded 3 bundles!
+	// End critical section.
+	add r8 =3D r8,r2		// Add xtime.nsecs
+	cmp4.ne.or p7,p0 =3D r28,r10
+(p7)	br.cond.dpnt.few .time_redo	// sequence number changed ?
+	// Now r8=3Dtv->tv_nsec and r9=3Dtv->tv_sec
+	mov r10 =3D r0
+	movl r2 =3D 1000000000
+	add r23 =3D IA64_TIMESPEC_TV_NSEC_OFFSET, r31
+(p14)	movl r3 =3D 2361183241434822607	// Prep for / 1000 hack
+	;;
+.time_normalize:
+	mov r21 =3D r8
+	cmp.ge p6,p0 =3D r8,r2
+(p14)	shr.u r20 =3D r8, 3		// We can repeat this if necessary just wasting=
 some time
+	;;
+(p14)	setf.sig f8 =3D r20
+(p6)	sub r8 =3D r8,r2
+(p6)	add r9 =3D 1,r9			// two nops before the branch.
+(p14)	setf.sig f7 =3D r3		// Chances for repeats are 1 in 10000 for gettod
+(p6)	br.cond.dpnt.few .time_normalize
+	;;
+	// Divided by 8 though shift. Now divide by 125
+	// The compiler was able to do that with a multiply
+	// and a shift and we do the same
+EX(.fail_efault, probe.w.fault r23, 3)		// This also costs 5 cycles
+(p14)	xmpy.hu f8 =3D f8, f7			// xmpy has 5 cycles latency so use it...
 	;;
-(p8)	cmp.ne.unc p9, p0=3Dr24, r14
-	xmpy.hu f6=F8, f9		//						(5 cyc)
-(p9)	br.spnt.many .retry
-	;;
-
-	getf.sig r3=F6			//						(6 cyc)
+	mov r8 =3D r0
+(p14)	getf.sig r2 =3D f8
 	;;
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
+(p14)	shr.u r21 =3D r2, 4
 	;;
-EX(.fail_efault, st8 [r9]=3Dr3)		// store them in the timeval struct
-	mov r10=3D0
+EX(.fail_efault, st8 [r31] =3D r9)
+EX(.fail_efault, st8 [r23] =3D r21)
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
 .fail_einval:
-	mov r8=3DEINVAL			// r8 =3D EINVAL
-	mov r10=3D-1			// r10 =3D -1
+	mov r8 =3D EINVAL
+	mov r10 =3D -1
 	FSYS_RETURN
-
 .fail_efault:
-	mov r8=EFAULT			// r8 =3D EFAULT
-	mov r10=3D-1			// r10 =3D -1
+	mov r8 =3D EFAULT
+	mov r10 =3D -1
 	FSYS_RETURN
 END(fsys_gettimeofday)

+ENTRY(fsys_clock_gettime)
+	.prologue
+	.altrp b6
+	.body
+	cmp4.lt p6, p0 =3D CLOCK_MONOTONIC, r32
+	// Fallback if this is not CLOCK_REALTIME or CLOCK_MONOTONIC
+(p6)	br.spnt.few fsys_fallback_syscall
+	mov r31 =3D r33
+	shl r30 =3D r32,15
+	br.many .gettime
+END(fsys_clock_gettime)
+
 /*
  * long fsys_rt_sigprocmask (int how, sigset_t *set, sigset_t *oset, size_=
t sigsetsize).
  */
@@ -838,7 +851,7 @@
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
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.7.orig/arch/ia64/kernel/time.c	2004-0=
6-15 22:19:01.000000000 -0700
+++ linux-2.6.7/arch/ia64/kernel/time.c	2004-07-29 12:08:56.000000000 -0700
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
@@ -127,51 +88,13 @@
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
-
-		/* someone else beat us to updating last_nsec_offset; try again */
-	}
+		offset =3D time_interpolator_get_offset();
+		sec =3D xtime.tv_sec;
+		nsec =3D xtime.tv_nsec;
+	} while (unlikely(read_seqretry(&xtime_lock, seq)));

 	usec =3D (nsec + offset) / 1000;

@@ -323,6 +246,18 @@
 	ia64_set_itm(local_cpu_data->itm_next);
 }

+static int nojitter;
+
+static int __init nojitter_setup(char *str)
+{
+	nojitter =3D 1;
+	printk("Jitter checking for ITC timers disabled\n");
+	return 1;
+}
+
+__setup("nojitter", nojitter_setup);
+
+
 void __devinit
 ia64_init_itm (void)
 {
@@ -385,7 +320,27 @@

 	if (!(sal_platform_features & IA64_SAL_PLATFORM_FEATURE_ITC_DRIFT)) {
 		itc_interpolator.frequency =3D local_cpu_data->itc_freq;
+		itc_interpolator.shift =3D 10;	/* accuracy ~200ns */
+		/* shift=16 yields a much better accuracy (~50ns) but runs
+		 * the risk of having the interpolator run too fast on some
+		 * systems
+		 */
 		itc_interpolator.drift =3D itc_drift;
+		itc_interpolator.source =3D TIME_SOURCE_CPU;
+#ifdef CONFIG_SMP
+		/* On IA64 in an SMP configuration ITCs are never accurately synchronize=
d.
+		 * Jitter compensation requires a cmpxchg which may limit
+		 * the scalability of the syscalls for retrieving time.
+		 * The ITC synchronization is usually successful to within a few
+		 * ITC ticks but this is not a sure thing. If you need to improve
+		 * timer performance in SMP situations then boot the kernel with the
+		 * "nojitter" option. However, doing so may result in time fluctuating (=
maybe
+		 * even going backward) if the ITC offsets between the individual CPUs
+		 * are too large.
+		 */
+		if (!nojitter) itc_interpolator.jitter =3D 1;
+#endif
+		itc_interpolator.addr =3D NULL;
 		register_time_interpolator(&itc_interpolator);
 	}

Index: linux-2.6.7/arch/ia64/sn/kernel/sn2/timer.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.7.orig/arch/ia64/sn/kernel/sn2/timer.=
c	2004-06-15 22:19:36.000000000 -0700
+++ linux-2.6.7/arch/ia64/sn/kernel/sn2/timer.c	2004-07-22 19:45:58.0000000=
00 -0700
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
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.7.orig/include/linux/timex.h	2004-06-=
15 22:18:56.000000000 -0700
+++ linux-2.6.7/include/linux/timex.h	2004-07-29 12:08:14.000000000 -0700
@@ -53,8 +53,10 @@

 #include <linux/config.h>
 #include <linux/compiler.h>
+#include <linux/jiffies.h>

 #include <asm/param.h>
+#include <asm/io.h>

 /*
  * The following defines establish the engineering parameters of the PLL
@@ -320,81 +322,130 @@

 #ifdef CONFIG_TIME_INTERPOLATION

-struct time_interpolator {
-	/* cache-hot stuff first: */
-	unsigned long (*get_offset) (void);
-	void (*update) (long);
-	void (*reset) (void);
+#define TIME_SOURCE_CPU 0
+#define TIME_SOURCE_MMIO64 1
+#define TIME_SOURCE_MMIO32 2
+#define TIME_SOURCE_FUNCTION 3
+
+/* For proper operations time_interpolator clocks must run slightly slower
+ * than the standard clock since the interpolator may only correct by havi=
ng
+ * time jump forward during a tick. A slower clock is usually a side effect
+ * of the integer divide of the nanoseconds in a second by the frequency.
+ * The accuracy of the division can be increased by specifying a shift.
+ * However, this may cause the clock not to be slow enough. If that is the
+ * case then either the scaling needs to be reduced or a lower frequency
+ * specified to slow down the interpolator.
+ * A too fast interpolator will result in a time_interpolator->offset
+ * that does not go back to zero once in a while. The interpolator
+ * clock will become the time source for the system and the
+ * logic for time adjustments in kernel/time.c will no longer work.
+ *
+ * Setting jitter compensates for a fluctuating timesource by comparing
+ * to the last value read from the timesource to insure that an earlier va=
lue
+ * is not returned by a later call.
+ * Some timesources may fluctuate which may result in the strange phenomen=
on that
+ * highly accurate timer calls seem to be stepping backward. The price to =
pay
+ * for the compensation is that the timer routines are not as scalable any=
more.
+ */

-	/* cache-cold stuff follows here: */
-	struct time_interpolator *next;
+struct time_interpolator {
+	unsigned short source;		/* time source flags */
+	unsigned char shift;		/* increases accuracy of multiply by shifting. */
+			/* Note that bits may be lost if shift is set too high */
+	unsigned char jitter;		/* if set compensate for fluctuations */
+	unsigned nsec_per_cyc;		/* set by register_time_interpolator() */
+	void *addr;			/* address of counter or function */
+	unsigned long offset;		/* nsec offset at last update of interpolator */
+	unsigned long last_counter;	/* counter value in units of the counter at l=
ast update */
+	unsigned long last_cycle;	/* Last timer value if TIME_SOURCE_JITTER is se=
t */
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
+time_interpolator_get_cycles(unsigned int src)
 {
-	struct time_interpolator *ti =3D time_interpolator;
+	unsigned long (*x)(void);

-	if (last_nsec_offset > 0) {
-#ifdef __HAVE_ARCH_CMPXCHG
-		unsigned long new, old;
+	switch (src)
+	{
+		case TIME_SOURCE_FUNCTION:
+			x =3D time_interpolator->addr;
+			return x();

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
+		case TIME_SOURCE_MMIO64	:
+			return readq(time_interpolator->addr);
+
+		case TIME_SOURCE_MMIO32	:
+			return readl(time_interpolator->addr);
+
+		default: return get_cycles();
 	}
+}
+
+static inline unsigned long
+time_interpolator_get_counter(void)
+{
+	unsigned int src =3D time_interpolator->source;

-	if (ti)
-		(*ti->update)(delta_nsec);
+	if (time_interpolator->jitter)
+	{
+		unsigned long lcycle;
+		unsigned long now;
+
+		do {
+			lcycle =3D time_interpolator->last_cycle;
+			now =3D time_interpolator_get_cycles(src);
+			if (lcycle && time_after(lcycle,now)) return lcycle;
+			/* Keep track of the last timer value returned. The use of cmpxchg here
+			 * will cause contention in an SMP environment.
+			 */
+		} while (unlikely(cmpxchg(&time_interpolator->last_cycle,lcycle,now) !=
=3D lcycle));
+		return now;
+	}
+	else
+		return time_interpolator_get_cycles(src);
 }

-/* Called with xtime WRITE-lock acquired.  */
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
+	time_interpolator->offset =3D 0;
+	time_interpolator->last_counter =3D time_interpolator_get_counter();
 }

-/* Called with xtime READ-lock acquired.  */
+#define GET_TI_NSECS(count,i) ((((count) - i->last_counter) * i->nsec_per_=
cyc) >> i->shift)
+
 static inline unsigned long
 time_interpolator_get_offset(void)
 {
-	struct time_interpolator *ti =3D time_interpolator;
-	if (ti)
-		return (*ti->get_offset)();
-	return last_nsec_offset;
+	return time_interpolator->offset +
+		GET_TI_NSECS(time_interpolator_get_counter(),time_interpolator);
+}
+
+static inline void time_interpolator_update(long delta_nsec)
+{
+	unsigned long counter=3Dtime_interpolator_get_counter();
+	unsigned long offset=3Dtime_interpolator->offset + GET_TI_NSECS(counter,t=
ime_interpolator);
+
+	/* The interpolator compensates for late ticks by accumulating
+         * the late time in interpolator_offset. A tick earlier than
+	 * expected will lead to a reset of the offset and a corresponding
+	 * jump of the clock forward. Again this only works if the
+	 * interpolator clock is running slightly slower than the regular clock.
+         */
+
+	if (delta_nsec < 0 || (unsigned long) delta_nsec < offset)
+		time_interpolator->offset =3D offset - delta_nsec;
+	else
+		time_interpolator->offset =3D 0;			/* Early tick. Resync */
+	time_interpolator->last_counter =3D counter;
 }

 #else /* !CONFIG_TIME_INTERPOLATION */
Index: linux-2.6.7/kernel/timer.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.7.orig/kernel/timer.c	2004-07-22 19:4=
0:09.000000000 -0700
+++ linux-2.6.7/kernel/timer.c	2004-07-22 19:45:58.000000000 -0700
@@ -1425,10 +1425,6 @@
 }

 #ifdef CONFIG_TIME_INTERPOLATION
-volatile unsigned long last_nsec_offset;
-#ifndef __HAVE_ARCH_CMPXCHG
-spinlock_t last_nsec_offset_lock =3D SPIN_LOCK_UNLOCKED;
-#endif

 struct time_interpolator *time_interpolator;
 static struct time_interpolator *time_interpolator_list;
@@ -1439,17 +1435,21 @@
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
@@ -1480,6 +1480,7 @@
 		for (curr =3D time_interpolator_list; curr; curr =3D curr->next)
 			if (is_better_time_interpolator(curr))
 				time_interpolator =3D curr;
+		time_interpolator_reset();
 	}
 	write_sequnlock_irq(&xtime_lock);
 	spin_unlock(&time_interpolator_lock);
Index: linux-2.6.7/arch/ia64/kernel/asm-offsets.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.7.orig/arch/ia64/kernel/asm-offsets.c=
	2004-06-15 22:20:03.000000000 -0700
+++ linux-2.6.7/arch/ia64/kernel/asm-offsets.c	2004-07-29 12:44:00.00000000=
0 -0700
@@ -187,14 +187,6 @@
 	DEFINE(IA64_CLONE_VFORK, CLONE_VFORK);
 	DEFINE(IA64_CLONE_VM, CLONE_VM);

-	BLANK();
-    /* used by fsys_gettimeofday in arch/ia64/kernel/fsys.S */
-	DEFINE(IA64_CPUINFO_ITM_DELTA_OFFSET, offsetof (struct cpuinfo_ia64, itm_=
delta));
-	DEFINE(IA64_CPUINFO_ITM_NEXT_OFFSET, offsetof (struct cpuinfo_ia64, itm_n=
ext));
-	DEFINE(IA64_CPUINFO_NSEC_PER_CYC_OFFSET, offsetof (struct cpuinfo_ia64, n=
sec_per_cyc));
-	DEFINE(IA64_TIMESPEC_TV_NSEC_OFFSET, offsetof (struct timespec, tv_nsec));
-
-
 	DEFINE(CLONE_IDLETASK_BIT, 12);
 #if CLONE_IDLETASK !=3D (1 << 12)
 # error "CLONE_IDLETASK_BIT incorrect, please fix"
@@ -207,5 +199,21 @@

 	BLANK();
 	DEFINE(IA64_MCA_TLB_INFO_SIZE, sizeof (struct ia64_mca_tlb_info));
+	/* used by head.S */
+	DEFINE(IA64_CPUINFO_NSEC_PER_CYC_OFFSET, offsetof (struct cpuinfo_ia64, n=
sec_per_cyc));

+	BLANK();
+	/* used by fsys_gettimeofday in arch/ia64/kernel/fsys.S */
+	DEFINE(IA64_TIME_INTERPOLATOR_ADDRESS_OFFSET, offsetof (struct time_inter=
polator, addr));
+	DEFINE(IA64_TIME_INTERPOLATOR_SOURCE_OFFSET, offsetof (struct time_interp=
olator, source));
+	DEFINE(IA64_TIME_INTERPOLATOR_SHIFT_OFFSET, offsetof (struct time_interpo=
lator, shift));
+	DEFINE(IA64_TIME_INTERPOLATOR_NSEC_OFFSET, offsetof (struct time_interpol=
ator, nsec_per_cyc));
+	DEFINE(IA64_TIME_INTERPOLATOR_OFFSET_OFFSET, offsetof (struct time_interp=
olator, offset));
+	DEFINE(IA64_TIME_INTERPOLATOR_LAST_CYCLE_OFFSET, offsetof (struct time_in=
terpolator, last_cycle));
+	DEFINE(IA64_TIME_INTERPOLATOR_LAST_COUNTER_OFFSET, offsetof (struct time_=
interpolator, last_counter));
+	DEFINE(IA64_TIME_INTERPOLATOR_JITTER_OFFSET, offsetof (struct time_interp=
olator, jitter));
+	DEFINE(IA64_TIME_SOURCE_CPU, TIME_SOURCE_CPU);
+	DEFINE(IA64_TIME_SOURCE_MMIO64, TIME_SOURCE_MMIO64);
+	DEFINE(IA64_TIME_SOURCE_MMIO32, TIME_SOURCE_MMIO32);
+	DEFINE(IA64_TIMESPEC_TV_NSEC_OFFSET, offsetof (struct timespec, tv_nsec));
 }
