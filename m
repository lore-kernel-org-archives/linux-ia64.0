From: Dean Nelson <dcn@sgi.com>
Date: Wed, 16 Jun 2004 16:33:39 +0000
Subject: [PATCH 1/4] SGI Altix cross partition functionality
Message-Id: <20040616163339.GA27891@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch exports the symbols needed by XP[C|NET].


Index: linux/arch/ia64/kernel/sal.c
=================================--- linux.orig/arch/ia64/kernel/sal.c	Thu Jun 10 14:47:44 2004
+++ linux/arch/ia64/kernel/sal.c	Thu Jun 10 16:31:55 2004
@@ -12,12 +12,15 @@
 #include <linux/init.h>
 #include <linux/spinlock.h>
 #include <linux/string.h>
+#include <linux/module.h>
 
 #include <asm/page.h>
 #include <asm/sal.h>
 #include <asm/pal.h>
 
 spinlock_t sal_lock __cacheline_aligned = SPIN_LOCK_UNLOCKED;
+EXPORT_SYMBOL(sal_lock);
+
 unsigned long sal_platform_features;
 
 unsigned short sal_revision;
@@ -38,6 +41,8 @@ default_handler (void)
 }
 
 ia64_sal_handler ia64_sal = (ia64_sal_handler) default_handler;
+EXPORT_SYMBOL(ia64_sal);
+
 ia64_sal_desc_ptc_t *ia64_ptc_domain_info;
 
 const char *
Index: linux/arch/ia64/kernel/smpboot.c
=================================--- linux.orig/arch/ia64/kernel/smpboot.c	Thu Jun 10 14:47:53 2004
+++ linux/arch/ia64/kernel/smpboot.c	Thu Jun 10 16:31:55 2004
@@ -498,6 +498,7 @@ u8 cpu_to_node_map[NR_CPUS] __cacheline_
 EXPORT_SYMBOL(cpu_to_node_map);
 /* which logical CPUs are on which nodes */
 cpumask_t node_to_cpu_mask[MAX_NUMNODES] __cacheline_aligned;
+EXPORT_SYMBOL(node_to_cpu_mask);
 
 /*
  * Build cpu to node mapping and initialize the per node cpu masks.
Index: linux/arch/ia64/sn/kernel/bte.c
=================================--- linux.orig/arch/ia64/sn/kernel/bte.c	Mon May 10 12:32:38 2004
+++ linux/arch/ia64/sn/kernel/bte.c	Thu Jun 10 16:31:55 2004
@@ -7,6 +7,7 @@
  */
 
 #include <linux/config.h>
+#include <linux/module.h>
 #include <asm/sn/sgi.h>
 #include <asm/sn/nodepda.h>
 #include <asm/sn/addrs.h>
@@ -169,6 +170,7 @@ bte_copy(u64 src, u64 dest, u64 len, u64
 
 	return bte_status;
 }
+EXPORT_SYMBOL(bte_copy);
 
 
 /*
@@ -405,7 +407,7 @@ void
 bte_init_cpu(void)
 {
 	/* Called by setup.c as each cpu is being added to the nodepda */
-	if (local_node_data->active_cpu_count & 0x1) {
+	if (get_slice() = 0) {
 		pda->cpu_bte_if[0] = &(nodepda->bte_if[0]);
 		pda->cpu_bte_if[1] = &(nodepda->bte_if[1]);
 	} else {
Index: linux/arch/ia64/sn/kernel/setup.c
=================================--- linux.orig/arch/ia64/sn/kernel/setup.c	Thu Jun 10 16:29:44 2004
+++ linux/arch/ia64/sn/kernel/setup.c	Thu Jun 10 16:31:55 2004
@@ -50,6 +50,7 @@
 #include <asm/sn/sn2/shub.h>
 
 DEFINE_PER_CPU(struct pda_s, pda_percpu);
+EXPORT_SYMBOL(per_cpu__pda_percpu);
 
 #define MAX_PHYS_MEMORY		(1UL << 49)     /* 1 TB */
 
@@ -68,8 +69,11 @@ unsigned long sn_rtc_cycles_per_second; 
 EXPORT_SYMBOL(sn_rtc_cycles_per_second);
 
 partid_t sn_partid = -1;
+EXPORT_SYMBOL(sn_partid);
 char sn_system_serial_number_string[128];
+EXPORT_SYMBOL(sn_system_serial_number_string);
 u64 sn_partition_serial_number;
+EXPORT_SYMBOL(sn_partition_serial_number);
 
 short physical_node_map[MAX_PHYSNODE_ID];
 
Index: linux/include/asm-ia64/sn/sn_sal.h
=================================--- linux.orig/include/asm-ia64/sn/sn_sal.h	Mon May 10 12:33:21 2004
+++ linux/include/asm-ia64/sn/sn_sal.h	Thu Jun 10 16:31:55 2004
@@ -13,6 +13,7 @@
 
 
 #include <linux/config.h>
+#include <asm/sn/sgi.h>
 #include <asm/sal.h>
 #include <asm/sn/sn_cpuid.h>
 #include <asm/sn/arch.h>
Index: linux/kernel/exit.c
=================================--- linux.orig/kernel/exit.c	Thu Jun 10 15:04:09 2004
+++ linux/kernel/exit.c	Thu Jun 10 16:31:55 2004
@@ -1184,6 +1184,7 @@ end_wait4:
 	remove_wait_queue(&current->wait_chldexit,&wait);
 	return retval;
 }
+EXPORT_SYMBOL(sys_wait4);
 
 #ifdef __ARCH_WANT_SYS_WAITPID
 
Index: linux/kernel/sched.c
=================================--- linux.orig/kernel/sched.c	Thu Jun 10 16:30:39 2004
+++ linux/kernel/sched.c	Thu Jun 10 16:31:55 2004
@@ -2814,6 +2814,7 @@ asmlinkage long sys_sched_setscheduler(p
 {
 	return setscheduler(pid, policy, param);
 }
+EXPORT_SYMBOL(sys_sched_setscheduler);
 
 /**
  * sys_sched_setparam - set/change the RT priority of a thread
Index: linux/mm/page_alloc.c
=================================--- linux.orig/mm/page_alloc.c	Thu Jun 10 14:47:51 2004
+++ linux/mm/page_alloc.c	Thu Jun 10 16:31:55 2004
@@ -40,6 +40,7 @@ unsigned long totalram_pages;
 unsigned long totalhigh_pages;
 int nr_swap_pages;
 int numnodes = 1;
+EXPORT_SYMBOL(numnodes);
 int sysctl_lower_zone_protection = 0;
 
 EXPORT_SYMBOL(totalram_pages);
