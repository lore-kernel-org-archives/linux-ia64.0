From: "Enrico Weigelt, metux IT consult" <info@metux.net>
Date: Sat, 27 Apr 2019 12:51:57 +0000
Subject: [PATCH 16/41] drivers: tty: serial: uartlite: fix overlong lines
Message-Id: <1556369542-13247-17-git-send-email-info@metux.net>
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
    #283: FILE: drivers/tty/serial/uartlite.c:283:
    +	ret = request_irq(port->irq, ulite_isr, IRQF_SHARED | IRQF_TRIGGER_RISING,

    WARNING: Missing a blank line after declarations
    #577: FILE: drivers/tty/serial/uartlite.c:577:
    +	struct earlycon_device *device = console->data;
    +	uart_console_write(&device->port, s, n, early_uartlite_putc);

    WARNING: line over 80 characters
    #590: FILE: drivers/tty/serial/uartlite.c:590:
    +OF_EARLYCON_DECLARE(uartlite_b, "xlnx,opb-uartlite-1.00.b", early_uartlite_setup);

    WARNING: line over 80 characters
    #591: FILE: drivers/tty/serial/uartlite.c:591:
    +OF_EARLYCON_DECLARE(uartlite_a, "xlnx,xps-uartlite-1.00.a", early_uartlite_setup);

Signed-off-by: Enrico Weigelt <info@metux.net>
---
 drivers/tty/serial/uartlite.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/tty/serial/uartlite.c b/drivers/tty/serial/uartlite.c
index 6f79353..0140cec 100644
--- a/drivers/tty/serial/uartlite.c
+++ b/drivers/tty/serial/uartlite.c
@@ -280,7 +280,8 @@ static int ulite_startup(struct uart_port *port)
 		return ret;
 	}
 
-	ret = request_irq(port->irq, ulite_isr, IRQF_SHARED | IRQF_TRIGGER_RISING,
+	ret = request_irq(port->irq, ulite_isr,
+			  IRQF_SHARED | IRQF_TRIGGER_RISING,
 			  "uartlite", port);
 	if (ret)
 		return ret;
@@ -574,6 +575,7 @@ static void early_uartlite_write(struct console *console,
 				 const char *s, unsigned int n)
 {
 	struct earlycon_device *device = console->data;
+
 	uart_console_write(&device->port, s, n, early_uartlite_putc);
 }
 
@@ -587,8 +589,10 @@ static int __init early_uartlite_setup(struct earlycon_device *device,
 	return 0;
 }
 EARLYCON_DECLARE(uartlite, early_uartlite_setup);
-OF_EARLYCON_DECLARE(uartlite_b, "xlnx,opb-uartlite-1.00.b", early_uartlite_setup);
-OF_EARLYCON_DECLARE(uartlite_a, "xlnx,xps-uartlite-1.00.a", early_uartlite_setup);
+OF_EARLYCON_DECLARE(uartlite_b, "xlnx,opb-uartlite-1.00.b",
+		    early_uartlite_setup);
+OF_EARLYCON_DECLARE(uartlite_a, "xlnx,xps-uartlite-1.00.a",
+		    early_uartlite_setup);
 
 #endif /* CONFIG_SERIAL_UARTLITE_CONSOLE */
 
-- 
1.9.1
