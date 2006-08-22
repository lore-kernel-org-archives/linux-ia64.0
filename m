From: Al Stone <ahs3@fc.hp.com>
Date: Tue, 22 Aug 2006 23:08:01 +0000
Subject: [PATCH] 80-column reformatting for fsys.S
Message-Id: <1156288081.7332.15.camel@fcboson.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Simple reformatting to clean up fsys.S and make it comply with
Linux CodingStyle.

Signed-off-by: Al Stone <ahs3@fc.hp.com>


diff --git a/arch/ia64/kernel/fsys.S b/arch/ia64/kernel/fsys.S
index 7a05b1c..2bf90a8 100644
--- a/arch/ia64/kernel/fsys.S
+++ b/arch/ia64/kernel/fsys.S
@@ -6,10 +6,11 @@
  *
  * 25-Sep-03 davidm	Implement fsys_rt_sigprocmask().
  * 18-Feb-03 louisk	Implement fsys_gettimeofday().
- * 28-Feb-03 davidm	Fixed several bugs in fsys_gettimeofday().  Tuned it s=
ome more,
- *			probably broke it along the way... ;-)
- * 13-Jul-04 clameter   Implement fsys_clock_gettime and revise fsys_getti=
meofday to make
- *                      it capable of using memory based clocks without fa=
lling back to C code.
+ * 28-Feb-03 davidm	Fixed several bugs in fsys_gettimeofday().  Tuned it
+ *			some more, probably broke it along the way... ;-)
+ * 13-Jul-04 clameter   Implement fsys_clock_gettime and revise=20
+ *			fsys_gettimeofday to make it capable of using memory
+ *			based clocks without falling back to C code.
  */
=20
 #include <asm/asmmacro.h>
@@ -83,31 +84,34 @@ ENTRY(fsys_getppid)
 	;;
=20
 	ld4 r9=3D[r9]
-	add r17=3DIA64_TASK_REAL_PARENT_OFFSET,r17 // r17 =3D &current->group_lea=
der->real_parent
+	// r17 =3D &current->group_leader->real_parent
+	add r17=3DIA64_TASK_REAL_PARENT_OFFSET,r17
 	;;
 	and r9=3DTIF_ALLWORK_MASK,r9
=20
-1:	ld8 r18=3D[r17]				// r18 =3D current->group_leader->real_parent
+1:	ld8 r18=3D[r17]		// r18 =3D current->group_leader->real_parent
 	;;
 	cmp.ne p8,p0=3D0,r9
-	add r8=3DIA64_TASK_TGID_OFFSET,r18	// r8 =3D &current->group_leader->real=
_parent->tgid
+	// r8 =3D &current->group_leader->real_parent->tgid
+	add r8=3DIA64_TASK_TGID_OFFSET,r18
 	;;
=20
 	/*
-	 * The .acq is needed to ensure that the read of tgid has returned its da=
ta before
-	 * we re-check "real_parent".
+	 * The .acq is needed to ensure that the read of tgid has returned
+	 * its data before we re-check "real_parent".
 	 */
-	ld4.acq r8=3D[r8]				// r8 =3D current->group_leader->real_parent->tgid
+	ld4.acq r8=3D[r8]	    // r8 =3D current->group_leader->real_parent->tgid
 #ifdef CONFIG_SMP
 	/*
 	 * Re-read current->group_leader->real_parent.
 	 */
-	ld8 r19=3D[r17]				// r19 =3D current->group_leader->real_parent
+	ld8 r19=3D[r17]		// r19 =3D current->group_leader->real_parent
 (p8)	br.spnt.many fsys_fallback_syscall
 	;;
-	cmp.ne p6,p0=3Dr18,r19			// did real_parent change?
+	cmp.ne p6,p0=3Dr18,r19		// did real_parent change?
 	mov r19=3D0			// i must not leak kernel bits...
-(p6)	br.cond.spnt.few 1b			// yes -> redo the read of tgid and the check
+(p6)	br.cond.spnt.few 1b		// yes -> redo the read of tgid and
+					//   the check
 	;;
 	mov r17=3D0			// i must not leak kernel bits...
 	mov r18=3D0			// i must not leak kernel bits...
