From: Martin Hicks <mort@wildopensource.com>
Date: Wed, 03 Sep 2003 16:42:29 +0000
Subject: [patch] platform hook for timer_interrupt()
MIME-Version: 1
Content-Type: multipart/mixed; boundary="tsOsTdHNUZQcU9Ye"
Message-Id: <marc-linux-ia64-106260860913129@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--tsOsTdHNUZQcU9Ye
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


Hello,

SGI has a need to run platform specific code during the timer interrupt.
Attached are patches for both 2.4 and 2.6 that add a hook inside the
timer interrupt that will run platform specific code if required.

Any opinions on this?
mh

-- 
Wild Open Source Inc.                  mort@wildopensource.com

--tsOsTdHNUZQcU9Ye
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="timer-interrupt-hook-2.4bk-2.diff"

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1082  -> 1.1083 
#	arch/ia64/kernel/time.c	1.8     -> 1.9    
#	arch/ia64/sn/kernel/setup.c	1.9     -> 1.10   
#	arch/ia64/sn/kernel/sn2/Makefile	1.4     -> 1.5    
#	               (new)	        -> 1.1     arch/ia64/sn/kernel/sn2/timer_interrupt.c
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/08/29	mort@tomahawk.engr.sgi.com	1.1083
# Add a hook so that ia64-platform specific code can be run from within timer_interrupt()
# --------------------------------------------
#
diff -Nru a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
--- a/arch/ia64/kernel/time.c	Fri Aug 29 08:39:28 2003
+++ b/arch/ia64/kernel/time.c	Fri Aug 29 08:39:28 2003
@@ -27,6 +27,8 @@
 extern unsigned long wall_jiffies;
 extern unsigned long last_time_offset;
 
+void (*ia64_platform_timer_extras)(void);
+
 #ifdef CONFIG_IA64_DEBUG_IRQ
 
 unsigned long last_cli_ip;
@@ -148,6 +150,9 @@
 timer_interrupt(int irq, void *dev_id, struct pt_regs *regs)
 {
 	unsigned long new_itm;
+
+	if (ia64_platform_timer_extras)
+	     (*ia64_platform_timer_extras)();
 
 	new_itm = local_cpu_data->itm_next;
 
diff -Nru a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
--- a/arch/ia64/sn/kernel/setup.c	Fri Aug 29 08:39:28 2003
+++ b/arch/ia64/sn/kernel/setup.c	Fri Aug 29 08:39:28 2003
@@ -80,6 +80,8 @@
 extern void sn_timer_init(void);
 extern unsigned long last_time_offset;
 extern void (*ia64_mark_idle)(int);
+extern void (*ia64_platform_timer_extras)(void);
+extern void sn_timer_interrupt_extras(void);
 extern void snidle(int);
 
 unsigned long sn_rtc_cycles_per_second;   
@@ -315,6 +317,8 @@
 	init_smp_config();
 #endif
 	screen_info = sn_screen_info;
+
+	ia64_platform_timer_extras = &sn_timer_interrupt_extras;
 
 	sn_timer_init();
 }
diff -Nru a/arch/ia64/sn/kernel/sn2/Makefile b/arch/ia64/sn/kernel/sn2/Makefile
--- a/arch/ia64/sn/kernel/sn2/Makefile	Fri Aug 29 08:39:28 2003
+++ b/arch/ia64/sn/kernel/sn2/Makefile	Fri Aug 29 08:39:28 2003
@@ -44,6 +44,6 @@
 export-objs	:= io.o
 
 obj-y		= cache.o io.o ptc_deadlock.o sn2_smp.o sn_proc_fs.o \
-		  prominfo_proc.o timer.o
+		  prominfo_proc.o timer.o timer_interrupt.o
 
 include $(TOPDIR)/Rules.make
