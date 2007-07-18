From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Wed, 18 Jul 2007 15:03:10 +0000
Subject: [PATCH 1/3] fix ia64 clocksource : copy time structures into fsys_gtod_data
Message-Id: <469E2BAE.8070408@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This is 1 of 3 patches for ia64 clocksource.

As john stultz wrote:
> So w/ x86_64, we've split the xtime_lock and get vgtod_lock, so that
> only when the vsyscall page is being updated do we hold a write on the
> vgtod_lock. This is safe as the vsyscall gtod does not access the
> kernel's time structures (xtime and friends). Instead it reads its copy
> of them that is made in update_vsyscall().
>
> So it should be fine to use the gtod_lock.sequence, assuming you're also
> not touching the kernel's xtime directly  (and instead using copy of
> xtime made in update_vsyscall).

having copy of xtime is good solution.

This patch does:

  - add wall_time/monotonic_time member to struct fsys_gtod_data.
  - copy xtime to wall_time in update_vsyscall.
  - calculate monotonic time in update_vsyscall, instead of doing
    it in each gettimeofday call. And save it to monotonic_time.
  - force loading gtod_lock.sequence before touching protected data.
  - modify comments.

Then, the results of my test:

> # clocksource (Bob's) : default
> CPU  0:  4.66 (usecs) (0 errors / 2145680 iterations)
> CPU  1:  4.65 (usecs) (493 errors / 2148438 iterations)
> CPU  2:  4.63 (usecs) (668 errors / 2159461 iterations)
> CPU  3:  4.62 (usecs) (654 errors / 2163997 iterations)
> # clocksource (Bob's) : nojitter
> CPU  0:  0.14 (usecs) (0 errors / 70945550 iterations)
> CPU  1:  0.14 (usecs) (470 errors / 71640889 iterations)
> CPU  2:  0.14 (usecs) (664 errors / 70960917 iterations)
> CPU  3:  0.14 (usecs) (571 errors / 70956121 iterations)
> # clocksource (Bob's) : nolwsys
> CPU  0:  2.88 (usecs) (0 errors / 3475147 iterations)
> CPU  1:  2.88 (usecs) (0 errors / 3474881 iterations)
> CPU  2:  2.96 (usecs) (0 errors / 3382229 iterations)
> CPU  3:  2.97 (usecs) (0 errors / 3371004 iterations)

are now

> # savextime : default
> CPU  0:  5.49 (usecs) (0 errors / 1822461 iterations)
> CPU  1:  5.46 (usecs) (0 errors / 1830527 iterations)
> CPU  2:  5.45 (usecs) (0 errors / 1834697 iterations)
> CPU  3:  5.46 (usecs) (0 errors / 1831464 iterations)
> # savextime : nojitter
> CPU  0:  0.14 (usecs) (0 errors / 70918167 iterations)
> CPU  1:  0.14 (usecs) (0 errors / 71620242 iterations)
> CPU  2:  0.14 (usecs) (0 errors / 70946394 iterations)
> CPU  3:  0.14 (usecs) (0 errors / 70933043 iterations)
> # savextime : nolwsys
> CPU  0:  2.89 (usecs) (0 errors / 3459498 iterations)
> CPU  1:  2.89 (usecs) (0 errors / 3458876 iterations)
> CPU  2:  2.96 (usecs) (0 errors / 3377799 iterations)
> CPU  3:  2.97 (usecs) (0 errors / 3372353 iterations)

so errors are vanished by proper locking, but something in
"default" is still wrong.

(Continue to next patch.)

Thanks,
H.Seto

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>

-----
 arch/ia64/kernel/asm-offsets.c        |   28 +++++++++----
 arch/ia64/kernel/fsys.S               |   71 +++++++++++++++++-----------------
 arch/ia64/kernel/fsyscall_gtod_data.h |    2
 arch/ia64/kernel/time.c               |   14 ++++++
 4 files changed, 73 insertions(+), 42 deletions(-)

Index: linux-2.6.22/arch/ia64/kernel/asm-offsets.c
=================================--- linux-2.6.22.orig/arch/ia64/kernel/asm-offsets.c
+++ linux-2.6.22/arch/ia64/kernel/asm-offsets.c
@@ -258,12 +258,24 @@
 	BLANK();

 	/* used by fsys_gettimeofday in arch/ia64/kernel/fsys.S */
