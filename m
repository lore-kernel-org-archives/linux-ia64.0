From: Jes Sorensen <jes@wildopensource.com>
Date: Tue, 08 Apr 2003 20:35:56 +0000
Subject: [Linux-ia64] [patch] 2.4 timer_interrupt/gettimeoffset machvec
Message-Id: <marc-linux-ia64-105590723705438@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

On systems with a drifting ITC, such as the SGI SN2, the current
implementation of timer_interrupt() and gettimeoffset() wont work as
they rely heavily on ar.itc.

On SN2 this has been solved by using the synchronized RTC in the system,
which results a different implementation of the two above mentioned
functions.

To get around this I suggest we change gettimeoffset() and
timer_intererupt() to be machvec's.

Patch against a not too old Bjorn-2.4 kernel attached. Tested on DIG.

Cheers,
Jes

diff -X /home/jes/exclude-linux -urN linux-2.4.21-pre5-030312-pretimeofday/arch/ia64/kernel/time.c linux-2.4.21-pre5-030312/arch/ia64/kernel/time.c
--- linux-2.4.21-pre5-030312-pretimeofday/arch/ia64/kernel/time.c	Thu Nov 28 18:53:09 2002
+++ linux-2.4.21-pre5-030312/arch/ia64/kernel/time.c	Fri Apr  4 18:44:21 2003
@@ -33,7 +33,7 @@
 
 #endif
 
