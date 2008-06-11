From: Alex Chiang <achiang@hp.com>
Date: Wed, 11 Jun 2008 23:29:27 +0000
Subject: [PATCH] Update check_sal_cache_flush to use platform_send_ipi()
Message-Id: <20080611232927.GC29736@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Tony,

This is the patch you asked for on irc. I didn't test on any
virtualization platforms (kvm, xen, etc.) because I didn't know
which ones were troublesome.

Would you mind verifying them for me?

cheers,

/ac


From: Alex Chiang <achiang@hp.com>

check_sal_cache_flush is used to detect broken firmware that drops
pending interrupts.

The old implementation schedules a timer interrupt for itself in
the future by getting the current value of the Interval Timer
Counter + 1000 cycles, waits for the interrupt to be pended, calls
SAL_CACHE_FLUSH, and finally checks to see if the interrupt is
still pending.

This implementation can cause problems for virtual machine code if
the process of scheduling the timer interrupt takes more than 1000
cycles; the virtual machine can end up sleeping for several hundred
years while waiting for the ITC to wrap around.

The fix is to use platform_send_ipi. The processor will still send
an interrupt to itself, using the IA64_IPI_DM_INT delivery mode,
which causes the IPI to look like an external interrupt. The rest
of the SAL_CACHE_FLUSH + checking to see if the interrupt is still
pending remains unchanged.

This fix has been boot tested successfully on:

	- intel tiger2
	- hp rx6600
	- hp rx5670

The rx5670 has known buggy firmware, where SAL_CACHE_FLUSH drops
pending interrupts. A boot test on this machine showed this message
on the console:

SAL: SAL_CACHE_FLUSH drops interrupts; PAL_CACHE_FLUSH will be used instead

Which proves that the self-inflicted IPI approach is viable. And
as expected, the other tested platforms correctly did not display
the warning.

Signed-off-by: Alex Chiang <achiang@hp.com>
---
 arch/ia64/kernel/sal.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/arch/ia64/kernel/sal.c b/arch/ia64/kernel/sal.c
index 7e02597..0464173 100644
--- a/arch/ia64/kernel/sal.c
+++ b/arch/ia64/kernel/sal.c
@@ -252,11 +252,10 @@ check_sal_cache_flush (void)
 	local_irq_save(flags);
 
 	/*
-	 * Schedule a timer interrupt, wait until it's reported, and see if
-	 * SAL_CACHE_FLUSH drops it.
+	 * Send ourselves a timer interrupt, wait until it's reported, and see
+	 * if SAL_CACHE_FLUSH drops it.
 	 */
-	ia64_set_itv(IA64_TIMER_VECTOR);
-	ia64_set_itm(ia64_get_itc() + 1000);
+	platform_send_ipi(cpu, IA64_TIMER_VECTOR, IA64_IPI_DM_INT, 0);
 
 	while (!ia64_get_irr(IA64_TIMER_VECTOR))
 		cpu_relax();
-- 
1.5.3.1.1.g1e61