-	DEFINE(IA64_GTOD_LOCK_OFFSET, offsetof (struct fsyscall_gtod_data_t, lock));
-	DEFINE(IA64_CLKSRC_MASK_OFFSET, offsetof (struct fsyscall_gtod_data_t, clk_mask));
-	DEFINE(IA64_CLKSRC_MULT_OFFSET, offsetof (struct fsyscall_gtod_data_t, clk_mult));
-	DEFINE(IA64_CLKSRC_SHIFT_OFFSET, offsetof (struct fsyscall_gtod_data_t, clk_shift));
-	DEFINE(IA64_CLKSRC_MMIO_OFFSET, offsetof (struct fsyscall_gtod_data_t, clk_fsys_mmio));
-	DEFINE(IA64_CLKSRC_CYCLE_LAST_OFFSET, offsetof (struct fsyscall_gtod_data_t, clk_cycle_last));
-	DEFINE(IA64_ITC_LASTCYCLE_OFFSET, offsetof (struct fsyscall_gtod_data_t, itc_lastcycle));
-	DEFINE(IA64_ITC_JITTER_OFFSET, offsetof (struct fsyscall_gtod_data_t, itc_jitter));
+	DEFINE(IA64_GTOD_LOCK_OFFSET,
+		offsetof (struct fsyscall_gtod_data_t, lock));
+	DEFINE(IA64_GTOD_WALL_TIME_OFFSET,
+		offsetof (struct fsyscall_gtod_data_t, wall_time));
+	DEFINE(IA64_GTOD_MONO_TIME_OFFSET,
+		offsetof (struct fsyscall_gtod_data_t, monotonic_time));
+	DEFINE(IA64_CLKSRC_MASK_OFFSET,
+		offsetof (struct fsyscall_gtod_data_t, clk_mask));
+	DEFINE(IA64_CLKSRC_MULT_OFFSET,
+		offsetof (struct fsyscall_gtod_data_t, clk_mult));
+	DEFINE(IA64_CLKSRC_SHIFT_OFFSET,
+		offsetof (struct fsyscall_gtod_data_t, clk_shift));
+	DEFINE(IA64_CLKSRC_MMIO_OFFSET,
+		offsetof (struct fsyscall_gtod_data_t, clk_fsys_mmio));
+	DEFINE(IA64_CLKSRC_CYCLE_LAST_OFFSET,
+		offsetof (struct fsyscall_gtod_data_t, clk_cycle_last));
+	DEFINE(IA64_ITC_LASTCYCLE_OFFSET,
+		offsetof (struct fsyscall_gtod_data_t, itc_lastcycle));
+	DEFINE(IA64_ITC_JITTER_OFFSET,
+		offsetof (struct fsyscall_gtod_data_t, itc_jitter));
 }
Index: linux-2.6.22/arch/ia64/kernel/fsyscall_gtod_data.h
=================================--- linux-2.6.22.orig/arch/ia64/kernel/fsyscall_gtod_data.h
+++ linux-2.6.22/arch/ia64/kernel/fsyscall_gtod_data.h
@@ -7,6 +7,8 @@

 struct fsyscall_gtod_data_t {
 	seqlock_t	lock;
+	struct timespec	wall_time;
+	struct timespec monotonic_time;
 	cycle_t		clk_mask;
 	u32		clk_mult;
 	u32		clk_shift;
Index: linux-2.6.22/arch/ia64/kernel/time.c
=================================--- linux-2.6.22.orig/arch/ia64/kernel/time.c
+++ linux-2.6.22/arch/ia64/kernel/time.c
@@ -373,6 +373,20 @@
         fsyscall_gtod_data.clk_fsys_mmio = c->fsys_mmio;
         fsyscall_gtod_data.clk_cycle_last = c->cycle_last;

+	/* copy kernel time structures */
+        fsyscall_gtod_data.wall_time.tv_sec = wall->tv_sec;
+        fsyscall_gtod_data.wall_time.tv_nsec = wall->tv_nsec;
+        fsyscall_gtod_data.monotonic_time.tv_sec = wall_to_monotonic.tv_sec
+							+ wall->tv_sec;
+        fsyscall_gtod_data.monotonic_time.tv_nsec = wall_to_monotonic.tv_nsec
+							+ wall->tv_nsec;
+
+	/* normalize */
+	while (fsyscall_gtod_data.monotonic_time.tv_nsec >= NSEC_PER_SEC) {
+		fsyscall_gtod_data.monotonic_time.tv_nsec -= NSEC_PER_SEC;
+		fsyscall_gtod_data.monotonic_time.tv_sec++;
+	}
+
         write_sequnlock_irqrestore(&fsyscall_gtod_data.lock, flags);
 }

Index: linux-2.6.22/arch/ia64/kernel/fsys.S
=================================--- linux-2.6.22.orig/arch/ia64/kernel/fsys.S
+++ linux-2.6.22/arch/ia64/kernel/fsys.S
@@ -178,18 +178,19 @@
 	// r14 = address of mask / mask value
 	// r15 = preserved: system call number
 	// r16 = preserved: current task pointer
