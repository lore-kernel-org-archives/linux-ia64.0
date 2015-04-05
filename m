From: Joe Perches <joe@perches.com>
Date: Sun, 05 Apr 2015 18:24:54 +0000
Subject: [PATCH V2] tty: serial: Add const to struct uart_ops declarations
Message-Id: <1428258294.2775.69.camel@perches.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1428169665.2775.53.camel@perches.com>
	 <a938a0e86638588e5ccff85771fa3b95@agner.ch>
In-Reply-To: <a938a0e86638588e5ccff85771fa3b95@agner.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Stefan Agner <stefan@agner.ch>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jiri Slaby <jslaby@suse.cz>, linux-ia64@vger.kernel.org, kernel@stlinux.com, Nicolas Ferre <nicolas.ferre@atmel.com>, Timur Tabi <timur@tabi.org>, linux-kernel@vger.kernel.org, Pat Gefre <pfg@sgi.com>, Laxman Dewangan <ldewangan@nvidia.com>, "Maciej W. Rozycki" <macro@linux-mips.org>, Daniel Walker <dwalker@fifo99.com>, sparclinux@vger.kernel.org, Peter Korsgaard <jacmet@sunsite.dk>, Sonic Zhang <sonic.zhang@analog.com>, Alexandre Courbot <gnurou@gmail.com>, Russell King <linux@arm.linux.org.uk>, Michal Simek <michal.simek@xilinx.com>, linux-arm-kernel@lists.infradead.org, linux-serial@vger.kernel.org, Tobias Klauser <tklauser@distanz.ch>, Stephen Warren <swarren@wwwdotorg.org>, linux-arm-msm@vger.kernel.org, adi-buildroot-devel@lists.sourceforge.net, Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>, linux

These structs can be const, so make them const.

Miscellanea:

o Add static to struct uart_ops declaration in bfin_sport_uart

Signed-off-by: Joe Perches <joe@perches.com>
---
On Sun, 2015-04-05 at 00:04 +0200, Stefan Agner wrote:
> On 2015-04-04 19:47, Joe Perches wrote:
> > Done with:
> > sed -r -i -e 's/\bstruct\s+uart_ops\s+(\w+)\s*=\s*/const struct
> > uart_ops \1 = /g' drivers/tty/serial/*.c
[]
> +++ b/drivers/tty/serial/fsl_lpuart.c
> Something went wrong in this driver, const is twice...

Apologies, thanks for noticing.
The sed was mistakenly done twice on that file.

V2:

o Fix duplicate const in fsl_lpuart.c
o Add static to drivers/tty/serial/bfin_sport_uart.c

Still compiled only x86 and not cross-compiled or tested.

 drivers/tty/serial/21285.c                  | 2 +-
 drivers/tty/serial/altera_jtaguart.c        | 2 +-
 drivers/tty/serial/altera_uart.c            | 2 +-
 drivers/tty/serial/amba-pl010.c             | 2 +-
 drivers/tty/serial/amba-pl011.c             | 2 +-
 drivers/tty/serial/apbuart.c                | 2 +-
 drivers/tty/serial/ar933x_uart.c            | 2 +-
 drivers/tty/serial/arc_uart.c               | 2 +-
 drivers/tty/serial/atmel_serial.c           | 2 +-
 drivers/tty/serial/bcm63xx_uart.c           | 2 +-
 drivers/tty/serial/bfin_sport_uart.c        | 2 +-
 drivers/tty/serial/bfin_uart.c              | 2 +-
 drivers/tty/serial/cpm_uart/cpm_uart_core.c | 2 +-
 drivers/tty/serial/dz.c                     | 2 +-
 drivers/tty/serial/efm32-uart.c             | 2 +-
 drivers/tty/serial/fsl_lpuart.c             | 4 ++--
 drivers/tty/serial/icom.c                   | 2 +-
 drivers/tty/serial/imx.c                    | 2 +-
 drivers/tty/serial/ioc3_serial.c            | 2 +-
 drivers/tty/serial/ioc4_serial.c            | 2 +-
 drivers/tty/serial/ip22zilog.c              | 2 +-
 drivers/tty/serial/jsm/jsm_tty.c            | 2 +-
 drivers/tty/serial/lantiq.c                 | 2 +-
 drivers/tty/serial/lpc32xx_hs.c             | 2 +-
 drivers/tty/serial/m32r_sio.c               | 2 +-
 drivers/tty/serial/max3100.c                | 2 +-
 drivers/tty/serial/men_z135_uart.c          | 2 +-
 drivers/tty/serial/meson_uart.c             | 2 +-
 drivers/tty/serial/mpc52xx_uart.c           | 2 +-
 drivers/tty/serial/mpsc.c                   | 2 +-
 drivers/tty/serial/msm_serial.c             | 2 +-
 drivers/tty/serial/mux.c                    | 2 +-
 drivers/tty/serial/mxs-auart.c              | 2 +-
 drivers/tty/serial/netx-serial.c            | 2 +-
 drivers/tty/serial/nwpserial.c              | 2 +-
 drivers/tty/serial/omap-serial.c            | 2 +-
 drivers/tty/serial/pch_uart.c               | 2 +-
 drivers/tty/serial/pmac_zilog.c             | 2 +-
 drivers/tty/serial/pnx8xxx_uart.c           | 2 +-
 drivers/tty/serial/pxa.c                    | 2 +-
 drivers/tty/serial/sa1100.c                 | 2 +-
 drivers/tty/serial/samsung.c                | 2 +-
 drivers/tty/serial/serial-tegra.c           | 2 +-
 drivers/tty/serial/serial_ks8695.c          | 2 +-
 drivers/tty/serial/serial_txx9.c            | 2 +-
 drivers/tty/serial/sh-sci.c                 | 2 +-
 drivers/tty/serial/sirfsoc_uart.c           | 2 +-
 drivers/tty/serial/sn_console.c             | 2 +-
 drivers/tty/serial/sprd_serial.c            | 2 +-
 drivers/tty/serial/st-asc.c                 | 2 +-
 drivers/tty/serial/sunhv.c                  | 2 +-
 drivers/tty/serial/sunsab.c                 | 2 +-
 drivers/tty/serial/sunsu.c                  | 2 +-
 drivers/tty/serial/sunzilog.c               | 2 +-
 drivers/tty/serial/timbuart.c               | 2 +-
 drivers/tty/serial/uartlite.c               | 2 +-
 drivers/tty/serial/ucc_uart.c               | 2 +-
 drivers/tty/serial/vr41xx_siu.c             | 2 +-
 drivers/tty/serial/vt8500_serial.c          | 2 +-
 drivers/tty/serial/xilinx_uartps.c          | 2 +-
 drivers/tty/serial/zs.c                     | 2 +-
 61 files changed, 62 insertions(+), 62 deletions(-)

