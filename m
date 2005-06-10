From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 10 Jun 2005 05:39:51 +0000
Subject: [patch] replace left-over KDB-code in simserial with MAGIC_SYSRQ code
Message-Id: <200506100539.j5A5dprs001963@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Patch below makes it possible to use the "F4" function key to do
magic sysrq in the HP Ski simulator.

Thanks,

	--david

[IA64] Replace stale KDB-code with useful MAGIC_SYSRQ code in simserial.c

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

diff --git a/arch/ia64/hp/sim/simserial.c b/arch/ia64/hp/sim/simserial.c
--- a/arch/ia64/hp/sim/simserial.c
+++ b/arch/ia64/hp/sim/simserial.c
@@ -30,6 +30,7 @@
 #include <linux/module.h>
 #include <linux/serial.h>
 #include <linux/serialP.h>
+#include <linux/sysrq.h>
 
 #include <asm/irq.h>
 #include <asm/hw_irq.h>
@@ -149,12 +150,17 @@ static  void receive_chars(struct tty_st
 				seen_esc = 2;
 				continue;
 			} else if ( seen_esc = 2 ) {
-				if ( ch = 'P' ) show_state();		/* F1 key */
-#ifdef CONFIG_KDB
-				if ( ch = 'S' )
-					kdb(KDB_REASON_KEYBOARD, 0, (kdb_eframe_t) regs);
+				if ( ch = 'P' ) /* F1 */
+					show_state();
+#ifdef CONFIG_MAGIC_SYSRQ
+				if ( ch = 'S' ) { /* F4 */
+					do
+						ch = ia64_ssc(0, 0, 0, 0,
+							      SSC_GETCHAR);
+					while (!ch);
+					handle_sysrq(ch, regs, NULL);
+				}
 #endif
-
 				seen_esc = 0;
 				continue;
 			}
