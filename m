From: "Pat O'Rourke" <orourke@mclinux.com>
Date: Thu, 07 Sep 2000 18:12:28 +0000
Subject: [Linux-ia64] [PATCH] Hundred percent system time
Message-Id: <marc-linux-ia64-105590678205462@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

vmstat(8) was showing 100% system time on an "idle" system.  The problem
is that irq_enter() was being called twice for each clock interrupt; once
in handle_IRQ_event() and a second time in smp_do_timer():

	do_IRQ()
	|
	+-> handle_IRQ_event()
		|
		irq_enter()				// local_irq_count = 1
			|
			+-> timer_interrupt()
				|
				+-> smp_do_timer()
					|
					irq_enter	// local_irq_count = 2

As a result update_process_times() was attributing every clock tick as
occurring during an interrupt and therefore bumping up the per_cpu_system
counter.

I could see no other callers of smp_do_timer() other than timer_interrupt(),
and this will always be called via handle_IRQ_event.  So I believe that the
irq_enter/irq_exit in smp_do_timer() is not necessary and incorrect.  Is this
a true statement?  If so, this patch will remove the irq_enter/irq_exit from
smp_do_timer.

I've run this patch on a 4 cpu lion in SMP mode and UP mode (CONFIG_SMP
turned off as opposed to the nosmp boot option) and have not seen any ill
effects and the reported system time seems correct too.

Pat

-- 
Patrick O'Rourke
orourke@missioncriticallinux.com

--- linux-test7-plain/arch/ia64/kernel/smp.c	Thu Sep  7 12:26:32 2000
+++ linux-test7-patched/arch/ia64/kernel/smp.c	Thu Sep  7 12:32:00 2000
@@ -457,10 +457,12 @@
 		 * update_process_times() expects us to have done irq_enter().
 		 * Besides, if we don't timer interrupts ignore the global
 		 * interrupt lock, which is the WrongThing (tm) to do.
+		 *
+		 * [ The irq_enter() has been done in our caller, 	]
+		 * [ handle_IRQ_event, so we don't need to do it here.	]
+		 *
 		 */
-		irq_enter(cpu, 0);
 		update_process_times(user);
-		irq_exit(cpu, 0);
 	}
 }
 





