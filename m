From: KY Srinivasan <kys@microsoft.com>
Date: Thu, 05 Feb 2015 15:49:30 +0000
Subject: RE: [Patch v4 01/23] ACPICA: Resources: Provide common part for struct acpi_resource_address structu
Message-Id: <BY2PR0301MB0711A14B73ED25E48F16D01EA03B0@BY2PR0301MB0711.namprd03.prod.outlook.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1423115089-12904-1-git-send-email-jiang.liu@linux.intel.com>
 <1423115089-12904-2-git-send-email-jiang.liu@linux.intel.com>
In-Reply-To: <1423115089-12904-2-git-send-email-jiang.liu@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jiang Liu <jiang.liu@linux.intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Thomas Gleixner <tglx@linutronix.de>, Bjorn Helgaas <bhelgaas@google.com>, Yinghai Lu <yinghai@kernel.org>, Borislav Petkov <bp@alien8.de>, Lv Zheng <lv.zheng@intel.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, Len Brown <lenb@kernel.org>, Robert Moore <robert.moore@intel.com>, Clemens Ladisch <clemens@ladisch.de>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Haiyang Zhang <haiyangz@microsoft.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Vrabel <david.vrabel@citrix.com>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, "devel@acpica.org" <devel@acpica.org>



> -----Original Message-----
> From: Jiang Liu [mailto:jiang.liu@linux.intel.com]
> Sent: Wednesday, February 4, 2015 9:44 PM
> To: Rafael J. Wysocki; Thomas Gleixner; Bjorn Helgaas; Yinghai Lu; Borislav
> Petkov; Lv Zheng; Tony Luck; Fenghua Yu; Ingo Molnar; H. Peter Anvin;
> x86@kernel.org; Len Brown; Robert Moore; Clemens Ladisch; Arnd
> Bergmann; Greg Kroah-Hartman; KY Srinivasan; Haiyang Zhang; Konrad
> Rzeszutek Wilk; Boris Ostrovsky; David Vrabel
> Cc: linux-kernel@vger.kernel.org; linux-pci@vger.kernel.org; linux-
> acpi@vger.kernel.org; Jiang Liu; linux-ia64@vger.kernel.org;
> devel@acpica.org; devel@linuxdriverproject.org; xen-
> devel@lists.xenproject.org
> Subject: [Patch v4 01/23] ACPICA: Resources: Provide common part for struct
> acpi_resource_address structures.
> 
> From: Lv Zheng <lv.zheng@intel.com>
> 
> struct acpi_resource_address and struct
> acpi_resource_extended_address64 share substracts just at different
> offsets. To unify the parsing functions, OSPMs like Linux need a new
> ACPI_ADDRESS64_ATTRIBUTE as their substructs, so they can extract the
> shared data.
> 
> This patch also synchronizes the structure changes to the Linux kernel.
> The usages are searched by matching the following keywords:
> 1. acpi_resource_address
> 2. acpi_resource_extended_address
> 3. ACPI_RESOURCE_TYPE_ADDRESS
> 4. ACPI_RESOURCE_TYPE_EXTENDED_ADDRESS
> And we found and fixed the usages in the following files:
>  arch/ia64/kernel/acpi-ext.c
>  arch/ia64/pci/pci.c
>  arch/x86/pci/acpi.c
>  arch/x86/pci/mmconfig-shared.c
>  drivers/xen/xen-acpi-memhotplug.c
>  drivers/acpi/acpi_memhotplug.c
>  drivers/acpi/pci_root.c
>  drivers/acpi/resource.c
>  drivers/char/hpet.c
>  drivers/pnp/pnpacpi/rsparser.c
>  drivers/hv/vmbus_drv.c
> 
> Build tests are passed with defconfig/allnoconfig/allyesconfig and
> defconfig+CONFIG_ACPI=n.
> 
> Original-by: Thomas Gleixner <tglx@linutronix.de>
> Original-by: Jiang Liu <jiang.liu@linux.intel.com>
> Signed-off-by: Lv Zheng <lv.zheng@intel.com>
> Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>

Hyper-V parts:
Acked-by: K. Y. Srinivasan <kys@microsoft.com>

