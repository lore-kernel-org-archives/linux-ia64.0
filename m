From: "Ashok Raj" <ashok.raj@intel.com>
Date: Sun, 25 Apr 2004 06:46:34 +0000
Subject: [RFC IA64 Hotplug] [Patch 1/7] core_kernel_init.patch
Message-Id: <ORSMSX4041LEdyt3cew00000172@orsmsx404.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Patch 1/7

Removed __init in core kernel files.


Cheers,
ashok raj
- Linux Core Software Group
   


Name: core_kernel_init.patch
Author: Ashok Raj (Intel Corporation)
D: This patch changes __init to __devinit to init_idle so that when a new
cpu
D: arrives, it can call these functions at a later time.


---

 linux-2.6.5-lhcs-root/init/main.c    |    2 +-
 linux-2.6.5-lhcs-root/kernel/sched.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff -puN kernel/sched.c~core_kernel_init kernel/sched.c
--- linux-2.6.5-lhcs/kernel/sched.c~core_kernel_init	2004-04-20
21:08:09.748764489 -0700
+++ linux-2.6.5-lhcs-root/kernel/sched.c	2004-04-20
21:08:09.752670741 -0700
@@ -2657,7 +2657,7 @@ void show_state(void)
 	read_unlock(&tasklist_lock);
 }
 
-void __init init_idle(task_t *idle, int cpu)
+void __devinit init_idle(task_t *idle, int cpu)
 {
 	runqueue_t *idle_rq = cpu_rq(cpu), *rq = cpu_rq(task_cpu(idle));
 	unsigned long flags;
diff -puN init/main.c~core_kernel_init init/main.c
--- linux-2.6.5-lhcs/init/main.c~core_kernel_init	2004-04-20
21:08:09.750717615 -0700
+++ linux-2.6.5-lhcs-root/init/main.c	2004-04-20 21:08:09.753647304 -0700
@@ -181,7 +181,7 @@ EXPORT_SYMBOL(loops_per_jiffy);
    better than 1% */
 #define LPS_PREC 8
 
-void __init calibrate_delay(void)
+void __devinit calibrate_delay(void)
 {
 	unsigned long ticks, loopbit;
 	int lps_precision = LPS_PREC;

_

