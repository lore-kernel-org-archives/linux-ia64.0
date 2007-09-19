From: Russ Anderson <rja@sgi.com>
Date: Wed, 19 Sep 2007 21:58:31 +0000
Subject: [patch] Fix race when multiple cpus go through MCA
Message-Id: <200709192158.l8JLwV1N168392543@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[patch] Fix race when multiple cpus go through MCA

Additional testing uncovered a situation where the MCA recovery code could
hang due to a race condition.

According to the SAL spec, SAL sends a rendezvous interrupt to all but the first
CPU that goes into MCA.  This includes other CPUs that go into MCA at the same
time.  Those other CPUs will go into the linux MCA handler (rather than the
slave loop) with the rendezvous interrupt pending.  When all the CPUs have
completed MCA processing and the last monarch completes, freeing all the CPUs,
the CPUs with the pended rendezvous interrupt then go into the 
ia64_mca_rendez_int_handler().  In ia64_mca_rendez_int_handler() the CPUs
get marked as rendezvoused, but then leave the handler (due to no MCA).
That leaves the CPUs marked as rendezvoused _before_ the next MCA event.

When the next MCA hits, the monarch will mistakenly believe that all the CPUs
are rendezvoused when they are not, opening up a window where a CPU can get
stuck in the slave loop.

This patch avoids leaving CPUs marked as rendezvoused when they are not.

Signed-off-by: Russ Anderson <rja@sgi.com>

---
 arch/ia64/kernel/mca.c |   47 +++++++++++++++++++++++++----------------------
 1 file changed, 25 insertions(+), 22 deletions(-)

