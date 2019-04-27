From: "Enrico Weigelt, metux IT consult" <info@metux.net>
Date: Sat, 27 Apr 2019 12:52:20 +0000
Subject: [PATCH 39/41] drivers: tty: serial: pmac_zilog: fill mapsize and use it
Message-Id: <1556369542-13247-40-git-send-email-info@metux.net>
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
 drivers/tty/serial/pmac_zilog.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/tty/serial/pmac_zilog.c b/drivers/tty/serial/pmac_zilog.c
index bcb5bf7..1fef014 100644
--- a/drivers/tty/serial/pmac_zilog.c
+++ b/drivers/tty/serial/pmac_zilog.c
@@ -88,6 +88,8 @@
 #define PMACZILOG_NAME		"ttyPZ"
 #endif
 
+#define PMZ_MAPSIZE		0x1000
+
 #define pmz_debug(fmt, arg...)	pr_debug("ttyPZ%d: " fmt, uap->port.line, ## arg)
 #define pmz_error(fmt, arg...)	pr_err("ttyPZ%d: " fmt, uap->port.line, ## arg)
 #define pmz_info(fmt, arg...)	pr_info("ttyPZ%d: " fmt, uap->port.line, ## arg)
@@ -1411,7 +1413,8 @@ static int __init pmz_init_port(struct uart_pmac_port *uap)
 	if (of_address_to_resource(np, 0, &r_ports))
 		return -ENODEV;
 	uap->port.mapbase = r_ports.start;
-	uap->port.membase = ioremap(uap->port.mapbase, 0x1000);
+	uap->port.mapsize = PMZ_MAPSIZE;
+	uap->port.membase = ioremap(uap->port.mapbase, uap->port.mapsize);
 
 	uap->control_reg = uap->port.membase;
 	uap->data_reg = uap->control_reg + 0x10;
@@ -1709,6 +1712,7 @@ static int __init pmz_init_port(struct uart_pmac_port *uap)
 		return -ENODEV;
 
 	uap->port.mapbase  = r_ports->start;
+	uap->port.mapsize  = PMZ_MAPSIZE;
 	uap->port.membase  = (unsigned char __iomem *) r_ports->start;
 	uap->port.iotype   = UPIO_MEM;
 	uap->port.irq      = irq;
-- 
1.9.1
