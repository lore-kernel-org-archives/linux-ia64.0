From: Jes Sorensen <jes@wildopensource.com>
Date: Sun, 11 May 2003 17:54:29 +0000
Subject: Re: [Linux-ia64] gettimeoffset for 2.5.67
Message-Id: <marc-linux-ia64-105590723705724@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705684@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705684@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:

>>>>> On Thu, 8 May 2003 12:44:47 -0400, Jes Sorensen <jes@wildopensource.com> said:
Jes> Patch is relative to David's 2.5.67 0416 release.

David> The patch looks largely fine to me.  It's missing an update to
David> fsys_gettimeofday() though.  In that routine, you need to check
David> whether the ITC_DRIFT flag is on and, if so, fall back on doing
David> the heavy-weight syscall.

Hi David,

Here is the updated version relative to you 2.5.69 patch.
CLOCK_MONOTONIC didn't cause any problems to the patch btw.

I have added the check to fsys.S so for now we will stick to the slow
version for SN2, but I may look into fixing it to use the fast
syscalls for that at a later point. But lets get the kernel booting
first ... details, details ;-)

Tested on my zx1 and doesn't seem to cause any problems there.

Cheers,
Jes

diff -urN -X /home/jes/exclude-linux linux-2.5.69-030509-vanilla/arch/ia64/kernel/fsys.S linux-2.5.69-030509/arch/ia64/kernel/fsys.S
--- linux-2.5.69-030509-vanilla/arch/ia64/kernel/fsys.S	Sun May  4 19:52:48 2003
+++ linux-2.5.69-030509/arch/ia64/kernel/fsys.S	Sun May 11 13:19:24 2003
@@ -142,21 +142,31 @@
  *	   we ought to either skip the ITC-based interpolation or run an ntp-like
  *	   daemon to keep the ITCs from drifting too far apart.
  */
+
+#define IA64_SAL_PLATFORM_FEATURE_ITC_DRIFT	 	(1 << 3)
+
 ENTRY(fsys_gettimeofday)
 	add r9=TI_FLAGS+IA64_TASK_SIZE,r16
 	movl r3=THIS_CPU(cpu_info)
 
 	mov.m r31=ar.itc		// put time stamp into r31 (ITC) = now		(35 cyc)
 	movl r19=xtime			// xtime is a timespec struct
+#ifdef CONFIG_SMP
+	movl r2=sal_platform_features
+#endif
 	;;
 
 #ifdef CONFIG_SMP
+	ld8 r2=[r2]
 	movl r10=__per_cpu_offset
 	;;
 	ld8 r10=[r10]			// r10 <- __per_cpu_offset[0]
 	movl r21=cpu_info__per_cpu
+	and r2=IA64_SAL_PLATFORM_FEATURE_ITC_DRIFT,r2
 	;;
 	add r10=r21, r10		// r10 <- &cpu_data(time_keeper_id)
+	cmp.ne p8, p0=0, r2
+(p8)	br.spnt.many fsys_fallback_syscall
 #else
 	mov r10=r3
 #endif
diff -urN -X /home/jes/exclude-linux linux-2.5.69-030509-vanilla/arch/ia64/kernel/time.c linux-2.5.69-030509/arch/ia64/kernel/time.c
--- linux-2.5.69-030509-vanilla/arch/ia64/kernel/time.c	Sun May 11 10:53:49 2003
+++ linux-2.5.69-030509/arch/ia64/kernel/time.c	Sun May 11 11:20:35 2003
@@ -17,6 +17,7 @@
 #include <linux/time.h>
 #include <linux/interrupt.h>
 #include <linux/efi.h>
+#include <linux/timex.h>
 
 #include <asm/delay.h>
 #include <asm/hw_irq.h>
@@ -26,9 +27,14 @@
 
 extern unsigned long wall_jiffies;
 extern unsigned long last_nsec_offset;
+static unsigned long __ia64_gettimeoffset (void);
+
+unsigned long (*gettimeoffset)(void) = &__ia64_gettimeoffset;
 
 u64 jiffies_64 = INITIAL_JIFFIES;
 
+#define TIME_KEEPER_ID	0	/* smp_processor_id() of time-keeper */
+
 #ifdef CONFIG_IA64_DEBUG_IRQ
 
 unsigned long last_cli_ip;
