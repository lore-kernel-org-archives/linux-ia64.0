From: Bjorn Helgaas <helgaas@kernel.org>
Date: Tue, 08 Mar 2016 22:21:25 +0000
Subject: Re: [PATCH v2] PCI: ACPI: IA64: fix IO port generic range check
Message-Id: <20160308222125.GG27132@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <1455212827-9382-1-git-send-email-lorenzo.pieralisi@arm.com>
In-Reply-To: <1455212827-9382-1-git-send-email-lorenzo.pieralisi@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>
Cc: linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org, Bjorn Helgaas <bhelgaas@google.com>, Hanjun Guo <hanjun.guo@linaro.org>, Jiang Liu <jiang.liu@linux.intel.com>, Tony Luck <tony.luck@intel.com>, Tomasz Nowicki <tn@semihalf.com>, Mark Salter <msalter@redhat.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>

On Thu, Feb 11, 2016 at 05:47:07PM +0000, Lorenzo Pieralisi wrote:
> The [0 - 64k] ACPI PCI IO port resource boundary check in:
> 
> acpi_dev_ioresource_flags()
> 
> is currently applied blindly in the ACPI resource parsing to all
> architectures, but only x86 suffers from that IO space limitation.
> 
> On arches (ie IA64 and ARM64) where IO space is memory mapped,
> the PCI root bridges IO resource windows are firstly initialized from
> the _CRS (in acpi_decode_space()) and contain the CPU physical address
> at which a root bridge decodes IO space in the CPU physical address
> space with the offset value representing the offset required to translate
> the PCI bus address into the CPU physical address.
> 
> The IO resource windows are then parsed and updated in arch code
> before creating and enumerating PCI buses (eg IA64 add_io_space())
> to map in an arch specific way the obtained CPU physical address range
> to a slice of virtual address space reserved to map PCI IO space,
> ending up with PCI bridges resource windows containing IO
> resources like the following on a working IA64 configuration:
> 
> PCI host bridge to bus 0000:00
> pci_bus 0000:00: root bus resource [io  0x1000000-0x100ffff window] (bus
> address [0x0000-0xffff])
> pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000fffff window]
> pci_bus 0000:00: root bus resource [mem 0x80000000-0x8fffffff window]
> pci_bus 0000:00: root bus resource [mem 0x80004000000-0x800ffffffff window]
> pci_bus 0000:00: root bus resource [bus 00]
> 
> This implies that the [0 - 64K] check in acpi_dev_ioresource_flags()
> leaves platforms with memory mapped IO space (ie IA64) broken (ie kernel
> can't claim IO resources since the host bridge IO resource is disabled
> and discarded by ACPI core code, see log on IA64 with missing root bridge
> IO resource, silently filtered by current [0 - 64k] check in
> acpi_dev_ioresource_flags()):
> 
> PCI host bridge to bus 0000:00
> pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000fffff window]
> pci_bus 0000:00: root bus resource [mem 0x80000000-0x8fffffff window]
> pci_bus 0000:00: root bus resource [mem 0x80004000000-0x800ffffffff window]
> pci_bus 0000:00: root bus resource [bus 00]
> 
> [...]
> 
> pci 0000:00:03.0: [1002:515e] type 00 class 0x030000
> pci 0000:00:03.0: reg 0x10: [mem 0x80000000-0x87ffffff pref]
> pci 0000:00:03.0: reg 0x14: [io  0x1000-0x10ff]
> pci 0000:00:03.0: reg 0x18: [mem 0x88020000-0x8802ffff]
> pci 0000:00:03.0: reg 0x30: [mem 0x88000000-0x8801ffff pref]
> pci 0000:00:03.0: supports D1 D2
> pci 0000:00:03.0: can't claim BAR 1 [io  0x1000-0x10ff]: no compatible
> bridge window
> 
> For this reason, the IO port resources boundaries check in generic ACPI
> parsing code should be moved to x86 arch code so that more arches (ie
> ARM64) can benefit from the generic ACPI resources parsing interface
> without incurring in unexpected resource filtering, fixing at the same
> time current breakage on IA64.
> 
> This patch moves the IO ports boundary [0 - 64k] check to x86 arch code
> code that validates the PCI host bridge resources.

I definitely agree with moving this check out of the generic ACPI
code, so while I have a minor question below,

Acked-by: Bjorn Helgaas <bhelgaas@google.com>

