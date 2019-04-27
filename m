From: "Enrico Weigelt, metux IT consult" <info@metux.net>
Date: Sat, 27 Apr 2019 12:52:10 +0000
Subject: [PATCH 29/41] drivers: tty: serial: sunzilog: cleanup logging
Message-Id: <1556369542-13247-30-git-send-email-info@metux.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556369542-13247-1-git-send-email-info@metux.net>
In-Reply-To: <1556369542-13247-1-git-send-email-info@metux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: gregkh@linuxfoundation.org, andrew@aj.id.au, andriy.shevchenko@linux.intel.com, macro@linux-mips.org, vz@mleia.com, slemieux.tyco@gmail.com, khilman@baylibre.com, liviu.dudau@arm.com, sudeep.holla@arm.com, lorenzo.pieralisi@arm.com, davem@davemloft.net, jacmet@sunsite.dk, linux@prisktech.co.nz, matthias.bgg@gmail.com, linux-mips@vger.kernel.org, linux-serial@vger.kernel.org, linux-ia64@vger.kernel.org, linux-amlogic@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

Fix checkpatch warning:

    WARNING: Prefer [subsystem eg: netdev]_info([subsystem]dev, ... then dev_info(dev, ... then pr_info(...  to printk(KERN_INFO ...
    #1238: FILE: drivers/tty/serial/sunzilog.c:1238:
    +	printk(KERN_INFO "Console: ttyS%d (SunZilog zs%d)\n",

Signed-off-by: Enrico Weigelt <info@metux.net>
---
 drivers/tty/serial/sunzilog.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/tty/serial/sunzilog.c b/drivers/tty/serial/sunzilog.c
index 85edb0d..dba723c 100644
--- a/drivers/tty/serial/sunzilog.c
+++ b/drivers/tty/serial/sunzilog.c
@@ -1235,7 +1235,7 @@ static int __init sunzilog_console_setup(struct console *con, char *options)
 	if (up->port.type != PORT_SUNZILOG)
 		return -1;
 
-	printk(KERN_INFO "Console: ttyS%d (SunZilog zs%d)\n",
+	pr_info("Console: ttyS%d (SunZilog zs%d)\n",
 	       (sunzilog_reg.minor - 64) + con->index, con->index);
 
 	/* Get firmware console settings.  */
@@ -1615,9 +1615,8 @@ static int __init sunzilog_init(void)
 		while (up) {
 			struct zilog_channel __iomem *channel;
 
-			/* printk(KERN_INFO
-			 *        "Enable IRQ for ZILOG Hardware %p\n",
-			 *        up);
+			/* pr_info("Enable IRQ for ZILOG Hardware %p\n",
+			 *         up);
 			 */
 			channel          = ZILOG_CHANNEL_FROM_PORT(&up->port);
 			up->flags       |= SUNZILOG_FLAG_ISR_HANDLER;
@@ -1655,9 +1654,8 @@ static void __exit sunzilog_exit(void)
 		while (up) {
 			struct zilog_channel __iomem *channel;
 
-			/* printk(KERN_INFO
-			 *        "Disable IRQ for ZILOG Hardware %p\n",
-			 *        up);
+			/* pr_info("Disable IRQ for ZILOG Hardware %p\n",
+			 *         up);
 			 */
 			channel          = ZILOG_CHANNEL_FROM_PORT(&up->port);
 			up->flags       &= ~SUNZILOG_FLAG_ISR_HANDLER;
-- 
1.9.1