@@ -148,8 +152,10 @@ END(fsys_set_tid_address)
 /*
  * Ensure that the time interpolator structure is compatible with the asm =
code
  */
-#if IA64_TIME_INTERPOLATOR_SOURCE_OFFSET !=3D0 || IA64_TIME_INTERPOLATOR_S=
HIFT_OFFSET !=3D 2 \
-	|| IA64_TIME_INTERPOLATOR_JITTER_OFFSET !=3D 3 || IA64_TIME_INTERPOLATOR_=
NSEC_OFFSET !=3D 4
+#if IA64_TIME_INTERPOLATOR_SOURCE_OFFSET !=3D0 || \
+    IA64_TIME_INTERPOLATOR_SHIFT_OFFSET !=3D 2 || \
+    IA64_TIME_INTERPOLATOR_JITTER_OFFSET !=3D 3 || \
+    IA64_TIME_INTERPOLATOR_NSEC_OFFSET !=3D 4
 #error fsys_gettimeofday incompatible with changes to struct time_interpol=
ator
 #endif
 #define CLOCK_REALTIME 0
@@ -183,7 +189,8 @@ (p6)    br.cond.spnt.few .fail_einval
 	// r17 =3D wall to monotonic use
 	// r18 =3D time_interpolator->offset
 	// r19 =3D address of wall_to_monotonic
-	// r20 =3D pointer to struct time_interpolator / pointer to time_interpol=
ator->address
+	// r20 =3D pointer to struct time_interpolator /=20
+	//       pointer to time_interpolator->address
 	// r21 =3D shift factor
 	// r22 =3D address of time interpolator->last_counter
 	// r23 =3D address of time_interpolator->last_cycle
@@ -206,10 +213,11 @@ (p6)    br.cond.spnt.few .fail_einval
 	// p14 =3D Divide by 1000
 	// p15 =3D Add monotonic
 	//
-	// Note that instructions are optimized for McKinley. McKinley can proces=
s two
-	// bundles simultaneously and therefore we continuously try to feed the C=
PU
-	// two bundles and then a stop.
-	tnat.nz p6,p0 =3D r31	// branch deferred since it does not fit into bundl=
e structure
+	// Note that instructions are optimized for McKinley. McKinley can
+	// process two bundles simultaneously and therefore we continuously
+	// try to feed the CPU two bundles and then a stop.
+	tnat.nz p6,p0 =3D r31	// branch deferred since it does not fit into
+				//   bundle structure
 	mov pr =3D r30,0xc000	// Set predicates according to function
 	add r2 =3D TI_FLAGS+IA64_TASK_SIZE,r16
 	movl r20 =3D time_interpolator
@@ -218,7 +226,7 @@ (p6)    br.cond.spnt.few .fail_einval
 	movl r29 =3D xtime_lock
 	ld4 r2 =3D [r2]		// process work pending flags
 	movl r27 =3D xtime
-	;;	// only one bundle here
+	;;			// only one bundle here
 	ld8 r21 =3D [r20]		// first quad with control information
 	and r2 =3D TIF_ALLWORK_MASK,r2
 (p6)    br.cond.spnt.few .fail_einval	// deferred branch
@@ -244,13 +252,16 @@ (p12)	ld8 r30 =3D [r10]
 	;;
 .time_redo:
 	.pred.rel.mutex p8,p9,p10
-	ld4.acq r28 =3D [r29]	// xtime_lock.sequence. Must come first for locking=
 purposes
+	ld4.acq r28 =3D [r29]	// xtime_lock.sequence. Must come first for
+				//   locking purposes
 (p8)	mov r2 =3D ar.itc		// CPU_TIMER. 36 clocks latency!!!
 	add r22 =3D IA64_TIME_INTERPOLATOR_LAST_COUNTER_OFFSET,r20
-(p9)	ld8 r2 =3D [r30]		// readq(ti->address). Could also have latency issu=
es..
+(p9)	ld8 r2 =3D [r30]		// readq(ti->address). Could also have=20
+				//   latency issues..
 (p10)	ld4 r2 =3D [r30]		// readw(ti->address)
 (p13)	add r23 =3D IA64_TIME_INTERPOLATOR_LAST_CYCLE_OFFSET,r20
