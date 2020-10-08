From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 08 Oct 2020 15:46:46 +0000
Subject: [PATCH 08/13] m68k: m68328: use legacy_timer_tick()
Message-Id: <20201008154651.1901126-9-arnd@arndb.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201008154651.1901126-1-arnd@arndb.de>
In-Reply-To: <20201008154651.1901126-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Arnd Bergmann <arnd@arndb.de>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Ungerer <gerg@linux-m68k.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Finn Thain <fthain@telegraphics.com.au>, Philip Blundell <philb@gnu.org>, Joshua Thompson <funaho@jurai.org>, Sam Creasey <sammy@sammy.net>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Thomas Gleixner <tglx@linutronix.de>, Daniel Lezcano <daniel.lezcano@linaro.org>, John Stultz <john.stultz@linaro.org>, Stephen Boyd <sboyd@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-arm-kernel@lists.infradead.org

A couple of machines share the m68328 timer code that
is based on calling timer_interrupt(). Change these
to the new and slightly more generic legacy_timer_tick()
helper.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 arch/m68k/68000/timers.c  | 5 ++---
 arch/m68k/Kconfig.machine | 4 ++++
 2 files changed, 6 insertions(+), 3 deletions(-)

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
diff --git a/arch/m68k/Kconfig.machine b/arch/m68k/Kconfig.machine
index e3c835440d9a..0ff9338b958e 100644
--- a/arch/m68k/Kconfig.machine
+++ b/arch/m68k/Kconfig.machine
@@ -146,6 +146,7 @@ config PILOT
 config PILOT3
 	bool "Pilot 1000/5000, PalmPilot Personal/Pro, or PalmIII support"
 	depends on M68328
+	select LEGACY_TIMER_TICK
 	select PILOT
 	help
 	  Support for the Palm Pilot 1000/5000, Personal/Pro and PalmIII.
@@ -159,18 +160,21 @@ config XCOPILOT_BUGS
 config UCSIMM
 	bool "uCsimm module support"
 	depends on M68EZ328
+	select LEGACY_TIMER_TICK
 	help
 	  Support for the Arcturus Networks uCsimm module.
 
 config UCDIMM
 	bool "uDsimm module support"
 	depends on M68VZ328
+	select LEGACY_TIMER_TICK
 	help
 	  Support for the Arcturus Networks uDsimm module.
 
 config DRAGEN2
 	bool "DragenEngine II board support"
 	depends on M68VZ328
+	select LEGACY_TIMER_TICK
 	help
 	  Support for the DragenEngine II board.
 
-- 
2.27.0
