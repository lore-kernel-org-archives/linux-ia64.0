From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 09 Jul 2004 22:58:03 +0000
Subject: Timer patches (nsec support + fastcalls for gettod/clock_gettime
Message-Id: <Pine.LNX.4.58.0407091545250.5720@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

The following patch is the first edition that is complete in that it
provides all existing functionality (fastcalls) and enhances various
interfaces:

1. Restructure timer interpolators to extract common code and provide a
structure that can be used from assembly language.
2. Remove cmpxchg that causes scalability problems (for all clocks
including ITC now)

3. Simplify gettimeofday

4. Provide new fastcall gettimeofday suitable for all types of clock
(including cyclone and SN2 RTC). More than factor 10 speed gain on
machines that did not use ITC clock before.

5. Provide fastcall path for clock_gettime(CLOCK_REALTIME). Also for all
clock times. More than a factor 20 gain on this one since it returns
nanoseconds resolution and thereby avoids the multiplications / division
and the syscall overhead.

6. nanosecond resolution for CLOCK_REALTIME and CLOCK_MONOTONIC. This
yield a 40ns resolution on SN2.

Todo:
- Test with cyclone machines
- Test with machines that only have ITC based clocks.

Testind and feedback appreciated.

Output of the clocks test program (SN2 system. ITC not synchronized and
therefore neither the process/thread clocks. Has to be that way according
to glibc folks):

revenue2:~/noship-tests # ./clocks
Delta time from previous cpu
CPU     GETTOD  REALTIME   PROCESS    THREAD               ITC
  1:       1000       417  -18065328  -18065589         -18064835
  2:          0       519  39365896  39365886          39365460
  3:       1000       363  -18067346  -18067344         -18067280
  4:          0       593  -9277516  -9277518          -9277814
  5:       1000       379  -6148914691254583914  -6148914691254583917      =
   -18066830
  6:          0       603  6148914691258187681  6148914691258187684        =
  21670340
  7:       1000       424  -6148914691254582101  -6148914691254582099      =
   -18064835
  8:          0       643  -1988431  -1988433          -1988340
  9:       1000       411  -18065446  -18065446         -18065445
 10:          0       584  6148914691262149499  6148914691262149500        =
  25632170
 11:       1000       390  -6148914691254583467  -6148914691254583466      =
   -18066210
 12:          0       651  12032205  12032204          12032255
 13:       1000       429  -18064707  -18064708         -18064690
 14:          0       579  -11312545  -11312544         -11312674
 15:       1000       439  -18064285  -18064286         -18064240
 16:          0       680  6148914691356982236  6148914691356982236        =
 120464985
 17:       1000       440  -18064275  -18064275         -18064310
 18:       1000       627  -3029222  -3029222          -3029294
 19:          0       413  -18065866  -18065865         -18064565
 20:       1000       668  -20376600  -20376601         -20377230
 21:          0       404  -6148914691254582876  -6148914691254582874      =
   -18065020
 22:       1000       644  6148914691265177821  6148914691265177819        =
  28660050
 23:          0       398  -18065901  -18065899         -18065355
 24:       1000       704  -6148914691247420150  -6148914691247420151      =
   -10903584
 25:     952000    952172  -18061422  -18061426         -18062380
 26:       1000       630  6148914691276084448  6148914691276084451        =
  39567320
 27:          0       410  -6148914691254582783  -6148914691254582783      =
   -18065395
 28:       1000       687  -13289477  -13289476         -13289284
 29:          0       441  -18064254  -18064255         -18064310
 30:       1000       619  -9980610  -9980614          -9980730

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
+	.source =3D TIME_SOURCE_MEM32,
+	.shift =3D 32,
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
+	cyclone_interpolator.addr=3Dcyclone_timer;
 	register_time_interpolator(&cyclone_interpolator);

 	return 0;
Index: linux-2.6.7/arch/ia64/kernel/fsys.S
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.7.orig/arch/ia64/kernel/fsys.S
+++ linux-2.6.7/arch/ia64/kernel/fsys.S
@@ -143,186 +143,177 @@
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
+#define FASTCALL_DEBUG
 ENTRY(fsys_gettimeofday)
+	// Register map
+	// r1 =3D used to check for pending work in initialization / time_interpo=
lator_last_counter address
+	// r2 =3D scratch / sequence number of seqlock
+	// r3 =3D scratch / nsec result
+	// r4 =3D scratch / sec result
+	// r5 =3D scratch / time interpolator address
+	// r6 =3D scratch / time interpolator first quad with sourcetype, shift, =
nsec_per_cyc
+	// r7 =3D points to nsec portion of argument (r32+8)
+	// r8 =3D time_interpolator_offset address
+	// r9 =3D time interpolator address
+	// r10 =3D address of seqlock
+	// r12 =3D debug address
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
+	add r1=3DTI_FLAGS+IA64_TASK_SIZE,r16
+	tnat.nz p1,p0=3Dr32               // guard against NaT args
+(p1)    br.cond.spnt.few .fail_einval
+	;;
+	ld4 r1=3D[r1]
+	movl r10=3Dxtime_lock
+	;;
+	tnat.nz p1,p0=3Dr33
+	movl r9=3Dtime_interpolator
+	;;
+	ld8 r9=3D[r9]
+	movl r4 =3D 2361183241434822607	// Prep for / 1000 hack
+	;;
+	and r1=3DTIF_ALLWORK_MASK,r1
+	setf.sig f9 =3D r4		// f9 is used to simulate multiplication by division
+(p1)    br.cond.spnt.few .fail_einval
+	;;
+	add r7=3D8,r32
+	cmp.ne p1, p0=3D0, r1		// Fallback if work is scheduled
+(p1)    br.spnt.many fsys_fallback_syscall
+	;;
+        /*
+         * Verify that we have permission to write to struct timeval.  Not=
e:
+         * Another thread might unmap the mapping before we actually get
+         * to store the result.  That's OK as long as the stores are also
+         * protect by EX().
+         */
+EX(.fail_efault, probe.w.fault r32, 3)          // this must come _after_ =
NaT-check
+EX(.fail_efault, probe.w.fault r7, 3)          // this must come _after_ N=
aT-check
+        nop 0
+	;;
+	movl r1=3Dtime_interpolator_last_counter
+	;;
+	movl r8=3Dtime_interpolator_offset
+	;;
+#ifdef FASTCALL_DEBUG
+        movl r12=FAstcall_debug
+        ;;
+        ld8 r2=3D[r12]
+        ;;
+        cmp.ne p1, p0 =3D r0, r2                  // If debug information =
has already been written
+(p1)    br.spnt.many fsys_fallback_syscall      // then fall back instead =
of doing a fastcall
+        ;;
+        st8 [r12]=3Dr12,8
+        ;;
 #endif
-	ld4 r9=3D[r9]
-	movl r17=3Dxtime_lock
+.timeofday_retry:
+	ld4 r2 =3D [r10]		//  xtime_lock.sequence
+	mf
+	ld8 r6 =3D [r9],8		// time_interpolator->source/shift/nsec_per_cyc
 	;;
-
-	// r32, r33 should contain the 2 args of gettimeofday
-	adds r21=3DIA64_CPUINFO_ITM_NEXT_OFFSET, r10
-	mov r2=3D-1
-	tnat.nz p6,p7=3Dr32		// guard against NaT args
+	extr r3 =3D  r6,0,16
+	ld8 r5 =3D [r9],-8	// time_interpolator->address
 	;;
-
-	adds r10=3DIA64_CPUINFO_ITM_DELTA_OFFSET, r10
-(p7)	tnat.nz p6,p0=3Dr33
-(p6)	br.cond.spnt.few .fail_einval
-
-	adds r8=3DIA64_CPUINFO_NSEC_PER_CYC_OFFSET, r3
-	movl r24#61183241434822607	// for division hack (only for / 1000)
+	cmp4.eq p1, p0 =3D 0, r3
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
+	cmp4.eq p2, p0 =3D 1, r3
+	cmp4.eq p3, p0 =3D 2, r3
+(p1)	mov r3 =3D ar44		// CPU_TIMER
 	;;
-.retry:	// *** seq =3D read_seqbegin(&xtime_lock); ***
-	ld4.acq r23=3D[r17]		// since &xtime_lock =3D &xtime_lock->sequence
-	ld8 r14=3D[r25]			// r14 (old) =3D last_nsec_offset
-
-	ld8 r28=3D[r26]			// r28 =3D jiffies
-	ld8 r29=3D[r27]			// r29 =3D wall_jiffies
+	cmp4.lt p4, p0 =3D 2, r3
+(p2)	ld8 r3 =3D [r5]		// readq
+	ld8 r4 =3D [r1]		// time_interpolator_last_counter
 	;;
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
+(p3)	ld4 r3 =3D [r5]		// readw
+(p4)	br.spnt.many fsys_fallback_syscall
+	;;
+	sub r3 =3D r3, r4
+	extr r4 =3D r6,32,32		// time_interpolator->nsec_per_cyc
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
+#ifdef FASTCALL_DEBUG
+        st8 [r12]=3Dr3,8           // clock_diff
 	;;
-
-	mov r31=3Dar.itc			// re-read ITC in case we .retry		(35 cyc)
-	xma.l f8=F11, f8, f12	// f8 (elapsed_cycles) <- (-1*last_tick + now) =3D =
(now - last_tick)
-	nop 0
+#endif
+	setf.sig f8 =3D r3
+	setf.sig f10 =3D r4
 	;;
-
-	getf.sig r18=F8			// r18 <- (now - last_tick)
-	xmpy.l f8=F8, f10		// f8 <- elapsed_cycles*nsec_per_cyc (5 cyc)
-	add r3=3Dr29, r14			// r3 =3D (nsec + old)
+	xmpy.l f8 =3D f8,f10	// nsec_per_cyc*(timeval-last_counter)
+	extr r4 =3D r6,16,16	// time_interpolator->shift
+	getf.sig r3 =3D f8
 	;;
-
-	cmp.lt p7, p8=3Dr18, r0		// if now < last_tick, set p7 =3D 1, p8 =3D 0
-	getf.sig r18=F8			// r18 =3D elapsed_cycles*nsec_per_cyc		(6 cyc)
-	nop 0
+	shr.u r3 =3D r3,r4
 	;;
-
-(p10)	cmp.ne p9, p0=3Dr23, r24		// if xtime_lock->sequence !=3D seq, set p9
-	shr.u r18=3Dr18, IA64_NSEC_PER_CYC_SHIFT	// r18 <- offset
-(p9)	br.spnt.many .retry
+#ifdef FASTCALL_DEBUG
+        st8 [r12]=3Dr3,8           // nsec_diff
 	;;
-
-	mov ar.ccv=3Dr14			// ar.ccv =3D old					(1 cyc)
-	cmp.leu p7, p8=3Dr18, r14		// if (offset <=3D old), set p7 =3D 1, p8 =3D 0
+#endif
+	ld8 r4 =3D [r8]		// time_interpolator_offset
+	movl r5=3Dxtime
 	;;
-
-(p8)	cmpxchg8.rel r24=3D[r25], r18, ar.ccv	// compare-and-exchange (atomic=
!)
-(p8)	add r3=3Dr29, r18			// r3 =3D (nsec + offset)
+#ifdef FASTCALL_DEBUG
+        st8 [r12]=3Dr4,8           // time interpolator offset
 	;;