-static void
+void
 do_profile (unsigned long ip)
 {
 	extern unsigned long prof_cpu_mask;
@@ -61,8 +61,8 @@
  * Return the number of micro-seconds that elapsed since the last update to jiffy.  The
  * xtime_lock must be at least read-locked when calling this routine.
  */
-static inline unsigned long
-gettimeoffset (void)
+unsigned long
+__ia64_gettimeoffset (void)
 {
 	unsigned long elapsed_cycles, lost = jiffies - wall_jiffies;
 	unsigned long now, last_tick;
@@ -146,8 +146,8 @@
 	tv->tv_usec = usec;
 }
 
-static void
-timer_interrupt(int irq, void *dev_id, struct pt_regs *regs)
+void
+__ia64_timer_interrupt(int irq, void *dev_id, struct pt_regs *regs)
 {
 	unsigned long new_itm;
 
@@ -284,7 +284,7 @@
 }
 
 static struct irqaction timer_irqaction = {
-	handler:	timer_interrupt,
+	handler:	NULL,
 	flags:		SA_INTERRUPT,
 	name:		"timer"
 };
@@ -292,6 +294,7 @@
 void __init
 time_init (void)
 {
+	timer_irqaction.handler = platform_timer_interrupt;
 	register_percpu_irq(IA64_TIMER_VECTOR, &timer_irqaction);
 	efi_gettimeofday((struct timeval *) &xtime);
 	ia64_init_itm();
diff -X /home/jes/exclude-linux -urN linux-2.4.21-pre5-030312-pretimeofday/arch/ia64/sn/kernel/setup.c linux-2.4.21-pre5-030312/arch/ia64/sn/kernel/setup.c
--- linux-2.4.21-pre5-030312-pretimeofday/arch/ia64/sn/kernel/setup.c	Wed Mar 12 17:24:55 2003
+++ linux-2.4.21-pre5-030312/arch/ia64/sn/kernel/setup.c	Sun Apr  6 17:52:15 2003
@@ -76,6 +76,7 @@
 
 extern void bte_init_node (nodepda_t *, cnodeid_t);
 extern void bte_init_cpu (void);
+extern void sn_timer_init (void);
 
 unsigned long sn_rtc_cycles_per_second;   
 unsigned long sn_rtc_usec_per_cyc;
@@ -313,6 +314,8 @@
 	 * Turn off "floating-point assist fault" warnings by default.
 	 */
 	current->thread.flags |= IA64_THREAD_FPEMU_NOPRINT;
+
+	sn_timer_init();
 }
 
 /**
diff -X /home/jes/exclude-linux -urN linux-2.4.21-pre5-030312-pretimeofday/arch/ia64/sn/kernel/sn2/Makefile linux-2.4.21-pre5-030312/arch/ia64/sn/kernel/sn2/Makefile
--- linux-2.4.21-pre5-030312-pretimeofday/arch/ia64/sn/kernel/sn2/Makefile	Wed Mar 12 17:24:55 2003
+++ linux-2.4.21-pre5-030312/arch/ia64/sn/kernel/sn2/Makefile	Fri Apr  4 17:25:34 2003
@@ -42,6 +42,6 @@
 
 O_TARGET        = sn2.o
 
-obj-y          = cache.o iomv.o ptc_deadlock.o sn2_smp.o sn_proc_fs.o
+obj-y          = cache.o iomv.o ptc_deadlock.o sn2_smp.o sn_proc_fs.o timer.o
 
 include $(TOPDIR)/Rules.make
diff -X /home/jes/exclude-linux -urN linux-2.4.21-pre5-030312-pretimeofday/arch/ia64/sn/kernel/sn2/timer.c linux-2.4.21-pre5-030312/arch/ia64/sn/kernel/sn2/timer.c
--- linux-2.4.21-pre5-030312-pretimeofday/arch/ia64/sn/kernel/sn2/timer.c	Wed Dec 31 19:00:00 1969
+++ linux-2.4.21-pre5-030312/arch/ia64/sn/kernel/sn2/timer.c	Sun Apr  6 19:07:50 2003
@@ -0,0 +1,176 @@
+/*
+ * linux/arch/ia64/sn/kernel/sn2/timer.c
+ *
+ * Copyright (C) 2003 Silicon Graphics, Inc.
+ * Copyright (C) 1998-2001 Hewlett-Packard Co
+ * Copyright (C) 1998-2000 Stephane Eranian <eranian@hpl.hp.com>
+ * Copyright (C) 1999-2001 David Mosberger <davidm@hpl.hp.com>
+ * Copyright (C) 1999 Don Dugger <don.dugger@intel.com>
+ * Copyright (C) 1999-2000 VA Linux Systems
+ * Copyright (C) 1999-2000 Walt Drummond <drummond@valinux.com>
+ */
+
+#include <linux/config.h>
+
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/time.h>
+#include <linux/interrupt.h>
+#include <linux/efi.h>
+
+#include <asm/delay.h>
+#include <asm/hw_irq.h>
+#include <asm/ptrace.h>
+#include <asm/sal.h>
+#include <asm/system.h>
+
+#include <asm/sn/leds.h>
+#include <asm/sn/clksupport.h>
+
+extern rwlock_t xtime_lock;
+extern void do_profile (unsigned long ip);
+
+extern unsigned long sn_rtc_cycles_per_second;
+extern unsigned long sn_rtc_usec_per_cyc;
+static unsigned long sn_rtc_per_itc;
+static unsigned long sn_rtc_delta;
+static volatile unsigned long last_rtc_val;
+
+/**
+ * gettimeoffset - number of usecs elapsed since &xtime was last updated
+ *
+ * This function is used by do_gettimeofday() to determine the number
+ * of usecs that have elapsed since the last update to &xtime.  On SN
+ * this is accomplished using the RTC built in to each Hub chip; each
+ * is guaranteed to be synchronized by the PROM, so a local read will
+ * suffice (get_cycles() does this for us).  A snapshot of the RTC value
+ * is taken on every timer interrupt and this function more or less
+ * subtracts that snapshot value from the current value.
+ *
+ * Note that if a lot of processing was done during the last timer
+ * interrupt then &xtime may be some number of jiffies out of date.
+ * This function must account for that.
+ */
+extern unsigned long wall_jiffies; /* from kernel/timer.c */
+
+unsigned long
+sn2_gettimeoffset(void)
+{
+	unsigned long elapsed_rtc_cycles, lost = jiffies - wall_jiffies;
+	unsigned long local_last_rtc_val, current_rtc_val, last_tick;
+
+	local_last_rtc_val = last_rtc_val;
+	last_tick = local_last_rtc_val -
+		(((lost + 1)* sn_rtc_delta) >> SN_RTC_PER_ITC_SHIFT);
+	current_rtc_val = get_cycles();
+	if ((long)(current_rtc_val - last_tick) < 0) {
+		/* This happens when a timer interrupt occurred on cpu 0
+		 * and our local jiffies/wall_jiffies values are out of
+		 * sync.  The frlock around this code will detect the
+		 * inconsistency and try again */
+		return 0; 
+	}
+
+	elapsed_rtc_cycles = current_rtc_val - last_tick;
+	return (elapsed_rtc_cycles * (long)sn_rtc_usec_per_cyc) >>
+		IA64_USEC_PER_CYC_SHIFT; 
+}
+
+void
+sn2_timer_interrupt(int irq, void *dev_id, struct pt_regs *regs)
+{
+	unsigned long new_itm;
+
+	if (!pda.hb_count--) {
+		pda.hb_count = HZ/2;
+		pda.hb_state ^= LED_CPU_HEARTBEAT;
+		set_led_bits(pda.hb_state, LED_CPU_HEARTBEAT);
+	}
+
+	if (pda.pio_shub_war_cam_addr)
+		*pda.pio_shub_war_cam_addr = 0x8000000000000010UL;
+
+#if 1	/* XXX - what is this? - do we really need it? - Jes */
+#define SN_LB_INT_WAR_INTERVAL 100
+	if (pda.sn_lb_int_war_ticks = 0) {
+		sn_lb_int_war_check();
+	}
+	pda.sn_lb_int_war_ticks++;
+	if (pda.sn_lb_int_war_ticks >= SN_LB_INT_WAR_INTERVAL)
+		pda.sn_lb_int_war_ticks = 0;
+#endif
+
+	new_itm = local_cpu_data->itm_next;
+
+	if (!time_after(ia64_get_itc(), new_itm))
+		printk("Oops: timer tick before it's due (itc=%lx,itm=%lx)\n",
+		       ia64_get_itc(), new_itm);
+
+	while (1) {
+		/*
+		 * Do kernel PC profiling here. We multiply the instruction
+		 * number by four so that we can use a prof_shift of 2
+		 * to get instruction-level instead of just
+		 * bundle-level accuracy.
+		 */
+		if (!user_mode(regs))
+			do_profile(regs->cr_iip + 4*ia64_psr(regs)->ri);
+
+#ifdef CONFIG_SMP
+		smp_do_timer(regs);
+#endif
+		new_itm += local_cpu_data->itm_delta;
+
+		if (smp_processor_id() = 0) {
+			long last_rtc_del;
+			/*
+			 * Here we are in the timer irq handler. We have 
+			 * irqs locally disabled, but we don't know if the
+			 * timer_bh is running on another CPU. We need to
+			 * avoid to SMP race by acquiring the xtime_lock.
+			 */
+			write_lock(&xtime_lock);
+
+	  		/* Used by gettimeoffset on 'drifty' platforms */
+			last_rtc_del = ((((long)new_itm -
+					  (long)ia64_get_itc()) *
+					 (long)sn_rtc_per_itc) >>
+					SN_RTC_PER_ITC_SHIFT);
+			last_rtc_val = (unsigned long)last_rtc_del +
+				GET_RTC_COUNTER();
+
+			do_timer(regs);
+			local_cpu_data->itm_next = new_itm;
+			write_unlock(&xtime_lock);
+		} else
+			local_cpu_data->itm_next = new_itm;
+
+		if (time_after(new_itm, ia64_get_itc()))
+			break;
+	}
+
+	do {
+		/*
+		 * If we're too close to the next clock tick for comfort, we
+		 * increase the saftey margin by intentionally dropping the
+		 * next tick(s).  We do NOT update itm.next because that 
+		 * would force us to call do_timer() which in turn would let 
+		 * our clock run too fast (with the potentially devastating 
+		 * effect of losing monotony of time).
+		 */
+		while (!time_after(new_itm, ia64_get_itc() +
+				   local_cpu_data->itm_delta/2))
+			new_itm += local_cpu_data->itm_delta;
+		ia64_set_itm(new_itm);
+		/* double check, in case we got hit by a (slow) PMI: */
+	} while (time_after_eq(ia64_get_itc(), new_itm));
+}
+
+void __init
+sn_timer_init (void)
+{
+	sn_rtc_per_itc = (sn_rtc_cycles_per_second << SN_RTC_PER_ITC_SHIFT) /
+		local_cpu_data->itc_freq;
+	sn_rtc_delta = local_cpu_data->itm_delta * sn_rtc_per_itc;
+}
diff -X /home/jes/exclude-linux -urN linux-2.4.21-pre5-030312-pretimeofday/include/asm-ia64/machvec.h linux-2.4.21-pre5-030312/include/asm-ia64/machvec.h
--- linux-2.4.21-pre5-030312-pretimeofday/include/asm-ia64/machvec.h	Sun Mar 16 10:55:27 2003
+++ linux-2.4.21-pre5-030312/include/asm-ia64/machvec.h	Fri Apr  4 19:23:31 2003
@@ -64,6 +64,8 @@
 typedef void ia64_mv_outb_t (unsigned char, unsigned long);
 typedef void ia64_mv_outw_t (unsigned short, unsigned long);
 typedef void ia64_mv_outl_t (unsigned int, unsigned long);
+typedef unsigned long ia64_mv_gettimeoffset_t (void);
+typedef void ia64_mv_timer_interrupt_t(int, void *, struct pt_regs *);
 
 extern void machvec_noop (void);
 
@@ -115,6 +117,8 @@
 #  define platform_outb		ia64_mv.outb
 #  define platform_outw		ia64_mv.outw
 #  define platform_outl		ia64_mv.outl
+#  define platform_gettimeoffset	ia64_mv.gettimeoffset
+#  define platform_timer_interrupt	ia64_mv.timer_interrupt
 # endif
 
 struct ia64_machine_vector {
@@ -151,6 +155,8 @@
 	ia64_mv_outb_t *outb;
 	ia64_mv_outw_t *outw;
 	ia64_mv_outl_t *outl;
+	ia64_mv_gettimeoffset_t *gettimeoffset;
+	ia64_mv_timer_interrupt_t *timer_interrupt;
 };
 
 #define MACHVEC_INIT(name)			\
@@ -187,7 +193,9 @@
 	platform_inl,				\
 	platform_outb,				\
 	platform_outw,				\
-	platform_outl				\
+	platform_outl,				\
+	platform_gettimeoffset,			\
+	platform_timer_interrupt		\
 }
 
 extern struct ia64_machine_vector ia64_mv;
