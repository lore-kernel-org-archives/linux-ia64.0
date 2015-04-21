From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Date: Tue, 21 Apr 2015 15:40:05 +0000
Subject: Re: [PATCH] ia64/PCI: Treat all host bridge Address Space Descriptors (even consumers) as windows
Message-Id: <8894432.G9pvVBipeX@vostro.rjw.lan>
List-Id: <linux-ia64.vger.kernel.org>
References: <20150420233055.20866.87460.stgit@bhelgaas-glaptop2.roam.corp.google.com>
In-Reply-To: <20150420233055.20866.87460.stgit@bhelgaas-glaptop2.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Jiang Liu <jiang.liu@linux.intel.com>

On Monday, April 20, 2015 06:30:55 PM Bjorn Helgaas wrote:
> Prior to c770cb4cb505 ("PCI: Mark invalid BARs as unassigned"), if we tri=
ed
> to claim a PCI BAR but could not find an upstream bridge window that
> matched it, we complained but still allowed the device to be enabled.
>=20
> c770cb4cb505 broke devices that previously worked (mptsas and igb in the
> case Tony reported, but it could be any devices) because it marks those
> BARs as IORESOURCE_UNSET, which makes pci_enable_device() complain and
> return failure:
>=20
>   igb 0000:81:00.0: can't enable device: BAR 0 [mem size 0x00020000] not =
assigned
>   igb: probe of 0000:81:00.0 failed with error -22
>=20
> The underlying cause is an ACPI Address Space Descriptor for a PCI host
> bridge window that is marked as "consumer".  This is a firmware defect:
> resources that are produced on the downstream side of a bridge should be
> marked "producer".  But rejecting these BARs that we previously allowed is
> a functionality regression, and firmware has not used the producer/consum=
er
> bit consistently, so we can't rely on it anyway.
>=20
> Stop checking the producer/consumer bit, and assume all bridge Address
> Space Descriptors are for bridge windows.
>=20
> Note that this change does not affect I/O Port or Fixed Location I/O Port
> Descriptors, which are commonly used for the [io 0x0cf8-0x0cff] config
> access range.  That range is a "consumer" range and should not be treated
> as a window.
>=20
> Fixes: c770cb4cb505 ("PCI: Mark invalid BARs as unassigned")
> Link: https://bugzilla.kernel.org/show_bug.cgi?id=96961
> Reported-and-tested-by: Tony Luck <tony.luck@intel.com>
> Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>

Acked-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>

