From: Hanjun Guo <hanjun.guo@linaro.org>
Date: Fri, 22 May 2015 13:46:38 +0000
Subject: Re: [Patch v3 3/7] ia64/PCI: Use common struct resource_entry to replace struct iospace_resource
Message-Id: <555F333E.10605@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1431593803-5213-1-git-send-email-jiang.liu@linux.intel.com> <1431593803-5213-4-git-send-email-jiang.liu@linux.intel.com>
In-Reply-To: <1431593803-5213-4-git-send-email-jiang.liu@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Jiang Liu <jiang.liu@linux.intel.com>, "Rafael J . Wysocki" <rjw@rjwysocki.net>, Bjorn Helgaas <bhelgaas@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Yijing Wang <wangyijing@huawei.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Yinghai Lu <yinghai@kernel.org>
Cc: Lv Zheng <lv.zheng@intel.com>, "lenb @ kernel . org" <lenb@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, "x86 @ kernel . org" <x86@kernel.org>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org

On 2015年05月14日 16:56, Jiang Liu wrote:
> Use common struct resource_entry to replace private
> struct iospace_resource.
>
> Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
> ---
>   arch/ia64/include/asm/pci.h |    5 -----
>   arch/ia64/pci/pci.c         |   17 ++++++++---------
>   2 files changed, 8 insertions(+), 14 deletions(-)
>
> diff --git a/arch/ia64/include/asm/pci.h b/arch/ia64/include/asm/pci.h
> index 52af5ed9f60b..5c10e0ec48d4 100644
> --- a/arch/ia64/include/asm/pci.h
> +++ b/arch/ia64/include/asm/pci.h
> @@ -83,11 +83,6 @@ extern int pci_mmap_legacy_page_range(struct pci_bus *bus,
>   #define pci_legacy_read platform_pci_legacy_read
>   #define pci_legacy_write platform_pci_legacy_write
>
> -struct iospace_resource {
> -	struct list_head list;
> -	struct resource res;
> -};
> -
>   struct pci_controller {
>   	struct acpi_device *companion;
>   	void *iommu;
> diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
> index 23689d4c37ae..4af1b52c7a44 100644
> --- a/arch/ia64/pci/pci.c
> +++ b/arch/ia64/pci/pci.c
> @@ -154,14 +154,14 @@ new_space (u64 phys_base, int sparse)
>   static int add_io_space(struct device *dev, struct pci_root_info *info,
>   			struct resource_entry *entry)
>   {
> -	struct iospace_resource *iospace;
> +	struct resource_entry *iospace;
>   	struct resource *resource, *res = entry->res;
>   	char *name;
>   	unsigned long base, min, max, base_port;
>   	unsigned int sparse = 0, space_nr, len;
>
>   	len = strlen(info->name) + 32;
> -	iospace = kzalloc(sizeof(*iospace) + len, GFP_KERNEL);
> +	iospace = resource_list_create_entry(NULL, len);
>   	if (!iospace) {
>   		dev_err(dev, "PCI: No memory for %s I/O port space\n",
>   			info->name);
> @@ -190,7 +190,7 @@ static int add_io_space(struct device *dev, struct pci_root_info *info,
>   	if (space_nr = 0)
>   		sparse = 1;
>
> -	resource = &iospace->res;
> +	resource = iospace->res;
>   	resource->name  = name;
>   	resource->flags = IORESOURCE_MEM;
>   	resource->start = base + (sparse ? IO_SPACE_SPARSE_ENCODING(min) : min);
> @@ -205,12 +205,12 @@ static int add_io_space(struct device *dev, struct pci_root_info *info,
>   	entry->offset = base_port;
>   	res->start = min + base_port;
>   	res->end = max + base_port;
> -	list_add_tail(&iospace->list, &info->io_resources);
> +	resource_list_add_tail(iospace, &info->io_resources);
>
>   	return 0;
>
>   free_resource:
> -	kfree(iospace);
> +	resource_list_free_entry(iospace);
>   	return -ENOSPC;
>   }
>
> @@ -369,12 +369,11 @@ static void add_resources(struct pci_root_info *info, struct device *dev)
>   static void __release_pci_root_info(struct pci_root_info *info)
>   {
>   	struct resource *res;
> -	struct iospace_resource *iospace, *tmp;
>   	struct resource_entry *entry, *tentry;
>
> -	list_for_each_entry_safe(iospace, tmp, &info->io_resources, list) {
> -		release_resource(&iospace->res);
> -		kfree(iospace);
> +	resource_list_for_each_entry_safe(entry, tentry, &info->io_resources) {
> +		release_resource(entry->res);
> +		resource_list_destroy_entry(entry);
>   	}
>
>   	resource_list_for_each_entry_safe(entry, tentry, &info->resources) {


Reviewed-by: Hanjun Guo <hanjun.guo@linaro.org>

Thanks
Hanjun