@@ -211,6 +219,8 @@
 extern ia64_mv_pci_dma_sync_single swiotlb_sync_single;
 extern ia64_mv_pci_dma_sync_sg swiotlb_sync_sg;
 extern ia64_mv_pci_dma_supported swiotlb_pci_dma_supported;
+extern ia64_mv_gettimeoffset_t __ia64_gettimeoffset;
+extern void __ia64_timer_interrupt(int, void *, struct pt_regs *);
 
 /*
  * Define default versions so we can extend machvec for new platforms without having
@@ -309,5 +319,11 @@
 #ifndef platform_outl
 # define platform_outl		__ia64_outl
 #endif
+#ifndef platform_gettimeoffset
+# define platform_gettimeoffset	__ia64_gettimeoffset
+#endif
+#ifndef platform_timer_interrupt
+# define platform_timer_interrupt	__ia64_timer_interrupt
+#endif
 
 #endif /* _ASM_IA64_MACHVEC_H */
diff -X /home/jes/exclude-linux -urN linux-2.4.21-pre5-030312-pretimeofday/include/asm-ia64/machvec_sn2.h linux-2.4.21-pre5-030312/include/asm-ia64/machvec_sn2.h
--- linux-2.4.21-pre5-030312-pretimeofday/include/asm-ia64/machvec_sn2.h	Sun Mar 16 10:55:27 2003
+++ linux-2.4.21-pre5-030312/include/asm-ia64/machvec_sn2.h	Fri Apr  4 19:23:57 2003
@@ -59,6 +59,8 @@
 extern ia64_mv_pci_dma_sync_single	sn_pci_dma_sync_single;
 extern ia64_mv_pci_dma_sync_sg		sn_pci_dma_sync_sg;
 extern ia64_mv_pci_dma_supported	sn_pci_dma_supported;
