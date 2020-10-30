From: Arnd Bergmann <arnd@kernel.org>
Date: Fri, 30 Oct 2020 15:17:56 +0000
Subject: [PATCH v2 13/15] m68k: remove timer_interrupt() function
Message-Id: <20201030151758.1241164-14-arnd@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201030151758.1241164-1-arnd@kernel.org>
In-Reply-To: <20201030151758.1241164-1-arnd@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Arnd Bergmann <arnd@arndb.de>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Ungerer <gerg@linux-m68k.org>, Finn Thain <fthain@telegraphics.com.au>, Philip Blundell <philb@gnu.org>, Joshua Thompson <funaho@jurai.org>, Sam Creasey <sammy@sammy.net>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Daniel Lezcano <daniel.lezcano@linaro.org>, John Stultz <john.stultz@linaro.org>, Stephen Boyd <sboyd@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, linux-ia64@vger.kernel.org, Parisc List <linux-parisc@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Geert Uytterhoeven <geert@linux-m68k.org>

From: Arnd Bergmann <arnd@arndb.de>

This gets passed to a number of init functions, but is
ignored everywhere, so remove the function and change the
mach_sched_init callback to take no arguments.

Reviewed-by: Geert Uytterhoeven <geert@linux-m68k.org>
Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>
Tested-by: Geert Uytterhoeven <geert@linux-m68k.org>
Reviewed-by: Linus Walleij <linus.walleij@linaro.org>
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 arch/m68k/68000/timers.c        |  2 +-
 arch/m68k/amiga/config.c        |  4 ++--
 arch/m68k/apollo/config.c       |  4 ++--
 arch/m68k/atari/config.c        |  2 +-
 arch/m68k/atari/time.c          |  2 +-
 arch/m68k/bvme6000/config.c     |  4 ++--
 arch/m68k/coldfire/pit.c        |  2 +-
 arch/m68k/coldfire/sltimers.c   |  2 +-
 arch/m68k/coldfire/timers.c     |  2 +-
 arch/m68k/hp300/time.c          |  2 +-
 arch/m68k/hp300/time.h          |  2 +-
 arch/m68k/include/asm/machdep.h |  5 ++---
 arch/m68k/kernel/setup_mm.c     |  2 +-
 arch/m68k/kernel/setup_no.c     |  2 +-
 arch/m68k/kernel/time.c         | 15 +--------------
 arch/m68k/mac/config.c          |  6 +++---
 arch/m68k/mac/via.c             |  2 +-
 arch/m68k/mvme147/config.c      |  4 ++--
 arch/m68k/mvme16x/config.c      |  4 ++--
 arch/m68k/q40/config.c          |  2 +-
 arch/m68k/q40/q40ints.c         |  2 +-
 arch/m68k/sun3/config.c         |  4 ++--
 arch/m68k/sun3x/time.c          |  2 +-
 arch/m68k/sun3x/time.h          |  2 +-
 24 files changed, 33 insertions(+), 47 deletions(-)

