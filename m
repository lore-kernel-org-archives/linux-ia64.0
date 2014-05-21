From: =?UTF-8?Q?=C3=89meric_MASCHINO?= <emeric.maschino@gmail.com>
Date: Wed, 21 May 2014 13:23:41 +0000
Subject: Re: [regression][bisected] zx1 AGP GART no more detected since merge of 'acpi-scan' branch
Message-Id: <CAA9xbM5-qRNutJcp3uhV54MCenTHcgzcte4WRCVFFyxn-CE+_g@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAA9xbM4=Rt3hVYEUv2GoWNex8cCeaxnBUWEc4_6mF_cLRLZZ2A@mail.gmail.com>
In-Reply-To: <CAA9xbM4=Rt3hVYEUv2GoWNex8cCeaxnBUWEc4_6mF_cLRLZZ2A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi,

I've looked at this issue deeper: the problem seems to rely in the
initialization of the PCI resources.

Instrumenting the ioc_iova_init function in
arch/ia64/hp/common/sba_iommu.c most notably gives for working <3.10.40 ker=
nels:
[    3.730289] for_each_pci_dev(0xe000004080245000)
[    3.730442] for_each_pci_dev(0xe000004080245800)
[    3.730594] for_each_pci_dev(0xe000004080246000)
[    3.730745] for_each_pci_dev(0xe000004080246800)
[    3.730897] for_each_pci_dev(0xe000004080247000)
[    3.731034] for_each_pci_dev(0xe000004080247800)
[    3.731281] for_each_pci_dev(0xe000004080248000)
[    3.731528] for_each_pci_dev(0xe000004080248800)
[    3.731918] for_each_pci_dev(0xe000004080249000)
[    3.732133] for_each_pci_dev(0xe000004080249800)
[    3.732336] for_each_pci_dev(0xe00000408024a000)
[    3.732532] for_each_pci_dev(0xe00000408024a800)

Whereas with kernel 3.11-rc1, the same function instrumentation
outputs nothing, i.e. for_each_pci_dev(device) immediately returns
NULL (see below). The agp_found variable is thus still 0 and the
corresponding AGP GART initialization path is not taken:

        /*
        ** If an AGP device is present, only use half of the IOV space
        ** for PCI DMA.  Unfortunately we can't know ahead of time
        ** whether GART support will actually be used, for now we
        ** can just key on an AGP device found in the system.
        ** We program the next pdir index after we stop w/ a key for
        ** the GART code to handshake on.
        */
        for_each_pci_dev(device)
                agp_found |=3D pci_find_capability(device, PCI_CAP_ID_AGP);

        if (agp_found && reserve_sba_gart) {
                printk(KERN_INFO PFX "reserving %dMb of IOVA space at 0x%lx=
 for$
                      ioc->iov_size/2 >> 20, ioc->ibase + ioc->iov_size/2);
                ioc->pdir_size /=3D 2;
                ((u64 *)ioc->pdir_base)[PDIR_INDEX(ioc->iov_size/2)] =3D ZX=
1_SBA_$
        }

Where should I look for now?

     =C3=89meric


2014-05-15 2:32 GMT+02:00 =C3=89meric MASCHINO <emeric.maschino@gmail.com>:
> Hi,
>
> Up to kernel 3.10.40, zx1 AGP GART was successfully detected:
> [   15.896075] Linux agpgart interface v0.103
> [   17.272674] agpgart: HP ZX1 IOC: IOPDIR shared with sba_iommu
> [   17.272980]  (null): AGP aperture is 512M @ 0x60000000
> [   17.273015] agpgart: Detected HP ZX1 HWP0003 AGP chipset (ioc=FEd01000=
, lba=3Df
> ed28000)
> <snip>
> [   29.602989] radeon 0000:80:00.0: putting AGP V2 device into 2x mode
> [   29.603306] radeon 0000:80:00.0: GTT: 512M 0x60000000 - 0x7FFFFFFF
> [   29.603399] [drm] Generation 1 PCI interface in multifunction mode
>
> Starting with kernel 3.11-rc1, zx1 AGP GART is no more detected and my
> ATI FireGL X1 AGP graphics adapter is set to PCI mode:
> [    5.442563] Linux agpgart interface v0.103
> [    5.937458] agpgart: HP ZX1 IOC: IOPDIR shared with sba_iommu
> [    5.937491] agpgart: No reserved IO PDIR entry found; GART disabled
> <snip>
> [    6.028511] [drm:radeon_agp_init] *ERROR* Unable to acquire AGP: -19
> [    6.028543] [drm] Forcing AGP to PCI mode
> [    6.028631] [drm] Generation 1 PCI interface in multifunction mode
>
> Note: Nevermind the timing, timer frequency isn't the same between the
> two runs (250 Hz vs 1000 Hz).
>
> I've managed to nearly bisect the regression. I say nearly, because
> some commits made the kernel unbuildable and must be skipped.
>
> So, the offending candidates are:
> - 66345d5f79fcfa0214f5d98763643d4ee8e6965d (ACPI / ia64 / sba_iommu:
> Use ACPI scan handler for device discovery);
> - 24071f472d813fccacc1ef7356b1f41422a1b968 (ACPI / scan: Do not bind
> ACPI drivers to objects with scan handlers);
> - d9e455f53f6fb93c764de2399c3894bbdfd2caa7 (ACPI / scan: Simplify ACPI
> driver probing).
> These were merged with 8e9914d5efe460600f5948da7ae4c1b6c038a4c0 (Merge
> branch 'acpi-scan').
>
> I bet that the culprit is 66345d5f79fcfa0214f5d98763643d4ee8e6965d as
> it is zx1 specific, but I can't verify for sure as reverting it makes
> the kernel panics:
> IOC IOMMU Driver: probe of HWP0001:00 failed with error -22
> Kernel panic - not syncinc: Unable to find SBA IOMMU: Try a generic or
> DIG kernel
> (Yep, I'm running HP-zx1/sx1000, i.e. CONFIG_IA64_HP_ZX1=3Dy kernel).
>
> What's your opinion ia64 gurus? How to fix the breakage with the zx1
> AGP GART detection?
>
> Thanks,
>
>      =C3=89meric
