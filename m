From: John Hawkes <hawkes@babylon.engr.sgi.com>
Date: Thu, 20 Nov 2003 00:56:23 +0000
Subject: [PATCH] - sched_clock() broken for ia64 SN platform
Message-Id: <marc-linux-ia64-106928980122896@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

sched_clock() is broken in 2.6.0-test9 for ia64 "drifty ITC" platforms,
such as the SGI "SN" platform.  The CPU Scheduler expects sched_clock() to
return a nanosecond value that is synchronized across all CPUs, and the SN
platform must use platform's RealTimeClock (RTC).

I attach a patch that fixes this for the SN platform.

We might instead want to implement a more general scheme, along the lines of
what is done by (struct time_interpolator), to provide a framework to solve
this for other architectures that have "drifty" non-default timebases.

John Hawkes


diff -X /home/hawkes/Patches/ignore.dirs -Naur linux-2.6.0/arch/ia64/kernel/time.c linux-2.6.0-schedclock/arch/ia64/kernel/time.c
--- linux-2.6.0/arch/ia64/kernel/time.c	Mon Oct 20 12:48:11 2003
+++ linux-2.6.0-schedclock/arch/ia64/kernel/time.c	Tue Nov 18 17:28:31 2003
@@ -42,12 +42,18 @@
 
 #endif
 
+static unsigned long long
+itc_sched_clock (void)
+{
+	return jiffies * (1000000000/HZ);	/* a crude-granularity hack */
+}
+
+unsigned long long (*ia64_sched_clock)(void) = &itc_sched_clock;
+
 unsigned long long
 sched_clock (void)
 {
-	unsigned long offset = ia64_get_itc();
-
-	return (offset * local_cpu_data->nsec_per_cyc) >> IA64_NSEC_PER_CYC_SHIFT;
+	return ia64_sched_clock();
 }
 
 static void
diff -X /home/hawkes/Patches/ignore.dirs -Naur linux-2.6.0/arch/ia64/sn/kernel/sn2/timer.c linux-2.6.0-schedclock/arch/ia64/sn/kernel/sn2/timer.c
--- linux-2.6.0/arch/ia64/sn/kernel/sn2/timer.c	Mon Jul 14 11:51:29 2003
+++ linux-2.6.0-schedclock/arch/ia64/sn/kernel/sn2/timer.c	Wed Nov 19 10:00:43 2003
@@ -22,6 +22,8 @@
 extern unsigned long sn_rtc_cycles_per_second;
 static volatile unsigned long last_wall_rtc;
 
+extern unsigned long long (*ia64_sched_clock)(void);
+
 static unsigned long rtc_offset;	/* updated only when xtime write-lock is held! */
 static long rtc_nsecs_per_cycle;
 static long rtc_per_timer_tick;
@@ -55,6 +57,12 @@
 	last_wall_rtc = GET_RTC_COUNTER();
 }
 
+static unsigned long long
+sn_sched_clock(void)
+{
+	return GET_RTC_COUNTER() * rtc_nsecs_per_cycle;
+}
+
 
 static struct time_interpolator sn2_interpolator = {
 	.get_offset =	getoffset,
@@ -73,4 +81,6 @@
 	rtc_nsecs_per_cycle = 1000000000 / sn_rtc_cycles_per_second;
 
 	last_wall_rtc = GET_RTC_COUNTER();
+
+	ia64_sched_clock = &sn_sched_clock;
 }