-	shr.u r3=3Dr3, 3			// initiate dividing r3 by 1000
+#endif
+	add r3 =3D r3,r4
+ 	ld8 r4 =3D [r5],8		// xtime.tv_sec
 	;;
-	setf.sig f8=3Dr3			//						(6 cyc)
-	mov r10=1000000			// r10 =3D 1000000
+	ld8 r5 =3D [r5]		// xtime_tv_nsec
 	;;
-(p8)	cmp.ne.unc p9, p0=3Dr24, r14
-	xmpy.hu f6=F8, f9		//						(5 cyc)
-(p9)	br.spnt.many .retry
+#ifdef FASTCALL_DEBUG
+        st8 [r12]=3Dr4,8           // xtime. sec
+        ;;
+        st8 [r12]=3Dr5,8           // xtime. nsec
 	;;
+#endif

-	getf.sig r3=F6			//						(6 cyc)
+	add r3 =3D r3,r5
+	mf
+	ld8 r5 =3D [r10]		// xtime_lock.sequence
 	;;
-	shr.u r3=3Dr3, 4			// end of division, r3 is divided by 1000 (=3Dusec)
+	cmp4.ne p1,p0 =3D r5,r2
+(p1)	br.cond.dpnt .timeofday_retry
+	;;
+	//  now r3=3Dtv->tv_nsec and r4=3Dtv->tv_sec
+	movl r2 =3D 1000000000
+	;;
+.timeofday_checkagain:
+	cmp.gt p1,p0 =3D r3,r2
+	;;
+(p1)	sub r3 =3D r3,r2
+(p1)	add r4 =3D 1,r4
+(p1)	br.cond.dpnt .timeofday_checkagain
+	;;
+	// now r3,r4 contains the normalized time
+EX(.fail_efault, st8 [r32]=3Dr4)			// tv->tv_sec =3D seconds
+	;;
+#ifdef FASTCALL_DEBUG
+        st8 [r12]=3Dr4,8
+        ;;
+        st8 [r12]=3Dr3,8
 	;;
