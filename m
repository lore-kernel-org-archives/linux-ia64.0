From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 31 Oct 2017 18:50:57 +0000
Subject: [PATCH] ia64: Update fsyscall gettime to use modern vsyscall_update
Message-Id: <20171031185057.2166-1-tony.luck@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Tony Luck <tony.luck@intel.com>

John Stultz provided the outline for this patch back in May 2014 here:

	http://patches.linaro.org/patch/30501/

but I let this sit on the shelf for too long and in the intervening
years almost every field in "struct timekeeper" was changed. So this
is almost completely different from his original. Though the key change
in arch/ia64/kernel/fsys.S remains the same.

The core logic change with the updated vsyscall method is that we
preserve the base nanosecond value in shifted nanoseconds, which
allows us to avoid truncating and rounding up to the next nanosecond
every tick to avoid inconsistencies.

Thus the logic moved from
nsec = ((cycle_delta * mult)>>shift) + base_nsec;
to
nsec = ((cycle_delta * mult) + base_snsec) >> shift;

Cc: John Stultz <john.stultz@linaro.org>
Cc: linux-ia64@vger.kernel.org
Signed-off-by: Tony Luck <tony.luck@intel.com>
---
Tried this out with the "timers" kselftest and it passes all the same
tests that worked before this change (clocksource-switch and set-tz
continue to fail).

 arch/ia64/Kconfig                     |  2 +-
 arch/ia64/kernel/asm-offsets.c        |  2 ++
 arch/ia64/kernel/fsys.S               |  8 +++----
 arch/ia64/kernel/fsyscall_gtod_data.h | 10 +++++++--
 arch/ia64/kernel/time.c               | 40 ++++++++++++++++++-----------------
 5 files changed, 36 insertions(+), 26 deletions(-)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 6a15083cc366..4d032e7f1637 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -46,7 +46,7 @@ config IA64
 	select ARCH_TASK_STRUCT_ALLOCATOR
 	select ARCH_THREAD_STACK_ALLOCATOR
 	select ARCH_CLOCKSOURCE_DATA
-	select GENERIC_TIME_VSYSCALL_OLD
+	select GENERIC_TIME_VSYSCALL
 	select SYSCTL_ARCH_UNALIGN_NO_WARN
 	select HAVE_MOD_ARCH_SPECIFIC
 	select MODULES_USE_ELF_RELA
diff --git a/arch/ia64/kernel/asm-offsets.c b/arch/ia64/kernel/asm-offsets.c
index 798bdb209d00..c5eecf3e76fc 100644
--- a/arch/ia64/kernel/asm-offsets.c
+++ b/arch/ia64/kernel/asm-offsets.c
@@ -211,6 +211,8 @@ void foo(void)
 	BLANK();
 	DEFINE(IA64_TIMESPEC_TV_NSEC_OFFSET,
 	       offsetof (struct timespec, tv_nsec));
+	DEFINE(IA64_TIME_SN_SPEC_SNSEC_OFFSET,
+	       offsetof (struct time_sn_spec, snsec));
 
 	DEFINE(CLONE_SETTLS_BIT, 19);
 #if CLONE_SETTLS != (1<<19)
diff --git a/arch/ia64/kernel/fsys.S b/arch/ia64/kernel/fsys.S
index edbf7af95849..0d3c7abb31a8 100644
--- a/arch/ia64/kernel/fsys.S
+++ b/arch/ia64/kernel/fsys.S
@@ -235,9 +235,9 @@ ENTRY(fsys_gettimeofday)
 	MOV_FROM_ITC(p8, p6, r2, r10)	// CPU_TIMER. 36 clocks latency!!!
 (p9)	ld8 r2 = [r30]		// MMIO_TIMER. Could also have latency issues..
 (p13)	ld8 r25 = [r19]		// get itc_lastcycle value
-	ld8 r9 = [r22],IA64_TIMESPEC_TV_NSEC_OFFSET	// tv_sec
+	ld8 r9 = [r22],IA64_TIME_SN_SPEC_SNSEC_OFFSET	// sec
 	;;
