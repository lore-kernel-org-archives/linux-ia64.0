From: Jes Sorensen <jes@wildopensource.com>
Date: Fri, 18 Apr 2003 01:21:43 +0000
Subject: Re: [Linux-ia64] [patch] 2.4 timer_interrupt/gettimeoffset machvec
Message-Id: <marc-linux-ia64-105590723705557@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705438@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705438@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:

>>>>> On 17 Apr 2003 19:02:26 -0400, Jes Sorensen <jes@wildopensource.com> said:
Jes> Comments? If you think this is a better solution, I'll go ahead
Jes> and forward port it to 2.5 as well.

David> I thought we agreed that gettimeoffset() should just be a
David> function pointer?  Also, in 2.5, there is already a
David> "clock_was_set()" call-back (for the POSIX timers).  Perhaps
David> that should be considered.

Hi David,

I had a look at clock_was_set() and it really serves a different
purpose, which is to wake up sleeping tasks waiting for the
clock. Being called outside the xtime_lock points means that in a
preemptive kernel this would fail for us.

Anyway here is a new version of the patch, all traces of machvec's are
gone ;-) Anything else you'd like me to change?

Cheers,
Jes

diff -X /home/jes/exclude-linux -urN linux-2.4.21-pre5-cset-1.1020/arch/ia64/kernel/time.c linux-2.4.21-hack-timer/arch/ia64/kernel/time.c
--- linux-2.4.21-pre5-cset-1.1020/arch/ia64/kernel/time.c	Thu Nov 28 18:53:09 2002
+++ linux-2.4.21-hack-timer/arch/ia64/kernel/time.c	Thu Apr 17 20:23:23 2003
@@ -26,6 +26,9 @@
 extern rwlock_t xtime_lock;
 extern unsigned long wall_jiffies;
 extern unsigned long last_time_offset;
+unsigned long __ia64_gettimeoffset (void);
+
+unsigned long (*gettimeoffset)(void) = &__ia64_gettimeoffset;
 
 #ifdef CONFIG_IA64_DEBUG_IRQ
 
@@ -61,8 +64,8 @@
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
@@ -102,6 +105,9 @@
 			tv->tv_sec--;
 		}
 
+		if (update_wall_time_plug)
+			update_wall_time_plug();
+
 		xtime = *tv;
 		time_adjust = 0;		/* stop active adjtime() */
 		time_status |= STA_UNSYNC;
diff -X /home/jes/exclude-linux -urN linux-2.4.21-pre5-cset-1.1020/arch/ia64/sn/kernel/setup.c linux-2.4.21-hack-timer/arch/ia64/sn/kernel/setup.c
--- linux-2.4.21-pre5-cset-1.1020/arch/ia64/sn/kernel/setup.c	Sun Apr  6 17:14:59 2003
+++ linux-2.4.21-hack-timer/arch/ia64/sn/kernel/setup.c	Thu Apr 17 17:26:09 2003
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
@@ -510,54 +513,6 @@
 	return GET_RTC_COUNTER();
 }
 
