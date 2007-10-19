From: Alex Chiang <achiang@hp.com>
Date: Fri, 19 Oct 2007 17:03:11 +0000
Subject: Re: [PATCH] ia64: /proc/cpuinfo "physical id" field cleanups
Message-Id: <20071019170311.GA16961@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070928010850.GG16444@ldl.fc.hp.com>
In-Reply-To: <20070928010850.GG16444@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Tony,

After a lot of rethinking (and a little bit of rework), here is
my second shot at this patch.

The only real change from the prior version is that I change the
intialization of socket_id to 0 as default. I think the benefit
of displaying information from PAL/SAL (when available) on older
platforms outweighs the oddity that the user may see physical_id
= 0 for multiple CPUs occasionally.

I've tested on:

  rx1620
  rx2660
  rx6600
  rx8620
  rx8640
  superdome

And it does reasonable things on all of them.

Please consider this for inclusion. Thanks.

/ac

From: Alex Chiang <achiang@hp.com>

Clean up the process for presenting the "physical id" field in
/proc/cpuinfo.

	- remove global smp_num_cpucores, as it is mostly useless

	- remove check_for_logical_procs(), since we do the same
	  functionality in identify_siblings()

	- initialize socket_id to 0 as a default, in case an
	  older CPU implements neither PAL_LOGICAL_TO_PHYSICAL
	  nor SAL_PHYSICAL_ID_INFO. We're presenting this data
	  later in /proc/cpuinfo, so we'd like a reasonable
	  value for older platforms.

	- reflow logic in identify_siblings(). If an older CPU
	  does not implement PAL_LOGICAL_TO_PHYSICAL, we may still
	  be able to get useful information from SAL_PHYSICAL_ID_INFO

	- in identify_siblings(), threads/cores are a property of
	  the CPU, not the platform

	- remove useless printk's about multi-core / thread
	  capability in identify_siblings(), as that information
	  is readily available in /proc/cpuinfo, and printing for
	  the BSP only adds little value

	- smp_num_siblings is now meaningful if any CPU in the
	  system supports threads, not just the BSP

	- expose "physical id" field, even on CPUs that are not
	  multi-core / multi-threaded. Now we know what sockets
	  Madisons live in too

Signed-off-by: Alex Chiang <achiang@hp.com>
---
 arch/ia64/kernel/setup.c   |   49 +++++++------------------------------------
 arch/ia64/kernel/smpboot.c |   21 ++++++++++++------
 include/asm-ia64/smp.h     |    1 -
 3 files changed, 22 insertions(+), 49 deletions(-)

diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index c5cfcfa..3ceca25 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -405,34 +405,6 @@ mark_bsp_online (void)
 #endif
 }
 
-#ifdef CONFIG_SMP
-static void __init
-check_for_logical_procs (void)
-{
-	pal_logical_to_physical_t info;
-	s64 status;
-
-	status = ia64_pal_logical_to_phys(0, &info);
-	if (status = -1) {
-		printk(KERN_INFO "No logical to physical processor mapping "
-		       "available\n");
-		return;
-	}
-	if (status) {
-		printk(KERN_ERR "ia64_pal_logical_to_phys failed with %ld\n",
-		       status);
-		return;
-	}
-	/*
-	 * Total number of siblings that BSP has.  Though not all of them 
-	 * may have booted successfully. The correct number of siblings 
-	 * booted is in info.overview_num_log.
-	 */
-	smp_num_siblings = info.overview_tpc;
-	smp_num_cpucores = info.overview_cpp;
-}
-#endif
-
 static __initdata int nomca;
 static __init int setup_nomca(char *s)
 {
@@ -528,15 +500,6 @@ setup_arch (char **cmdline_p)
 
 #ifdef CONFIG_SMP
 	cpu_physical_id(0) = hard_smp_processor_id();
-	check_for_logical_procs();
-	if (smp_num_cpucores > 1)
-		printk(KERN_INFO
-		       "cpu package is Multi-Core capable: number of cores=%d\n",
-		       smp_num_cpucores);
-	if (smp_num_siblings > 1)
-		printk(KERN_INFO
-		       "cpu package is Multi-Threading capable: number of siblings=%d\n",
-		       smp_num_siblings);
 #endif
 
 	cpu_init();	/* initialize the bootstrap CPU */
@@ -648,13 +611,14 @@ show_cpuinfo (struct seq_file *m, void *v)
 		   c->itc_freq / 1000000, c->itc_freq % 1000000,
 		   lpj*HZ/500000, (lpj*HZ/5000) % 100);
 #ifdef CONFIG_SMP
