From: Bjorn Helgaas <bhelgaas@google.com>
Date: Wed, 04 Mar 2015 17:22:37 +0000
Subject: Re: [PATCH] ia64/PCI: Fix the build warning of pci_domain_nr()
Message-Id: <CAErSpo76ap_3LB7PVoQL-ngdrMc39KiuRbMnuQSHpcyCdjJUag@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1425449804-28887-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1425449804-28887-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yijing Wang <wangyijing@huawei.com>
Cc: Tony Luck <tony.luck@intel.com>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, Fenghua Yu <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>

On Wed, Mar 4, 2015 at 12:16 AM, Yijing Wang <wangyijing@huawei.com> wrote:
> We should pass pci_bus * instead of pci_dev * to pci_domain_nr().
>
> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
> CC: Tony Luck <tony.luck@intel.com>
> CC: Fenghua Yu <fenghua.yu@intel.com>
> CC: linux-ia64@vger.kernel.org
> CC: stable@vger.kernel.org
> Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>

I think this seems correct, at least in terms of fixing a build issue.
But it changes some behavior too.  It would be nice to have
confirmation that the change *fixes* something rather than breaking
something.

It looks like this code has been this way since 6f09a9250a5d ("Altix:
ACPI SSDT PCI device support") in 2007.  So if it really is broken
without this fix, it seems strange that we wouldn't have noticed until
now.

Tony, since I can't test this, and the rest of Yijing's PCI series
doesn't depend on this, do you want to take care of this?  You can
drop my Signed-off-by in that case.

Bjorn

> ---
>  arch/ia64/sn/kernel/io_acpi_init.c |    6 +++---
>  arch/ia64/sn/kernel/io_init.c      |    2 +-
>  2 files changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/arch/ia64/sn/kernel/io_acpi_init.c b/arch/ia64/sn/kernel/io_acpi_init.c
> index 0640739..2fd7414 100644
> --- a/arch/ia64/sn/kernel/io_acpi_init.c
> +++ b/arch/ia64/sn/kernel/io_acpi_init.c
> @@ -364,12 +364,12 @@ sn_acpi_get_pcidev_info(struct pci_dev *dev, struct pcidev_info **pcidev_info,
>          status = acpi_evaluate_integer(rootbus_handle, METHOD_NAME__SEG, NULL,
>                                         &segment);
>          if (ACPI_SUCCESS(status)) {
> -               if (segment != pci_domain_nr(dev)) {
> +               if (segment != pci_domain_nr(dev->bus)) {
>                         acpi_get_name(rootbus_handle, ACPI_FULL_PATHNAME,
>                                 &name_buffer);
>                         printk(KERN_ERR
>                                "%s: Segment number mismatch, 0x%llx vs 0x%x for: %s\n",
> -                              __func__, segment, pci_domain_nr(dev),
> +                              __func__, segment, pci_domain_nr(dev->bus),
>                                (char *)name_buffer.pointer);
>                         kfree(name_buffer.pointer);
>                         return 1;
> @@ -407,7 +407,7 @@ sn_acpi_get_pcidev_info(struct pci_dev *dev, struct pcidev_info **pcidev_info,
>         /* Build up the pcidev_info.pdi_slot_host_handle */
>         host_devfn = get_host_devfn(pcidev_match.handle, rootbus_handle);
>         (*pcidev_info)->pdi_slot_host_handle > -                       ((unsigned long) pci_domain_nr(dev) << 40) |
> +                       ((unsigned long) pci_domain_nr(dev->bus) << 40) |
>                                         /* bus = 0 */
>                                         host_devfn;
>         return 0;
> diff --git a/arch/ia64/sn/kernel/io_init.c b/arch/ia64/sn/kernel/io_init.c
> index 55776df..19506a5 100644
> --- a/arch/ia64/sn/kernel/io_init.c
> +++ b/arch/ia64/sn/kernel/io_init.c
> @@ -164,7 +164,7 @@ sn_io_slot_fixup(struct pci_dev *dev)
>                 panic("%s: Unable to alloc memory for sn_irq_info", __func__);
>
>         /* Call to retrieve pci device information needed by kernel. */
> -       status = sal_get_pcidev_info((u64) pci_domain_nr(dev),
> +       status = sal_get_pcidev_info((u64) pci_domain_nr(dev->bus),
>                 (u64) dev->bus->number,
>                 dev->devfn,
>                 (u64) __pa(pcidev_info),
> --
> 1.7.1
>
