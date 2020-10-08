From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 08 Oct 2020 15:46:41 +0000
Subject: [PATCH 03/13] ARM: rpc: use legacy_timer_tick
Message-Id: <20201008154651.1901126-4-arnd@arndb.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201008154651.1901126-1-arnd@arndb.de>
In-Reply-To: <20201008154651.1901126-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Arnd Bergmann <arnd@arndb.de>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Ungerer <gerg@linux-m68k.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Finn Thain <fthain@telegraphics.com.au>, Philip Blundell <philb@gnu.org>, Joshua Thompson <funaho@jurai.org>, Sam Creasey <sammy@sammy.net>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Thomas Gleixner <tglx@linutronix.de>, Daniel Lezcano <daniel.lezcano@linaro.org>, John Stultz <john.stultz@linaro.org>, Stephen Boyd <sboyd@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-arm-kernel@lists.infradead.org

rpc is the only user of the timer_tick() function now, and can
just call the newly added generic version instead.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 arch/arm/Kconfig                 |  1 +
 arch/arm/include/asm/mach/time.h |  2 --
 arch/arm/kernel/time.c           | 14 --------------
 arch/arm/mach-rpc/time.c         |  2 +-
 4 files changed, 2 insertions(+), 17 deletions(-)

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index fe2f17eb2b50..13af8d7a6c17 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -467,6 +467,7 @@ config ARCH_RPC
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
