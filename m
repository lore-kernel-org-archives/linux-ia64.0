From: Jes Sorensen <jes@wildopensource.com>
Date: Sun, 11 May 2003 18:33:48 +0000
Subject: [Linux-ia64] 2.5.69 process.c: cpu_idle() cleanup
Message-Id: <marc-linux-ia64-105590723705726@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi David.

Looking at the 2.5.69 cpu_idle() code and noticing that it has some SGI
specific hooks in it. However I can see other platforms having leds or
lcds or something else they want to flash or play little jingles when
the box is idle. 

As such I suggest we make these hooks that any platform can register.
Adding the extra code to the idle loop doesn't seem all that expensive
;-)

This patch goes on top of the gettimeoffset() patch I posted earlier
this afternoon.

Cheers,
Jes


diff -urN -X /home/jes/exclude-linux linux-2.5.69-030509-timer/arch/ia64/kernel/process.c linux-2.5.69-030509/arch/ia64/kernel/process.c
--- linux-2.5.69-030509-timer/arch/ia64/kernel/process.c	Sun May 11 10:53:49 2003
+++ linux-2.5.69-030509/arch/ia64/kernel/process.c	Sun May 11 13:57:54 2003
@@ -33,16 +33,16 @@
 #include <asm/unwind.h>
 #include <asm/user.h>
 
-#ifdef CONFIG_IA64_SGI_SN
-#include <asm/sn/idle.h>
-#endif
-
 #ifdef CONFIG_PERFMON
 # include <asm/perfmon.h>
 #endif
 
 #include "sigframe.h"
 
+void (*ia64_mark_idle_hook)(void);
+void (*ia64_mark_not_idle_hook)(void);
+
+
 void
 ia64_do_show_stack (struct unw_frame_info *info, void *arg)
 {
@@ -187,15 +187,13 @@
 #endif
 
 		while (!need_resched()) {
-#ifdef CONFIG_IA64_SGI_SN
-			snidle();
-#endif
+			if (ia64_mark_idle_hook)
+				ia64_mark_idle_hook();
 			(*idle)();
 		}
 
-#ifdef CONFIG_IA64_SGI_SN
-		snidleoff();
-#endif
+		if (ia64_mark_not_idle_hook)
+			ia64_mark_not_idle_hook();
 
 #ifdef CONFIG_SMP
 		normal_xtp();
diff -urN -X /home/jes/exclude-linux linux-2.5.69-030509-timer/arch/ia64/sn/kernel/idle.c linux-2.5.69-030509/arch/ia64/sn/kernel/idle.c
--- linux-2.5.69-030509-timer/arch/ia64/sn/kernel/idle.c	Wed Dec 31 19:00:00 1969
+++ linux-2.5.69-030509/arch/ia64/sn/kernel/idle.c	Sun May 11 14:17:35 2003
@@ -0,0 +1,50 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (c) 2001-2003 Silicon Graphics, Inc.  All rights reserved.
+ */
+
+#include <linux/config.h>
+#include <asm/sn/leds.h>
+#include <asm/sn/simulator.h>
+
+void snidle(void) {
+#if 0
+#ifdef CONFIG_IA64_SGI_AUTOTEST
+	{
+		extern int	autotest_enabled;
+		if (autotest_enabled) {
+			extern void llsc_main(int);
+			llsc_main(smp_processor_id());
+		}
+	}
+#endif
+	
+	if (pda.idle_flag = 0) {
+		/* 
+		 * Turn the activity LED off.
+		 */
+		set_led_bits(0, LED_CPU_ACTIVITY);
+	}
+
+#ifdef CONFIG_IA64_SGI_SN_SIM
+	if (IS_RUNNING_ON_SIMULATOR())
+		SIMULATOR_SLEEP();
+#endif
+
+	pda.idle_flag = 1;
+#endif
+}
+
+void snidleoff(void) {
+#if 0
+	/* 
+	 * Turn the activity LED on.
+	 */
+	set_led_bits(LED_CPU_ACTIVITY, LED_CPU_ACTIVITY);
+
+	pda.idle_flag = 0;
+#endif
+}
diff -urN -X /home/jes/exclude-linux linux-2.5.69-030509-timer/arch/ia64/sn/kernel/setup.c linux-2.5.69-030509/arch/ia64/sn/kernel/setup.c
--- linux-2.5.69-030509-timer/arch/ia64/sn/kernel/setup.c	Sun May 11 14:27:17 2003
+++ linux-2.5.69-030509/arch/ia64/sn/kernel/setup.c	Sun May 11 14:21:44 2003
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 1999,2001-2002 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (C) 1999,2001-2003 Silicon Graphics, Inc. All rights reserved.
  * 
  * This program is free software; you can redistribute it and/or modify it 
  * under the terms of version 2 of the GNU General Public License 
@@ -79,6 +79,10 @@
 extern void bte_init_node (nodepda_t *, cnodeid_t);
 extern void bte_init_cpu (void);
 extern void sn_timer_init (void);
+extern void (*ia64_mark_idle_hook)(void);
+extern void (*ia64_mark_not_idle_hook)(void);
+extern void snidle(void);
+extern void snidleoff(void);
 
 unsigned long sn_rtc_cycles_per_second;   
 
@@ -304,6 +308,9 @@
 	current->thread.flags |= IA64_THREAD_FPEMU_NOPRINT;
 
 	sn_timer_init();
+
+	ia64_mark_idle_hook = &snidle;
+	ia64_mark_not_idle_hook = &snidleoff;
 }
 
 /**
diff -urN -X /home/jes/exclude-linux linux-2.5.69-030509-timer/include/asm-ia64/sn/idle.h linux-2.5.69-030509/include/asm-ia64/sn/idle.h
--- linux-2.5.69-030509-timer/include/asm-ia64/sn/idle.h	Sun May  4 19:53:32 2003
+++ linux-2.5.69-030509/include/asm-ia64/sn/idle.h	Wed Dec 31 19:00:00 1969
@@ -1,57 +0,0 @@
-#ifndef _ASM_IA64_SN_IDLE_H
-#define _ASM_IA64_SN_IDLE_H
-
-/*
- * This file is subject to the terms and conditions of the GNU General Public
- * License.  See the file "COPYING" in the main directory of this archive
- * for more details.
- *
- * Copyright (c) 2001-2002 Silicon Graphics, Inc.  All rights reserved.
- */
-
-#include <linux/config.h>
-#include <asm/sn/leds.h>
-#include <asm/sn/simulator.h>
-
-static __inline__ void
-snidle(void) {
-#if 0
-#ifdef CONFIG_IA64_SGI_AUTOTEST
-	{
-		extern int	autotest_enabled;
-		if (autotest_enabled) {
-			extern void llsc_main(int);
-			llsc_main(smp_processor_id());
-		}
-	}
-#endif
-	
-	if (pda.idle_flag = 0) {
-		/* 
-		 * Turn the activity LED off.
-		 */
-		set_led_bits(0, LED_CPU_ACTIVITY);
-	}
-
-#ifdef CONFIG_IA64_SGI_SN_SIM
-	if (IS_RUNNING_ON_SIMULATOR())
-		SIMULATOR_SLEEP();
-#endif
-
-	pda.idle_flag = 1;
-#endif
-}
-
-static __inline__ void
-snidleoff(void) {
-#if 0
-	/* 
-	 * Turn the activity LED on.
-	 */
-	set_led_bits(LED_CPU_ACTIVITY, LED_CPU_ACTIVITY);
-
-	pda.idle_flag = 0;
-#endif
-}
-
-#endif /* _ASM_IA64_SN_IDLE_H */

