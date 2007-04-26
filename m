From: Peter Keilty <peter.keilty@hp.com>
Date: Thu, 26 Apr 2007 20:27:23 +0000
Subject: [PATCH 3/3] ia64: update fsyscall for performance, enable build/run on 2.6.21-rc1
Message-Id: <20070426202723.23343.95117.sendpatchset@rambler.zko.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070426202632.23343.54944.sendpatchset@rambler.zko.hp.com>
In-Reply-To: <20070426202632.23343.54944.sendpatchset@rambler.zko.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: John Stultz <johnstul@us.ibm.com>, linux-kernel@vger.kernel.org, Eric Whitney <eric.whitney@hp.com>, Peter Keilty <peter.keilty@hp.com>

From: Peter Keilty <peter.keilty@hp.com>

Update ia64 conversion to the generic timekeeping/clocksource code.
Modified fast syscall path for gettimeofday to get performance equal
to orginal code and handle clocksource change at clock hz time.

Performance measurements for single calls (ITC cycles):

A. 32 way Intel IA64 SMP system 8640 (montecito)
A.1. Current code itc cmpxchg
gettimeofday cycles: 39 37 37 37 37 37 37 37 37 37 
clock_gettime(REAL) cycles: 49 35 35 35 35 35 35 35 35 35
clock_gettime(MONO) cycles: 42 36 36 36 36 36 36 36 36 36

A.2 New code itc cmpxchg
gettimeofday cycles: 39 38 37 37 38 37 38 37 37 37
clock_gettime(REAL) cycles: 53 35 35 36 35 35 35 35 35 35
clock_gettime(MONO) cycles: 44 38 36 36 36 36 36 36 36 36

A.3 New code itc cmpxchg switched off (nojitter kernel option)
gettimeofday cycles: 35 35 36 35 36 35 36 35 35 35
clock_gettime(REAL) cycles: 49 33 33 34 33 33 33 33 33 33
clock_gettime(MONO) cycles: 38 33 33 33 33 33 33 33 33 33

A.4 New code with hpet as clocksource, mmio space read
gettimeofday cycles: 183 183 181 180 182 185 182 183 184 182
clock_gettime(REAL) cycles: 196 180 179 179 183 181 182 183 183 181
clock_gettime(MONO) cycles: 185 180 182 180 182 182 179 179 179 181

Signed-off-by: Peter keilty <peter.keilty@hp.com>

---

 arch/ia64/kernel/asm-offsets.c        |   15 ++++---
 arch/ia64/kernel/cyclone.c            |    2 -
 arch/ia64/kernel/fsys.S               |   64 ++++++++++++++++++----------------
 arch/ia64/kernel/fsyscall_gtod_data.h |   18 +++++++++
 arch/ia64/kernel/time.c               |   37 +++++++++++++------
 arch/ia64/sn/kernel/sn2/timer.c       |    2 -
 drivers/char/hpet.c                   |    2 -
 kernel/time/ntp.c                     |   10 -----
 8 files changed, 90 insertions(+), 60 deletions(-)

Index: Linux/arch/ia64/kernel/asm-offsets.c
=================================--- Linux.orig/arch/ia64/kernel/asm-offsets.c	2007-04-24 11:40:44.000000000 -0400
+++ Linux/arch/ia64/kernel/asm-offsets.c	2007-04-24 12:58:49.000000000 -0400
@@ -16,6 +16,7 @@
 #include <asm-ia64/mca.h>
 
 #include "../kernel/sigframe.h"
