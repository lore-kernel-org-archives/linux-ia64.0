From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Thu, 17 Apr 2003 18:51:16 +0000
Subject: [Linux-ia64] Re: [patch] consolidate cpu_is_online definition
Message-Id: <marc-linux-ia64-105590723705536@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 01 April 2003 12:07 pm, Martin Hicks wrote:
> Here is a patch against 2.4.21-pre5-ia64-030312 that consolidates the
> definitions of cpu_is_online().  This is basically the same patch that
> was recently applied to 2.5

I applied this for 2.4 with a couple changes:
  - both defs in asm-ia64/smp.h to keep it arch-specific
  - used cpu_online as in 2.5, since these are local uses anyway

Here's the actual patch I applied.  Thanks!

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1070  -> 1.1071 
#	arch/ia64/kernel/palinfo.c	1.7     -> 1.8    
#	arch/ia64/kernel/perfmon.c	1.18    -> 1.19   
#	include/asm-ia64/smp.h	1.5     -> 1.6    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/04/17	bjorn_helgaas@hp.com	1.1071
# ia64: remove cpu_is_online local defs, in favor of a 2.5-style cpu_online.
# --------------------------------------------
#
diff -Nru a/arch/ia64/kernel/palinfo.c b/arch/ia64/kernel/palinfo.c
--- a/arch/ia64/kernel/palinfo.c	Thu Apr 17 12:27:39 2003
+++ b/arch/ia64/kernel/palinfo.c	Thu Apr 17 12:27:39 2003
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
@@ -936,7 +928,7 @@
 	 */
 	for (i=0; i < NR_CPUS; i++) {
 
-		if (!cpu_is_online(i)) continue;
+		if (!cpu_online(i)) continue;
 
 		sprintf(cpustr,CPUSTR, i);
 
diff -Nru a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
--- a/arch/ia64/kernel/perfmon.c	Thu Apr 17 12:27:39 2003
+++ b/arch/ia64/kernel/perfmon.c	Thu Apr 17 12:27:39 2003
@@ -24,6 +24,7 @@
 #include <linux/wrapper.h>
 #include <linux/mm.h>
 #include <linux/sysctl.h>
+#include <linux/smp.h>
 
 #include <asm/bitops.h>
 #include <asm/errno.h>
@@ -131,12 +132,6 @@
 
 #define PFM_REG_RETFLAG_SET(flags, val)	do { flags &= ~PFM_REG_RETFL_MASK; flags |= (val); } while(0)
 
-#ifdef CONFIG_SMP
-#define cpu_is_online(i) (cpu_online_map & (1UL << i))
-#else
-#define cpu_is_online(i)        (i=0)
-#endif
-
 /*
  * debugging
  */
@@ -1080,7 +1075,7 @@
 		 * and it must be a valid CPU
 		 */
 		cpu = ffz(~pfx->ctx_cpu_mask);
-		if (cpu_is_online(cpu) = 0) {
+		if (cpu_online(cpu) = 0) {
 			DBprintk(("CPU%d is not online\n", cpu));
 			return -EINVAL;
 		}
@@ -3169,7 +3164,7 @@
 	p += sprintf(p, "ovfl_mask              : 0x%lx\n", pmu_conf.ovfl_val);
 
 	for(i=0; i < NR_CPUS; i++) {
-		if (cpu_is_online(i) = 0) continue;
+		if (cpu_online(i) = 0) continue;
 		p += sprintf(p, "CPU%-2d overflow intrs   : %lu\n", i, pfm_stats[i].pfm_ovfl_intr_count);
 		p += sprintf(p, "CPU%-2d spurious intrs   : %lu\n", i, pfm_stats[i].pfm_spurious_ovfl_intr_count);
 		p += sprintf(p, "CPU%-2d recorded samples : %lu\n", i, pfm_stats[i].pfm_recorded_samples_count);
diff -Nru a/include/asm-ia64/smp.h b/include/asm-ia64/smp.h
--- a/include/asm-ia64/smp.h	Thu Apr 17 12:27:39 2003
+++ b/include/asm-ia64/smp.h	Thu Apr 17 12:27:39 2003
@@ -48,6 +48,8 @@
 
 extern unsigned long ap_wakeup_vector;
 
+#define cpu_online(cpu)		(cpu_online_map & (1UL << (cpu)))
+
 /*
  * Function to map hard smp processor id to logical id.  Slow, so
  * don't use this in performance-critical code.
@@ -122,6 +124,10 @@
 extern int smp_call_function_single (int cpuid, void (*func) (void *info), void *info,
 				     int retry, int wait);
 
+
+#else
+
+#define cpu_online(cpu)		(cpu = 0)
 
 #endif /* CONFIG_SMP */
 #endif /* _ASM_IA64_SMP_H */


