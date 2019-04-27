From: "Enrico Weigelt, metux IT consult" <info@metux.net>
Date: Sat, 27 Apr 2019 12:52:14 +0000
Subject: [PATCH 33/41] drivers: tty: serial: zs: use dev_err() instead of printk()
Message-Id: <1556369542-13247-34-git-send-email-info@metux.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556369542-13247-1-git-send-email-info@metux.net>
In-Reply-To: <1556369542-13247-1-git-send-email-info@metux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: gregkh@linuxfoundation.org, andrew@aj.id.au, andriy.shevchenko@linux.intel.com, macro@linux-mips.org, vz@mleia.com, slemieux.tyco@gmail.com, khilman@baylibre.com, liviu.dudau@arm.com, sudeep.holla@arm.com, lorenzo.pieralisi@arm.com, davem@davemloft.net, jacmet@sunsite.dk, linux@prisktech.co.nz, matthias.bgg@gmail.com, linux-mips@vger.kernel.org, linux-serial@vger.kernel.org, linux-ia64@vger.kernel.org, linux-amlogic@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

Using dev_err() instead of printk() for more consistent output.
(prints device name, etc).

Signed-off-by: Enrico Weigelt <info@metux.net>
---
 drivers/tty/serial/zs.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/tty/serial/zs.c b/drivers/tty/serial/zs.c
index b03d3e4..adbfe79 100644
--- a/drivers/tty/serial/zs.c
+++ b/drivers/tty/serial/zs.c
@@ -767,7 +767,7 @@ static int zs_startup(struct uart_port *uport)
 				  IRQF_SHARED, "scc", scc);
 		if (ret) {
 			atomic_add(-1, &scc->irq_guard);
-			printk(KERN_ERR "zs: can't get irq %d\n",
+			dev_err(uport->dev, "zs: can't get irq %d\n",
 			       zport->port.irq);
 			return ret;
 		}
@@ -995,7 +995,7 @@ static int zs_map_port(struct uart_port *uport)
 		uport->membase = ioremap_nocache(uport->mapbase,
 						 ZS_CHAN_IO_SIZE);
 	if (!uport->membase) {
-		printk(KERN_ERR "zs: Cannot map MMIO\n");
+		dev_err(port->dev, "zs: Cannot map MMIO\n");
 		return -ENOMEM;
 	}
 	return 0;
@@ -1006,7 +1006,7 @@ static int zs_request_port(struct uart_port *uport)
 	int ret;
 
 	if (!request_mem_region(uport->mapbase, ZS_CHAN_IO_SIZE, "scc")) {
-		printk(KERN_ERR "zs: Unable to reserve MMIO resource\n");
+		dev_err(uport->dev, "zs: Unable to reserve MMIO resource\n");
 		return -EBUSY;
 	}
 	ret = zs_map_port(uport);
-- 
1.9.1