+#include "../kernel/fsyscall_gtod_data.h"
 
 #define DEFINE(sym, val) \
         asm volatile("\n->" #sym " %0 " #val : : "i" (val))
@@ -256,10 +257,12 @@ void foo(void)
 	BLANK();
 
 	/* used by fsys_gettimeofday in arch/ia64/kernel/fsys.S */
-	DEFINE(IA64_TIMESPEC_TV_NSEC_OFFSET, offsetof (struct timespec, tv_nsec));
-	DEFINE(IA64_CLOCKSOURCE_MASK_OFFSET, offsetof (struct clocksource, mask));
-	DEFINE(IA64_CLOCKSOURCE_MULT_OFFSET, offsetof (struct clocksource, mult));
-	DEFINE(IA64_CLOCKSOURCE_SHIFT_OFFSET, offsetof (struct clocksource, shift));
-	DEFINE(IA64_CLOCKSOURCE_MMIO_PTR_OFFSET, offsetof (struct clocksource, fsys_mmio_ptr));
-	DEFINE(IA64_CLOCKSOURCE_CYCLE_LAST_OFFSET, offsetof (struct clocksource, cycle_last));
+	DEFINE(IA64_GTOD_LOCK_OFFSET, offsetof (struct fsyscall_gtod_data_t, lock));
+	DEFINE(IA64_CLKSRC_MASK_OFFSET, offsetof (struct fsyscall_gtod_data_t, clk_mask));
+	DEFINE(IA64_CLKSRC_MULT_OFFSET, offsetof (struct fsyscall_gtod_data_t, clk_mult));
+	DEFINE(IA64_CLKSRC_SHIFT_OFFSET, offsetof (struct fsyscall_gtod_data_t, clk_shift));
+	DEFINE(IA64_CLKSRC_MMIO_PTR_OFFSET, offsetof (struct fsyscall_gtod_data_t, clk_fsys_mmio_ptr));
+	DEFINE(IA64_CLKSRC_CYCLE_LAST_OFFSET, offsetof (struct fsyscall_gtod_data_t, clk_cycle_last));
+	DEFINE(IA64_ITC_LASTCYCLE_OFFSET, offsetof (struct fsyscall_gtod_data_t, itc_lastcycle));
+	DEFINE(IA64_ITC_JITTER_OFFSET, offsetof (struct fsyscall_gtod_data_t, itc_jitter));
 }
Index: Linux/arch/ia64/kernel/cyclone.c
=================================--- Linux.orig/arch/ia64/kernel/cyclone.c	2007-04-24 11:40:44.000000000 -0400
+++ Linux/arch/ia64/kernel/cyclone.c	2007-04-24 12:31:20.000000000 -0400
@@ -33,7 +33,7 @@ static struct clocksource clocksource_cy
         .mask           = (1LL << 40) - 1,
         .mult           = 0, /*to be caluclated*/
         .shift          = 16,
-        .is_continuous  = 1,
+        .flags          = CLOCK_SOURCE_IS_CONTINUOUS,
 };
 
 int __init init_cyclone_clock(void)
Index: Linux/arch/ia64/kernel/fsys.S
=================================--- Linux.orig/arch/ia64/kernel/fsys.S	2007-04-24 11:40:44.000000000 -0400
+++ Linux/arch/ia64/kernel/fsys.S	2007-04-25 16:39:25.000000000 -0400
@@ -145,6 +145,9 @@ ENTRY(fsys_set_tid_address)
 	FSYS_RETURN
 END(fsys_set_tid_address)
 
+#if IA64_GTOD_LOCK_OFFSET !=0
+#error fsys_gettimeofday incompatible with changes to struct fsyscall_gtod_data_t
+#endif
 #define CLOCK_REALTIME 0
 #define CLOCK_MONOTONIC 1
 #define CLOCK_DIVIDE_BY_1000 0x4000
@@ -175,10 +178,10 @@ ENTRY(fsys_gettimeofday)
 	// r16 = preserved: current task pointer
 	// r17 = wall to monotonic use
 	// r19 = address of itc_lastcycle
-	// r20 = struct clocksource / address of first element
-	// r21 = shift value
-	// r22 = address of itc_jitter/ wall_to_monotonic
-	// r23 = address of shift
+	// r20 = struct fsyscall_gtod_data  / address of first element
+	// r21 = address of mmio_ptr
+	// r22 = address of  wall_to_monotonic
+	// r23 = address of shift/ value
 	// r24 = address mult factor / cycle_last value
 	// r25 = itc_lastcycle value
 	// r26 = address clocksource cycle_last
@@ -204,46 +207,47 @@ ENTRY(fsys_gettimeofday)
 	tnat.nz p6,p0 = r31	// branch deferred since it does not fit into bundle structure
 	mov pr = r30,0xc000	// Set predicates according to function
 	add r2 = TI_FLAGS+IA64_TASK_SIZE,r16
-	movl r20 = fsyscall_clock // load fsyscall clocksource address
+	movl r20 = fsyscall_gtod_data // load fsyscall gettimeofday data address
 	;;
-	add r10 = IA64_CLOCKSOURCE_MMIO_PTR_OFFSET,r20
-	movl r29 = xtime_lock
-	ld4 r2 = [r2]		// process work pending flags
+	add r29 = IA64_ITC_JITTER_OFFSET,r20
 	movl r27 = xtime
