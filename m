From: "Enrico Weigelt, metux IT consult" <info@metux.net>
Date: Sat, 27 Apr 2019 12:52:17 +0000
Subject: [PATCH 36/41] drivers: tty: serial: 8250: store mmio resource size in port struct
Message-Id: <1556369542-13247-37-git-send-email-info@metux.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556369542-13247-1-git-send-email-info@metux.net>
In-Reply-To: <1556369542-13247-1-git-send-email-info@metux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: gregkh@linuxfoundation.org, andrew@aj.id.au, andriy.shevchenko@linux.intel.com, macro@linux-mips.org, vz@mleia.com, slemieux.tyco@gmail.com, khilman@baylibre.com, liviu.dudau@arm.com, sudeep.holla@arm.com, lorenzo.pieralisi@arm.com, davem@davemloft.net, jacmet@sunsite.dk, linux@prisktech.co.nz, matthias.bgg@gmail.com, linux-mips@vger.kernel.org, linux-serial@vger.kernel.org, linux-ia64@vger.kernel.org, linux-amlogic@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

The io resource size is currently recomputed when it's needed but this
actually needs to be done once (or drivers could specify fixed values)

Simplify that by doing this computation only once and storing the result
into the mapsize field. serial8250_register_8250_port() is now called
only once on driver init, the previous call sites now just fetch the
value from the mapsize field.

Signed-off-by: Enrico Weigelt <info@metux.net>
---
 drivers/tty/serial/8250/8250.h      |  2 ++
 drivers/tty/serial/8250/8250_core.c |  3 +++
 drivers/tty/serial/8250/8250_port.c | 33 +++++++++++++++------------------
 3 files changed, 20 insertions(+), 18 deletions(-)

diff --git a/drivers/tty/serial/8250/8250.h b/drivers/tty/serial/8250/8250.h
index ebfb0bd..89e3f09 100644
--- a/drivers/tty/serial/8250/8250.h
+++ b/drivers/tty/serial/8250/8250.h
@@ -255,3 +255,5 @@ static inline int serial_index(struct uart_port *port)
 {
 	return port->minor - 64;
 }
+
+unsigned int serial8250_port_size(struct uart_8250_port *pt);
diff --git a/drivers/tty/serial/8250/8250_core.c b/drivers/tty/serial/8250/8250_core.c
index 71a398b..a9d4ba1 100644
--- a/drivers/tty/serial/8250/8250_core.c
+++ b/drivers/tty/serial/8250/8250_core.c
@@ -979,6 +979,9 @@ int serial8250_register_8250_port(struct uart_8250_port *up)
 	if (up->port.uartclk = 0)
 		return -EINVAL;
 
+	/* compute the mapsize in case the driver didn't specify one */
+	up->mapsize = serial8250_port_size(up);
+
 	mutex_lock(&serial_mutex);
 
 	uart = serial8250_find_match_or_unused(&up->port);
diff --git a/drivers/tty/serial/8250/8250_port.c b/drivers/tty/serial/8250/8250_port.c
index d2f3310..d09af4c 100644
--- a/drivers/tty/serial/8250/8250_port.c
+++ b/drivers/tty/serial/8250/8250_port.c
@@ -2829,7 +2829,7 @@ void serial8250_do_pm(struct uart_port *port, unsigned int state,
 		serial8250_do_pm(port, state, oldstate);
 }
 
-static unsigned int serial8250_port_size(struct uart_8250_port *pt)
+unsigned int serial8250_port_size(struct uart_8250_port *pt)
 {
 	if (pt->port.mapsize)
 		return pt->port.mapsize;
@@ -2849,9 +2849,7 @@ static unsigned int serial8250_port_size(struct uart_8250_port *pt)
  */
 static int serial8250_request_std_resource(struct uart_8250_port *up)
 {
-	unsigned int size = serial8250_port_size(up);
 	struct uart_port *port = &up->port;
-	int ret = 0;
 
 	switch (port->iotype) {
 	case UPIO_AU:
@@ -2863,32 +2861,31 @@ static int serial8250_request_std_resource(struct uart_8250_port *up)
 		if (!port->mapbase)
 			break;
 
-		if (!request_mem_region(port->mapbase, size, "serial")) {
-			ret = -EBUSY;
-			break;
-		}
+		if (!request_mem_region(port->mapbase,
+					port->mapsize, "serial"))
+			return -EBUSY;
 
 		if (port->flags & UPF_IOREMAP) {
-			port->membase = ioremap_nocache(port->mapbase, size);
-			if (!port->membase) {
-				release_mem_region(port->mapbase, size);
-				ret = -ENOMEM;
-			}
+			port->membase = ioremap_nocache(port->mapbase,
+							port->mapsize);
+			if (!port->membase)
+				release_mem_region(port->mapbase,
+						   port->mapsize);
+				return -ENOMEM;
 		}
 		break;
 
 	case UPIO_HUB6:
 	case UPIO_PORT:
-		if (!request_region(port->iobase, size, "serial"))
-			ret = -EBUSY;
+		if (!request_region(port->iobase, port->mapsize, "serial"))
+			return -EBUSY;
 		break;
 	}
-	return ret;
+	return 0;
 }
 
 static void serial8250_release_std_resource(struct uart_8250_port *up)
 {
-	unsigned int size = serial8250_port_size(up);
 	struct uart_port *port = &up->port;
 
 	switch (port->iotype) {
@@ -2906,12 +2903,12 @@ static void serial8250_release_std_resource(struct uart_8250_port *up)
 			port->membase = NULL;
 		}
 
-		release_mem_region(port->mapbase, size);
+		release_mem_region(port->mapbase, port->mapsize);
 		break;
 
 	case UPIO_HUB6:
 	case UPIO_PORT:
-		release_region(port->iobase, size);
+		release_region(port->iobase, port->mapsize);
 		break;
 	}
 }
-- 
1.9.1