+#endif

-1:	cmp.geu p7, p0=3Dr3, r10		// while (usec >=3D 1000000)
+	// The only thing left to do is to divide nsecs in r3 by 1000. sigh
+	shr.u r3 =3D r3, 3
 	;;
-(p7)	sub r3=3Dr3, r10			// usec -=3D 1000000
-(p7)	adds r2=3D1, r2			// ++sec
-(p7)	br.spnt.many 1b
-
-	// finally: r2 =3D sec, r3 =3D usec
-EX(.fail_efault, st8 [r32]=3Dr2)
-	adds r9=3D8, r32
-	mov r8=3Dr0			// success
+	// Ok. divided by 8 so the only thing left is to divide by 125
+	// Seems that the compiler was able to do that with a multiply
+	// and a shift
+	setf.sig f8 =3D r3
+	;;
+	xmpy.hu f8 =3D f8, f9
+	getf.sig r3 =3D f8
+	;;
+	shr.u r3 =3D r3, 4
+	;;
+EX(.fail_efault, st8 [r7]=3Dr3)
+#ifdef FASTCALL_DEBUG
+        st8 [r12]=3Dr3,8
 	;;
-EX(.fail_efault, st8 [r9]=3Dr3)		// store them in the timeval struct
-	mov r10=3D0
+#endif
+	mov r8=3Dr0
+	mov r10=3Dr0
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
 	mov r8=3DEINVAL			// r8 =3D EINVAL
 	mov r10=3D-1			// r10 =3D -1
