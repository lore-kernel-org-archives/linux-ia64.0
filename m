From: Ashok Raj <ashok.raj@intel.com>
Date: Wed, 28 Apr 2004 01:00:34 +0000
Subject: Updated CPU Hotplug patches for IA64 [Patch 1/7]
Message-Id: <20040427180033.B29377@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Andrew

Here are the updated patches for CPU hotplug support for IA64. I reworked
some of the patches, and merged/split them based on feedback from 
David Mosberger-Tang, and couple others from the list.

Summary of changes.
- Removed kdb patch that got in by mistake :-(
- split migrate_irq.patch to separate the bug fix v.s. feature required for
  cpu hotplug support. (Thanks to Kanashige-san (fujitsu) for giving me that
  extra work :-)).
- Removed one per-cpu global that was also initialized to 0, which was not
  necessary.
- Removed some hunks that were white space in hotcpu_ia64.patch
- Sorted the newly added headers as per David Moshberger's requirements.
- Merged the rest of migrate_irq.patch with hotcpu_ia64.patch as it was
  integral part of the cpu hotplug patches.
- arch/ia64/dig/topology.c is added only for non-numa, numa adds it in 
  arch/ia64/mm/numa.c (Probably better to move to a common file in future)

Mostly the same, except some minor restructuring and cleanup...

Oh.. this time, i have learned to keep the lines together...:-) and not 
introducing line breaks... (Hopefully)

Cheers,
Ashok Raj
- Linux Core Software Group



Name: core_kernel_init.patch
Author: Ashok Raj (Intel Corporation)
D: This patch changes __init to __devinit to init_idle so that when a new cpu
D: arrives, it can call these functions at a later time.


---

 linux-2.6.5-lhcs-root/init/main.c    |    2 +-
 linux-2.6.5-lhcs-root/kernel/sched.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff -puN kernel/sched.c~core_kernel_init kernel/sched.c
--- linux-2.6.5-lhcs/kernel/sched.c~core_kernel_init	2004-04-26 22:14:54.113320301 -0700
+++ linux-2.6.5-lhcs-root/kernel/sched.c	2004-04-26 22:14:54.117226553 -0700
@@ -2657,7 +2657,7 @@ void show_state(void)
 	read_unlock(&tasklist_lock);
 }
 
-void __init init_idle(task_t *idle, int cpu)
+void __devinit init_idle(task_t *idle, int cpu)
 {
 	runqueue_t *idle_rq = cpu_rq(cpu), *rq = cpu_rq(task_cpu(idle));
 	unsigned long flags;
diff -puN init/main.c~core_kernel_init init/main.c
--- linux-2.6.5-lhcs/init/main.c~core_kernel_init	2004-04-26 22:14:54.114296864 -0700
+++ linux-2.6.5-lhcs-root/init/main.c	2004-04-26 22:14:54.124062494 -0700
@@ -181,7 +181,7 @@ EXPORT_SYMBOL(loops_per_jiffy);
    better than 1% */
 #define LPS_PREC 8
 
-void __init calibrate_delay(void)
+void __devinit calibrate_delay(void)
 {
 	unsigned long ticks, loopbit;
 	int lps_precision = LPS_PREC;

_
