From: Erich Focht <efocht@ess.nec.de>
Date: Mon, 22 Jul 2002 13:59:41 +0000
Subject: [Linux-ia64] node affine NUMA scheduler
Message-Id: <marc-linux-ia64-105590701905801@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

There's a new version of the node affine NUMA scheduler extension based
on the O(1) scheduler at
    http://home.arcor.de/efocht/sched/Nod18_2.4.18-ia64-O1ef7.patch

The patch is for 2.4.18 kernels and it has been tested on IA64 systems.
It requires the O(1) scheduler patch with the corrected complex macros
which I posted to the LSE and linux-ia64 mailing lists last week. For
IA64 you should use:
    http://home.arcor.de/efocht/sched/O1_ia64-ef7-2.4.18.patch.bz2
which should be applied to   2.4.18  +  ia64-020622 patch.
For IA32 (NUMA-Q) try instead:
    http://home.arcor.de/efocht/sched/O1_i386-ef7-2.4.18.patch.bz2

What is it good for?

 - Extends the scheduler to NUMA.
 - Each task gets a homenode assigned at start (initial load balancing).
 - A memory affinity patch (like discontigmem, or similar) should take
   care that the memory of the task is allocated mainly from its
   homenode.
 - The scheduler attracts the tasks to their homenodes while trying to
   keep the nodes equally balanced.
 - Target: keep processes and their memory on the same node to reduce
   memory access latencies without having to fiddle with the
   cpus_allowed masks (hard affinities).
 - Within one node, behaves like the normal O(1) scheduler.

For an overview over the features have a look at:
    http://home.arcor.de/efocht/sched

There are several changes compared to the previous version, the most
important ones are:
 - Extension to multilevel NUMA hierarchy by implementing delays when
   stealing tasks from remote nodes.
 - Better selection of task to be stolen from busiest runqueue. Take
   into account cache coolness, node and supernode of task and runqueue.

Comments and feedback are very wellcome.

Regards,
Erich