-	;;			// could be removed by moving the last add upward
+	;;			// could be removed by moving the last add
+				//   upward
 	ld8 r26 =3D [r22]		// time_interpolator->last_counter
 (p13)	ld8 r25 =3D [r23]		// time interpolator->last_cycle
 	add r24 =3D IA64_TIME_INTERPOLATOR_OFFSET_OFFSET,r20
@@ -263,7 +274,7 @@ (p15)	ld8 r17 =3D [r19],IA64_TIMESPEC_TV_N
 (p13)	sub r3 =3D r25,r2	// Diff needed before comparison (thanks davidm)
 	;;
 	ld8 r14 =3D [r14]		// time_interpolator->mask
-(p13)	cmp.gt.unc p6,p7 =3D r3,r0	// check if it is less than last. p6,p7 c=
leared
+(p13)	cmp.gt.unc p6,p7 =3D r3,r0  // check if less than last. p6,p7 cleared
 	sub r10 =3D r2,r26	// current_counter - last_counter
 	;;
 (p6)	sub r10 =3D r25,r26	// time we got was less than last_cycle
@@ -275,7 +286,8 @@ (p7)	mov ar.ccv =3D r25	// more than last_
 	nop.i 123
 	;;
 (p7)	cmpxchg8.rel r3 =3D [r23],r2,ar.ccv
-EX(.fail_efault, probe.w.fault r31, 3)	// This takes 5 cycles and we have =
spare time
+EX(.fail_efault, probe.w.fault r31, 3)	// This takes 5 cycles and we have
+					//   spare time
 	xmpy.l f8 =3D f8,f7	// nsec_per_cyc*(counter-last_counter)
 (p15)	add r9 =3D r9,r17		// Add wall to monotonic.secs to result secs
 	;;
@@ -290,7 +302,7 @@ (p7)	cmp.ne p7,p0 =3D r25,r3	// if cmpxchg
 	ld4 r10 =3D [r29]		// xtime_lock.sequence
 (p15)	add r8 =3D r8, r17	// Add monotonic.nsecs to nsecs
 	shr.u r2 =3D r2,r21
-	;;		// overloaded 3 bundles!
+	;;			// overloaded 3 bundles!
 	// End critical section.
 	add r8 =3D r8,r2		// Add xtime.nsecs
 	cmp4.ne.or p7,p0 =3D r28,r10
@@ -304,19 +316,21 @@ (p14)	movl r3 =3D 2361183241434822607	// P
 .time_normalize:
 	mov r21 =3D r8
 	cmp.ge p6,p0 =3D r8,r2
-(p14)	shr.u r20 =3D r8, 3		// We can repeat this if necessary just wasting=
 some time
+(p14)	shr.u r20 =3D r8, 3		// We can repeat this if necessary,
+					//   just wasting some time
 	;;
 (p14)	setf.sig f8 =3D r20
 (p6)	sub r8 =3D r8,r2
 (p6)	add r9 =3D 1,r9			// two nops before the branch.
-(p14)	setf.sig f7 =3D r3		// Chances for repeats are 1 in 10000 for gettod
+(p14)	setf.sig f7 =3D r3		// Chances for repeats are 1 in 10000
+					//   for gettod
 (p6)	br.cond.dpnt.few .time_normalize
 	;;
 	// Divided by 8 though shift. Now divide by 125
 	// The compiler was able to do that with a multiply
 	// and a shift and we do the same
-EX(.fail_efault, probe.w.fault r23, 3)		// This also costs 5 cycles
-(p14)	xmpy.hu f8 =3D f8, f7			// xmpy has 5 cycles latency so use it...
+EX(.fail_efault, probe.w.fault r23, 3)	// This also costs 5 cycles
+(p14)	xmpy.hu f8 =3D f8, f7		// xmpy has 5 cycle latency so use it..
 	;;
 	mov r8 =3D r0
 (p14)	getf.sig r2 =3D f8
