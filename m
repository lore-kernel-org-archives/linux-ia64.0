From: "Enrico Weigelt, metux IT consult" <info@metux.net>
Date: Sat, 27 Apr 2019 12:51:56 +0000
Subject: [PATCH 15/41] drivers: tty: serial: uartlite: fix use fix bare 'unsigned'
Message-Id: <1556369542-13247-16-git-send-email-info@metux.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556369542-13247-1-git-send-email-info@metux.net>
In-Reply-To: <1556369542-13247-1-git-send-email-info@metux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: gregkh@linuxfoundation.org, andrew@aj.id.au, andriy.shevchenko@linux.intel.com, macro@linux-mips.org, vz@mleia.com, slemieux.tyco@gmail.com, khilman@baylibre.com, liviu.dudau@arm.com, sudeep.holla@arm.com, lorenzo.pieralisi@arm.com, davem@davemloft.net, jacmet@sunsite.dk, linux@prisktech.co.nz, matthias.bgg@gmail.com, linux-mips@vger.kernel.org, linux-serial@vger.kernel.org, linux-ia64@vger.kernel.org, linux-amlogic@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

Fix checkpatch warnings:

    WARNING: Prefer 'unsigned int' to bare use of 'unsigned'
    #562: FILE: drivers/tty/serial/uartlite.c:562:
    +	unsigned retries = 1000000;

    WARNING: Prefer 'unsigned int' to bare use of 'unsigned'
    #574: FILE: drivers/tty/serial/uartlite.c:574:
    +				 const char *s, unsigned n)

Signed-off-by: Enrico Weigelt <info@metux.net>
---
 drivers/tty/serial/uartlite.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/tty/serial/uartlite.c b/drivers/tty/serial/uartlite.c
index 4c28600..6f79353 100644
--- a/drivers/tty/serial/uartlite.c
+++ b/drivers/tty/serial/uartlite.c
@@ -559,7 +559,7 @@ static void early_uartlite_putc(struct uart_port *port, int c)
 	 * we'll never timeout on a working UART.
 	 */
 
-	unsigned retries = 1000000;
+	unsigned int retries = 1000000;
 	/* read status bit - 0x8 offset */
 	while (--retries && (readl(port->membase + 8) & (1 << 3)))
 		;
@@ -571,7 +571,7 @@ static void early_uartlite_putc(struct uart_port *port, int c)
 }
 
 static void early_uartlite_write(struct console *console,
-				 const char *s, unsigned n)
+				 const char *s, unsigned int n)
 {
 	struct earlycon_device *device = console->data;
 	uart_console_write(&device->port, s, n, early_uartlite_putc);
-- 
1.9.1
