From: Jack Steiner <steiner@sgi.com>
Date: Thu, 11 Aug 2005 17:26:54 +0000
Subject: [PATCH 4/7] - New SN hardware support - no_wars
Message-Id: <20050811172654.GA18449@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Disable some shub1-specific code when running on systems with shub2.


	Signed-off-by: Jack Steiner <steiner@sgi.com>


 timer_interrupt.c |   20 +++++++++++---------
 1 files changed, 11 insertions(+), 9 deletions(-)




Index: linux/arch/ia64/sn/kernel/sn2/timer_interrupt.c
=================================--- linux.orig/arch/ia64/sn/kernel/sn2/timer_interrupt.c	2005-08-10 16:40:13.405524480 -0500
+++ linux/arch/ia64/sn/kernel/sn2/timer_interrupt.c	2005-08-10 16:41:33.497051598 -0500
@@ -1,7 +1,7 @@
 /*
  *
  *
- * Copyright (c) 2003 Silicon Graphics, Inc.  All Rights Reserved.
+ * Copyright (c) 2005 Silicon Graphics, Inc.  All Rights Reserved.
  * 
  * This program is free software; you can redistribute it and/or modify it 
  * under the terms of version 2 of the GNU General Public License 
@@ -50,14 +50,16 @@ void sn_timer_interrupt(int irq, void *d
 			     LED_CPU_HEARTBEAT, LED_CPU_HEARTBEAT);
 	}
 
-	if (enable_shub_wars_1_1()) {
-		/* Bugfix code for SHUB 1.1 */
-		if (pda->pio_shub_war_cam_addr)
-			*pda->pio_shub_war_cam_addr = 0x8000000000000010UL;
+	if (is_shub1()) {
+		if (enable_shub_wars_1_1()) {
+			/* Bugfix code for SHUB 1.1 */
+			if (pda->pio_shub_war_cam_addr)
+				*pda->pio_shub_war_cam_addr = 0x8000000000000010UL;
+		}
+		if (pda->sn_lb_int_war_ticks = 0)
+			sn_lb_int_war_check();
+		pda->sn_lb_int_war_ticks++;
+		if (pda->sn_lb_int_war_ticks >= SN_LB_INT_WAR_INTERVAL)
+			pda->sn_lb_int_war_ticks = 0;
 	}
-	if (pda->sn_lb_int_war_ticks = 0)
-		sn_lb_int_war_check();
-	pda->sn_lb_int_war_ticks++;
-	if (pda->sn_lb_int_war_ticks >= SN_LB_INT_WAR_INTERVAL)
-		pda->sn_lb_int_war_ticks = 0;
 }
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