diff --git a/drivers/tty/serial/21285.c b/drivers/tty/serial/21285.c
index 9b208bd..804632b 100644
--- a/drivers/tty/serial/21285.c
+++ b/drivers/tty/serial/21285.c
@@ -334,7 +334,7 @@ static int serial21285_verify_port(struct uart_port *port, struct serial_struct
 	return ret;
 }
 
-static struct uart_ops serial21285_ops = {
+static const struct uart_ops serial21285_ops = {
 	.tx_empty	= serial21285_tx_empty,
 	.get_mctrl	= serial21285_get_mctrl,
 	.set_mctrl	= serial21285_set_mctrl,
diff --git a/drivers/tty/serial/altera_jtaguart.c b/drivers/tty/serial/altera_jtaguart.c
index 0fefdd8..668158a1 100644
--- a/drivers/tty/serial/altera_jtaguart.c
+++ b/drivers/tty/serial/altera_jtaguart.c
@@ -280,7 +280,7 @@ static int altera_jtaguart_verify_port(struct uart_port *port,
 /*
  *	Define the basic serial functions we support.
  */
-static struct uart_ops altera_jtaguart_ops = {
+static const struct uart_ops altera_jtaguart_ops = {
 	.tx_empty	= altera_jtaguart_tx_empty,
 	.get_mctrl	= altera_jtaguart_get_mctrl,
 	.set_mctrl	= altera_jtaguart_set_mctrl,
diff --git a/drivers/tty/serial/altera_uart.c b/drivers/tty/serial/altera_uart.c
index b2859fe..555b090 100644
--- a/drivers/tty/serial/altera_uart.c
+++ b/drivers/tty/serial/altera_uart.c
@@ -404,7 +404,7 @@ static void altera_uart_poll_put_char(struct uart_port *port, unsigned char c)
 /*
  *	Define the basic serial functions we support.
  */
-static struct uart_ops altera_uart_ops = {
+static const struct uart_ops altera_uart_ops = {
 	.tx_empty	= altera_uart_tx_empty,
 	.get_mctrl	= altera_uart_get_mctrl,
 	.set_mctrl	= altera_uart_set_mctrl,
diff --git a/drivers/tty/serial/amba-pl010.c b/drivers/tty/serial/amba-pl010.c
index 5d41d5b..f2f2510 100644
--- a/drivers/tty/serial/amba-pl010.c
+++ b/drivers/tty/serial/amba-pl010.c
@@ -554,7 +554,7 @@ static int pl010_verify_port(struct uart_port *port, struct serial_struct *ser)
 	return ret;
 }
 
-static struct uart_ops amba_pl010_pops = {
+static const struct uart_ops amba_pl010_pops = {
 	.tx_empty	= pl010_tx_empty,
 	.set_mctrl	= pl010_set_mctrl,
 	.get_mctrl	= pl010_get_mctrl,
diff --git a/drivers/tty/serial/amba-pl011.c b/drivers/tty/serial/amba-pl011.c
index 5a4e9d5..0fe3bf6 100644
--- a/drivers/tty/serial/amba-pl011.c
+++ b/drivers/tty/serial/amba-pl011.c
@@ -1948,7 +1948,7 @@ static int pl011_verify_port(struct uart_port *port, struct serial_struct *ser)
 	return ret;
 }
 
-static struct uart_ops amba_pl011_pops = {
+static const struct uart_ops amba_pl011_pops = {
 	.tx_empty	= pl011_tx_empty,
 	.set_mctrl	= pl011_set_mctrl,
 	.get_mctrl	= pl011_get_mctrl,
diff --git a/drivers/tty/serial/apbuart.c b/drivers/tty/serial/apbuart.c
index f3af317..9e13cc2 100644
--- a/drivers/tty/serial/apbuart.c
+++ b/drivers/tty/serial/apbuart.c
@@ -325,7 +325,7 @@ static int apbuart_verify_port(struct uart_port *port,
 	return ret;
 }
 
-static struct uart_ops grlib_apbuart_ops = {
+static const struct uart_ops grlib_apbuart_ops = {
 	.tx_empty = apbuart_tx_empty,
 	.set_mctrl = apbuart_set_mctrl,
 	.get_mctrl = apbuart_get_mctrl,
diff --git a/drivers/tty/serial/ar933x_uart.c b/drivers/tty/serial/ar933x_uart.c
index 1519d2c..921dc9e 100644
--- a/drivers/tty/serial/ar933x_uart.c
+++ b/drivers/tty/serial/ar933x_uart.c
@@ -493,7 +493,7 @@ static int ar933x_uart_verify_port(struct uart_port *port,
 	return 0;
 }
 
-static struct uart_ops ar933x_uart_ops = {
+static const struct uart_ops ar933x_uart_ops = {
 	.tx_empty	= ar933x_uart_tx_empty,
 	.set_mctrl	= ar933x_uart_set_mctrl,
 	.get_mctrl	= ar933x_uart_get_mctrl,
diff --git a/drivers/tty/serial/arc_uart.c b/drivers/tty/serial/arc_uart.c
index 03ebe40..2ceda0a 100644
--- a/drivers/tty/serial/arc_uart.c
+++ b/drivers/tty/serial/arc_uart.c
@@ -464,7 +464,7 @@ static int arc_serial_poll_getchar(struct uart_port *port)
 }
 #endif
 
-static struct uart_ops arc_serial_pops = {
+static const struct uart_ops arc_serial_pops = {
 	.tx_empty	= arc_serial_tx_empty,
 	.set_mctrl	= arc_serial_set_mctrl,
 	.get_mctrl	= arc_serial_get_mctrl,
diff --git a/drivers/tty/serial/atmel_serial.c b/drivers/tty/serial/atmel_serial.c
index d58fe47..5ba2184 100644
--- a/drivers/tty/serial/atmel_serial.c
+++ b/drivers/tty/serial/atmel_serial.c
@@ -2223,7 +2223,7 @@ static void atmel_poll_put_char(struct uart_port *port, unsigned char ch)
 }
 #endif
 
-static struct uart_ops atmel_pops = {
+static const struct uart_ops atmel_pops = {
 	.tx_empty	= atmel_tx_empty,
 	.set_mctrl	= atmel_set_mctrl,
 	.get_mctrl	= atmel_get_mctrl,
diff --git a/drivers/tty/serial/bcm63xx_uart.c b/drivers/tty/serial/bcm63xx_uart.c
index 681e0f3..6dd3431 100644
--- a/drivers/tty/serial/bcm63xx_uart.c
+++ b/drivers/tty/serial/bcm63xx_uart.c
@@ -631,7 +631,7 @@ static int bcm_uart_verify_port(struct uart_port *port,
 }
 
 /* serial core callbacks */
-static struct uart_ops bcm_uart_ops = {
+static const struct uart_ops bcm_uart_ops = {
 	.tx_empty	= bcm_uart_tx_empty,
 	.get_mctrl	= bcm_uart_get_mctrl,
 	.set_mctrl	= bcm_uart_set_mctrl,
diff --git a/drivers/tty/serial/bfin_sport_uart.c b/drivers/tty/serial/bfin_sport_uart.c
index 984e1c0..cafa2ce 100644
--- a/drivers/tty/serial/bfin_sport_uart.c
+++ b/drivers/tty/serial/bfin_sport_uart.c
@@ -584,7 +584,7 @@ static void sport_set_termios(struct uart_port *port,
 	spin_unlock_irqrestore(&up->port.lock, flags);
 }
 
-struct uart_ops sport_uart_ops = {
+static const struct uart_ops sport_uart_ops = {
 	.tx_empty	= sport_tx_empty,
 	.set_mctrl	= sport_set_mctrl,
 	.get_mctrl	= sport_get_mctrl,
diff --git a/drivers/tty/serial/bfin_uart.c b/drivers/tty/serial/bfin_uart.c
index 155781e..28fb2c9 100644
--- a/drivers/tty/serial/bfin_uart.c
+++ b/drivers/tty/serial/bfin_uart.c
@@ -1010,7 +1010,7 @@ static int bfin_serial_poll_get_char(struct uart_port *port)
 }
 #endif
 
-static struct uart_ops bfin_serial_pops = {
+static const struct uart_ops bfin_serial_pops = {
 	.tx_empty	= bfin_serial_tx_empty,
 	.set_mctrl	= bfin_serial_set_mctrl,
 	.get_mctrl	= bfin_serial_get_mctrl,
diff --git a/drivers/tty/serial/cpm_uart/cpm_uart_core.c b/drivers/tty/serial/cpm_uart/cpm_uart_core.c
index 08431ad..aa6783f 100644
--- a/drivers/tty/serial/cpm_uart/cpm_uart_core.c
+++ b/drivers/tty/serial/cpm_uart/cpm_uart_core.c
@@ -1123,7 +1123,7 @@ static void cpm_put_poll_char(struct uart_port *port,
 }
 #endif /* CONFIG_CONSOLE_POLL */
 
-static struct uart_ops cpm_uart_pops = {
+static const struct uart_ops cpm_uart_pops = {
 	.tx_empty	= cpm_uart_tx_empty,
 	.set_mctrl	= cpm_uart_set_mctrl,
 	.get_mctrl	= cpm_uart_get_mctrl,
diff --git a/drivers/tty/serial/dz.c b/drivers/tty/serial/dz.c
index c121f16..ff465ff 100644
--- a/drivers/tty/serial/dz.c
+++ b/drivers/tty/serial/dz.c
@@ -739,7 +739,7 @@ static int dz_verify_port(struct uart_port *uport, struct serial_struct *ser)
 	return ret;
 }
 
-static struct uart_ops dz_ops = {
+static const struct uart_ops dz_ops = {
 	.tx_empty	= dz_tx_empty,
 	.get_mctrl	= dz_get_mctrl,
 	.set_mctrl	= dz_set_mctrl,
diff --git a/drivers/tty/serial/efm32-uart.c b/drivers/tty/serial/efm32-uart.c
index 195acc8..ebd8569 100644
--- a/drivers/tty/serial/efm32-uart.c
+++ b/drivers/tty/serial/efm32-uart.c
@@ -487,7 +487,7 @@ static int efm32_uart_verify_port(struct uart_port *port,
 	return ret;
 }
 
-static struct uart_ops efm32_uart_pops = {
+static const struct uart_ops efm32_uart_pops = {
 	.tx_empty = efm32_uart_tx_empty,
 	.set_mctrl = efm32_uart_set_mctrl,
 	.get_mctrl = efm32_uart_get_mctrl,
diff --git a/drivers/tty/serial/fsl_lpuart.c b/drivers/tty/serial/fsl_lpuart.c
index 08ce76f..083940a 100644
--- a/drivers/tty/serial/fsl_lpuart.c
+++ b/drivers/tty/serial/fsl_lpuart.c
@@ -1494,7 +1494,7 @@ static int lpuart_verify_port(struct uart_port *port, struct serial_struct *ser)
 	return ret;
 }
 
-static struct uart_ops lpuart_pops = {
+static const struct uart_ops lpuart_pops = {
 	.tx_empty	= lpuart_tx_empty,
 	.set_mctrl	= lpuart_set_mctrl,
 	.get_mctrl	= lpuart_get_mctrl,
@@ -1513,7 +1513,7 @@ static struct uart_ops lpuart_pops = {
 	.flush_buffer	= lpuart_flush_buffer,
 };
 
-static struct uart_ops lpuart32_pops = {
+static const struct uart_ops lpuart32_pops = {
 	.tx_empty	= lpuart32_tx_empty,
 	.set_mctrl	= lpuart32_set_mctrl,
 	.get_mctrl	= lpuart32_get_mctrl,
diff --git a/drivers/tty/serial/icom.c b/drivers/tty/serial/icom.c
index 45fc323..3915443 100644
--- a/drivers/tty/serial/icom.c
+++ b/drivers/tty/serial/icom.c
@@ -1287,7 +1287,7 @@ static void icom_config_port(struct uart_port *port, int flags)
 	port->type = PORT_ICOM;
 }
 
-static struct uart_ops icom_ops = {
+static const struct uart_ops icom_ops = {
 	.tx_empty = icom_tx_empty,
 	.set_mctrl = icom_set_mctrl,
 	.get_mctrl = icom_get_mctrl,
diff --git a/drivers/tty/serial/imx.c b/drivers/tty/serial/imx.c
index c8cfa06..64956b7 100644
--- a/drivers/tty/serial/imx.c
+++ b/drivers/tty/serial/imx.c
@@ -1570,7 +1570,7 @@ static int imx_rs485_config(struct uart_port *port,
 	return 0;
 }
 
-static struct uart_ops imx_pops = {
+static const struct uart_ops imx_pops = {
 	.tx_empty	= imx_tx_empty,
 	.set_mctrl	= imx_set_mctrl,
 	.get_mctrl	= imx_get_mctrl,
diff --git a/drivers/tty/serial/ioc3_serial.c b/drivers/tty/serial/ioc3_serial.c
index abd7ea2..2a412c8 100644
--- a/drivers/tty/serial/ioc3_serial.c
+++ b/drivers/tty/serial/ioc3_serial.c
@@ -1873,7 +1873,7 @@ static int ic3_request_port(struct uart_port *port)
 }
 
 /* Associate the uart functions above - given to serial core */
-static struct uart_ops ioc3_ops = {
+static const struct uart_ops ioc3_ops = {
 	.tx_empty = ic3_tx_empty,
 	.set_mctrl = ic3_set_mctrl,
 	.get_mctrl = ic3_get_mctrl,
diff --git a/drivers/tty/serial/ioc4_serial.c b/drivers/tty/serial/ioc4_serial.c
index aa28209..e8ed149 100644
--- a/drivers/tty/serial/ioc4_serial.c
+++ b/drivers/tty/serial/ioc4_serial.c
@@ -2590,7 +2590,7 @@ static int ic4_request_port(struct uart_port *port)
 
 /* Associate the uart functions above - given to serial core */
 
-static struct uart_ops ioc4_ops = {
+static const struct uart_ops ioc4_ops = {
 	.tx_empty	= ic4_tx_empty,
 	.set_mctrl	= ic4_set_mctrl,
 	.get_mctrl	= ic4_get_mctrl,
diff --git a/drivers/tty/serial/ip22zilog.c b/drivers/tty/serial/ip22zilog.c
index 991e6dc..7ddddb4 100644
--- a/drivers/tty/serial/ip22zilog.c
+++ b/drivers/tty/serial/ip22zilog.c
@@ -930,7 +930,7 @@ static int ip22zilog_verify_port(struct uart_port *port, struct serial_struct *s
 	return -EINVAL;
 }
 
-static struct uart_ops ip22zilog_pops = {
+static const struct uart_ops ip22zilog_pops = {
 	.tx_empty	=	ip22zilog_tx_empty,
 	.set_mctrl	=	ip22zilog_set_mctrl,
 	.get_mctrl	=	ip22zilog_get_mctrl,
diff --git a/drivers/tty/serial/jsm/jsm_tty.c b/drivers/tty/serial/jsm/jsm_tty.c
index 524e86a..cfc6694 100644
--- a/drivers/tty/serial/jsm/jsm_tty.c
+++ b/drivers/tty/serial/jsm/jsm_tty.c
@@ -346,7 +346,7 @@ static void jsm_config_port(struct uart_port *port, int flags)
 	port->type = PORT_JSM;
 }
 
-static struct uart_ops jsm_ops = {
+static const struct uart_ops jsm_ops = {
 	.tx_empty	= jsm_tty_tx_empty,
 	.set_mctrl	= jsm_tty_set_mctrl,
 	.get_mctrl	= jsm_tty_get_mctrl,
diff --git a/drivers/tty/serial/lantiq.c b/drivers/tty/serial/lantiq.c
index 4ccc039..83652fd 100644
--- a/drivers/tty/serial/lantiq.c
+++ b/drivers/tty/serial/lantiq.c
@@ -558,7 +558,7 @@ lqasc_verify_port(struct uart_port *port,
 	return ret;
 }
 
-static struct uart_ops lqasc_pops = {
+static const struct uart_ops lqasc_pops = {
 	.tx_empty =	lqasc_tx_empty,
 	.set_mctrl =	lqasc_set_mctrl,
 	.get_mctrl =	lqasc_get_mctrl,
diff --git a/drivers/tty/serial/lpc32xx_hs.c b/drivers/tty/serial/lpc32xx_hs.c
index e92d7eb..c972321 100644
--- a/drivers/tty/serial/lpc32xx_hs.c
+++ b/drivers/tty/serial/lpc32xx_hs.c
@@ -645,7 +645,7 @@ static int serial_lpc32xx_verify_port(struct uart_port *port,
 	return ret;
 }
 
-static struct uart_ops serial_lpc32xx_pops = {
+static const struct uart_ops serial_lpc32xx_pops = {
 	.tx_empty	= serial_lpc32xx_tx_empty,
 	.set_mctrl	= serial_lpc32xx_set_mctrl,
 	.get_mctrl	= serial_lpc32xx_get_mctrl,
diff --git a/drivers/tty/serial/m32r_sio.c b/drivers/tty/serial/m32r_sio.c
index 8f7f83a..c81c87a 100644
--- a/drivers/tty/serial/m32r_sio.c
+++ b/drivers/tty/serial/m32r_sio.c
@@ -920,7 +920,7 @@ m32r_sio_verify_port(struct uart_port *port, struct serial_struct *ser)
 	return 0;
 }
 
-static struct uart_ops m32r_sio_pops = {
+static const struct uart_ops m32r_sio_pops = {
 	.tx_empty	= m32r_sio_tx_empty,
 	.set_mctrl	= m32r_sio_set_mctrl,
 	.get_mctrl	= m32r_sio_get_mctrl,
diff --git a/drivers/tty/serial/max3100.c b/drivers/tty/serial/max3100.c
index 0773772..8444ca3 100644
--- a/drivers/tty/serial/max3100.c
+++ b/drivers/tty/serial/max3100.c
@@ -712,7 +712,7 @@ static void max3100_break_ctl(struct uart_port *port, int break_state)
 	dev_dbg(&s->spi->dev, "%s\n", __func__);
 }
 
-static struct uart_ops max3100_ops = {
+static const struct uart_ops max3100_ops = {
 	.tx_empty	= max3100_tx_empty,
 	.set_mctrl	= max3100_set_mctrl,
 	.get_mctrl	= max3100_get_mctrl,
diff --git a/drivers/tty/serial/men_z135_uart.c b/drivers/tty/serial/men_z135_uart.c
index 35c5550..af4e236 100644
--- a/drivers/tty/serial/men_z135_uart.c
+++ b/drivers/tty/serial/men_z135_uart.c
@@ -769,7 +769,7 @@ static int men_z135_verify_port(struct uart_port *port,
 	return -EINVAL;
 }
 
-static struct uart_ops men_z135_ops = {
+static const struct uart_ops men_z135_ops = {
 	.tx_empty = men_z135_tx_empty,
 	.set_mctrl = men_z135_set_mctrl,
 	.get_mctrl = men_z135_get_mctrl,
diff --git a/drivers/tty/serial/meson_uart.c b/drivers/tty/serial/meson_uart.c
index 67c0367..05b60c2 100644
--- a/drivers/tty/serial/meson_uart.c
+++ b/drivers/tty/serial/meson_uart.c
@@ -413,7 +413,7 @@ static void meson_uart_config_port(struct uart_port *port, int flags)
 	}
 }
 
-static struct uart_ops meson_uart_ops = {
+static const struct uart_ops meson_uart_ops = {
 	.set_mctrl      = meson_uart_set_mctrl,
 	.get_mctrl      = meson_uart_get_mctrl,
 	.tx_empty	= meson_uart_tx_empty,
diff --git a/drivers/tty/serial/mpc52xx_uart.c b/drivers/tty/serial/mpc52xx_uart.c
index 1589f17..8a08d38 100644
--- a/drivers/tty/serial/mpc52xx_uart.c
+++ b/drivers/tty/serial/mpc52xx_uart.c
@@ -1339,7 +1339,7 @@ mpc52xx_uart_verify_port(struct uart_port *port, struct serial_struct *ser)
 }
 
 
-static struct uart_ops mpc52xx_uart_ops = {
+static const struct uart_ops mpc52xx_uart_ops = {
 	.tx_empty	= mpc52xx_uart_tx_empty,
 	.set_mctrl	= mpc52xx_uart_set_mctrl,
 	.get_mctrl	= mpc52xx_uart_get_mctrl,
diff --git a/drivers/tty/serial/mpsc.c b/drivers/tty/serial/mpsc.c
index 856fd5a..ab17caf 100644
--- a/drivers/tty/serial/mpsc.c
+++ b/drivers/tty/serial/mpsc.c
@@ -1676,7 +1676,7 @@ static void mpsc_put_poll_char(struct uart_port *port,
 }
 #endif
 
-static struct uart_ops mpsc_pops = {
+static const struct uart_ops mpsc_pops = {
 	.tx_empty	= mpsc_tx_empty,
 	.set_mctrl	= mpsc_set_mctrl,
 	.get_mctrl	= mpsc_get_mctrl,
diff --git a/drivers/tty/serial/msm_serial.c b/drivers/tty/serial/msm_serial.c
index b73889c..de20c8f 100644
--- a/drivers/tty/serial/msm_serial.c
+++ b/drivers/tty/serial/msm_serial.c
@@ -783,7 +783,7 @@ static void msm_poll_put_char(struct uart_port *port, unsigned char c)
 }
 #endif
 
-static struct uart_ops msm_uart_pops = {
+static const struct uart_ops msm_uart_pops = {
 	.tx_empty = msm_tx_empty,
 	.set_mctrl = msm_set_mctrl,
 	.get_mctrl = msm_get_mctrl,
diff --git a/drivers/tty/serial/mux.c b/drivers/tty/serial/mux.c
index dd26511..b1b9c11 100644
--- a/drivers/tty/serial/mux.c
+++ b/drivers/tty/serial/mux.c
@@ -432,7 +432,7 @@ static struct console mux_console = {
 #define MUX_CONSOLE	NULL
 #endif
 
-static struct uart_ops mux_pops = {
+static const struct uart_ops mux_pops = {
 	.tx_empty =		mux_tx_empty,
 	.set_mctrl =		mux_set_mctrl,
 	.get_mctrl =		mux_get_mctrl,
diff --git a/drivers/tty/serial/mxs-auart.c b/drivers/tty/serial/mxs-auart.c
index f7e5825..2b61518 100644
--- a/drivers/tty/serial/mxs-auart.c
+++ b/drivers/tty/serial/mxs-auart.c
@@ -948,7 +948,7 @@ static void mxs_auart_break_ctl(struct uart_port *u, int ctl)
 			     u->membase + AUART_LINECTRL_CLR);
 }
 
-static struct uart_ops mxs_auart_ops = {
+static const struct uart_ops mxs_auart_ops = {
 	.tx_empty       = mxs_auart_tx_empty,
 	.start_tx       = mxs_auart_start_tx,
 	.stop_tx	= mxs_auart_stop_tx,
diff --git a/drivers/tty/serial/netx-serial.c b/drivers/tty/serial/netx-serial.c
index 207a0a0..b75f132 100644
--- a/drivers/tty/serial/netx-serial.c
+++ b/drivers/tty/serial/netx-serial.c
@@ -462,7 +462,7 @@ netx_verify_port(struct uart_port *port, struct serial_struct *ser)
 	return ret;
 }
 
-static struct uart_ops netx_pops = {
+static const struct uart_ops netx_pops = {
 	.tx_empty	= netx_tx_empty,
 	.set_mctrl	= netx_set_mctrl,
 	.get_mctrl	= netx_get_mctrl,
diff --git a/drivers/tty/serial/nwpserial.c b/drivers/tty/serial/nwpserial.c
index 5da7622..112b899 100644
--- a/drivers/tty/serial/nwpserial.c
+++ b/drivers/tty/serial/nwpserial.c
@@ -304,7 +304,7 @@ static unsigned int nwpserial_tx_empty(struct uart_port *port)
 	return ret & UART_LSR_TEMT ? TIOCSER_TEMT : 0;
 }
 
-static struct uart_ops nwpserial_pops = {
+static const struct uart_ops nwpserial_pops = {
 	.tx_empty     = nwpserial_tx_empty,
 	.set_mctrl    = nwpserial_set_mctrl,
 	.get_mctrl    = nwpserial_get_mctrl,
diff --git a/drivers/tty/serial/omap-serial.c b/drivers/tty/serial/omap-serial.c
index 211479a..554897a 100644
--- a/drivers/tty/serial/omap-serial.c
+++ b/drivers/tty/serial/omap-serial.c
@@ -1416,7 +1416,7 @@ serial_omap_config_rs485(struct uart_port *port, struct serial_rs485 *rs485conf)
 	return 0;
 }
 
-static struct uart_ops serial_omap_pops = {
+static const struct uart_ops serial_omap_pops = {
 	.tx_empty	= serial_omap_tx_empty,
 	.set_mctrl	= serial_omap_set_mctrl,
 	.get_mctrl	= serial_omap_get_mctrl,
diff --git a/drivers/tty/serial/pch_uart.c b/drivers/tty/serial/pch_uart.c
index ea4ffc2..b5874d1 100644
--- a/drivers/tty/serial/pch_uart.c
+++ b/drivers/tty/serial/pch_uart.c
@@ -1603,7 +1603,7 @@ static void pch_uart_put_poll_char(struct uart_port *port,
 }
 #endif /* CONFIG_CONSOLE_POLL */
 
-static struct uart_ops pch_uart_ops = {
+static const struct uart_ops pch_uart_ops = {
 	.tx_empty = pch_uart_tx_empty,
 	.set_mctrl = pch_uart_set_mctrl,
 	.get_mctrl = pch_uart_get_mctrl,
diff --git a/drivers/tty/serial/pmac_zilog.c b/drivers/tty/serial/pmac_zilog.c
index e156e39..4f908a3 100644
--- a/drivers/tty/serial/pmac_zilog.c
+++ b/drivers/tty/serial/pmac_zilog.c
@@ -1379,7 +1379,7 @@ static void pmz_poll_put_char(struct uart_port *port, unsigned char c)
 
 #endif /* CONFIG_CONSOLE_POLL */
 
-static struct uart_ops pmz_pops = {
+static const struct uart_ops pmz_pops = {
 	.tx_empty	=	pmz_tx_empty,
 	.set_mctrl	=	pmz_set_mctrl,
 	.get_mctrl	=	pmz_get_mctrl,
diff --git a/drivers/tty/serial/pnx8xxx_uart.c b/drivers/tty/serial/pnx8xxx_uart.c
index 7a3bb9c..dab2668 100644
--- a/drivers/tty/serial/pnx8xxx_uart.c
+++ b/drivers/tty/serial/pnx8xxx_uart.c
@@ -631,7 +631,7 @@ pnx8xxx_verify_port(struct uart_port *port, struct serial_struct *ser)
 	return ret;
 }
 
-static struct uart_ops pnx8xxx_pops = {
+static const struct uart_ops pnx8xxx_pops = {
 	.tx_empty	= pnx8xxx_tx_empty,
 	.set_mctrl	= pnx8xxx_set_mctrl,
 	.get_mctrl	= pnx8xxx_get_mctrl,
diff --git a/drivers/tty/serial/pxa.c b/drivers/tty/serial/pxa.c
index 9becba6..bd85c6f 100644
--- a/drivers/tty/serial/pxa.c
+++ b/drivers/tty/serial/pxa.c
@@ -763,7 +763,7 @@ static struct console serial_pxa_console = {
 #define PXA_CONSOLE	NULL
 #endif
 
-static struct uart_ops serial_pxa_pops = {
+static const struct uart_ops serial_pxa_pops = {
 	.tx_empty	= serial_pxa_tx_empty,
 	.set_mctrl	= serial_pxa_set_mctrl,
 	.get_mctrl	= serial_pxa_get_mctrl,
diff --git a/drivers/tty/serial/sa1100.c b/drivers/tty/serial/sa1100.c
index fd3d132..e9cfd45 100644
--- a/drivers/tty/serial/sa1100.c
+++ b/drivers/tty/serial/sa1100.c
@@ -592,7 +592,7 @@ sa1100_verify_port(struct uart_port *port, struct serial_struct *ser)
 	return ret;
 }
 
-static struct uart_ops sa1100_pops = {
+static const struct uart_ops sa1100_pops = {
 	.tx_empty	= sa1100_tx_empty,
 	.set_mctrl	= sa1100_set_mctrl,
 	.get_mctrl	= sa1100_get_mctrl,
diff --git a/drivers/tty/serial/samsung.c b/drivers/tty/serial/samsung.c
index cf08876..e172544 100644
--- a/drivers/tty/serial/samsung.c
+++ b/drivers/tty/serial/samsung.c
@@ -1470,7 +1470,7 @@ static void s3c24xx_serial_put_poll_char(struct uart_port *port,
 			 unsigned char c);
 #endif
 
-static struct uart_ops s3c24xx_serial_ops = {
+static const struct uart_ops s3c24xx_serial_ops = {
 	.pm		= s3c24xx_serial_pm,
 	.tx_empty	= s3c24xx_serial_tx_empty,
 	.get_mctrl	= s3c24xx_serial_get_mctrl,
diff --git a/drivers/tty/serial/serial-tegra.c b/drivers/tty/serial/serial-tegra.c
index 1d5ea39..e3a0c49 100644
--- a/drivers/tty/serial/serial-tegra.c
+++ b/drivers/tty/serial/serial-tegra.c
@@ -1195,7 +1195,7 @@ static const char *tegra_uart_type(struct uart_port *u)
 	return TEGRA_UART_TYPE;
 }
 
-static struct uart_ops tegra_uart_ops = {
+static const struct uart_ops tegra_uart_ops = {
 	.tx_empty	= tegra_uart_tx_empty,
 	.set_mctrl	= tegra_uart_set_mctrl,
 	.get_mctrl	= tegra_uart_get_mctrl,
diff --git a/drivers/tty/serial/serial_ks8695.c b/drivers/tty/serial/serial_ks8695.c
index 5c79bda..72b540b 100644
--- a/drivers/tty/serial/serial_ks8695.c
+++ b/drivers/tty/serial/serial_ks8695.c
@@ -526,7 +526,7 @@ static int ks8695uart_verify_port(struct uart_port *port, struct serial_struct *
 	return ret;
 }
 
-static struct uart_ops ks8695uart_pops = {
+static const struct uart_ops ks8695uart_pops = {
 	.tx_empty	= ks8695uart_tx_empty,
 	.set_mctrl	= ks8695uart_set_mctrl,
 	.get_mctrl	= ks8695uart_get_mctrl,
diff --git a/drivers/tty/serial/serial_txx9.c b/drivers/tty/serial/serial_txx9.c
index f80312e..f80fead 100644
--- a/drivers/tty/serial/serial_txx9.c
+++ b/drivers/tty/serial/serial_txx9.c
@@ -845,7 +845,7 @@ serial_txx9_type(struct uart_port *port)
 	return "txx9";
 }
 
-static struct uart_ops serial_txx9_pops = {
+static const struct uart_ops serial_txx9_pops = {
 	.tx_empty	= serial_txx9_tx_empty,
 	.set_mctrl	= serial_txx9_set_mctrl,
 	.get_mctrl	= serial_txx9_get_mctrl,
diff --git a/drivers/tty/serial/sh-sci.c b/drivers/tty/serial/sh-sci.c
index e7d6566..0b0c76d 100644
--- a/drivers/tty/serial/sh-sci.c
+++ b/drivers/tty/serial/sh-sci.c
@@ -2163,7 +2163,7 @@ static int sci_verify_port(struct uart_port *port, struct serial_struct *ser)
 	return 0;
 }
 
-static struct uart_ops sci_uart_ops = {
+static const struct uart_ops sci_uart_ops = {
 	.tx_empty	= sci_tx_empty,
 	.set_mctrl	= sci_set_mctrl,
 	.get_mctrl	= sci_get_mctrl,
diff --git a/drivers/tty/serial/sirfsoc_uart.c b/drivers/tty/serial/sirfsoc_uart.c
index 9de3eab..69cca0a 100644
--- a/drivers/tty/serial/sirfsoc_uart.c
+++ b/drivers/tty/serial/sirfsoc_uart.c
@@ -1169,7 +1169,7 @@ static void sirfsoc_uart_config_port(struct uart_port *port, int flags)
 	}
 }
 
-static struct uart_ops sirfsoc_uart_ops = {
+static const struct uart_ops sirfsoc_uart_ops = {
 	.tx_empty	= sirfsoc_uart_tx_empty,
 	.get_mctrl	= sirfsoc_uart_get_mctrl,
 	.set_mctrl	= sirfsoc_uart_set_mctrl,
diff --git a/drivers/tty/serial/sn_console.c b/drivers/tty/serial/sn_console.c
index 33e94e5..7344a97 100644
--- a/drivers/tty/serial/sn_console.c
+++ b/drivers/tty/serial/sn_console.c
@@ -380,7 +380,7 @@ static void snp_config_port(struct uart_port *port, int flags)
 
 /* Associate the uart functions above - given to serial core */
 
-static struct uart_ops sn_console_ops = {
+static const struct uart_ops sn_console_ops = {
 	.tx_empty = snp_tx_empty,
 	.set_mctrl = snp_set_mctrl,
 	.get_mctrl = snp_get_mctrl,
diff --git a/drivers/tty/serial/sprd_serial.c b/drivers/tty/serial/sprd_serial.c
index 582d272..da0472e 100644
--- a/drivers/tty/serial/sprd_serial.c
+++ b/drivers/tty/serial/sprd_serial.c
@@ -498,7 +498,7 @@ static int sprd_verify_port(struct uart_port *port,
 	return 0;
 }
 
-static struct uart_ops serial_sprd_ops = {
+static const struct uart_ops serial_sprd_ops = {
 	.tx_empty = sprd_tx_empty,
 	.get_mctrl = sprd_get_mctrl,
 	.set_mctrl = sprd_set_mctrl,
diff --git a/drivers/tty/serial/st-asc.c b/drivers/tty/serial/st-asc.c
index d625664..c174c4e 100644
--- a/drivers/tty/serial/st-asc.c
+++ b/drivers/tty/serial/st-asc.c
@@ -639,7 +639,7 @@ static void asc_put_poll_char(struct uart_port *port, unsigned char c)
 
 /*---------------------------------------------------------------------*/
 
-static struct uart_ops asc_uart_ops = {
+static const struct uart_ops asc_uart_ops = {
 	.tx_empty	= asc_tx_empty,
 	.set_mctrl	= asc_set_mctrl,
 	.get_mctrl	= asc_get_mctrl,
diff --git a/drivers/tty/serial/sunhv.c b/drivers/tty/serial/sunhv.c
index 5347544..064d754 100644
--- a/drivers/tty/serial/sunhv.c
+++ b/drivers/tty/serial/sunhv.c
@@ -369,7 +369,7 @@ static int sunhv_verify_port(struct uart_port *port, struct serial_struct *ser)
 	return -EINVAL;
 }
 
-static struct uart_ops sunhv_pops = {
+static const struct uart_ops sunhv_pops = {
 	.tx_empty	= sunhv_tx_empty,
 	.set_mctrl	= sunhv_set_mctrl,
 	.get_mctrl	= sunhv_get_mctrl,
diff --git a/drivers/tty/serial/sunsab.c b/drivers/tty/serial/sunsab.c
index b5e3195..653a076 100644
--- a/drivers/tty/serial/sunsab.c
+++ b/drivers/tty/serial/sunsab.c
@@ -819,7 +819,7 @@ static int sunsab_verify_port(struct uart_port *port, struct serial_struct *ser)
 	return -EINVAL;
 }
 
-static struct uart_ops sunsab_pops = {
+static const struct uart_ops sunsab_pops = {
 	.tx_empty	= sunsab_tx_empty,
 	.set_mctrl	= sunsab_set_mctrl,
 	.get_mctrl	= sunsab_get_mctrl,
diff --git a/drivers/tty/serial/sunsu.c b/drivers/tty/serial/sunsu.c
index e124d2e..29e7b5c 100644
--- a/drivers/tty/serial/sunsu.c
+++ b/drivers/tty/serial/sunsu.c
@@ -958,7 +958,7 @@ sunsu_type(struct uart_port *port)
 	return uart_config[type].name;
 }
 
-static struct uart_ops sunsu_pops = {
+static const struct uart_ops sunsu_pops = {
 	.tx_empty	= sunsu_tx_empty,
 	.set_mctrl	= sunsu_set_mctrl,
 	.get_mctrl	= sunsu_get_mctrl,
diff --git a/drivers/tty/serial/sunzilog.c b/drivers/tty/serial/sunzilog.c
index 8b6ace3..252cea4 100644
--- a/drivers/tty/serial/sunzilog.c
+++ b/drivers/tty/serial/sunzilog.c
@@ -1046,7 +1046,7 @@ static void sunzilog_put_poll_char(struct uart_port *port,
 }
 #endif /* CONFIG_CONSOLE_POLL */
 
-static struct uart_ops sunzilog_pops = {
+static const struct uart_ops sunzilog_pops = {
 	.tx_empty	=	sunzilog_tx_empty,
 	.set_mctrl	=	sunzilog_set_mctrl,
 	.get_mctrl	=	sunzilog_get_mctrl,
diff --git a/drivers/tty/serial/timbuart.c b/drivers/tty/serial/timbuart.c
index 512c162..5da7fe4 100644
--- a/drivers/tty/serial/timbuart.c
+++ b/drivers/tty/serial/timbuart.c
@@ -394,7 +394,7 @@ static int timbuart_verify_port(struct uart_port *port,
 	return -EINVAL;
 }
 
-static struct uart_ops timbuart_ops = {
+static const struct uart_ops timbuart_ops = {
 	.tx_empty = timbuart_tx_empty,
 	.set_mctrl = timbuart_set_mctrl,
 	.get_mctrl = timbuart_get_mctrl,
diff --git a/drivers/tty/serial/uartlite.c b/drivers/tty/serial/uartlite.c
index 708eead..8918c67 100644
--- a/drivers/tty/serial/uartlite.c
+++ b/drivers/tty/serial/uartlite.c
@@ -383,7 +383,7 @@ static void ulite_put_poll_char(struct uart_port *port, unsigned char ch)
 }
 #endif
 
-static struct uart_ops ulite_ops = {
+static const struct uart_ops ulite_ops = {
 	.tx_empty	= ulite_tx_empty,
 	.set_mctrl	= ulite_set_mctrl,
 	.get_mctrl	= ulite_get_mctrl,
diff --git a/drivers/tty/serial/ucc_uart.c b/drivers/tty/serial/ucc_uart.c
index 7d2532b..3539b2a 100644
--- a/drivers/tty/serial/ucc_uart.c
+++ b/drivers/tty/serial/ucc_uart.c
@@ -1085,7 +1085,7 @@ static int qe_uart_verify_port(struct uart_port *port,
  *
  * Details on these functions can be found in Documentation/serial/driver
  */
-static struct uart_ops qe_uart_pops = {
+static const struct uart_ops qe_uart_pops = {
 	.tx_empty       = qe_uart_tx_empty,
 	.set_mctrl      = qe_uart_set_mctrl,
 	.get_mctrl      = qe_uart_get_mctrl,
diff --git a/drivers/tty/serial/vr41xx_siu.c b/drivers/tty/serial/vr41xx_siu.c
index 485de53..439057e 100644
--- a/drivers/tty/serial/vr41xx_siu.c
+++ b/drivers/tty/serial/vr41xx_siu.c
@@ -681,7 +681,7 @@ static int siu_verify_port(struct uart_port *port, struct serial_struct *serial)
 	return 0;
 }
 
-static struct uart_ops siu_uart_ops = {
+static const struct uart_ops siu_uart_ops = {
 	.tx_empty	= siu_tx_empty,
 	.set_mctrl	= siu_set_mctrl,
 	.get_mctrl	= siu_get_mctrl,
diff --git a/drivers/tty/serial/vt8500_serial.c b/drivers/tty/serial/vt8500_serial.c
index 4079ec5..61ba23f 100644
--- a/drivers/tty/serial/vt8500_serial.c
+++ b/drivers/tty/serial/vt8500_serial.c
@@ -593,7 +593,7 @@ static void vt8500_put_poll_char(struct uart_port *port, unsigned char c)
 }
 #endif
 
-static struct uart_ops vt8500_uart_pops = {
+static const struct uart_ops vt8500_uart_pops = {
 	.tx_empty	= vt8500_tx_empty,
 	.set_mctrl	= vt8500_set_mctrl,
 	.get_mctrl	= vt8500_get_mctrl,
diff --git a/drivers/tty/serial/xilinx_uartps.c b/drivers/tty/serial/xilinx_uartps.c
index f218ec6..1dd1356 100644
--- a/drivers/tty/serial/xilinx_uartps.c
+++ b/drivers/tty/serial/xilinx_uartps.c
@@ -991,7 +991,7 @@ static void cdns_uart_poll_put_char(struct uart_port *port, unsigned char c)
 }
 #endif
 
-static struct uart_ops cdns_uart_ops = {
+static const struct uart_ops cdns_uart_ops = {
 	.set_mctrl	= cdns_uart_set_mctrl,
 	.get_mctrl	= cdns_uart_get_mctrl,
 	.start_tx	= cdns_uart_start_tx,
diff --git a/drivers/tty/serial/zs.c b/drivers/tty/serial/zs.c
index 2b65bb7..0ee68bc 100644
--- a/drivers/tty/serial/zs.c
+++ b/drivers/tty/serial/zs.c
@@ -1045,7 +1045,7 @@ static int zs_verify_port(struct uart_port *uport, struct serial_struct *ser)
 }
 
 
-static struct uart_ops zs_ops = {
+static const struct uart_ops zs_ops = {
 	.tx_empty	= zs_tx_empty,
 	.set_mctrl	= zs_set_mctrl,
 	.get_mctrl	= zs_get_mctrl,


