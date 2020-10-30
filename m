From: Arnd Bergmann <arnd@kernel.org>
Date: Fri, 30 Oct 2020 15:17:51 +0000
Subject: [PATCH v2 08/15] m68k: coldfire: use legacy_timer_tick()
Message-Id: <20201030151758.1241164-9-arnd@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201030151758.1241164-1-arnd@kernel.org>
In-Reply-To: <20201030151758.1241164-1-arnd@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Arnd Bergmann <arnd@arndb.de>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Ungerer <gerg@linux-m68k.org>, Finn Thain <fthain@telegraphics.com.au>, Philip Blundell <philb@gnu.org>, Joshua Thompson <funaho@jurai.org>, Sam Creasey <sammy@sammy.net>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Daniel Lezcano <daniel.lezcano@linaro.org>, John Stultz <john.stultz@linaro.org>, Stephen Boyd <sboyd@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, linux-ia64@vger.kernel.org, Parisc List <linux-parisc@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>

From: Arnd Bergmann <arnd@arndb.de>

Replace the indirect function calls in the timer code
with direct calls to the newly added legacy_timer_tick()
helper for those that have not yet been converted to
generic clockevents.

This makes the timer code a little more self-contained.

Tested-by: Greg Ungerer <gerg@linux-m68k.org>
Reviewed-by: Linus Walleij <linus.walleij@linaro.org>
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 arch/m68k/Kconfig.cpu         | 35 +++++++++++++++++++++++++++++------
 arch/m68k/coldfire/Makefile   | 32 ++++++++++++++++++--------------
 arch/m68k/coldfire/sltimers.c |  6 ++----
 arch/m68k/coldfire/timers.c   |  6 ++----
 4 files changed, 51 insertions(+), 28 deletions(-)

diff --git a/arch/m68k/Kconfig.cpu b/arch/m68k/Kconfig.cpu
index 694c4fca9f5d..322a35ef14c6 100644
--- a/arch/m68k/Kconfig.cpu
+++ b/arch/m68k/Kconfig.cpu
@@ -137,6 +137,7 @@ config M5206
 	bool "MCF5206"
 	depends on !MMU
 	select COLDFIRE_SW_A7
+	select COLDFIRE_TIMERS
 	select HAVE_MBAR
 	select CPU_NO_EFFICIENT_FFS
 	help
@@ -146,6 +147,7 @@ config M5206e
 	bool "MCF5206e"
 	depends on !MMU
 	select COLDFIRE_SW_A7
+	select COLDFIRE_TIMERS
 	select HAVE_MBAR
 	select CPU_NO_EFFICIENT_FFS
 	help
@@ -154,7 +156,7 @@ config M5206e
 config M520x
 	bool "MCF520x"
 	depends on !MMU
-	select GENERIC_CLOCKEVENTS
+	select COLDFIRE_PIT_TIMER
 	select HAVE_CACHE_SPLIT
 	help
 	   Freescale Coldfire 5207/5208 processor support.
@@ -162,7 +164,7 @@ config M520x
 config M523x
 	bool "MCF523x"
 	depends on !MMU
-	select GENERIC_CLOCKEVENTS
+	select COLDFIRE_PIT_TIMER
 	select HAVE_CACHE_SPLIT
 	select HAVE_IPSBAR
 	help
@@ -172,6 +174,7 @@ config M5249
 	bool "MCF5249"
 	depends on !MMU
 	select COLDFIRE_SW_A7
+	select COLDFIRE_TIMERS
 	select HAVE_MBAR
 	select CPU_NO_EFFICIENT_FFS
 	help
@@ -181,6 +184,7 @@ config M525x
 	bool "MCF525x"
 	depends on !MMU
 	select COLDFIRE_SW_A7
+	select COLDFIRE_TIMERS
 	select HAVE_MBAR
 	select CPU_NO_EFFICIENT_FFS
 	help
@@ -189,10 +193,10 @@ config M525x
 config M5271
 	bool "MCF5271"
 	depends on !MMU
+	select COLDFIRE_PIT_TIMER
 	select M527x
 	select HAVE_CACHE_SPLIT
 	select HAVE_IPSBAR
-	select GENERIC_CLOCKEVENTS
 	help
 	  Freescale (Motorola) ColdFire 5270/5271 processor support.
 
@@ -200,6 +204,7 @@ config M5272
 	bool "MCF5272"
 	depends on !MMU
 	select COLDFIRE_SW_A7
+	select COLDFIRE_TIMERS
 	select HAVE_MBAR
 	select CPU_NO_EFFICIENT_FFS
 	help
@@ -208,17 +213,17 @@ config M5272
 config M5275
 	bool "MCF5275"
 	depends on !MMU
+	select COLDFIRE_PIT_TIMER
 	select M527x
 	select HAVE_CACHE_SPLIT
 	select HAVE_IPSBAR
