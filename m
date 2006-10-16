From: Jack Steiner <steiner@sgi.com>
Date: Mon, 16 Oct 2006 17:56:54 +0000
Subject: [PATCH] - Allow IPIs in timer loop
Message-Id: <20061016175654.GA9779@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Allow pending IPIs to interrupt a timer interrupt that is looping
in the do_timer() "while" loop in timer_interrupt(). (Interrupts are
allowed at only 1 spot in the code).

	Signed-off-by: Jack Steiner <steiner@sgi.com>

---
We have seen isolated cases where a cpu fails to respond to an IPI for
an extended period of time. This has only been seen on very large (1024p) 
HT-enabled montecito systems running workloads that cause EXTREME contention
on the BKL lock. 

One failing senario appears to be:
	
	- Lots of cpus already contending on BKL
	- One cpu runs the haldaemon. This daemon grabs the BKL, then sends an 
	  IPI to all other cpus (see invalidate_bh_lrus()). 
	- Cpus that are already processing timer ticks don't respond to the IPI
	  until it exits from the timer interrupt exception
	- The haldaemon will hold the BKL until all cpus have responded to the IPI.
	  This increases or prolongs the BKL contention.
	- A cpu may decide to do a global load_balance as part of timer tick
	  processing. 
	- A global load_balance requires lots of off-node memory references
	- Off node memory references are really slow (not sure if this is a chipset or
	  montecito issue) during periods of SEVERE(!!!) lock contention.
	- If the global load_balance takes > 4 msec, the while loop is 
	  reexecuted. This can continue for multiple iterations of
	  the loop. IPIs will not be processed until the loops completes & 
	  timer_interrupt() exits.

There are probably other failing senarios.

We have a workload that causes system lockups within 5 - 10 minutes running the
standard kernel. With this patch, we have had 2 overnight runs with no failures.

I still want to identify the root cause of the poor performance but this
patch appears to work around the problem. The patch should have no impact
on smaller systems - they are unlikely to loop very often in the "while" loop. 
No new code is executed unless the loop is reexecuted.



Index: linux/arch/ia64/kernel/time.c
=================================--- linux.orig/arch/ia64/kernel/time.c	2006-10-16 10:53:45.000000000 -0500
+++ linux/arch/ia64/kernel/time.c	2006-10-16 12:14:23.536140299 -0500
@@ -84,6 +84,12 @@ timer_interrupt (int irq, void *dev_id)
 
 		if (time_after(new_itm, ia64_get_itc()))
 			break;
+
+		/*
+		 * Allow IPIs to interrupt the timer loop.
+		 */
+		local_irq_enable();
+		local_irq_disable();
 	}
 
 	do {
