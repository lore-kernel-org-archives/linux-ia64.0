From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 01 Aug 2007 20:56:54 +0000
Subject: [PATCH] ITC: Reduce rating for ITC clock if ITCs are drifty
Message-Id: <Pine.LNX.4.64.0708011352030.848@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From 497cb18db5c53eeb7e07b44d2e7ed8fff35d102f Mon Sep 17 00:00:00 2001
From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 1 Aug 2007 13:49:45 -0700
Subject: [PATCH] ITC: Reduce rating for ITC clock if ITCs are drifty

Make sure to reduce the rating of the ITC clock if ITCs are drifty. If they
are drifting then we have not synchronized the ITC values, nor are we doing
the jitter compensation (useless since drift may increase the differentials
arbitrarily).

Without this patch it is possible that the ITC clock becomes selected as 
the system clock on systems with drifty ITCs which will result in 
nanosleep hanging.

One can still select the itc clock manually on such systems via

clocksource=itc

(Produces nice hangs on SGI Altix.)

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 arch/ia64/kernel/time.c |   16 +++++++++++++++-
 1 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
index 6c0e9e2..98cfc90 100644
--- a/arch/ia64/kernel/time.c
+++ b/arch/ia64/kernel/time.c
@@ -240,7 +240,21 @@ ia64_init_itm (void)
 		if (!nojitter)
 			itc_jitter_data.itc_jitter = 1;
 #endif
-	}
+	} else
+		/*
+		 * ITC is drifty and we have not synchronized the ITCs in smpboot.c.
+		 * ITC values may fluctuate significantly between processors.
+		 * Clock should not be used for hrtimers. Mark itc as only
+		 * useful for boot and testing.
+		 *
+		 * Note that jitter compensation is off! There is no point of
+		 * synchronizing ITCs since they may be large differentials
+		 * that change over time.
+		 *
+		 * The only way to fix this would be to repeatedly sync the
+		 * ITCs. Until that time we have to avoid ITC.
+		 */
+		clocksource_itc.rating = 50;
 
 	/* Setup the CPU local timer tick */
 	ia64_cpu_local_tick();
-- 
1.5.2.4

