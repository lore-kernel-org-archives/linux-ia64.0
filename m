From: Alex Williamson <alex.williamson@hp.com>
Date: Mon, 26 Apr 2004 14:42:59 +0000
Subject: [PATCH] 8250_hcdp needs irq sharing
Message-Id: <1082990579.15656.31.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


   Here's a trivial patch that makes 8250_hcdp setup the correct flags
when IRQ sharing is enabled for serial ports.  Please apply.  Thanks,

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab

=== drivers/serial/8250_hcdp.c 1.4 vs edited ==--- 1.4/drivers/serial/8250_hcdp.c	Sat Apr 10 03:26:14 2004
+++ edited/drivers/serial/8250_hcdp.c	Sun Apr 25 21:25:42 2004
@@ -189,6 +189,9 @@
 		if (gsi)
 			port.flags |= UPF_AUTO_IRQ;
 
+#ifdef CONFIG_SERIAL_8250_SHARE_IRQ
+		port.flags |= UPF_SHARE_IRQ;
+#endif
 		/*
 		 * Note: the above memset() initializes port.line to 0,
 		 * so we register this port as ttyS0.


