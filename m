From: Bhumika Goyal <bhumirks@gmail.com>
Date: Wed, 25 Jan 2017 17:49:31 +0000
Subject: [PATCH] tty: serial: constify uart_ops structures
Message-Id: <1485366532-3048-1-git-send-email-bhumirks@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: julia.lawall@lip6.fr, linux@armlinux.org.uk, gregkh@linuxfoundation.org, jslaby@suse.com, macro@linux-mips.org, kernel@pengutronix.de, pfg@sgi.com, vz@mleia.com, slemieux.tyco@gmail.com, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, ldewangan@nvidia.com, wwwdotorg.org@vger.kernel.org, thierry.reding@gmail.com, gnurou@gmail.com, baohua@kernel.org, davem@davemloft.net, linux@prisktech.co.nz, linux-serial@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-tegra@vger.kernel.org, sparclinux@vger.kernel.org
Cc: Bhumika Goyal <bhumirks@gmail.com>

Declare uart_ops structures as const as they are only stored in the ops
field of an uart_port structure. This field is of type const, so
uart_ops structures having this property can be made const too.

File size details before and after patching.
First line of every .o file shows the file size before patching
and second line shows the size after patching.

   text	   data	    bss	    dec	    hex	filename

   2977	    456	     64	   3497	    da9	drivers/tty/serial/amba-pl010.o
   3169	    272	     64	   3505	    db1	drivers/tty/serial/amba-pl010.o

   3109	    456	      0	   3565	    ded	drivers/tty/serial/efm32-uart.o
   3301	    272	      0	   3573	    df5	drivers/tty/serial/efm32-uart.o

  10668	    753	      1	  11422	   2c9e	drivers/tty/serial/icom.o
  10860	    561	      1	  11422	   2c9e	drivers/tty/serial/icom.o

  23904	    408	      8	  24320	   5f00	drivers/tty/serial/ioc3_serial.o
  24088	    224	      8	  24320	   5f00	drivers/tty/serial/ioc3_serial.o

  10516	    560	      4	  11080	   2b48	drivers/tty/serial/ioc4_serial.o
  10709	    368	      4	  11081	   2b49	drivers/tty/serial/ioc4_serial.o

   7853	    648	   1216	   9717	   25f5	drivers/tty/serial/mpsc.o
   8037	    456	   1216	   9709	   25ed	drivers/tty/serial/mpsc.o

  10248	    456	      0	  10704	   29d0	drivers/tty/serial/omap-serial.o
  10440	    272	      0	  10712	   29d8	drivers/tty/serial/omap-serial.o

   8122	    532	   1984	  10638	   298e	drivers/tty/serial/pmac_zilog.o
   8306	    340	   1984	  10630	   2986	drivers/tty/serial/pmac_zilog.o

   3808	    456	      0	   4264	   10a8	drivers/tty/serial/pxa.o
   4000	    264	      0	   4264	   10a8	drivers/tty/serial/pxa.o

  21781	   3864	      0	  25645	   642d	drivers/tty/serial/serial-tegra.o
  22037	   3608	      0	  25645	   642d	drivers/tty/serial/serial-tegra.o

   2481	    456	     96	   3033	    bd9	drivers/tty/serial/sprd_serial.o
   2673	    272	     96	   3041	    be1	drivers/tty/serial/sprd_serial.o

   5534	    300	    512	   6346	   18ca	drivers/tty/serial/vr41xx_siu.o
   5630	    204	    512	   6346	   18ca	drivers/tty/serial/vr41xx_siu.o

   6730	   1576	    128	   8434	   20f2	drivers/tty/serial/vt8500_serial.o
   6986	   1320	    128	   8434	   20f2	drivers/tty/serial/vt8500_serial.o