@@ -349,7 +363,8 @@ (p6)	br.spnt.few fsys_fallback_syscall
 END(fsys_clock_gettime)
=20
 /*
- * long fsys_rt_sigprocmask (int how, sigset_t *set, sigset_t *oset, size_=
t sigsetsize).
+ * long fsys_rt_sigprocmask (int how, sigset_t *set, sigset_t *oset,=20
+ *			     size_t sigsetsize).
  */
 #if _NSIG_WORDS !=3D 1
 # error Sorry, fsys_rt_sigprocmask() needs to be updated for _NSIG_WORDS !=
=3D 1.
@@ -363,11 +378,11 @@ ENTRY(fsys_rt_sigprocmask)
 	add r9=3DTI_FLAGS+IA64_TASK_SIZE,r16
 	cmp4.ltu p6,p0=3DSIG_SETMASK,r32
=20
-	cmp.ne p15,p0=3Dr0,r34			// oset !=3D NULL?
+	cmp.ne p15,p0=3Dr0,r34		// oset !=3D NULL?
 	tnat.nz p8,p0=3Dr34
 	add r31=3DIA64_TASK_SIGHAND_OFFSET,r16
 	;;
-	ld8 r3=3D[r2]				// read/prefetch current->blocked
+	ld8 r3=3D[r2]			// read/prefetch current->blocked
 	ld4 r9=3D[r9]
 	tnat.nz.or p6,p0=3Dr35
=20
@@ -383,14 +398,20 @@ #endif
 	;;
 	cmp.ne p7,p0=3D0,r9
 	cmp.eq p6,p0=3Dr0,r33			// set =3D NULL?
-	add r31=3DIA64_SIGHAND_SIGLOCK_OFFSET,r31	// r31 <- current->sighand->sig=
lock
+	// r31 <- current->sighand->siglock
+	add r31=3DIA64_SIGHAND_SIGLOCK_OFFSET,r31=09
 (p8)	br.spnt.few .fail_efault		// fail with EFAULT
 (p7)	br.spnt.many fsys_fallback_syscall	// got pending kernel work...
-(p6)	br.dpnt.many .store_mask		// -> short-circuit to just reading the sig=
nal mask
+(p6)	br.dpnt.many .store_mask		// -> short-circuit to just
+						//   reading the signal mask
=20
-	/* Argh, we actually have to do some work and _update_ the signal mask: */
+	/*=20
+	 * Argh, we actually have to do some work and _update_ the signal
+	 * mask:
+	 */
=20
-EX(.fail_efault, probe.r.fault r33, 3)		// verify user has read-access to =
*set
+EX(.fail_efault, probe.r.fault r33, 3)		// verify user has read-access
+						//   to *set
 EX(.fail_efault, ld8 r14=3D[r33])			// r14 <- *set
 	mov r17=3D(1 << (SIGKILL - 1)) | (1 << (SIGSTOP - 1))
 	;;
@@ -403,21 +424,23 @@ #ifdef CONFIG_SMP
 	mov r17=3D1
 	;;
 	cmpxchg4.acq r18=3D[r31],r17,ar.ccv	// try to acquire the lock
-	mov r8=3DEINVAL			// default to EINVAL
+	mov r8=3DEINVAL				// default to EINVAL
 	;;
-	ld8 r3=3D[r2]			// re-read current->blocked now that we hold the lock
+	ld8 r3=3D[r2]				// re-read current->blocked=20
+						//   now that we hold the lock
 	cmp4.ne p6,p0=3Dr18,r0
 (p6)	br.cond.spnt.many .lock_contention
 	;;
 #else
-	ld8 r3=3D[r2]			// re-read current->blocked now that we hold the lock
-	mov r8=3DEINVAL			// default to EINVAL
+	ld8 r3=3D[r2]				// re-read current->blocked=20
+						//   now that we hold the lock
+	mov r8=3DEINVAL				// default to EINVAL
 #endif
 	add r18=3DIA64_TASK_PENDING_OFFSET+IA64_SIGPENDING_SIGNAL_OFFSET,r16
 	add r19=3DIA64_TASK_SIGNAL_OFFSET,r16
 	cmp4.eq p6,p0=3DSIG_BLOCK,r32
 	;;