-	// r17 = wall to monotonic use
+	// r17 = (not used)
+	// r18 = (not used)
 	// r19 = address of itc_lastcycle
-	// r20 = struct fsyscall_gtod_data  / address of first element
+	// r20 = struct fsyscall_gtod_data (= address of gtod_lock.sequence)
 	// r21 = address of mmio_ptr
-	// r22 = address of  wall_to_monotonic
-	// r23 = address of shift/ value
+	// r22 = address of wall_time or monotonic_time
+	// r23 = address of shift / value
 	// r24 = address mult factor / cycle_last value
 	// r25 = itc_lastcycle value
 	// r26 = address clocksource cycle_last
-	// r27 = pointer to xtime
+	// r27 = (not used)
 	// r28 = sequence number at the beginning of critcal section
-	// r29 = address of seqlock
+	// r29 = address of itc_jitter
 	// r30 = time processing flags / memory address
 	// r31 = pointer to result
 	// Predicates
@@ -203,30 +204,36 @@
 	// p14 = Divide by 1000
 	// p15 = Add monotonic
 	//
-	// Note that instructions are optimized for McKinley. McKinley can process two
-	// bundles simultaneously and therefore we continuously try to feed the CPU
-	// two bundles and then a stop.
-	tnat.nz p6,p0 = r31	// branch deferred since it does not fit into bundle structure
+	// Note that instructions are optimized for McKinley. McKinley can
+	// process two bundles simultaneously and therefore we continuously
+	// try to feed the CPU two bundles and then a stop.
+	//
+	// Additional note that code has changed a lot. Optimization is TBD.
+	// Comments begin with "?" are maybe outdated.
+	tnat.nz p6,p0 = r31	// ? branch deferred to fit later bundle
 	mov pr = r30,0xc000	// Set predicates according to function
 	add r2 = TI_FLAGS+IA64_TASK_SIZE,r16
 	movl r20 = fsyscall_gtod_data // load fsyscall gettimeofday data address
 	;;
 	add r29 = IA64_ITC_JITTER_OFFSET,r20
-	movl r27 = xtime
+	add r22 = IA64_GTOD_WALL_TIME_OFFSET,r20	// wall_time
 	ld4 r2 = [r2]		// process work pending flags
-(p15)	movl r22 = wall_to_monotonic
 	;;
+(p15)	add r22 = IA64_GTOD_MONO_TIME_OFFSET,r20	// monotonic_time
 	add r21 = IA64_CLKSRC_MMIO_OFFSET,r20
 	add r19 = IA64_ITC_LASTCYCLE_OFFSET,r20
 	and r2 = TIF_ALLWORK_MASK,r2
-(p6)    br.cond.spnt.few .fail_einval	// deferred branch
+(p6)    br.cond.spnt.few .fail_einval	// ? deferred branch
 	;;
 	add r26 = IA64_CLKSRC_CYCLE_LAST_OFFSET,r20 // clksrc_cycle_last
 	cmp.ne p6, p0 = 0, r2	// Fallback if work is scheduled
 (p6)    br.cond.spnt.many fsys_fallback_syscall
 	;; // get lock.seq here new code, outer loop2!
 .time_redo:
-	ld4.acq r28 = [r20]	// gtod_lock.sequence, Must be first in struct
+	ld4.acq r28 = [r20]	// gtod_lock.sequence, Must take first
+	;;
+	and r28 = ~1,r28	// And make sequence even to force retry if odd
+	;;
 	ld8 r30 = [r21]		// clocksource->mmio_ptr
 	add r24 = IA64_CLKSRC_MULT_OFFSET,r20
 	ld4 r2 = [r29]		// itc_jitter value
@@ -235,7 +242,7 @@
 	;;
 	ld4 r3 = [r24]		// clocksource mult value
 	ld8 r14 = [r14]         // clocksource mask value
-	cmp.eq p8,p9 = 0,r30	// Check for cpu timer, no mmio_ptr, set p8, clear p9
+	cmp.eq p8,p9 = 0,r30	// use cpu timer if no mmio_ptr
 	;;
 	setf.sig f7 = r3	// Setup for mult scaling of counter
 (p8)	cmp.ne p13,p0 = r2,r0	// need itc_jitter compensation, set p13
@@ -246,17 +253,16 @@
 .cmpxchg_redo:
 	.pred.rel.mutex p8,p9
 (p8)	mov r2 = ar.itc		// CPU_TIMER. 36 clocks latency!!!