-	select GENERIC_CLOCKEVENTS
 	help
 	  Freescale (Motorola) ColdFire 5274/5275 processor support.
 
 config M528x
 	bool "MCF528x"
 	depends on !MMU
-	select GENERIC_CLOCKEVENTS
+	select COLDFIRE_PIT_TIMER
 	select HAVE_CACHE_SPLIT
 	select HAVE_IPSBAR
 	help
@@ -227,6 +232,7 @@ config M528x
 config M5307
 	bool "MCF5307"
 	depends on !MMU
+	select COLDFIRE_TIMERS
 	select COLDFIRE_SW_A7
 	select HAVE_CACHE_CB
 	select HAVE_MBAR
@@ -237,6 +243,7 @@ config M5307
 config M532x
 	bool "MCF532x"
 	depends on !MMU
+	select COLDFIRE_TIMERS
 	select M53xx
 	select HAVE_CACHE_CB
 	help
@@ -245,6 +252,7 @@ config M532x
 config M537x
 	bool "MCF537x"
 	depends on !MMU
+	select COLDFIRE_TIMERS
 	select M53xx
 	select HAVE_CACHE_CB
 	help
@@ -254,6 +262,7 @@ config M5407
 	bool "MCF5407"
 	depends on !MMU
 	select COLDFIRE_SW_A7
+	select COLDFIRE_TIMERS
 	select HAVE_CACHE_CB
 	select HAVE_MBAR
 	select CPU_NO_EFFICIENT_FFS
@@ -263,6 +272,7 @@ config M5407
 config M547x
 	bool "MCF547x"
 	select M54xx
+	select COLDFIRE_SLTIMERS
 	select MMU_COLDFIRE if MMU
 	select FPU if MMU
 	select HAVE_CACHE_CB
@@ -273,6 +283,7 @@ config M547x
 
 config M548x
 	bool "MCF548x"
+	select COLDFIRE_SLTIMERS
 	select MMU_COLDFIRE if MMU
 	select FPU if MMU
 	select M54xx
@@ -284,8 +295,8 @@ config M548x
 
 config M5441x
 	bool "MCF5441x"
+	select COLDFIRE_PIT_TIMER
 	select MMU_COLDFIRE if MMU
-	select GENERIC_CLOCKEVENTS
 	select HAVE_CACHE_CB
 	help
 	  Freescale Coldfire 54410/54415/54416/54417/54418 processor support.
@@ -302,6 +313,18 @@ config M54xx
 	select HAVE_PCI
 	bool
 
+config COLDFIRE_PIT_TIMER
+	bool
+	select GENERIC_CLOCKEVENTS
+
+config COLDFIRE_TIMERS
+	bool
+	select LEGACY_TIMER_TICK
+
+config COLDFIRE_SLTIMERS
+	bool
+	select LEGACY_TIMER_TICK
+
 endif # COLDFIRE
 
 
diff --git a/arch/m68k/coldfire/Makefile b/arch/m68k/coldfire/Makefile
index 573eabca1a3a..a3e18d73d8b8 100644
--- a/arch/m68k/coldfire/Makefile
+++ b/arch/m68k/coldfire/Makefile
@@ -16,20 +16,24 @@
 asflags-$(CONFIG_FULLDEBUG) := -DDEBUGGER_COMPATIBLE_CACHE=1
 
 obj-$(CONFIG_COLDFIRE)	+= cache.o clk.o device.o dma.o entry.o vectors.o
