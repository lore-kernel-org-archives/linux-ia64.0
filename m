From: Jesse Barnes <jbarnes@sgi.com>
Date: Mon, 22 Mar 2004 18:34:33 +0000
Subject: [PATCH] quiet sn_serial driver
Message-Id: <200403221034.33133.jbarnes@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_5GzXAYi5hCwRatp"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--Boundary-00=_5GzXAYi5hCwRatp
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Bjorn pointed out that the sn console driver will spew printks if compiled in 
even if no hardware is present.  In addition to fixing that, I took the 
opportunity to cleanup/correct a few other printks in that driver.

Thanks,
Jesse

--Boundary-00=_5GzXAYi5hCwRatp
Content-Type: text/plain;
  charset="us-ascii";
  name="sn_serial-quiet.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="sn_serial-quiet.patch"

===== drivers/char/sn_serial.c 1.9 vs edited =====
--- 1.9/drivers/char/sn_serial.c	Mon Mar 15 06:28:24 2004
+++ edited/drivers/char/sn_serial.c	Mon Mar 22 10:29:18 2004
@@ -352,7 +352,7 @@
 		if (xmit_count > 0) {
 			result = sn_func->sal_puts((char *)start, xmit_count);
 			if (!result)
-				sn_debug_printf("\n*** synch_flush_xmit failed to flush\n");
+				DPRINTF("\n*** synch_flush_xmit failed to flush\n");
 			if (result > 0) {
 				xmit_count -= result;
 				sn_total_tx_count += result;
@@ -389,12 +389,12 @@
 	xmit_count = (head < tail) ?  (SN_SAL_BUFFER_SIZE - tail) : (head - tail);
 
 	if (xmit_count == 0)
-		sn_debug_printf("\n*** empty xmit_count\n");
+		DPRINTF("\n*** empty xmit_count\n");
 
 	/* use the ops, as we could be on the simulator */
 	result = sn_func->sal_puts((char *)start, xmit_count);
 	if (!result)
-		sn_debug_printf("\n*** error in synchronous sal_puts\n");
+		DPRINTF("\n*** error in synchronous sal_puts\n");
 	/* XXX chadt clean this up */
 	if (result > 0) {
 		xmit_count -= result;
@@ -447,7 +447,7 @@
 			result = ia64_sn_console_xmit_chars((char *)start, xmit_count);
 #ifdef DEBUG
 			if (!result)
-				sn_debug_printf("`");
+				DPRINTF("`");
 #endif
 			if (result > 0) {
 				xmit_count -= result;
@@ -511,7 +511,7 @@
 	if (result >= 0)
 		return console_irq;
 
-	printk(KERN_INFO "sn_serial: console proceeding in polled mode\n");
+	printk(KERN_WARNING "sn_serial: console proceeding in polled mode\n");
 	return 0;
 }
 
@@ -823,7 +823,7 @@
 		return;
 	}
 
-	sn_debug_printf("sn_serial: switch to asynchronous console\n");
+	DPRINTF("sn_serial: switch to asynchronous console\n");
 
 	/* early_printk invocation may have done this for us */
 	if (!sn_func) {
@@ -859,7 +859,7 @@
 {
 	int irq;
 
-	sn_debug_printf("sn_serial: switching to interrupt driven console\n");
+	DPRINTF("sn_serial: switching to interrupt driven console\n");
 
 	irq = sn_sal_connect_interrupt();
 	if (irq) {
@@ -883,7 +883,7 @@
 {
 	int retval;
 
-	printk("sn_serial: sn_sal_module_init\n");
+	DPRINTF("sn_serial: sn_sal_module_init\n");
 
 	if (!ia64_platform_is("sn2"))
 		return -ENODEV;
@@ -1016,7 +1016,7 @@
 {
 	if (ia64_platform_is("sn2")) {
 		sn_sal_switch_to_asynch();
-		sn_debug_printf("sn_sal_serial_console_init : register console\n");
+		DPRINTF("sn_sal_serial_console_init : register console\n");
 		register_console(&sal_console);
 	}
 	return 0;

--Boundary-00=_5GzXAYi5hCwRatp--
