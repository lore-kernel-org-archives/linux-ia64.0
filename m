From: "H. J. Lu" <hjl@lucon.org>
Date: Mon, 28 Jul 2003 23:18:34 +0000
Subject: Re: Does the new ACPI code work with bigsur?
Message-Id: <marc-linux-ia64-105943447103365@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105942953131189@msgid-missing>
In-Reply-To: <marc-linux-ia64-105942953131189@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Jul 28, 2003 at 11:06:23PM +0100, Matthew Wilcox wrote:
> On Mon, Jul 28, 2003 at 02:44:07PM -0700, H. J. Lu wrote:
> > 2.4.21 kernel has
> > 
> > ACPI Subsystem revision 20020517
> > 
> > and works fine on bigsur. Has anyone got
> > 
> > ACPI Subsystem revision 20030619
> > 
> > working on bigsur?
> 
> what firmware are you running?  this is a common problem with bigsur-era
> machines.

My firmware is OK. This patch allows the kernel to boot on bigsur.


H.J.
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