> ---
>  arch/ia64/kernel/acpi-ext.c       |    6 ++--
>  arch/ia64/pci/pci.c               |   14 ++++-----
>  arch/x86/pci/acpi.c               |   26 ++++++++--------
>  arch/x86/pci/mmconfig-shared.c    |    6 ++--
>  drivers/acpi/acpi_memhotplug.c    |    8 ++---
>  drivers/acpi/acpica/rsaddr.c      |    9 +++---
>  drivers/acpi/acpica/rsdumpinfo.c  |   59 +++++++++++++++++++--------------
> ----
>  drivers/acpi/acpica/rsxface.c     |   10 +++----
>  drivers/acpi/pci_root.c           |    6 ++--
>  drivers/acpi/resource.c           |   24 +++++++--------
>  drivers/char/hpet.c               |    4 +--
>  drivers/hv/vmbus_drv.c            |    4 +--
>  drivers/pnp/pnpacpi/rsparser.c    |   16 +++++-----
>  drivers/xen/xen-acpi-memhotplug.c |    8 ++---
>  include/acpi/acrestyp.h           |   40 +++++++++++++++----------
>  15 files changed, 125 insertions(+), 115 deletions(-)
> 
> diff --git a/arch/ia64/kernel/acpi-ext.c b/arch/ia64/kernel/acpi-ext.c index
> 8b9318d311a0..bd09bf74f187 100644
> --- a/arch/ia64/kernel/acpi-ext.c
> +++ b/arch/ia64/kernel/acpi-ext.c
> @@ -69,10 +69,10 @@ static acpi_status find_csr_space(struct acpi_resource
> *resource, void *data)
>  	status = acpi_resource_to_address64(resource, &addr);
>  	if (ACPI_SUCCESS(status) &&
>  	    addr.resource_type = ACPI_MEMORY_RANGE &&
> -	    addr.address_length &&
> +	    addr.address.address_length &&
>  	    addr.producer_consumer = ACPI_CONSUMER) {
> -		space->base = addr.minimum;
> -		space->length = addr.address_length;
> +		space->base = addr.address.minimum;
> +		space->length = addr.address.address_length;
>  		return AE_CTRL_TERMINATE;
>  	}
>  	return AE_OK;		/* keep looking */
> diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c index
> 900cc93e5409..48cc65705db4 100644
> --- a/arch/ia64/pci/pci.c
> +++ b/arch/ia64/pci/pci.c
> @@ -188,12 +188,12 @@ static u64 add_io_space(struct pci_root_info *info,
> 
>  	name = (char *)(iospace + 1);
> 
> -	min = addr->minimum;
> -	max = min + addr->address_length - 1;
> +	min = addr->address.minimum;
> +	max = min + addr->address.address_length - 1;
>  	if (addr->info.io.translation_type = ACPI_SPARSE_TRANSLATION)
>  		sparse = 1;
> 
> -	space_nr = new_space(addr->translation_offset, sparse);
> +	space_nr = new_space(addr->address.translation_offset, sparse);
>  	if (space_nr = ~0)
>  		goto free_resource;
> 
> @@ -247,7 +247,7 @@ static acpi_status resource_to_window(struct
> acpi_resource *resource,
>  	if (ACPI_SUCCESS(status) &&
>  	    (addr->resource_type = ACPI_MEMORY_RANGE ||
>  	     addr->resource_type = ACPI_IO_RANGE) &&
> -	    addr->address_length &&
> +	    addr->address.address_length &&
>  	    addr->producer_consumer = ACPI_PRODUCER)
>  		return AE_OK;
> 
> @@ -284,7 +284,7 @@ static acpi_status add_window(struct acpi_resource
> *res, void *data)
>  	if (addr.resource_type = ACPI_MEMORY_RANGE) {
>  		flags = IORESOURCE_MEM;
>  		root = &iomem_resource;
> -		offset = addr.translation_offset;
> +		offset = addr.address.translation_offset;
>  	} else if (addr.resource_type = ACPI_IO_RANGE) {
>  		flags = IORESOURCE_IO;
>  		root = &ioport_resource;
> @@ -297,8 +297,8 @@ static acpi_status add_window(struct acpi_resource
> *res, void *data)
>  	resource = &info->res[info->res_num];
>  	resource->name = info->name;
>  	resource->flags = flags;
> -	resource->start = addr.minimum + offset;
> -	resource->end = resource->start + addr.address_length - 1;
> +	resource->start = addr.address.minimum + offset;
> +	resource->end = resource->start + addr.address.address_length - 1;
>  	info->res_offset[info->res_num] = offset;
> 
>  	if (insert_resource(root, resource)) { diff --git a/arch/x86/pci/acpi.c
> b/arch/x86/pci/acpi.c index cfd1b132b8e3..bb98afd0591e 100644
> --- a/arch/x86/pci/acpi.c
> +++ b/arch/x86/pci/acpi.c
> @@ -231,23 +231,23 @@ static acpi_status resource_to_addr(struct
> acpi_resource *resource,
>  	case ACPI_RESOURCE_TYPE_MEMORY24:
>  		memory24 = &resource->data.memory24;
>  		addr->resource_type = ACPI_MEMORY_RANGE;
> -		addr->minimum = memory24->minimum;
> -		addr->address_length = memory24->address_length;
> -		addr->maximum = addr->minimum + addr->address_length -
> 1;
> +		addr->address.minimum = memory24->minimum;
> +		addr->address.address_length = memory24-
> >address_length;
> +		addr->address.maximum = addr->address.minimum +
> +addr->address.address_length - 1;
>  		return AE_OK;
>  	case ACPI_RESOURCE_TYPE_MEMORY32:
>  		memory32 = &resource->data.memory32;
>  		addr->resource_type = ACPI_MEMORY_RANGE;
> -		addr->minimum = memory32->minimum;
> -		addr->address_length = memory32->address_length;
> -		addr->maximum = addr->minimum + addr->address_length -
> 1;
> +		addr->address.minimum = memory32->minimum;
> +		addr->address.address_length = memory32-
> >address_length;
> +		addr->address.maximum = addr->address.minimum +
> +addr->address.address_length - 1;
>  		return AE_OK;
>  	case ACPI_RESOURCE_TYPE_FIXED_MEMORY32:
>  		fixed_memory32 = &resource->data.fixed_memory32;
>  		addr->resource_type = ACPI_MEMORY_RANGE;
> -		addr->minimum = fixed_memory32->address;
> -		addr->address_length = fixed_memory32->address_length;
> -		addr->maximum = addr->minimum + addr->address_length -
> 1;
> +		addr->address.minimum = fixed_memory32->address;
> +		addr->address.address_length = fixed_memory32-
> >address_length;
> +		addr->address.maximum = addr->address.minimum +
> +addr->address.address_length - 1;
>  		return AE_OK;
>  	case ACPI_RESOURCE_TYPE_ADDRESS16:
>  	case ACPI_RESOURCE_TYPE_ADDRESS32:
> @@ -256,7 +256,7 @@ static acpi_status resource_to_addr(struct
> acpi_resource *resource,
>  		if (ACPI_SUCCESS(status) &&
>  		    (addr->resource_type = ACPI_MEMORY_RANGE ||
>  		    addr->resource_type = ACPI_IO_RANGE) &&
> -		    addr->address_length > 0) {
> +		    addr->address.address_length > 0) {
>  			return AE_OK;
>  		}
>  		break;
> @@ -298,8 +298,8 @@ static acpi_status setup_resource(struct
> acpi_resource *acpi_res, void *data)
>  	} else
>  		return AE_OK;
> 
> -	start = addr.minimum + addr.translation_offset;
> -	orig_end = end = addr.maximum + addr.translation_offset;
> +	start = addr.address.minimum + addr.address.translation_offset;
> +	orig_end = end = addr.address.maximum +
> +addr.address.translation_offset;
> 
>  	/* Exclude non-addressable range or non-addressable portion of
> range */
>  	end = min(end, (u64)iomem_resource.end); @@ -320,7 +320,7 @@
> static acpi_status setup_resource(struct acpi_resource *acpi_res, void
> *data)
>  	res->flags = flags;
>  	res->start = start;
>  	res->end = end;
> -	info->res_offset[info->res_num] = addr.translation_offset;
> +	info->res_offset[info->res_num] = addr.address.translation_offset;
>  	info->res_num++;
> 
>  	if (!pci_use_crs)
> diff --git a/arch/x86/pci/mmconfig-shared.c b/arch/x86/pci/mmconfig-
> shared.c index 326198a4434e..5a8dceac3094 100644
> --- a/arch/x86/pci/mmconfig-shared.c
> +++ b/arch/x86/pci/mmconfig-shared.c
> @@ -397,12 +397,12 @@ static acpi_status check_mcfg_resource(struct
> acpi_resource *res, void *data)
> 
>  	status = acpi_resource_to_address64(res, &address);
>  	if (ACPI_FAILURE(status) ||
> -	   (address.address_length <= 0) ||
> +	   (address.address.address_length <= 0) ||
>  	   (address.resource_type != ACPI_MEMORY_RANGE))
>  		return AE_OK;
> 
> -	if ((mcfg_res->start >= address.minimum) &&
> -	    (mcfg_res->end < (address.minimum + address.address_length)))
> {
> +	if ((mcfg_res->start >= address.address.minimum) &&
> +	    (mcfg_res->end < (address.address.minimum +
> +address.address.address_length))) {
>  		mcfg_res->flags = 1;
>  		return AE_CTRL_TERMINATE;
>  	}
> diff --git a/drivers/acpi/acpi_memhotplug.c
> b/drivers/acpi/acpi_memhotplug.c index 23e2319ead41..ee28f4d15625
> 100644
> --- a/drivers/acpi/acpi_memhotplug.c
> +++ b/drivers/acpi/acpi_memhotplug.c
> @@ -101,8 +101,8 @@ acpi_memory_get_resource(struct acpi_resource
> *resource, void *context)
>  		/* Can we combine the resource range information? */
>  		if ((info->caching = address64.info.mem.caching) &&
>  		    (info->write_protect =
> address64.info.mem.write_protect) &&
> -		    (info->start_addr + info->length = address64.minimum)) {
> -			info->length += address64.address_length;
> +		    (info->start_addr + info->length =
> address64.address.minimum)) {
> +			info->length += address64.address.address_length;
>  			return AE_OK;
>  		}
>  	}
> @@ -114,8 +114,8 @@ acpi_memory_get_resource(struct acpi_resource
> *resource, void *context)
>  	INIT_LIST_HEAD(&new->list);
>  	new->caching = address64.info.mem.caching;
>  	new->write_protect = address64.info.mem.write_protect;
> -	new->start_addr = address64.minimum;
> -	new->length = address64.address_length;
> +	new->start_addr = address64.address.minimum;
> +	new->length = address64.address.address_length;
>  	list_add_tail(&new->list, &mem_device->res_list);
> 
>  	return AE_OK;
> diff --git a/drivers/acpi/acpica/rsaddr.c b/drivers/acpi/acpica/rsaddr.c index
> 916fd095ff34..94a3a057042c 100644
> --- a/drivers/acpi/acpica/rsaddr.c
> +++ b/drivers/acpi/acpica/rsaddr.c
> @@ -74,7 +74,7 @@ struct acpi_rsconvert_info
> acpi_rs_convert_address16[5] = {
>  	 * Address Translation Offset
>  	 * Address Length
>  	 */
> -	{ACPI_RSC_MOVE16, ACPI_RS_OFFSET(data.address16.granularity),
> +	{ACPI_RSC_MOVE16,
> ACPI_RS_OFFSET(data.address16.address.granularity),
>  	 AML_OFFSET(address16.granularity),
>  	 5},
> 
> @@ -112,7 +112,7 @@ struct acpi_rsconvert_info
> acpi_rs_convert_address32[5] = {
>  	 * Address Translation Offset
>  	 * Address Length
>  	 */
> -	{ACPI_RSC_MOVE32, ACPI_RS_OFFSET(data.address32.granularity),
> +	{ACPI_RSC_MOVE32,
> ACPI_RS_OFFSET(data.address32.address.granularity),
>  	 AML_OFFSET(address32.granularity),
>  	 5},
> 
> @@ -150,7 +150,7 @@ struct acpi_rsconvert_info
> acpi_rs_convert_address64[5] = {
>  	 * Address Translation Offset
>  	 * Address Length
>  	 */
> -	{ACPI_RSC_MOVE64, ACPI_RS_OFFSET(data.address64.granularity),
> +	{ACPI_RSC_MOVE64,
> ACPI_RS_OFFSET(data.address64.address.granularity),
>  	 AML_OFFSET(address64.granularity),
>  	 5},
> 
> @@ -194,7 +194,8 @@ struct acpi_rsconvert_info
> acpi_rs_convert_ext_address64[5] = {
>  	 * Address Length
>  	 * Type-Specific Attribute
>  	 */
> -	{ACPI_RSC_MOVE64,
> ACPI_RS_OFFSET(data.ext_address64.granularity),
> +	{ACPI_RSC_MOVE64,
> +	 ACPI_RS_OFFSET(data.ext_address64.address.granularity),
>  	 AML_OFFSET(ext_address64.granularity),
>  	 6}
>  };
> diff --git a/drivers/acpi/acpica/rsdumpinfo.c
> b/drivers/acpi/acpica/rsdumpinfo.c
> index 2f9332d5c973..6ba7ad5faa9c 100644
> --- a/drivers/acpi/acpica/rsdumpinfo.c
> +++ b/drivers/acpi/acpica/rsdumpinfo.c
> @@ -183,15 +183,15 @@ struct acpi_rsdump_info
> acpi_rs_dump_address16[8] = {
>  	{ACPI_RSD_TITLE, ACPI_RSD_TABLE_SIZE(acpi_rs_dump_address16),
>  	 "16-Bit WORD Address Space", NULL},
>  	{ACPI_RSD_ADDRESS, 0, NULL, NULL},
> -	{ACPI_RSD_UINT16, ACPI_RSD_OFFSET(address16.granularity),
> "Granularity",
> -	 NULL},
> -	{ACPI_RSD_UINT16, ACPI_RSD_OFFSET(address16.minimum),
> "Address Minimum",
> -	 NULL},
> -	{ACPI_RSD_UINT16, ACPI_RSD_OFFSET(address16.maximum),
> "Address Maximum",
> -	 NULL},
> -	{ACPI_RSD_UINT16,
> ACPI_RSD_OFFSET(address16.translation_offset),
> +	{ACPI_RSD_UINT16,
> ACPI_RSD_OFFSET(address16.address.granularity),
> +	 "Granularity", NULL},
> +	{ACPI_RSD_UINT16,
> ACPI_RSD_OFFSET(address16.address.minimum),
> +	 "Address Minimum", NULL},
> +	{ACPI_RSD_UINT16,
> ACPI_RSD_OFFSET(address16.address.maximum),
> +	 "Address Maximum", NULL},
> +	{ACPI_RSD_UINT16,
> +ACPI_RSD_OFFSET(address16.address.translation_offset),
>  	 "Translation Offset", NULL},
> -	{ACPI_RSD_UINT16, ACPI_RSD_OFFSET(address16.address_length),
> +	{ACPI_RSD_UINT16,
> ACPI_RSD_OFFSET(address16.address.address_length),
>  	 "Address Length", NULL},
>  	{ACPI_RSD_SOURCE,
> ACPI_RSD_OFFSET(address16.resource_source), NULL, NULL}  }; @@ -200,15
> +200,15 @@ struct acpi_rsdump_info acpi_rs_dump_address32[8] = {
>  	{ACPI_RSD_TITLE, ACPI_RSD_TABLE_SIZE(acpi_rs_dump_address32),
>  	 "32-Bit DWORD Address Space", NULL},
>  	{ACPI_RSD_ADDRESS, 0, NULL, NULL},
> -	{ACPI_RSD_UINT32, ACPI_RSD_OFFSET(address32.granularity),
> "Granularity",
> -	 NULL},
> -	{ACPI_RSD_UINT32, ACPI_RSD_OFFSET(address32.minimum),
> "Address Minimum",
> -	 NULL},
> -	{ACPI_RSD_UINT32, ACPI_RSD_OFFSET(address32.maximum),
> "Address Maximum",
> -	 NULL},
> -	{ACPI_RSD_UINT32,
> ACPI_RSD_OFFSET(address32.translation_offset),
> +	{ACPI_RSD_UINT32,
> ACPI_RSD_OFFSET(address32.address.granularity),
> +	 "Granularity", NULL},
> +	{ACPI_RSD_UINT32,
> ACPI_RSD_OFFSET(address32.address.minimum),
> +	 "Address Minimum", NULL},
> +	{ACPI_RSD_UINT32,
> ACPI_RSD_OFFSET(address32.address.maximum),
> +	 "Address Maximum", NULL},
> +	{ACPI_RSD_UINT32,
> +ACPI_RSD_OFFSET(address32.address.translation_offset),
>  	 "Translation Offset", NULL},
> -	{ACPI_RSD_UINT32, ACPI_RSD_OFFSET(address32.address_length),
> +	{ACPI_RSD_UINT32,
> ACPI_RSD_OFFSET(address32.address.address_length),
>  	 "Address Length", NULL},
>  	{ACPI_RSD_SOURCE,
> ACPI_RSD_OFFSET(address32.resource_source), NULL, NULL}  }; @@ -217,15
> +217,15 @@ struct acpi_rsdump_info acpi_rs_dump_address64[8] = {
>  	{ACPI_RSD_TITLE, ACPI_RSD_TABLE_SIZE(acpi_rs_dump_address64),
>  	 "64-Bit QWORD Address Space", NULL},
>  	{ACPI_RSD_ADDRESS, 0, NULL, NULL},
> -	{ACPI_RSD_UINT64, ACPI_RSD_OFFSET(address64.granularity),
> "Granularity",
> -	 NULL},
> -	{ACPI_RSD_UINT64, ACPI_RSD_OFFSET(address64.minimum),
> "Address Minimum",
> -	 NULL},
> -	{ACPI_RSD_UINT64, ACPI_RSD_OFFSET(address64.maximum),
> "Address Maximum",
> -	 NULL},
> -	{ACPI_RSD_UINT64,
> ACPI_RSD_OFFSET(address64.translation_offset),
> +	{ACPI_RSD_UINT64,
> ACPI_RSD_OFFSET(address64.address.granularity),
> +	 "Granularity", NULL},
> +	{ACPI_RSD_UINT64,
> ACPI_RSD_OFFSET(address64.address.minimum),
> +	 "Address Minimum", NULL},
> +	{ACPI_RSD_UINT64,
> ACPI_RSD_OFFSET(address64.address.maximum),
> +	 "Address Maximum", NULL},
> +	{ACPI_RSD_UINT64,
> +ACPI_RSD_OFFSET(address64.address.translation_offset),
>  	 "Translation Offset", NULL},
> -	{ACPI_RSD_UINT64, ACPI_RSD_OFFSET(address64.address_length),
> +	{ACPI_RSD_UINT64,
> ACPI_RSD_OFFSET(address64.address.address_length),
>  	 "Address Length", NULL},
>  	{ACPI_RSD_SOURCE,
> ACPI_RSD_OFFSET(address64.resource_source), NULL, NULL}  }; @@ -234,15
> +234,16 @@ struct acpi_rsdump_info acpi_rs_dump_ext_address64[8] = {
>  	{ACPI_RSD_TITLE,
> ACPI_RSD_TABLE_SIZE(acpi_rs_dump_ext_address64),
>  	 "64-Bit Extended Address Space", NULL},
>  	{ACPI_RSD_ADDRESS, 0, NULL, NULL},
> -	{ACPI_RSD_UINT64, ACPI_RSD_OFFSET(ext_address64.granularity),
> +	{ACPI_RSD_UINT64,
> ACPI_RSD_OFFSET(ext_address64.address.granularity),
>  	 "Granularity", NULL},
> -	{ACPI_RSD_UINT64, ACPI_RSD_OFFSET(ext_address64.minimum),
> +	{ACPI_RSD_UINT64,
> ACPI_RSD_OFFSET(ext_address64.address.minimum),
>  	 "Address Minimum", NULL},
> -	{ACPI_RSD_UINT64, ACPI_RSD_OFFSET(ext_address64.maximum),
> +	{ACPI_RSD_UINT64,
> ACPI_RSD_OFFSET(ext_address64.address.maximum),
>  	 "Address Maximum", NULL},
> -	{ACPI_RSD_UINT64,
> ACPI_RSD_OFFSET(ext_address64.translation_offset),
> +	{ACPI_RSD_UINT64,
> +	 ACPI_RSD_OFFSET(ext_address64.address.translation_offset),
>  	 "Translation Offset", NULL},
> -	{ACPI_RSD_UINT64,
> ACPI_RSD_OFFSET(ext_address64.address_length),
> +	{ACPI_RSD_UINT64,
> +ACPI_RSD_OFFSET(ext_address64.address.address_length),
>  	 "Address Length", NULL},
>  	{ACPI_RSD_UINT64,
> ACPI_RSD_OFFSET(ext_address64.type_specific),
>  	 "Type-Specific Attribute", NULL}
> diff --git a/drivers/acpi/acpica/rsxface.c b/drivers/acpi/acpica/rsxface.c index
> 877ab9202133..295287891174 100644
> --- a/drivers/acpi/acpica/rsxface.c
> +++ b/drivers/acpi/acpica/rsxface.c
> @@ -60,11 +60,11 @@ ACPI_MODULE_NAME("rsxface")
>  	ACPI_COPY_FIELD(out, in, min_address_fixed);         \
>  	ACPI_COPY_FIELD(out, in, max_address_fixed);         \
>  	ACPI_COPY_FIELD(out, in, info);                      \
> -	ACPI_COPY_FIELD(out, in, granularity);               \
> -	ACPI_COPY_FIELD(out, in, minimum);                   \
> -	ACPI_COPY_FIELD(out, in, maximum);                   \
> -	ACPI_COPY_FIELD(out, in, translation_offset);        \
> -	ACPI_COPY_FIELD(out, in, address_length);            \
> +	ACPI_COPY_FIELD(out, in, address.granularity);       \
> +	ACPI_COPY_FIELD(out, in, address.minimum);           \
> +	ACPI_COPY_FIELD(out, in, address.maximum);           \
> +	ACPI_COPY_FIELD(out, in, address.translation_offset); \
> +	ACPI_COPY_FIELD(out, in, address.address_length);    \
>  	ACPI_COPY_FIELD(out, in, resource_source);
>  /* Local prototypes */
>  static acpi_status
> diff --git a/drivers/acpi/pci_root.c b/drivers/acpi/pci_root.c index
> c6bcb8c719d8..e53e0f659204 100644
> --- a/drivers/acpi/pci_root.c
> +++ b/drivers/acpi/pci_root.c
> @@ -112,10 +112,10 @@ get_root_bridge_busnr_callback(struct
> acpi_resource *resource, void *data)
>  	if (ACPI_FAILURE(status))
>  		return AE_OK;
> 
> -	if ((address.address_length > 0) &&
> +	if ((address.address.address_length > 0) &&
>  	    (address.resource_type = ACPI_BUS_NUMBER_RANGE)) {
> -		res->start = address.minimum;
> -		res->end = address.minimum + address.address_length - 1;
> +		res->start = address.address.minimum;
> +		res->end = address.address.minimum +
> address.address.address_length -
> +1;
>  	}
> 
>  	return AE_OK;
> diff --git a/drivers/acpi/resource.c b/drivers/acpi/resource.c index
> 782a0d15c25f..d0a4d90c6bcc 100644
> --- a/drivers/acpi/resource.c
> +++ b/drivers/acpi/resource.c
> @@ -202,22 +202,22 @@ bool acpi_dev_resource_address_space(struct
> acpi_resource *ares,
>  	if (ACPI_FAILURE(status))
>  		return false;
> 
> -	res->start = addr.minimum;
> -	res->end = addr.maximum;
> +	res->start = addr.address.minimum;
> +	res->end = addr.address.maximum;
>  	window = addr.producer_consumer = ACPI_PRODUCER;
> 
>  	switch(addr.resource_type) {
>  	case ACPI_MEMORY_RANGE:
> -		len = addr.maximum - addr.minimum + 1;
> +		len = addr.address.maximum - addr.address.minimum + 1;
>  		res->flags = acpi_dev_memresource_flags(len,
> 
> 	addr.info.mem.write_protect,
>  						window);
>  		break;
>  	case ACPI_IO_RANGE:
> -		io_decode = addr.granularity = 0xfff ?
> +		io_decode = addr.address.granularity = 0xfff ?
>  				ACPI_DECODE_10 : ACPI_DECODE_16;
> -		res->flags = acpi_dev_ioresource_flags(addr.minimum,
> -						       addr.maximum,
> +		res->flags > acpi_dev_ioresource_flags(addr.address.minimum,
> +						       addr.address.maximum,
>  						       io_decode, window);
>  		break;
>  	case ACPI_BUS_NUMBER_RANGE:
> @@ -253,22 +253,22 @@ bool acpi_dev_resource_ext_address_space(struct
> acpi_resource *ares,
> 
>  	ext_addr = &ares->data.ext_address64;
> 
> -	res->start = ext_addr->minimum;
> -	res->end = ext_addr->maximum;
> +	res->start = ext_addr->address.minimum;
> +	res->end = ext_addr->address.maximum;
>  	window = ext_addr->producer_consumer = ACPI_PRODUCER;
> 
>  	switch(ext_addr->resource_type) {
>  	case ACPI_MEMORY_RANGE:
> -		len = ext_addr->maximum - ext_addr->minimum + 1;
> +		len = ext_addr->address.maximum - ext_addr-
> >address.minimum + 1;
>  		res->flags = acpi_dev_memresource_flags(len,
>  					ext_addr->info.mem.write_protect,
>  					window);
>  		break;
>  	case ACPI_IO_RANGE:
> -		io_decode = ext_addr->granularity = 0xfff ?
> +		io_decode = ext_addr->address.granularity = 0xfff ?
>  				ACPI_DECODE_10 : ACPI_DECODE_16;
> -		res->flags = acpi_dev_ioresource_flags(ext_addr->minimum,
> -						       ext_addr->maximum,
> +		res->flags = acpi_dev_ioresource_flags(ext_addr-
> >address.minimum,
> +						       ext_addr-
> >address.maximum,
>  						       io_decode, window);
>  		break;
>  	case ACPI_BUS_NUMBER_RANGE:
> diff --git a/drivers/char/hpet.c b/drivers/char/hpet.c index
> d5d4cd82b9f7..5c0baa9ffc64 100644
> --- a/drivers/char/hpet.c
> +++ b/drivers/char/hpet.c
> @@ -976,8 +976,8 @@ static acpi_status hpet_resources(struct
> acpi_resource *res, void *data)
>  	status = acpi_resource_to_address64(res, &addr);
> 
>  	if (ACPI_SUCCESS(status)) {
> -		hdp->hd_phys_address = addr.minimum;
> -		hdp->hd_address = ioremap(addr.minimum,
> addr.address_length);
> +		hdp->hd_phys_address = addr.address.minimum;
> +		hdp->hd_address = ioremap(addr.address.minimum,
> +addr.address.address_length);
> 
>  		if (hpet_is_known(hdp)) {
>  			iounmap(hdp->hd_address);
> diff --git a/drivers/hv/vmbus_drv.c b/drivers/hv/vmbus_drv.c index
> 4d6b26979fbd..bb3725b672cf 100644
> --- a/drivers/hv/vmbus_drv.c
> +++ b/drivers/hv/vmbus_drv.c
> @@ -861,8 +861,8 @@ static acpi_status vmbus_walk_resources(struct
> acpi_resource *res, void *ctx)
>  		break;
> 
>  	case ACPI_RESOURCE_TYPE_ADDRESS64:
> -		hyperv_mmio.start = res->data.address64.minimum;
> -		hyperv_mmio.end = res->data.address64.maximum;
> +		hyperv_mmio.start = res-
> >data.address64.address.minimum;
> +		hyperv_mmio.end = res->data.address64.address.maximum;
>  		break;
>  	}
> 
> diff --git a/drivers/pnp/pnpacpi/rsparser.c b/drivers/pnp/pnpacpi/rsparser.c
> index 66977ebf13b3..2d9bc789af0f 100644
> --- a/drivers/pnp/pnpacpi/rsparser.c
> +++ b/drivers/pnp/pnpacpi/rsparser.c
> @@ -410,12 +410,12 @@ static __init void
> pnpacpi_parse_address_option(struct pnp_dev *dev,
>  	if (p->resource_type = ACPI_MEMORY_RANGE) {
>  		if (p->info.mem.write_protect =
> ACPI_READ_WRITE_MEMORY)
>  			flags = IORESOURCE_MEM_WRITEABLE;
> -		pnp_register_mem_resource(dev, option_flags, p-
> >minimum,
> -					  p->minimum, 0, p->address_length,
> +		pnp_register_mem_resource(dev, option_flags, p-
> >address.minimum,
> +					  p->address.minimum, 0, p-
> >address.address_length,
>  					  flags);
>  	} else if (p->resource_type = ACPI_IO_RANGE)
> -		pnp_register_port_resource(dev, option_flags, p-
> >minimum,
> -					   p->minimum, 0, p->address_length,
> +		pnp_register_port_resource(dev, option_flags, p-
> >address.minimum,
> +					   p->address.minimum, 0, p-
> >address.address_length,
>  					   IORESOURCE_IO_FIXED);
>  }
> 
> @@ -429,12 +429,12 @@ static __init void
> pnpacpi_parse_ext_address_option(struct pnp_dev *dev,
>  	if (p->resource_type = ACPI_MEMORY_RANGE) {
>  		if (p->info.mem.write_protect =
> ACPI_READ_WRITE_MEMORY)
>  			flags = IORESOURCE_MEM_WRITEABLE;
> -		pnp_register_mem_resource(dev, option_flags, p-
> >minimum,
> -					  p->minimum, 0, p->address_length,
> +		pnp_register_mem_resource(dev, option_flags, p-
> >address.minimum,
> +					  p->address.minimum, 0, p-
> >address.address_length,
>  					  flags);
>  	} else if (p->resource_type = ACPI_IO_RANGE)
> -		pnp_register_port_resource(dev, option_flags, p-
> >minimum,
> -					   p->minimum, 0, p->address_length,
> +		pnp_register_port_resource(dev, option_flags, p-
> >address.minimum,
> +					   p->address.minimum, 0, p-
> >address.address_length,
>  					   IORESOURCE_IO_FIXED);
>  }
> 
> diff --git a/drivers/xen/xen-acpi-memhotplug.c b/drivers/xen/xen-acpi-
> memhotplug.c
> index 34e40b733f9a..4fc886cd5586 100644
> --- a/drivers/xen/xen-acpi-memhotplug.c
> +++ b/drivers/xen/xen-acpi-memhotplug.c
> @@ -117,8 +117,8 @@ acpi_memory_get_resource(struct acpi_resource
> *resource, void *context)
>  	list_for_each_entry(info, &mem_device->res_list, list) {
>  		if ((info->caching = address64.info.mem.caching) &&
>  		    (info->write_protect =
> address64.info.mem.write_protect) &&
> -		    (info->start_addr + info->length = address64.minimum)) {
> -			info->length += address64.address_length;
> +		    (info->start_addr + info->length =
> address64.address.minimum)) {
> +			info->length += address64.address.address_length;
>  			return AE_OK;
>  		}
>  	}
> @@ -130,8 +130,8 @@ acpi_memory_get_resource(struct acpi_resource
> *resource, void *context)
>  	INIT_LIST_HEAD(&new->list);
>  	new->caching = address64.info.mem.caching;
>  	new->write_protect = address64.info.mem.write_protect;
> -	new->start_addr = address64.minimum;
> -	new->length = address64.address_length;
> +	new->start_addr = address64.address.minimum;
> +	new->length = address64.address.address_length;
>  	list_add_tail(&new->list, &mem_device->res_list);
> 
>  	return AE_OK;
> diff --git a/include/acpi/acrestyp.h b/include/acpi/acrestyp.h index
> eb760ca0b2e0..0b75e01212c7 100644
> --- a/include/acpi/acrestyp.h
> +++ b/include/acpi/acrestyp.h
> @@ -305,43 +305,51 @@ struct acpi_resource_source {
>  	u8                                      max_address_fixed; \
>  	union acpi_resource_attribute           info;
> 
> -struct acpi_resource_address {
> -ACPI_RESOURCE_ADDRESS_COMMON};
> -
> -struct acpi_resource_address16 {
> -	ACPI_RESOURCE_ADDRESS_COMMON u16 granularity;
> +struct acpi_address16_attribute {
> +	u16 granularity;
>  	u16 minimum;
>  	u16 maximum;
>  	u16 translation_offset;
>  	u16 address_length;
> -	struct acpi_resource_source resource_source;
>  };
> 
> -struct acpi_resource_address32 {
> -	ACPI_RESOURCE_ADDRESS_COMMON u32 granularity;
> +struct acpi_address32_attribute {
> +	u32 granularity;
>  	u32 minimum;
>  	u32 maximum;
>  	u32 translation_offset;
>  	u32 address_length;
> -	struct acpi_resource_source resource_source;
>  };
> 
> -struct acpi_resource_address64 {
> -	ACPI_RESOURCE_ADDRESS_COMMON u64 granularity;
> +struct acpi_address64_attribute {
> +	u64 granularity;
>  	u64 minimum;
>  	u64 maximum;
>  	u64 translation_offset;
>  	u64 address_length;
> +};
> +
> +struct acpi_resource_address {
> +ACPI_RESOURCE_ADDRESS_COMMON};
> +
> +struct acpi_resource_address16 {
> +	ACPI_RESOURCE_ADDRESS_COMMON struct
> acpi_address16_attribute address;
> +	struct acpi_resource_source resource_source; };
> +
> +struct acpi_resource_address32 {
> +	ACPI_RESOURCE_ADDRESS_COMMON struct
> acpi_address32_attribute address;
> +	struct acpi_resource_source resource_source; };
> +
> +struct acpi_resource_address64 {
> +	ACPI_RESOURCE_ADDRESS_COMMON struct
> acpi_address64_attribute address;
>  	struct acpi_resource_source resource_source;  };
> 
>  struct acpi_resource_extended_address64 {
>  	ACPI_RESOURCE_ADDRESS_COMMON u8 revision_ID;
> -	u64 granularity;
> -	u64 minimum;
> -	u64 maximum;
> -	u64 translation_offset;
> -	u64 address_length;
> +	struct acpi_address64_attribute address;
>  	u64 type_specific;
>  };
> 
> --
> 1.7.10.4

