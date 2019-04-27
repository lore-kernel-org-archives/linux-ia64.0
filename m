From: "Enrico Weigelt, metux IT consult" <info@metux.net>
Date: Sat, 27 Apr 2019 12:52:06 +0000
Subject: [PATCH 25/41] drivers: tty: serial: timbuart: fix formatting issues
Message-Id: <1556369542-13247-26-git-send-email-info@metux.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556369542-13247-1-git-send-email-info@metux.net>
In-Reply-To: <1556369542-13247-1-git-send-email-info@metux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: gregkh@linuxfoundation.org, andrew@aj.id.au, andriy.shevchenko@linux.intel.com, macro@linux-mips.org, vz@mleia.com, slemieux.tyco@gmail.com, khilman@baylibre.com, liviu.dudau@arm.com, sudeep.holla@arm.com, lorenzo.pieralisi@arm.com, davem@davemloft.net, jacmet@sunsite.dk, linux@prisktech.co.nz, matthias.bgg@gmail.com, linux-mips@vger.kernel.org, linux-serial@vger.kernel.org, linux-ia64@vger.kernel.org, linux-amlogic@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

Fix checkpatch warnings:

    WARNING: Missing a blank line after declarations
    #43: FILE: drivers/tty/serial/timbuart.c:43:
    +	u32 ier = ioread32(port->membase + TIMBUART_IER) & ~RXFLAGS;
    +	iowrite32(ier, port->membase + TIMBUART_IER);

    WARNING: Missing a blank line after declarations
    #50: FILE: drivers/tty/serial/timbuart.c:50:
    +	u32 ier = ioread32(port->membase + TIMBUART_IER) & ~TXBAE;
    +	iowrite32(ier, port->membase + TIMBUART_IER);

    WARNING: Missing a blank line after declarations
    #86: FILE: drivers/tty/serial/timbuart.c:86:
    +		u8 ch = ioread8(port->membase + TIMBUART_RXFIFO);
    +		port->icount.rx++;

    WARNING: Missing a blank line after declarations
    #202: FILE: drivers/tty/serial/timbuart.c:202:
    +	u8 cts = ioread8(port->membase + TIMBUART_CTRL);
    +	dev_dbg(port->dev, "%s - cts %x\n", __func__, cts);

    WARNING: Block comments use * on subsequent lines
    #296: FILE: drivers/tty/serial/timbuart.c:296:
    +	/* The serial layer calls into this once with old = NULL when setting
    +	   up initially */

    WARNING: Block comments use a trailing */ on a separate line
    #296: FILE: drivers/tty/serial/timbuart.c:296:

Signed-off-by: Enrico Weigelt <info@metux.net>
---
 drivers/tty/serial/timbuart.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/tty/serial/timbuart.c b/drivers/tty/serial/timbuart.c
index dcce936..d80c332 100644
--- a/drivers/tty/serial/timbuart.c
+++ b/drivers/tty/serial/timbuart.c
@@ -40,6 +40,7 @@ static void timbuart_stop_rx(struct uart_port *port)
 {
 	/* spin lock held by upper layer, disable all RX interrupts */
 	u32 ier = ioread32(port->membase + TIMBUART_IER) & ~RXFLAGS;
+
 	iowrite32(ier, port->membase + TIMBUART_IER);
 }
 
@@ -47,6 +48,7 @@ static void timbuart_stop_tx(struct uart_port *port)
 {
 	/* spinlock held by upper layer, disable TX interrupt */
 	u32 ier = ioread32(port->membase + TIMBUART_IER) & ~TXBAE;
+
 	iowrite32(ier, port->membase + TIMBUART_IER);
 }
 
@@ -83,6 +85,7 @@ static void timbuart_rx_chars(struct uart_port *port)
 
 	while (ioread32(port->membase + TIMBUART_ISR) & RXDP) {
 		u8 ch = ioread8(port->membase + TIMBUART_RXFIFO);
+
 		port->icount.rx++;
 		tty_insert_flip_char(tport, ch, TTY_NORMAL);
 	}
@@ -199,6 +202,7 @@ static void timbuart_tasklet(unsigned long arg)
 static unsigned int timbuart_get_mctrl(struct uart_port *port)
 {
 	u8 cts = ioread8(port->membase + TIMBUART_CTRL);
+
 	dev_dbg(port->dev, "%s - cts %x\n", __func__, cts);
 
 	if (cts & TIMBUART_CTRL_CTS)
@@ -293,7 +297,8 @@ static void timbuart_set_termios(struct uart_port *port,
 	baud = baudrates[bindex];
 
 	/* The serial layer calls into this once with old = NULL when setting
-	   up initially */
+	 * up initially
+	 */
 	if (old)
 		tty_termios_copy_hw(termios, old);
 	tty_termios_encode_baud_rate(termios, baud, baud);
@@ -500,4 +505,3 @@ static int timbuart_remove(struct platform_device *dev)
 MODULE_DESCRIPTION("Timberdale UART driver");
 MODULE_LICENSE("GPL v2");
 MODULE_ALIAS("platform:timb-uart");
-
-- 
1.9.1
