From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 08 Oct 2020 15:46:49 +0000
Subject: [PATCH 11/13] timekeeping: remove xtime_update
Message-Id: <20201008154651.1901126-12-arnd@arndb.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201008154651.1901126-1-arnd@arndb.de>
In-Reply-To: <20201008154651.1901126-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Arnd Bergmann <arnd@arndb.de>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Ungerer <gerg@linux-m68k.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Finn Thain <fthain@telegraphics.com.au>, Philip Blundell <philb@gnu.org>, Joshua Thompson <funaho@jurai.org>, Sam Creasey <sammy@sammy.net>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Thomas Gleixner <tglx@linutronix.de>, Daniel Lezcano <daniel.lezcano@linaro.org>, John Stultz <john.stultz@linaro.org>, Stephen Boyd <sboyd@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-arm-kernel@lists.infradead.org

There are no more users of xtime_update aside from legacy_timer_tick(),
so fold it into that function and remove the declaration.

update_process_times() is now only called inside of the kernel/time/
code, so the declaration can be moved there.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 include/linux/timekeeping.h |  4 +---
 kernel/time/tick-legacy.c   | 22 ++++++++++++++++++++--
 kernel/time/timekeeping.c   | 16 ----------------
 kernel/time/timekeeping.h   |  1 +
 4 files changed, 22 insertions(+), 21 deletions(-)

diff --git a/include/linux/timekeeping.h b/include/linux/timekeeping.h
index 3670cb1670ff..a8bef0ffcbdd 100644
--- a/include/linux/timekeeping.h
+++ b/include/linux/timekeeping.h
@@ -9,9 +9,7 @@
 void timekeeping_init(void);
 extern int timekeeping_suspended;
 
-/* Architecture timer tick functions: */
-extern void update_process_times(int user);
-extern void xtime_update(unsigned long ticks);
+/* Architecture timer tick functions */
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
index 6858a31364b6..2c7814411f83 100644
--- a/kernel/time/timekeeping.c
+++ b/kernel/time/timekeeping.c
@@ -2461,19 +2461,3 @@ void hardpps(const struct timespec64 *phase_ts, const struct timespec64 *raw_ts)
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
