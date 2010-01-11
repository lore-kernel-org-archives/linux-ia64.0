From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 11 Jan 2010 17:54:56 +0000
Subject: Re: [drm:drm_mmap_locked] *ERROR* Could not find map: Could this be  kernel-related?
Message-Id: <201001111054.56485.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <d72eeaf61001041440s58b51b9j58e62af378b55224@mail.gmail.com>
In-Reply-To: <d72eeaf61001041440s58b51b9j58e62af378b55224@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Saturday 09 January 2010 04:46:55 am =C9meric Maschino wrote:
> > 2010/1/9 Bjorn Helgaas <bjorn.helgaas@hp.com>:
> > Then for some reason we must be calling hp_zx1_setup() again, and this
> > time it failed because the cookie is gone. =A0This could happen if
> > agp_add_bridge() failed, but I don't see a way it could fail after
> > printing the "AGP aperture is 512M" message.
> >
> > Can you try the attached patch, please?
>=20
> Please find below the dmesg output with the patches attached in your
> previous message. I don't have the impression that hp_zx1_setup() is
> called twice:

> [   12.778181] Linux agpgart interface v0.103
> [   12.786149] agp_hp_init
> [   12.885078] agpgart: HP ZX1 IOC: IOPDIR shared with sba_iommu
> [   12.885115] GART at 0xe000004080ec0000
> [   12.885147] read cookie at 0xe000004080ec0000: 0xbadbadc0ffee
> [   12.885187] hp_zx1_create_gatt_table
> [   12.885833]  (null): AGP aperture is 512M @ 0x60000000
> [   12.885866] agp_add_bridge: returning 0 (success)
> [   12.885899] hp_zx1_setup: agp_add_bridge returned 0

Here's what I don't understand.  My code looks like this:

        error =3D hp_zx1_setup(sba_hpa + HP_ZX1_IOC_OFFSET, lba_hpa);
        printk("%s: hp_zx1_setup returned %d\n", __func__, error);
        if (error)
                return AE_OK;

        printk(KERN_INFO PFX "Detected HP ZX1 %s AGP chipset "
                "(ioc=3D%llx, lba=3D%llx)\n", (char *)context,
                sba_hpa + HP_ZX1_IOC_OFFSET, lba_hpa);

If hp_zx1_setup returned 0, we should see the "Detected HP ZX1
HWP0003 AGP chipset" message next, but we don't:

> [   12.885932] zx1_gart_probe: hp_zx1_setup returned 0
> [   12.885966] agpgart: HP ZX1 IOC: IOPDIR shared with sba_iommu
> [   12.886001] GART at 0xe000004080ec0000
> [   12.886032] read cookie at 0xe000004080ec0000: 0x0
> [   12.886065] agpgart: No reserved IO PDIR entry found; GART disabled
> [   12.886099] hp_zx1_cleanup

Is your code different?  Can you instrument this area and figure
out what's going on?  From the output, it seems like we're taking
the "return AE_OK" path, but we shouldn't be.

Bjorn
