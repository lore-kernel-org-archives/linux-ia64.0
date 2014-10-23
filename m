From: Bjorn Helgaas <bhelgaas@google.com>
Date: Thu, 23 Oct 2014 05:38:58 +0000
Subject: Re: [PATCH v3 09/27] arm/PCI: Clean unused pcibios_add_bus() and pcibios_remove_bus()
Message-Id: <20141023053858.GD11770@google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1413342435-7876-1-git-send-email-wangyijing@huawei.com>
 <1413342435-7876-10-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1413342435-7876-10-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yijing Wang <wangyijing@huawei.com>
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, linux-arch@vger.kernel.org, arnab.basu@freescale.com, Bharat.Bhushan@freescale.com, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Ralf Baechle <ralf@linux-mips.org>, Lucas Stach <l.stach@pengutronix.de>, David Vrabel <david.vrabel@citrix.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, Michael Ellerman <mpe@ellerman.id.au>, Thierry Reding <thierry.reding@gmail.com>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Liviu Dudau <liviu@dudau.co.uk>

On Wed, Oct 15, 2014 at 11:06:57AM +0800, Yijing Wang wrote:
> MSI chip will be saved in pci_sys_data, now we can
> clean up pcibios_add_bus() and pcibios_remove_bus()
> in arm, and use pci_find_msi_chip() to get msi chip
> in core MSI code.
> 
> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
> ---
>  arch/arm/include/asm/mach/pci.h |    4 ----
>  arch/arm/kernel/bios32.c        |   16 ----------------
>  drivers/pci/msi.c               |   11 +++--------
>  3 files changed, 3 insertions(+), 28 deletions(-)
> 
> diff --git a/arch/arm/include/asm/mach/pci.h b/arch/arm/include/asm/mach/pci.h
> index 59b0d87..230b2c9 100644
> --- a/arch/arm/include/asm/mach/pci.h
> +++ b/arch/arm/include/asm/mach/pci.h
> @@ -39,8 +39,6 @@ struct hw_pci {
>  					  resource_size_t start,
>  					  resource_size_t size,
>  					  resource_size_t align);
> -	void		(*add_bus)(struct pci_bus *bus);
> -	void		(*remove_bus)(struct pci_bus *bus);
>  };
>  
>  /*
> @@ -71,8 +69,6 @@ struct pci_sys_data {
>  					  resource_size_t start,
>  					  resource_size_t size,
>  					  resource_size_t align);
> -	void		(*add_bus)(struct pci_bus *bus);
> -	void		(*remove_bus)(struct pci_bus *bus);
>  	void		*private_data;	/* platform controller private data	*/
>  };
>  
> diff --git a/arch/arm/kernel/bios32.c b/arch/arm/kernel/bios32.c
> index a19038d..b1b872e 100644
> --- a/arch/arm/kernel/bios32.c
> +++ b/arch/arm/kernel/bios32.c
> @@ -360,20 +360,6 @@ void pcibios_fixup_bus(struct pci_bus *bus)
>  }
>  EXPORT_SYMBOL(pcibios_fixup_bus);
>  
> -void pcibios_add_bus(struct pci_bus *bus)
> -{
> -	struct pci_sys_data *sys = bus->sysdata;
> -	if (sys->add_bus)
> -		sys->add_bus(bus);
> -}
> -
> -void pcibios_remove_bus(struct pci_bus *bus)
> -{
> -	struct pci_sys_data *sys = bus->sysdata;
> -	if (sys->remove_bus)
> -		sys->remove_bus(bus);
> -}
> -
>  /*
>   * Swizzle the device pin each time we cross a bridge.  If a platform does
>   * not provide a swizzle function, we perform the standard PCI swizzling.
> @@ -478,8 +464,6 @@ static void pcibios_init_hw(struct device *parent, struct hw_pci *hw,
>  		sys->swizzle = hw->swizzle;
>  		sys->map_irq = hw->map_irq;
>  		sys->align_resource = hw->align_resource;
> -		sys->add_bus = hw->add_bus;
> -		sys->remove_bus = hw->remove_bus;
>  		INIT_LIST_HEAD(&sys->resources);
>  
>  		if (hw->private_data)

What do the core changes below have to do with the ARM changes above?
They should be a separate patch unless they can't be separated.

> diff --git a/drivers/pci/msi.c b/drivers/pci/msi.c
> index f11108c..56e54ad 100644
> --- a/drivers/pci/msi.c
> +++ b/drivers/pci/msi.c
> @@ -32,12 +32,10 @@ int pci_msi_ignore_mask;
>  
>  int __weak arch_setup_msi_irq(struct pci_dev *dev, struct msi_desc *desc)
>  {
> -	struct msi_chip *chip = dev->bus->msi;
> +	struct msi_chip *chip;
>  	int err;
>  
> -	if (!chip)
> -		chip = pci_msi_chip(dev->bus);
> -
> +	chip = pci_msi_chip(dev->bus);
>  	if (!chip || !chip->setup_irq)
>  		return -EINVAL;
>  
> @@ -51,10 +49,7 @@ int __weak arch_setup_msi_irq(struct pci_dev *dev, struct msi_desc *desc)
>  void __weak arch_teardown_msi_irq(unsigned int irq)
>  {
>  	struct msi_desc *entry = irq_get_msi_desc(irq);
> -	struct msi_chip *chip = entry->dev->bus->msi;
> -
> -	if (!chip)
> -		chip = pci_msi_chip(entry->dev->bus);
> +	struct msi_chip *chip = pci_msi_chip(entry->dev->bus);
>  
>  	if (!chip || !chip->teardown_irq)
>  		return;
> -- 
> 1.7.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-pci" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
