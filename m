From: Martin Hicks <mort@wildopensource.com>
Date: Tue, 01 Apr 2003 19:07:31 +0000
Subject: [Linux-ia64] [patch] consolidate cpu_is_online definition
Message-Id: <marc-linux-ia64-105590723705377@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Bjorn,

Here is a patch against 2.4.21-pre5-ia64-030312 that consolidates the
definitions of cpu_is_online().  This is basically the same patch that
was recently applied to 2.5

thanks
mh

-- 
Wild Open Source Inc.                  mort@wildopensource.com


diff -ur linux-2.4.21-pre5.pristine/arch/ia64/kernel/palinfo.c linux-2.4.21-pre5/arch/ia64/kernel/palinfo.c
--- linux-2.4.21-pre5.pristine/arch/ia64/kernel/palinfo.c	Thu Nov 28 16:53:09 2002
+++ linux-2.4.21-pre5/arch/ia64/kernel/palinfo.c	Tue Apr  1 18:23:11 2003
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
diff -ur linux-2.4.21-pre5.pristine/arch/ia64/kernel/perfmon.c linux-2.4.21-pre5/arch/ia64/kernel/perfmon.c
--- linux-2.4.21-pre5.pristine/arch/ia64/kernel/perfmon.c	Sun Mar 30 17:31:07 2003
+++ linux-2.4.21-pre5/arch/ia64/kernel/perfmon.c	Tue Apr  1 18:23:11 2003
@@ -24,6 +24,7 @@
 #include <linux/wrapper.h>
 #include <linux/mm.h>
 #include <linux/sysctl.h>
+#include <linux/smp.h>
 
 #include <asm/bitops.h>
 #include <asm/errno.h>
@@ -134,12 +135,6 @@
 #define PFM_CPUINFO_CLEAR(v)	local_cpu_data->pfm_syst_info &= ~(v)
 #define PFM_CPUINFO_SET(v)	local_cpu_data->pfm_syst_info |= (v)
 
-#ifdef CONFIG_SMP
-#define cpu_is_online(i) (cpu_online_map & (1UL << i))
-#else
-#define cpu_is_online(i)        (i=0)
-#endif
-
 /*
  * debugging
  */
Only in linux-2.4.21-pre5/include/asm-ia64: offsets.h
diff -ur linux-2.4.21-pre5.pristine/include/asm-ia64/smp.h linux-2.4.21-pre5/include/asm-ia64/smp.h
--- linux-2.4.21-pre5.pristine/include/asm-ia64/smp.h	Fri Nov  9 15:26:17 2001
+++ linux-2.4.21-pre5/include/asm-ia64/smp.h	Tue Apr  1 18:27:46 2003
@@ -45,6 +45,7 @@
 #define cpu_physical_id(i)	ia64_cpu_to_sapicid[i]
 #define cpu_number_map(i)	(i)
 #define cpu_logical_map(i)	(i)
+#define cpu_is_online(i)        test_bit(i, &cpu_online_map)
 
 extern unsigned long ap_wakeup_vector;
 
diff -ur linux-2.4.21-pre5.pristine/include/linux/smp.h linux-2.4.21-pre5/include/linux/smp.h
--- linux-2.4.21-pre5.pristine/include/linux/smp.h	Sun Mar 30 17:31:31 2003
+++ linux-2.4.21-pre5/include/linux/smp.h	Tue Apr  1 18:27:46 2003
@@ -77,6 +77,7 @@
 #define cpu_number_map(cpu)			0
 #define smp_call_function(func,info,retry,wait)	({ 0; })
 #define cpu_online_map				1
+#define cpu_is_online(i)			(i=0)	
 
 #endif
 #endif
Only in linux-2.4.21-pre5: vmlinux.gz

