From: Martin Hicks <mort@wildopensource.com>
Date: Fri, 28 Mar 2003 14:52:27 +0000
Subject: [Linux-ia64] [patch] replace cpu_is_online with cpu_online
Message-Id: <marc-linux-ia64-105590723705356@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

Here is a patch against 2.5.64-ia64-030307 to consolidate the uses of
cpu_is_online() to use the existing cpu_online() macro.

mh

-- 
Wild Open Source Inc.                  mort@wildopensource.com



diff -ur linux-2.5.64.pristine/arch/ia64/kernel/palinfo.c linux-2.5.64/arch/ia64/kernel/palinfo.c
--- linux-2.5.64.pristine/arch/ia64/kernel/palinfo.c	Thu Mar 27 18:32:56 2003
+++ linux-2.5.64/arch/ia64/kernel/palinfo.c	Thu Mar 27 18:36:54 2003
@@ -27,9 +27,7 @@
 #include <asm/sal.h>
 #include <asm/page.h>
 #include <asm/processor.h>
-#ifdef CONFIG_SMP
 #include <linux/smp.h>
-#endif
 
 MODULE_AUTHOR("Stephane Eranian <eranian@hpl.hp.com>");
 MODULE_DESCRIPTION("/proc interface to IA-64 PAL");
@@ -37,12 +35,6 @@
 
 #define PALINFO_VERSION "0.5"
 
-#ifdef CONFIG_SMP
-#define cpu_is_online(i) (cpu_online_map & (1UL << i))
-#else
-#define cpu_is_online(i)	1
-#endif
-
 typedef int (*palinfo_func_t)(char*);
 
 typedef struct {
@@ -933,7 +925,7 @@
 	 */
 	for (i=0; i < NR_CPUS; i++) {
 
-		if (!cpu_is_online(i)) continue;
+		if (!cpu_online(i)) continue;
 
 		sprintf(cpustr,CPUSTR, i);
 
diff -ur linux-2.5.64.pristine/arch/ia64/kernel/perfmon.c linux-2.5.64/arch/ia64/kernel/perfmon.c
--- linux-2.5.64.pristine/arch/ia64/kernel/perfmon.c	Thu Mar 27 18:32:56 2003
+++ linux-2.5.64/arch/ia64/kernel/perfmon.c	Thu Mar 27 18:37:09 2003
@@ -24,6 +24,7 @@
 #include <linux/wrapper.h>
 #include <linux/mm.h>
 #include <linux/sysctl.h>
+#include <linux/smp.h>
 
 #include <asm/bitops.h>
 #include <asm/errno.h>
@@ -134,12 +135,6 @@
 #define PFM_CPUINFO_CLEAR(v)	__get_cpu_var(pfm_syst_info) &= ~(v)
 #define PFM_CPUINFO_SET(v)	__get_cpu_var(pfm_syst_info) |= (v)
 
-#ifdef CONFIG_SMP
-#define cpu_is_online(i) (cpu_online_map & (1UL << i))
-#else
-#define cpu_is_online(i)        (i=0)
-#endif
-
 /*
  * debugging
  */
@@ -1082,7 +1077,7 @@
 		 * and it must be a valid CPU
 		 */
 		cpu = ffz(~pfx->ctx_cpu_mask);
-		if (cpu_is_online(cpu) = 0) {
+		if (cpu_online(cpu) = 0) {
 			DBprintk(("CPU%d is not online\n", cpu));
 			return -EINVAL;
 		}
@@ -3153,7 +3148,7 @@
 	p += sprintf(p, "ovfl_mask              : 0x%lx\n", pmu_conf.ovfl_val);
 
 	for(i=0; i < NR_CPUS; i++) {
-		if (cpu_is_online(i) = 0) continue;
+		if (cpu_online(i) = 0) continue;
 		p += sprintf(p, "CPU%-2d overflow intrs   : %lu\n", i, pfm_stats[i].pfm_ovfl_intr_count);
 		p += sprintf(p, "CPU%-2d spurious intrs   : %lu\n", i, pfm_stats[i].pfm_spurious_ovfl_intr_count);
 		p += sprintf(p, "CPU%-2d recorded samples : %lu\n", i, pfm_stats[i].pfm_recorded_samples_count);

