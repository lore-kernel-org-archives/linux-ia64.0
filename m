From: Jack Steiner <steiner@sgi.com>
Date: Fri, 30 Jan 2004 21:48:03 +0000
Subject: [PATCH] - Delete debug code in arch/ia64/sn/kernel/sn2/timer_interrupt.c
Message-Id: <20040130214803.GA20223@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Some debug was left in timer_interrupt.c:


diff -Naur linux_base/arch/ia64/sn/kernel/sn2/timer_interrupt.c linux/arch/ia64/sn/kernel/sn2/timer_interrupt.c
--- linux_base/arch/ia64/sn/kernel/sn2/timer_interrupt.c	Thu Jan 29 18:14:23 2004
+++ linux/arch/ia64/sn/kernel/sn2/timer_interrupt.c	Fri Jan 30 14:55:34 2004
@@ -48,7 +48,6 @@
 	if (!pda->hb_count--) {
 		pda->hb_count = HZ/2;
 		set_led_bits(pda->hb_state ^= LED_CPU_HEARTBEAT, LED_CPU_HEARTBEAT);
-		printk("Blink\n");
 	}
 
 	if (enable_shub_wars_1_1()) {



-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


