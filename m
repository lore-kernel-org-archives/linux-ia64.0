From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 13 May 2004 19:02:42 +0000
Subject: Re: [PATCH] fix "timer tick before it's due"
Message-Id: <200405131302.42501.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405121721.30863.bjorn.helgaas@hp.com>
In-Reply-To: <200405121721.30863.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 12 May 2004 5:42 pm, David Mosberger wrote:
> However, it's kind of hard to imagine a clean solution to the timer
> tick problem you observed so I think it's reasonable to require that
> timer ticks be disabled before syncing the ITCs.

Isn't the real problem the fact that the printk in timer_interrupt()
takes a large fraction of a tick?  If we just eliminate the printk,
that problem goes away, and then we'd just have to make sure we
aren't syncing the ITC too far backwards.

Actually, shouldn't we check that we don't set it too far backwards
anyway?  If the new CPU came online with an ITC way ahead of the
BP, we could schedule a tick, sync with the BP, and wait for a
looong time.

=== arch/ia64/kernel/smpboot.c 1.49 vs edited ==--- 1.49/arch/ia64/kernel/smpboot.c	Thu Mar 25 12:53:03 2004
+++ edited/arch/ia64/kernel/smpboot.c	Thu May 13 12:46:06 2004
@@ -249,12 +249,15 @@
 	       "maxerr %lu cycles)\n", smp_processor_id(), master, delta, rt);
 
 	/*
-	 * Check whether we sync'd the itc ahead of the next timer interrupt.  If so, just
-	 * reset it.
+	 * Check whether we sync'd the itc too far from the next timer
+	 * interrupt.  If so, just reschedule the next tick.
 	 */
-	if (time_after(ia64_get_itc(), local_cpu_data->itm_next)) {
-		Dprintk("CPU %d: oops, jumped a timer tick; resetting timer.\n",
-			smp_processor_id());
+	if (time_after(ia64_get_itc(), local_cpu_data->itm_next) ||
+	    time_before(ia64_get_itc(), local_cpu_data->itm_next - local_cpu_data->itm_delta)) {
+		Dprintk("CPU %d: oops, timer tick too far away; resetting "
+			"timer (itc=0x%lx,itm=0x%lx).\n",
+			smp_processor_id(), ia64_get_itc(),
+			local_cpu_data->itm_next);
 		ia64_cpu_local_tick();
 	}
 }
=== arch/ia64/kernel/time.c 1.39 vs edited ==--- 1.39/arch/ia64/kernel/time.c	Thu Mar 25 12:53:03 2004
+++ edited/arch/ia64/kernel/time.c	Thu May 13 12:46:21 2004
@@ -248,10 +248,6 @@
 
 	new_itm = local_cpu_data->itm_next;
 
-	if (!time_after(ia64_get_itc(), new_itm))
-		printk(KERN_ERR "Oops: timer tick before it's due (itc=%lx,itm=%lx)\n",
-		       ia64_get_itc(), new_itm);
-
 	ia64_do_profile(regs);
 
 	while (1) {