-	ld8 r19=3D[r19]			// r19 <- current->signal
+	ld8 r19=3D[r19]				// r19 <- current->signal
 	cmp4.eq p7,p0=3DSIG_UNBLOCK,r32
 	cmp4.eq p8,p0=3DSIG_SETMASK,r32
 	;;
@@ -431,59 +454,64 @@ (p6)	mov r8=3D0			// clear error code
 	// recalc_sigpending()
 	add r17=3DIA64_SIGNAL_GROUP_STOP_COUNT_OFFSET,r19
=20
-	add r19=3DIA64_SIGNAL_SHARED_PENDING_OFFSET+IA64_SIGPENDING_SIGNAL_OFFSET=
,r19
+	add r19=3DIA64_SIGNAL_SHARED_PENDING_OFFSET + \
+	        IA64_SIGPENDING_SIGNAL_OFFSET,r19
 	;;
 	ld4 r17=3D[r17]		// r17 <- current->signal->group_stop_count
 (p7)	mov r8=3D0		// clear error code
=20
 	ld8 r19=3D[r19]		// r19 <- current->signal->shared_pending
 	;;
-	cmp4.gt p6,p7=3Dr17,r0	// p6/p7 <- (current->signal->group_stop_count > 0=
)?
+	// p6/p7 <- (current->signal->group_stop_count > 0)?
+	cmp4.gt p6,p7=3Dr17,r0
 (p8)	mov r8=3D0		// clear error code
=20
-	or r18=3Dr18,r19		// r18 <- current->pending | current->signal->shared_pe=
nding
+	or r18=3Dr18,r19		// r18 <- current->pending |=20
+				//	  current->signal->shared_pending
 	;;
-	// r18 <- (current->pending | current->signal->shared_pending) & ~current=
->blocked:
+	// r18 <- (current->pending | current->signal->shared_pending) &
+	//	   ~current->blocked:
 	andcm r18=3Dr18,r14
 	add r9=3DTI_FLAGS+IA64_TASK_SIZE,r16
 	;;
=20
-(p7)	cmp.ne.or.andcm p6,p7=3Dr18,r0		// p6/p7 <- signal pending
-	mov r19=3D0					// i must not leak kernel bits...
+(p7)	cmp.ne.or.andcm p6,p7=3Dr18,r0	// p6/p7 <- signal pending
+	mov r19=3D0			// must not leak kernel bits...
 (p6)	br.cond.dpnt.many .sig_pending
 	;;
=20
-1:	ld4 r17=3D[r9]				// r17 <- current->thread_info->flags
+1:	ld4 r17=3D[r9]			// r17 <- current->thread_info->flags
 	;;
 	mov ar.ccv=3Dr17
-	and r18=3D~_TIF_SIGPENDING,r17		// r18 <- r17 & ~(1 << TIF_SIGPENDING)
+	and r18=3D~_TIF_SIGPENDING,r17	// r18 <- r17 & ~(1 << TIF_SIGPENDING)
 	;;
=20
-	st8 [r2]=3Dr14				// update current->blocked with new mask
-	cmpxchg4.acq r8=3D[r9],r18,ar.ccv		// current->thread_info->flags <- r18
+	st8 [r2]=3Dr14			// update current->blocked with new mask
+	cmpxchg4.acq r8=3D[r9],r18,ar.ccv	  // current->thread_info->flags <- r18
 	;;
-	cmp.ne p6,p0=3Dr17,r8			// update failed?
-(p6)	br.cond.spnt.few 1b			// yes -> retry
+	cmp.ne p6,p0=3Dr17,r8		// update failed?
+(p6)	br.cond.spnt.few 1b		// yes -> retry
=20
 #ifdef CONFIG_SMP
-	st4.rel [r31]=3Dr0			// release the lock
+	st4.rel [r31]=3Dr0		// release the lock
 #endif
 	ssm psr.i
 	;;
=20
-	srlz.d					// ensure psr.i is set again
-	mov r18=3D0					// i must not leak kernel bits...
+	srlz.d				// ensure psr.i is set again
+	mov r18=3D0			// i must not leak kernel bits...
=20
 .store_mask:
