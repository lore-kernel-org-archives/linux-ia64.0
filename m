From: "Enrico Weigelt, metux IT consult" <info@metux.net>
Date: Sat, 27 Apr 2019 12:52:13 +0000
Subject: [PATCH 32/41] drivers: tty: serial: 21285: define's for address/size, use mapsize field
Message-Id: <1556369542-13247-33-git-send-email-info@metux.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556369542-13247-1-git-send-email-info@metux.net>
In-Reply-To: <1556369542-13247-1-git-send-email-info@metux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: gregkh@linuxfoundation.org, andrew@aj.id.au, andriy.shevchenko@linux.intel.com, macro@linux-mips.org, vz@mleia.com, slemieux.tyco@gmail.com, khilman@baylibre.com, liviu.dudau@arm.com, sudeep.holla@arm.com, lorenzo.pieralisi@arm.com, davem@davemloft.net, jacmet@sunsite.dk, linux@prisktech.co.nz, matthias.bgg@gmail.com, linux-mips@vger.kernel.org, linux-serial@vger.kernel.org, linux-ia64@vger.kernel.org, linux-amlogic@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

Instead of hardcoding raw numbers, add define's for the mmio address/size.
Also fill the mapsize field and use it on mem request/release calls, for
more consistency and allowing generic helpers to be used later.

Signed-off-by: Enrico Weigelt <info@metux.net>
---
 drivers/tty/serial/21285.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/tty/serial/21285.c b/drivers/tty/serial/21285.c
index 32b3acf..90684cd 100644
--- a/drivers/tty/serial/21285.c
+++ b/drivers/tty/serial/21285.c
@@ -27,6 +27,9 @@
 #define SERIAL_21285_MAJOR	204
 #define SERIAL_21285_MINOR	4
 
+#define SERIAL_21285_ADDRESS	0x42000160
+#define SERIAL_21285_SIZE	32
+
 #define RXSTAT_DUMMY_READ	0x80000000
 #define RXSTAT_FRAME		(1 << 0)
 #define RXSTAT_PARITY		(1 << 1)
@@ -305,12 +308,14 @@ static const char *serial21285_type(struct uart_port *port)
 
 static void serial21285_release_port(struct uart_port *port)
 {
-	release_mem_region(port->mapbase, 32);
+	release_mem_region(port->mapbase, port->mapsize);
 }
 
 static int serial21285_request_port(struct uart_port *port)
 {
-	return request_mem_region(port->mapbase, 32, serial21285_name)
+	return request_mem_region(port->mapbase,
+				  port->mapsize,
+				  serial21285_name)
 			 != NULL ? 0 : -EBUSY;
 }
 
@@ -354,7 +359,8 @@ static int serial21285_verify_port(struct uart_port *port, struct serial_struct
 };
 
 static struct uart_port serial21285_port = {
-	.mapbase	= 0x42000160,
+	.mapbase	= SERIAL_21285_BASE,
+	.mapsize	= SERIAL_21285_SIZE,
 	.iotype		= UPIO_MEM,
 	.irq		= 0,
 	.fifosize	= 16,
-- 
1.9.1
