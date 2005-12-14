From: hawkes@sgi.com
Date: Wed, 14 Dec 2005 18:47:59 +0000
Subject: [PATCH] disable preemption in udelay()
Message-Id: <20051214184759.13503.88346.sendpatchset@tomahawk.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The udelay() inline for ia64 uses the ITC.  If CONFIG_PREEMPT is enabled
and the platform has unsynchronized ITCs and the calling task migrates to
another CPU while doing the udelay loop, then the effective delay may be
too short or very, very long.

The most simple fix is to disable preemption around the udelay looping.
The downside is that inhibits realtime preemption for cases of long
udelays.  I am reluctant to propose a much more complicated patch (that
disables preemption only for "short" delays, and uses the global RTC as
the time base for longer, preemptible delays) unless there are valid
objections to this more simple fix.

Signed-off-by: John Hawkes <hawkes@sgi.com>

Index: linux/include/asm-ia64/delay.h
=================================--- linux.orig/include/asm-ia64/delay.h	2005-10-27 17:02:08.000000000 -0700
+++ linux/include/asm-ia64/delay.h	2005-12-14 10:30:55.000000000 -0800
@@ -87,11 +87,17 @@
 static __inline__ void
 udelay (unsigned long usecs)
 {
-	unsigned long start = ia64_get_itc();
-	unsigned long cycles = usecs*local_cpu_data->cyc_per_usec;
+	unsigned long start;
+	unsigned long cycles;
+
+	preempt_disable();
+	cycles = usecs*local_cpu_data->cyc_per_usec;
+	start = ia64_get_itc();
 
 	while (ia64_get_itc() - start < cycles)
 		cpu_relax();
+
+	preempt_enable();
 }
 
 #endif /* _ASM_IA64_DELAY_H */
