From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Wed, 18 Jul 2007 15:08:58 +0000
Subject: [PATCH 2/3] fix ia64 clocksource : separate data for jitter compensation
Message-Id: <469E2D0A.5020103@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This is 2 of 3 patches for ia64 clocksource.

My former patch (1 of 3) revealed that "default" has problem.
It was assumed that something in combination of "fsys + jitter"
is wrong since both of "nojitter (= fsys)" and "nolwsys (= non-fsys
+ jitter)" provides better result.
Especially it is assumed as serious bug that "non-fsys + jitter",
written in C is faster than "fsys + jitter", written in assembler.

I picked up some points:
  - It seems that logics are not so different.
  - both uses jitter-related data in fsys_gtod_data
  - only fsys uses rests of contents of fsys_gtod_data,
    while non-fsys still uses xtime.
  - xtime_lock is larger lock than gtod_lock.

So summary was:
  "reading one structure with small lock"
  is slower than
  "reading two structure with large lock"

I came near to give up, but for some reason, an inspiration hit me,
and at last I caught a line.
> } __attribute__ ((aligned (L1_CACHE_BYTES)));

The imagined situation is that a read from fsys_gtod_data
was disturbed by concurrent cmpxchg of itc_lastcycle,
which located in same cacheline.
If so, it can be explained that why read from xtime is
faster than read from fsys_gtod_data.

So I made this patch to:

  - separate itc_lastcycle from fsys_gtod_data and put
    it on other cacheline.
  - separate itc_jitter from fsys_gtod_data too.
    in fact, itc_lastcycle and itc_jitter are used from
    both of fsys and non-fsys.

Fortunately this patch works well, then the results:

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

become more reasonable, expected level:

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

(Continue to next patch.)

Thanks,
H.Seto

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>

-----
 arch/ia64/kernel/asm-offsets.c        |    6 +++---
 arch/ia64/kernel/fsys.S               |    7 +++++--
 arch/ia64/kernel/fsyscall_gtod_data.h |    5 ++++-
 arch/ia64/kernel/time.c               |   12 +++++++-----
 4 files changed, 19 insertions(+), 11 deletions(-)

Index: linux-2.6.22/arch/ia64/kernel/asm-offsets.c
=================================--- linux-2.6.22.orig/arch/ia64/kernel/asm-offsets.c
+++ linux-2.6.22/arch/ia64/kernel/asm-offsets.c
@@ -274,8 +274,8 @@
 		offsetof (struct fsyscall_gtod_data_t, clk_fsys_mmio));
 	DEFINE(IA64_CLKSRC_CYCLE_LAST_OFFSET,
 		offsetof (struct fsyscall_gtod_data_t, clk_cycle_last));
-	DEFINE(IA64_ITC_LASTCYCLE_OFFSET,
-		offsetof (struct fsyscall_gtod_data_t, itc_lastcycle));
 	DEFINE(IA64_ITC_JITTER_OFFSET,
-		offsetof (struct fsyscall_gtod_data_t, itc_jitter));
+		offsetof (struct itc_jitter_data_t, itc_jitter));
+	DEFINE(IA64_ITC_LASTCYCLE_OFFSET,
+		offsetof (struct itc_jitter_data_t, itc_lastcycle));
 }
Index: linux-2.6.22/arch/ia64/kernel/fsys.S
=================================--- linux-2.6.22.orig/arch/ia64/kernel/fsys.S
+++ linux-2.6.22/arch/ia64/kernel/fsys.S
@@ -150,6 +150,9 @@
 #if IA64_GTOD_LOCK_OFFSET !=0
 #error fsys_gettimeofday incompatible with changes to struct fsyscall_gtod_data_t
 #endif
+#if IA64_ITC_JITTER_OFFSET !=0
+#error fsys_gettimeofday incompatible with changes to struct itc_jitter_data_t
+#endif
 #define CLOCK_REALTIME 0
 #define CLOCK_MONOTONIC 1
 #define CLOCK_DIVIDE_BY_1000 0x4000
