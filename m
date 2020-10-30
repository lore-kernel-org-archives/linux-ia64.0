From: Arnd Bergmann <arnd@kernel.org>
Date: Fri, 30 Oct 2020 15:17:54 +0000
Subject: [PATCH v2 11/15] m68k: m68328: use legacy_timer_tick()
Message-Id: <20201030151758.1241164-12-arnd@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201030151758.1241164-1-arnd@kernel.org>
In-Reply-To: <20201030151758.1241164-1-arnd@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Arnd Bergmann <arnd@arndb.de>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Ungerer <gerg@linux-m68k.org>, Finn Thain <fthain@telegraphics.com.au>, Philip Blundell <philb@gnu.org>, Joshua Thompson <funaho@jurai.org>, Sam Creasey <sammy@sammy.net>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Daniel Lezcano <daniel.lezcano@linaro.org>, John Stultz <john.stultz@linaro.org>, Stephen Boyd <sboyd@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, linux-ia64@vger.kernel.org, Parisc List <linux-parisc@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Geert Uytterhoeven <geert@linux-m68k.org>

From: Arnd Bergmann <arnd@arndb.de>

A couple of machines share the m68328 timer code that
is based on calling timer_interrupt(). Change these
to the new and slightly more generic legacy_timer_tick()
helper.

Reviewed-by: Geert Uytterhoeven <geert@linux-m68k.org>
Reviewed-by: Linus Walleij <linus.walleij@linaro.org>
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 arch/m68k/68000/timers.c | 5 ++---
 arch/m68k/Kconfig.cpu    | 3 +++
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/arch/m68k/68000/timers.c b/arch/m68k/68000/timers.c
index e8dfdd2556a5..3aa006f8e7ea 100644
--- a/arch/m68k/68000/timers.c
+++ b/arch/m68k/68000/timers.c
@@ -52,7 +52,6 @@
 #endif
 
 static u32 m68328_tick_cnt;
-static irq_handler_t timer_interrupt;
 
 /***************************************************************************/
 
@@ -62,7 +61,8 @@ static irqreturn_t hw_tick(int irq, void *dummy)
 	TSTAT &= 0;
 
 	m68328_tick_cnt += TICKS_PER_JIFFY;
-	return timer_interrupt(irq, dummy);
+	legacy_timer_tick(1);
+	return IRQ_HANDLED;
 }
 
 /***************************************************************************/
@@ -113,7 +113,6 @@ void hw_timer_init(irq_handler_t handler)
 	/* Enable timer 1 */
 	TCTL |= TCTL_TEN;
 	clocksource_register_hz(&m68328_clk, TICKS_PER_JIFFY*HZ);
-	timer_interrupt = handler;
 }
 
 /***************************************************************************/
diff --git a/arch/m68k/Kconfig.cpu b/arch/m68k/Kconfig.cpu
index 322a35ef14c6..648054d4f860 100644
--- a/arch/m68k/Kconfig.cpu
+++ b/arch/m68k/Kconfig.cpu
@@ -104,6 +104,7 @@ config M68060
 config M68328
 	bool "MC68328"
 	depends on !MMU
+	select LEGACY_TIMER_TICK
 	select M68000
 	help
 	  Motorola 68328 processor support.
@@ -111,6 +112,7 @@ config M68328
 config M68EZ328
 	bool "MC68EZ328"
 	depends on !MMU
+	select LEGACY_TIMER_TICK
 	select M68000
 	help
 	  Motorola 68EX328 processor support.
@@ -118,6 +120,7 @@ config M68EZ328
 config M68VZ328
 	bool "MC68VZ328"
 	depends on !MMU
+	select LEGACY_TIMER_TICK
 	select M68000
 	help
 	  Motorola 68VZ328 processor support.
-- 
2.27.0
