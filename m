From: =?ISO-8859-1?Q?=C9meric_Maschino?= <emeric.maschino@gmail.com>
Date: Thu, 07 Jan 2010 23:02:37 +0000
Subject: Re: [drm:drm_mmap_locked] *ERROR* Could not find map: Could this be
Message-Id: <d72eeaf61001071502u2c09b483nce4e95b19694a591@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <d72eeaf61001041440s58b51b9j58e62af378b55224@mail.gmail.com>
In-Reply-To: <d72eeaf61001041440s58b51b9j58e62af378b55224@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

All,

I've successfully recompiled 2.6.33-rc3 kernel with the following
patches from Bjorn Helgaas (thank you!):
- [PATCH 1/2] ACPICA: acpi_get_object_info(): fixup array -> pointer
() (http://marc.info/?l=3Dlinux-ia64&m=126289433630090&w=3D2)
- [PATCH 2/2] agp/hp: fail gracefully if we don't find an IOC
(http://marc.info/?l=3Dlinux-ia64&m=126289434030106&w=3D2).

I'm still getting the reported drm_mmap_locked error, but now that
Bjorn fixed the kernel crash in the hp-agp driver ([PATCH 0/2] agp/hp:
fix zx1_gart_probe oops
(http://marc.info/?l=3Dlinux-ia64&m=126289433530083&w=3D2)), dmesg output
is more verbose:

[   14.206257] Linux agpgart interface v0.103
[   14.315142] agpgart: HP ZX1 IOC: IOPDIR shared with sba_iommu
[   14.315522]  (null): AGP aperture is 512M @ 0x60000000
[   14.315557] agpgart: HP ZX1 IOC: IOPDIR shared with sba_iommu
[   14.315592] agpgart: No reserved IO PDIR entry found; GART disabled

I imagine that GART should remain enabled, should'n it?

=C9meric
