From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 07 Aug 2007 20:11:36 +0000
Subject: RE: [PATCH] disable irq's and check need_resched before safe_halt
Message-Id: <617E1C2C70743745A92448908E030B2A021D889B@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070807134932.GA30447@sgi.com>
In-Reply-To: <20070807134932.GA30447@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This looks like it re-introduces code that Ken Chen backed out
about two years ago.  Here's Ken's commit that explains what
broke last time we made the idle loop look like this.  Now
that code was wider ranging ... messing with TIF bits too,
so maybe this is different this time?

-Tony

commit 1e185b97b4364063f1135604b87f8d8469944233
Author: Chen, Kenneth W <kenneth.w.chen@intel.com>
Date:   Tue Nov 15 14:37:05 2005 -0800

    [PATCH] ia64: cpu_idle performance bug fix
    
    Our performance validation on 2.6.15-rc1 caught a disastrous performance
    regression on ia64 with netperf (-98%) and volanomark (-58%) compares to
    previous kernel version 2.6.14-git7.  See the following chart (result
    group 1 & 2).
    
      http://kernel-perf.sourceforge.net/results.machine_id&.html
    
    We have root caused it to commit 64c7c8f88559624abdbe12b5da6502e8879f8d28
    
    This changeset broke the ia64 task resched notification.  In
    sched.c:resched_task(), a reschedule IPI is conditioned upon
    TIF_POLLING_NRFLAG.  However, the above changeset unconditionally set
    the polling thread flag for idle tasks regardless whether pal_halt_light
    is in use or not.  As a result, resched IPI is not sent from
    resched_task().  And since the default behavior on ia64 is to use
    pal_halt_light, we end up delaying the rescheduling task until next
    timer tick, and thus cause the performance regression.
    
    This fixes the performance bug.  I'm glad our performance suite is
    turning up bad performance bug like this in time.
    
    Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
    Signed-off-by: Linus Torvalds <torvalds@osdl.org>

diff --git a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
index e92ea64..4305d2b 100644
--- a/arch/ia64/kernel/process.c
+++ b/arch/ia64/kernel/process.c
@@ -202,12 +202,9 @@ default_idle (void)
 {
 	local_irq_enable();
 	while (!need_resched()) {
-		if (can_do_pal_halt) {
-			local_irq_disable();
-			if (!need_resched())
-				safe_halt();
-			local_irq_enable();
-		} else
+		if (can_do_pal_halt)
+			safe_halt();
+		else
 			cpu_relax();
 	}
 }
@@ -272,10 +269,14 @@ cpu_idle (void)
 {
 	void (*mark_idle)(int) = ia64_mark_idle;
   	int cpu = smp_processor_id();
-	set_thread_flag(TIF_POLLING_NRFLAG);
 
 	/* endless idle loop with no priority at all */
 	while (1) {
+		if (can_do_pal_halt)
+			clear_thread_flag(TIF_POLLING_NRFLAG);
+		else
+			set_thread_flag(TIF_POLLING_NRFLAG);
+
 		if (!need_resched()) {
 			void (*idle)(void);
 #ifdef CONFIG_SMP