@@ -215,13 +218,13 @@
 	add r2 = TI_FLAGS+IA64_TASK_SIZE,r16
 	movl r20 = fsyscall_gtod_data // load fsyscall gettimeofday data address
 	;;
-	add r29 = IA64_ITC_JITTER_OFFSET,r20
+	movl r29 = itc_jitter_data	// itc_jitter
 	add r22 = IA64_GTOD_WALL_TIME_OFFSET,r20	// wall_time
 	ld4 r2 = [r2]		// process work pending flags
 	;;
 (p15)	add r22 = IA64_GTOD_MONO_TIME_OFFSET,r20	// monotonic_time
 	add r21 = IA64_CLKSRC_MMIO_OFFSET,r20
-	add r19 = IA64_ITC_LASTCYCLE_OFFSET,r20
+	add r19 = IA64_ITC_LASTCYCLE_OFFSET,r29
 	and r2 = TIF_ALLWORK_MASK,r2
 (p6)    br.cond.spnt.few .fail_einval	// ? deferred branch
 	;;
Index: linux-2.6.22/arch/ia64/kernel/fsyscall_gtod_data.h
=================================--- linux-2.6.22.orig/arch/ia64/kernel/fsyscall_gtod_data.h
+++ linux-2.6.22/arch/ia64/kernel/fsyscall_gtod_data.h
@@ -14,7 +14,10 @@
 	u32		clk_shift;
 	void		*clk_fsys_mmio;
 	cycle_t		clk_cycle_last;
-	cycle_t		itc_lastcycle;
+} __attribute__ ((aligned (L1_CACHE_BYTES)));
+
+struct itc_jitter_data_t {
 	int		itc_jitter;
+	cycle_t		itc_lastcycle;
 } __attribute__ ((aligned (L1_CACHE_BYTES)));

Index: linux-2.6.22/arch/ia64/kernel/time.c
=================================--- linux-2.6.22.orig/arch/ia64/kernel/time.c
+++ linux-2.6.22/arch/ia64/kernel/time.c
@@ -37,6 +37,8 @@
 	.lock = SEQLOCK_UNLOCKED,
 };

+struct itc_jitter_data_t itc_jitter_data;
+
 volatile int time_keeper_id = 0; /* smp_processor_id() of time-keeper */

 #ifdef CONFIG_IA64_DEBUG_IRQ
@@ -236,7 +238,7 @@
 		 * are too large.
 		 */
 		if (!nojitter)
-			fsyscall_gtod_data.itc_jitter = 1;
+			itc_jitter_data.itc_jitter = 1;
 #endif
 	}

@@ -258,10 +260,10 @@
 	u64 lcycle;
 	u64 now;

-	if (!fsyscall_gtod_data.itc_jitter)
+	if (!itc_jitter_data.itc_jitter)
 		return get_cycles();
 	do {
-		lcycle = fsyscall_gtod_data.itc_lastcycle;
+		lcycle = itc_jitter_data.itc_lastcycle;
 		now = get_cycles();
 		if (lcycle && time_after(lcycle, now))
 			return lcycle;
@@ -271,14 +273,14 @@
 		 * force to retry until the write lock is released.
 		 */
 		if (spin_is_locked(&xtime_lock.lock)) {
-			fsyscall_gtod_data.itc_lastcycle = now;
+			itc_jitter_data.itc_lastcycle = now;
 			return now;
 		}
 		/* Keep track of the last timer value returned.
 		 * The use of cmpxchg here will cause contention in
 		 * an SMP environment.
 		 */
-	} while (likely(cmpxchg(&fsyscall_gtod_data.itc_lastcycle,
+	} while (likely(cmpxchg(&itc_jitter_data.itc_lastcycle,
 				lcycle, now) != lcycle));
 	return now;
 }

