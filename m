From: Martin Hicks <mort@bork.org>
Date: Mon, 26 Jan 2004 16:16:21 +0000
Subject: Re: [PATCH] Timer interrupt extras for sn2
Message-Id: <20040126161621.GJ17306@localhost>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="jI8keyz6grp/JLjh"
List-Id: <linux-ia64.vger.kernel.org>
References: <20040123161721.GJ15871@localhost>
In-Reply-To: <20040123161721.GJ15871@localhost>
To: linux-ia64@vger.kernel.org


--jI8keyz6grp/JLjh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline



On Fri, Jan 23, 2004 at 11:17:21AM -0500, Martin Hicks wrote:
> 
> Hi David,
> 
> Here is a patch that has been floating around for a while for adding a
> a new hook inside timer_interrupt() so that platforms can execute a bit
> of their own code during the timer interrupt.

Oops.  I still had a debug printk in the last on in the sn2
timer_interrupt().

Here's a better one.

mh

-- 
Martin Hicks || mort@bork.org || PGP/GnuPG: 0x4C7F2BEE

--jI8keyz6grp/JLjh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="sn2-timer-interrupt.diff"

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1499  -> 1.1500 
#	arch/ia64/kernel/time.c	1.37    -> 1.38   
#	include/asm-ia64/machvec_sn2.h	1.9     -> 1.10   
#	include/asm-ia64/machvec.h	1.16    -> 1.17   
#	arch/ia64/sn/kernel/sn2/Makefile	1.13    -> 1.14   
#	               (new)	        -> 1.1     arch/ia64/sn/kernel/sn2/timer_interrupt.c
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/01/23	mort@green.i.bork.org	1.1500
# Add a machvec hook in the timer_interrupt so platforms
# can execute their own code during the timer_interrupt.
# --------------------------------------------
#
diff -Nru a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
--- a/arch/ia64/kernel/time.c	Fri Jan 23 10:20:12 2004
+++ b/arch/ia64/kernel/time.c	Fri Jan 23 10:20:12 2004
@@ -21,6 +21,7 @@
 #include <linux/profile.h>
 #include <linux/timex.h>
 
+#include <asm/machvec.h>
 #include <asm/delay.h>
 #include <asm/hw_irq.h>
 #include <asm/ptrace.h>
@@ -242,6 +243,8 @@
 timer_interrupt (int irq, void *dev_id, struct pt_regs *regs)
 {
 	unsigned long new_itm;
+
+	platform_timer_interrupt(irq, dev_id, regs);
 
 	new_itm = local_cpu_data->itm_next;
 
diff -Nru a/arch/ia64/sn/kernel/sn2/Makefile b/arch/ia64/sn/kernel/sn2/Makefile
--- a/arch/ia64/sn/kernel/sn2/Makefile	Fri Jan 23 10:20:12 2004
+++ b/arch/ia64/sn/kernel/sn2/Makefile	Fri Jan 23 10:20:12 2004
@@ -10,4 +10,4 @@
 #
 
 obj-y += cache.o io.o ptc_deadlock.o sn2_smp.o sn_proc_fs.o \
-	 prominfo_proc.o timer.o
+	 prominfo_proc.o timer.o timer_interrupt.o
diff -Nru a/arch/ia64/sn/kernel/sn2/timer_interrupt.c b/arch/ia64/sn/kernel/sn2/timer_interrupt.c
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/arch/ia64/sn/kernel/sn2/timer_interrupt.c	Fri Jan 23 10:20:12 2004
@@ -0,0 +1,63 @@
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
+void
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
+	if (pda->sn_lb_int_war_ticks == 0)
+		sn_lb_int_war_check();
+	pda->sn_lb_int_war_ticks++;
+	if (pda->sn_lb_int_war_ticks >= SN_LB_INT_WAR_INTERVAL)
+		pda->sn_lb_int_war_ticks = 0;
+}
diff -Nru a/include/asm-ia64/machvec.h b/include/asm-ia64/machvec.h
--- a/include/asm-ia64/machvec.h	Fri Jan 23 10:20:12 2004
+++ b/include/asm-ia64/machvec.h	Fri Jan 23 10:20:12 2004
@@ -28,6 +28,7 @@
 typedef void ia64_mv_cmci_handler_t (int, void *, struct pt_regs *);
 typedef void ia64_mv_log_print_t (void);
 typedef void ia64_mv_send_ipi_t (int, int, int, int);
