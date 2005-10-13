From: hawkes@sgi.com
Date: Thu, 13 Oct 2005 19:01:18 +0000
Subject: [PATCH] 2.6.14-rc4: more wider use of for_each_cpu_mask() in arch/ia64
Message-Id: <20051013190118.13190.1459.sendpatchset@tomahawk.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In arch/ia64 change the explicit use of a for-loop using NR_CPUS into the
general for_each_online_cpu() construct.  This widens the scope of potential
future optimizations of the general constructs, as well as takes advantage
of the existing optimizations of first_cpu() and next_cpu(), which is
advantageous when the true CPU count is much smaller than NR_CPUS.

Signed-off-by: John Hawkes <hawkes@sgi.com>

Index: linux/arch/ia64/kernel/mca.c
=================================--- linux.orig/arch/ia64/kernel/mca.c	2005-10-11 09:58:56.000000000 -0700
+++ linux/arch/ia64/kernel/mca.c	2005-10-11 10:01:22.000000000 -0700
@@ -508,9 +508,7 @@
 	int cpu;
 
 	/* Clear the Rendez checkin flag for all cpus */
-	for(cpu = 0; cpu < NR_CPUS; cpu++) {
-		if (!cpu_online(cpu))
-			continue;
+	for_each_online_cpu(cpu) {
 		if (ia64_mc_info.imi_rendez_checkin[cpu] = IA64_MCA_RENDEZ_CHECKIN_DONE)
 			ia64_mca_wakeup(cpu);
 	}
