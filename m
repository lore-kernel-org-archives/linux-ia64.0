From: Andy Lutomirski <luto@MIT.EDU>
Date: Sun, 10 Jul 2011 03:22:14 +0000
Subject: [PATCH v2 7/8] ia64: Replace clocksource.fsys_mmio with generic arch data
Message-Id: <c5bd454bb6f00d3a29a57266b294c0f3eab9ff0d.1310267866.git.luto@mit.edu>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1310267866.git.luto@mit.edu>
In-Reply-To: <cover.1310267866.git.luto@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: x86@kernel.org
Cc: linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, John Stultz <johnstul@us.ibm.com>, Borislav Petkov <bp@amd64.org>, Andy Lutomirski <luto@MIT.EDU>, Clemens Ladisch <clemens@ladisch.de>, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>

Now that clocksource.archdata is available, use it for ia64-specific
code.

Cc: Clemens Ladisch <clemens@ladisch.de>
Cc: linux-ia64@vger.kernel.org
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: John Stultz <johnstul@us.ibm.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Andy Lutomirski <luto@mit.edu>
---
 arch/ia64/include/asm/clocksource.h |   12 ++++++++++++
 arch/ia64/kernel/cyclone.c          |    2 +-
 arch/ia64/kernel/time.c             |    2 +-
 arch/ia64/sn/kernel/sn2/timer.c     |    2 +-
 drivers/char/hpet.c                 |    2 +-
 include/linux/clocksource.h         |    7 -------
 6 files changed, 16 insertions(+), 11 deletions(-)
 create mode 100644 arch/ia64/include/asm/clocksource.h

diff --git a/arch/ia64/include/asm/clocksource.h b/arch/ia64/include/asm/clocksource.h
new file mode 100644
index 0000000..00eb549
--- /dev/null
+++ b/arch/ia64/include/asm/clocksource.h
@@ -0,0 +1,12 @@
+/* IA64-specific clocksource additions */
+
+#ifndef _ASM_IA64_CLOCKSOURCE_H
+#define _ASM_IA64_CLOCKSOURCE_H
+
+#define __ARCH_HAS_CLOCKSOURCE_DATA
+
+struct arch_clocksource_data {
+	void *fsys_mmio;        /* used by fsyscall asm code */
+};
+
+#endif /* _ASM_IA64_CLOCKSOURCE_H */
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
diff --git a/drivers/char/hpet.c b/drivers/char/hpet.c
index 34d6a1c..0833896 100644
--- a/drivers/char/hpet.c
+++ b/drivers/char/hpet.c
@@ -952,7 +952,7 @@ int hpet_alloc(struct hpet_data *hdp)
 #ifdef CONFIG_IA64
 	if (!hpet_clocksource) {
 		hpet_mctr = (void __iomem *)&hpetp->hp_hpet->hpet_mc;
-		CLKSRC_FSYS_MMIO_SET(clocksource_hpet.fsys_mmio, hpet_mctr);
+		clocksource_hpet.archdata.fsys_mmio = hpet_mctr;
 		clocksource_register_hz(&clocksource_hpet, hpetp->hp_tick_freq);
 		hpetp->hp_clocksource = &clocksource_hpet;
 		hpet_clocksource = &clocksource_hpet;
diff --git a/include/linux/clocksource.h b/include/linux/clocksource.h
index 9ab6b6a..0c79005 100644
--- a/include/linux/clocksource.h
+++ b/include/linux/clocksource.h
@@ -171,13 +171,6 @@ struct clocksource {
 	u32 shift;
 	u64 max_idle_ns;
 
-#ifdef CONFIG_IA64
-	void *fsys_mmio;        /* used by fsyscall asm code */
-#define CLKSRC_FSYS_MMIO_SET(mmio, addr)      ((mmio) = (addr))
-#else
-#define CLKSRC_FSYS_MMIO_SET(mmio, addr)      do { } while (0)
-#endif
-
 #ifdef __ARCH_HAS_CLOCKSOURCE_DATA
 	struct arch_clocksource_data archdata;
 #endif
-- 
1.7.6

