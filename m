From: "Enrico Weigelt, metux IT consult" <info@metux.net>
Date: Sat, 27 Apr 2019 12:51:58 +0000
Subject: [PATCH 17/41] drivers: tty: serial: apbuart: fix logging calls
Message-Id: <1556369542-13247-18-git-send-email-info@metux.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556369542-13247-1-git-send-email-info@metux.net>
In-Reply-To: <1556369542-13247-1-git-send-email-info@metux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: gregkh@linuxfoundation.org, andrew@aj.id.au, andriy.shevchenko@linux.intel.com, macro@linux-mips.org, vz@mleia.com, slemieux.tyco@gmail.com, khilman@baylibre.com, liviu.dudau@arm.com, sudeep.holla@arm.com, lorenzo.pieralisi@arm.com, davem@davemloft.net, jacmet@sunsite.dk, linux@prisktech.co.nz, matthias.bgg@gmail.com, linux-mips@vger.kernel.org, linux-serial@vger.kernel.org, linux-ia64@vger.kernel.org, linux-amlogic@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

Fix checkpatch warnings:

    WARNING: Prefer using '"%s...", __func__' to using 'apbuart_console_setup', this function's name, in a string
    #491: FILE: drivers/tty/serial/apbuart.c:491:
    +	pr_debug("apbuart_console_setup co=%p, co->index=%i, options=%s\n",

    WARNING: Prefer [subsystem eg: netdev]_info([subsystem]dev, ... then dev_info(dev, ... then pr_info(...  to printk(KERN_INFO ...
    #661: FILE: drivers/tty/serial/apbuart.c:661:
    +	printk(KERN_INFO "Serial: GRLIB APBUART driver\n");

    WARNING: Prefer [subsystem eg: netdev]_err([subsystem]dev, ... then dev_err(dev, ... then pr_err(...  to printk(KERN_ERR ...
    #666: FILE: drivers/tty/serial/apbuart.c:666:
    +		printk(KERN_ERR "%s: uart_register_driver failed (%i)\n",

    WARNING: Prefer [subsystem eg: netdev]_err([subsystem]dev, ... then dev_err(dev, ... then pr_err(...  to printk(KERN_ERR ...
    #673: FILE: drivers/tty/serial/apbuart.c:673:
    +		printk(KERN_ERR

Signed-off-by: Enrico Weigelt <info@metux.net>
---
 drivers/tty/serial/apbuart.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/tty/serial/apbuart.c b/drivers/tty/serial/apbuart.c
index 60cd133..d2b86f7 100644
--- a/drivers/tty/serial/apbuart.c
+++ b/drivers/tty/serial/apbuart.c
@@ -482,8 +482,8 @@ static int __init apbuart_console_setup(struct console *co, char *options)
 	int parity = 'n';
 	int flow = 'n';
 
-	pr_debug("apbuart_console_setup co=%p, co->index=%i, options=%s\n",
-		 co, co->index, options);
+	pr_debug("%s() co=%p, co->index=%i, options=%s\n",
+		 __func__, co, co->index, options);
 
 	/*
 	 * Check whether an invalid uart number has been specified, and
@@ -650,21 +650,20 @@ static int __init grlib_apbuart_init(void)
 	if (ret)
 		return ret;
 
-	printk(KERN_INFO "Serial: GRLIB APBUART driver\n");
+	pr_info("Serial: GRLIB APBUART driver\n");
 
 	ret = uart_register_driver(&grlib_apbuart_driver);
 
 	if (ret) {
-		printk(KERN_ERR "%s: uart_register_driver failed (%i)\n",
-		       __FILE__, ret);
+		pr_err("%s: uart_register_driver failed (%i)\n",
+		       __func__, ret);
 		return ret;
 	}
 
 	ret = platform_driver_register(&grlib_apbuart_of_driver);
 	if (ret) {
-		printk(KERN_ERR
-		       "%s: platform_driver_register failed (%i)\n",
-		       __FILE__, ret);
+		pr_err("%s: platform_driver_register failed (%i)\n",
+		       __func__, ret);
 		uart_unregister_driver(&grlib_apbuart_driver);
 		return ret;
 	}
-- 
1.9.1