@@ -334,6 +325,110 @@
 	FSYS_RETURN
 END(fsys_gettimeofday)

+ENTRY(fsys_clock_gettime)
+	.prologue
+	.altrp b6
+	.body
+	add r9=3DTI_FLAGS+IA64_TASK_SIZE,r16
+	tnat.nz p1,p0=3Dr32               // guard against NaT args
+(p1)    br.cond.spnt.few .fail_einval
+	;;
+	movl r10=3Dxtime_lock
+	;;
+	ld4 r9=3D[r9]
+	tnat.nz p1,p0=3Dr33
+(p1)    br.cond.spnt.few .fail_einval
+	;;
+	and r9=3DTIF_ALLWORK_MASK,r9
+	add r7=3D8,r33
+	;;
+	cmp.ne p1, p0=3D0, r9		// Fallback if work is scheduled
+(p1)    br.spnt.many fsys_fallback_syscall
+	;;
+	cmp.ne p1, p0=3D0, r32		// Fallback if this is not CLOCK_REALTIME
+(p1)	br.spnt.many fsys_fallback_syscall
+        /*
+         * Verify that we have permission to write to struct timespec.  No=
te:
+         * Another thread might unmap the mapping before we actually get
+         * to store the result.  That's OK as long as the stores are also
+         * protect by EX().
+         */
+EX(.fail_efault, probe.w.fault r33, 3)          // this must come _after_ =
NaT-check
+EX(.fail_efault, probe.w.fault r7, 3)          // this must come _after_ N=
aT-check
+        nop 0
+
+.gettime_retry:
+	ld4 r2 =3D [r10]		//  xtime_lock.sequence
+	movl r3=3Dtime_interpolator
+	;;
+	mf
+	ld8 r3=3D[r3]
+	;;
+	ld8 r6 =3D [r3],8		// time_interpolator->source/shift/nsec_per_cyc
+	;;
+	ld8 r5 =3D [r3]		// time_interpolator->address
+	extr r3 =3D  r6,0,16
+	;;
+	cmp4.eq p1, p0 =3D 0, r3
+	movl r4=3Dtime_interpolator_last_counter
+	;;
+	cmp4.eq p2, p0 =3D 1, r3
+	cmp4.eq p3, p0 =3D 2, r3
+(p1)	mov r3 =3D ar44		// CPU_TIMER
+	;;
+	cmp4.lt p4, p0 =3D 2, r3
+(p2)	ld8 r3 =3D [r5]		// readq
+	ld8 r4 =3D [r4]		// time_interpolator_last_counter
+	;;
+(p3)	ld4 r3 =3D [r5]		// readw
+(p4)	br.spnt.many fsys_fallback_syscall
+	;;
+	sub r3 =3D r3, r4
+	extr r4 =3D r6,32,32		// time_interpolator->nsec_per_cyc
+	;;
+	setf.sig f8 =3D r3
+	setf.sig f9 =3D r4
+	;;
+	xmpy.l f8 =3D f8,f9	// nsec_per_cyc*(timeval-last_counter)
+	extr r4 =3D r6,16,16	// time_interpolator->shift
+	getf.sig r3 =3D f8
+	;;
+	shr.u r3 =3D r3,r4
+	movl r4 =3D time_interpolator_offset
+	;;
+	ld8 r4 =3D [r4]		// time_interpolator_offset
+	movl r5=3Dxtime
+	;;
+	add r3 =3D r3,r4
+ 	ld8 r4 =3D [r5],8		// xtime.tv_sec
+	;;
+	ld8 r5 =3D [r5]		// xtime_tv_nsec
+	;;
+	add r3 =3D r3,r5
+	mf
+	ld8 r5 =3D [r10]		// xtime_lock.sequence
+	;;
+	cmp4.ne p1,p0 =3D r5,r2
+(p1)	br.cond.dpnt .gettime_retry
+	;;
+	//  now r3=3Dtv->tv_nsec and r4=3Dtv->tv_sec
+	movl r2 =3D 1000000000
+	;;
+.gettime_checkagain:
+	cmp.gt p1,p0 =3D r3,r2
+	;;
+(p1)	sub r3 =3D r3,r2
+(p1)	add r4 =3D 1,r4
+(p1)	br.cond.dpnt .gettime_checkagain
+	;;
+	// now r3,r4 contain the normalized time
+EX(.fail_efault, st8 [r33] =3D r4)		// tv->tv_sec =3D seconds
+EX(.fail_efault, st8 [r7] =3D r3)			// tv->tv_nsec =3D nanosecs
+	mov r8=3Dr0
+	mov r10=3Dr0
+	FSYS_RETURN
+END(fsys_gettime)
+
 /*
  * long fsys_rt_sigprocmask (int how, sigset_t *set, sigset_t *oset, size_=
t sigsetsize).
  */
