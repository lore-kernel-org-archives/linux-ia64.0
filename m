From: Dimitri Sivanich <sivanich@sgi.com>
Date: Tue, 07 Aug 2007 13:49:32 +0000
Subject: [PATCH] disable irq's and check need_resched before safe_halt
Message-Id: <20070807134932.GA30447@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

While sending interrupts to a cpu to repeatedly wake a thread, on occasion that thread will take a full timer tick cycle (4002 usec in my case) to wakeup.

The problem concerns a race condition in the code around the safe_halt() call in the default_idle() routine.  Setting 'nohalt' on the kernel command line causes the long wakeups to disappear.

void
default_idle (void)
{
        local_irq_enable();
        while (!need_resched()) {
-->             if (can_do_pal_halt)
-->                     safe_halt();
                else

A timer tick could arrive between the check for !need_resched and the actual call to safe_halt() (which does a pal call to PAL_HALT_LIGHT).  By the time the timer tick completes, a thread that might now need to run could get held up for as long as a timer tick waiting for the halted cpu.

I'm proposing that we disable irq's and check need_resched again before calling safe_halt().  Does anyone see any problem with this approach?


Signed-off-by: Dimitri Sivanich <sivanich@sgi.com>

Index: linux/arch/ia64/kernel/process.c
=================================--- linux.orig/arch/ia64/kernel/process.c	2007-08-02 15:05:56.427236082 -0500
+++ linux/arch/ia64/kernel/process.c	2007-08-06 19:42:20.147944967 -0500
@@ -198,9 +198,13 @@ default_idle (void)
 {
 	local_irq_enable();
 	while (!need_resched()) {
-		if (can_do_pal_halt)
-			safe_halt();
-		else
+		if (can_do_pal_halt) {
+			local_irq_disable();
+			if (!need_resched()) {
+				safe_halt();
+			}
+			local_irq_enable();
+		} else
 			cpu_relax();
 	}
 }
