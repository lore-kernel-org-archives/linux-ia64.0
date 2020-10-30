From: Arnd Bergmann <arnd@kernel.org>
Date: Fri, 30 Oct 2020 15:17:49 +0000
Subject: [PATCH v2 06/15] ARM: rpc: use legacy_timer_tick
Message-Id: <20201030151758.1241164-7-arnd@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201030151758.1241164-1-arnd@kernel.org>
In-Reply-To: <20201030151758.1241164-1-arnd@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Arnd Bergmann <arnd@arndb.de>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Ungerer <gerg@linux-m68k.org>, Finn Thain <fthain@telegraphics.com.au>, Philip Blundell <philb@gnu.org>, Joshua Thompson <funaho@jurai.org>, Sam Creasey <sammy@sammy.net>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Daniel Lezcano <daniel.lezcano@linaro.org>, John Stultz <john.stultz@linaro.org>, Stephen Boyd <sboyd@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, linux-ia64@vger.kernel.org, Parisc List <linux-parisc@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>

From: Arnd Bergmann <arnd@arndb.de>

rpc is the only user of the timer_tick() function now, and can
just call the newly added generic version instead.

Reviewed-by: Linus Walleij <linus.walleij@linaro.org>
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 arch/arm/Kconfig                 |  1 +
 arch/arm/include/asm/mach/time.h |  2 --
 arch/arm/kernel/time.c           | 14 --------------
 arch/arm/mach-rpc/time.c         |  2 +-
 4 files changed, 2 insertions(+), 17 deletions(-)

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 1b9fda08b92f..dbadfa186f72 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -452,6 +452,7 @@ config ARCH_RPC
 	select HAVE_IDE
 	select HAVE_PATA_PLATFORM
 	select ISA_DMA_API
+	select LEGACY_TIMER_TICK
 	select NEED_MACH_IO_H
 	select NEED_MACH_MEMORY_H
 	select NO_IOPORT_MAP
diff --git a/arch/arm/include/asm/mach/time.h b/arch/arm/include/asm/mach/time.h
index d75d39280db7..5f522916ec99 100644
--- a/arch/arm/include/asm/mach/time.h
+++ b/arch/arm/include/asm/mach/time.h
@@ -7,8 +7,6 @@
 #ifndef __ASM_ARM_MACH_TIME_H
 #define __ASM_ARM_MACH_TIME_H
 
-extern void timer_tick(void);
-
 typedef void (*clock_access_fn)(struct timespec64 *);
 extern int register_persistent_clock(clock_access_fn read_persistent);
 
diff --git a/arch/arm/kernel/time.c b/arch/arm/kernel/time.c
index 09b149b09c43..b3836c94dc74 100644
--- a/arch/arm/kernel/time.c
+++ b/arch/arm/kernel/time.c
@@ -60,20 +60,6 @@ unsigned long profile_pc(struct pt_regs *regs)
 EXPORT_SYMBOL(profile_pc);
 #endif
 
-#ifndef CONFIG_GENERIC_CLOCKEVENTS
-/*
- * Kernel system timer support.
- */
-void timer_tick(void)
-{
-	profile_tick(CPU_PROFILING);
-	xtime_update(1);
-#ifndef CONFIG_SMP
-	update_process_times(user_mode(get_irq_regs()));
-#endif
-}
-#endif
-
 static void dummy_clock_access(struct timespec64 *ts)
 {
 	ts->tv_sec = 0;
diff --git a/arch/arm/mach-rpc/time.c b/arch/arm/mach-rpc/time.c
index da85cac761ba..9f8edcfe9357 100644
--- a/arch/arm/mach-rpc/time.c
+++ b/arch/arm/mach-rpc/time.c
@@ -81,7 +81,7 @@ static irqreturn_t
 ioc_timer_interrupt(int irq, void *dev_id)
 {
 	ioc_time += RPC_LATCH;
-	timer_tick();
+	legacy_timer_tick(1);
 	return IRQ_HANDLED;
 }
 
-- 
2.27.0