@@ -839,7 +934,7 @@
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
@@ -123,57 +84,36 @@
 }

 EXPORT_SYMBOL(do_settimeofday);
+#define DEBUG_FASTCALL
+
+#ifdef DEBUG_FASTCALL
+struct {
+	unsigned long off;
+	unsigned long x1;
+	unsigned long x2;
+	unsigned long x3;
+	unsigned long x4;
+	unsigned long x5;
+	unsigned long x6;
+	unsigned long x7;
+	unsigned long x8;
+	unsigned long x9;
+	unsigned long x10;
+} fastcall_debug;
+#endif

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

-	usec =3D (nsec + offset) / 1000;
+       	usec =3D (nsec + offset) / 1000;

 	while (unlikely(usec >=3D USEC_PER_SEC)) {
 		usec -=3D USEC_PER_SEC;
@@ -182,6 +122,18 @@

 	tv->tv_sec =3D sec;
 	tv->tv_usec =3D usec;
+
+#ifdef DEBUG_FASTCALL
+	if (fastcall_debug.off)
+	{
+		printk("fastcall_debug clock_diff=3D%lu,nsec_diff=3D%lu ti_offs=3D%lu xt=
.sec=3D%lu xt.nsec=3D%lu t.sec=3D%lu t.nsec=3D%lu r.usec=3D%lu x9=3D%lu\n",
+		fastcall_debug.x1,fastcall_debug.x2,fastcall_debug.x3,fastcall_debug.x4,
+		fastcall_debug.x5,fastcall_debug.x6,fastcall_debug.x7,fastcall_debug.x8,
+		fastcall_debug.x9);
+		printk("c-gettimeofday result sec=3D%lu nsec=3D%lu\n",sec,usec);
+		memset(&fastcall_debug,0,sizeof(fastcall_debug));
+	}
+#endif
 }

 EXPORT_SYMBOL(do_gettimeofday);