Cross compiled for mips architecture.

   3005	    488	      0	   3493	    da5	drivers/tty/serial/pnx8xxx_uart.o
   3189	    304	      0	   3493	    da5	drivers/tty/serial/pnx8xxx_uart.o

   4272	    196	   1056	   5524	   1594	drivers/tty/serial/dz.o
   4368	    100	   1056	   5524	   1594	drivers/tty/serial/dz.o

   6551	    144	     16	   6711	   1a37	drivers/tty/serial/ip22zilog.o
   6647	     48	     16	   6711	   1a37	drivers/tty/serial/ip22zilog.o

   9612	    428	   1520	  11560	   2d28	drivers/tty/serial/serial_txx9.o
   9708	    332	   1520	  11560	   2d28	drivers/tty/serial/serial_txx9.o

   4156	    296	     16	   4468	   1174	drivers/tty/serial/ar933x_uart.o
   4252	    200	     16	   4468	   1174	drivers/tty/serial/ar933x_uart.o

Cross compiled for arm archiecture.

  11716	   1780	     44	  13540	   34e4	drivers/tty/serial/sirfsoc_uart.o
  11808	   1688	     44	  13540	   34e4	drivers/tty/serial/sirfsoc_uart.o

  13352	    596	     56	  14004	   36b4	drivers/tty/serial/amba-pl011.o
  13444	    504	     56	  14004	   36b4	drivers/tty/serial/amba-pl011.o

Cross compiled for sparc architecture.

   4664	    528	     32	   5224	   1468	drivers/tty/serial/sunhv.o
   4848	    344	     32	   5224	   1468	drivers/tty/serial/sunhv.o

   8080	    332	     28	   8440	   20f8	drivers/tty/serial/sunzilog.o
   8184	    228	     28	   8440	   20f8	drivers/tty/serial/sunzilog.o

Cross compiled for ia64 architecture.

  10226	    549	    472	  11247	   2bef	drivers/tty/serial/sn_console.o
  10414	    365	    472	  11251	   2bf3	drivers/tty/serial/sn_console.o

The files drivers/tty/serial/zs.o, drivers/tty/serial/lpc32xx_hs.o and
drivers/tty/serial/lantiq.o did not compile.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
 drivers/tty/serial/amba-pl010.c    | 2 +-
 drivers/tty/serial/amba-pl011.c    | 2 +-
 drivers/tty/serial/ar933x_uart.c   | 2 +-
 drivers/tty/serial/dz.c            | 2 +-
 drivers/tty/serial/efm32-uart.c    | 2 +-
 drivers/tty/serial/icom.c          | 2 +-
 drivers/tty/serial/ioc3_serial.c   | 2 +-
 drivers/tty/serial/ioc4_serial.c   | 2 +-
 drivers/tty/serial/ip22zilog.c     | 2 +-
 drivers/tty/serial/lantiq.c        | 2 +-
 drivers/tty/serial/lpc32xx_hs.c    | 2 +-
 drivers/tty/serial/mpsc.c          | 2 +-
 drivers/tty/serial/omap-serial.c   | 2 +-
 drivers/tty/serial/pmac_zilog.c    | 2 +-
 drivers/tty/serial/pnx8xxx_uart.c  | 2 +-
 drivers/tty/serial/pxa.c           | 2 +-
 drivers/tty/serial/serial-tegra.c  | 2 +-
 drivers/tty/serial/serial_txx9.c   | 2 +-
 drivers/tty/serial/sirfsoc_uart.c  | 2 +-
 drivers/tty/serial/sn_console.c    | 2 +-
 drivers/tty/serial/sprd_serial.c   | 2 +-
 drivers/tty/serial/sunhv.c         | 2 +-
 drivers/tty/serial/sunzilog.c      | 2 +-
 drivers/tty/serial/vr41xx_siu.c    | 2 +-
 drivers/tty/serial/vt8500_serial.c | 2 +-
 drivers/tty/serial/zs.c            | 2 +-
 26 files changed, 26 insertions(+), 26 deletions(-)

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
index d4171d7..d3b3f02 100644
--- a/drivers/tty/serial/amba-pl011.c
+++ b/drivers/tty/serial/amba-pl011.c
@@ -2114,7 +2114,7 @@ static int pl011_verify_port(struct uart_port *port, struct serial_struct *ser)
 	return ret;
 }
 
