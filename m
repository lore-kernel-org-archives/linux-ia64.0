From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 10 Feb 2004 23:28:31 +0000
Subject: [PATCH] Fix /proc serial info for MMIO ports
Message-Id: <200402101628.31933.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch against 2.6.2 fixes a minor issue with /proc/tty/drivers/serial,
which currently doesn't show MMIO address information.  Current
sample output:

	# cat /proc/tty/driver/serial
	serinfo:1.0 driver revision:
	0: uart:16450 port:00000000 irq:65 tx:72 rx:0 RTS|DTR
	1: uart:16550A port:00000000 irq:65 tx:2950 rx:0 RTS|DTR
	...

Output with the attached patch:

	# cat /proc/tty/driver/serial 
	serinfo:1.0 driver revision:
	0: uart:16450 mmio:0xF8031000 irq:65 tx:72 rx:0 RTS|DTR
	1: uart:16550A mmio:0xFF5E0000 irq:65 tx:2403 rx:74 RTS|DTR
	...

=== drivers/serial/serial_core.c 1.78 vs edited ==--- 1.78/drivers/serial/serial_core.c	Sat Jan 24 14:53:13 2004
+++ edited/drivers/serial/serial_core.c	Tue Feb 10 15:52:10 2004
@@ -1666,9 +1666,12 @@
 	if (!port)
 		return 0;
 
-	ret = sprintf(buf, "%d: uart:%s port:%08X irq:%d",
+	ret = sprintf(buf, "%d: uart:%s %s%08lX irq:%d",
 			port->line, uart_type(port),
-			port->iobase, port->irq);
+			port->iotype = UPIO_MEM ? "mmio:0x" : "port:",
+			port->iotype = UPIO_MEM ? port->mapbase :
+						(unsigned long) port->iobase,
+			port->irq);
 
 	if (port->type = PORT_UNKNOWN) {
 		strcat(buf, "\n");

