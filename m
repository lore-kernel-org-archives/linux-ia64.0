From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 08 Oct 2020 15:46:40 +0000
Subject: [PATCH 02/13] ia64: convert to legacy_timer_tick
Message-Id: <20201008154651.1901126-3-arnd@arndb.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201008154651.1901126-1-arnd@arndb.de>
In-Reply-To: <20201008154651.1901126-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Arnd Bergmann <arnd@arndb.de>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Ungerer <gerg@linux-m68k.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Finn Thain <fthain@telegraphics.com.au>, Philip Blundell <philb@gnu.org>, Joshua Thompson <funaho@jurai.org>, Sam Creasey <sammy@sammy.net>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Thomas Gleixner <tglx@linutronix.de>, Daniel Lezcano <daniel.lezcano@linaro.org>, John Stultz <john.stultz@linaro.org>, Stephen Boyd <sboyd@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-arm-kernel@lists.infradead.org

ia64 is the only architecture that calls xtime_update() in a loop,
once for each jiffie that has passed since the last event.

Before commit 3171a0305d62 ("[PATCH] simplify update_times (avoid
jiffies/jiffies_64 aliasing problem)") in 2006, it could not actually do
this any differently, but now it seems simpler to just pass the number
of jiffies that passed in the meantime.

While this loses the ability process interrupts in the middle of
the timer tick by calling local_irq_enable(), doing so is fairly
peculiar anyway and it seems better to just do what everyone
else does here.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 arch/ia64/Kconfig       |  1 +
 arch/ia64/kernel/time.c | 36 +++++++++++++-----------------------
 2 files changed, 14 insertions(+), 23 deletions(-)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 39b25a5a591b..db8c2a365b70 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -46,6 +46,7 @@ config IA64
 	select ARCH_THREAD_STACK_ALLOCATOR
 	select ARCH_CLOCKSOURCE_DATA
 	select GENERIC_TIME_VSYSCALL
+	select LEGACY_TIMER_TICK
 	select SWIOTLB
 	select SYSCTL_ARCH_UNALIGN_NO_WARN
 	select HAVE_MOD_ARCH_SPECIFIC
diff --git a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
index 7abc5f37bfaf..9431edb08508 100644
--- a/arch/ia64/kernel/time.c
+++ b/arch/ia64/kernel/time.c
@@ -161,39 +161,29 @@ void vtime_account_idle(struct task_struct *tsk)
 static irqreturn_t
 timer_interrupt (int irq, void *dev_id)
 {
-	unsigned long new_itm;
+	unsigned long cur_itm, new_itm, ticks;
 
 	if (cpu_is_offline(smp_processor_id())) {
 		return IRQ_HANDLED;
 	}
 
 	new_itm = local_cpu_data->itm_next;
+	cur_itm = ia64_get_itc();
 
-	if (!time_after(ia64_get_itc(), new_itm))
+	if (!time_after(cur_itm, new_itm)) {
 		printk(KERN_ERR "Oops: timer tick before it's due (itc=%lx,itm=%lx)\n",
-		       ia64_get_itc(), new_itm);
-
-	profile_tick(CPU_PROFILING);
-
-	while (1) {
-		update_process_times(user_mode(get_irq_regs()));
-
-		new_itm += local_cpu_data->itm_delta;
-
-		if (smp_processor_id() = time_keeper_id)
-			xtime_update(1);
-
-		local_cpu_data->itm_next = new_itm;
+		       cur_itm, new_itm);
+		ticks = 1;
+	} else {
+		ticks = DIV_ROUND_UP(cur_itm - new_itm,
+				     local_cpu_data->itm_delta);
+		new_itm += ticks * local_cpu_data->itm_delta;
+	}
 
-		if (time_after(new_itm, ia64_get_itc()))
-			break;
+	if (smp_processor_id() != time_keeper_id)
+		ticks = 0;
 
-		/*
-		 * Allow IPIs to interrupt the timer loop.
-		 */
-		local_irq_enable();
-		local_irq_disable();
-	}
+	legacy_timer_tick(ticks);
 
 	do {
 		/*
-- 
2.27.0
