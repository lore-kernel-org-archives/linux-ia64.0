From: Jack Steiner <steiner@sgi.com>
Date: Mon, 25 Oct 2004 15:34:51 +0000
Subject: [PATCH] - Delete obsolete code grom SGI console driver
Message-Id: <20041025153450.GA24620@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Tony - please apply:


Delete obsolete code that supports the SGI simulator. This
support code has been moved into the fakeprom and is no
longer required in the kernel.


Signed-off-by: Jack Steiner <steiner@sgi.com>

---

--- linux_base/drivers/serial/sn_console.c	2004-10-22 11:36:37 -05:00
+++ linux/drivers/serial/sn_console.c	2004-10-25 10:23:55 -05:00
@@ -108,7 +108,6 @@ static struct sn_cons_port sal_console_p
 /* Only used if USE_DYNAMIC_MINOR is set to 1 */
 static struct miscdevice misc;	/* used with misc_register for dynamic */
 
-extern u64 __iomem *master_node_bedrock_address;
 extern void early_sn_setup(void);
 
 #undef DEBUG
@@ -124,9 +123,6 @@ static int snt_hw_puts_raw(const char *,
 static int snt_hw_puts_buffered(const char *, int);
 static int snt_poll_getc(void);
 static int snt_poll_input_pending(void);
-static int snt_sim_puts(const char *, int);
-static int snt_sim_getc(void);
-static int snt_sim_input_pending(void);
 static int snt_intr_getc(void);
 static int snt_intr_input_pending(void);
 static void sn_transmit_chars(struct sn_cons_port *, int);
@@ -140,14 +136,6 @@ static struct sn_sal_ops poll_ops = {
 	.sal_input_pending = snt_poll_input_pending
 };
 
-/* A table for the simulator */
-static struct sn_sal_ops sim_ops = {
-	.sal_puts_raw = snt_sim_puts,
-	.sal_puts = snt_sim_puts,
-	.sal_getc = snt_sim_getc,
-	.sal_input_pending = snt_sim_input_pending
-};
-
 /* A table for interrupts enabled */
 static struct sn_sal_ops intr_ops = {
 	.sal_puts_raw = snt_hw_puts_raw,
@@ -194,53 +182,6 @@ static int snt_poll_input_pending(void)
 	return !status && input;
 }
 
-/* routines for running the console on the simulator */
-
-/**
- * snt_sim_puts - send to the console, used in simulator mode
- * @str: String to send
- * @count: length of string
- *
- */
-static int snt_sim_puts(const char *str, int count)
-{
-	int counter = count;
-
-#ifdef FLAG_DIRECT_CONSOLE_WRITES
-	/* This is an easy way to pre-pend the output to know whether the output
-	 * was done via sal or directly */
-	writeb('[', master_node_bedrock_address + (UART_TX << 3));
-	writeb('+', master_node_bedrock_address + (UART_TX << 3));
-	writeb(']', master_node_bedrock_address + (UART_TX << 3));
-	writeb(' ', master_node_bedrock_address + (UART_TX << 3));
-#endif				/* FLAG_DIRECT_CONSOLE_WRITES */
-	while (counter > 0) {
-		writeb(*str, master_node_bedrock_address + (UART_TX << 3));
-		counter--;
-		str++;
-	}
-	return count;
-}
-
-/**
- * snt_sim_getc - Get character from console in simulator mode
- *
- */
-static int snt_sim_getc(void)
-{
-	return readb(master_node_bedrock_address + (UART_RX << 3));
-}
-
-/**
- * snt_sim_input_pending - Check if there is input pending in simulator mode
- *
- */
-static int snt_sim_input_pending(void)
-{
-	return readb(master_node_bedrock_address +
-		     (UART_LSR << 3)) & UART_LSR_DR;
-}
-
 /* routines for an interrupt driven console (normal) */
 
 /**
@@ -491,11 +432,7 @@ static int sn_debug_printf(const char *f
 	printed_len = vsnprintf(printk_buf, sizeof(printk_buf), fmt, args);
 
 	if (!sal_console_port.sc_ops) {
-		if (IS_RUNNING_ON_SIMULATOR())
-			sal_console_port.sc_ops = &sim_ops;
-		else
-			sal_console_port.sc_ops = &poll_ops;
-
+		sal_console_port.sc_ops = &poll_ops;
 		early_sn_setup();
 	}
 	sal_console_port.sc_ops->sal_puts_raw(printk_buf, printed_len);
@@ -781,12 +718,8 @@ static void __init sn_sal_switch_to_asyn
 	spin_lock_irqsave(&port->sc_port.lock, flags);
 
 	/* early_printk invocation may have done this for us */
-	if (!port->sc_ops) {
-		if (IS_RUNNING_ON_SIMULATOR())
-			port->sc_ops = &sim_ops;
-		else
-			port->sc_ops = &poll_ops;
-	}
+	if (!port->sc_ops)
+		port->sc_ops = &poll_ops;
 
 	/* we can't turn on the console interrupt (as request_irq
 	 * calls kmalloc, which isn't set up yet), so we rely on a
@@ -1155,11 +1088,7 @@ int __init sn_serial_console_early_setup
 	if (!ia64_platform_is("sn2"))
 		return -1;
 
-	if (IS_RUNNING_ON_SIMULATOR())
-		sal_console_port.sc_ops = &sim_ops;
-	else
-		sal_console_port.sc_ops = &poll_ops;
-
+	sal_console_port.sc_ops = &poll_ops;
 	early_sn_setup();	/* Find SAL entry points */
 	register_console(&sal_console_early);
 
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


