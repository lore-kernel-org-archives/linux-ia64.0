From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Mon, 21 Mar 2016 12:42:01 +0000
Subject: Re: [PATCH v3] PCI: ACPI: IA64: fix IO port generic range check
Message-Id: <CAJZ5v0gvB8fHzmgrnz2wOPdLakJyuRg0eQ65oo13LP0_PHRAbg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1458558775-6242-1-git-send-email-lorenzo.pieralisi@arm.com>
In-Reply-To: <1458558775-6242-1-git-send-email-lorenzo.pieralisi@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>, Bjorn Helgaas <bhelgaas@google.com>
Cc: Linux PCI <linux-pci@vger.kernel.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Hanjun Guo <hanjun.guo@linaro.org>, Jiang Liu <jiang.liu@linux.intel.com>, Tony Luck <tony.luck@intel.com>, Tomasz Nowicki <tn@semihalf.com>, Mark Salter <msalter@redhat.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>

On Mon, Mar 21, 2016 at 12:12 PM, Lorenzo Pieralisi
<lorenzo.pieralisi@arm.com> wrote:
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
> parsing code should be guarded with a CONFIG_X86 guard so that more arches
> (ie ARM64) can benefit from the generic ACPI resources parsing interface
> without incurring in unexpected resource filtering, fixing at the same
> time current breakage on IA64.
>
> This patch factors out IO ports boundary [0 - 64k] check in generic ACPI
> code and makes the IO space check X86 specific to make sure that IO
> space resources are usable on other arches too.
>
> Fixes: 3772aea7d6f3 ("ia64/PCI/ACPI: Use common ACPI resource parsing
> interface for host bridge")
> Signed-off-by: Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>
> Cc: Bjorn Helgaas <bhelgaas@google.com>
> Cc: Hanjun Guo <hanjun.guo@linaro.org>
> Cc: Jiang Liu <jiang.liu@linux.intel.com>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Tomasz Nowicki <tn@semihalf.com>
> Cc: Mark Salter <msalter@redhat.com>
> Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
> ---
> v2 -> v3
>
> - Moved IO resource check to generic ACPI resource code
> - Dropped Tested-by tags
> - Rebased against v4.5
>
> v2: https://marc.info/?l=linux-acpi&m5521271330332&w=2
>
> v1 -> v2
>
> - Updated commit log to report missing IO resources
> - Fixed function ioport_valid() comment 16k/64k typo
>
> v1: https://marc.info/?l=linux-acpi&m5432228025354&w=2
>
>  drivers/acpi/resource.c | 14 +++++++++++++-
>  1 file changed, 13 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/acpi/resource.c b/drivers/acpi/resource.c
> index d02fd53..56241eb 100644
> --- a/drivers/acpi/resource.c
> +++ b/drivers/acpi/resource.c
> @@ -27,8 +27,20 @@
>
>  #ifdef CONFIG_X86
>  #define valid_IRQ(i) (((i) != 0) && ((i) != 2))
> +static inline bool acpi_iospace_resource_valid(struct resource *res)
> +{
> +       /* On X86 IO space is limited to the [0 - 64K] IO port range */
> +       return res->end < 0x10003;
> +}
>  #else
>  #define valid_IRQ(i) (true)
> +/*
> + * ACPI IO descriptors on arches other than X86 contain MMIO CPU physical
> + * addresses mapping IO space in CPU physical address space, IO space
> + * resources can be placed anywhere in the 64-bit physical address space.
> + */
> +static inline bool
> +acpi_iospace_resource_valid(struct resource *res) { return true; }
>  #endif
>
>  static bool acpi_dev_resource_len_valid(u64 start, u64 end, u64 len, bool io)
> @@ -127,7 +139,7 @@ static void acpi_dev_ioresource_flags(struct resource *res, u64 len,
>         if (!acpi_dev_resource_len_valid(res->start, res->end, len, true))
>                 res->flags |= IORESOURCE_DISABLED | IORESOURCE_UNSET;
>
> -       if (res->end >= 0x10003)
> +       if (!acpi_iospace_resource_valid(res))
>                 res->flags |= IORESOURCE_DISABLED | IORESOURCE_UNSET;
>
>         if (io_decode = ACPI_DECODE_16)
> --

This is fine by me.

Bjorn?