diff -Nru a/arch/ia64/sn/kernel/sn2/timer_interrupt.c b/arch/ia64/sn/kernel/sn2/timer_interrupt.c
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/arch/ia64/sn/kernel/sn2/timer_interrupt.c	Fri Aug 29 08:39:28 2003
@@ -0,0 +1,60 @@
+/*
+ *
+ *
+ * Copyright (c) 2003 Silicon Graphics, Inc.  All Rights Reserved.
+ * 
+ * This program is free software; you can redistribute it and/or modify it 
+ * under the terms of version 2 of the GNU General Public License 
+ * as published by the Free Software Foundation.
+ * 
+ * This program is distributed in the hope that it would be useful, but 
+ * WITHOUT ANY WARRANTY; without even the implied warranty of 
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
+ * 
+ * Further, this software is distributed without any warranty that it is 
+ * free of the rightful claim of any third person regarding infringement 
+ * or the like.  Any license provided herein, whether implied or 
+ * otherwise, applies only to this software file.  Patent licenses, if 
+ * any, provided herein do not apply to combinations of this program with 
+ * other software, or any other product whatsoever.
+ * 
+ * You should have received a copy of the GNU General Public 
+ * License along with this program; if not, write the Free Software 
+ * Foundation, Inc., 59 Temple Place - Suite 330, Boston MA 02111-1307, USA.
+ * 
+ * Contact information:  Silicon Graphics, Inc., 1600 Amphitheatre Pkwy, 
+ * Mountain View, CA  94043, or:
+ * 
+ * http://www.sgi.com 
+ * 
+ * For further information regarding this notice, see: 
+ * 
+ * http://oss.sgi.com/projects/GenInfo/NoticeExplan
+ */
+
+#include <asm/sn/pda.h>
+#include <asm/sn/leds.h>
+
+extern void sn_lb_int_war_check(void);
+#define SN_LB_INT_WAR_INTERVAL 100
+
+void
+sn_timer_interrupt_extras(void)
+{
+	/* LED blinking */
+	if (!pda.hb_count--) {
+		pda.hb_count = HZ/2;
+		set_led_bits(pda.hb_state ^= LED_CPU_HEARTBEAT, LED_CPU_HEARTBEAT);
+	}
+
+	if (enable_shub_wars_1_1()) {
+		/* Bugfix code for SHUB 1.1 */
+        	if (pda.pio_shub_war_cam_addr)
+                	*pda.pio_shub_war_cam_addr = 0x8000000000000010UL;
+	}
+	if (pda.sn_lb_int_war_ticks == 0)
+		sn_lb_int_war_check();
+	pda.sn_lb_int_war_ticks++;
+	if (pda.sn_lb_int_war_ticks >= SN_LB_INT_WAR_INTERVAL)
+		pda.sn_lb_int_war_ticks = 0;
+}

--tsOsTdHNUZQcU9Ye
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="timer-interrupt-hook-2.5bk.diff"

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1298  -> 1.1299 
#	arch/ia64/kernel/time.c	1.31    -> 1.32   
#	arch/ia64/sn/kernel/setup.c	1.18    -> 1.19   
#	arch/ia64/sn/kernel/sn2/Makefile	1.12    -> 1.13   
#	               (new)	        -> 1.1     arch/ia64/sn/kernel/sn2/timer_interrupt.c
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/08/29	mort@tomahawk.engr.sgi.com	1.1299
# Add a hook so that ia64-platform specific code can be run from within timer_interrupt()
# --------------------------------------------
#
diff -Nru a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
--- a/arch/ia64/kernel/time.c	Fri Aug 29 08:28:10 2003
+++ b/arch/ia64/kernel/time.c	Fri Aug 29 08:28:10 2003
@@ -32,6 +32,8 @@
 
 #define TIME_KEEPER_ID	0	/* smp_processor_id() of time-keeper */
 
+void (*ia64_platform_timer_extras)(void);
+
 #ifdef CONFIG_IA64_DEBUG_IRQ
 
 unsigned long last_cli_ip;