-obj-$(CONFIG_M5206)	+= m5206.o timers.o intc.o reset.o
-obj-$(CONFIG_M5206e)	+= m5206.o timers.o intc.o reset.o
-obj-$(CONFIG_M520x)	+= m520x.o pit.o intc-simr.o reset.o
-obj-$(CONFIG_M523x)	+= m523x.o pit.o dma_timer.o intc-2.o reset.o
-obj-$(CONFIG_M5249)	+= m5249.o timers.o intc.o intc-5249.o reset.o
-obj-$(CONFIG_M525x)	+= m525x.o timers.o intc.o intc-525x.o reset.o
-obj-$(CONFIG_M527x)	+= m527x.o pit.o intc-2.o reset.o
-obj-$(CONFIG_M5272)	+= m5272.o intc-5272.o timers.o
-obj-$(CONFIG_M528x)	+= m528x.o pit.o intc-2.o reset.o
-obj-$(CONFIG_M5307)	+= m5307.o timers.o intc.o reset.o
-obj-$(CONFIG_M53xx)	+= m53xx.o timers.o intc-simr.o reset.o
-obj-$(CONFIG_M5407)	+= m5407.o timers.o intc.o reset.o
-obj-$(CONFIG_M54xx)	+= m54xx.o sltimers.o intc-2.o
-obj-$(CONFIG_M5441x)	+= m5441x.o pit.o intc-simr.o reset.o
+obj-$(CONFIG_M5206)	+= m5206.o intc.o reset.o
+obj-$(CONFIG_M5206e)	+= m5206.o intc.o reset.o
+obj-$(CONFIG_M520x)	+= m520x.o intc-simr.o reset.o
+obj-$(CONFIG_M523x)	+= m523x.o dma_timer.o intc-2.o reset.o
+obj-$(CONFIG_M5249)	+= m5249.o intc.o intc-5249.o reset.o
+obj-$(CONFIG_M525x)	+= m525x.o intc.o intc-525x.o reset.o
+obj-$(CONFIG_M527x)	+= m527x.o intc-2.o reset.o
+obj-$(CONFIG_M5272)	+= m5272.o intc-5272.o
+obj-$(CONFIG_M528x)	+= m528x.o intc-2.o reset.o
+obj-$(CONFIG_M5307)	+= m5307.o intc.o reset.o
+obj-$(CONFIG_M53xx)	+= m53xx.o intc-simr.o reset.o
+obj-$(CONFIG_M5407)	+= m5407.o intc.o reset.o
+obj-$(CONFIG_M54xx)	+= m54xx.o intc-2.o
+obj-$(CONFIG_M5441x)	+= m5441x.o intc-simr.o reset.o
+
+obj-$(CONFIG_COLDFIRE_PIT_TIMER) += pit.o
+obj-$(CONFIG_COLDFIRE_TIMERS)	 += timers.o
+obj-$(CONFIG_COLDFIRE_SLTIMERS)	 += sltimers.o
 
 obj-$(CONFIG_NETtel)	+= nettel.o
 obj-$(CONFIG_CLEOPATRA)	+= nettel.o
diff --git a/arch/m68k/coldfire/sltimers.c b/arch/m68k/coldfire/sltimers.c
index 5ab81c9c552d..25a1319f3cb8 100644
--- a/arch/m68k/coldfire/sltimers.c
+++ b/arch/m68k/coldfire/sltimers.c
@@ -83,14 +83,13 @@ void mcfslt_profile_init(void)
 static u32 mcfslt_cycles_per_jiffy;
 static u32 mcfslt_cnt;
 
-static irq_handler_t timer_interrupt;
-
 static irqreturn_t mcfslt_tick(int irq, void *dummy)
 {
 	/* Reset Slice Timer 0 */
 	__raw_writel(MCFSLT_SSR_BE | MCFSLT_SSR_TE, TA(MCFSLT_SSR));
 	mcfslt_cnt += mcfslt_cycles_per_jiffy;
-	return timer_interrupt(irq, dummy);
+	legacy_timer_tick(1);
+	return IRQ_HANDLED;
 }
 
 static u64 mcfslt_read_clk(struct clocksource *cs)
@@ -136,7 +135,6 @@ void hw_timer_init(irq_handler_t handler)
 	/* initialize mcfslt_cnt knowing that slice timers count down */
 	mcfslt_cnt = mcfslt_cycles_per_jiffy;
 
-	timer_interrupt = handler;
 	r = request_irq(MCF_IRQ_TIMER, mcfslt_tick, IRQF_TIMER, "timer", NULL);
 	if (r) {
 		pr_err("Failed to request irq %d (timer): %pe\n", MCF_IRQ_TIMER,
diff --git a/arch/m68k/coldfire/timers.c b/arch/m68k/coldfire/timers.c
index b8301fddf901..24b5e2d1b00b 100644
--- a/arch/m68k/coldfire/timers.c
+++ b/arch/m68k/coldfire/timers.c
@@ -48,8 +48,6 @@ void coldfire_profile_init(void);
 static u32 mcftmr_cycles_per_jiffy;
 static u32 mcftmr_cnt;
 
-static irq_handler_t timer_interrupt;
-
 /***************************************************************************/
 
 static void init_timer_irq(void)
@@ -77,7 +75,8 @@ static irqreturn_t mcftmr_tick(int irq, void *dummy)
 	__raw_writeb(MCFTIMER_TER_CAP | MCFTIMER_TER_REF, TA(MCFTIMER_TER));
 
 	mcftmr_cnt += mcftmr_cycles_per_jiffy;
-	return timer_interrupt(irq, dummy);
+	legacy_timer_tick(1);
+	return IRQ_HANDLED;
 }
 
 /***************************************************************************/
@@ -126,7 +125,6 @@ void hw_timer_init(irq_handler_t handler)
 
 	clocksource_register_hz(&mcftmr_clk, FREQ);
 
-	timer_interrupt = handler;
 	init_timer_irq();
 	r = request_irq(MCF_IRQ_TIMER, mcftmr_tick, IRQF_TIMER, "timer", NULL);
 	if (r) {
-- 
2.27.0
