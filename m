From: Rusty Russell <rusty@rustcorp.com.au>
Date: Fri, 08 May 2015 18:22:52 +0000
Subject: ia64: make cpu_callin_map non-volatile.
Message-Id: <87vbg3kkib.fsf@rustcorp.com.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

cpumask_test_cpu() doesn't take volatile, unlike the obsoleted
cpu_isset.  The only place ia64 really cares is the spin waiting for a
bit; udelay() is probably a barrier but insert rmb() to be sure.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

diff --git a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
index 15051e9c2c6f..629975b56608 100644
--- a/arch/ia64/kernel/smpboot.c
+++ b/arch/ia64/kernel/smpboot.c
@@ -127,7 +127,7 @@ int smp_num_siblings = 1;
 volatile int ia64_cpu_to_sapicid[NR_CPUS];
 EXPORT_SYMBOL(ia64_cpu_to_sapicid);
 
-static volatile cpumask_t cpu_callin_map;
+static cpumask_t cpu_callin_map;
 
 struct smp_boot_data smp_boot_data __initdata;
 
@@ -477,6 +477,7 @@ do_boot_cpu (int sapicid, int cpu, struct task_struct *idle)
 	for (timeout = 0; timeout < 100000; timeout++) {
 		if (cpumask_test_cpu(cpu, &cpu_callin_map))
 			break;  /* It has booted */
+		rmb(); /* Make sure we re-read cpu_callin_map */
 		udelay(100);
 	}
 	Dprintk("\n");
