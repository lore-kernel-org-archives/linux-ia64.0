From: "Enrico Weigelt, metux IT consult" <info@metux.net>
Date: Sat, 27 Apr 2019 12:52:18 +0000
Subject: [PATCH 37/41] drivers: tty: serial: 8250: simplify io resource size computation
Message-Id: <1556369542-13247-38-git-send-email-info@metux.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556369542-13247-1-git-send-email-info@metux.net>
In-Reply-To: <1556369542-13247-1-git-send-email-info@metux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: gregkh@linuxfoundation.org, andrew@aj.id.au, andriy.shevchenko@linux.intel.com, macro@linux-mips.org, vz@mleia.com, slemieux.tyco@gmail.com, khilman@baylibre.com, liviu.dudau@arm.com, sudeep.holla@arm.com, lorenzo.pieralisi@arm.com, davem@davemloft.net, jacmet@sunsite.dk, linux@prisktech.co.nz, matthias.bgg@gmail.com, linux-mips@vger.kernel.org, linux-serial@vger.kernel.org, linux-ia64@vger.kernel.org, linux-amlogic@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

Simpily io resource size computation by setting mapsize field.

Some of the special cases handled by serial8250_port_size() can be
simplified by putting this data to corresponding platform data
or probe function.

Signed-off-by: Enrico Weigelt <info@metux.net>
---
 arch/mips/alchemy/common/platform.c | 1 +
 drivers/tty/serial/8250/8250.h      | 1 +
 drivers/tty/serial/8250/8250_of.c   | 1 +
 drivers/tty/serial/8250/8250_port.c | 6 +-----
 4 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/arch/mips/alchemy/common/platform.c b/arch/mips/alchemy/common/platform.c
index 1454d9f..226096d 100644
--- a/arch/mips/alchemy/common/platform.c
+++ b/arch/mips/alchemy/common/platform.c
@@ -51,6 +51,7 @@ static void alchemy_8250_pm(struct uart_port *port, unsigned int state,
 #define PORT(_base, _irq)					\
 	{							\
 		.mapbase	= _base,			\
+		.mapsize	= 0x1000,			\
 		.irq		= _irq,				\
 		.regshift	= 2,				\
 		.iotype		= UPIO_AU,			\
diff --git a/drivers/tty/serial/8250/8250.h b/drivers/tty/serial/8250/8250.h
index 89e3f09..7984aad 100644
--- a/drivers/tty/serial/8250/8250.h
+++ b/drivers/tty/serial/8250/8250.h
@@ -105,6 +105,7 @@ struct serial8250_config {
 
 #define SERIAL8250_PORT(_base, _irq) SERIAL8250_PORT_FLAGS(_base, _irq, 0)
 
+#define SERIAL_RT2880_IOSIZE	0x100
 
 static inline int serial_in(struct uart_8250_port *up, int offset)
 {
diff --git a/drivers/tty/serial/8250/8250_of.c b/drivers/tty/serial/8250/8250_of.c
index 0277479c..08157a1 100644
--- a/drivers/tty/serial/8250/8250_of.c
+++ b/drivers/tty/serial/8250/8250_of.c
@@ -185,6 +185,7 @@ static int of_platform_serial_setup(struct platform_device *ofdev,
 
 	case PORT_RT2880:
 		port->iotype = UPIO_AU;
+		port->mapsize = SERIAL_RT2880_IOSIZE;
 		break;
 	}
 
diff --git a/drivers/tty/serial/8250/8250_port.c b/drivers/tty/serial/8250/8250_port.c
index d09af4c..51d6076 100644
--- a/drivers/tty/serial/8250/8250_port.c
+++ b/drivers/tty/serial/8250/8250_port.c
@@ -2833,11 +2833,7 @@ unsigned int serial8250_port_size(struct uart_8250_port *pt)
 {
 	if (pt->port.mapsize)
 		return pt->port.mapsize;
-	if (pt->port.iotype = UPIO_AU) {
-		if (pt->port.type = PORT_RT2880)
-			return 0x100;
-		return 0x1000;
-	}
+
 	if (is_omap1_8250(pt))
 		return 0x16 << pt->port.regshift;
 
-- 
1.9.1
