From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 08 Oct 2020 15:46:45 +0000
Subject: [PATCH 07/13] m68k: sun3/sun3c: use legacy_timer_tick
Message-Id: <20201008154651.1901126-8-arnd@arndb.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201008154651.1901126-1-arnd@arndb.de>
In-Reply-To: <20201008154651.1901126-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Arnd Bergmann <arnd@arndb.de>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Ungerer <gerg@linux-m68k.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Finn Thain <fthain@telegraphics.com.au>, Philip Blundell <philb@gnu.org>, Joshua Thompson <funaho@jurai.org>, Sam Creasey <sammy@sammy.net>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Thomas Gleixner <tglx@linutronix.de>, Daniel Lezcano <daniel.lezcano@linaro.org>, John Stultz <john.stultz@linaro.org>, Stephen Boyd <sboyd@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-arm-kernel@lists.infradead.org

These two are different from all other machines:

* sun3 does not call timer_routine() but open-codes it
  except for the profile_tick() call that appears to
  be unintentionally missing.

* sun3x has a commented-out timer irq handler but no
  functional timer tick I could find.

Change both to calling the new legacy_timer_tick here,
which includes the call to profile_tick() but does not
fix sun3x as that is still commented out.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 arch/m68k/Kconfig.machine | 2 ++
 arch/m68k/sun3/sun3ints.c | 3 +--
 arch/m68k/sun3x/time.c    | 3 +--
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/m68k/Kconfig.machine b/arch/m68k/Kconfig.machine
index 17e8c3a292d7..e3c835440d9a 100644
--- a/arch/m68k/Kconfig.machine
+++ b/arch/m68k/Kconfig.machine
@@ -99,6 +99,7 @@ config HP300
 config SUN3X
 	bool "Sun3x support"
 	depends on MMU
+	select LEGACY_TIMER_TICK
 	select MMU_MOTOROLA if MMU
 	select M68030
 	help
@@ -126,6 +127,7 @@ config SUN3
 	depends on MMU
 	depends on !MMU_MOTOROLA
 	select MMU_SUN3 if MMU
+	select LEGACY_TIMER_TICK
 	select NO_DMA
 	select M68020
 	help
diff --git a/arch/m68k/sun3/sun3ints.c b/arch/m68k/sun3/sun3ints.c
index a5824abb4a39..41ae422119d3 100644
--- a/arch/m68k/sun3/sun3ints.c
+++ b/arch/m68k/sun3/sun3ints.c
@@ -73,8 +73,7 @@ static irqreturn_t sun3_int5(int irq, void *dev_id)
 #ifdef CONFIG_SUN3
 	intersil_clear();
 #endif
-	xtime_update(1);
-	update_process_times(user_mode(get_irq_regs()));
+	legacy_timer_tick(1);
 	cnt = kstat_irqs_cpu(irq, 0);
 	if (!(cnt % 20))
 		sun3_leds(led_pattern[cnt % 160 / 20]);
diff --git a/arch/m68k/sun3x/time.c b/arch/m68k/sun3x/time.c
index 9163294b0fb6..f6e25fdc008c 100644
--- a/arch/m68k/sun3x/time.c
+++ b/arch/m68k/sun3x/time.c
@@ -77,14 +77,13 @@ int sun3x_hwclk(int set, struct rtc_time *t)
 #if 0
 static irqreturn_t sun3x_timer_tick(int irq, void *dev_id)
 {
-	irq_handler_t timer_routine = dev_id;
 	unsigned long flags;
 
 	local_irq_save(flags);
 	/* Clear the pending interrupt - pulse the enable line low */
 	disable_irq(5);
 	enable_irq(5);
-	timer_routine(0, NULL);
+	legacy_timer_tick(1);
 	local_irq_restore(flags);
 
 	return IRQ_HANDLED;
-- 
2.27.0
