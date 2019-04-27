From: "Enrico Weigelt, metux IT consult" <info@metux.net>
Date: Sat, 27 Apr 2019 12:52:00 +0000
Subject: [PATCH 19/41] drivers: tty: serial: apbuart: fix code formatting
Message-Id: <1556369542-13247-20-git-send-email-info@metux.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556369542-13247-1-git-send-email-info@metux.net>
In-Reply-To: <1556369542-13247-1-git-send-email-info@metux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: gregkh@linuxfoundation.org, andrew@aj.id.au, andriy.shevchenko@linux.intel.com, macro@linux-mips.org, vz@mleia.com, slemieux.tyco@gmail.com, khilman@baylibre.com, liviu.dudau@arm.com, sudeep.holla@arm.com, lorenzo.pieralisi@arm.com, davem@davemloft.net, jacmet@sunsite.dk, linux@prisktech.co.nz, matthias.bgg@gmail.com, linux-mips@vger.kernel.org, linux-serial@vger.kernel.org, linux-ia64@vger.kernel.org, linux-amlogic@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

Fix checkpatch warnings:

    WARNING: line over 80 characters
    #9: FILE: drivers/tty/serial/apbuart.c:9:
    + *  Copyright (C) 2006 Daniel Hellstrom <daniel@gaisler.com>, Aeroflex Gaisler AB

    WARNING: line over 80 characters
    #11: FILE: drivers/tty/serial/apbuart.c:11:
    + *  Copyright (C) 2009 Kristoffer Glembo <kristoffer@gaisler.com>, Aeroflex Gaisler AB

    WARNING: line over 80 characters
    #16: FILE: drivers/tty/serial/apbuart.c:16:
    +#if defined(CONFIG_SERIAL_GRLIB_GAISLER_APBUART_CONSOLE) && defined(CONFIG_MAGIC_SYSRQ)

    WARNING: labels should not be indented
    #122: FILE: drivers/tty/serial/apbuart.c:122:
    +	      ignore_char:

    WARNING: Missing a blank line after declarations
    #186: FILE: drivers/tty/serial/apbuart.c:186:
    +	unsigned int status = UART_GET_STATUS(port);
    +	return status & UART_STATUS_THE ? TIOCSER_TEMT : 0;

    WARNING: Missing a blank line after declarations
    #322: FILE: drivers/tty/serial/apbuart.c:322:
    +	int ret = 0;
    +	if (ser->type != PORT_UNKNOWN && ser->type != PORT_APBUART)

    WARNING: Missing a blank line after declarations
    #427: FILE: drivers/tty/serial/apbuart.c:427:
    +	unsigned int status;
    +	do {

    WARNING: Missing a blank line after declarations
    #463: FILE: drivers/tty/serial/apbuart.c:463:
    +		unsigned int quot, status;
    +		status = UART_GET_STATUS(port);

    WARNING: line over 80 characters
    #627: FILE: drivers/tty/serial/apbuart.c:627:
    +		port->membase = ioremap(addr, sizeof(struct grlib_apbuart_regs_map));

    WARNING: line over 80 characters
    #634: FILE: drivers/tty/serial/apbuart.c:634:
    +		port->fifosize = apbuart_scan_fifo_size((struct uart_port *) port, line);

Signed-off-by: Enrico Weigelt <info@metux.net>
---
 drivers/tty/serial/apbuart.c | 22 +++++++++++++++-------
 1 file changed, 15 insertions(+), 7 deletions(-)

diff --git a/drivers/tty/serial/apbuart.c b/drivers/tty/serial/apbuart.c
index 89e19b6..515a562 100644
--- a/drivers/tty/serial/apbuart.c
+++ b/drivers/tty/serial/apbuart.c
@@ -6,12 +6,15 @@
  *
  *  Copyright (C) 2000 Deep Blue Solutions Ltd.
  *  Copyright (C) 2003 Konrad Eisele <eiselekd@web.de>
- *  Copyright (C) 2006 Daniel Hellstrom <daniel@gaisler.com>, Aeroflex Gaisler AB
+ *  Copyright (C) 2006 Daniel Hellstrom <daniel@gaisler.com>,
+ *                     Aeroflex Gaisler AB
  *  Copyright (C) 2008 Gilead Kutnick <kutnickg@zin-tech.com>
- *  Copyright (C) 2009 Kristoffer Glembo <kristoffer@gaisler.com>, Aeroflex Gaisler AB
+ *  Copyright (C) 2009 Kristoffer Glembo <kristoffer@gaisler.com>,
+ *                     Aeroflex Gaisler AB
  */
 
-#if defined(CONFIG_SERIAL_GRLIB_GAISLER_APBUART_CONSOLE) && defined(CONFIG_MAGIC_SYSRQ)
+#if defined(CONFIG_SERIAL_GRLIB_GAISLER_APBUART_CONSOLE) \
+	&& defined(CONFIG_MAGIC_SYSRQ)
 #define SUPPORT_SYSRQ
 #endif
 
@@ -116,8 +119,7 @@ static void apbuart_rx_chars(struct uart_port *port)
 
 		uart_insert_char(port, rsr, UART_STATUS_OE, ch, flag);
 
-
-	      ignore_char:
+ignore_char:
 		status = UART_GET_STATUS(port);
 	}
 
@@ -181,6 +183,7 @@ static irqreturn_t apbuart_int(int irq, void *dev_id)
 static unsigned int apbuart_tx_empty(struct uart_port *port)
 {
 	unsigned int status = UART_GET_STATUS(port);
+
 	return status & UART_STATUS_THE ? TIOCSER_TEMT : 0;
 }
 
@@ -317,6 +320,7 @@ static int apbuart_verify_port(struct uart_port *port,
 			       struct serial_struct *ser)
 {
 	int ret = 0;
+
 	if (ser->type != PORT_UNKNOWN && ser->type != PORT_APBUART)
 		ret = -EINVAL;
 	if (ser->irq < 0 || ser->irq >= NR_IRQS)
@@ -422,6 +426,7 @@ static void apbuart_flush_fifo(struct uart_port *port)
 static void apbuart_console_putchar(struct uart_port *port, int ch)
 {
 	unsigned int status;
+
 	do {
 		status = UART_GET_STATUS(port);
 	} while (!UART_TX_READY(status));
@@ -458,6 +463,7 @@ static void apbuart_console_putchar(struct uart_port *port, int ch)
 	if (UART_GET_CTRL(port) & (UART_CTRL_RE | UART_CTRL_TE)) {
 
 		unsigned int quot, status;
+
 		status = UART_GET_STATUS(port);
 
 		*parity = 'n';
@@ -622,14 +628,16 @@ static int __init grlib_apbuart_configure(void)
 		port = &grlib_apbuart_ports[line];
 
 		port->mapbase = addr;
-		port->membase = ioremap(addr, sizeof(struct grlib_apbuart_regs_map));
+		port->membase = ioremap(addr,
+			sizeof(struct grlib_apbuart_regs_map));
 		port->irq = 0;
 		port->iotype = UPIO_MEM;
 		port->ops = &grlib_apbuart_ops;
 		port->flags = UPF_BOOT_AUTOCONF;
 		port->line = line;
 		port->uartclk = *freq_hz;
-		port->fifosize = apbuart_scan_fifo_size((struct uart_port *) port, line);
+		port->fifosize = apbuart_scan_fifo_size(
+			(struct uart_port *) port, line);
 		line++;
 
 		/* We support maximum UART_NR uarts ... */
-- 
1.9.1
