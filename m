From: "Enrico Weigelt, metux IT consult" <info@metux.net>
Date: Sat, 27 Apr 2019 12:52:11 +0000
Subject: [PATCH 30/41] drivers: tty: serial: ioc4_serial: use dev_warn() instead of printk()
Message-Id: <1556369542-13247-31-git-send-email-info@metux.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556369542-13247-1-git-send-email-info@metux.net>
In-Reply-To: <1556369542-13247-1-git-send-email-info@metux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: gregkh@linuxfoundation.org, andrew@aj.id.au, andriy.shevchenko@linux.intel.com, macro@linux-mips.org, vz@mleia.com, slemieux.tyco@gmail.com, khilman@baylibre.com, liviu.dudau@arm.com, sudeep.holla@arm.com, lorenzo.pieralisi@arm.com, davem@davemloft.net, jacmet@sunsite.dk, linux@prisktech.co.nz, matthias.bgg@gmail.com, linux-mips@vger.kernel.org, linux-serial@vger.kernel.org, linux-ia64@vger.kernel.org, linux-amlogic@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

Using dev_warn() instead of printk() for more consistent output.
(prints device name, etc).

Signed-off-by: Enrico Weigelt <info@metux.net>
---
 drivers/tty/serial/ioc4_serial.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/tty/serial/ioc4_serial.c b/drivers/tty/serial/ioc4_serial.c
index db5b979..21c1b8f 100644
--- a/drivers/tty/serial/ioc4_serial.c
+++ b/drivers/tty/serial/ioc4_serial.c
@@ -2752,7 +2752,7 @@ static int ioc4_serial_remove_one(struct ioc4_driver_data *idd)
 		the_port->dev = &pdev->dev;
 		spin_lock_init(&the_port->lock);
 		if (uart_add_one_port(u_driver, the_port) < 0) {
-			printk(KERN_WARNING
+			dev_warn(&pdev->dev,
 		           "%s: unable to add port %d bus %d\n",
 			       __func__, the_port->line, pdev->bus->number);
 		} else {
-- 
1.9.1
