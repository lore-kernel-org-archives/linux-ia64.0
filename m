From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 08 Mar 2004 19:12:04 +0000
Subject: Re: [PATCH] fix PCI interrupt setting for ia64
Message-Id: <200403081212.04213.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3ACA40606221794F80A5670F0AF15F8401B1A017@PDSMSX403.ccr.corp.intel.com> <20040308.182552.55855095.t-kochi@bq.jp.nec.com>
In-Reply-To: <20040308.182552.55855095.t-kochi@bq.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Takayoshi Kochi <t-kochi@bq.jp.nec.com>, benjamin.liu@intel.com, Russell King <rmk@arm.linux.org.uk>
Cc: iod00d@hp.com, kaneshige.kenji@jp.fujitsu.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Monday 08 March 2004 2:25 am, Takayoshi Kochi wrote:
> I think that's still true for IDE / serial port drivers.
> Kaneshige-san, could you confirm your changes are compatible
> with probe_irq_on()?
> 
> Itanium-generation machines (such as BigSur) depends on
> probe_irq_on() for finding serial port IRQ.

Strictly speaking, since ACPI tells us about IRQs, we shouldn't need
probe_irq_on() on ia64, should we?

I don't see any ACPI smarts in the IDE driver, but I think the
serial driver needs only the attached patch to make it avoid
the use of probe_irq_on().  I tested this on i2k and various
HP zx1 boxes, and it works fine.

Russell, if you agree, would you mind applying this?

ACPI and HCDP tell us what IRQ the serial port uses, so there's
no need to have the driver probe for the IRQ.

=== drivers/serial/8250_acpi.c 1.7 vs edited ==--- 1.7/drivers/serial/8250_acpi.c	Fri Jan 16 15:01:45 2004
+++ edited/drivers/serial/8250_acpi.c	Mon Mar  8 11:14:51 2004
@@ -134,8 +134,7 @@
 	}
 
 	serial_req.baud_base = BASE_BAUD;
-	serial_req.flags = UPF_SKIP_TEST | UPF_BOOT_AUTOCONF |
-			   UPF_AUTO_IRQ  | UPF_RESOURCES;
+	serial_req.flags = UPF_SKIP_TEST | UPF_BOOT_AUTOCONF | UPF_RESOURCES;
 
 	priv->line = register_serial(&serial_req);
 	if (priv->line < 0) {
=== drivers/serial/8250_hcdp.c 1.2 vs edited ==--- 1.2/drivers/serial/8250_hcdp.c	Sun Jan 11 16:27:13 2004
+++ edited/drivers/serial/8250_hcdp.c	Mon Mar  8 11:28:27 2004
@@ -186,8 +186,6 @@
 		port.irq = gsi;
 #endif
 		port.flags = UPF_SKIP_TEST | UPF_BOOT_AUTOCONF | UPF_RESOURCES;
-		if (gsi)
-			port.flags |= ASYNC_AUTO_IRQ;
 
 		/*
 		 * Note: the above memset() initializes port.line to 0,

