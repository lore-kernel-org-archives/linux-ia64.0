From: Jes Sorensen <jes@wildopensource.com>
Date: Wed, 23 Apr 2003 22:08:36 +0000
Subject: [Linux-ia64] Re: gettimeoffset() for sn2
Message-Id: <marc-linux-ia64-105590723705594@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705593@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705593@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:

>>>>> On Wed, 23 Apr 2003 12:19:25 -0400, Jes Sorensen <jes@wildopensource.com> said:
Jes> This patch is against 2.4.21-pre5-cset-1.1020, I will be working
Jes> on a 2.5.x version later today.

Jes> Unless there are strong objections, I'd love to see this applied
Jes> to the 2.4.x tree. Oh yes, I tested it on my zx1 as well.

David> One small comment: lose the " = NULL" initializers for the
David> global *time_hook variables; they only increase the data size
David> for no good reason.

Whoops, good point, thanks.

David> The bigger issue: note that do_gettimeofday() acquires a _read_
David> lock.  Thus, you need to be careful about updating rtc_offset
David> atomically.

Argh, you are right, here we go again, now I think I got it all
covered. However I think I will stop declaring victory on this one,
everytime I do so it comes back to haunt me. This version also fixed a
bug where i was scaling the RTC clock twice, not that it was lethal,
but it was still a bug.

Thanks for your comments.

Cheers,
Jes

diff -urN -X /home/jes/exclude-linux linux-2.4.21-pre5-cset-1.1020/arch/ia64/kernel/time.c linux-2.4.21-pre5-timer2/arch/ia64/kernel/time.c
--- linux-2.4.21-pre5-cset-1.1020/arch/ia64/kernel/time.c	Thu Nov 28 18:53:09 2002
+++ linux-2.4.21-pre5-timer2/arch/ia64/kernel/time.c	Wed Apr 23 11:48:58 2003
@@ -26,6 +26,9 @@
 extern rwlock_t xtime_lock;
 extern unsigned long wall_jiffies;
 extern unsigned long last_time_offset;
+static unsigned long __ia64_gettimeoffset (void);
+
+unsigned long (*gettimeoffset)(void) = &__ia64_gettimeoffset;
 
 #ifdef CONFIG_IA64_DEBUG_IRQ
 
@@ -33,6 +36,8 @@
 
 #endif
 
+#define TIME_KEEPER_ID	0	/* smp_processor_id() of time-keeper */
+
 static void
 do_profile (unsigned long ip)
 {
@@ -58,18 +63,18 @@
 }
 
 /*
- * Return the number of micro-seconds that elapsed since the last update to jiffy.  The
- * xtime_lock must be at least read-locked when calling this routine.
+ * Return the number of micro-seconds that elapsed since the last update to
+ * jiffy.  The xtime_lock must be at least read-locked when calling this
+ * routine.
  */
