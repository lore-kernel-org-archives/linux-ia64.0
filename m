From: "H. J. Lu" <hjl@lucon.org>
Date: Mon, 04 Aug 2003 18:10:33 +0000
Subject: Re: milstone reached: ia64 linux builds out of Linus' tree
Message-Id: <marc-linux-ia64-106002071504213@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106001867501939@msgid-missing>
In-Reply-To: <marc-linux-ia64-106001867501939@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Aug 04, 2003 at 11:00:16AM -0700, Jesse Barnes wrote:
> On Mon, Aug 04, 2003 at 10:53:08AM -0700, H. J. Lu wrote:
> > On Mon, Aug 04, 2003 at 10:37:39AM -0700, David Mosberger wrote:
> > > As of this morning, Linus's current bk tree
> > > (http://linux.bkbits.net:8080/linux-2.5) builds and works out of the
> > > box for ia64!
> > > 
> > 
> > Does it work on bigsur? Does it support kernel modules?
> 
> I just tried the latest on my big sur, and though I think modules work
> (at least they build for other machines), big sur is broken because
> non-ACPI based PCI enumeration has been removed from the tree.
> 

Can you try this patch for bigsur?


H.J.
---
--- linux/drivers/acpi/osl.c.acpi	Mon Jul 28 11:41:53 2003
+++ linux/drivers/acpi/osl.c	Mon Jul 28 15:12:44 2003
@@ -250,7 +250,12 @@ acpi_os_install_interrupt_handler(u32 ir
 	irq = acpi_fadt.sci_int;
 
 #ifdef CONFIG_IA64
-	irq = gsi_to_vector(irq);
+	irq = acpi_irq_to_vector (irq);
+	if (irq < 0) {
+		printk(KERN_ERR PREFIX "SCI (IRQ%d/%d) not registerd\n",
+		       irq, acpi_fadt.sci_int);
+		return AE_OK;
+	}
 #endif
 	acpi_irq_irq = irq;
 	acpi_irq_handler = handler;