+extern ia64_mv_gettimeoffset_t		sn_gettimeoffset;
+extern ia64_mv_timer_interrupt_t	sn_timer_interrupt;
 
 /*
  * This stuff has dual use!
@@ -95,5 +97,7 @@
 #define platform_pci_dma_sync_single	sn_pci_dma_sync_single
 #define platform_pci_dma_sync_sg	sn_pci_dma_sync_sg
 #define platform_pci_dma_supported	sn_pci_dma_supported
+#define platform_gettimeoffset		sn_gettimeoffset
+#define platform_timer_interrupt	sn_timer_interrupt
 
 #endif /* _ASM_IA64_MACHVEC_SN2_H */
diff -X /home/jes/exclude-linux -urN linux-2.4.21-pre5-030312-pretimeofday/include/asm-ia64/sn/clksupport.h linux-2.4.21-pre5-030312/include/asm-ia64/sn/clksupport.h
--- linux-2.4.21-pre5-030312-pretimeofday/include/asm-ia64/sn/clksupport.h	Wed Mar 12 17:24:59 2003
+++ linux-2.4.21-pre5-030312/include/asm-ia64/sn/clksupport.h	Sun Apr  6 18:59:05 2003
@@ -38,7 +38,7 @@
 
 extern nasid_t master_nasid;
 
