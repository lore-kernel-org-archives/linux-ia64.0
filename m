From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 12 May 2004 23:21:30 +0000
Subject: [PATCH] fix "timer tick before it's due"
Message-Id: <200405121721.30863.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Fix the "timer tick before it's due" complaint from timer_interrupt().
The problem was that smp_callin() turned on the periodic timer tick
before syncing the ITC with the BP.

Syncing the ITC happens with interrupts disabled, and if you're
unlucky enough to (1) pend a timer interrupt, and (2) set the ITC
back before the ITM value that caused the timer interrupt, you
can get stuck for several iterations in the following cycle
(assume 100 clocks per tick):

    ITC     ITM
    ---	    ---
                    ia64_init_itm()
    100	    200	        schedule first tick at 200
                    ia64_sync_itc()
                        disable interrupts
    200     200         ITC = ITM; pend IT interrupt
    150                 set ITC to sync with BP
                        enable interrupts
                        recognize pending IT interrupt
                        disable IT interrupts
                    timer_interrupt()
    160     200         notice that 160 < 200,
                            printk "timer tick before it's due")
    200     200         ITC = ITM; pend IT interrupt
	    300         set ITM for next tick
                        re-enable IT interrupt
                        recognize pending IT interrupt
                        disable IT interrupts
                    timer_interrupt()
    260     300         notice that 260 < 300,
                            printk "timer tick before it's due")

    ...	            repeat until you're tired or timer_interrupt()
                    takes long enough that the ITC lands after the
                    ITM

This patch syncs the ITC with the BP before starting up the
periodic tick, so the above scenario should never happen.

This doesn't change how the timer tick on the BP is started;
that happens quite early (and must be early because things
like calibrate_delay() depend on jiffies updates).

(This is against 2.6.6, but I think it will conflict slightly
with my iobase init change that is in your tree but not Linus'.)

=== arch/ia64/kernel/smpboot.c 1.49 vs edited ==--- 1.49/arch/ia64/kernel/smpboot.c	Thu Mar 25 12:53:03 2004
+++ edited/arch/ia64/kernel/smpboot.c	Wed May 12 14:36:17 2004
@@ -289,11 +289,6 @@
 	smp_setup_percpu_timer();
 
 	/*
-	 * Get our bogomips.
-	 */
-	ia64_init_itm();
-
-	/*
 	 * Set I/O port base per CPU
 	 */
 	ia64_set_kr(IA64_KR_IO_BASE, __pa(ia64_iobase));
@@ -305,11 +300,6 @@
 #endif
 
 	local_irq_enable();
-	calibrate_delay();
-	local_cpu_data->loops_per_jiffy = loops_per_jiffy;
-#ifdef CONFIG_IA32_SUPPORT
-	ia32_gdt_init();
-#endif
 
 	if (!(sal_platform_features & IA64_SAL_PLATFORM_FEATURE_ITC_DRIFT)) {
 		/*
@@ -321,6 +311,17 @@
 		Dprintk("Going to syncup ITC with BP.\n");
 		ia64_sync_itc(0);
 	}
+
+	/*
+	 * Get our bogomips.
+	 */
+	ia64_init_itm();
+	calibrate_delay();
+	local_cpu_data->loops_per_jiffy = loops_per_jiffy;
+
+#ifdef CONFIG_IA32_SUPPORT
+	ia32_gdt_init();
+#endif
 
 	/*
 	 * Allow the master to continue.