-static struct uart_ops amba_pl011_pops = {
+static const struct uart_ops amba_pl011_pops = {
 	.tx_empty	= pl011_tx_empty,
 	.set_mctrl	= pl011_set_mctrl,
 	.get_mctrl	= pl011_get_mctrl,
diff --git a/drivers/tty/serial/ar933x_uart.c b/drivers/tty/serial/ar933x_uart.c
index 73137f4..decc7f3 100644
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
diff --git a/drivers/tty/serial/icom.c b/drivers/tty/serial/icom.c
index d83783c..fe92d74 100644
--- a/drivers/tty/serial/icom.c
+++ b/drivers/tty/serial/icom.c
@@ -1286,7 +1286,7 @@ static void icom_config_port(struct uart_port *port, int flags)
 	port->type = PORT_ICOM;
 }
 
-static struct uart_ops icom_ops = {
+static const struct uart_ops icom_ops = {
 	.tx_empty = icom_tx_empty,
 	.set_mctrl = icom_set_mctrl,
 	.get_mctrl = icom_get_mctrl,
diff --git a/drivers/tty/serial/ioc3_serial.c b/drivers/tty/serial/ioc3_serial.c
index 27b5fef..2a61dd6 100644
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
index 3be051abb..6ad26f8 100644
--- a/drivers/tty/serial/ioc4_serial.c
+++ b/drivers/tty/serial/ioc4_serial.c
@@ -2596,7 +2596,7 @@ static int ic4_request_port(struct uart_port *port)
 
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
diff --git a/drivers/tty/serial/lantiq.c b/drivers/tty/serial/lantiq.c
index b88832e..d34398e 100644
--- a/drivers/tty/serial/lantiq.c
+++ b/drivers/tty/serial/lantiq.c
@@ -557,7 +557,7 @@ lqasc_verify_port(struct uart_port *port,
 	return ret;
 }
 
-static struct uart_ops lqasc_pops = {
+static const struct uart_ops lqasc_pops = {
 	.tx_empty =	lqasc_tx_empty,
 	.set_mctrl =	lqasc_set_mctrl,
 	.get_mctrl =	lqasc_get_mctrl,
diff --git a/drivers/tty/serial/lpc32xx_hs.c b/drivers/tty/serial/lpc32xx_hs.c
index 7eb04ae..cea57ff 100644
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
diff --git a/drivers/tty/serial/mpsc.c b/drivers/tty/serial/mpsc.c
index 4a3021b..1a60a20 100644
--- a/drivers/tty/serial/mpsc.c
+++ b/drivers/tty/serial/mpsc.c
@@ -1670,7 +1670,7 @@ static void mpsc_put_poll_char(struct uart_port *port,
 }
 #endif
 
-static struct uart_ops mpsc_pops = {
+static const struct uart_ops mpsc_pops = {
 	.tx_empty	= mpsc_tx_empty,
 	.set_mctrl	= mpsc_set_mctrl,
 	.get_mctrl	= mpsc_get_mctrl,
diff --git a/drivers/tty/serial/omap-serial.c b/drivers/tty/serial/omap-serial.c
index a2a5299..96dd99c 100644
--- a/drivers/tty/serial/omap-serial.c
+++ b/drivers/tty/serial/omap-serial.c
@@ -1395,7 +1395,7 @@ serial_omap_config_rs485(struct uart_port *port, struct serial_rs485 *rs485)
 	return 0;
 }
 
-static struct uart_ops serial_omap_pops = {
+static const struct uart_ops serial_omap_pops = {
 	.tx_empty	= serial_omap_tx_empty,
 	.set_mctrl	= serial_omap_set_mctrl,
 	.get_mctrl	= serial_omap_get_mctrl,
diff --git a/drivers/tty/serial/pmac_zilog.c b/drivers/tty/serial/pmac_zilog.c
index b24b055..0da5294 100644
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
index 7595281..905631d 100644
--- a/drivers/tty/serial/pxa.c
+++ b/drivers/tty/serial/pxa.c
@@ -762,7 +762,7 @@ static struct console serial_pxa_console = {
 #define PXA_CONSOLE	NULL
 #endif
 
-static struct uart_ops serial_pxa_pops = {
+static const struct uart_ops serial_pxa_pops = {
 	.tx_empty	= serial_pxa_tx_empty,
 	.set_mctrl	= serial_pxa_set_mctrl,
 	.get_mctrl	= serial_pxa_get_mctrl,
diff --git a/drivers/tty/serial/serial-tegra.c b/drivers/tty/serial/serial-tegra.c
index 731ac35..d92a150 100644
--- a/drivers/tty/serial/serial-tegra.c
+++ b/drivers/tty/serial/serial-tegra.c
@@ -1191,7 +1191,7 @@ static const char *tegra_uart_type(struct uart_port *u)
 	return TEGRA_UART_TYPE;
 }
 
-static struct uart_ops tegra_uart_ops = {
+static const struct uart_ops tegra_uart_ops = {
 	.tx_empty	= tegra_uart_tx_empty,
 	.set_mctrl	= tegra_uart_set_mctrl,
 	.get_mctrl	= tegra_uart_get_mctrl,
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
diff --git a/drivers/tty/serial/sirfsoc_uart.c b/drivers/tty/serial/sirfsoc_uart.c
index b186c9c..e03282d 100644
--- a/drivers/tty/serial/sirfsoc_uart.c
+++ b/drivers/tty/serial/sirfsoc_uart.c
@@ -1061,7 +1061,7 @@ static void sirfsoc_uart_config_port(struct uart_port *port, int flags)
 	}
 }
 
-static struct uart_ops sirfsoc_uart_ops = {
+static const struct uart_ops sirfsoc_uart_ops = {
 	.tx_empty	= sirfsoc_uart_tx_empty,
 	.get_mctrl	= sirfsoc_uart_get_mctrl,
 	.set_mctrl	= sirfsoc_uart_set_mctrl,
diff --git a/drivers/tty/serial/sn_console.c b/drivers/tty/serial/sn_console.c
index d4692d8..9e0e658 100644
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
index 699447a..d98e3dc 100644
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
diff --git a/drivers/tty/serial/sunhv.c b/drivers/tty/serial/sunhv.c
index 99ef5c6..73abd89 100644
--- a/drivers/tty/serial/sunhv.c
+++ b/drivers/tty/serial/sunhv.c
@@ -370,7 +370,7 @@ static int sunhv_verify_port(struct uart_port *port, struct serial_struct *ser)
 	return -EINVAL;
 }
 
-static struct uart_ops sunhv_pops = {
+static const struct uart_ops sunhv_pops = {
 	.tx_empty	= sunhv_tx_empty,
 	.set_mctrl	= sunhv_set_mctrl,
 	.get_mctrl	= sunhv_get_mctrl,
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
index 6b85adc..435a6f3 100644
--- a/drivers/tty/serial/vt8500_serial.c
+++ b/drivers/tty/serial/vt8500_serial.c
@@ -592,7 +592,7 @@ static void vt8500_put_poll_char(struct uart_port *port, unsigned char c)
 }
 #endif
 
-static struct uart_ops vt8500_uart_pops = {
+static const struct uart_ops vt8500_uart_pops = {
 	.tx_empty	= vt8500_tx_empty,
 	.set_mctrl	= vt8500_set_mctrl,
 	.get_mctrl	= vt8500_get_mctrl,
diff --git a/drivers/tty/serial/zs.c b/drivers/tty/serial/zs.c
index eeefd76..d32bd49 100644
--- a/drivers/tty/serial/zs.c
+++ b/drivers/tty/serial/zs.c
@@ -1045,7 +1045,7 @@ static int zs_verify_port(struct uart_port *uport, struct serial_struct *ser)
 }
 
 
-static struct uart_ops zs_ops = {
+static const struct uart_ops zs_ops = {
 	.tx_empty	= zs_tx_empty,
 	.set_mctrl	= zs_set_mctrl,
 	.get_mctrl	= zs_get_mctrl,
-- 
2.7.4

