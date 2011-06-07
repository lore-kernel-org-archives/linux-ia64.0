From: Andy Lutomirski <luto@MIT.EDU>
Date: Tue, 07 Jun 2011 19:32:41 +0000
Subject: [PATCH 4/5] clocksource: Replace vread and fsys_mmio with generic arch data
Message-Id: <4a233d5b7421ef8f7805139e3eba68c52c2d0d57.1307474707.git.luto@mit.edu>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1307474707.git.luto@mit.edu>
In-Reply-To: <cover.1307474707.git.luto@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: x86@kernel.org
Cc: linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Andy Lutomirski <luto@MIT.EDU>, Clemens Ladisch <clemens@ladisch.de>, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, John Stultz <johnstul@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>

The vread field was bloating struct clocksource everywhere except
x86_64, and I want to change the way this works on x86_64, so let's
split it out into per-arch data.

Cc: x86@kernel.org
Cc: Clemens Ladisch <clemens@ladisch.de>
Cc: linux-ia64@vger.kernel.org
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: John Stultz <johnstul@us.ibm.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Andy Lutomirski <luto@mit.edu>
---
 arch/ia64/include/asm/clocksource.h |   16 ++++++++++++++++
 arch/ia64/kernel/cyclone.c          |    2 +-
 arch/ia64/kernel/time.c             |    2 +-
 arch/ia64/sn/kernel/sn2/timer.c     |    2 +-
 arch/x86/include/asm/clocksource.h  |   16 ++++++++++++++++
 arch/x86/kernel/hpet.c              |    2 +-
 arch/x86/kernel/tsc.c               |    2 +-
 arch/x86/kernel/vsyscall_64.c       |    2 +-
 drivers/char/hpet.c                 |    2 +-
 include/asm-generic/clocksource.h   |    4 ++++
 include/linux/clocksource.h         |   13 ++++++-------
 11 files changed, 49 insertions(+), 14 deletions(-)
 create mode 100644 arch/ia64/include/asm/clocksource.h
 create mode 100644 arch/x86/include/asm/clocksource.h
 create mode 100644 include/asm-generic/clocksource.h

diff --git a/arch/ia64/include/asm/clocksource.h b/arch/ia64/include/asm/clocksource.h
new file mode 100644
index 0000000..453f363
--- /dev/null
+++ b/arch/ia64/include/asm/clocksource.h
@@ -0,0 +1,16 @@
+/* x86-specific clocksource additions */
+
+#ifndef _ASM_X86_CLOCKSOURCE_H
+#define _ASM_X86_CLOCKSOURCE_H
+
+#ifdef CONFIG_X86_64
+
+#define __ARCH_HAS_CLOCKSOURCE_DATA
+
+struct arch_clocksource_data {
+	void *fsys_mmio;        /* used by fsyscall asm code */
+};
+
+#endif /* CONFIG_X86_64 */
+
+#endif /* _ASM_X86_CLOCKSOURCE_H */
diff --git a/arch/ia64/kernel/cyclone.c b/arch/ia64/kernel/cyclone.c
index f64097b..4826ff9 100644
--- a/arch/ia64/kernel/cyclone.c
+++ b/arch/ia64/kernel/cyclone.c
@@ -115,7 +115,7 @@ int __init init_cyclone_clock(void)
 	}
 	/* initialize last tick */
 	cyclone_mc = cyclone_timer;
-	clocksource_cyclone.fsys_mmio = cyclone_timer;
+	clocksource_cyclone.archdata.fsys_mmio = cyclone_timer;
 	clocksource_register_hz(&clocksource_cyclone, CYCLONE_TIMER_FREQ);
 
 	return 0;
