From: Bjorn Helgaas <helgaas@kernel.org>
Date: Mon, 19 Mar 2018 18:57:34 +0000
Subject: Re: [PATCH] PCI/MSI: Don't set up INTx if MSI or MSI-X is enabled
Message-Id: <20180319185734.GF77194@bhelgaas-glaptop.roam.corp.google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <152097754955.241946.9551793957889760940.stgit@bhelgaas-glaptop.roam.corp.google.com>
In-Reply-To: <152097754955.241946.9551793957889760940.stgit@bhelgaas-glaptop.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-pci@vger.kernel.org
Cc: Mikael Starvik <starvik@axis.com>, Jesper Nilsson <jesper.nilsson@axis.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, David Howells <dhowells@redhat.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, linux-cris-kernel@axis.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-am33-list@redhat.com

On Tue, Mar 13, 2018 at 04:45:49PM -0500, Bjorn Helgaas wrote:
> From: Bjorn Helgaas <bhelgaas@google.com>
> 
> If a device already has MSI or MSI-X enabled, there's no need to set up its
> legacy INTx interrupt.
> 
> bba6f6fc68e7 ("[PATCH] MSI-X: fix resume crash") changed the cris, frv,
> x86, and ia64 arches to skip INTx setup when MSI is enabled.
> 
> 16cf0ebc35dd ("x86/PCI: Do not use interrupt links for devices using
> MSI-X") extended that by changing x86 to also skip INTx setup when MSI-X is
> enabled.
> 
> Change the remaining arches (cris, frv, and ia64) to skip INTx setup when
> either MSI or MSI-X is enabled.
> 
> Also update mn10300 (which didn't exist at the time of bba6f6fc68e7) to
> follow the same pattern.
> 
> Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>

Applied to pci/msi with tested-by from Tony and reviewed-by Rafael and
Andy.  And I added a note to my to-do list about getting rid of
pcibios_enable_device().

> ---
>  arch/cris/arch-v32/drivers/pci/bios.c |    2 +-
>  arch/frv/mb93090-mb00/pci-vdk.c       |    2 +-
>  arch/ia64/pci/pci.c                   |    4 ++--
>  arch/mn10300/unit-asb2305/pci.c       |    8 +++++---
>  4 files changed, 9 insertions(+), 7 deletions(-)
> 
> diff --git a/arch/cris/arch-v32/drivers/pci/bios.c b/arch/cris/arch-v32/drivers/pci/bios.c
> index 6b9e6cfaa29e..c2bed0cc060b 100644
> --- a/arch/cris/arch-v32/drivers/pci/bios.c
> +++ b/arch/cris/arch-v32/drivers/pci/bios.c
> @@ -68,7 +68,7 @@ int pcibios_enable_device(struct pci_dev *dev, int mask)
>  	if ((err = pcibios_enable_resources(dev, mask)) < 0)
>  		return err;
>  
> -	if (!dev->msi_enabled)
> +	if (!pci_dev_msi_enabled(dev))
>  		pcibios_enable_irq(dev);
>  	return 0;
>  }
> diff --git a/arch/frv/mb93090-mb00/pci-vdk.c b/arch/frv/mb93090-mb00/pci-vdk.c
> index f211839e2cae..4a55d1b82d21 100644
> --- a/arch/frv/mb93090-mb00/pci-vdk.c
> +++ b/arch/frv/mb93090-mb00/pci-vdk.c
> @@ -413,7 +413,7 @@ int pcibios_enable_device(struct pci_dev *dev, int mask)
>  
>  	if ((err = pci_enable_resources(dev, mask)) < 0)
>  		return err;
> -	if (!dev->msi_enabled)
> +	if (!pci_dev_msi_enabled(dev))
>  		pcibios_enable_irq(dev);
>  	return 0;
>  }
> diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
> index f5ec736100ee..7ccc64d5fe3e 100644
> --- a/arch/ia64/pci/pci.c
> +++ b/arch/ia64/pci/pci.c
> @@ -398,7 +398,7 @@ pcibios_enable_device (struct pci_dev *dev, int mask)
>  	if (ret < 0)
>  		return ret;
>  
> -	if (!dev->msi_enabled)
> +	if (!pci_dev_msi_enabled(dev))
>  		return acpi_pci_irq_enable(dev);
>  	return 0;
>  }
> @@ -407,7 +407,7 @@ void
>  pcibios_disable_device (struct pci_dev *dev)
>  {
>  	BUG_ON(atomic_read(&dev->enable_cnt));
> -	if (!dev->msi_enabled)
> +	if (!pci_dev_msi_enabled(dev))
>  		acpi_pci_irq_disable(dev);
>  }
>  
> diff --git a/arch/mn10300/unit-asb2305/pci.c b/arch/mn10300/unit-asb2305/pci.c
> index 3dfe2d31c67b..4d36ea517679 100644
> --- a/arch/mn10300/unit-asb2305/pci.c
> +++ b/arch/mn10300/unit-asb2305/pci.c
> @@ -399,10 +399,12 @@ int pcibios_enable_device(struct pci_dev *dev, int mask)
>  {
>  	int err;
>  
> -	err = pci_enable_resources(dev, mask);
> -	if (err = 0)
> +	if ((err = pci_enable_resources(dev, mask)) < 0)
> +		return err;
> +
> +	if (!pci_dev_msi_enabled(dev))
>  		pcibios_enable_irq(dev);
> -	return err;
> +	return 0;
>  }
>  
>  /*
> 