@@ -63,15 +69,14 @@
  * Return the number of nano-seconds that elapsed since the last update to jiffy.  The
  * xtime_lock must be at least read-locked when calling this routine.
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
 	if (unlikely((long) (now - last_tick) < 0)) {
@@ -124,6 +129,9 @@
 		time_status |= STA_UNSYNC;
 		time_maxerror = NTP_PHASE_LIMIT;
 		time_esterror = NTP_PHASE_LIMIT;
+		if (update_wall_time_hook)
+			update_wall_time_hook();
+
 	}
 	write_sequnlock_irq(&xtime_lock);
 	clock_was_set();
@@ -214,7 +222,7 @@
 #endif
 		new_itm += local_cpu_data->itm_delta;
 
-		if (smp_processor_id() = 0) {
+		if (smp_processor_id() = TIME_KEEPER_ID) {
 			/*
 			 * Here we are in the timer irq handler. We have irqs locally
 			 * disabled, but we don't know if the timer_bh is running on
diff -urN -X /home/jes/exclude-linux linux-2.5.69-030509-vanilla/arch/ia64/sn/kernel/setup.c linux-2.5.69-030509/arch/ia64/sn/kernel/setup.c
--- linux-2.5.69-030509-vanilla/arch/ia64/sn/kernel/setup.c	Sun May  4 19:53:08 2003
+++ linux-2.5.69-030509/arch/ia64/sn/kernel/setup.c	Sun May 11 11:20:35 2003
@@ -78,9 +78,9 @@
 
 extern void bte_init_node (nodepda_t *, cnodeid_t);
 extern void bte_init_cpu (void);
+extern void sn_timer_init (void);
 
 unsigned long sn_rtc_cycles_per_second;   
-unsigned long sn_rtc_usec_per_cyc;
 
 partid_t sn_partid = -1;
 char sn_system_serial_number_string[128];
@@ -263,13 +263,6 @@
 	else
 		sn_rtc_cycles_per_second = ticks_per_sec;
 
-#ifdef CONFIG_IA64_SGI_SN1
-	/* PROM has wrong value on SN1 */
-	sn_rtc_cycles_per_second = 990177;
-#endif
-	sn_rtc_usec_per_cyc = ((1000000000UL<<IA64_NSEC_PER_CYC_SHIFT)
-			       + sn_rtc_cycles_per_second/2) / sn_rtc_cycles_per_second;
-		
 	for (i=0;i<NR_CPUS;i++)
 		_sn_irq_desc[i] = _irq_desc;
 
@@ -309,6 +302,8 @@
 	 * Turn off "floating-point assist fault" warnings by default.
 	 */
 	current->thread.flags |= IA64_THREAD_FPEMU_NOPRINT;
+
+	sn_timer_init();
 }
 
 /**
diff -urN -X /home/jes/exclude-linux linux-2.5.69-030509-vanilla/arch/ia64/sn/kernel/sn2/Makefile linux-2.5.69-030509/arch/ia64/sn/kernel/sn2/Makefile
--- linux-2.5.69-030509-vanilla/arch/ia64/sn/kernel/sn2/Makefile	Sun May  4 19:53:56 2003
+++ linux-2.5.69-030509/arch/ia64/sn/kernel/sn2/Makefile	Sun May 11 11:20:35 2003
@@ -11,4 +11,4 @@
 
 EXTRA_CFLAGS := -DLITTLE_ENDIAN
 
-obj-y += cache.o iomv.o ptc_deadlock.o sn2_smp.o sn_proc_fs.o
+obj-y += cache.o iomv.o ptc_deadlock.o sn2_smp.o sn_proc_fs.o timer.o
diff -urN -X /home/jes/exclude-linux linux-2.5.69-030509-vanilla/arch/ia64/sn/kernel/sn2/timer.c linux-2.5.69-030509/arch/ia64/sn/kernel/sn2/timer.c
--- linux-2.5.69-030509-vanilla/arch/ia64/sn/kernel/sn2/timer.c	Wed Dec 31 19:00:00 1969
+++ linux-2.5.69-030509/arch/ia64/sn/kernel/sn2/timer.c	Sun May 11 11:20:35 2003
@@ -0,0 +1,85 @@
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
+ * gettimeoffset - number of nsecs elapsed since &xtime was last updated
+ *
+ * This function is used by do_gettimeofday() to determine the number
+ * of nsecs that have elapsed since the last update to &xtime.  On SN
+ * this is accomplished using the RTC built in to each Hub chip; each
+ * is guaranteed to be synchronized by the PROM, so a local read will
+ * suffice (GET_RTC_COUNTER() does this for us).  A snapshot of the RTC
+ * value is taken every time wall_jiffies is updated by the
+ * update_wall_time_hook (sn2_update_wall_time) which means we don't
+ * have to adjust for lost jiffies ticks or anything like that.
+ */
+
+static volatile long rtc_offset;
+static long rtc_nsecs_per_cycle;
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
+		new_offset = max(elapsed_rtc, old);
+	} while (cmpxchg(&rtc_offset, old, new_offset) != old);
+
+	return new_offset * rtc_nsecs_per_cycle;
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
+	rtc_nsecs_per_cycle = 1000000000 / sn_rtc_cycles_per_second;
+
+	last_wall_rtc = GET_RTC_COUNTER();
+	update_wall_time_hook = sn2_update_wall_time;
+	reset_wall_time_hook = sn2_reset_wall_time;
+	gettimeoffset = sn_gettimeoffset;
+}
diff -urN -X /home/jes/exclude-linux linux-2.5.69-030509-vanilla/include/asm-ia64/sn/clksupport.h linux-2.5.69-030509/include/asm-ia64/sn/clksupport.h
--- linux-2.5.69-030509-vanilla/include/asm-ia64/sn/clksupport.h	Sun May  4 19:53:35 2003
+++ linux-2.5.69-030509/include/asm-ia64/sn/clksupport.h	Sun May 11 11:20:35 2003
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
@@ -62,7 +62,6 @@
 #define RTC_INT_ENABLED_B_ADDR  ((clkreg_t*)LOCAL_MMR_ADDR(SH_RTC))
 #endif	/* CONFIG_IA64_SGI_SN1 */
 
