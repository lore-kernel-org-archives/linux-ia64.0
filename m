From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 21 Apr 2005 21:41:50 +0000
Subject: Re: [PATCH 2.6.12 1/1] pcdp: add PCDP pci interface support
Message-Id: <1114119711.2784.72.camel@eeyore>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050421202619.31042.93421.39277@attica.americas.sgi.com>
In-Reply-To: <20050421202619.31042.93421.39277@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2005-04-21 at 15:26 -0500, Mark Maule wrote:
>  #ifdef CONFIG_SERIAL_SGI_L1_CONSOLE
>  	{
>  		extern int sn_serial_console_early_setup(void);
>  		if (!sn_serial_console_early_setup())
> -			return 0;
> +			earlycons++;
>  	}

If SGI is going to support the PCDP, why don't you add a new
PCDP device type for the L1 console?  It feels like a nuisance
to have two places to look for console device info.  How do
you say "use VGA but not the L1 console"?

> +unsigned long	pcdp_vga_io_base;
> +unsigned long	pcdp_vga_mem_base;

Apart from the extra space that snuck into the definitions, I
don't really like these being associated with the PCDP.  Isn't
this the sort of thing that Ben H's VGA arbitrator[1] would
also change?

So I vote for something with a more neutral name, possibly in
arch/ia64/kernel/setup.c.

And pcdp_vga_io_base isn't used anywhere, so I'd remove it.

> +setup_vga_console(struct pcdp_device *dev)
>  {
> +
>  #if defined(CONFIG_VT) && defined(CONFIG_VGA_CONSOLE)
> -	if (efi_mem_type(0xA0000) = EFI_CONVENTIONAL_MEMORY) {
> +	u8			*if_ptr;

This isn't ACPI, so we don't need extra tabs in the middle
of variable declarations (or blank lines after the beginning
of the function).  :-)

> +		memcpy(&if_pci, if_ptr, sizeof(struct pcdp_if_pci));

The above is correct, but it's easier to verify this:

	memcpy(&if_pci, if_ptr, sizeof(if_pci));



[1] http://lkml.org/lkml/2005/3/9/42

