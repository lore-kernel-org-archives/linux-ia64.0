From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 01 Aug 2007 19:41:14 +0000
Subject: [PATCH] SN2: Fix up sn2_rtc clock
Message-Id: <Pine.LNX.4.64.0708011239360.26753@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From cbddfb36b77f8c96b2d5685c898c73025bb86a90 Mon Sep 17 00:00:00 2001
From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 1 Aug 2007 12:37:17 -0700
Subject: [PATCH] SN2: Fix up sn2_rtc clock

If the sn2_rtc clock is present then it is a must have since sn2_rtc
provides a synchronized time source on Altix systems. So elevate
the priority to 450. Otherwise the ITC would take precendence. Altix
systems currently do not boot because the ITC clocksource is broken. It 
seems to assume that ITCs are synchronized and as a result nanosleep 
hangs (may be fixed in a different patch).

While we are at it: Remove the sn2_mc definition. The sn2_rtc has a fixed
address. No point in reading the address from memory. Removing it avoids
touching one cacheline.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 arch/ia64/sn/kernel/sn2/timer.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/arch/ia64/sn/kernel/sn2/timer.c b/arch/ia64/sn/kernel/sn2/timer.c
index 19e25d2..cf67fc5 100644
--- a/arch/ia64/sn/kernel/sn2/timer.c
+++ b/arch/ia64/sn/kernel/sn2/timer.c
@@ -23,16 +23,14 @@
 
 extern unsigned long sn_rtc_cycles_per_second;
 
-static void __iomem *sn2_mc;
-
 static cycle_t read_sn2(void)
 {
-	return (cycle_t)readq(sn2_mc);
+	return (cycle_t)readq(RTC_COUNTER_ADDR);
 }
 
 static struct clocksource clocksource_sn2 = {
         .name           = "sn2_rtc",
-        .rating         = 300,
+        .rating         = 450,
         .read           = read_sn2,
         .mask           = (1LL << 55) - 1,
         .mult           = 0,
@@ -58,7 +56,6 @@ ia64_sn_udelay (unsigned long usecs)
 
 void __init sn_timer_init(void)
 {
-	sn2_mc = RTC_COUNTER_ADDR;
 	clocksource_sn2.fsys_mmio = RTC_COUNTER_ADDR;
 	clocksource_sn2.mult = clocksource_hz2mult(sn_rtc_cycles_per_second,
 							clocksource_sn2.shift);
-- 
1.5.2.4

