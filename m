From: Alex Shi <alex.shi@intel.com>
Date: Wed, 06 Jun 2012 06:52:51 +0000
Subject: [RFC PATCH] sched/numa: do load balance between remote nodes
Message-Id: <1338965571-9812-1-git-send-email-alex.shi@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: a.p.zijlstra@chello.nl
Cc: anton@samba.org, benh@kernel.crashing.org, cmetcalf@tilera.com, dhowells@redhat.com, davem@davemloft.net, fenghua.yu@intel.com, hpa@zytor.com, ink@jurassic.park.msu.ru, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, mattst88@gmail.com, paulus@samba.org, lethal@linux-sh.org, ralf@linux-mips.org, rth@twiddle.net, sparclinux@vger.kernel.org, tony.luck@intel.com, x86@kernel.org, sivanich@sgi.com, greg.pearson@hp.com, kamezawa.hiroyu@jp.fujitsu.com, bob.picco@oracle.com, chris.mason@oracle.com, torvalds@linux-foundation.org, akpm@linux-foundation.org, mingo@kernel.org, pjt@google.com, tglx@linutronix.de, seto.hidetoshi@jp.fujitsu.com, ak@linux.intel.com, arjan.van.de.ven@intel.com

commit cb83b629b remove the NODE sched domain and check if the node
distance in SLIT table is farther than REMOTE_DISTANCE, if so, it will
lose the load balance chance at exec/fork/wake_affine points.

But actually, even the node distance is farther than REMOTE_DISTANCE,
Modern CPUs also has QPI like connections, that make memory access is
not too slow between nodes. So above losing on NUMA machine make a
huge performance regression on benchmark: hackbench, tbench, netperf
and oltp etc.

This patch will recover the scheduler behavior to old mode on all my
Intel platforms: NHM EP/EX, WSM EP, SNB EP/EP4S, and so remove the
perfromance regressions. (all of them just has 2 kinds distance, 10 21)

Signed-off-by: Alex Shi <alex.shi@intel.com>
---
 kernel/sched/core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 39eb601..b2ee41a 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -6286,7 +6286,7 @@ static int sched_domains_curr_level;
 
 static inline int sd_local_flags(int level)
 {
-	if (sched_domains_numa_distance[level] > REMOTE_DISTANCE)
+	if (sched_domains_numa_distance[level] > RECLAIM_DISTANCE)
 		return 0;
 
 	return SD_BALANCE_EXEC | SD_BALANCE_FORK | SD_WAKE_AFFINE;
-- 
1.7.5.4