> Fixes: 3772aea7d6f3 ("ia64/PCI/ACPI: Use common ACPI resource parsing
> interface for host bridge")

3772aea7d6f3 was merged via the ACPI tree.  Does it make sense to
have this fix for it merged the same way?  I'll assume so unless
Rafael thinks otherwise.

> Signed-off-by: Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>
> Tested-by: Hanjun Guo <hanjun.guo@linaro.org>
> Cc: Bjorn Helgaas <bhelgaas@google.com>
> Cc: Hanjun Guo <hanjun.guo@linaro.org>
> Cc: Jiang Liu <jiang.liu@linux.intel.com>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Tomasz Nowicki <tn@semihalf.com>
> Cc: Mark Salter <msalter@redhat.com>
> Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
> ---
> v1 -> v2
> 
> - Updated commit log to report missing IO resources
> - Fixed function ioport_valid() comment 16k/64k typo
> 
> v1: https://lkml.org/lkml/2016/2/1/157
> 
>  arch/x86/pci/acpi.c     | 18 +++++++++++++-----
>  drivers/acpi/resource.c |  3 ---
>  2 files changed, 13 insertions(+), 8 deletions(-)
> 
> diff --git a/arch/x86/pci/acpi.c b/arch/x86/pci/acpi.c
> index 3cd6983..cec68e7 100644
> --- a/arch/x86/pci/acpi.c
> +++ b/arch/x86/pci/acpi.c
> @@ -275,11 +275,14 @@ static void pci_acpi_root_release_info(struct acpi_pci_root_info *ci)
>   *     to access PCI configuration space.
>   *
>   * So explicitly filter out PCI CFG IO ports[0xCF8-0xCFF].
> + *
> + * Furthermore, IO ports address space is limited to 64k on x86,
> + * any IO resource exceeding the boundary must therefore be discarded.
>   */
> -static bool resource_is_pcicfg_ioport(struct resource *res)
> +static bool ioport_valid(struct resource *res)
>  {
> -	return (res->flags & IORESOURCE_IO) &&
> -		res->start = 0xCF8 && res->end = 0xCFF;
> +	return !(res->start = 0xCF8 && res->end = 0xCFF) &&
> +	       !(res->end >= 0x10003);

Is the "res->end >= 0x10003" test actually fixing a problem?

I think 4d6b4e69a245 ("x86/PCI/ACPI: Use common interface to support
PCI host bridge") is the x86 change corresponding to 3772aea7d6f3.  I
took a quick look through it, and I didn't see a res->end test before
4d6b4e69a245, but maybe I missed it.

The reason I'm asking is because there's no reason in principle that
x86 couldn't support multiple host bridges, one with a 0-64K I/O space
accessible via the x86 inb/outb instructions, and others with more I/O
space accessible only via the in-kernel inb()/outb() functions, which
would use an MMIO region that the host bridge converts to I/O accesses
on the PCI side.  This is what ia64 does, and x86 could do something
similar.  If it did, it would be fine for res->end to be above
0x10003 for those memory-mapped I/O spaces.

>  }
>  
>  static int pci_acpi_root_prepare_resources(struct acpi_pci_root_info *ci)
> @@ -287,13 +290,18 @@ static int pci_acpi_root_prepare_resources(struct acpi_pci_root_info *ci)
>  	struct acpi_device *device = ci->bridge;
>  	int busnum = ci->root->secondary.start;
>  	struct resource_entry *entry, *tmp;
> +	struct resource *res;
>  	int status;
>  
>  	status = acpi_pci_probe_root_resources(ci);
>  	if (pci_use_crs) {
> -		resource_list_for_each_entry_safe(entry, tmp, &ci->resources)
> -			if (resource_is_pcicfg_ioport(entry->res))
> +		resource_list_for_each_entry_safe(entry, tmp, &ci->resources) {
> +			res = entry->res;
> +
> +			if (res->flags & IORESOURCE_IO && !ioport_valid(res))
>  				resource_list_destroy_entry(entry);
> +		}
> +
>  		return status;
>  	}
>  
> diff --git a/drivers/acpi/resource.c b/drivers/acpi/resource.c
> index d02fd53..c112e1d 100644
> --- a/drivers/acpi/resource.c
> +++ b/drivers/acpi/resource.c
> @@ -127,9 +127,6 @@ static void acpi_dev_ioresource_flags(struct resource *res, u64 len,
>  	if (!acpi_dev_resource_len_valid(res->start, res->end, len, true))
>  		res->flags |= IORESOURCE_DISABLED | IORESOURCE_UNSET;
>  
> -	if (res->end >= 0x10003)
> -		res->flags |= IORESOURCE_DISABLED | IORESOURCE_UNSET;
> -
>  	if (io_decode = ACPI_DECODE_16)
>  		res->flags |= IORESOURCE_IO_16BIT_ADDR;
>  	if (translation_type = ACPI_SPARSE_TRANSLATION)
> -- 
> 2.5.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-acpi" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