-/**
- * gettimeoffset - number of usecs elapsed since &xtime was last updated
- *
- * This function is used by do_gettimeofday() to determine the number
- * of usecs that have elapsed since the last update to &xtime.  On SN
- * this is accomplished using the RTC built in to each Hub chip; each
- * is guaranteed to be synchronized by the PROM, so a local read will
- * suffice (get_cycles() does this for us).  A snapshot of the RTC value
- * is taken on every timer interrupt and this function more or less
- * subtracts that snapshot value from the current value.
- *
- * Note that if a lot of processing was done during the last timer
- * interrupt then &xtime may be some number of jiffies out of date.
- * This function must account for that.
- */
-unsigned long
-gettimeoffset(void)
-{
-	unsigned long current_rtc_val, local_last_rtc_val;
-	unsigned long usec;
-
-	local_last_rtc_val = last_rtc_val;
-	current_rtc_val = get_cycles();
-	usec = last_itc_lost_usec;
-
-	/* If the RTC has wrapped around, compensate */
-	if (unlikely(current_rtc_val < local_last_rtc_val)) {
-		printk(KERN_NOTICE "RTC wrapped cpu:%d current:0x%lx last:0x%lx\n",
-				smp_processor_id(), current_rtc_val,
-				local_last_rtc_val);
-		current_rtc_val += RTC_MASK;
-	}
-
-	usec += ((current_rtc_val - local_last_rtc_val)*sn_rtc_usec_per_cyc) >> 
-		IA64_USEC_PER_CYC_SHIFT;
-
-	/*
-	 * usec is the number of microseconds into the current clock interval. Every
-	 * clock tick, xtime is advanced by "tick" microseconds. If "usec"
-	 * is allowed to get larger than "tick", the time value returned by gettimeofday
-	 * will go backward.
-	 */
-	if (usec >= tick)
-		usec = tick-1;
-
-	return usec;
-}
-
 #ifdef II_PRTE_TLB_WAR
 long iiprt_lock[16*64] __cacheline_aligned; /* allow for NASIDs up to 64 */
 #endif
diff -X /home/jes/exclude-linux -urN linux-2.4.21-pre5-cset-1.1020/arch/ia64/sn/kernel/sn2/Makefile linux-2.4.21-hack-timer/arch/ia64/sn/kernel/sn2/Makefile
--- linux-2.4.21-pre5-cset-1.1020/arch/ia64/sn/kernel/sn2/Makefile	Sun Apr  6 17:14:59 2003
+++ linux-2.4.21-hack-timer/arch/ia64/sn/kernel/sn2/Makefile	Tue Apr 15 19:37:40 2003
@@ -42,6 +42,6 @@
 
 O_TARGET        = sn2.o
 
-obj-y          = cache.o iomv.o ptc_deadlock.o sn2_smp.o sn_proc_fs.o
+obj-y          = cache.o iomv.o ptc_deadlock.o sn2_smp.o sn_proc_fs.o timer.o
 
 include $(TOPDIR)/Rules.make
diff -X /home/jes/exclude-linux -urN linux-2.4.21-pre5-cset-1.1020/arch/ia64/sn/kernel/sn2/timer.c linux-2.4.21-hack-timer/arch/ia64/sn/kernel/sn2/timer.c
--- linux-2.4.21-pre5-cset-1.1020/arch/ia64/sn/kernel/sn2/timer.c	Wed Dec 31 19:00:00 1969
+++ linux-2.4.21-hack-timer/arch/ia64/sn/kernel/sn2/timer.c	Thu Apr 17 20:49:15 2003
@@ -0,0 +1,85 @@
+/*
+ * linux/arch/ia64/sn/kernel/sn2/timer.c
+ *
+ * Copyright (C) 2003 Silicon Graphics, Inc.
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
+ * suffice (GET_RTC_COUNTER() does this for us).  A snapshot of the RTC
+ * value is taken every time wall_jiffies is updated by the
+ * update_wall_time_plug (sn2_update_wall_time) which means we don't
+ * have to adjust for lost jiffies ticks or anything like that.
+ */
+unsigned long
+sn_gettimeoffset(void)
+{
+	unsigned long current_rtc;
+	long elapsed_rtc;
+
+	current_rtc = GET_RTC_COUNTER();
+
+	/*
+	 * Need to address wrapping here!
+	 */
+	elapsed_rtc = (long)(current_rtc - last_wall_rtc);
+
+	if (elapsed_rtc < 0) {
+		printk(KERN_INFO "sn_gettimeoffset(): time goes backwards! "
+		       "current_rtc 0x%016lx, last_wall_rtc 0x%016lx\n",
+		       current_rtc, last_wall_rtc);
+	}
+
+	return (elapsed_rtc * (long)sn_rtc_usec_per_cyc) >>
+		IA64_USEC_PER_CYC_SHIFT; 
+}
+
+
+void sn2_update_wall_time()
+{
+	last_wall_rtc = GET_RTC();
+}
+
+
+void __init
+sn_timer_init (void)
+{
+	sn_rtc_per_itc = (sn_rtc_cycles_per_second << SN_RTC_PER_ITC_SHIFT) /
+		local_cpu_data->itc_freq;
+	sn_rtc_delta = local_cpu_data->itm_delta * sn_rtc_per_itc;
+
+	last_wall_rtc = GET_RTC_COUNTER();
+	update_wall_time_plug = sn2_update_wall_time;
+	gettimeoffset = sn_gettimeoffset;
+}
diff -X /home/jes/exclude-linux -urN linux-2.4.21-pre5-cset-1.1020/include/asm-ia64/sn/clksupport.h linux-2.4.21-hack-timer/include/asm-ia64/sn/clksupport.h
--- linux-2.4.21-pre5-cset-1.1020/include/asm-ia64/sn/clksupport.h	Sun Apr  6 17:15:02 2003
+++ linux-2.4.21-hack-timer/include/asm-ia64/sn/clksupport.h	Tue Apr 15 19:37:40 2003
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
 
