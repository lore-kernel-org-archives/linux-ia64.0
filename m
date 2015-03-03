From: Bjorn Helgaas <bhelgaas@google.com>
Date: Tue, 03 Mar 2015 02:02:49 +0000
Subject: Re: [PATCH v4 03/30] xen/PCI: Don't use deprecated function pci_scan_bus_parented()
Message-Id: <20150303020249.GC11978@google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1424938344-4017-1-git-send-email-wangyijing@huawei.com>
 <1424938344-4017-4-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1424938344-4017-4-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yijing Wang <wangyijing@huawei.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org

On Thu, Feb 26, 2015 at 04:11:57PM +0800, Yijing Wang wrote:
> From: Arnd Bergmann <arnd@arndb.de>
> 
> Use pci_scan_root_bus() instead of deprecated function
> pci_scan_bus_parented().
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
> CC: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> CC: xen-devel@lists.xenproject.org
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

This doesn't add &busn_resource like pci_scan_bus_parented() does.
That might be OK, but I think we'll now emit "No busn resource found for
root bus, will use [bus %02x-ff]" when we didn't before.  I don't know how
xen-pcifront works; it would be nice if it could supply the correct
bus resource (and ioport and iomem).

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

Please fix the comment typo at the same time ("have a have").

>  	* devfn=0. The pcifront_scan_bus enumerates all devfn. */
>  	err = pcifront_scan_bus(pdev, domain, bus, b);
>  
> -- 
> 1.7.1
> 
