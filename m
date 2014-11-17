From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 17 Nov 2014 10:56:36 +0000
Subject: Re: [RFC PATCH 07/16] PCI: Separate pci_host_bridge creation out of pci_create_root_bus()
Message-Id: <2507218.mHliopJb05@wuerfel>
List-Id: <linux-ia64.vger.kernel.org>
References: <1416219710-26088-1-git-send-email-wangyijing@huawei.com> <1416219710-26088-8-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1416219710-26088-8-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linuxppc-dev@lists.ozlabs.org
Cc: Yijing Wang <wangyijing@huawei.com>, Bjorn Helgaas <bhelgaas@google.com>, Liviu Dudau <liviu@dudau.co.uk>, Tony Luck <tony.luck@intel.com>, Russell King <linux@arm.linux.org.uk>, linux-pci@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Thierry Reding <thierry.reding@gmail.com>, Suravee.Suthikulpanit@amd.com, linux-ia64@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Wuyun <wuyun.wu@huawei.com>, linux-arm-kernel@lists.infradead.org

On Monday 17 November 2014 18:21:41 Yijing Wang wrote:
> There are some common PCI infos like domain, msi_controller, these
> infos are saved in arch PCI sysdata, and lots arch specific functions
> like pci_domain_nr() and pcibios_msi_controller() required.
> We could separate pci_host_bridge creation out of pci_create_root_bus(),
> then we could put the common infos in, then we could eliminate
> the arch specifc functions.
> 
> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
> ---
>  drivers/pci/host-bridge.c |   99 +++++++++++++++++++++++++++++++++
>  drivers/pci/probe.c       |  134 ++++++++++++++++----------------------------
>  include/linux/pci.h       |   11 +++-
>  3 files changed, 158 insertions(+), 86 deletions(-)
> 
> diff --git a/drivers/pci/host-bridge.c b/drivers/pci/host-bridge.c
> index 0e5f3c9..e31604f 100644
> --- a/drivers/pci/host-bridge.c
> +++ b/drivers/pci/host-bridge.c
> @@ -8,6 +8,105 @@
>  
>  #include "pci.h"
>  
> +LIST_HEAD(pci_host_bridge_list);
> +DECLARE_RWSEM(pci_host_bridge_sem);

Unless the pci_host_bridge_sem is accessed thousands of times per second,
it's normally better to use a simple mutex instead.

> +static struct resource busn_resource = {
> +	.name	= "PCI busn",
> +	.start	= 0,
> +	.end	= 255,
> +	.flags	= IORESOURCE_BUS,
> +};

I think it would be better to require callers to pass the bus resource
down to the function.

> +struct pci_host_bridge *pci_create_host_bridge(
> +		struct device *parent, u32 db, 
> +		struct pci_ops *ops, void *sysdata, 
> +		struct list_head *resources)
> +{

Do we still need to pass the 'sysdata' in here? If we are guaranteed to
have a device pointer, we should always be able to get the driver
private data from dev_get_drvdata(host->dev->parent).

> +	host = kzalloc(sizeof(*host), GFP_KERNEL);
> +	if (!host)
> +		return NULL;

devm_kzalloc maybe?

> +	if (!resources) {
> +		/* Use default IO/MEM/BUS resources*/
> +		pci_add_resource(&host->windows, &ioport_resource);
> +		pci_add_resource(&host->windows, &iomem_resource);
> +		pci_add_resource(&host->windows, &busn_resource);
> +	} else {
> +		list_for_each_entry_safe(window, n, resources, list)
> +			list_move_tail(&window->list, &host->windows);
> +	}

I think we should assume that the correct resources are passed. You
could add a wrapper around this function to convert old platforms
though.

> +EXPORT_SYMBOL(pci_create_host_bridge);

EXPORT_SYMBOL_GPL() maybe?

> diff --git a/include/linux/pci.h b/include/linux/pci.h
> index 8b11b38..daa7f40 100644
> --- a/include/linux/pci.h
> +++ b/include/linux/pci.h
> @@ -402,7 +402,12 @@ struct pci_host_bridge_window {
>  struct pci_host_bridge {
>  	struct device dev;
>  	struct pci_bus *bus;		/* root bus */
> +	struct list_head list;
>  	struct list_head windows;	/* pci_host_bridge_windows */
> +	int busnum;

The busnum should already be implied through the bus resource.

	Arnd