-(p9)	ld8 r2 = [r30]		// readq(ti->address). Could also have latency issues..
+(p9)	ld8 r2 = [r30]		// MMIO_TIMER. Could also have latency issues..
 (p13)	ld8 r25 = [r19]		// get itc_lastcycle value
-	;;			// could be removed by moving the last add upward
- 	ld8 r9 = [r27],IA64_TIMESPEC_TV_NSEC_OFFSET
-(p15)	ld8 r17 = [r22],IA64_TIMESPEC_TV_NSEC_OFFSET
+	;;		// ? could be removed by moving the last add upward
+ 	ld8 r9 = [r22],IA64_TIMESPEC_TV_NSEC_OFFSET	// tv_sec
 	;;
-	ld8 r8 = [r27],-IA64_TIMESPEC_TV_NSEC_OFFSET	// xtime.tv_nsec
+	ld8 r8 = [r22],-IA64_TIMESPEC_TV_NSEC_OFFSET	// tv_nsec
 (p13)	sub r3 = r25,r2		// Diff needed before comparison (thanks davidm)
 	;;
 (p13)	cmp.gt.unc p6,p7 = r3,r0 // check if it is less than last. p6,p7 cleared
-	sub r10 = r2,r24	// current_counter - last_counter
+	sub r10 = r2,r24	// current_cycle - last_cycle
 	;;
 (p6)	sub r10 = r25,r24	// time we got was less than last_cycle
 (p7)	mov ar.ccv = r25	// more than last_cycle. Prep for cmpxchg
@@ -267,23 +273,20 @@
 	nop.i 123
 	;;
 (p7)	cmpxchg8.rel r3 = [r19],r2,ar.ccv
-EX(.fail_efault, probe.w.fault r31, 3)	// This takes 5 cycles and we have spare time
+	// fault check takes 5 cycles and we have spare time
+EX(.fail_efault, probe.w.fault r31, 3)
 	xmpy.l f8 = f8,f7	// nsec_per_cyc*(counter-last_counter)
-(p15)	add r9 = r9,r17		// Add wall to monotonic.secs to result secs
 	;;
 	// End cmpxchg critical section loop1
-(p15)	ld8 r17 = [r22],-IA64_TIMESPEC_TV_NSEC_OFFSET
 (p7)	cmp.ne p7,p0 = r25,r3	// if cmpxchg not successful redo
 (p7)	br.cond.dpnt.few .cmpxchg_redo	// inner loop1
-	// simulate tbit.nz.or p7,p0 = r28,0
-	and r28 = ~1,r28	// Make sequence even to force retry if odd
+	// ? simulate tbit.nz.or p7,p0 = r28,0
 	getf.sig r2 = f8
 	mf
 	;;
-	ld4 r10 = [r20]		// gtod_lock.sequence, old xtime_lock.sequence
-(p15)	add r8 = r8, r17	// Add monotonic.nsecs to nsecs
+	ld4 r10 = [r20]		// gtod_lock.sequence
 	shr.u r2 = r2,r23	// shift by factor
-	;;		// overloaded 3 bundles!
+	;;		// ? overloaded 3 bundles!
 	// End critical section.
 	add r8 = r8,r2		// Add xtime.nsecs
 	cmp4.ne.or p7,p0 = r28,r10
@@ -297,19 +300,19 @@
 .time_normalize:
 	mov r21 = r8
 	cmp.ge p6,p0 = r8,r2
-(p14)	shr.u r20 = r8, 3		// We can repeat this if necessary just wasting some time
+(p14)	shr.u r20 = r8, 3 // We can repeat this if necessary just wasting time
 	;;
 (p14)	setf.sig f8 = r20
 (p6)	sub r8 = r8,r2
-(p6)	add r9 = 1,r9			// two nops before the branch.
-(p14)	setf.sig f7 = r3		// Chances for repeats are 1 in 10000 for gettod
+(p6)	add r9 = 1,r9		// two nops before the branch.
+(p14)	setf.sig f7 = r3	// Chances for repeats are 1 in 10000 for gettod
 (p6)	br.cond.dpnt.few .time_normalize
 	;;
 	// Divided by 8 though shift. Now divide by 125
 	// The compiler was able to do that with a multiply
 	// and a shift and we do the same
-EX(.fail_efault, probe.w.fault r23, 3)		// This also costs 5 cycles
-(p14)	xmpy.hu f8 = f8, f7			// xmpy has 5 cycles latency so use it...
+EX(.fail_efault, probe.w.fault r23, 3)	// This also costs 5 cycles
+(p14)	xmpy.hu f8 = f8, f7		// xmpy has 5 cycles latency so use it
 	;;
 	mov r8 = r0
 (p14)	getf.sig r2 = f8

