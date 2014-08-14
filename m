From: John Stultz <john.stultz@linaro.org>
Date: Thu, 14 Aug 2014 18:31:42 +0000
Subject: [PATCH] [RFC] ia64: Attempt to update of fsyscall gettime to use modern vsyscall_update
Message-Id: <1408041102-15524-1-git-send-email-john.stultz@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Miroslav Lichvar <mlichvar@redhat.com>, linux-ia64@vger.kernel.org

Sent this out awhile back, and only heard crickets. Figured it was time
to update and resend it.

Ia64 hasn't yet moved away from the old vsyscall_update to the newer
implementation. This is in part due to the vsyscall being implemented
in asm (via the ia64 fsyscall feature), which makes me want to run away.

The core logic change with the updated vsyscall method is that we
preserve the base nanosecond value in shifted nanoseconds, which
allows us to avoid truncating and rounding up to the next nanosecond
every tick to avoid inconsistencies.

Thus the logic moved from
nsec = ((cycle_delta * mult)>>shift) + base_nsec;
to
nsec = ((cycle_delta * mult) + base_snsec) >> shift;

To try to get the discussion going, I've taken a swing at migrating
the update logic and have naievely tried to change the asm logic,
but its quite likely wrong.

NOT BUILD TESTED! (Well, actually I did get it to build, but I'm no
more confident that the code is right here).

Feedback and thoughts would be appreciated!

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Miroslav Lichvar <mlichvar@redhat.com>
Cc: linux-ia64@vger.kernel.org
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 arch/ia64/Kconfig                     |  2 +-
 arch/ia64/kernel/asm-offsets.c        | 12 ++++++++----
 arch/ia64/kernel/fsys.S               |  8 ++++----
 arch/ia64/kernel/fsyscall_gtod_data.h |  6 ++++--
 arch/ia64/kernel/time.c               | 37 ++++++++++++++++++-----------------
 5 files changed, 36 insertions(+), 29 deletions(-)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 64aefb7..d60ebfb 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -43,7 +43,7 @@ config IA64
 	select ARCH_TASK_STRUCT_ALLOCATOR
 	select ARCH_THREAD_INFO_ALLOCATOR
 	select ARCH_CLOCKSOURCE_DATA
-	select GENERIC_TIME_VSYSCALL_OLD
+	select GENERIC_TIME_VSYSCALL
 	select SYSCTL_ARCH_UNALIGN_NO_WARN
 	select HAVE_MOD_ARCH_SPECIFIC
 	select MODULES_USE_ELF_RELA
diff --git a/arch/ia64/kernel/asm-offsets.c b/arch/ia64/kernel/asm-offsets.c
index 60ef83e..a02bc6d 100644
--- a/arch/ia64/kernel/asm-offsets.c
+++ b/arch/ia64/kernel/asm-offsets.c
@@ -268,10 +268,14 @@ void foo(void)
 	/* used by fsys_gettimeofday in arch/ia64/kernel/fsys.S */
 	DEFINE(IA64_GTOD_SEQ_OFFSET,
 	       offsetof (struct fsyscall_gtod_data_t, seq));