-EX(.fail_efault, (p15) probe.w.fault r34, 3)	// verify user has write-acce=
ss to *oset
+EX(.fail_efault, (p15) probe.w.fault r34, 3)	// verify user has write-acce=
ss
+						//   to *oset
 EX(.fail_efault, (p15) st8 [r34]=3Dr3)
-	mov r2=3D0					// i must not leak kernel bits...
-	mov r3=3D0					// i must not leak kernel bits...
+	mov r2=3D0				// must not leak kernel bits...
+	mov r3=3D0				// must not leak kernel bits...
 	mov r8=3D0				// return 0
-	mov r9=3D0					// i must not leak kernel bits...
-	mov r14=3D0					// i must not leak kernel bits...
-	mov r17=3D0					// i must not leak kernel bits...
-	mov r31=3D0					// i must not leak kernel bits...
+	mov r9=3D0				// must not leak kernel bits...
+	mov r14=3D0				// must not leak kernel bits...
+	mov r17=3D0				// must not leak kernel bits...
+	mov r31=3D0				// must not leak kernel bits...
 	FSYS_RETURN
=20
 .sig_pending:
@@ -493,11 +521,15 @@ #endif
 	ssm psr.i
 	;;
 	srlz.d
-	br.sptk.many fsys_fallback_syscall	// with signal pending, do the heavy-w=
eight syscall
+	br.sptk.many fsys_fallback_syscall	// with signal pending, do the
+						//   heavy-weight syscall
=20
 #ifdef CONFIG_SMP
 .lock_contention:
-	/* Rather than spinning here, fall back on doing a heavy-weight syscall. =
 */
+	/*
+	 * Rather than spinning here, fall back on doing a heavy-weight=20
+	 * syscall.
+	 */
 	ssm psr.i
 	;;
 	srlz.d
@@ -510,8 +542,9 @@ ENTRY(fsys_fallback_syscall)
 	.altrp b6
 	.body
 	/*
-	 * We only get here from light-weight syscall handlers.  Thus, we already
-	 * know that r15 contains a valid syscall number.  No need to re-check.
+	 * We only get here from light-weight syscall handlers.  Thus, we=20
+	 * already know that r15 contains a valid syscall number.  No need=20
+	 * to re-check.
 	 */
 	adds r17=3D-1024,r15
 	movl r14=3Dsys_call_table
@@ -519,8 +552,10 @@ ENTRY(fsys_fallback_syscall)
 	rsm psr.i
 	shladd r18=3Dr17,3,r14
 	;;
-	ld8 r18=3D[r18]				// load normal (heavy-weight) syscall entry-point
-	mov r29=3Dpsr				// read psr (12 cyc load latency)
+	ld8 r18=3D[r18]				// load normal (heavy-weight)
+						//   syscall entry-point
+	mov r29=3Dpsr				// read psr (12 cycle load
+						//   latency)
 	mov r27=3Dar.rsc
 	mov r21=3Dar.fpsr
 	mov r26=3Dar.pfs
@@ -593,48 +628,61 @@ #	define PSR_ONE_BITS		((3 << IA64_PSR_C
 	movl r28=3D__kernel_syscall_via_break	// X	create cr.iip
 	;;
=20
-	mov r2=3Dr16				// A    get task addr to addl-addressable register
+	mov r2=3Dr16				// A    get task addr to=20
+						//	addl-addressable
+						//	register
 	adds r16=3DIA64_TASK_THREAD_ON_USTACK_OFFSET,r16 // A
 	mov r31=3Dpr				// I0   save pr (2 cyc)
 	;;
-	st1 [r16]=3Dr0				// M2|3 clear current->thread.on_ustack flag
+	st1 [r16]=3Dr0		// M2|3 clear current->thread.on_ustack flag
 	addl r22=3DIA64_RBS_OFFSET,r2		// A    compute base of RBS
 	add r3=3DTI_FLAGS+IA64_TASK_SIZE,r2	// A
 	;;
