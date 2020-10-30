From: Arnd Bergmann <arnd@kernel.org>
Date: Fri, 30 Oct 2020 15:17:57 +0000
Subject: [PATCH v2 14/15] timekeeping: remove xtime_update
Message-Id: <20201030151758.1241164-15-arnd@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201030151758.1241164-1-arnd@kernel.org>
In-Reply-To: <20201030151758.1241164-1-arnd@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Arnd Bergmann <arnd@arndb.de>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Ungerer <gerg@linux-m68k.org>, Finn Thain <fthain@telegraphics.com.au>, Philip Blundell <philb@gnu.org>, Joshua Thompson <funaho@jurai.org>, Sam Creasey <sammy@sammy.net>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Daniel Lezcano <daniel.lezcano@linaro.org>, John Stultz <john.stultz@linaro.org>, Stephen Boyd <sboyd@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, linux-ia64@vger.kernel.org, Parisc List <linux-parisc@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Geert Uytterhoeven <geert@linux-m68k.org>

From: Arnd Bergmann <arnd@arndb.de>

There are no more users of xtime_update aside from legacy_timer_tick(),
so fold it into that function and remove the declaration.

update_process_times() is now only called inside of the kernel/time/
code, so the declaration can be moved there.

Reviewed-by: Geert Uytterhoeven <geert@linux-m68k.org>
Tested-by: Geert Uytterhoeven <geert@linux-m68k.org>
Reviewed-by: Linus Walleij <linus.walleij@linaro.org>
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 include/linux/timekeeping.h |  2 --
 kernel/time/tick-legacy.c   | 22 ++++++++++++++++++++--
 kernel/time/timekeeping.c   | 16 ----------------
 kernel/time/timekeeping.h   |  1 +
 4 files changed, 21 insertions(+), 20 deletions(-)

diff --git a/include/linux/timekeeping.h b/include/linux/timekeeping.h
index 3670cb1670ff..d47009611109 100644
--- a/include/linux/timekeeping.h
+++ b/include/linux/timekeeping.h
@@ -10,8 +10,6 @@ void timekeeping_init(void);
 extern int timekeeping_suspended;
 
 /* Architecture timer tick functions: */
-extern void update_process_times(int user);
-extern void xtime_update(unsigned long ticks);
 extern void legacy_timer_tick(unsigned long ticks);
 
 /*
diff --git a/kernel/time/tick-legacy.c b/kernel/time/tick-legacy.c
index 73c5a0af4743..af225b32f5b3 100644
--- a/kernel/time/tick-legacy.c
+++ b/kernel/time/tick-legacy.c
@@ -10,10 +10,28 @@
 
 #include "tick-internal.h"
 
+/**
+ * legacy_timer_tick() - advances the timekeeping infrastructure
+ * @ticks:	number of ticks, that have elapsed since the last call.
+ *
+ * This is used by platforms that have not been converted to
+ * generic clockevents.
+ *
+ * If 'ticks' is zero, the CPU is not handling timekeeping, so
+ * only perform process accounting and profiling.
+ *
+ * Must be called with interrupts disabled.
+ */
 void legacy_timer_tick(unsigned long ticks)
 {
-	if (ticks)
-		xtime_update(ticks);
+	if (ticks) {
+		raw_spin_lock(&jiffies_lock);
+		write_seqcount_begin(&jiffies_seq);
+		do_timer(ticks);
+		write_seqcount_end(&jiffies_seq);
+		raw_spin_unlock(&jiffies_lock);
+		update_wall_time();
+	}
 	update_process_times(user_mode(get_irq_regs()));
 	profile_tick(CPU_PROFILING);
 }
diff --git a/kernel/time/timekeeping.c b/kernel/time/timekeeping.c
index 52fff7e9edcd..daa0ff017819 100644
--- a/kernel/time/timekeeping.c
+++ b/kernel/time/timekeeping.c
@@ -2438,19 +2438,3 @@ void hardpps(const struct timespec64 *phase_ts, const struct timespec64 *raw_ts)
 }
 EXPORT_SYMBOL(hardpps);
 #endif /* CONFIG_NTP_PPS */
-
-/**
- * xtime_update() - advances the timekeeping infrastructure
- * @ticks:	number of ticks, that have elapsed since the last call.
- *
- * Must be called with interrupts disabled.
- */
-void xtime_update(unsigned long ticks)
-{
-	raw_spin_lock(&jiffies_lock);
-	write_seqcount_begin(&jiffies_seq);
-	do_timer(ticks);
-	write_seqcount_end(&jiffies_seq);
-	raw_spin_unlock(&jiffies_lock);
-	update_wall_time();
-}
diff --git a/kernel/time/timekeeping.h b/kernel/time/timekeeping.h
index 099737f6f10c..d94b69c5b869 100644
--- a/kernel/time/timekeeping.h
+++ b/kernel/time/timekeeping.h
@@ -22,6 +22,7 @@ static inline int sched_clock_suspend(void) { return 0; }
 static inline void sched_clock_resume(void) { }
 #endif
 
+extern void update_process_times(int user);
 extern void do_timer(unsigned long ticks);
 extern void update_wall_time(void);
 
-- 
2.27.0
