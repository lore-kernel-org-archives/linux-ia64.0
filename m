From: Bjorn Helgaas <bhelgaas@google.com>
Date: Fri, 06 Sep 2013 15:36:21 +0000
Subject: Re: [RFC PATCH 4/4] X86/PCI/ACPI: Rework setup_resource() via functions ACPI resource functions
Message-Id: <CAErSpo5rWq0+CbPMtjruDv0eN8-q=qBhHQURFeia_CfOgmDotA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1378477486-8758-1-git-send-email-tianyu.lan@intel.com> <1378477486-8758-5-git-send-email-tianyu.lan@intel.com>
In-Reply-To: <1378477486-8758-5-git-send-email-tianyu.lan@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Lan Tianyu <tianyu.lan@intel.com>
Cc: Len Brown <lenb@kernel.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Yinghai Lu <yinghai@kernel.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

[+cc Tony, linux-ia64]

On Fri, Sep 6, 2013 at 8:24 AM, Lan Tianyu <tianyu.lan@intel.com> wrote:
> Using ACPI resource functions to convert ACPI resource to generic resource
> instead of resource_to_addr(). Remove resource_to_addr().
>
> Signed-off-by: Lan Tianyu <tianyu.lan@intel.com>
> ---
>  arch/x86/pci/acpi.c | 81 ++++++++---------------------------------------------
>  1 file changed, 12 insertions(+), 69 deletions(-)

Please make corresponding changes to arch/ia64/pci/pci.c so that these
paths remain as similar as possible.  There's quite a bit of
similarity between this x86 and ia64 code, and it would be nice to
unify them more when possible.

> diff --git a/arch/x86/pci/acpi.c b/arch/x86/pci/acpi.c
> index d641897..d4f85a1 100644
> --- a/arch/x86/pci/acpi.c
> +++ b/arch/x86/pci/acpi.c
> @@ -219,62 +219,15 @@ static void teardown_mcfg_map(struct pci_root_info *info)
>  #endif
>
>  static acpi_status
> -resource_to_addr(struct acpi_resource *resource,
> -                       struct acpi_resource_address64 *addr)
> -{
> -       acpi_status status;
> -       struct acpi_resource_memory24 *memory24;
> -       struct acpi_resource_memory32 *memory32;
> -       struct acpi_resource_fixed_memory32 *fixed_memory32;
> -
> -       memset(addr, 0, sizeof(*addr));
> -       switch (resource->type) {
> -       case ACPI_RESOURCE_TYPE_MEMORY24:
> -               memory24 = &resource->data.memory24;
> -               addr->resource_type = ACPI_MEMORY_RANGE;
> -               addr->minimum = memory24->minimum;
> -               addr->address_length = memory24->address_length;
> -               addr->maximum = addr->minimum + addr->address_length - 1;
> -               return AE_OK;
> -       case ACPI_RESOURCE_TYPE_MEMORY32:
> -               memory32 = &resource->data.memory32;
> -               addr->resource_type = ACPI_MEMORY_RANGE;
> -               addr->minimum = memory32->minimum;
> -               addr->address_length = memory32->address_length;
> -               addr->maximum = addr->minimum + addr->address_length - 1;
> -               return AE_OK;
> -       case ACPI_RESOURCE_TYPE_FIXED_MEMORY32:
> -               fixed_memory32 = &resource->data.fixed_memory32;
> -               addr->resource_type = ACPI_MEMORY_RANGE;
> -               addr->minimum = fixed_memory32->address;
> -               addr->address_length = fixed_memory32->address_length;
> -               addr->maximum = addr->minimum + addr->address_length - 1;
> -               return AE_OK;
> -       case ACPI_RESOURCE_TYPE_ADDRESS16:
> -       case ACPI_RESOURCE_TYPE_ADDRESS32:
> -       case ACPI_RESOURCE_TYPE_ADDRESS64:
> -               status = acpi_resource_to_address64(resource, addr);
> -               if (ACPI_SUCCESS(status) &&
> -                   (addr->resource_type = ACPI_MEMORY_RANGE ||
> -                   addr->resource_type = ACPI_IO_RANGE) &&
> -                   addr->address_length > 0) {
> -                       return AE_OK;
> -               }
> -               break;
> -       }
> -       return AE_ERROR;
> -}
> -
> -static acpi_status
>  count_resource(struct acpi_resource *acpi_res, void *data)
>  {
>         struct pci_root_info *info = data;
> -       struct acpi_resource_address64 addr;
> -       acpi_status status;
> +       struct resource res;
>
> -       status = resource_to_addr(acpi_res, &addr);
> -       if (ACPI_SUCCESS(status))
> +       if (acpi_dev_resource_address_space(acpi_res, &res)
> +           || acpi_dev_resource_memory(acpi_res, &res))
>                 info->res_num++;
> +
>         return AE_OK;
>  }
>
> @@ -282,27 +235,18 @@ static acpi_status
>  setup_resource(struct acpi_resource *acpi_res, void *data)
>  {
>         struct pci_root_info *info = data;
> -       struct resource *res;
> +       struct resource *res = &info->res[info->res_num];
>         struct acpi_resource_address64 addr;
> -       acpi_status status;
> -       unsigned long flags;
>         u64 start, orig_end, end;
>
> -       status = resource_to_addr(acpi_res, &addr);
> -       if (!ACPI_SUCCESS(status))
> -               return AE_OK;
> +       memset(&addr, 0x00, sizeof(addr));
>
> -       if (addr.resource_type = ACPI_MEMORY_RANGE) {
> -               flags = IORESOURCE_MEM;
> -               if (addr.info.mem.caching = ACPI_PREFETCHABLE_MEMORY)
> -                       flags |= IORESOURCE_PREFETCH;
> -       } else if (addr.resource_type = ACPI_IO_RANGE) {
> -               flags = IORESOURCE_IO;
> -       } else
> +       if (!(acpi_dev_resource_address_space_with_addr(acpi_res, &addr, res)
> +           || acpi_dev_resource_memory(acpi_res, res)))
>                 return AE_OK;
>
> -       start = addr.minimum + addr.translation_offset;
> -       orig_end = end = addr.maximum + addr.translation_offset;
> +       start = res->start;
> +       orig_end = end = res->end;
>
>         /* Exclude non-addressable range or non-addressable portion of range */
>         end = min(end, (u64)iomem_resource.end);
> @@ -310,6 +254,7 @@ setup_resource(struct acpi_resource *acpi_res, void *data)
>                 dev_info(&info->bridge->dev,
>                         "host bridge window [%#llx-%#llx] "
>                         "(ignored, not CPU addressable)\n", start, orig_end);
> +               memset(&info->res[info->res_num], 0x00, sizeof(*res));
>                 return AE_OK;
>         } else if (orig_end != end) {
>                 dev_info(&info->bridge->dev,
> @@ -318,11 +263,9 @@ setup_resource(struct acpi_resource *acpi_res, void *data)
>                         start, orig_end, end + 1, orig_end);
>         }
>
> -       res = &info->res[info->res_num];
>         res->name = info->name;
> -       res->flags = flags;
> -       res->start = start;
>         res->end = end;
> +
>         info->res_offset[info->res_num] = addr.translation_offset;
>         info->res_num++;
>
> --
> 1.8.2.1
>
