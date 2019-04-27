From: "Enrico Weigelt, metux IT consult" <info@metux.net>
Date: Sat, 27 Apr 2019 12:51:54 +0000
Subject: [PATCH 13/41] drivers: tty: serial: uartlite: fill mapsize and use it
Message-Id: <1556369542-13247-14-git-send-email-info@metux.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556369542-13247-1-git-send-email-info@metux.net>
In-Reply-To: <1556369542-13247-1-git-send-email-info@metux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: gregkh@linuxfoundation.org, andrew@aj.id.au, andriy.shevchenko@linux.intel.com, macro@linux-mips.org, vz@mleia.com, slemieux.tyco@gmail.com, khilman@baylibre.com, liviu.dudau@arm.com, sudeep.holla@arm.com, lorenzo.pieralisi@arm.com, davem@davemloft.net, jacmet@sunsite.dk, linux@prisktech.co.nz, matthias.bgg@gmail.com, linux-mips@vger.kernel.org, linux-serial@vger.kernel.org, linux-ia64@vger.kernel.org, linux-amlogic@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

Fill the struct uart_port->mapsize field and use it, insteaf of
hardcoded values in many places. This makes the code layout a bit
more consistent and easily allows using generic helpers for the
io memory handling.

Candidates for such helpers could be eg. the request+ioremap and
iounmap+release combinations.

Signed-off-by: Enrico Weigelt <info@metux.net>
---
 drivers/tty/serial/uartlite.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/tty/serial/uartlite.c b/drivers/tty/serial/uartlite.c
index 44d65bd..c322ab6 100644
--- a/drivers/tty/serial/uartlite.c
+++ b/drivers/tty/serial/uartlite.c
@@ -342,7 +342,7 @@ static const char *ulite_type(struct uart_port *port)
 
 static void ulite_release_port(struct uart_port *port)
 {
-	release_mem_region(port->mapbase, ULITE_REGION);
+	release_mem_region(port->mapbase, port->mapsize);
 	iounmap(port->membase);
 	port->membase = NULL;
 }
@@ -356,15 +356,15 @@ static int ulite_request_port(struct uart_port *port)
 		"ulite console: port=%p; port->mapbase=%llx\n",
 		 port, (unsigned long long) port->mapbase);
 
-	if (!request_mem_region(port->mapbase, ULITE_REGION, "uartlite")) {
+	if (!request_mem_region(port->mapbase, port->mapsize, "uartlite")) {
 		dev_err(port->dev, "Memory region busy\n");
 		return -EBUSY;
 	}
 
-	port->membase = ioremap(port->mapbase, ULITE_REGION);
+	port->membase = ioremap(port->mapbase, port->mapsize);
 	if (!port->membase) {
 		dev_err(port->dev, "Unable to map registers\n");
-		release_mem_region(port->mapbase, ULITE_REGION);
+		release_mem_region(port->mapbase, port->mapsize);
 		return -EBUSY;
 	}
 
@@ -649,6 +649,7 @@ static int ulite_assign(struct device *dev, int id, u32 base, int irq,
 	port->iotype = UPIO_MEM;
 	port->iobase = 1; /* mark port in use */
 	port->mapbase = base;
+	port->mapsize = ULITE_REGION;
 	port->membase = NULL;
 	port->ops = &ulite_ops;
 	port->irq = irq;
-- 
1.9.1
