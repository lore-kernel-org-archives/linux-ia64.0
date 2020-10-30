From: Arnd Bergmann <arnd@kernel.org>
Date: Fri, 30 Oct 2020 15:17:55 +0000
Subject: [PATCH v2 12/15] m68k: change remaining timers to legacy_timer_tick
Message-Id: <20201030151758.1241164-13-arnd@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201030151758.1241164-1-arnd@kernel.org>
In-Reply-To: <20201030151758.1241164-1-arnd@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Arnd Bergmann <arnd@arndb.de>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Ungerer <gerg@linux-m68k.org>, Finn Thain <fthain@telegraphics.com.au>, Philip Blundell <philb@gnu.org>, Joshua Thompson <funaho@jurai.org>, Sam Creasey <sammy@sammy.net>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Daniel Lezcano <daniel.lezcano@linaro.org>, John Stultz <john.stultz@linaro.org>, Stephen Boyd <sboyd@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, linux-ia64@vger.kernel.org, Parisc List <linux-parisc@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Geert Uytterhoeven <geert@linux-m68k.org>

From: Arnd Bergmann <arnd@arndb.de>

There are nine more machines that each have their own timer interrupt
calling the m68k timer_interrupt() function through an indirect pointer.

This function is now the same as legacy_timer_tick, so just call that
directly and select the corresponding Kconfig symbol.

Reviewed-by: Geert Uytterhoeven <geert@linux-m68k.org>
Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>
Tested-by: Geert Uytterhoeven <geert@linux-m68k.org>
Reviewed-by: Linus Walleij <linus.walleij@linaro.org>
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 arch/m68k/Kconfig.machine   | 9 +++++++++
 arch/m68k/amiga/config.c    | 6 ++----
 arch/m68k/apollo/config.c   | 6 ++----
 arch/m68k/atari/time.c      | 5 ++---
 arch/m68k/bvme6000/config.c | 5 ++---
 arch/m68k/hp300/time.c      | 5 ++---
 arch/m68k/mac/via.c         | 6 ++----
 arch/m68k/mvme147/config.c  | 5 ++---
 arch/m68k/mvme16x/config.c  | 5 ++---
 arch/m68k/q40/q40ints.c     | 6 ++----
 10 files changed, 27 insertions(+), 31 deletions(-)

diff --git a/arch/m68k/Kconfig.machine b/arch/m68k/Kconfig.machine
index e3c835440d9a..b47ac37484fa 100644
--- a/arch/m68k/Kconfig.machine
+++ b/arch/m68k/Kconfig.machine
@@ -7,6 +7,7 @@ config AMIGA
 	bool "Amiga support"
 	depends on MMU
 	select MMU_MOTOROLA if MMU
+	select LEGACY_TIMER_TICK
 	help
 	  This option enables support for the Amiga series of computers. If
 	  you plan to use this kernel on an Amiga, say Y here and browse the
@@ -17,6 +18,7 @@ config ATARI
 	depends on MMU
 	select MMU_MOTOROLA if MMU
 	select HAVE_ARCH_NVRAM_OPS
+	select LEGACY_TIMER_TICK
 	help
 	  This option enables support for the 68000-based Atari series of
 	  computers (including the TT, Falcon and Medusa). If you plan to use
@@ -28,6 +30,7 @@ config MAC
 	depends on MMU
 	select MMU_MOTOROLA if MMU
 	select HAVE_ARCH_NVRAM_OPS
