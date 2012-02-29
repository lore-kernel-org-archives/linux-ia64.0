From: Bjorn Helgaas <bhelgaas@google.com>
Date: Wed, 29 Feb 2012 00:01:42 +0000
Subject: Re: [PATCH 12/24] PCI, ia64: Register busn_res for root buses
Message-Id: <CAErSpo66PD3+E3ZFqp73XHabL+8GavpX97pUkd28T6KWTBH-aA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1330466863-28469-1-git-send-email-yinghai@kernel.org> <1330466863-28469-13-git-send-email-yinghai@kernel.org>
In-Reply-To: <1330466863-28469-13-git-send-email-yinghai@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Yinghai Lu <yinghai@kernel.org>
Cc: Jesse Barnes <jbarnes@virtuousgeek.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Tony Luck <tony.luck@intel.com>, David Miller <davem@davemloft.net>, x86 <x86@kernel.org>, Dominik Brodowski <linux@dominikbrodowski.net>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

On Tue, Feb 28, 2012 at 3:07 PM, Yinghai Lu <yinghai@kernel.org> wrote:
> Signed-off-by: Yinghai Lu <yinghai@kernel.org>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Fenghua Yu <fenghua.yu@intel.com>
> Cc: linux-ia64@vger.kernel.org
> ---
> =A0arch/ia64/include/asm/pci.h | =A0 =A01 +
> =A0arch/ia64/pci/pci.c =A0 =A0 =A0 =A0 | =A0 =A05 +++++
> =A02 files changed, 6 insertions(+), 0 deletions(-)
>
> diff --git a/arch/ia64/include/asm/pci.h b/arch/ia64/include/asm/pci.h
> index b22e5f5..6e54220 100644
> --- a/arch/ia64/include/asm/pci.h
> +++ b/arch/ia64/include/asm/pci.h
> @@ -94,6 +94,7 @@ struct pci_controller {
>
> =A0 =A0 =A0 =A0unsigned int windows;
> =A0 =A0 =A0 =A0struct pci_window *window;
> + =A0 =A0 =A0 struct resource busn;

Why do you add a new struct resource here?  Can't you just use the one
passed in from acpi_pci_root_add()?

>
> =A0 =A0 =A0 =A0void *platform_data;
> =A0};
> diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
> index d1ce320..b250f0f 100644
> --- a/arch/ia64/pci/pci.c
> +++ b/arch/ia64/pci/pci.c
> @@ -332,6 +332,7 @@ pci_acpi_scan_root(struct acpi_pci_root *root)
> =A0 =A0 =A0 =A0struct acpi_device *device =3D root->device;
> =A0 =A0 =A0 =A0int domain =3D root->segment;
> =A0 =A0 =A0 =A0int bus =3D root->secondary.start;
> + =A0 =A0 =A0 int busmax =3D root->secondary.end;
> =A0 =A0 =A0 =A0struct pci_controller *controller;
> =A0 =A0 =A0 =A0unsigned int windows =3D 0;
> =A0 =A0 =A0 =A0struct pci_root_info info;
> @@ -372,6 +373,10 @@ pci_acpi_scan_root(struct acpi_pci_root *root)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0acpi_walk_resources(device->handle, METHOD=
_NAME__CRS,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0add_window, &info);
> =A0 =A0 =A0 =A0}
> + =A0 =A0 =A0 controller->busn.start =3D bus;
> + =A0 =A0 =A0 controller->busn.end =3D busmax;
> + =A0 =A0 =A0 conttoller->busn.flags =3D IORESOURCE_BUS;

Typo here - "conttoller" should be "controller".

> + =A0 =A0 =A0 pci_add_resource(&info.resources, &controller->busn);
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * See arch/x86/pci/acpi.c.
> =A0 =A0 =A0 =A0 * The desired pci bus might already be scanned in a quirk=
. We
> --
> 1.7.7
>