@@ -203,6 +205,9 @@
 timer_interrupt (int irq, void *dev_id, struct pt_regs *regs)
 {
 	unsigned long new_itm;
+
+	if (ia64_platform_timer_extras)
+	     (*ia64_platform_timer_extras)();
 
 	new_itm = local_cpu_data->itm_next;
 
diff -Nru a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
--- a/arch/ia64/sn/kernel/setup.c	Fri Aug 29 08:28:10 2003
+++ b/arch/ia64/sn/kernel/setup.c	Fri Aug 29 08:28:10 2003
@@ -83,6 +83,9 @@
 extern void sn_timer_init(void);
 extern unsigned long last_time_offset;
 extern void (*ia64_mark_idle)(int);
+extern void (*ia64_platform_timer_extras)(void);
+extern void sn_timer_interrupt_extras(void);
 extern void snidle(int);
 
 unsigned long sn_rtc_cycles_per_second;   
@@ -318,6 +321,8 @@
 	init_smp_config();
 #endif
 	screen_info = sn_screen_info;
+
+	ia64_platform_timer_extras = &sn_timer_interrupt_extras;
 
 	sn_timer_init();
 }
diff -Nru a/arch/ia64/sn/kernel/sn2/Makefile b/arch/ia64/sn/kernel/sn2/Makefile
--- a/arch/ia64/sn/kernel/sn2/Makefile	Fri Aug 29 08:28:10 2003
+++ b/arch/ia64/sn/kernel/sn2/Makefile	Fri Aug 29 08:28:10 2003
@@ -12,4 +12,4 @@
 EXTRA_CFLAGS := -DLITTLE_ENDIAN
 
 obj-y += cache.o io.o ptc_deadlock.o sn2_smp.o sn_proc_fs.o \
-	 prominfo_proc.o timer.o
+	 prominfo_proc.o timer.o timer_interrupt.o
diff -Nru a/arch/ia64/sn/kernel/sn2/timer_interrupt.c b/arch/ia64/sn/kernel/sn2/timer_interrupt.c
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/arch/ia64/sn/kernel/sn2/timer_interrupt.c	Fri Aug 29 08:28:10 2003
@@ -0,0 +1,60 @@
+/*
+ *
+ *
+ * Copyright (c) 2003 Silicon Graphics, Inc.  All Rights Reserved.
+ * 
+ * This program is free software; you can redistribute it and/or modify it 
+ * under the terms of version 2 of the GNU General Public License 
+ * as published by the Free Software Foundation.
+ * 
+ * This program is distributed in the hope that it would be useful, but 
+ * WITHOUT ANY WARRANTY; without even the implied warranty of 
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
+ * 
+ * Further, this software is distributed without any warranty that it is 
+ * free of the rightful claim of any third person regarding infringement 
+ * or the like.  Any license provided herein, whether implied or 
+ * otherwise, applies only to this software file.  Patent licenses, if 
+ * any, provided herein do not apply to combinations of this program with 
+ * other software, or any other product whatsoever.
+ * 
+ * You should have received a copy of the GNU General Public 
+ * License along with this program; if not, write the Free Software 
+ * Foundation, Inc., 59 Temple Place - Suite 330, Boston MA 02111-1307, USA.
+ * 
+ * Contact information:  Silicon Graphics, Inc., 1600 Amphitheatre Pkwy, 
+ * Mountain View, CA  94043, or:
+ * 
+ * http://www.sgi.com 
+ * 
+ * For further information regarding this notice, see: 
+ * 
+ * http://oss.sgi.com/projects/GenInfo/NoticeExplan
+ */
+
+#include <asm/sn/pda.h>
+#include <asm/sn/leds.h>
+
+extern void sn_lb_int_war_check(void);
+#define SN_LB_INT_WAR_INTERVAL 100
+
+void
+sn_timer_interrupt_extras(void)
+{
+	/* LED blinking */
+	if (!pda->hb_count--) {
+		pda->hb_count = HZ/2;
+		set_led_bits(pda->hb_state ^= LED_CPU_HEARTBEAT, LED_CPU_HEARTBEAT);
+	}
+
+	if (enable_shub_wars_1_1()) {
+		/* Bugfix code for SHUB 1.1 */
+        	if (pda->pio_shub_war_cam_addr)
+                	*pda->pio_shub_war_cam_addr = 0x8000000000000010UL;
+	}
+	if (pda->sn_lb_int_war_ticks == 0)
+		sn_lb_int_war_check();
+	pda->sn_lb_int_war_ticks++;
+	if (pda->sn_lb_int_war_ticks >= SN_LB_INT_WAR_INTERVAL)
+		pda->sn_lb_int_war_ticks = 0;
+}

--tsOsTdHNUZQcU9Ye--