-#define RTC_MASK		(0x007fffffffffffff)
+#define RTC_MASK		0x007fffffffffffffUL
 /* clocks are not synchronized yet on SN1  - used node 0 (problem if no NASID 0) */
 #define RTC_COUNTER_ADDR	((clkreg_t*)REMOTE_HUB_ADDR(master_nasid, PI_RT_COUNTER))
 #define RTC_COMPARE_A_ADDR      ((clkreg_t*)REMOTE_HUB_ADDR(master_nasid, PI_RT_COMPARE_A))
@@ -52,7 +52,7 @@
 #include <asm/sn/sn2/addrs.h>
 #include <asm/sn/sn2/shubio.h>
 #include <asm/sn/sn2/shub_mmr.h>
-#define RTC_MASK		(SH_RTC_MASK)
+#define RTC_MASK		SH_RTC_MASK
 #define RTC_COUNTER_ADDR	((clkreg_t*)LOCAL_MMR_ADDR(SH_RTC))
 #define RTC_COMPARE_A_ADDR      ((clkreg_t*)LOCAL_MMR_ADDR(SH_RTC))
 #define RTC_COMPARE_B_ADDR      ((clkreg_t*)LOCAL_MMR_ADDR(SH_RTC))
@@ -62,7 +62,7 @@
 #define RTC_INT_ENABLED_B_ADDR  ((clkreg_t*)LOCAL_MMR_ADDR(SH_RTC))
 #endif	/* CONFIG_IA64_SGI_SN1 */
 
-
+#define SN_RTC_PER_ITC_SHIFT	34
 #define GET_RTC_COUNTER()	(*RTC_COUNTER_ADDR)
 #define rtc_time()		GET_RTC_COUNTER()
 
diff -X /home/jes/exclude-linux -urN linux-2.4.21-pre5-030312-pretimeofday/include/asm-ia64/timex.h linux-2.4.21-pre5-030312/include/asm-ia64/timex.h
--- linux-2.4.21-pre5-030312-pretimeofday/include/asm-ia64/timex.h	Thu Nov 28 18:53:15 2002
+++ linux-2.4.21-pre5-030312/include/asm-ia64/timex.h	Fri Apr  4 15:07:17 2003
@@ -24,4 +24,6 @@
 #define vxtime_lock()		do {} while (0)
 #define vxtime_unlock()		do {} while (0)
 
+#define gettimeoffset()		platform_gettimeoffset()
+
 #endif /* _ASM_IA64_TIMEX_H */

