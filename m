From: Yijing Wang <wangyijing@huawei.com>
Date: Thu, 20 Nov 2014 01:53:48 +0000
Subject: Re: [PATCH 3/5] PCI: Use pci_scan_bus_simple() in simple scene.
Message-Id: <546D49AC.4020207@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1416382369-13587-1-git-send-email-wangyijing@huawei.com> <1416382369-13587-4-git-send-email-wangyijing@huawei.com> <3577231.2krnYe8yCU@wuerfel>
In-Reply-To: <3577231.2krnYe8yCU@wuerfel>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>, linux-arm-kernel@lists.infradead.org
Cc: Bjorn Helgaas <bhelgaas@google.com>, Liviu Dudau <liviu@dudau.co.uk>, Tony Luck <tony.luck@intel.com>, Russell King <linux@arm.linux.org.uk>, linux-pci@vger.kernel.org, x86@kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, linux-ia64@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>

On 2014/11/19 20:28, Arnd Bergmann wrote:
> On Wednesday 19 November 2014 15:32:47 Yijing Wang wrote:
>> Use pci_scan_bus_simple() to scan pci buses with
>> the default IO/MEM/BUS resources. Use it instead
>> of pci_scan_bus() and pci_scan_bus_parented().
>>
>> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
>>
> 
> I think we should replace pci_scan_bus_parented() with something better
> by making the xen code use pci_scan_root_bus() (see below for a draft
> patch). After that we no longer need the 'parent' argument here and we
> can just keep using the pci_scan_bus() function for the legacy users,
> or rename it if that helps.

It make sense to me, and we could rename pci_scan_bus() to pci_scan_bus_legacy().
Thanks, I will add this to my series,


> 
> 	Arnd
> 
> 
> 8<---
> 
> diff --git a/drivers/pci/xen-pcifront.c b/drivers/pci/xen-pcifront.c
> index 116ca3746adb..45a4843a608a 100644
> --- a/drivers/pci/xen-pcifront.c
> +++ b/drivers/pci/xen-pcifront.c
> @@ -448,6 +448,7 @@ static int pcifront_scan_root(struct pcifront_device *pdev,
>  	struct pci_bus *b;
>  	struct pcifront_sd *sd = NULL;
>  	struct pci_bus_entry *bus_entry = NULL;
> +	LIST_HEAD(resources);
>  	int err = 0;
>  
>  #ifndef CONFIG_PCI_DOMAINS
> @@ -470,17 +471,20 @@ static int pcifront_scan_root(struct pcifront_device *pdev,
>  		err = -ENOMEM;
>  		goto err_out;
>  	}
> +	pci_add_resource(&resources, &ioport_resource);
> +	pci_add_resource(&resources, &iomem_resource);
>  	pcifront_init_sd(sd, domain, bus, pdev);
>  
>  	pci_lock_rescan_remove();
>  
> -	b = pci_scan_bus_parented(&pdev->xdev->dev, bus,
> -				  &pcifront_bus_ops, sd);
> +	b = pci_scan_root_bus(&pdev->xdev->dev, bus, &pcifront_bus_ops, sd,
> +			      &resources);
>  	if (!b) {
>  		dev_err(&pdev->xdev->dev,
>  			"Error creating PCI Frontend Bus!\n");
>  		err = -ENOMEM;
>  		pci_unlock_rescan_remove();
> +		pci_free_resource_list(&resources);
>  		goto err_out;
>  	}
>  
> 
> 
> .
> 


-- 
Thanks!
Yijing

