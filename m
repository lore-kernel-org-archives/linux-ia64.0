From: Martin Hicks <mort@wildopensource.com>
Date: Thu, 06 Nov 2003 15:31:40 +0000
Subject: [PATCH] SN2 code for the timer interrupt
Message-Id: <marc-linux-ia64-106813294627469@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hello,

I'm reviving the discussion about how to get certain SGI-specific code
that needs to be run in the timer interrupt into the kernel.  The
original threads are here:

http://marc.theaimsgroup.com/?l=linux-ia64&r=5&b 0309&w=2

The original patches that I sent are in 126. and the responses are in
123.

The attached patch is basically the suggestion that Alex Williamson put
forward.  I created a thin wrapper around timer_interrupt for sn2 and
set the "handler" function pointer if we're running on an SN2 system.
This solution is much better than the last patch that I posted, which
used a platform hook inside timer_interrupt.

Some of the code that is being executed is actually an important bugfix
for SN2.

Opinions?

the patch is against 2.5-bk.

mh

-- 
Martin Hicks                Wild Open Source Inc.
mort@wildopensource.com     613-266-2296


# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1355  -> 1.1356 
#	arch/ia64/kernel/time.c	1.36    -> 1.37   
#	arch/ia64/sn/kernel/sn2/Makefile	1.12    -> 1.13   
#	               (new)	        -> 1.1     arch/ia64/sn/kernel/sn2/timer_interrupt.c
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/11/03	mort@green.bork.org	1.1356
# Create a thin wrapper around timer_interrupt() so sn2 can execute
# some platform specific code during the timer interrupt.
# --------------------------------------------
#
diff -Nru a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
--- a/arch/ia64/kernel/time.c	Mon Nov  3 18:37:14 2003
+++ b/arch/ia64/kernel/time.c	Mon Nov  3 18:37:14 2003
@@ -237,7 +237,7 @@
 	atomic_inc((atomic_t *)&prof_buffer[ip]);
 }
 
-static irqreturn_t
+irqreturn_t
 timer_interrupt (int irq, void *dev_id, struct pt_regs *regs)
 {
 	unsigned long new_itm;
@@ -395,6 +395,12 @@
 void __init
 time_init (void)
 {
+	/* sn2 timer_interrupt wrapper */
+	if (ia64_platform_is("sn2")) {
+		extern irqreturn_t sn_timer_interrupt(int, void *, struct pt_regs *);
+		timer_irqaction.handler = sn_timer_interrupt;
+	}
+
 	register_percpu_irq(IA64_TIMER_VECTOR, &timer_irqaction);
 	efi_gettimeofday(&xtime);
 	ia64_init_itm();
diff -Nru a/arch/ia64/sn/kernel/sn2/Makefile b/arch/ia64/sn/kernel/sn2/Makefile
--- a/arch/ia64/sn/kernel/sn2/Makefile	Mon Nov  3 18:37:14 2003
+++ b/arch/ia64/sn/kernel/sn2/Makefile	Mon Nov  3 18:37:14 2003
@@ -12,4 +12,4 @@
 EXTRA_CFLAGS := -DLITTLE_ENDIAN
 
 obj-y += cache.o io.o ptc_deadlock.o sn2_smp.o sn_proc_fs.o \
-	 prominfo_proc.o timer.o
+	 prominfo_proc.o timer.o timer_interrupt.o
diff -Nru a/arch/ia64/sn/kernel/sn2/timer_interrupt.c b/arch/ia64/sn/kernel/sn2/timer_interrupt.c
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/arch/ia64/sn/kernel/sn2/timer_interrupt.c	Mon Nov  3 18:37:14 2003
@@ -0,0 +1,65 @@
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
+#include <linux/interrupt.h>
+#include <asm/sn/pda.h>
+#include <asm/sn/leds.h>
+
+extern void sn_lb_int_war_check(void);
+extern irqreturn_t timer_interrupt (int irq, void *dev_id, struct pt_regs *regs);
+
+#define SN_LB_INT_WAR_INTERVAL 100
+
+irqreturn_t
+sn_timer_interrupt(int irq, void *dev_id, struct pt_regs *regs)
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
+	if (pda->sn_lb_int_war_ticks = 0)
+		sn_lb_int_war_check();
+	pda->sn_lb_int_war_ticks++;
+	if (pda->sn_lb_int_war_ticks >= SN_LB_INT_WAR_INTERVAL)
+		pda->sn_lb_int_war_ticks = 0;
+
+	return timer_interrupt(irq, dev_id, regs);
+}