-	;;	// only one bundle here
-	add r14 = IA64_CLOCKSOURCE_MASK_OFFSET,r20
-	movl r22 = itc_jitter
-	add r24 = IA64_CLOCKSOURCE_MULT_OFFSET,r20
+	ld4 r2 = [r2]		// process work pending flags
+(p15)	movl r22 = wall_to_monotonic
+	;;
+	add r21 = IA64_CLKSRC_MMIO_PTR_OFFSET,r20
+	add r19 = IA64_ITC_LASTCYCLE_OFFSET,r20
 	and r2 = TIF_ALLWORK_MASK,r2
 (p6)    br.cond.spnt.few .fail_einval	// deferred branch
 	;;
-	ld8 r30 = [r10]		// clocksource->mmio_ptr
-	movl r19 = itc_lastcycle
-	add r23 = IA64_CLOCKSOURCE_SHIFT_OFFSET,r20
+	add r26 = IA64_CLKSRC_CYCLE_LAST_OFFSET,r20 // clksrc_cycle_last
 	cmp.ne p6, p0 = 0, r2	// Fallback if work is scheduled
 (p6)    br.cond.spnt.many fsys_fallback_syscall
+	;; // get lock.seq here new code, outer loop2!
+.time_redo:
+	ld4.acq r28 = [r20]	// gtod_lock.sequence, Must be first in struct
+	ld8 r30 = [r21]		// clocksource->mmio_ptr
+	add r24 = IA64_CLKSRC_MULT_OFFSET,r20
+	ld4 r2 = [r29]		// itc_jitter value
+	add r23 = IA64_CLKSRC_SHIFT_OFFSET,r20
+	add r14 = IA64_CLKSRC_MASK_OFFSET,r20
 	;;
+	ld4 r3 = [r24]		// clocksource mult value
 	ld8 r14 = [r14]         // clocksource mask value
-	ld4 r2 = [r22]		// itc_jitter value
-	add r26 = IA64_CLOCKSOURCE_CYCLE_LAST_OFFSET,r20 // clock fsyscall_cycle_last
-	ld4 r3 = [r24]		// clocksource->mult value
 	cmp.eq p8,p9 = 0,r30	// Check for cpu timer, no mmio_ptr, set p8, clear p9
 	;;
 	setf.sig f7 = r3	// Setup for mult scaling of counter
-(p15)	movl r22 = wall_to_monotonic
-	ld4 r21 = [r23]		// shift value
-(p8)	cmp.ne p13,p0 = r2,r0	// need jitter compensation, set p13
+(p8)	cmp.ne p13,p0 = r2,r0	// need itc_jitter compensation, set p13
+	ld4 r23 = [r23]		// clocksource shift value
+	ld8 r24 = [r26]		// get clksrc_cycle_last value
 (p9)	cmp.eq p13,p0 = 0,r30	// if mmio_ptr, clear p13 jitter control
-	;;
-.time_redo:
-	.pred.rel.mutex p8,p9,p10
-	ld4.acq r28 = [r29]	// xtime_lock.sequence. Must come first for locking purposes
+	;; // old position for lock seq, new inner loop1!
+.cmpxchg_redo:
+	.pred.rel.mutex p8,p9
 (p8)	mov r2 = ar.itc		// CPU_TIMER. 36 clocks latency!!!
 (p9)	ld8 r2 = [r30]		// readq(ti->address). Could also have latency issues..
 (p13)	ld8 r25 = [r19]		// get itc_lastcycle value
 	;;			// could be removed by moving the last add upward
  	ld8 r9 = [r27],IA64_TIMESPEC_TV_NSEC_OFFSET
-	ld8 r24 = [r26]		// get fsyscall_cycle_last value
 (p15)	ld8 r17 = [r22],IA64_TIMESPEC_TV_NSEC_OFFSET
 	;;
 	ld8 r8 = [r27],-IA64_TIMESPEC_TV_NSEC_OFFSET	// xtime.tv_nsec
@@ -265,21 +269,23 @@ EX(.fail_efault, probe.w.fault r31, 3)	/
 	xmpy.l f8 = f8,f7	// nsec_per_cyc*(counter-last_counter)
 (p15)	add r9 = r9,r17		// Add wall to monotonic.secs to result secs
 	;;
