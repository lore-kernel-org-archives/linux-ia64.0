From: Bjorn Helgaas <bhelgaas@google.com>
Date: Tue, 21 Apr 2015 23:00:41 +0000
Subject: Re: [PATCH] ia64/PCI: Treat all host bridge Address Space Descriptors (even consumers) as windows
Message-Id: <CAErSpo6P-rr1sdp-d2zairPEKWr1q4E=8f=wRoaP56LDU8bcfw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20150420233055.20866.87460.stgit@bhelgaas-glaptop2.roam.corp.google.com>
In-Reply-To: <20150420233055.20866.87460.stgit@bhelgaas-glaptop2.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
Cc: "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Jiang Liu <jiang.liu@linux.intel.com>, "Rafael J . Wysocki" <rjw@rjwysocki.net>

On Mon, Apr 20, 2015 at 6:30 PM, Bjorn Helgaas <bhelgaas@google.com> wrote:
> Prior to c770cb4cb505 ("PCI: Mark invalid BARs as unassigned"), if we tri=
ed
> to claim a PCI BAR but could not find an upstream bridge window that
> matched it, we complained but still allowed the device to be enabled.
>
> c770cb4cb505 broke devices that previously worked (mptsas and igb in the
> case Tony reported, but it could be any devices) because it marks those
> BARs as IORESOURCE_UNSET, which makes pci_enable_device() complain and
> return failure:
>
>   igb 0000:81:00.0: can't enable device: BAR 0 [mem size 0x00020000] not =
assigned
>   igb: probe of 0000:81:00.0 failed with error -22
>
> The underlying cause is an ACPI Address Space Descriptor for a PCI host
> bridge window that is marked as "consumer".  This is a firmware defect:
> resources that are produced on the downstream side of a bridge should be
> marked "producer".  But rejecting these BARs that we previously allowed is
> a functionality regression, and firmware has not used the producer/consum=
er
> bit consistently, so we can't rely on it anyway.
>
> Stop checking the producer/consumer bit, and assume all bridge Address
> Space Descriptors are for bridge windows.
>
> Note that this change does not affect I/O Port or Fixed Location I/O Port
> Descriptors, which are commonly used for the [io 0x0cf8-0x0cff] config
> access range.  That range is a "consumer" range and should not be treated
> as a window.
>
> Fixes: c770cb4cb505 ("PCI: Mark invalid BARs as unassigned")
> Link: https://bugzilla.kernel.org/show_bug.cgi?id=96961
> Reported-and-tested-by: Tony Luck <tony.luck@intel.com>
> Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>

I applied this with Rafael's ack to for-linus for v4.1-rc1.

> ---
>  arch/ia64/pci/pci.c |    5 +----
>  1 file changed, 1 insertion(+), 4 deletions(-)
>
> diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
> index 48cc65705db4..d4e162d35b34 100644
> --- a/arch/ia64/pci/pci.c
> +++ b/arch/ia64/pci/pci.c
> @@ -240,15 +240,12 @@ static acpi_status resource_to_window(struct acpi_r=
esource *resource,
>          * We're only interested in _CRS descriptors that are
>          *      - address space descriptors for memory or I/O space
>          *      - non-zero size
> -        *      - producers, i.e., the address space is routed downstream,
> -        *        not consumed by the bridge itself
>          */
>         status =3D acpi_resource_to_address64(resource, addr);
>         if (ACPI_SUCCESS(status) &&
>             (addr->resource_type =3D ACPI_MEMORY_RANGE ||
>              addr->resource_type =3D ACPI_IO_RANGE) &&
> -           addr->address.address_length &&
> -           addr->producer_consumer =3D ACPI_PRODUCER)
> +           addr->address.address_length)
>                 return AE_OK;
>
>         return AE_ERROR;
>
