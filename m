From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 04 Aug 2003 19:07:19 +0000
Subject: Re: milstone reached: ia64 linux builds out of Linus' tree
Message-Id: <marc-linux-ia64-106002405508168@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106001867501939@msgid-missing>
In-Reply-To: <marc-linux-ia64-106001867501939@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Can someone look into/explain why this patch is needed for Big Sur?
Either the old code is wrong for other machines, too, or the old code
is broken and we just don't exercise it on the other ia64 machines?

	--david

>>>>> On Mon, 4 Aug 2003 11:10:33 -0700, "H. J. Lu" <hjl@lucon.org> said:

  >> I just tried the latest on my big sur, and though I think modules work
  >> (at least they build for other machines), big sur is broken because
  >> non-ACPI based PCI enumeration has been removed from the tree.

  HJ> Can you try this patch for bigsur?


  HJ> H.J.
  HJ> ---
  HJ> --- linux/drivers/acpi/osl.c.acpi	Mon Jul 28 11:41:53 2003
  HJ> +++ linux/drivers/acpi/osl.c	Mon Jul 28 15:12:44 2003
  HJ> @@ -250,7 +250,12 @@ acpi_os_install_interrupt_handler(u32 ir
  HJ> irq = acpi_fadt.sci_int;
 
  HJ> #ifdef CONFIG_IA64
  HJ> -	irq = gsi_to_vector(irq);
  HJ> +	irq = acpi_irq_to_vector (irq);
  HJ> +	if (irq < 0) {
  HJ> +		printk(KERN_ERR PREFIX "SCI (IRQ%d/%d) not registerd\n",
  HJ> +		       irq, acpi_fadt.sci_int);
  HJ> +		return AE_OK;
  HJ> +	}
  HJ> #endif
  HJ> acpi_irq_irq = irq;
  HJ> acpi_irq_handler = handler;