+typedef void ia64_mv_timer_interrupt_t (int, void *, struct pt_regs *);
 typedef void ia64_mv_global_tlb_purge_t (unsigned long, unsigned long, unsigned long);
 typedef struct irq_desc *ia64_mv_irq_desc (unsigned int);
 typedef u8 ia64_mv_irq_to_vector (u8);
@@ -90,6 +91,7 @@
 #  define platform_cmci_handler	ia64_mv.cmci_handler
 #  define platform_log_print	ia64_mv.log_print
 #  define platform_send_ipi	ia64_mv.send_ipi
+#  define platform_timer_interrupt	ia64_mv.timer_interrupt
 #  define platform_global_tlb_purge	ia64_mv.global_tlb_purge
 #  define platform_dma_init		ia64_mv.dma_init
 #  define platform_dma_alloc_coherent	ia64_mv.dma_alloc_coherent
@@ -131,6 +133,7 @@
 	ia64_mv_cmci_handler_t *cmci_handler;
 	ia64_mv_log_print_t *log_print;
 	ia64_mv_send_ipi_t *send_ipi;
+	ia64_mv_timer_interrupt_t *timer_interrupt;
 	ia64_mv_global_tlb_purge_t *global_tlb_purge;
 	ia64_mv_dma_init *dma_init;
 	ia64_mv_dma_alloc_coherent *dma_alloc_coherent;
@@ -168,6 +171,7 @@
 	platform_cmci_handler,			\
 	platform_log_print,			\
 	platform_send_ipi,			\
+	platform_timer_interrupt,		\
 	platform_global_tlb_purge,		\
 	platform_dma_init,			\
 	platform_dma_alloc_coherent,		\
@@ -242,6 +246,9 @@
 #endif
 #ifndef platform_send_ipi
 # define platform_send_ipi	ia64_send_ipi	/* default to architected version */
+#endif
+#ifndef platform_timer_interrupt
+# define platform_timer_interrupt 	((ia64_mv_timer_interrupt_t *) machvec_noop)
 #endif
 #ifndef platform_global_tlb_purge
 # define platform_global_tlb_purge	ia64_global_tlb_purge /* default to architected version */
diff -Nru a/include/asm-ia64/machvec_sn2.h b/include/asm-ia64/machvec_sn2.h
--- a/include/asm-ia64/machvec_sn2.h	Fri Jan 23 10:20:12 2004
+++ b/include/asm-ia64/machvec_sn2.h	Fri Jan 23 10:20:12 2004
@@ -37,6 +37,7 @@
 extern ia64_mv_cpu_init_t sn_cpu_init;
 extern ia64_mv_irq_init_t sn_irq_init;
 extern ia64_mv_send_ipi_t sn2_send_IPI;
+extern ia64_mv_timer_interrupt_t sn_timer_interrupt;
 extern ia64_mv_global_tlb_purge_t sn2_global_tlb_purge;
 extern ia64_mv_irq_desc sn_irq_desc;
 extern ia64_mv_irq_to_vector sn_irq_to_vector;
@@ -73,6 +74,7 @@
 #define platform_cpu_init		sn_cpu_init
 #define platform_irq_init		sn_irq_init
 #define platform_send_ipi		sn2_send_IPI
+#define platform_timer_interrupt	sn_timer_interrupt
 #define platform_global_tlb_purge       sn2_global_tlb_purge
 #define platform_pci_fixup		sn_pci_fixup
 #define platform_inb			__sn_inb

--jI8keyz6grp/JLjh--
