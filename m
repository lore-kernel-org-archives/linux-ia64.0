From: Bryan Sutula <Bryan.Sutula@hp.com>
Date: Wed, 05 Oct 2005 17:02:06 +0000
Subject: [PATCH] - Avoid kernel hang during CMC interrupt storm
Message-Id: <1128531726.27874.36.camel@xw.sutula>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I've noticed a kernel hang during a storm of CMC interrupts, which was
tracked down to the continual execution of the interrupt handler.

There's code in the CMC handler that's supposed to disable CMC
interrupts and switch to polling mode when it sees a bunch of CMCs.
Because disabling CMCs across all CPUs isn't safe in interrupt context,
the disable is done with a schedule_work().  But with continual CMC
interrupts, the schedule_work() never gets executed.

The following patch immediately disables CMC interrupts for the current
CPU.  This then allows (at least) one CPU to ignore CMC interrupts,
execute the schedule_work() code, and disable CMC interrupts on the rest
of the CPUs.

Signed-off-by: Bryan Sutula <Bryan.Sutula@hp.com>


--- linux-2.6.14-rc3-git5/arch/ia64/kernel/mca.c
+++ linux-2.6.14-rc3-git5_new/arch/ia64/kernel/mca.c
@@ -1016,6 +1016,11 @@ ia64_mca_cmc_int_handler(int cmc_irq, vo
 
 			cmc_polling_enabled = 1;
 			spin_unlock(&cmc_history_lock);
+			/* If we're being hit with CMC interrupts, we won't
+			 * ever execute the schedule_work() below.  Need to
+			 * disable CMC interrupts on this processor now.
+			 */
+			ia64_mca_cmc_vector_disable(NULL);
 			schedule_work(&cmc_disable_work);
 
 			/*