+	select LEGACY_TIMER_TICK
 	help
 	  This option enables support for the Apple Macintosh series of
 	  computers (yes, there is experimental support now, at least for part
@@ -40,6 +43,7 @@ config APOLLO
 	bool "Apollo support"
 	depends on MMU
 	select MMU_MOTOROLA if MMU
+	select LEGACY_TIMER_TICK
 	help
 	  Say Y here if you want to run Linux on an MC680x0-based Apollo
 	  Domain workstation such as the DN3500.
@@ -58,6 +62,7 @@ config MVME147
 	bool "MVME147 support"
 	depends on MMU
 	depends on VME
+	select LEGACY_TIMER_TICK
 	help
 	  Say Y to include support for early Motorola VME boards.  This will
 	  build a kernel which can run on MVME147 single-board computers.  If
@@ -68,6 +73,7 @@ config MVME16x
 	bool "MVME162, 166 and 167 support"
 	depends on MMU
 	depends on VME
+	select LEGACY_TIMER_TICK
 	help
 	  Say Y to include support for Motorola VME boards.  This will build a
 	  kernel which can run on MVME162, MVME166, MVME167, MVME172, and
@@ -79,6 +85,7 @@ config BVME6000
 	bool "BVME4000 and BVME6000 support"
 	depends on MMU
 	depends on VME
+	select LEGACY_TIMER_TICK
 	help
 	  Say Y to include support for VME boards from BVM Ltd.  This will
 	  build a kernel which can run on BVME4000 and BVME6000 boards.  If
@@ -89,6 +96,7 @@ config HP300
 	bool "HP9000/300 and HP9000/400 support"
 	depends on MMU
 	select MMU_MOTOROLA if MMU
+	select LEGACY_TIMER_TICK
 	help
 	  This option enables support for the HP9000/300 and HP9000/400 series
 	  of workstations. Support for these machines is still somewhat
@@ -115,6 +123,7 @@ config Q40
 	bool "Q40/Q60 support"
 	depends on MMU
 	select MMU_MOTOROLA if MMU
+	select LEGACY_TIMER_TICK
 	help
 	  The Q40 is a Motorola 68040-based successor to the Sinclair QL
 	  manufactured in Germany.  There is an official Q40 home page at
diff --git a/arch/m68k/amiga/config.c b/arch/m68k/amiga/config.c
index 29f92333119e..91dc87b86411 100644
--- a/arch/m68k/amiga/config.c
+++ b/arch/m68k/amiga/config.c
@@ -475,11 +475,9 @@ static u32 clk_total, clk_offset;
 
 static irqreturn_t ciab_timer_handler(int irq, void *dev_id)
 {
-	irq_handler_t timer_routine = dev_id;
-
 	clk_total += jiffy_ticks;
 	clk_offset = 0;
-	timer_routine(0, NULL);
+	legacy_timer_tick(1);
 	timer_heartbeat();
 
 	return IRQ_HANDLED;
@@ -504,7 +502,7 @@ static void __init amiga_sched_init(irq_handler_t timer_routine)
 	 * SCSI code. We'll have to take a look at this later
 	 */
 	if (request_irq(IRQ_AMIGA_CIAB_TA, ciab_timer_handler, IRQF_TIMER,
-			"timer", timer_routine))
+			"timer", NULL))
 		pr_err("Couldn't register timer interrupt\n");
 	/* start timer */
 	ciab.cra |= 0x11;
diff --git a/arch/m68k/apollo/config.c b/arch/m68k/apollo/config.c
index 30915f1a8760..17d59fa6b25b 100644
--- a/arch/m68k/apollo/config.c
+++ b/arch/m68k/apollo/config.c
@@ -168,11 +168,9 @@ void __init config_apollo(void)
 
 irqreturn_t dn_timer_int(int irq, void *dev_id)
 {
-	irq_handler_t timer_handler = dev_id;
-
 	volatile unsigned char x;
 
-	timer_handler(irq, dev_id);
+	legacy_timer_tick(1);
 	timer_heartbeat();
 
 	x = *(volatile unsigned char *)(apollo_timer + 3);
@@ -199,7 +197,7 @@ void dn_sched_init(irq_handler_t timer_routine)
 		*(volatile unsigned char *)(apollo_timer + 0x3));
 #endif
 
-	if (request_irq(IRQ_APOLLO, dn_timer_int, 0, "time", timer_routine))
+	if (request_irq(IRQ_APOLLO, dn_timer_int, 0, "time", NULL))
 		pr_err("Couldn't register timer interrupt\n");
 }
 
diff --git a/arch/m68k/atari/time.c b/arch/m68k/atari/time.c
index ce4a5961ca93..36d811ae09ee 100644
--- a/arch/m68k/atari/time.c
+++ b/arch/m68k/atari/time.c
@@ -41,7 +41,6 @@ static u8 last_timer_count;
 
 static irqreturn_t mfp_timer_c_handler(int irq, void *dev_id)
 {
-	irq_handler_t timer_routine = dev_id;
 	unsigned long flags;
 
 	local_irq_save(flags);
@@ -49,7 +48,7 @@ static irqreturn_t mfp_timer_c_handler(int irq, void *dev_id)
 		last_timer_count = st_mfp.tim_dt_c;
 	} while (last_timer_count = 1);
 	clk_total += INT_TICKS;
-	timer_routine(0, NULL);
+	legacy_timer_tick(1);
 	timer_heartbeat();
 	local_irq_restore(flags);
 
