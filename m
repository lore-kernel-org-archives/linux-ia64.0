From: "Enrico Weigelt, metux IT consult" <info@metux.net>
Date: Sat, 27 Apr 2019 12:52:22 +0000
Subject: [PATCH 41/41] drivers: tty: serial: lpc32xx_hs: fill mapsize and use it
Message-Id: <1556369542-13247-42-git-send-email-info@metux.net>
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
 drivers/tty/serial/lpc32xx_hs.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/tty/serial/lpc32xx_hs.c b/drivers/tty/serial/lpc32xx_hs.c
index f4e27d0..d1f09aa 100644
--- a/drivers/tty/serial/lpc32xx_hs.c
+++ b/drivers/tty/serial/lpc32xx_hs.c
@@ -579,7 +579,7 @@ static void serial_lpc32xx_release_port(struct uart_port *port)
 			port->membase = NULL;
 		}
 
-		release_mem_region(port->mapbase, SZ_4K);
+		release_mem_region(port->mapbase, port->mapsize);
 	}
 }
 
@@ -590,12 +590,15 @@ static int serial_lpc32xx_request_port(struct uart_port *port)
 	if ((port->iotype = UPIO_MEM32) && (port->mapbase)) {
 		ret = 0;
 
-		if (!request_mem_region(port->mapbase, SZ_4K, MODNAME))
+		if (!request_mem_region(port->mapbase,
+					port->mapsize, MODNAME))
 			ret = -EBUSY;
 		else if (port->flags & UPF_IOREMAP) {
-			port->membase = ioremap(port->mapbase, SZ_4K);
+			port->membase = ioremap(port->mapbase,
+						port->mapsize);
 			if (!port->membase) {
-				release_mem_region(port->mapbase, SZ_4K);
+				release_mem_region(port->mapbase,
+						   port->mapsize);
 				ret = -ENOMEM;
 			}
 		}
@@ -684,6 +687,7 @@ static int serial_hs_lpc32xx_probe(struct platform_device *pdev)
 		return -ENXIO;
 	}
 	p->port.mapbase = res->start;
+	p->port.mapsize = SZ_4K;
 	p->port.membase = NULL;
 
 	ret = platform_get_irq(pdev, 0);
-- 
1.9.1