diff -X /home/jes/exclude-linux -urN linux-2.4.21-pre5-cset-1.1020/include/asm-ia64/timex.h linux-2.4.21-hack-timer/include/asm-ia64/timex.h
--- linux-2.4.21-pre5-cset-1.1020/include/asm-ia64/timex.h	Thu Nov 28 18:53:15 2002
+++ linux-2.4.21-hack-timer/include/asm-ia64/timex.h	Thu Apr 17 20:37:04 2003
@@ -24,4 +24,6 @@
 #define vxtime_lock()		do {} while (0)
 #define vxtime_unlock()		do {} while (0)
 
+extern unsigned long (*gettimeoffset)(void);
+
 #endif /* _ASM_IA64_TIMEX_H */
diff -X /home/jes/exclude-linux -urN linux-2.4.21-pre5-cset-1.1020/include/linux/timex.h linux-2.4.21-hack-timer/include/linux/timex.h
--- linux-2.4.21-pre5-cset-1.1020/include/linux/timex.h	Sun Apr  6 17:37:58 2003
+++ linux-2.4.21-hack-timer/include/linux/timex.h	Thu Apr 17 20:37:09 2003
@@ -286,6 +286,12 @@
 extern long pps_errcnt;		/* calibration errors */
 extern long pps_stbcnt;		/* stability limit exceeded */
 
+/*
+ * Call-back for high precision timer sources to snapshot every time
+ * wall_jiffies is updated.
+ */
+extern void (*update_wall_time_plug)(void);
+
 #endif /* KERNEL */
 
 #endif /* LINUX_TIMEX_H */
diff -X /home/jes/exclude-linux -urN linux-2.4.21-pre5-cset-1.1020/kernel/timer.c linux-2.4.21-hack-timer/kernel/timer.c
--- linux-2.4.21-pre5-cset-1.1020/kernel/timer.c	Sun Apr  6 17:17:16 2003
+++ linux-2.4.21-hack-timer/kernel/timer.c	Tue Apr 15 19:28:54 2003
@@ -514,6 +514,14 @@
 }
 
 /*
+ * Hook for using external high precision timers for the system clock.
+ * On systems where the CPU clock isn't synchronized between CPUs,
+ * it is necessary to use an external source such as an RTC to obtain
+ * precision in gettimeofday().
+ */
+void (*update_wall_time_plug)(void) = NULL;
+
+/*
  * Using a loop looks inefficient, but "ticks" is
  * usually just one (we shouldn't be losing ticks,
  * we're doing this this way mainly for interrupt
@@ -522,6 +530,9 @@
  */
 static void update_wall_time(unsigned long ticks)
 {
+	if (update_wall_time_plug)
+		update_wall_time_plug();
+
 	do {
 		ticks--;
 		update_wall_time_one_tick();

