From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 02 Apr 2004 21:45:22 +0000
Subject: [PATCH] HCDP IRQ fixup
Message-Id: <200404021445.22223.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Some pre-production firmware has incorrect GSI values in the HCDP,
which tells us where the serial console port is, so we have to
do the auto-IRQ thing after all.

(This is in a function that will get removed if my recent early serial
console patches are accepted, but it would be convenient to have this
patch in the meantime.)

=== drivers/serial/8250_hcdp.c 1.3 vs edited ==--- 1.3/drivers/serial/8250_hcdp.c	Mon Mar 15 15:53:32 2004
+++ edited/drivers/serial/8250_hcdp.c	Fri Apr  2 14:18:18 2004
@@ -186,6 +186,8 @@
 		port.irq = gsi;
 #endif
 		port.flags = UPF_SKIP_TEST | UPF_BOOT_AUTOCONF | UPF_RESOURCES;
+		if (gsi)
+			port.flags |= UPF_AUTO_IRQ;
 
 		/*
 		 * Note: the above memset() initializes port.line to 0,
