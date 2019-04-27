From: "Enrico Weigelt, metux IT consult" <info@metux.net>
Date: Sat, 27 Apr 2019 12:51:50 +0000
Subject: [PATCH 09/41] drivers: tty: serial: sb1250-duart: fill mapsize and use it
Message-Id: <1556369542-13247-10-git-send-email-info@metux.net>
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
 drivers/tty/serial/sb1250-duart.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/tty/serial/sb1250-duart.c b/drivers/tty/serial/sb1250-duart.c
index 227af87..1184226 100644
--- a/drivers/tty/serial/sb1250-duart.c
+++ b/drivers/tty/serial/sb1250-duart.c
@@ -658,7 +658,7 @@ static void sbd_release_port(struct uart_port *uport)
 
 	if(refcount_dec_and_test(&duart->map_guard))
 		release_mem_region(duart->mapctrl, DUART_CHANREG_SPACING);
-	release_mem_region(uport->mapbase, DUART_CHANREG_SPACING);
+	release_mem_region(uport->mapbase, uport->mapsize);
 }
 
 static int sbd_map_port(struct uart_port *uport)
@@ -668,7 +668,7 @@ static int sbd_map_port(struct uart_port *uport)
 
 	if (!uport->membase)
 		uport->membase = ioremap_nocache(uport->mapbase,
-						 DUART_CHANREG_SPACING);
+						 uport->mapsize);
 	if (!uport->membase) {
 		dev_err(uport->dev, "Cannot map MMIO (base)\n");
 		return -ENOMEM;
@@ -693,7 +693,7 @@ static int sbd_request_port(struct uart_port *uport)
 	struct sbd_duart *duart = to_sport(uport)->duart;
 	int ret = 0;
 
-	if (!request_mem_region(uport->mapbase, DUART_CHANREG_SPACING,
+	if (!request_mem_region(uport->mapbase, uport->mapsize,
 				"sb1250-duart")) {
 		pr_err(err);
 		return -EBUSY;
@@ -716,7 +716,7 @@ static int sbd_request_port(struct uart_port *uport)
 		}
 	}
 	if (ret) {
-		release_mem_region(uport->mapbase, DUART_CHANREG_SPACING);
+		release_mem_region(uport->mapbase, uport->mapsize);
 		return ret;
 	}
 	return 0;
@@ -812,6 +812,7 @@ static void __init sbd_probe_duarts(void)
 			uport->ops	= &sbd_ops;
 			uport->line	= line;
 			uport->mapbase	= SBD_CHANREGS(line);
+			uport->mapsize	= DUART_CHANREG_SPACING;
 		}
 	}
 }
-- 
1.9.1