-
 #define GET_RTC_COUNTER()	(*RTC_COUNTER_ADDR)
 #define rtc_time()		GET_RTC_COUNTER()
 
diff -urN -X /home/jes/exclude-linux linux-2.5.69-030509-vanilla/include/asm-ia64/timex.h linux-2.5.69-030509/include/asm-ia64/timex.h
--- linux-2.5.69-030509-vanilla/include/asm-ia64/timex.h	Sun May  4 19:53:40 2003
+++ linux-2.5.69-030509/include/asm-ia64/timex.h	Sun May 11 11:20:35 2003
@@ -25,4 +25,6 @@
 	return ret;
 }
 
+extern unsigned long (*gettimeoffset)(void);
+
 #endif /* _ASM_IA64_TIMEX_H */
diff -urN -X /home/jes/exclude-linux linux-2.5.69-030509-vanilla/include/linux/timex.h linux-2.5.69-030509/include/linux/timex.h
--- linux-2.5.69-030509-vanilla/include/linux/timex.h	Sun May  4 19:52:59 2003
+++ linux-2.5.69-030509/include/linux/timex.h	Sun May 11 11:20:35 2003
@@ -310,6 +310,13 @@
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
diff -urN -X /home/jes/exclude-linux linux-2.5.69-030509-vanilla/kernel/time.c linux-2.5.69-030509/kernel/time.c
--- linux-2.5.69-030509-vanilla/kernel/time.c	Sun May 11 10:53:49 2003
+++ linux-2.5.69-030509/kernel/time.c	Sun May 11 11:20:35 2003
@@ -77,6 +77,9 @@
 	if (get_user(value, tptr))
 		return -EFAULT;
 	write_seqlock_irq(&xtime_lock);
+
+	if (reset_wall_time_hook)
+		reset_wall_time_hook();
 	xtime.tv_sec = value;
 	xtime.tv_nsec = 0;
 	last_nsec_offset = 0;
diff -urN -X /home/jes/exclude-linux linux-2.5.69-030509-vanilla/kernel/timer.c linux-2.5.69-030509/kernel/timer.c
--- linux-2.5.69-030509-vanilla/kernel/timer.c	Sun May 11 10:53:49 2003
+++ linux-2.5.69-030509/kernel/timer.c	Sun May 11 11:20:35 2003
@@ -665,6 +665,15 @@
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
@@ -676,12 +685,17 @@
 	do {
 		ticks--;
 		update_wall_time_one_tick();
+
+		if (update_wall_time_hook)
+			update_wall_time_hook();
 	} while (ticks);
 
 	if (xtime.tv_nsec >= 1000000000) {
 	    xtime.tv_nsec -= 1000000000;
 	    xtime.tv_sec++;
 	    second_overflow();
+	    if (update_wall_time_hook)
+		    update_wall_time_hook();
 	}
 }
 

