From: Jean Delvare <khali@linux-fr.org>
Date: Mon, 21 Sep 2009 13:31:32 +0000
Subject: [PATCH 2/2] IOC3/IOC4: Fix error path on driver registration
Message-Id: <20090921153132.196dd9d1@hyperion.delvare>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Two IOC3 and IOC4 drivers have broken error paths on registration.
Fix them.

Signed-off-by: Jean Delvare <khali@linux-fr.org>
Cc: Pat Gefre <pfg@sgi.com>
---
Note: I was not able to build-test these patches, please do.

 drivers/serial/ioc4_serial.c |   16 +++++++++++++---
 drivers/sn/ioc3.c            |    2 +-
 2 files changed, 14 insertions(+), 4 deletions(-)

--- linux-2.6.30-rc8.orig/drivers/serial/ioc4_serial.c	2009-06-04 11:41:02.000000000 +0200
+++ linux-2.6.30-rc8/drivers/serial/ioc4_serial.c	2009-06-04 12:05:51.000000000 +0200
@@ -2913,17 +2913,27 @@ static int __init ioc4_serial_init(void)
 		printk(KERN_WARNING
 			"%s: Couldn't register rs232 IOC4 serial driver\n",
 			__func__);
-		return ret;
+		goto out;
 	}
 	if ((ret = uart_register_driver(&ioc4_uart_rs422)) < 0) {
 		printk(KERN_WARNING
 			"%s: Couldn't register rs422 IOC4 serial driver\n",
 			__func__);
-		return ret;
+		goto out_uart_rs232;
 	}
 
 	/* register with IOC4 main module */
-	return ioc4_register_submodule(&ioc4_serial_submodule);
+	ret = ioc4_register_submodule(&ioc4_serial_submodule);
+	if (ret)
+		goto out_uart_rs422;
+	return 0;
+
+out_uart_rs422:
+	uart_unregister_driver(&ioc4_uart_rs422);
+out_uart_rs232:
+	uart_unregister_driver(&ioc4_uart_rs232);
+out:
+	return ret;
 }
 
 static void __exit ioc4_serial_exit(void)
--- linux-2.6.30-rc8.orig/drivers/sn/ioc3.c	2009-06-04 11:41:03.000000000 +0200
+++ linux-2.6.30-rc8/drivers/sn/ioc3.c	2009-06-04 12:03:26.000000000 +0200
@@ -820,7 +820,7 @@ static int __init ioc3_init(void)
 {
 	if (ia64_platform_is("sn2"))
 		return pci_register_driver(&ioc3_driver);
-	return 0;
+	return -ENODEV;
 }
 
 /* Module unload */


-- 
Jean Delvare
