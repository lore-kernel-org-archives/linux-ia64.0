From: hawkes@sgi.com
Date: Sat, 03 Sep 2005 16:21:13 +0000
Subject: [PATCH 0/3] 2.6.13: cpuset + build_sched_domains() fix
Message-Id: <20050903162113.22561.80700.sendpatchset@tomahawk.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dinakar Guniguntala <dino@in.ibm.com>, Andrew Morton <akpm@osdl.org>, Ingo Molnar <mingo@elte.hu>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-ia64@vger.kernel.org, hawkes@sgi.com, Paul Jackson <pj@sgi.com>, linux-kernel@vger.kernel.org

Dinakar Guniguntala's "dynamic sched domains" functionality was been merged
into 2.6.13-rcN, although it was disabled at the last minute in the final
2.6.13 because it triggers a fatal bug for NUMA systems with more than one
CPU per node.

Conceptually, when a user/sysadmin declares a cpu-exclusive (a.k.a.
"isolated") cpuset, the cpuset code calls build_sched_domains() to isolate
the cpu-exclusive CPU(s) such that these CPU(s) only load-balance among
themselves and the remaining CPU(s) only load-balance among themselves.
Thus, the non-isolated CPU(s) spend no load-balancing effort trying to
offload tasks cannot be migrated away from their isolated CPU(s).
Otherwise, for example, if an isolated CPU were to be the systemwide
most-heavily-loaded CPU, then this would effectively disable all dynamic
load-balancing in the Scheduler because the non-isolated CPU(s) would
keep making futile efforts to offload isolated, non-migratable tasks.

Unfortunately, the 2.6.13 bug is that build_sched_domains() expects that
a sched domain will include all the CPUs of each node in the domain; more
accurately, that no node will belong in both an isolated cpuset and a
non-isolated cpuset.  Declaring a cpuset that violates this presumption
will produce flawed data structures and will oops the kernel.  Hence,
for 2.6.13, the cpuset code that would otherwise call build_sched_domains()
is #ifdef'ed disabled.

To trigger the problem (on a NUMA system with >1 CPUs per node, if the
kernel/cpuset.c disabling #ifdef is removed):
   cd /dev/cpuset
   mkdir newcpuset
   cd newcpuset
   echo 0 >cpus
   echo 0 >mems
   echo 1 >cpu_exclusive

The fix is in three parts:
1) A contribution from Ingo Molnar to pull the arch-specific ia64
   build_sched_domains() (et al) routines into kernel/sched.c to form
   a unified set of build and destroy routines.
2) My fix to the 2.6.13 problem:  dynamically allocate sched_group_nodes[]
   and sched_group_allnodes[] for each invocation of build_sched_domains(),
   rather than use global arrays for these structures, taking care to
   remember kmalloc() addresses so that arch_destroy_sched_domains() can
   properly kfree() them.
3) Undo the #ifdef disabling hack that was put into 2.6.13 to disable
   dynamic sched domains.

This is a patch against 2.6.13.  I have posted a previous similar patch
against 2.6.13-mm1.

John Hawkes
