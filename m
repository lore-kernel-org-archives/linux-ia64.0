From: "Enrico Weigelt, metux IT consult" <info@metux.net>
Date: Sat, 27 Apr 2019 12:51:53 +0000
Subject: [PATCH 12/41] drivers: tty: serial: uartlite: use dev_dbg() instead of pr_debug()
Message-Id: <1556369542-13247-13-git-send-email-info@metux.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556369542-13247-1-git-send-email-info@metux.net>
In-Reply-To: <1556369542-13247-1-git-send-email-info@metux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: gregkh@linuxfoundation.org, andrew@aj.id.au, andriy.shevchenko@linux.intel.com, macro@linux-mips.org, vz@mleia.com, slemieux.tyco@gmail.com, khilman@baylibre.com, liviu.dudau@arm.com, sudeep.holla@arm.com, lorenzo.pieralisi@arm.com, davem@davemloft.net, jacmet@sunsite.dk, linux@prisktech.co.nz, matthias.bgg@gmail.com, linux-mips@vger.kernel.org, linux-serial@vger.kernel.org, linux-ia64@vger.kernel.org, linux-amlogic@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

Using dev_dbg() instead of pr_debg() for more consistent output.
(prints device name, etc).

Signed-off-by: Enrico Weigelt <info@metux.net>
---
 drivers/tty/serial/uartlite.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/tty/serial/uartlite.c b/drivers/tty/serial/uartlite.c
index b8b912b..44d65bd 100644
--- a/drivers/tty/serial/uartlite.c
+++ b/drivers/tty/serial/uartlite.c
@@ -352,7 +352,8 @@ static int ulite_request_port(struct uart_port *port)
 	struct uartlite_data *pdata = port->private_data;
 	int ret;
 
-	pr_debug("ulite console: port=%p; port->mapbase=%llx\n",
+	dev_dbg(port->dev,
+		"ulite console: port=%p; port->mapbase=%llx\n",
 		 port, (unsigned long long) port->mapbase);
 
 	if (!request_mem_region(port->mapbase, ULITE_REGION, "uartlite")) {
@@ -519,7 +520,8 @@ static int ulite_console_setup(struct console *co, char *options)
 
 	/* Has the device been initialized yet? */
 	if (!port->mapbase) {
-		pr_debug("console on ttyUL%i not present\n", co->index);
+		dev_dbg(port->dev, "console on ttyUL%i not present\n",
+			co->index);
 		return -ENODEV;
 	}
 
-- 
1.9.1
