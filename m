From: Paul Bame <bame@fc.hp.com>
Date: Tue, 10 Dec 2002 16:47:27 +0000
Subject: [Linux-ia64] Serial patch for HP Diva
Message-Id: <marc-linux-ia64-105590709805536@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

When running gettys on multiple of the ports on HP's "Diva" MP
(Management Processor) card, which shows up in various forms in various
boxes, transmit-empty interrupts from the simulated 16550 uarts get
"used up".  You can't get a further transmit empty interrupt from
a single empty condition which causes output to hang.  The following
ugly patch:

    1) bypasses one common case where the interrupt is used up,
       the rs_timer() poll of serial devices which forces a tx-empty
       interrupt
    2) calculates the correct IIR value (in rs-interrupt()) when
       the card won't produce the right one, so the rest of the
       interrupt will operate normally
    3) adds a once-per-second timer to poll the Diva card

When and if HP produces a box with multiple Diva cards, this patch
will need to be updated.  This same logic is recently committed to
the PA-RISC/Linux tree (http://parisc-linux.org) too.


	-Paul Bame

Index: drivers/char/serial.c
=================================RCS file: /var/cvs/linux/drivers/char/serial.c,v
retrieving revision 1.20
retrieving revision 1.23
diff -u -u -r1.20 -r1.23
--- drivers/char/serial.c	27 Aug 2002 15:20:48 -0000	1.20
+++ drivers/char/serial.c	27 Nov 2002 21:23:31 -0000	1.23
@@ -260,6 +260,10 @@
 
 static struct timer_list serial_timer;
 
+#define HP_DIVA_CHECKTIME (1*HZ)
+static struct timer_list hp_diva_timer;
+static int hp_diva_irq = -1;
+
 /* serial subtype definitions */
 #ifndef SERIAL_TYPE_NORMAL
 #define SERIAL_TYPE_NORMAL	1
@@ -797,6 +801,28 @@
 
 #ifdef CONFIG_SERIAL_SHARE_IRQ
 /*
+ * It is possible to "use up" transmit empty interrupts in some
+ * cases with HP Diva cards.  Figure out if there _should_ be a
+ * transmit interrupt and if so, return a suitable iir value so
+ * that we can recover when called from rs_timer().
+ */
+static inline int hp_diva_iir(int irq, struct async_struct *info)
+{
+	int iir = serial_in(info, UART_IIR);
+
+	if (irq = hp_diva_irq &&
+		(iir & UART_IIR_NO_INT) != 0 &&
+		(info->IER & UART_IER_THRI) != 0 &&
+		(info->xmit.head != info->xmit.tail || info->x_char) &&
+		(serial_in(info, UART_LSR) & UART_LSR_THRE) != 0) {
+		    iir &= ~(UART_IIR_ID | UART_IIR_NO_INT);
+		    iir |= UART_IIR_THRI;
+	}
+
+	return iir;
+}
+
+/*
  * This is the serial driver's generic interrupt routine
  */
 static void rs_interrupt(int irq, void *dev_id, struct pt_regs * regs)
@@ -826,7 +852,7 @@
 
 	do {
 		if (!info->tty ||
-		    ((iir=serial_in(info, UART_IIR)) & UART_IIR_NO_INT)) {
+		    ((iir=hp_diva_iir(irq, info)) & UART_IIR_NO_INT)) {
 			if (!end_mark)
 				end_mark = info;
 			goto next;
@@ -1090,9 +1116,11 @@
 #ifdef CONFIG_SERIAL_SHARE_IRQ
 			if (info->next_port) {
 				do {
-					serial_out(info, UART_IER, 0);
-					info->IER |= UART_IER_THRI;
-					serial_out(info, UART_IER, info->IER);
+					if (i != hp_diva_irq) {
+						serial_out(info, UART_IER, 0);
+						info->IER |= UART_IER_THRI;
+						serial_out(info, UART_IER, info->IER);
+					}
 					info = info->next_port;
 				} while (info);
 #ifdef CONFIG_SERIAL_MULTIPORT
@@ -1124,6 +1152,32 @@
 }
 
 /*
+ * This subroutine is called when the hp_diva_timer goes off.  In certain
+ * cases (multiple gettys in particular) Diva seems
+ * to issue only a single transmit empty interrupt instead of one each
+ * time THRI is enabled, causing interrupts to be "used up".  This
+ * serves to poll the Diva UARTS more frequently than rs_timer() does.
+ */
+static void hp_diva_check(unsigned long dummy)
+{
+	static unsigned long last_strobe;
+	struct async_struct *info;
+	unsigned long flags;
+
+	if (time_after_eq(jiffies, last_strobe + HP_DIVA_CHECKTIME)) {
+		info = IRQ_ports[hp_diva_irq];
+		if (info) {
+			save_flags(flags); cli();
+			rs_interrupt(hp_diva_irq, NULL, NULL);
+			restore_flags(flags);
+		}
+	}
+	last_strobe = jiffies;
+	mod_timer(&hp_diva_timer, jiffies + HP_DIVA_CHECKTIME);
+}
+
+
+/*
  * ---------------------------------------------------------------
  * Low level utility subroutines for the serial driver:  routines to
  * figure out the appropriate timeout for an interrupt chain, routines
@@ -4267,6 +4321,8 @@
 	if (!enable)
 		return 0;
 
+	hp_diva_irq = dev->irq;
+
 	switch (dev->subsystem_device) {
 	case 0x1049: /* Prelude Diva 1 */
 	case 0x1223: /* Superdome */
@@ -4285,6 +4341,10 @@
 		break;
 	}
 
+	init_timer(&hp_diva_timer);
+	hp_diva_timer.function = hp_diva_check;
+	mod_timer(&hp_diva_timer, jiffies + HP_DIVA_CHECKTIME);
+
 	return 0;
 }
 
@@ -5813,6 +5873,8 @@
 
 	/* printk("Unloading %s: version %s\n", serial_name, serial_version); */
 	del_timer_sync(&serial_timer);
+	if (hp_diva_irq != -1)
+		del_timer_sync(&hp_diva_timer);
 	save_flags(flags); cli();
         remove_bh(SERIAL_BH);
 	if ((e1 = tty_unregister_driver(&serial_driver)))