+	// End cmpxchg critical section loop1
 (p15)	ld8 r17 = [r22],-IA64_TIMESPEC_TV_NSEC_OFFSET
 (p7)	cmp.ne p7,p0 = r25,r3	// if cmpxchg not successful redo
+(p7)	br.cond.dpnt.few .cmpxchg_redo	// inner loop1
 	// simulate tbit.nz.or p7,p0 = r28,0
 	and r28 = ~1,r28	// Make sequence even to force retry if odd
 	getf.sig r2 = f8
 	mf
 	;;
-	ld4 r10 = [r29]		// xtime_lock.sequence
+	ld4 r10 = [r20]		// gtod_lock.sequence, old xtime_lock.sequence
 (p15)	add r8 = r8, r17	// Add monotonic.nsecs to nsecs
-	shr.u r2 = r2,r21	// shift by factor
+	shr.u r2 = r2,r23	// shift by factor
 	;;		// overloaded 3 bundles!
 	// End critical section.
 	add r8 = r8,r2		// Add xtime.nsecs
 	cmp4.ne.or p7,p0 = r28,r10
-(p7)	br.cond.dpnt.few .time_redo	// sequence number changed ?
+(p7)	br.cond.dpnt.few .time_redo	// sequence number changed, outer loop2
 	// Now r8=tv->tv_nsec and r9=tv->tv_sec
 	mov r10 = r0
 	movl r2 = 1000000000
Index: Linux/arch/ia64/kernel/fsyscall_gtod_data.h
=================================--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ Linux/arch/ia64/kernel/fsyscall_gtod_data.h	2007-04-24 12:54:52.000000000 -0400
@@ -0,0 +1,18 @@
+/*
+ * (c) Copyright 2007 Hewlett-Packard Development Company, L.P.
+ *        Contributed by Peter Keilty <peter.keilty@hp.com>
+ *
+ * fsyscall gettimeofday data
+ */
+
+struct fsyscall_gtod_data_t {
+        seqlock_t lock;
+        cycle_t   clk_mask;
+        u32       clk_mult;
+        u32       clk_shift;
+        void     *clk_fsys_mmio_ptr;
+        cycle_t   clk_cycle_last;
+        cycle_t   itc_lastcycle;
+        int       itc_jitter;
+} __attribute__ ((aligned (L1_CACHE_BYTES)));
+
Index: Linux/arch/ia64/kernel/time.c
=================================--- Linux.orig/arch/ia64/kernel/time.c	2007-04-24 11:40:44.000000000 -0400
+++ Linux/arch/ia64/kernel/time.c	2007-04-24 12:41:28.000000000 -0400
@@ -30,9 +30,13 @@
 #include <asm/sections.h>
 #include <asm/system.h>
 
+#include "fsyscall_gtod_data.h"
+
 static cycle_t itc_get_cycles(void);
-cycle_t	itc_lastcycle __attribute__((aligned(L1_CACHE_BYTES)));
-int	itc_jitter __attribute__((aligned(L1_CACHE_BYTES)));
+
+struct fsyscall_gtod_data_t fsyscall_gtod_data = {
+	.lock = SEQLOCK_UNLOCKED,
+};
 
 volatile int time_keeper_id = 0; /* smp_processor_id() of time-keeper */
 
@@ -50,7 +54,7 @@ static struct clocksource clocksource_it
         .mask           = 0xffffffffffffffffLL,
         .mult           = 0, /*to be caluclated*/
         .shift          = 16,
-        .is_continuous  = 1,
+        .flags          = CLOCK_SOURCE_IS_CONTINUOUS,
 };
 static struct clocksource *clocksource_itc_p;
 
@@ -232,7 +236,7 @@ ia64_init_itm (void)
 		 * even going backward) if the ITC offsets between the individual CPUs
 		 * are too large.
 		 */
-		if (!nojitter) itc_jitter = 1;
+		if (!nojitter) fsyscall_gtod_data.itc_jitter = 1;
 #endif
 	}
 
@@ -248,15 +252,14 @@ ia64_init_itm (void)
 	}
 }
 