-	DEFINE(IA64_GTOD_WALL_TIME_OFFSET,
-		offsetof (struct fsyscall_gtod_data_t, wall_time));
-	DEFINE(IA64_GTOD_MONO_TIME_OFFSET,
-		offsetof (struct fsyscall_gtod_data_t, monotonic_time));
+	DEFINE(IA64_GTOD_WALL_TIME_SEC_OFFSET,
+		offsetof (struct fsyscall_gtod_data_t, wall_time_sec));
+	DEFINE(IA64_GTOD_WALL_TIME_SNSEC_OFFSET,
+		offsetof (struct fsyscall_gtod_data_t, wall_time_snsec));
+	DEFINE(IA64_GTOD_MONO_TIME_SEC_OFFSET,
+		offsetof (struct fsyscall_gtod_data_t, monotonic_time_sec));
+	DEFINE(IA64_GTOD_MONO_TIME_SNSEC_OFFSET,
+		offsetof (struct fsyscall_gtod_data_t, monotonic_time_snsec));
 	DEFINE(IA64_CLKSRC_MASK_OFFSET,
 		offsetof (struct fsyscall_gtod_data_t, clk_mask));
 	DEFINE(IA64_CLKSRC_MULT_OFFSET,
diff --git a/arch/ia64/kernel/fsys.S b/arch/ia64/kernel/fsys.S
index abc6dee..acda4c5 100644
--- a/arch/ia64/kernel/fsys.S
+++ b/arch/ia64/kernel/fsys.S
@@ -197,13 +197,13 @@ ENTRY(fsys_gettimeofday)
 	;;
 	ld4 r2 = [r2]			// process work pending flags
 	movl r29 = itc_jitter_data	// itc_jitter
-	add r22 = IA64_GTOD_WALL_TIME_OFFSET,r20	// wall_time
+	add r22 = IA64_GTOD_WALL_TIME_SEC_OFFSET,r20	// wall_time
 	add r21 = IA64_CLKSRC_MMIO_OFFSET,r20
 	mov pr = r30,0xc000	// Set predicates according to function
 	;;
 	and r2 = TIF_ALLWORK_MASK,r2
 	add r19 = IA64_ITC_LASTCYCLE_OFFSET,r29
-(p15)	add r22 = IA64_GTOD_MONO_TIME_OFFSET,r20	// monotonic_time
+(p15)	add r22 = IA64_GTOD_MONO_TIME_SEC_OFFSET,r20	// monotonic_time
 	;;
 	add r26 = IA64_CLKSRC_CYCLE_LAST_OFFSET,r20	// clksrc_cycle_last
 	cmp.ne p6, p0 = 0, r2	// Fallback if work is scheduled
@@ -265,9 +265,9 @@ EX(.fail_efault, probe.w.fault r31, 3)
 	mf
 	;;
 	ld4 r10 = [r20]		// gtod_lock.sequence
-	shr.u r2 = r2,r23	// shift by factor
-	;;
 	add r8 = r8,r2		// Add xtime.nsecs
+	;;
+	shr.u r8 = r8,r23	// shift by factor
 	cmp4.ne p7,p0 = r28,r10
 (p7)	br.cond.dpnt.few .time_redo	// sequence number changed, redo
 	// End critical section.
diff --git a/arch/ia64/kernel/fsyscall_gtod_data.h b/arch/ia64/kernel/fsyscall_gtod_data.h
index 146b15b..ff292a9 100644
--- a/arch/ia64/kernel/fsyscall_gtod_data.h
+++ b/arch/ia64/kernel/fsyscall_gtod_data.h
@@ -7,8 +7,10 @@
 
 struct fsyscall_gtod_data_t {
 	seqcount_t	seq;
-	struct timespec	wall_time;
-	struct timespec monotonic_time;
+	u64 wall_time_sec;
+	u64 wall_time_snsec;
+	u64 monotonic_time_sec;
+	u64 monotonic_time_snsec;
 	cycle_t		clk_mask;
 	u32		clk_mult;
 	u32		clk_shift;
diff --git a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
index 9a0104a..59c3f4a 100644
--- a/arch/ia64/kernel/time.c
+++ b/arch/ia64/kernel/time.c
@@ -425,30 +425,31 @@ void update_vsyscall_tz(void)
 {
 }
 
-void update_vsyscall_old(struct timespec *wall, struct timespec *wtm,
-			 struct clocksource *c, u32 mult, cycle_t cycle_last)
+void update_vsyscall(struct timekeeper *tk)
 {
 	write_seqcount_begin(&fsyscall_gtod_data.seq);
-
-        /* copy fsyscall clock data */
-        fsyscall_gtod_data.clk_mask = c->mask;
-        fsyscall_gtod_data.clk_mult = mult;
-        fsyscall_gtod_data.clk_shift = c->shift;
-        fsyscall_gtod_data.clk_fsys_mmio = c->archdata.fsys_mmio;
-        fsyscall_gtod_data.clk_cycle_last = cycle_last;
+	/* copy fsyscall clock data */
+	fsyscall_gtod_data.clk_mask = tk->tkr.clock->mask;
+	fsyscall_gtod_data.clk_mult = tk->tkr.mult;
+	fsyscall_gtod_data.clk_shift = tk->tkr.clock->shift;
+	fsyscall_gtod_data.clk_fsys_mmio = tk->tkr.clock->archdata.fsys_mmio;
+	fsyscall_gtod_data.clk_cycle_last = tk->tkr.cycle_last;
 
 	/* copy kernel time structures */
-        fsyscall_gtod_data.wall_time.tv_sec = wall->tv_sec;
-        fsyscall_gtod_data.wall_time.tv_nsec = wall->tv_nsec;
-	fsyscall_gtod_data.monotonic_time.tv_sec = wtm->tv_sec
-							+ wall->tv_sec;
-	fsyscall_gtod_data.monotonic_time.tv_nsec = wtm->tv_nsec
-							+ wall->tv_nsec;
+	fsyscall_gtod_data.wall_time_sec = tk->xtime_sec;
+	fsyscall_gtod_data.wall_time_snsec = tk->tkr.xtime_nsec;
+	fsyscall_gtod_data.monotonic_time_sec = tk->wall_to_monotonic.tv_sec
+							+ tk->xtime_sec;
+	fsyscall_gtod_data.monotonic_time_snsec +			(tk->wall_to_monotonic.tv_nsec << tk->tkr.shift)
+			+ tk->tkr.xtime_nsec;
 
 	/* normalize */
-	while (fsyscall_gtod_data.monotonic_time.tv_nsec >= NSEC_PER_SEC) {
-		fsyscall_gtod_data.monotonic_time.tv_nsec -= NSEC_PER_SEC;
-		fsyscall_gtod_data.monotonic_time.tv_sec++;
+	while (fsyscall_gtod_data.monotonic_time_snsec >+					NSEC_PER_SEC << tk->tkr.shift) {
+		fsyscall_gtod_data.monotonic_time_snsec -+						NSEC_PER_SEC << tk->tkr.shift;
+		fsyscall_gtod_data.monotonic_time_sec++;
 	}
 
 	write_seqcount_end(&fsyscall_gtod_data.seq);
-- 
1.9.1