diff --git a/arch/m68k/68000/timers.c b/arch/m68k/68000/timers.c
index 3aa006f8e7ea..0d0417cebc7f 100644
--- a/arch/m68k/68000/timers.c
+++ b/arch/m68k/68000/timers.c
@@ -91,7 +91,7 @@ static struct clocksource m68328_clk = {
 
 /***************************************************************************/
 
-void hw_timer_init(irq_handler_t handler)
+void hw_timer_init(void)
 {
 	int ret;
 
diff --git a/arch/m68k/amiga/config.c b/arch/m68k/amiga/config.c
index 91dc87b86411..50e9a2c6523e 100644
--- a/arch/m68k/amiga/config.c
+++ b/arch/m68k/amiga/config.c
@@ -92,7 +92,7 @@ static char *amiga_models[] __initdata = {
 
 static char amiga_model_name[13] = "Amiga ";
 
-static void amiga_sched_init(irq_handler_t handler);
+static void amiga_sched_init(void);
 static void amiga_get_model(char *model);
 static void amiga_get_hardware_list(struct seq_file *m);
 extern void amiga_mksound(unsigned int count, unsigned int ticks);
@@ -483,7 +483,7 @@ static irqreturn_t ciab_timer_handler(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
-static void __init amiga_sched_init(irq_handler_t timer_routine)
+static void __init amiga_sched_init(void)
 {
 	static struct resource sched_res = {
 		.name = "timer", .start = 0x00bfd400, .end = 0x00bfd5ff,
diff --git a/arch/m68k/apollo/config.c b/arch/m68k/apollo/config.c
index 17d59fa6b25b..36c2cd97f228 100644
--- a/arch/m68k/apollo/config.c
+++ b/arch/m68k/apollo/config.c
@@ -26,7 +26,7 @@ u_long cpuctrl_physaddr;
 u_long timer_physaddr;
 u_long apollo_model;
 
-extern void dn_sched_init(irq_handler_t handler);
+extern void dn_sched_init(void);
 extern void dn_init_IRQ(void);
 extern int dn_dummy_hwclk(int, struct rtc_time *);
 extern void dn_dummy_reset(void);
@@ -179,7 +179,7 @@ irqreturn_t dn_timer_int(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
-void dn_sched_init(irq_handler_t timer_routine)
+void dn_sched_init(void)
 {
 	/* program timer 1 */
 	*(volatile unsigned char *)(apollo_timer + 3) = 0x01;
diff --git a/arch/m68k/atari/config.c b/arch/m68k/atari/config.c
index 7ec3161e8517..50fda4bea521 100644
--- a/arch/m68k/atari/config.c
+++ b/arch/m68k/atari/config.c
@@ -77,7 +77,7 @@ static void atari_heartbeat(int on);
 #endif
 
 /* atari specific timer functions (in time.c) */
-extern void atari_sched_init(irq_handler_t);
+extern void atari_sched_init(void);
 extern int atari_mste_hwclk (int, struct rtc_time *);
 extern int atari_tt_hwclk (int, struct rtc_time *);
 
diff --git a/arch/m68k/atari/time.c b/arch/m68k/atari/time.c
index 36d811ae09ee..1068670cb741 100644
--- a/arch/m68k/atari/time.c
+++ b/arch/m68k/atari/time.c
@@ -56,7 +56,7 @@ static irqreturn_t mfp_timer_c_handler(int irq, void *dev_id)
 }
 
 void __init
-atari_sched_init(irq_handler_t timer_routine)
+atari_sched_init(void)
 {
     /* set Timer C data Register */
     st_mfp.tim_dt_c = INT_TICKS;
diff --git a/arch/m68k/bvme6000/config.c b/arch/m68k/bvme6000/config.c
index d3f5963021d3..b37f8ce034e7 100644
--- a/arch/m68k/bvme6000/config.c
+++ b/arch/m68k/bvme6000/config.c
@@ -38,7 +38,7 @@
 #include <asm/bvme6000hw.h>
 
 static void bvme6000_get_model(char *model);
-extern void bvme6000_sched_init(irq_handler_t handler);
+extern void bvme6000_sched_init(void);
 extern int bvme6000_hwclk (int, struct rtc_time *);
 extern void bvme6000_reset (void);
 void bvme6000_set_vectors (void);
@@ -189,7 +189,7 @@ static irqreturn_t bvme6000_timer_int (int irq, void *dev_id)
  * so divide by 8 to get the microsecond result.
  */
 
-void bvme6000_sched_init (irq_handler_t timer_routine)
+void bvme6000_sched_init (void)
 {
     volatile RtcPtr_t rtc = (RtcPtr_t)BVME_RTC_BASE;
     unsigned char msr = rtc->msr & 0xc0;
diff --git a/arch/m68k/coldfire/pit.c b/arch/m68k/coldfire/pit.c
index fd1d9c915daa..855d0af47097 100644
--- a/arch/m68k/coldfire/pit.c
+++ b/arch/m68k/coldfire/pit.c
@@ -136,7 +136,7 @@ static struct clocksource pit_clk = {
 
 /***************************************************************************/
 
-void hw_timer_init(irq_handler_t handler)
+void hw_timer_init(void)
 {
 	int ret;
 
diff --git a/arch/m68k/coldfire/sltimers.c b/arch/m68k/coldfire/sltimers.c
index 25a1319f3cb8..f9d572ee63db 100644
--- a/arch/m68k/coldfire/sltimers.c
+++ b/arch/m68k/coldfire/sltimers.c
@@ -118,7 +118,7 @@ static struct clocksource mcfslt_clk = {
 	.flags	= CLOCK_SOURCE_IS_CONTINUOUS,
 };
 
-void hw_timer_init(irq_handler_t handler)
+void hw_timer_init(void)
 {
 	int r;
 
diff --git a/arch/m68k/coldfire/timers.c b/arch/m68k/coldfire/timers.c
index 24b5e2d1b00b..05a42d8e0a59 100644
--- a/arch/m68k/coldfire/timers.c
+++ b/arch/m68k/coldfire/timers.c
@@ -107,7 +107,7 @@ static struct clocksource mcftmr_clk = {
 
 /***************************************************************************/
 
-void hw_timer_init(irq_handler_t handler)
+void hw_timer_init(void)
 {
 	int r;
 
diff --git a/arch/m68k/hp300/time.c b/arch/m68k/hp300/time.c
index 011fc2e5a68a..1d1b7b3b5dd4 100644
--- a/arch/m68k/hp300/time.c
+++ b/arch/m68k/hp300/time.c
@@ -98,7 +98,7 @@ static u64 hp300_read_clk(struct clocksource *cs)
 	return ticks;
 }
 
-void __init hp300_sched_init(irq_handler_t vector)
+void __init hp300_sched_init(void)
 {
   out_8(CLOCKBASE + CLKCR2, 0x1);		/* select CR1 */
   out_8(CLOCKBASE + CLKCR1, 0x1);		/* reset */
diff --git a/arch/m68k/hp300/time.h b/arch/m68k/hp300/time.h
index 1d77b55cc72a..040a098b7db1 100644
--- a/arch/m68k/hp300/time.h
+++ b/arch/m68k/hp300/time.h
@@ -1 +1 @@
-extern void hp300_sched_init(irq_handler_t vector);
+extern void hp300_sched_init(void);
diff --git a/arch/m68k/include/asm/machdep.h b/arch/m68k/include/asm/machdep.h
index e62a39d01ae4..7181ed43ba22 100644
--- a/arch/m68k/include/asm/machdep.h
+++ b/arch/m68k/include/asm/machdep.h
@@ -12,7 +12,7 @@ struct rtc_time;
 struct rtc_pll_info;
 struct buffer_head;
 
-extern void (*mach_sched_init) (irq_handler_t handler);
+extern void (*mach_sched_init) (void);
 /* machine dependent irq functions */
 extern void (*mach_init_IRQ) (void);
 extern void (*mach_get_model) (char *model);
@@ -33,8 +33,7 @@ extern void (*mach_l2_flush) (int);
 extern void (*mach_beep) (unsigned int, unsigned int);
 
 /* Hardware clock functions */
-extern void hw_timer_init(irq_handler_t handler);
-extern unsigned long hw_timer_offset(void);
+extern void hw_timer_init(void);
 #ifdef CONFIG_HEARTBEAT
 extern void timer_heartbeat(void);
 #else
diff --git a/arch/m68k/kernel/setup_mm.c b/arch/m68k/kernel/setup_mm.c
index ab8aa7be260f..0628733bfb88 100644
--- a/arch/m68k/kernel/setup_mm.c
+++ b/arch/m68k/kernel/setup_mm.c
@@ -82,7 +82,7 @@ static struct m68k_mem_info m68k_ramdisk __initdata;
 
 static char m68k_command_line[CL_SIZE] __initdata;
 
-void (*mach_sched_init) (irq_handler_t handler) __initdata = NULL;
+void (*mach_sched_init) (void) __initdata = NULL;
 /* machine dependent irq functions */
 void (*mach_init_IRQ) (void) __initdata = NULL;
 void (*mach_get_model) (char *model);
diff --git a/arch/m68k/kernel/setup_no.c b/arch/m68k/kernel/setup_no.c
index f66f4b1d062e..e377b4219528 100644
--- a/arch/m68k/kernel/setup_no.c
+++ b/arch/m68k/kernel/setup_no.c
@@ -49,7 +49,7 @@ EXPORT_SYMBOL(memory_end);
 char __initdata command_line[COMMAND_LINE_SIZE];
 
 /* machine dependent timer functions */
-void (*mach_sched_init)(irq_handler_t handler) __initdata = NULL;
+void (*mach_sched_init)(void) __initdata = NULL;
 int (*mach_hwclk) (int, struct rtc_time*);
 
 /* machine dependent reboot functions */
diff --git a/arch/m68k/kernel/time.c b/arch/m68k/kernel/time.c
index c05cec21b05f..340ffeea0a9d 100644
--- a/arch/m68k/kernel/time.c
+++ b/arch/m68k/kernel/time.c
@@ -35,19 +35,6 @@
 unsigned long (*mach_random_get_entropy)(void);
 EXPORT_SYMBOL_GPL(mach_random_get_entropy);
 
-
-/*
- * timer_interrupt() needs to keep up the real-time clock,
- * as well as call the "xtime_update()" routine every clocktick
- */
-static irqreturn_t timer_interrupt(int irq, void *dummy)
-{
-	xtime_update(1);
-	update_process_times(user_mode(get_irq_regs()));
-	profile_tick(CPU_PROFILING);
-	return IRQ_HANDLED;
-}
-
 #ifdef CONFIG_HEARTBEAT
 void timer_heartbeat(void)
 {
@@ -157,5 +144,5 @@ module_init(rtc_init);
 
 void __init time_init(void)
 {
-	mach_sched_init(timer_interrupt);
+	mach_sched_init();
 }
diff --git a/arch/m68k/mac/config.c b/arch/m68k/mac/config.c
index 0ac53d87493c..0dbe0fedd826 100644
--- a/arch/m68k/mac/config.c
+++ b/arch/m68k/mac/config.c
@@ -58,7 +58,7 @@ extern int mac_hwclk(int, struct rtc_time *);
 extern void iop_preinit(void);
 extern void iop_init(void);
 extern void via_init(void);
-extern void via_init_clock(irq_handler_t func);
+extern void via_init_clock(void);
 extern void oss_init(void);
 extern void psc_init(void);
 extern void baboon_init(void);
@@ -69,9 +69,9 @@ static void mac_get_model(char *str);
 static void mac_identify(void);
 static void mac_report_hardware(void);
 
-static void __init mac_sched_init(irq_handler_t vector)
+static void __init mac_sched_init(void)
 {
-	via_init_clock(vector);
+	via_init_clock();
 }
 
 /*
diff --git a/arch/m68k/mac/via.c b/arch/m68k/mac/via.c
index ba444e1774b8..8ad734e3c934 100644
--- a/arch/m68k/mac/via.c
+++ b/arch/m68k/mac/via.c
@@ -609,7 +609,7 @@ static irqreturn_t via_timer_handler(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
-void __init via_init_clock(irq_handler_t timer_routine)
+void __init via_init_clock(void)
 {
 	if (request_irq(IRQ_MAC_TIMER_1, via_timer_handler, IRQF_TIMER, "timer",
 			NULL)) {
diff --git a/arch/m68k/mvme147/config.c b/arch/m68k/mvme147/config.c
index 5dabbc915b8d..4fc43b5d7545 100644
--- a/arch/m68k/mvme147/config.c
+++ b/arch/m68k/mvme147/config.c
@@ -37,7 +37,7 @@
 
 
 static void mvme147_get_model(char *model);
-extern void mvme147_sched_init(irq_handler_t handler);
+extern void mvme147_sched_init(void);
 extern int mvme147_hwclk (int, struct rtc_time *);
 extern void mvme147_reset (void);
 
@@ -125,7 +125,7 @@ static irqreturn_t mvme147_timer_int (int irq, void *dev_id)
 }
 
 
-void mvme147_sched_init (irq_handler_t timer_routine)
+void mvme147_sched_init (void)
 {
 	if (request_irq(PCC_IRQ_TIMER1, mvme147_timer_int, IRQF_TIMER,
 			"timer 1", NULL))
diff --git a/arch/m68k/mvme16x/config.c b/arch/m68k/mvme16x/config.c
index ae9bb7fda161..18e158887ec9 100644
--- a/arch/m68k/mvme16x/config.c
+++ b/arch/m68k/mvme16x/config.c
@@ -43,7 +43,7 @@ extern t_bdid mvme_bdid;
 static MK48T08ptr_t volatile rtc = (MK48T08ptr_t)MVME_RTC_BASE;
 
 static void mvme16x_get_model(char *model);
-extern void mvme16x_sched_init(irq_handler_t handler);
+extern void mvme16x_sched_init(void);
 extern int mvme16x_hwclk (int, struct rtc_time *);
 extern void mvme16x_reset (void);
 
@@ -384,7 +384,7 @@ static irqreturn_t mvme16x_timer_int (int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
-void mvme16x_sched_init (irq_handler_t timer_routine)
+void mvme16x_sched_init(void)
 {
     uint16_t brdno = be16_to_cpu(mvme_bdid.brdno);
     int irq;
diff --git a/arch/m68k/q40/config.c b/arch/m68k/q40/config.c
index 4627de3c0603..55f76f0fa29b 100644
--- a/arch/m68k/q40/config.c
+++ b/arch/m68k/q40/config.c
@@ -37,7 +37,7 @@
 
 extern void q40_init_IRQ(void);
 static void q40_get_model(char *model);
-extern void q40_sched_init(irq_handler_t handler);
+extern void q40_sched_init(void);
 
 static int q40_hwclk(int, struct rtc_time *);
 static unsigned int q40_get_ss(void);
diff --git a/arch/m68k/q40/q40ints.c b/arch/m68k/q40/q40ints.c
index 4c6c409053fd..6886a5d0007b 100644
--- a/arch/m68k/q40/q40ints.c
+++ b/arch/m68k/q40/q40ints.c
@@ -149,7 +149,7 @@ static irqreturn_t q40_timer_int(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
-void q40_sched_init (irq_handler_t timer_routine)
+void q40_sched_init (void)
 {
 	int timer_irq;
 
diff --git a/arch/m68k/sun3/config.c b/arch/m68k/sun3/config.c
index 7204c0ea0dc7..f7dd47232b6c 100644
--- a/arch/m68k/sun3/config.c
+++ b/arch/m68k/sun3/config.c
@@ -36,7 +36,7 @@
 
 char sun3_reserved_pmeg[SUN3_PMEGS_NUM];
 
-static void sun3_sched_init(irq_handler_t handler);
+static void sun3_sched_init(void);
 extern void sun3_get_model (char* model);
 extern int sun3_hwclk(int set, struct rtc_time *t);
 
@@ -151,7 +151,7 @@ void __init config_sun3(void)
 	sun3_bootmem_alloc(memory_start, memory_end);
 }
 
-static void __init sun3_sched_init(irq_handler_t timer_routine)
+static void __init sun3_sched_init(void)
 {
 	sun3_disable_interrupts();
         intersil_clock->cmd_reg=(INTERSIL_RUN|INTERSIL_INT_DISABLE|INTERSIL_24H_MODE);
diff --git a/arch/m68k/sun3x/time.c b/arch/m68k/sun3x/time.c
index f6e25fdc008c..a2c97821faf2 100644
--- a/arch/m68k/sun3x/time.c
+++ b/arch/m68k/sun3x/time.c
@@ -90,7 +90,7 @@ static irqreturn_t sun3x_timer_tick(int irq, void *dev_id)
 }
 #endif
 
-void __init sun3x_sched_init(irq_handler_t vector)
+void __init sun3x_sched_init(void)
 {
 
 	sun3_disable_interrupts();
diff --git a/arch/m68k/sun3x/time.h b/arch/m68k/sun3x/time.h
index 86ce78bb3c28..7cfff22e4986 100644
--- a/arch/m68k/sun3x/time.h
+++ b/arch/m68k/sun3x/time.h
@@ -3,7 +3,7 @@
 #define SUN3X_TIME_H
 
 extern int sun3x_hwclk(int set, struct rtc_time *t);
-void sun3x_sched_init(irq_handler_t vector);
+void sun3x_sched_init(void);
 
 struct mostek_dt {
 	volatile unsigned char csr;
-- 
2.27.0
