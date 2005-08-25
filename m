From: Paul Jackson <pj@sgi.com>
Date: Thu, 25 Aug 2005 19:47:50 +0000
Subject: [PATCH 2.6.13-rc7 1/2] undo partial cpu_exclusive sched domain disabling
Message-Id: <20050825194750.7341.75723.sendpatchset@jackhammer.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: torvalds@osdl.org, Andrew Morton <akpm@osdl.org>
Cc: nickpiggin@yahoo.com.au, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, paulus@samba.org, mingo@elte.hu, hawkes@sgi.com, Paul Jackson <pj@sgi.com>, dino@in.ibm.com

The partial disabling of Dinakar's new facility to allow
cpu_exclusive cpusets to define dynamic sched domains
doesn't go far enough.  At the suggestion of Nick Piggin
and Dinakar, let us instead totally disable this facility
for 2.6.13, in order to avoid problems first reported
by John Hawkes (corrupt sched data structures and kernel oops).

This patch removes the partial disabling code in 2.6.13-rc7,
in anticipation of the next patch, which will totally disable
it instead.

Signed-off-by: Paul Jackson <pj@sgi.com>

Index: linux-2.6.13-rc7/kernel/cpuset.c
=================================--- linux-2.6.13-rc7.orig/kernel/cpuset.c
+++ linux-2.6.13-rc7/kernel/cpuset.c
@@ -636,25 +636,6 @@ static void update_cpu_domains(struct cp
 		return;
 
 	/*
-	 * Hack to avoid 2.6.13 partial node dynamic sched domain bug.
-	 * Require the 'cpu_exclusive' cpuset to include all (or none)
-	 * of the CPUs on each node, or return w/o changing sched domains.
-	 * Remove this hack when dynamic sched domains fixed.
-	 */
-	{
-		int i, j;
-
-		for_each_cpu_mask(i, cur->cpus_allowed) {
-			cpumask_t mask = node_to_cpumask(cpu_to_node(i));
-
-			for_each_cpu_mask(j, mask) {
-				if (!cpu_isset(j, cur->cpus_allowed))
-					return;
-			}
-		}
-	}
-
-	/*
 	 * Get all cpus from parent's cpus_allowed not part of exclusive
 	 * children
 	 */

-- 
                          I won't rest till it's the best ...
                          Programmer, Linux Scalability
                          Paul Jackson <pj@sgi.com> 1.650.933.1373