-	ld4 r3=3D[r3]				// M0|1 r3 =3D current_thread_info()->flags
-	lfetch.fault.excl.nt1 [r22]		// M0|1 prefetch register backing-store
+	ld4 r3=3D[r3]		// M0|1 r3 =3D current_thread_info()->flags
+	lfetch.fault.excl.nt1 [r22]	// M0|1 prefetch register backing-store
 	nop.i 0
 	;;
-	mov ar.rsc=3D0				// M2   set enforced lazy mode, pl 0, LE, loadrs=3D0
+	mov ar.rsc=3D0				// M2   set enforced lazy mode,
+						//	pl 0, LE, loadrs=3D0
 	nop.m 0
 	nop.i 0
 	;;
 	mov r23=3Dar.bspstore			// M2 (12 cyc) save ar.bspstore
-	mov.m r24=3Dar.rnat			// M2 (5 cyc) read ar.rnat (dual-issues!)
+	mov.m r24=3Dar.rnat			// M2 (5 cyc) read ar.rnat=20
+						//    (dual-issues!)
 	nop.i 0
 	;;
-	mov ar.bspstore=3Dr22			// M2 (6 cyc) switch to kernel RBS
+	mov ar.bspstore=3Dr22			// M2 (6 cyc) switch to kernel
+						//    RBS
 	movl r8=3DPSR_ONE_BITS			// X
 	;;
 	mov r25=3Dar.unat				// M2 (5 cyc) save ar.unat
 	mov r19=B6				// I0   save b6 (2 cyc)
 	mov r20=3Dr1				// A    save caller's gp in r20
 	;;
-	or r29=3Dr8,r29				// A    construct cr.ipsr value to save
-	mov b6=3Dr18				// I0   copy syscall entry-point to b6 (7 cyc)
-	addl r1=3DIA64_STK_OFFSET-IA64_PT_REGS_SIZE,r2 // A compute base of memor=
y stack
-
-	mov r18=3Dar.bsp				// M2   save (kernel) ar.bsp (12 cyc)
-	cmp.ne pKStk,pUStk=3Dr0,r0		// A    set pKStk <- 0, pUStk <- 1
+	or r29=3Dr8,r29				// A    construct cr.ipsr value
+						//	to save
+	mov b6=3Dr18				// I0   copy syscall entry=20
+						//	point to b6 (7 cyc)
+	addl r1=3DIA64_STK_OFFSET-IA64_PT_REGS_SIZE,r2 // A compute base of
+						     //   memory stack
+
+	mov r18=3Dar.bsp				// M2   save (kernel) ar.bsp
+						//	(12 cyc)
+	cmp.ne pKStk,pUStk=3Dr0,r0		// A    set pKStk <- 0,=20
+						//	pUStk <- 1
 	br.call.sptk.many b7=3Dia64_syscall_setup	// B
 	;;
-	mov ar.rsc=3D0x3				// M2   set eager mode, pl 0, LE, loadrs=3D0
-	mov rp=3Dr14				// I0   set the real return addr
+	mov ar.rsc=3D0x3				// M2   set eager mode, pl 0,=20
+						//	LE, loadrs=3D0
+	mov rp=3Dr14				// I0   set real return address
 	and r3=3D_TIF_SYSCALL_TRACEAUDIT,r3	// A
 	;;
-	ssm psr.i				// M2   we're on kernel stacks now, reenable irqs
+	ssm psr.i				// M2   we're on kernel stacks
+						//	now, reenable irqs
 	cmp.eq p8,p0=3Dr3,r0			// A
-(p10)	br.cond.spnt.many ia64_ret_from_syscall	// B    return if bad call-f=
rame or r15 is a NaT
+(p10)	br.cond.spnt.many ia64_ret_from_syscall	// B    return if bad call=20
+						//	frame or r15 is a NaT
=20
 	nop.m 0
 (p8)	br.call.sptk.many b6=B6			// B    (ignore return address)


--=20
Ciao,
al
----------------------------------------------------------------------
Al Stone                                      Alter Ego:
Open Source and Linux R&D                     Debian Developer
Hewlett-Packard Company                       http://www.debian.org
E-mail: ahs3@fc.hp.com                        ahs3@debian.org
----------------------------------------------------------------------

