From: "Enrico Weigelt, metux IT consult" <info@metux.net>
Date: Sat, 27 Apr 2019 12:51:49 +0000
Subject: [PATCH 08/41] drivers: tty: serial: sb1250-duart: fix checkpatch warning on printk()
Message-Id: <1556369542-13247-9-git-send-email-info@metux.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556369542-13247-1-git-send-email-info@metux.net>
In-Reply-To: <1556369542-13247-1-git-send-email-info@metux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: gregkh@linuxfoundation.org, andrew@aj.id.au, andriy.shevchenko@linux.intel.com, macro@linux-mips.org, vz@mleia.com, slemieux.tyco@gmail.com, khilman@baylibre.com, liviu.dudau@arm.com, sudeep.holla@arm.com, lorenzo.pieralisi@arm.com, davem@davemloft.net, jacmet@sunsite.dk, linux@prisktech.co.nz, matthias.bgg@gmail.com, linux-mips@vger.kernel.org, linux-serial@vger.kernel.org, linux-ia64@vger.kernel.org, linux-amlogic@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

checkpatch complaints:

    WARNING: printk() should include KERN_<LEVEL> facility level
    #698: FILE: drivers/tty/serial/sb1250-duart.c:698:
    +		printk(err);

    WARNING: printk() should include KERN_<LEVEL> facility level
    #706: FILE: drivers/tty/serial/sb1250-duart.c:706:
    +			printk(err);

Even though it's a false alarm here (the string is already prefixed
w/ KERN_ERR), it's nicer to use pr_err() here, which also makes
checkpatch happy.

Signed-off-by: Enrico Weigelt <info@metux.net>
---
 drivers/tty/serial/sb1250-duart.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/tty/serial/sb1250-duart.c b/drivers/tty/serial/sb1250-duart.c
index b4342c8..227af87 100644
--- a/drivers/tty/serial/sb1250-duart.c
+++ b/drivers/tty/serial/sb1250-duart.c
@@ -689,13 +689,13 @@ static int sbd_map_port(struct uart_port *uport)
 
 static int sbd_request_port(struct uart_port *uport)
 {
-	const char *err = KERN_ERR "sbd: Unable to reserve MMIO resource\n";
+	const char *err = "sbd: Unable to reserve MMIO resource\n";
 	struct sbd_duart *duart = to_sport(uport)->duart;
 	int ret = 0;
 
 	if (!request_mem_region(uport->mapbase, DUART_CHANREG_SPACING,
 				"sb1250-duart")) {
-		printk(err);
+		pr_err(err);
 		return -EBUSY;
 	}
 	refcount_inc(&duart->map_guard);
@@ -703,7 +703,7 @@ static int sbd_request_port(struct uart_port *uport)
 		if (!request_mem_region(duart->mapctrl, DUART_CHANREG_SPACING,
 					"sb1250-duart")) {
 			refcount_dec(&duart->map_guard);
-			printk(err);
+			pr_err(err);
 			ret = -EBUSY;
 		}
 	}
-- 
1.9.1
