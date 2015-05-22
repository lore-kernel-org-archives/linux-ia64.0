From: Hanjun Guo <hanjun.guo@linaro.org>
Date: Fri, 22 May 2015 13:42:23 +0000
Subject: Re: [Patch v3 2/7] ia64/PCI/ACPI: Use common ACPI resource parsing interface for host bridge
Message-Id: <555F323F.3020107@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1431593803-5213-1-git-send-email-jiang.liu@linux.intel.com> <1431593803-5213-3-git-send-email-jiang.liu@linux.intel.com>
In-Reply-To: <1431593803-5213-3-git-send-email-jiang.liu@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Jiang Liu <jiang.liu@linux.intel.com>, "Rafael J . Wysocki" <rjw@rjwysocki.net>, Bjorn Helgaas <bhelgaas@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Yijing Wang <wangyijing@huawei.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Yinghai Lu <yinghai@kernel.org>
Cc: Lv Zheng <lv.zheng@intel.com>, "lenb @ kernel . org" <lenb@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, "x86 @ kernel . org" <x86@kernel.org>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org

On 2015年05月14日 16:56, Jiang Liu wrote:
> Use common ACPI resource parsing interface to parse ACPI resources for
> PCI host bridge, so we could share more code between IA64 and x86.
> Later we will consolidate arch specific implementations into ACPI core.
>
> Tested-by: Tony Luck <tony.luck@intel.com>
> Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
> ---
>   arch/ia64/pci/pci.c |  414 ++++++++++++++++++++++++---------------------------
>   1 file changed, 193 insertions(+), 221 deletions(-)
>
> diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
> index d4e162d35b34..23689d4c37ae 100644
> --- a/arch/ia64/pci/pci.c
> +++ b/arch/ia64/pci/pci.c
> @@ -115,29 +115,12 @@ struct pci_ops pci_root_ops = {
>   	.write = pci_write,
>   };
>
> -/* Called by ACPI when it finds a new root bus.  */
> -
> -static struct pci_controller *alloc_pci_controller(int seg)
> -{
> -	struct pci_controller *controller;
> -
> -	controller = kzalloc(sizeof(*controller), GFP_KERNEL);
> -	if (!controller)
> -		return NULL;
> -
> -	controller->segment = seg;
> -	return controller;
> -}
> -
>   struct pci_root_info {
> +	struct pci_controller controller;
>   	struct acpi_device *bridge;
> -	struct pci_controller *controller;
>   	struct list_head resources;
> -	struct resource *res;
> -	resource_size_t *res_offset;
> -	unsigned int res_num;
>   	struct list_head io_resources;
> -	char *name;
> +	char name[16];
>   };
>
>   static unsigned int
> @@ -168,11 +151,11 @@ new_space (u64 phys_base, int sparse)
>   	return i;
>   }
>
> -static u64 add_io_space(struct pci_root_info *info,
> -			struct acpi_resource_address64 *addr)
> +static int add_io_space(struct device *dev, struct pci_root_info *info,
> +			struct resource_entry *entry)
>   {
>   	struct iospace_resource *iospace;
> -	struct resource *resource;
> +	struct resource *resource, *res = entry->res;
>   	char *name;
>   	unsigned long base, min, max, base_port;
>   	unsigned int sparse = 0, space_nr, len;
> @@ -180,27 +163,24 @@ static u64 add_io_space(struct pci_root_info *info,
>   	len = strlen(info->name) + 32;
>   	iospace = kzalloc(sizeof(*iospace) + len, GFP_KERNEL);
>   	if (!iospace) {
> -		dev_err(&info->bridge->dev,
> -				"PCI: No memory for %s I/O port space\n",
> -				info->name);
> -		goto out;
> +		dev_err(dev, "PCI: No memory for %s I/O port space\n",
> +			info->name);
> +		return -ENOMEM;
>   	}
>
> -	name = (char *)(iospace + 1);
> -
> -	min = addr->address.minimum;
> -	max = min + addr->address.address_length - 1;
> -	if (addr->info.io.translation_type = ACPI_SPARSE_TRANSLATION)
> +	if (res->flags & IORESOURCE_IO_SPARSE)
>   		sparse = 1;
> -
> -	space_nr = new_space(addr->address.translation_offset, sparse);
> +	space_nr = new_space(entry->offset, sparse);
>   	if (space_nr = ~0)
>   		goto free_resource;
>
> +	name = (char *)(iospace + 1);
> +	min = res->start - entry->offset;
> +	max = res->end - entry->offset;
>   	base = __pa(io_space[space_nr].mmio_base);
>   	base_port = IO_SPACE_BASE(space_nr);
>   	snprintf(name, len, "%s I/O Ports %08lx-%08lx", info->name,
> -		base_port + min, base_port + max);
> +		 base_port + min, base_port + max);
>
>   	/*
>   	 * The SDM guarantees the legacy 0-64K space is sparse, but if the
> @@ -216,153 +196,195 @@ static u64 add_io_space(struct pci_root_info *info,
>   	resource->start = base + (sparse ? IO_SPACE_SPARSE_ENCODING(min) : min);
>   	resource->end   = base + (sparse ? IO_SPACE_SPARSE_ENCODING(max) : max);
>   	if (insert_resource(&iomem_resource, resource)) {
> -		dev_err(&info->bridge->dev,
> -				"can't allocate host bridge io space resource  %pR\n",
> -				resource);
> +		dev_err(dev,
> +			"can't allocate host bridge io space resource  %pR\n",
> +			resource);
>   		goto free_resource;
>   	}
>
> +	entry->offset = base_port;
> +	res->start = min + base_port;
> +	res->end = max + base_port;
>   	list_add_tail(&iospace->list, &info->io_resources);
> -	return base_port;
> +
> +	return 0;
>
>   free_resource:
>   	kfree(iospace);
> -out:
> -	return ~0;
> +	return -ENOSPC;
> +}
> +
> +/*
> + * An IO port or MMIO resource assigned to a PCI host bridge may be
> + * consumed by the host bridge itself or available to its child
> + * bus/devices. The ACPI specification defines a bit (Producer/Consumer)
> + * to tell whether the resource is consumed by the host bridge itself,
> + * but firmware hasn't used that bit consistently, so we can't rely on it.

If we make the firmware obey to the ACPI spec, and
...

> + *
> + * On x86 and IA64 platforms, all IO port and MMIO resources are assumed
> + * to be available to child bus/devices except one special case:
> + *     IO port [0xCF8-0xCFF] is consumed by the host bridge itself
> + *     to access PCI configuration space.
> + *
> + * So explicitly filter out PCI CFG IO ports[0xCF8-0xCFF].

This is not going to happen on ARM64, right?

but this question is not about the patch itself, so for this patch

Reviewed-by: Hanjun Guo <hanjun.guo@linaro.org>

Thanks
Hanjun
