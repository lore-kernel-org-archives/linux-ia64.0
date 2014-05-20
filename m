From: John Stultz <john.stultz@linaro.org>
Date: Tue, 20 May 2014 22:16:42 +0000
Subject: [PATCH] [RFC] ia64: Attempt to update of fsyscall gettime to use modern vsyscall_update
Message-Id: <1400624202-3778-1-git-send-email-john.stultz@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Miroslav Lichvar <mlichvar@redhat.com>, linux-ia64@vger.kernel.org

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

NOT BUILD TESTED!

Feedback and thoughts would be appreciated!

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Miroslav Lichvar <mlichvar@redhat.com>
Cc: linux-ia64@vger.kernel.org
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 arch/ia64/Kconfig                     |  1 -
 arch/ia64/kernel/fsys.S               |  4 ++--
 arch/ia64/kernel/fsyscall_gtod_data.h |  6 ++++--
 arch/ia64/kernel/time.c               | 37 ++++++++++++++++++-----------------
 4 files changed, 25 insertions(+), 23 deletions(-)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 12c3afe..35562fb 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -40,7 +40,6 @@ config IA64
 	select ARCH_TASK_STRUCT_ALLOCATOR
 	select ARCH_THREAD_INFO_ALLOCATOR
 	select ARCH_CLOCKSOURCE_DATA
-	select GENERIC_TIME_VSYSCALL_OLD
 	select SYSCTL_ARCH_UNALIGN_NO_WARN
 	select HAVE_MOD_ARCH_SPECIFIC
 	select MODULES_USE_ELF_RELA
diff --git a/arch/ia64/kernel/fsys.S b/arch/ia64/kernel/fsys.S
index abc6dee..91ae672 100644
--- a/arch/ia64/kernel/fsys.S
+++ b/arch/ia64/kernel/fsys.S
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
index 71c52bc..6b249c5 100644
--- a/arch/ia64/kernel/time.c
+++ b/arch/ia64/kernel/time.c
@@ -440,30 +440,31 @@ void update_vsyscall_tz(void)
 {
 }
 
-void update_vsyscall_old(struct timespec *wall, struct timespec *wtm,
-			struct clocksource *c, u32 mult)
+void update_vsyscall(struct timekeeper *tk)
 {
 	write_seqcount_begin(&fsyscall_gtod_data.seq);
-
-        /* copy fsyscall clock data */
-        fsyscall_gtod_data.clk_mask = c->mask;
-        fsyscall_gtod_data.clk_mult = mult;
-        fsyscall_gtod_data.clk_shift = c->shift;
-        fsyscall_gtod_data.clk_fsys_mmio = c->archdata.fsys_mmio;
-        fsyscall_gtod_data.clk_cycle_last = c->cycle_last;
+	/* copy fsyscall clock data */
+	fsyscall_gtod_data.clk_mask = tk->clock->mask;
+	fsyscall_gtod_data.clk_mult = tk->mult;
+	fsyscall_gtod_data.clk_shift = tk->clock->shift;
+	fsyscall_gtod_data.clk_fsys_mmio = tk->clock->archdata.fsys_mmio;
+	fsyscall_gtod_data.clk_cycle_last = tk->cycle_last;
 
 	/* copy kernel time structures */
-        fsyscall_gtod_data.wall_time.tv_sec = wall->tv_sec;
-        fsyscall_gtod_data.wall_time.tv_nsec = wall->tv_nsec;
-	fsyscall_gtod_data.monotonic_time.tv_sec = wtm->tv_sec
-							+ wall->tv_sec;
-	fsyscall_gtod_data.monotonic_time.tv_nsec = wtm->tv_nsec
-							+ wall->tv_nsec;
+	fsyscall_gtod_data.wall_time_sec = tk->xtime_sec;
+	fsyscall_gtod_data.wall_time_snsec = tk->xtime_nsec;
+	fsyscall_gtod_data.monotonic_time_sec = tk->wall_to_monotonic->tv_sec
+							+ tk->xtime_sec;
+	fsyscall_gtod_data.monotonic_time_snsec +			tk->wall_to_monotonic->tv_nsec << tk->clock->shift,
+			+ tk->xtime_nsec;
 
 	/* normalize */
-	while (fsyscall_gtod_data.monotonic_time.tv_nsec >= NSEC_PER_SEC) {
-		fsyscall_gtod_data.monotonic_time.tv_nsec -= NSEC_PER_SEC;
-		fsyscall_gtod_data.monotonic_time.tv_sec++;
+	while (fsyscall_gtod_data.monotonic_time_snsec >+					NSEC_PER_SEC << tk->clock->shift) {
+		fsyscall_gtod_data.monotonic_time_snsec -+						NSEC_PER_SEC << c->shift;
+		fsyscall_gtod_data.monotonic_time_sec++;
 	}
 
 	write_seqcount_end(&fsyscall_gtod_data.seq);
-- 
1.9.1

