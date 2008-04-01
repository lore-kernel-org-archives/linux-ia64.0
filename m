From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 01 Apr 2008 15:57:15 +0000
Subject: Re: + revert-gregkh-pci-pci-x86-use-generic-pci_enable_resources.patch added to -mm tree
Message-Id: <200804010957.16459.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200803282348.m2SNmleP016847@imap1.linux-foundation.org>
In-Reply-To: <200803282348.m2SNmleP016847@imap1.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, davem@davemloft.net, greg@kroah.com, m.kozlowski@tuxland.pl, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Ivan Kokshaysky <ink@jurassic.park.msu.ru>

On Friday 28 March 2008 05:48:47 pm akpm@linux-foundation.org wrote:
> 
> The patch titled
>      revert gregkh-pci-pci-x86-use-generic-pci_enable_resources
> has been added to the -mm tree.  Its filename is
>      revert-gregkh-pci-pci-x86-use-generic-pci_enable_resources.patch

OK, I'm not sure where we are with this.  Ben listed arches where
the generic pci_enable_resources() should be safe: x86, alpha, and
powerpc.  I think we should also include ia64, since I work on that.

If there's no objection to those arches, how should we move forward?
Since Andrew put in "revert gregkh-pci" patches rather than just
dropping things, I assume the original patches are in Greg KH's tree.

Can we just drop the "revert gregkh" patches for x86, alpha, powerpc,
and ia64?

Bjorn

> ------------------------------------------------------
> Subject: revert gregkh-pci-pci-x86-use-generic-pci_enable_resources
> From: Andrew Morton <akpm@linux-foundation.org>
> 
> On Fri, 28 Mar 2008 16:10:11 -0700 (PDT) David Miller <davem@davemloft.net> wrote:
> 
> > From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
> > Date: Fri, 28 Mar 2008 23:52:10 +0100
> > 
> > > 	The gregkh-pci-pci-sparc64-use-generic-pci_enable_resources.patch which
> > > replaces arch-specific code with generic pci_enable_resources() makes my sparc64
> > > box unable to boot (that's what quilt bisection says). At first I see these messages:
> > 
> > Yes, that generic code won't work because of the NULL
> > r->parent check.
> > 
> > Alpha, ARM, V32, FRV, IA64, MIPS, MN10300, PARISC, PPC,
> > SH, V850, X86, and Xtensa are all likely to run into
> > problems because of this change.
> > 
> > The only platform that did the check as a test of r->parent
> > being NULL is Powerpc.
> > 
> > The rest either didn't check (like sparc64), or tested it by going:
> > 
> > 	if (!r->start && r->end)
> > 
> > So the amount of potential breakage from this change is enormous.
> 
> Cc: Bjorn Helgaas <bjorn.helgaas@hp.com>
> Cc: Greg KH <greg@kroah.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  arch/x86/pci/common.c |    2 +-
>  arch/x86/pci/i386.c   |   38 ++++++++++++++++++++++++++++++++++++++
>  arch/x86/pci/pci.h    |    1 +
>  3 files changed, 40 insertions(+), 1 deletion(-)
> 
> diff -puN arch/x86/pci/common.c~revert-gregkh-pci-pci-x86-use-generic-pci_enable_resources arch/x86/pci/common.c
> --- a/arch/x86/pci/common.c~revert-gregkh-pci-pci-x86-use-generic-pci_enable_resources
> +++ a/arch/x86/pci/common.c
> @@ -466,7 +466,7 @@ int pcibios_enable_device(struct pci_dev
>  {
>  	int err;
>  
> -	if ((err = pci_enable_resources(dev, mask)) < 0)
> +	if ((err = pcibios_enable_resources(dev, mask)) < 0)
>  		return err;
>  
>  	if (!dev->msi_enabled)
> diff -puN arch/x86/pci/i386.c~revert-gregkh-pci-pci-x86-use-generic-pci_enable_resources arch/x86/pci/i386.c
> --- a/arch/x86/pci/i386.c~revert-gregkh-pci-pci-x86-use-generic-pci_enable_resources
> +++ a/arch/x86/pci/i386.c
> @@ -238,6 +238,44 @@ void __init pcibios_resource_survey(void
>   */
>  fs_initcall(pcibios_assign_resources);
>  
> +int pcibios_enable_resources(struct pci_dev *dev, int mask)
> +{
> +	u16 cmd, old_cmd;
> +	int idx;
> +	struct resource *r;
> +
> +	pci_read_config_word(dev, PCI_COMMAND, &cmd);
> +	old_cmd = cmd;
> +	for (idx = 0; idx < PCI_NUM_RESOURCES; idx++) {
> +		/* Only set up the requested stuff */
> +		if (!(mask & (1 << idx)))
> +			continue;
> +
> +		r = &dev->resource[idx];
> +		if (!(r->flags & (IORESOURCE_IO | IORESOURCE_MEM)))
> +			continue;
> +		if ((idx = PCI_ROM_RESOURCE) &&
> +				(!(r->flags & IORESOURCE_ROM_ENABLE)))
> +			continue;
> +		if (!r->start && r->end) {
> +			printk(KERN_ERR "PCI: Device %s not available "
> +				"because of resource %d collisions\n",
> +				pci_name(dev), idx);
> +			return -EINVAL;
> +		}
> +		if (r->flags & IORESOURCE_IO)
> +			cmd |= PCI_COMMAND_IO;
> +		if (r->flags & IORESOURCE_MEM)
> +			cmd |= PCI_COMMAND_MEMORY;
> +	}
> +	if (cmd != old_cmd) {
> +		printk("PCI: Enabling device %s (%04x -> %04x)\n",
> +			pci_name(dev), old_cmd, cmd);
> +		pci_write_config_word(dev, PCI_COMMAND, cmd);
> +	}
> +	return 0;
> +}
> +
>  /*
>   *  If we set up a device for bus mastering, we need to check the latency
>   *  timer as certain crappy BIOSes forget to set it properly.
> diff -puN arch/x86/pci/pci.h~revert-gregkh-pci-pci-x86-use-generic-pci_enable_resources arch/x86/pci/pci.h
> --- a/arch/x86/pci/pci.h~revert-gregkh-pci-pci-x86-use-generic-pci_enable_resources
> +++ a/arch/x86/pci/pci.h
> @@ -42,6 +42,7 @@ enum pci_bf_sort_state {
>  extern unsigned int pcibios_max_latency;
>  
>  void pcibios_resource_survey(void);
> +int pcibios_enable_resources(struct pci_dev *, int);
>  
>  /* pci-pc.c */
>  
> _