-	ld8 r8 = [r22],-IA64_TIMESPEC_TV_NSEC_OFFSET	// tv_nsec
+	ld8 r8 = [r22],-IA64_TIME_SN_SPEC_SNSEC_OFFSET	// snsec
 (p13)	sub r3 = r25,r2		// Diff needed before comparison (thanks davidm)
 	;;
 (p13)	cmp.gt.unc p6,p7 = r3,r0 // check if it is less than last. p6,p7 cleared
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
index dcc514917731..28363bfc9f57 100644
--- a/arch/ia64/kernel/fsyscall_gtod_data.h
+++ b/arch/ia64/kernel/fsyscall_gtod_data.h
@@ -5,10 +5,16 @@
  * fsyscall gettimeofday data
  */
 
+/* like timespec, but includes "shifted nanoseconds" */
+struct time_sn_spec {
+	u64	sec;
+	u64	snsec;
+};
+
 struct fsyscall_gtod_data_t {
 	seqcount_t	seq;
-	struct timespec	wall_time;
-	struct timespec monotonic_time;
+	struct time_sn_spec wall_time;
+	struct time_sn_spec monotonic_time;
 	u64		clk_mask;
 	u32		clk_mult;
 	u32		clk_shift;
diff --git a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
index aa7be020a904..c6ecb97151a2 100644
--- a/arch/ia64/kernel/time.c
+++ b/arch/ia64/kernel/time.c
@@ -430,30 +430,32 @@ void update_vsyscall_tz(void)
 {
 }
 
-void update_vsyscall_old(struct timespec *wall, struct timespec *wtm,
-			 struct clocksource *c, u32 mult, u64 cycle_last)
+void update_vsyscall(struct timekeeper *tk)
 {
 	write_seqcount_begin(&fsyscall_gtod_data.seq);
 
-        /* copy fsyscall clock data */
-        fsyscall_gtod_data.clk_mask = c->mask;
-        fsyscall_gtod_data.clk_mult = mult;
-        fsyscall_gtod_data.clk_shift = c->shift;
-        fsyscall_gtod_data.clk_fsys_mmio = c->archdata.fsys_mmio;
-        fsyscall_gtod_data.clk_cycle_last = cycle_last;
-
-	/* copy kernel time structures */
-        fsyscall_gtod_data.wall_time.tv_sec = wall->tv_sec;
-        fsyscall_gtod_data.wall_time.tv_nsec = wall->tv_nsec;
-	fsyscall_gtod_data.monotonic_time.tv_sec = wtm->tv_sec
-							+ wall->tv_sec;
-	fsyscall_gtod_data.monotonic_time.tv_nsec = wtm->tv_nsec
-							+ wall->tv_nsec;
+	/* copy vsyscall data */
+	fsyscall_gtod_data.clk_mask = tk->tkr_mono.mask;
+	fsyscall_gtod_data.clk_mult = tk->tkr_mono.mult;
+	fsyscall_gtod_data.clk_shift = tk->tkr_mono.shift;
+	fsyscall_gtod_data.clk_fsys_mmio = tk->tkr_mono.clock->archdata.fsys_mmio;
+	fsyscall_gtod_data.clk_cycle_last = tk->tkr_mono.cycle_last;
+
+	fsyscall_gtod_data.wall_time.sec = tk->xtime_sec;
+	fsyscall_gtod_data.wall_time.snsec = tk->tkr_mono.xtime_nsec;
+
+	fsyscall_gtod_data.monotonic_time.sec = tk->xtime_sec
+					      + tk->wall_to_monotonic.tv_sec;
+	fsyscall_gtod_data.monotonic_time.snsec = tk->tkr_mono.xtime_nsec
+						+ ((u64)tk->wall_to_monotonic.tv_nsec
+							<< tk->tkr_mono.shift);
 
 	/* normalize */
-	while (fsyscall_gtod_data.monotonic_time.tv_nsec >= NSEC_PER_SEC) {
-		fsyscall_gtod_data.monotonic_time.tv_nsec -= NSEC_PER_SEC;
-		fsyscall_gtod_data.monotonic_time.tv_sec++;
+	while (fsyscall_gtod_data.monotonic_time.snsec >+					(((u64)NSEC_PER_SEC) << tk->tkr_mono.shift)) {
+		fsyscall_gtod_data.monotonic_time.snsec -+					((u64)NSEC_PER_SEC) << tk->tkr_mono.shift;
+		fsyscall_gtod_data.monotonic_time.sec++;
 	}
 
 	write_seqcount_end(&fsyscall_gtod_data.seq);
-- 
2.11.0

