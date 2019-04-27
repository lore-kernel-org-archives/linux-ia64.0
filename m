From: "Enrico Weigelt, metux IT consult" <info@metux.net>
Date: Sat, 27 Apr 2019 12:52:01 +0000
Subject: [PATCH 20/41] drivers: tty: serial: cpm_uart: use dev_err()/dev_warn() instead of printk()
Message-Id: <1556369542-13247-21-git-send-email-info@metux.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556369542-13247-1-git-send-email-info@metux.net>
In-Reply-To: <1556369542-13247-1-git-send-email-info@metux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: gregkh@linuxfoundation.org, andrew@aj.id.au, andriy.shevchenko@linux.intel.com, macro@linux-mips.org, vz@mleia.com, slemieux.tyco@gmail.com, khilman@baylibre.com, liviu.dudau@arm.com, sudeep.holla@arm.com, lorenzo.pieralisi@arm.com, davem@davemloft.net, jacmet@sunsite.dk, linux@prisktech.co.nz, matthias.bgg@gmail.com, linux-mips@vger.kernel.org, linux-serial@vger.kernel.org, linux-ia64@vger.kernel.org, linux-amlogic@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

Using dev_err()/dev_warn() instead of printk() for more consistent output.
(prints device name, etc).

Signed-off-by: Enrico Weigelt <info@metux.net>
---
 drivers/tty/serial/cpm_uart/cpm_uart_core.c | 6 +++---
 drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c | 2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/tty/serial/cpm_uart/cpm_uart_core.c b/drivers/tty/serial/cpm_uart/cpm_uart_core.c
index b929c7a..374b8bb 100644
--- a/drivers/tty/serial/cpm_uart/cpm_uart_core.c
+++ b/drivers/tty/serial/cpm_uart/cpm_uart_core.c
@@ -265,7 +265,7 @@ static void cpm_uart_int_rx(struct uart_port *port)
 		 * later, which will be the next rx-interrupt or a timeout
 		 */
 		if (tty_buffer_request_room(tport, i) < i) {
-			printk(KERN_WARNING "No room in flip buffer\n");
+			dev_warn(port->dev, "No room in flip buffer\n");
 			return;
 		}
 
@@ -1155,7 +1155,7 @@ static int cpm_uart_init_port(struct device_node *np,
 	if (!pinfo->clk) {
 		data = of_get_property(np, "fsl,cpm-brg", &len);
 		if (!data || len != 4) {
-			printk(KERN_ERR "CPM UART %pOFn has no/invalid "
+			dev_err(port->dev, "CPM UART %pOFn has no/invalid "
 			                "fsl,cpm-brg property.\n", np);
 			return -EINVAL;
 		}
@@ -1164,7 +1164,7 @@ static int cpm_uart_init_port(struct device_node *np,
 
 	data = of_get_property(np, "fsl,cpm-command", &len);
 	if (!data || len != 4) {
-		printk(KERN_ERR "CPM UART %pOFn has no/invalid "
+		dev_err(port->dev, "CPM UART %pOFn has no/invalid "
 		                "fsl,cpm-command property.\n", np);
 		return -EINVAL;
 	}
diff --git a/drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c b/drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c
index 6a1cd03..ef1ae08 100644
--- a/drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c
+++ b/drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c
@@ -67,7 +67,7 @@ void __iomem *cpm_uart_map_pram(struct uart_cpm_port *port,
 		return pram;
 
 	if (len != 2) {
-		printk(KERN_WARNING "cpm_uart[%d]: device tree references "
+		dev_warn(port->dev, "cpm_uart[%d]: device tree references "
 			"SMC pram, using boot loader/wrapper pram mapping. "
 			"Please fix your device tree to reference the pram "
 			"base register instead.\n",
-- 
1.9.1