@@ -65,7 +64,7 @@ atari_sched_init(irq_handler_t timer_routine)
     st_mfp.tim_ct_cd = (st_mfp.tim_ct_cd & 15) | 0x60;
     /* install interrupt service routine for MFP Timer C */
     if (request_irq(IRQ_MFP_TIMC, mfp_timer_c_handler, IRQF_TIMER, "timer",
-                    timer_routine))
+                    NULL))
 	pr_err("Couldn't register timer interrupt\n");
 
     clocksource_register_hz(&atari_clk, INT_CLK);
diff --git a/arch/m68k/bvme6000/config.c b/arch/m68k/bvme6000/config.c
index 50f4d01363df..d3f5963021d3 100644
--- a/arch/m68k/bvme6000/config.c
+++ b/arch/m68k/bvme6000/config.c
@@ -165,7 +165,6 @@ static u32 clk_total, clk_offset;
 
 static irqreturn_t bvme6000_timer_int (int irq, void *dev_id)
 {
-    irq_handler_t timer_routine = dev_id;
     unsigned long flags;
     volatile RtcPtr_t rtc = (RtcPtr_t)BVME_RTC_BASE;
     unsigned char msr;
@@ -175,7 +174,7 @@ static irqreturn_t bvme6000_timer_int (int irq, void *dev_id)
     rtc->msr = msr | 0x20;		/* Ack the interrupt */
     clk_total += RTC_TIMER_CYCLES;
     clk_offset = 0;
-    timer_routine(0, NULL);
+    legacy_timer_tick(1);
     local_irq_restore(flags);
 
     return IRQ_HANDLED;
@@ -198,7 +197,7 @@ void bvme6000_sched_init (irq_handler_t timer_routine)
     rtc->msr = 0;	/* Ensure timer registers accessible */
 
     if (request_irq(BVME_IRQ_RTC, bvme6000_timer_int, IRQF_TIMER, "timer",
-                    timer_routine))
+                    NULL))
 	panic ("Couldn't register timer int");
 
     rtc->t1cr_omr = 0x04;	/* Mode 2, ext clk */
