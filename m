From: Jack Steiner <steiner@sgi.com>
Date: Tue, 26 Oct 2004 11:47:56 +0000
Subject: [PATCH] - Delete simulator support from SN idle loop
Message-Id: <20041026114756.GA12783@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Tony - please apply


Delete hack for supporting simulator for SN platforms. This capability
has been moved into the simulator environment & is no longer required
in the kernel.

---
Signed-off-by: Jack Steiner <steiner@sgi.com>
---


--- linux_base/arch/ia64/sn/kernel/idle.c	2004-10-22 11:36:31 -05:00
+++ linux/arch/ia64/sn/kernel/idle.c	2004-10-25 17:55:09 -05:00
@@ -3,14 +3,13 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2001-2003 Silicon Graphics, Inc.  All rights reserved.
+ * Copyright (c) 2001-2004 Silicon Graphics, Inc.  All rights reserved.
  */
 
-#include <linux/config.h>
 #include <asm/sn/leds.h>
-#include <asm/sn/simulator.h>
 
-void snidle(int state) {
+void snidle(int state)
+{
 	if (state) {
 		if (pda->idle_flag = 0) {
 			/* 
@@ -18,11 +17,6 @@ void snidle(int state) {
 			 */
 			set_led_bits(0, LED_CPU_ACTIVITY);
 		}
-
-#ifdef CONFIG_IA64_SGI_SN_SIM
-		if (IS_RUNNING_ON_SIMULATOR())
-			SIMULATOR_SLEEP();
-#endif
 
 		pda->idle_flag = 1;
 	} else {
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