-
 static cycle_t itc_get_cycles()
 {
-	if (itc_jitter) {
+	if (fsyscall_gtod_data.itc_jitter) {
 		u64 lcycle;
 		u64 now;
 
 		do {
-			lcycle = itc_lastcycle;
+			lcycle = fsyscall_gtod_data.itc_lastcycle;
 			now = get_cycles();
 			if (lcycle && time_after(lcycle, now))
 				return lcycle;
@@ -266,14 +269,14 @@ static cycle_t itc_get_cycles()
 			 * force to retry until the write lock is released.
 			 */
 			if (spin_is_locked(&xtime_lock.lock)) {
-				itc_lastcycle = now;
+				fsyscall_gtod_data.itc_lastcycle = now;
 				return now;
 			}
 			/* Keep track of the last timer value returned.
 			 * The use of cmpxchg here will cause contention in
 			 * an SMP environment.
 			 */
-		} while (unlikely(cmpxchg(&itc_lastcycle, lcycle, now) != lcycle));
+		} while (likely(cmpxchg(&fsyscall_gtod_data.itc_lastcycle, lcycle, now) != lcycle));
 		return now;
 	} else
 		return get_cycles();
@@ -356,9 +359,19 @@ ia64_setup_printk_clock(void)
 		ia64_printk_clock = ia64_itc_printk_clock;
 }
 
-struct clocksource fsyscall_clock __attribute__((aligned(L1_CACHE_BYTES)));
-
 void update_vsyscall(struct timespec *wall, struct clocksource *c)
 {
-	fsyscall_clock = *c;
+        unsigned long flags;
+
+        write_seqlock_irqsave(&fsyscall_gtod_data.lock, flags);
+
+        /* copy fsyscall clock data */
+        fsyscall_gtod_data.clk_mask = c->mask;
+        fsyscall_gtod_data.clk_mult = c->mult;
+        fsyscall_gtod_data.clk_shift = c->shift;
+        fsyscall_gtod_data.clk_fsys_mmio_ptr = c->fsys_mmio_ptr;
+        fsyscall_gtod_data.clk_cycle_last = c->cycle_last;
+
+        write_sequnlock_irqrestore(&fsyscall_gtod_data.lock, flags);
 }
+
Index: Linux/arch/ia64/sn/kernel/sn2/timer.c
=================================--- Linux.orig/arch/ia64/sn/kernel/sn2/timer.c	2007-04-24 11:40:44.000000000 -0400
+++ Linux/arch/ia64/sn/kernel/sn2/timer.c	2007-04-24 12:32:33.000000000 -0400
@@ -37,7 +37,7 @@ static struct clocksource clocksource_sn
         .mask           = (1LL << 55) - 1,
         .mult           = 0,
         .shift          = 10,
-        .is_continuous  = 1,
+        .flags          = CLOCK_SOURCE_IS_CONTINUOUS,
 };
 
 /*
Index: Linux/drivers/char/hpet.c
=================================--- Linux.orig/drivers/char/hpet.c	2007-04-24 11:40:44.000000000 -0400
+++ Linux/drivers/char/hpet.c	2007-04-26 09:36:31.000000000 -0400
@@ -76,7 +76,7 @@ static struct clocksource clocksource_hp
         .mask           = 0xffffffffffffffffLL,
         .mult           = 0, /*to be caluclated*/
         .shift          = 10,
-        .is_continuous  = 1,
+        .flags          = CLOCK_SOURCE_IS_CONTINUOUS,
 };
 static struct clocksource *hpet_clocksource_p;
 
Index: Linux/kernel/time/ntp.c
=================================--- Linux.orig/kernel/time/ntp.c	2007-04-24 11:40:44.000000000 -0400
+++ Linux/kernel/time/ntp.c	2007-04-24 12:33:24.000000000 -0400
@@ -114,11 +114,6 @@ void second_overflow(void)
 		if (xtime.tv_sec % 86400 = 0) {
 			xtime.tv_sec--;
 			wall_to_monotonic.tv_sec++;
-			/*
-			 * The timer interpolator will make time change
-			 * gradually instead of an immediate jump by one second
-			 */
-			time_interpolator_update(-NSEC_PER_SEC);
 			time_state = TIME_OOP;
 			clock_was_set();
 			printk(KERN_NOTICE "Clock: inserting leap second "
@@ -129,11 +124,6 @@ void second_overflow(void)
 		if ((xtime.tv_sec + 1) % 86400 = 0) {
 			xtime.tv_sec++;
 			wall_to_monotonic.tv_sec--;
-			/*
-			 * Use of time interpolator for a gradual change of
-			 * time
-			 */
-			time_interpolator_update(NSEC_PER_SEC);
 			time_state = TIME_WAIT;
 			clock_was_set();
 			printk(KERN_NOTICE "Clock: deleting leap second "