diff --git a/arch/m68k/hp300/time.c b/arch/m68k/hp300/time.c
index e3cd938de0f9..011fc2e5a68a 100644
--- a/arch/m68k/hp300/time.c
+++ b/arch/m68k/hp300/time.c
@@ -55,7 +55,6 @@ static u32 clk_total, clk_offset;
 
 static irqreturn_t hp300_tick(int irq, void *dev_id)
 {
-	irq_handler_t timer_routine = dev_id;
 	unsigned long flags;
 	unsigned long tmp;
 
@@ -64,7 +63,7 @@ static irqreturn_t hp300_tick(int irq, void *dev_id)
 	asm volatile ("movpw %1@(5),%0" : "=d" (tmp) : "a" (CLOCKBASE));
 	clk_total += INTVAL;
 	clk_offset = 0;
-	timer_routine(0, NULL);
+	legacy_timer_tick(1);
 	timer_heartbeat();
 	local_irq_restore(flags);
 
@@ -106,7 +105,7 @@ void __init hp300_sched_init(irq_handler_t vector)
 
   asm volatile(" movpw %0,%1@(5)" : : "d" (INTVAL), "a" (CLOCKBASE));
 
-  if (request_irq(IRQ_AUTO_6, hp300_tick, IRQF_TIMER, "timer tick", vector))
+  if (request_irq(IRQ_AUTO_6, hp300_tick, IRQF_TIMER, "timer tick", NULL))
     pr_err("Couldn't register timer interrupt\n");
 
   out_8(CLOCKBASE + CLKCR2, 0x1);		/* select CR1 */
diff --git a/arch/m68k/mac/via.c b/arch/m68k/mac/via.c
index ac77d73af19a..ba444e1774b8 100644
--- a/arch/m68k/mac/via.c
+++ b/arch/m68k/mac/via.c
@@ -602,11 +602,9 @@ static u32 clk_total, clk_offset;
 
 static irqreturn_t via_timer_handler(int irq, void *dev_id)
 {
-	irq_handler_t timer_routine = dev_id;
-
 	clk_total += VIA_TIMER_CYCLES;
 	clk_offset = 0;
-	timer_routine(0, NULL);
+	legacy_timer_tick(1);
 
 	return IRQ_HANDLED;
 }
@@ -614,7 +612,7 @@ static irqreturn_t via_timer_handler(int irq, void *dev_id)
 void __init via_init_clock(irq_handler_t timer_routine)
 {
 	if (request_irq(IRQ_MAC_TIMER_1, via_timer_handler, IRQF_TIMER, "timer",
-			timer_routine)) {
+			NULL)) {
 		pr_err("Couldn't register %s interrupt\n", "timer");
 		return;
 	}
diff --git a/arch/m68k/mvme147/config.c b/arch/m68k/mvme147/config.c
index 490700aa2212..5dabbc915b8d 100644
--- a/arch/m68k/mvme147/config.c
+++ b/arch/m68k/mvme147/config.c
@@ -112,14 +112,13 @@ static u32 clk_total;
 
 static irqreturn_t mvme147_timer_int (int irq, void *dev_id)
 {
-	irq_handler_t timer_routine = dev_id;
 	unsigned long flags;
 
 	local_irq_save(flags);
 	m147_pcc->t1_int_cntrl = PCC_TIMER_INT_CLR;
 	m147_pcc->t1_cntrl = PCC_TIMER_CLR_OVF;
 	clk_total += PCC_TIMER_CYCLES;
-	timer_routine(0, NULL);
+	legacy_timer_tick(1);
 	local_irq_restore(flags);
 
 	return IRQ_HANDLED;
@@ -129,7 +128,7 @@ static irqreturn_t mvme147_timer_int (int irq, void *dev_id)
 void mvme147_sched_init (irq_handler_t timer_routine)
 {
 	if (request_irq(PCC_IRQ_TIMER1, mvme147_timer_int, IRQF_TIMER,
-			"timer 1", timer_routine))
+			"timer 1", NULL))
 		pr_err("Couldn't register timer interrupt\n");
 
 	/* Init the clock with a value */
diff --git a/arch/m68k/mvme16x/config.c b/arch/m68k/mvme16x/config.c
index 5b86d10e0f84..ae9bb7fda161 100644
--- a/arch/m68k/mvme16x/config.c
+++ b/arch/m68k/mvme16x/config.c
@@ -372,14 +372,13 @@ static u32 clk_total;
 
 static irqreturn_t mvme16x_timer_int (int irq, void *dev_id)
 {
-	irq_handler_t timer_routine = dev_id;
 	unsigned long flags;
 
 	local_irq_save(flags);
 	out_8(PCCTIC1, in_8(PCCTIC1) | PCCTIC1_INT_CLR);
 	out_8(PCCTOVR1, PCCTOVR1_OVR_CLR);
 	clk_total += PCC_TIMER_CYCLES;
-	timer_routine(0, NULL);
+	legacy_timer_tick(1);
 	local_irq_restore(flags);
 
 	return IRQ_HANDLED;
@@ -396,7 +395,7 @@ void mvme16x_sched_init (irq_handler_t timer_routine)
     out_8(PCCTOVR1, in_8(PCCTOVR1) | PCCTOVR1_TIC_EN | PCCTOVR1_COC_EN);
     out_8(PCCTIC1, PCCTIC1_INT_EN | 6);
     if (request_irq(MVME16x_IRQ_TIMER, mvme16x_timer_int, IRQF_TIMER, "timer",
-                    timer_routine))
+                    NULL))
 	panic ("Couldn't register timer int");
 
     clocksource_register_hz(&mvme16x_clk, PCC_TIMER_CLOCK_FREQ);
diff --git a/arch/m68k/q40/q40ints.c b/arch/m68k/q40/q40ints.c
index b01b545a2db0..4c6c409053fd 100644
--- a/arch/m68k/q40/q40ints.c
+++ b/arch/m68k/q40/q40ints.c
@@ -130,8 +130,6 @@ void q40_mksound(unsigned int hz, unsigned int ticks)
 
 static irqreturn_t q40_timer_int(int irq, void *dev_id)
 {
-	irq_handler_t timer_routine = dev_id;
-
 	ql_ticks = ql_ticks ? 0 : 1;
 	if (sound_ticks) {
 		unsigned char sval=(sound_ticks & 1) ? 128-SVOL : 128+SVOL;
@@ -144,7 +142,7 @@ static irqreturn_t q40_timer_int(int irq, void *dev_id)
 		unsigned long flags;
 
 		local_irq_save(flags);
-		timer_routine(0, NULL);
+		legacy_timer_tick(1);
 		timer_heartbeat();
 		local_irq_restore(flags);
 	}
@@ -157,7 +155,7 @@ void q40_sched_init (irq_handler_t timer_routine)
 
 	timer_irq = Q40_IRQ_FRAME;
 
-	if (request_irq(timer_irq, q40_timer_int, 0, "timer", timer_routine))
+	if (request_irq(timer_irq, q40_timer_int, 0, "timer", NULL))
 		panic("Couldn't register timer int");
 
 	master_outb(-1, FRAME_CLEAR_REG);
-- 
2.27.0