diff --git a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
index 85118df..43920de 100644
--- a/arch/ia64/kernel/time.c
+++ b/arch/ia64/kernel/time.c
@@ -468,7 +468,7 @@ void update_vsyscall(struct timespec *wall, struct timespec *wtm,
         fsyscall_gtod_data.clk_mask = c->mask;
         fsyscall_gtod_data.clk_mult = mult;
         fsyscall_gtod_data.clk_shift = c->shift;
-        fsyscall_gtod_data.clk_fsys_mmio = c->fsys_mmio;
+        fsyscall_gtod_data.clk_fsys_mmio = c->archdata.fsys_mmio;
         fsyscall_gtod_data.clk_cycle_last = c->cycle_last;
 
 	/* copy kernel time structures */
diff --git a/arch/ia64/sn/kernel/sn2/timer.c b/arch/ia64/sn/kernel/sn2/timer.c
index c34efda..0f8844e 100644
--- a/arch/ia64/sn/kernel/sn2/timer.c
+++ b/arch/ia64/sn/kernel/sn2/timer.c
@@ -54,7 +54,7 @@ ia64_sn_udelay (unsigned long usecs)
 
 void __init sn_timer_init(void)
 {
-	clocksource_sn2.fsys_mmio = RTC_COUNTER_ADDR;
+	clocksource_sn2.archdata.fsys_mmio = RTC_COUNTER_ADDR;
 	clocksource_register_hz(&clocksource_sn2, sn_rtc_cycles_per_second);
 
 	ia64_udelay = &ia64_sn_udelay;
diff --git a/arch/x86/include/asm/clocksource.h b/arch/x86/include/asm/clocksource.h
new file mode 100644
index 0000000..a5df33f
--- /dev/null
+++ b/arch/x86/include/asm/clocksource.h
@@ -0,0 +1,16 @@
+/* x86-specific clocksource additions */
+
+#ifndef _ASM_X86_CLOCKSOURCE_H
+#define _ASM_X86_CLOCKSOURCE_H
+
+#ifdef CONFIG_X86_64
+
+#define __ARCH_HAS_CLOCKSOURCE_DATA
+
+struct arch_clocksource_data {
+	cycle_t (*vread)(void);
+};
+
+#endif /* CONFIG_X86_64 */
+
+#endif /* _ASM_X86_CLOCKSOURCE_H */
diff --git a/arch/x86/kernel/hpet.c b/arch/x86/kernel/hpet.c
index e9f5605..0e07257 100644
--- a/arch/x86/kernel/hpet.c
+++ b/arch/x86/kernel/hpet.c
@@ -753,7 +753,7 @@ static struct clocksource clocksource_hpet = {
 	.flags		= CLOCK_SOURCE_IS_CONTINUOUS,
 	.resume		= hpet_resume_counter,
 #ifdef CONFIG_X86_64
-	.vread		= vread_hpet,
+	.archdata	= { .vread = vread_hpet },
 #endif
 };
 
diff --git a/arch/x86/kernel/tsc.c b/arch/x86/kernel/tsc.c
index 6cc6922..e7a74b8 100644
--- a/arch/x86/kernel/tsc.c
+++ b/arch/x86/kernel/tsc.c
@@ -777,7 +777,7 @@ static struct clocksource clocksource_tsc = {
 	.flags                  = CLOCK_SOURCE_IS_CONTINUOUS |
 				  CLOCK_SOURCE_MUST_VERIFY,
 #ifdef CONFIG_X86_64
-	.vread                  = vread_tsc,
+	.archdata               = { .vread = vread_tsc },
 #endif
 };
 
diff --git a/arch/x86/kernel/vsyscall_64.c b/arch/x86/kernel/vsyscall_64.c
index 10cd8ac..eb0d3ef 100644
--- a/arch/x86/kernel/vsyscall_64.c
+++ b/arch/x86/kernel/vsyscall_64.c
@@ -73,7 +73,7 @@ void update_vsyscall(struct timespec *wall_time, struct timespec *wtm,
 	write_seqlock_irqsave(&vsyscall_gtod_data.lock, flags);
 
 	/* copy vsyscall data */
-	vsyscall_gtod_data.clock.vread		= clock->vread;
+	vsyscall_gtod_data.clock.vread		= clock->archdata.vread;
 	vsyscall_gtod_data.clock.cycle_last	= clock->cycle_last;
 	vsyscall_gtod_data.clock.mask		= clock->mask;
 	vsyscall_gtod_data.clock.mult		= mult;
diff --git a/drivers/char/hpet.c b/drivers/char/hpet.c
index 051474c..0557651 100644
--- a/drivers/char/hpet.c
+++ b/drivers/char/hpet.c
@@ -931,7 +931,7 @@ int hpet_alloc(struct hpet_data *hdp)
 #ifdef CONFIG_IA64
 	if (!hpet_clocksource) {
 		hpet_mctr = (void __iomem *)&hpetp->hp_hpet->hpet_mc;
-		CLKSRC_FSYS_MMIO_SET(clocksource_hpet.fsys_mmio, hpet_mctr);
+		clocksource_hpet.archdata.fsys_mmio = hpet_mctr;
 		clocksource_register_hz(&clocksource_hpet, hpetp->hp_tick_freq);
 		hpetp->hp_clocksource = &clocksource_hpet;
 		hpet_clocksource = &clocksource_hpet;
diff --git a/include/asm-generic/clocksource.h b/include/asm-generic/clocksource.h
new file mode 100644
index 0000000..0a462d3
--- /dev/null
+++ b/include/asm-generic/clocksource.h
@@ -0,0 +1,4 @@
+/*
+ * Architectures should override this file to add private userspace
+ * clock magic if needed.
+ */
diff --git a/include/linux/clocksource.h b/include/linux/clocksource.h
index d4646b4..6bb6970 100644
--- a/include/linux/clocksource.h
+++ b/include/linux/clocksource.h
@@ -22,6 +22,8 @@
 typedef u64 cycle_t;
 struct clocksource;
 
+#include <asm/clocksource.h>
+
 /**
  * struct cyclecounter - hardware abstraction for a free running counter
  *	Provides completely state-free accessors to the underlying hardware.
@@ -153,7 +155,7 @@ extern u64 timecounter_cyc2time(struct timecounter *tc,
  * @shift:		cycle to nanosecond divisor (power of two)
  * @max_idle_ns:	max idle time permitted by the clocksource (nsecs)
  * @flags:		flags describing special properties
- * @vread:		vsyscall based read
+ * @archdata:		arch-specific data
  * @suspend:		suspend function for the clocksource, if necessary
  * @resume:		resume function for the clocksource, if necessary
  */
@@ -169,16 +171,13 @@ struct clocksource {
 	u32 shift;
 	u64 max_idle_ns;
 
-#ifdef CONFIG_IA64
-	void *fsys_mmio;        /* used by fsyscall asm code */
-#define CLKSRC_FSYS_MMIO_SET(mmio, addr)      ((mmio) = (addr))
-#else
-#define CLKSRC_FSYS_MMIO_SET(mmio, addr)      do { } while (0)
+#ifdef __ARCH_HAS_CLOCKSOURCE_DATA
+	struct arch_clocksource_data archdata;
 #endif
+
 	const char *name;
 	struct list_head list;
 	int rating;
-	cycle_t (*vread)(void);
 	int (*enable)(struct clocksource *cs);
 	void (*disable)(struct clocksource *cs);
 	unsigned long flags;
-- 
1.7.5.2

