From: Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>
Date: Mon, 17 Nov 2014 12:08:39 +0000
Subject: Re: [RFC PATCH 14/16] arm/PCI: Introduce pci_get_domain_nr()
Message-Id: <20141117120839.GA22241@e102568-lin.cambridge.arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1416219710-26088-1-git-send-email-wangyijing@huawei.com>
 <1416219710-26088-15-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1416219710-26088-15-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yijing Wang <wangyijing@huawei.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "huxinwei@huawei.com" <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Russell King <linux@arm.linux.org.uk>, "x86@kernel.org" <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Thierry Reding <thierry.reding@gmail.com>, Liviu Dudau <liviu@dudau.co.uk>, "suravee.suthikulpanit@amd.com" <suravee.suthikulpanit@amd.com>

On Mon, Nov 17, 2014 at 10:21:48AM +0000, Yijing Wang wrote:
> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
> ---
>  arch/arm/include/asm/mach/pci.h |    9 +++++++++
>  arch/arm/kernel/bios32.c        |    8 ++++++--
>  2 files changed, 15 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/arm/include/asm/mach/pci.h b/arch/arm/include/asm/mach/pci.h
> index f19f627..370b3bd 100644
> --- a/arch/arm/include/asm/mach/pci.h
> +++ b/arch/arm/include/asm/mach/pci.h
> @@ -90,6 +90,15 @@ extern void pci_map_io_early(unsigned long pfn);
>  static inline void pci_map_io_early(unsigned long pfn) {}
>  #endif
>  
> +#ifdef CONFIG_PCI_DOMAINS_GENERIC
> +int pci_get_domain_nr(struct device *parent)
> +#else
> +static inline int pci_get_domain_nr(struct device *parent)
> +{
> +	return 0;
> +}
> +#endif
> +
>  /*
>   * PCI controllers
>   */
> diff --git a/arch/arm/kernel/bios32.c b/arch/arm/kernel/bios32.c
> index d8c2b4e..3fe56f1 100644
> --- a/arch/arm/kernel/bios32.c
> +++ b/arch/arm/kernel/bios32.c
> @@ -513,7 +513,7 @@ static void pcibios_init_hw(struct device *parent, struct hw_pci *hw,
>  #ifdef CONFIG_PCI_DOMAINS_GENERIC
>  static bool dt_domain_found;
>  
> -void pci_bus_assign_domain_nr(struct pci_bus *bus, struct device *parent)
> +int pci_get_domain_nr(struct device *parent)
>  {
>  	int domain = of_get_pci_domain_nr(parent->of_node);
>  
> @@ -526,8 +526,12 @@ void pci_bus_assign_domain_nr(struct pci_bus *bus, struct device *parent)
>  	} else {
>  		domain = pci_get_new_domain_nr();
>  	}
> +	return domain;
> +}
>  
> -	bus->domain_nr = domain;
> +void pci_bus_assign_domain_nr(struct pci_bus *bus, struct device *parent)
> +{
> +	bus->domain_nr = pci_get_domain_nr(parent);
>  }
>  #endif

This code is superseded by the last patches I sent to move the domain
assignment to PCI core code.

http://lists.infradead.org/pipermail/linux-arm-kernel/2014-November/301220.html

Lorenzo

