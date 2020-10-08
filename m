From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 08 Oct 2020 15:46:42 +0000
Subject: [PATCH 04/13] parisc: use legacy_timer_tick
Message-Id: <20201008154651.1901126-5-arnd@arndb.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201008154651.1901126-1-arnd@arndb.de>
In-Reply-To: <20201008154651.1901126-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Arnd Bergmann <arnd@arndb.de>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Ungerer <gerg@linux-m68k.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Finn Thain <fthain@telegraphics.com.au>, Philip Blundell <philb@gnu.org>, Joshua Thompson <funaho@jurai.org>, Sam Creasey <sammy@sammy.net>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Thomas Gleixner <tglx@linutronix.de>, Daniel Lezcano <daniel.lezcano@linaro.org>, John Stultz <john.stultz@linaro.org>, Stephen Boyd <sboyd@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-arm-kernel@lists.infradead.org

parisc has selected CONFIG_GENERIC_CLOCKEVENTS since commit 43b1f6abd590
("parisc: Switch to generic sched_clock implementation"), but does not
appear to actually be using it, and instead calls the low-level
timekeeping functions directly.

Remove the GENERIC_CLOCKEVENTS select again, and instead convert to
the newly added legacy_timer_tick() helper.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 Documentation/features/time/clockevents/arch-support.txt | 2 +-
 arch/parisc/Kconfig                                      | 2 +-
 arch/parisc/kernel/time.c                                | 9 +++------
 3 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/Documentation/features/time/clockevents/arch-support.txt b/Documentation/features/time/clockevents/arch-support.txt
index 8287b6aa522e..61a5c9d68c15 100644
--- a/Documentation/features/time/clockevents/arch-support.txt
+++ b/Documentation/features/time/clockevents/arch-support.txt
@@ -21,7 +21,7 @@
     |       nds32: |  ok  |
     |       nios2: |  ok  |
     |    openrisc: |  ok  |
-    |      parisc: |  ok  |
+    |      parisc: | TODO |
     |     powerpc: |  ok  |
     |       riscv: |  ok  |
     |        s390: |  ok  |
diff --git a/arch/parisc/Kconfig b/arch/parisc/Kconfig
index b234e8154cbd..78b17621ee4a 100644
--- a/arch/parisc/Kconfig
+++ b/arch/parisc/Kconfig
@@ -52,7 +52,7 @@ config PARISC
 	select HAVE_REGS_AND_STACK_ACCESS_API
 	select GENERIC_SCHED_CLOCK
 	select HAVE_UNSTABLE_SCHED_CLOCK if SMP
-	select GENERIC_CLOCKEVENTS
+	select LEGACY_TIMER_TICK
 	select CPU_NO_EFFICIENT_FFS
 	select NEED_DMA_MAP_STATE
 	select NEED_SG_DMA_LENGTH
diff --git a/arch/parisc/kernel/time.c b/arch/parisc/kernel/time.c
index 04508158815c..889aaaa555ea 100644
--- a/arch/parisc/kernel/time.c
+++ b/arch/parisc/kernel/time.c
@@ -70,8 +70,6 @@ irqreturn_t __irq_entry timer_interrupt(int irq, void *dev_id)
 	/* gcc can optimize for "read-only" case with a local clocktick */
 	unsigned long cpt = clocktick;
 
-	profile_tick(CPU_PROFILING);
-
 	/* Initialize next_tick to the old expected tick time. */
 	next_tick = cpuinfo->it_value;
 
@@ -86,10 +84,9 @@ irqreturn_t __irq_entry timer_interrupt(int irq, void *dev_id)
 	cpuinfo->it_value = next_tick;
 
 	/* Go do system house keeping. */
-	if (cpu = 0)
-		xtime_update(ticks_elapsed);
-
-	update_process_times(user_mode(get_irq_regs()));
+	if (cpu != 0)
+		ticks_elapsed = 0;
+	legacy_timer_tick(ticks_elapsed);
 
 	/* Skip clockticks on purpose if we know we would miss those.
 	 * The new CR16 must be "later" than current CR16 otherwise
-- 
2.27.0