Index: test/arch/ia64/kernel/mca.c
=================================--- test.orig/arch/ia64/kernel/mca.c	2007-09-19 15:51:53.473073173 -0500
+++ test/arch/ia64/kernel/mca.c	2007-09-19 15:56:20.749226156 -0500
@@ -701,8 +701,7 @@ ia64_mca_cmc_vector_enable_keventd(struc
 /*
  * ia64_mca_wakeup
  *
- *	Send an inter-cpu interrupt to wake-up a particular cpu
- *	and mark that cpu to be out of rendez.
+ *	Send an inter-cpu interrupt to wake-up a particular cpu.
  *
  *  Inputs  :   cpuid
  *  Outputs :   None
@@ -711,14 +710,12 @@ static void
 ia64_mca_wakeup(int cpu)
 {
 	platform_send_ipi(cpu, IA64_MCA_WAKEUP_VECTOR, IA64_IPI_DM_INT, 0);
-	ia64_mc_info.imi_rendez_checkin[cpu] = IA64_MCA_RENDEZ_CHECKIN_NOTDONE;
-
 }
 
 /*
  * ia64_mca_wakeup_all
  *
- *	Wakeup all the cpus which have rendez'ed previously.
+ *	Wakeup all the slave cpus which have rendez'ed previously.
  *
  *  Inputs  :   None
  *  Outputs :   None
@@ -741,7 +738,10 @@ ia64_mca_wakeup_all(void)
  *
  *	This is handler used to put slave processors into spinloop
  *	while the monarch processor does the mca handling and later
- *	wake each slave up once the monarch is done.
+ *	wake each slave up once the monarch is done.  The state
+ *	IA64_MCA_RENDEZ_CHECKIN_DONE indicates the cpu is rendez'ed
+ *	in SAL.  The state IA64_MCA_RENDEZ_CHECKIN_NOTDONE indicates
+ *	the cpu has come out of OS rendezvous.
  *
  *  Inputs  :   None
  *  Outputs :   None
@@ -778,6 +778,7 @@ ia64_mca_rendez_int_handler(int rendez_i
 		       (long)&nd, 0, 0) = NOTIFY_STOP)
 		ia64_mca_spin(__FUNCTION__);
 
+	ia64_mc_info.imi_rendez_checkin[cpu] = IA64_MCA_RENDEZ_CHECKIN_NOTDONE;
 	/* Enable all interrupts */
 	local_irq_restore(flags);
 	return IRQ_HANDLED;
@@ -1224,26 +1225,27 @@ ia64_mca_handler(struct pt_regs *regs, s
 	if (notify_die(DIE_MCA_MONARCH_ENTER, "MCA", regs, (long)&nd, 0, 0)
 			= NOTIFY_STOP)
 		ia64_mca_spin(__FUNCTION__);
+
+	ia64_mc_info.imi_rendez_checkin[cpu] = IA64_MCA_RENDEZ_CHECKIN_CONCURRENT_MCA;
 	if (sos->monarch) {
 		ia64_wait_for_slaves(cpu, "MCA");
+
+		/* Wakeup all the processors which are spinning in the
+		 * rendezvous loop.  They will leave SAL, then spin in the OS
+		 * with interrupts disabled until this monarch cpu leaves the
+		 * MCA handler.  That gets control back to the OS so we can
+		 * backtrace the other cpus, backtrace when spinning in SAL
+		 * does not work.
+		 */
+		ia64_mca_wakeup_all();
+		if (notify_die(DIE_MCA_MONARCH_PROCESS, "MCA", regs, (long)&nd, 0, 0)
+				= NOTIFY_STOP)
+			ia64_mca_spin(__FUNCTION__);
 	} else {
-		ia64_mc_info.imi_rendez_checkin[cpu] = IA64_MCA_RENDEZ_CHECKIN_CONCURRENT_MCA;
 		while (cpu_isset(cpu, mca_cpu))
 			cpu_relax();	/* spin until monarch wakes us */
-		ia64_mc_info.imi_rendez_checkin[cpu] = IA64_MCA_RENDEZ_CHECKIN_NOTDONE;
         }
 
-	/* Wakeup all the processors which are spinning in the rendezvous loop.
-	 * They will leave SAL, then spin in the OS with interrupts disabled
-	 * until this monarch cpu leaves the MCA handler.  That gets control
-	 * back to the OS so we can backtrace the other cpus, backtrace when
-	 * spinning in SAL does not work.
-	 */
-	ia64_mca_wakeup_all();
-	if (notify_die(DIE_MCA_MONARCH_PROCESS, "MCA", regs, (long)&nd, 0, 0)
-			= NOTIFY_STOP)
-		ia64_mca_spin(__FUNCTION__);
-
 	/* Get the MCA error record and log it */
 	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_MCA);
 
@@ -1277,21 +1279,22 @@ ia64_mca_handler(struct pt_regs *regs, s
 		/* wake up the next monarch cpu,
 		 * and put this cpu in the rendez loop.
 		 */
-		ia64_mc_info.imi_rendez_checkin[cpu] = IA64_MCA_RENDEZ_CHECKIN_CONCURRENT_MCA;
 		for_each_online_cpu(i) {
 			if (cpu_isset(i, mca_cpu)) {
 				monarch_cpu = i;
 				cpu_clear(i, mca_cpu);	/* wake next cpu */
 				while (monarch_cpu != -1)
 					cpu_relax();	/* spin until last cpu leaves */
-				ia64_mc_info.imi_rendez_checkin[cpu] = IA64_MCA_RENDEZ_CHECKIN_NOTDONE;
 				set_curr_task(cpu, previous_current);
+				ia64_mc_info.imi_rendez_checkin[cpu]
+						= IA64_MCA_RENDEZ_CHECKIN_NOTDONE;
 				return;
 			}
 		}
 	}
 	set_curr_task(cpu, previous_current);
-	monarch_cpu = -1;
+	ia64_mc_info.imi_rendez_checkin[cpu] = IA64_MCA_RENDEZ_CHECKIN_NOTDONE;
+	monarch_cpu = -1;	/* This frees the slaves and previous monarchs */
 }
 
 static DECLARE_WORK(cmc_disable_work, ia64_mca_cmc_vector_disable_keventd);
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