-static inline unsigned long
-gettimeoffset (void)
+static unsigned long
+__ia64_gettimeoffset (void)
 {
 	unsigned long elapsed_cycles, lost = jiffies - wall_jiffies;
 	unsigned long now, last_tick;
-#	define time_keeper_id	0	/* smp_processor_id() of time-keeper */
 
-	last_tick = (cpu_data(time_keeper_id)->itm_next
-		     - (lost + 1)*cpu_data(time_keeper_id)->itm_delta);
+	last_tick = (cpu_data(TIME_KEEPER_ID)->itm_next
+		     - (lost + 1)*cpu_data(TIME_KEEPER_ID)->itm_delta);
 
 	now = ia64_get_itc();
 	if ((long) (now - last_tick) < 0) {
@@ -102,6 +107,9 @@
 			tv->tv_sec--;
 		}
 
+		if (update_wall_time_hook)
+			update_wall_time_hook();
+
 		xtime = *tv;
 		time_adjust = 0;		/* stop active adjtime() */
 		time_status |= STA_UNSYNC;
@@ -171,7 +179,7 @@
 #endif
 		new_itm += local_cpu_data->itm_delta;
 
-		if (smp_processor_id() = 0) {
+		if (smp_processor_id() = TIME_KEEPER_ID) {
 			/*
 			 * Here we are in the timer irq handler. We have irqs locally
 			 * disabled, but we don't know if the timer_bh is running on
diff -urN -X /home/jes/exclude-linux linux-2.4.21-pre5-cset-1.1020/arch/ia64/sn/kernel/setup.c linux-2.4.21-pre5-timer2/arch/ia64/sn/kernel/setup.c
--- linux-2.4.21-pre5-cset-1.1020/arch/ia64/sn/kernel/setup.c	Sun Apr  6 17:14:59 2003
+++ linux-2.4.21-pre5-timer2/arch/ia64/sn/kernel/setup.c	Wed Apr 23 11:36:26 2003
@@ -78,7 +78,6 @@
 extern void bte_init_cpu (void);
 
 unsigned long sn_rtc_cycles_per_second;   
-unsigned long sn_rtc_usec_per_cyc;
 
 partid_t sn_partid = -1;
 char sn_system_serial_number_string[128];
@@ -209,6 +208,8 @@
 
 extern nasid_t master_nasid;
 
+extern void sn_timer_init(void);
+
 /**
  * sn_setup - SN platform setup routine
  * @cmdline_p: kernel command line
@@ -261,13 +262,6 @@
 	else
 		sn_rtc_cycles_per_second = ticks_per_sec;
 
-#ifdef CONFIG_IA64_SGI_SN1
-	/* PROM has wrong value on SN1 */
-	sn_rtc_cycles_per_second = 990177;
-#endif
-	sn_rtc_usec_per_cyc = ((1000000UL<<IA64_USEC_PER_CYC_SHIFT)
-			       + sn_rtc_cycles_per_second/2) / sn_rtc_cycles_per_second;
-		
 	for (i=0;i<NR_CPUS;i++)
 		_sn_irq_desc[i] = _irq_desc;
 
@@ -309,6 +303,8 @@
 #endif
 	screen_info = sn_screen_info;
 
+	sn_timer_init();
+
 	/*
 	 * Turn off "floating-point assist fault" warnings by default.
 	 */
diff -urN -X /home/jes/exclude-linux linux-2.4.21-pre5-cset-1.1020/arch/ia64/sn/kernel/sn2/Makefile linux-2.4.21-pre5-timer2/arch/ia64/sn/kernel/sn2/Makefile
--- linux-2.4.21-pre5-cset-1.1020/arch/ia64/sn/kernel/sn2/Makefile	Sun Apr  6 17:14:59 2003
+++ linux-2.4.21-pre5-timer2/arch/ia64/sn/kernel/sn2/Makefile	Wed Apr 23 11:37:01 2003
@@ -42,6 +42,7 @@
 
 O_TARGET        = sn2.o
 
-obj-y          = cache.o iomv.o ptc_deadlock.o sn2_smp.o sn_proc_fs.o
+obj-y          = cache.o iomv.o ptc_deadlock.o sn2_smp.o sn_proc_fs.o \
+		 timer.o
 
 include $(TOPDIR)/Rules.make
diff -urN -X /home/jes/exclude-linux linux-2.4.21-pre5-cset-1.1020/arch/ia64/sn/kernel/sn2/timer.c linux-2.4.21-pre5-timer2/arch/ia64/sn/kernel/sn2/timer.c
--- linux-2.4.21-pre5-cset-1.1020/arch/ia64/sn/kernel/sn2/timer.c	Wed Dec 31 19:00:00 1969
+++ linux-2.4.21-pre5-timer2/arch/ia64/sn/kernel/sn2/timer.c	Wed Apr 23 17:46:48 2003
@@ -0,0 +1,100 @@
+/*
+ * linux/arch/ia64/sn/kernel/sn2/timer.c
+ *
+ * Copyright (C) 2003 Silicon Graphics, Inc.
+ */
+
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/time.h>
+#include <linux/interrupt.h>
+
+#include <asm/hw_irq.h>
+#include <asm/system.h>
+
+#include <asm/sn/leds.h>
+#include <asm/sn/clksupport.h>
+
+
+extern unsigned long sn_rtc_cycles_per_second;
+static volatile unsigned long last_wall_rtc;
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
+ * update_wall_time_hook (sn2_update_wall_time) which means we don't
+ * have to adjust for lost jiffies ticks or anything like that.
+ */
+extern unsigned long wall_jiffies; /* from kernel/timer.c */
+
+static volatile long rtc_offset;
+static long rtc_cycles_per_usec;
+static long rtc_per_timer_tick;
+
+unsigned long
+sn_gettimeoffset(void)
+{
+	long current_rtc, elapsed_rtc, old, new_offset;
+
+	do {
+		old = rtc_offset;
+		current_rtc = GET_RTC_COUNTER();
+
+		/*
+		 * Need to address wrapping here!
+		 */
+		elapsed_rtc = (long)(current_rtc - last_wall_rtc);
+
+		/*
+		 * This case is non lethal as the max() will take care of it.
+		 */
+#if 0
+		if (elapsed_rtc < 0) {
+			printk(KERN_ERR "sn_gettimeoffset(): time goes "
+			       "backwards!\n    current_rtc 0x%016lx, "
+			       "last_wall_rtc 0x%016lx, elapsed %08lx, "
+			       "offset %li\n", current_rtc, last_wall_rtc,
+			       elapsed_rtc, max(elapsed_rtc, rtc_offset)/
+			       rtc_cycles_per_usec);
+		}
+#endif
+
+		new_offset = max(elapsed_rtc, old);
+	} while (cmpxchg(&rtc_offset, old, new_offset) != old);
+
+	return new_offset / rtc_cycles_per_usec;
+}
+
+
+void sn2_update_wall_time(void)
+{
+	rtc_offset -= min(rtc_offset, rtc_per_timer_tick);
+	last_wall_rtc = GET_RTC_COUNTER();
+}
+
+
+void sn2_reset_wall_time(void)
+{
+	rtc_offset = 0;
+	last_wall_rtc = GET_RTC_COUNTER();
+}
+
+
+void __init
+sn_timer_init(void)
+{
+	rtc_per_timer_tick = sn_rtc_cycles_per_second / HZ;
+	rtc_cycles_per_usec = sn_rtc_cycles_per_second / 1000000;
+
+	last_wall_rtc = GET_RTC_COUNTER();
+	update_wall_time_hook = sn2_update_wall_time;
+	reset_wall_time_hook = sn2_reset_wall_time;
+	gettimeoffset = sn_gettimeoffset;
+}
diff -urN -X /home/jes/exclude-linux linux-2.4.21-pre5-cset-1.1020/include/asm-ia64/sn/clksupport.h linux-2.4.21-pre5-timer2/include/asm-ia64/sn/clksupport.h
--- linux-2.4.21-pre5-cset-1.1020/include/asm-ia64/sn/clksupport.h	Sun Apr  6 17:15:02 2003
+++ linux-2.4.21-pre5-timer2/include/asm-ia64/sn/clksupport.h	Wed Apr 23 11:25:48 2003
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
diff -urN -X /home/jes/exclude-linux linux-2.4.21-pre5-cset-1.1020/include/linux/timex.h linux-2.4.21-pre5-timer2/include/linux/timex.h
--- linux-2.4.21-pre5-cset-1.1020/include/linux/timex.h	Sun Apr  6 17:37:58 2003
+++ linux-2.4.21-pre5-timer2/include/linux/timex.h	Wed Apr 23 11:25:55 2003
@@ -286,6 +286,13 @@
 extern long pps_errcnt;		/* calibration errors */
 extern long pps_stbcnt;		/* stability limit exceeded */
 
+/*
+ * Call-back for high precision timer sources to snapshot every time
+ * wall_jiffies is updated.
+ */
+extern void (*update_wall_time_hook)(void);
+extern void (*reset_wall_time_hook)(void);
+
 #endif /* KERNEL */
 
 #endif /* LINUX_TIMEX_H */
diff -urN -X /home/jes/exclude-linux linux-2.4.21-pre5-cset-1.1020/kernel/time.c linux-2.4.21-pre5-timer2/kernel/time.c
--- linux-2.4.21-pre5-cset-1.1020/kernel/time.c	Sun Apr  6 17:17:16 2003
+++ linux-2.4.21-pre5-timer2/kernel/time.c	Wed Apr 23 11:25:55 2003
@@ -82,6 +82,9 @@
 		return -EFAULT;
 	write_lock_irq(&xtime_lock);
 	vxtime_lock();
+
+	if (reset_wall_time_hook)
+		reset_wall_time_hook();
 	xtime.tv_sec = value;
 	xtime.tv_usec = 0;
 	vxtime_unlock();
diff -urN -X /home/jes/exclude-linux linux-2.4.21-pre5-cset-1.1020/kernel/timer.c linux-2.4.21-pre5-timer2/kernel/timer.c
--- linux-2.4.21-pre5-cset-1.1020/kernel/timer.c	Sun Apr  6 17:17:16 2003
+++ linux-2.4.21-pre5-timer2/kernel/timer.c	Wed Apr 23 16:13:45 2003
@@ -514,6 +514,15 @@
 }
 
 /*
+ * Hook for using external high precision timers for the system clock.
+ * On systems where the CPU clock isn't synchronized between CPUs,
+ * it is necessary to use an external source such as an RTC to obtain
+ * precision in gettimeofday().
+ */
+void (*update_wall_time_hook)(void);
+void (*reset_wall_time_hook)(void);
+
+/*
  * Using a loop looks inefficient, but "ticks" is
  * usually just one (we shouldn't be losing ticks,
  * we're doing this this way mainly for interrupt
@@ -525,12 +534,17 @@
 	do {
 		ticks--;
 		update_wall_time_one_tick();
+
+		if (update_wall_time_hook)
+			update_wall_time_hook();
 	} while (ticks);
 
 	if (xtime.tv_usec >= 1000000) {
 	    xtime.tv_usec -= 1000000;
 	    xtime.tv_sec++;
 	    second_overflow();
+	    if (update_wall_time_hook)
+		    update_wall_time_hook();
 	}
 }
 