-	seq_printf(m, "siblings   : %u\n", cpus_weight(cpu_core_map[cpunum]));
+	seq_printf(m, "siblings   : %u\n",
+		      "physical id: %d\n",
+		      cpus_weight(cpu_core_map[cpunum]), c->socket_id);
 	if (c->threads_per_core > 1 || c->cores_per_socket > 1)
 		seq_printf(m,
-		   	   "physical id: %u\n"
 		   	   "core id    : %u\n"
 		   	   "thread id  : %u\n",
-		   	   c->socket_id, c->core_id, c->thread_id);
+		   	   c->core_id, c->thread_id);
 #endif
 	seq_printf(m,"\n");
 
@@ -763,9 +727,12 @@ identify_cpu (struct cpuinfo_ia64 *c)
 	 * for Multi-Threading/Multi-Core capable CPUs
 	 */
 	c->threads_per_core = c->cores_per_socket = c->num_log = 1;
-	c->socket_id = -1;
+	c->socket_id = 0;
 
 	identify_siblings(c);
+
+	if (c->threads_per_core > smp_num_siblings)
+		smp_num_siblings = c->threads_per_core;
 #endif
 	c->ppn = cpuid.field.ppn;
 	c->number = cpuid.field.number;
diff --git a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
index c57dbce..f0fc4d8 100644
--- a/arch/ia64/kernel/smpboot.c
+++ b/arch/ia64/kernel/smpboot.c
@@ -142,7 +142,6 @@ DEFINE_PER_CPU_SHARED_ALIGNED(cpumask_t, cpu_sibling_map);
 EXPORT_PER_CPU_SYMBOL(cpu_sibling_map);
 
 int smp_num_siblings = 1;
-int smp_num_cpucores = 1;
 
 /* which logical CPU number maps to which CPU (physical APIC ID) */
 volatile int ia64_cpu_to_sapicid[NR_CPUS];
@@ -886,13 +885,17 @@ identify_siblings(struct cpuinfo_ia64 *c)
 	u16 pltid;
 	pal_logical_to_physical_t info;
 
-	if (smp_num_cpucores = 1 && smp_num_siblings = 1)
-		return;
-
 	if ((status = ia64_pal_logical_to_phys(-1, &info)) != PAL_STATUS_SUCCESS) {
-		printk(KERN_ERR "ia64_pal_logical_to_phys failed with %ld\n",
-		       status);
-		return;
+		if (status != PAL_STATUS_UNIMPLEMENTED) {
+			printk(KERN_ERR
+				"ia64_pal_logical_to_phys failed with %ld\n",
+				status);
+			return;
+		}
+
+		info.overview_ppid = 0;
+		info.overview_cpp  = 1;
+		info.overview_tpc  = 1;
 	}
 	if ((status = ia64_sal_physical_id_info(&pltid)) != PAL_STATUS_SUCCESS) {
 		printk(KERN_ERR "ia64_sal_pltid failed with %ld\n", status);
@@ -900,6 +903,10 @@ identify_siblings(struct cpuinfo_ia64 *c)
 	}
 
 	c->socket_id =  (pltid << 8) | info.overview_ppid;
+
+	if (info.overview_cpp = 1 && info.overview_tpc = 1)
+		return;
+
 	c->cores_per_socket = info.overview_cpp;
 	c->threads_per_core = info.overview_tpc;
 	c->num_log = info.overview_num_log;
diff --git a/include/asm-ia64/smp.h b/include/asm-ia64/smp.h
index 1703c9d..3d13fea 100644
--- a/include/asm-ia64/smp.h
+++ b/include/asm-ia64/smp.h
@@ -60,7 +60,6 @@ extern cpumask_t cpu_online_map;
 extern cpumask_t cpu_core_map[NR_CPUS];
 DECLARE_PER_CPU(cpumask_t, cpu_sibling_map);
 extern int smp_num_siblings;
-extern int smp_num_cpucores;
 extern void __iomem *ipi_base_addr;
 extern unsigned char smp_int_redirect;
 
-- 
1.5.3.1.1.g1e61