@@ -385,7 +337,10 @@

 	if (!(sal_platform_features & IA64_SAL_PLATFORM_FEATURE_ITC_DRIFT)) {
 		itc_interpolator.frequency =3D local_cpu_data->itc_freq;
+		itc_interpolator.shift=3D5;
 		itc_interpolator.drift =3D itc_drift;
+		itc_interpolator.source=3D TIME_SOURCE_CPU;
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
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.7.orig/include/linux/timex.h
+++ linux-2.6.7/include/linux/timex.h
@@ -55,6 +55,7 @@
 #include <linux/compiler.h>

 #include <asm/param.h>
+#include <asm/io.h>

 /*
  * The following defines establish the engineering parameters of the PLL
@@ -320,92 +321,107 @@

 #ifdef CONFIG_TIME_INTERPOLATION

-struct time_interpolator {
-	/* cache-hot stuff first: */
-	unsigned long (*get_offset) (void);
-	void (*update) (long);
-	void (*reset) (void);
+#ifdef CPU_TIMER
+#define TIME_SOURCE_CPU 0
+#endif
+#define TIME_SOURCE_MEM64 1
+#define TIME_SOURCE_MEM32 2
+#define TIME_SOURCE_FUNCTION 3

-	/* cache-cold stuff follows here: */
-	struct time_interpolator *next;
+struct time_interpolator {
+	unsigned short source;		/* the type of time source */
+	unsigned short shift;		/* Increases accuracy by shifting. Note that bits =
may be lost if this is set too high */
+	unsigned nsec_per_cyc;		/* calculated by register_time_interpolator */
+	void *addr;			/* Address if this is a counter with a memory address or fu=
nction */
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
+	switch (time_interpolator->source)
+	{
+		case TIME_SOURCE_FUNCTION:
+			x=3Dtime_interpolator->addr;
+			return x();
+
+		case TIME_SOURCE_MEM64	: return readq(time_interpolator->addr);
+		case TIME_SOURCE_MEM32	: return readl(time_interpolator->addr);
+#ifdef CPU_TIMER
+		default: return CPU_TIMER;
 #else
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
+		default: return 0;
 #endif
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
+	time_interpolator_offset=3D0;
+	time_interpolator_last_counter=3Dtime_interpolator_get_counter();
 }

-/* Called with xtime READ-lock acquired.  */
 static inline unsigned long
 time_interpolator_get_offset(void)
 {
-	struct time_interpolator *ti =3D time_interpolator;
-	if (ti)
-		return (*ti->get_offset)();
-	return last_nsec_offset;
+	return time_interpolator_offset+
+		(
+			((time_interpolator_get_counter()-time_interpolator_last_counter)*time_=
interpolator->nsec_per_cyc)
+			>>time_interpolator->shift
+		);
+}
+
+static inline void time_interpolator_update(long delta_nsec)
+{
+	unsigned long counter=3Dtime_interpolator_get_counter();
+	unsigned long offset=3Dtime_interpolator_offset + (((counter-time_interpo=
lator_last_counter)*time_interpolator->nsec_per_cyc)>>time_interpolator->sh=
ift);
+
+	/* Traditional mysterious code piece for time interpolators.
+	   If the correction forward would result in a negative offset then the o=
ffset is reset to zero
+	   thereby providing a means for synchronization. This will occur because
+	     1. The scaling factor has been calculated in such a way as
+		to insure that the time interpolator runs SLOWER than real time.
+		Timer interrupts on time will therefore reset the time interpolator in r=
egular
+		intervals. A late timer interrupt will leave the offset running.
+		(this may lead to a minimal time jump forward before a tick but insures
+		that time never goes backward)
+	     2. warp_clock and leap seconds since the delta_nsec specified
+		in these situations is far too large.
+	     3. After the interpolator initialization when the first call to time=
_interpolator_update
+		by the timer code occurs which will invariably specify a delta that is t=
oo large.
+	*/
+	if (delta_nsec < 0 || (unsigned long) delta_nsec < offset)
+		time_interpolator_offset =3D offset - delta_nsec;
+	else
+		time_interpolator_offset =3D 0;
+	time_interpolator_last_counter=3Dcounter;
 }

 #else /* !CONFIG_TIME_INTERPOLATION */

 static inline void
-time_interpolator_update(long delta_nsec)
+time_interpolator_reset(void)
 {
 }

 static inline void
-time_interpolator_reset(void)
+time_interpolator_update(long delta_nsec)
 {
 }

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
@@ -1426,14 +1425,12 @@
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
@@ -1447,10 +1444,18 @@
 void
 register_time_interpolator(struct time_interpolator *ti)
 {
+	/* Must not round up. The interpolator update code relies on offsets
+	   being calculated too short so that a resync can take place once in a w=
hile
+	   ti->nsec_per_cyc=3D((NSEC_PER_SEC<<ti->shift)+ti->frequency/2)/ti->fre=
quency;
+	*/
+	ti->nsec_per_cyc=3D(NSEC_PER_SEC<<ti->shift)/ti->frequency;
 	spin_lock(&time_interpolator_lock);
 	write_seqlock_irq(&xtime_lock);
 	if (is_better_time_interpolator(ti))
+	{
 		time_interpolator =3D ti;
+		time_interpolator_reset();
+	}
 	write_sequnlock_irq(&xtime_lock);

 	ti->next =3D time_interpolator_list;
@@ -1481,6 +1486,7 @@
 		for (curr =3D time_interpolator_list; curr; curr =3D curr->next)
 			if (is_better_time_interpolator(curr))
 				time_interpolator =3D curr;
+		time_interpolator_reset();
 	}
 	write_sequnlock_irq(&xtime_lock);
 	spin_unlock(&time_interpolator_lock);
Index: linux-2.6.7/kernel/posix-timers.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.7.orig/kernel/posix-timers.c
+++ linux-2.6.7/kernel/posix-timers.c
@@ -1015,15 +1015,10 @@
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

@@ -1039,24 +1034,16 @@
 	struct timespec *tp, struct timespec *mo)
 {
 	u64 jiff;
-	struct timeval tpv;
 	unsigned int seq;

 	do {
 		seq =3D read_seqbegin(&xtime_lock);
-		do_gettimeofday(&tpv);
+		getnstimeofday(mo);
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

Index: linux-2.6.7/include/asm-ia64/timex.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.7.orig/include/asm-ia64/timex.h
+++ linux-2.6.7/include/asm-ia64/timex.h
@@ -8,6 +8,7 @@
 /*
  * 2001/01/18 davidm	Removed CLOCK_TICK_RATE.  It makes no sense on IA-64.
  *			Also removed cacheflush_time as it's entirely unused.
+ * 2004/07/03 clameter	Define CPU_TIMER
  */

 #include <asm/intrinsics.h>
@@ -27,6 +28,7 @@
  * 100MHz.
  */
 #define CLOCK_TICK_RATE		(HZ * 100000UL)
+#define CPU_TIMER ia64_getreg(_IA64_REG_AR_ITC)

 static inline cycles_t
 get_cycles (void)
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
@@ -421,6 +421,51 @@

 EXPORT_SYMBOL(current_kernel_time);

+#ifdef TIME_INTERPOLATION
+void getnstimeofday (struct timespec *tv)
+{
+        unsigned long seq;
+
+        do {
+                seq =3D read_seqbegin(&xtime_lock);
+                tv->tv_sec =3D xtime.tv_sec;
+                tv->tv_nsec =3D xtime.tv_nsec+time_interpolator_get_offset=
();
+        } while (unlikely(read_seqretry(&xtime_lock, seq)));
+
+        while (unlikely(tv->tv_nsec >=3D NSEC_PER_SEC)) {
+                tv->tv_nsec -=3D NSEC_PER_SEC;
+                ++tv->tv_sec;
+        }
+}
+
+#if 0
+void do_gettimeofday(struct timeval *x)
+{
+	struct timespec tv;
+	getnstimeofday(&ns);
+	x->tv_sec=3Dtv.tv_sec;
+	x->tv_usec=3D(tv.tv_nsec+NSEC_PER_USEC/2)/ NSEC_PER_USEC;
+}
+#endif
+
+EXPORT_SYMBOL(do_gettimeofday);
+
+#else
+/*
+ * Simulate getnstimeofday using gettimeofday. This will only yield usec a=
ccuracy
+ */
+void getnstimeofday(struct timespec *tv)
+{
+	struct timeval x;
+
+	do_gettimeofday(&x);
+	tv->tv_sec =3D x.tv_sec;
+	tv->tv_nsec =3D x.tv_usec*NSEC_PER_USEC;
+}
+
+EXPORT_SYMBOL(getnstimeofday);
+#endif
+
 #if (BITS_PER_LONG < 64)
 u64 get_jiffies_64(void)
 {
