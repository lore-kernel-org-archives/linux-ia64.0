From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Date: Thu, 22 Jan 2015 20:25:23 +0000
Subject: Re: [PATCH v2 03/30] xen/PCI: Don't use deprecated function pci_scan_bus_parented()
Message-Id: <20150122202523.GC5813@l.oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1421800225-26230-1-git-send-email-wangyijing@huawei.com>
 <1421800225-26230-4-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1421800225-26230-4-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yijing Wang <wangyijing@huawei.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>, Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, xen-devel@lists.xenproject.org

On Wed, Jan 21, 2015 at 08:29:58AM +0800, Yijing Wang wrote:
> From: Arnd Bergmann <arnd@arndb.de>
> 
> Use pci_scan_root_bus() instead of deprecated function
> pci_scan_bus_parented().
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
> CC: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> CC: xen-devel@lists.xenproject.org

It looks OK to me thought I need to test it first.
> ---
>  drivers/pci/xen-pcifront.c |   10 +++++++---
>  1 files changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/pci/xen-pcifront.c b/drivers/pci/xen-pcifront.c
> index b1ffebe..240ddbc 100644
> --- a/drivers/pci/xen-pcifront.c
> +++ b/drivers/pci/xen-pcifront.c
> @@ -446,6 +446,7 @@ static int pcifront_scan_root(struct pcifront_device *pdev,
>  				 unsigned int domain, unsigned int bus)
>  {
>  	struct pci_bus *b;
> +	LIST_HEAD(resources);
>  	struct pcifront_sd *sd = NULL;
>  	struct pci_bus_entry *bus_entry = NULL;
>  	int err = 0;
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
> +	b = pci_scan_root_bus(&pdev->xdev->dev, bus,
> +				  &pcifront_bus_ops, sd, &resources);
>  	if (!b) {
>  		dev_err(&pdev->xdev->dev,
>  			"Error creating PCI Frontend Bus!\n");
>  		err = -ENOMEM;
>  		pci_unlock_rescan_remove();
> +		pci_free_resource_list(&resources);
>  		goto err_out;
>  	}
>  
> @@ -488,7 +492,7 @@ static int pcifront_scan_root(struct pcifront_device *pdev,
>  
>  	list_add(&bus_entry->list, &pdev->root_buses);
>  
> -	/* pci_scan_bus_parented skips devices which do not have a have
> +	/* pci_scan_root_bus skips devices which do not have a have
>  	* devfn=0. The pcifront_scan_bus enumerates all devfn. */
>  	err = pcifront_scan_bus(pdev, domain, bus, b);
>  
> -- 
> 1.7.1
> 
