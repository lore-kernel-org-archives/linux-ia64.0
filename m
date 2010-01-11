From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 11 Jan 2010 21:40:30 +0000
Subject: Re: [drm:drm_mmap_locked] *ERROR* Could not find map: Could this be  kernel-related?
Message-Id: <201001111440.30572.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <d72eeaf61001041440s58b51b9j58e62af378b55224@mail.gmail.com>
In-Reply-To: <d72eeaf61001041440s58b51b9j58e62af378b55224@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Monday 11 January 2010 02:18:11 pm =C9meric Maschino wrote:
> 2010/1/11 Bjorn Helgaas <bjorn.helgaas@hp.com>:
> > On Monday 11 January 2010 11:23:30 am Luck, Tony wrote:
> >> > =A0 =A0 =A0 =A0printk(KERN_INFO PFX "Detected HP ZX1 %s AGP chipset "
> >> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"(ioc=3D%llx, lba=3D%llx)\n", (char *=
)context,
> >> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sba_hpa + HP_ZX1_IOC_OFFSET, lba_hpa);
> >> >
> >> >If hp_zx1_setup returned 0, we should see the "Detected HP ZX1
> >> >HWP0003 AGP chipset" message next, but we don't
>=20
> Sorry guys, my mistake: I had the return AE_OK line; duplicated!

Probably my fault for sending you an additional patch; sometimes
"patch" adds things twice if things don't match up exactly right.

> [   13.986234] Linux agpgart interface v0.103
> [   13.992347] agp_hp_init
> [   14.091509] agpgart: HP ZX1 IOC: IOPDIR shared with sba_iommu
> [   14.091546] GART at 0xe000004080ec0000
> [   14.091577] read cookie at 0xe000004080ec0000: 0xbadbadc0ffee
> [   14.091618] hp_zx1_create_gatt_table
> [   14.092261]  (null): AGP aperture is 512M @ 0x60000000
> [   14.092295] agp_add_bridge: returning 0 (success)
> [   14.092328] hp_zx1_setup: agp_add_bridge returned 0
> [   14.092361] zx1_gart_probe: hp_zx1_setup returned 0
> [   14.092394] agpgart: Detected HP ZX1 HWP0003 AGP chipset
> (ioc=FEd01000, lba=FEd28000)

> Looks as expected this time :-)

Yep!  So you should be able to remove the debug patches and go back to
the plain upstream kernel + the "ACPICA: acpi_get_object_info(): fixup
array -> pointer conversion" bug fix.

Right?  I'm a bit confused because that should have been what you were
testing here: http://marc.info/?l=3Dlinux-ia64&m=126290536216298&w=3D2,
unless you applied the patch by hand and made a mistake.

> I've initially posted the dmesg command output because drm-related
> messages don't seem to be logged in /var/log/dmesg. We thus could have
> the impression that everything is fine, but the dmesg command output
> reveals that the drm_mmap_locked error is still there:

I'm afraid I won't be much help with the DRM issue below.  I think
you'll have better luck with the dri-devel people now.  If this is
a regression and you can identify an old working kernel, that might
help.

Bjorn

> [   26.337042] [drm] Initialized drm 1.1.0 20060810
> [   26.654034] [drm] radeon defaulting to userspace modesetting.
> [   26.654042] [drm:drm_init],
> [   26.654119] [drm:drm_get_dev],
> [   26.654674] [drm:drm_get_minor],
> [   26.656293] [drm:drm_get_minor], new minor assigned 0
> [   26.656468] [drm:drm_addmap_core], offset =3D 0xd8030000, size > 0x000=
10000, type =3D 1
> [   26.656478] [drm:radeon_driver_load], AGP card detected
> [   26.656483] [drm] Initialized radeon 1.31.0 20080528 for
> 0000:80:00.0 on minor 0
> [   26.657092] [drm:drm_stub_open],
> [   26.657097] [drm:drm_open_helper], pid =3D 1576, minor =3D 0
> [   26.657102] [drm:radeon_driver_open],
> [   26.657107] [drm:drm_addmap_core], offset =3D 0x00000000, size > 0x000=
10000, type =3D 2
> [   26.657140] [drm:drm_addmap_core], 65536 16 a000000203600000
> [   26.657147] [drm:drm_addmap_core], offset =3D 0xd0000000, size > 0x080=
00000, type =3D 0
> [   26.657154] [drm:drm_setup],
> [   26.657215] [drm:drm_ioctl], pid=1576, cmd=3D0xc0106407, nr=3D0x07, dev
> 0xe200, auth=3D1
> [   26.657230] [drm:drm_ioctl], pid=1576, cmd=3D0xc0106401, nr=3D0x01, dev
> 0xe200, auth=3D1
> [   26.657240] [drm:drm_ioctl], pid=1576, cmd=3D0xc0106401, nr=3D0x01, dev
> 0xe200, auth=3D1
> [   26.657284] [drm:drm_ioctl], pid=1576, cmd=3D0xc0406400, nr=3D0x00, dev
> 0xe200, auth=3D1
> [   26.657291] [drm:drm_ioctl], pid=1576, cmd=3D0xc0406400, nr=3D0x00, dev
> 0xe200, auth=3D1
> [   26.657383] [drm:drm_release], open_count =3D 1
> [   26.657387] [drm:drm_release], pid =3D 1576, device =3D 0xe200, open_c=
ount =3D 1
> [   26.657398] [drm:drm_lastclose],
> [   26.657404] [drm:radeon_do_cleanup_cp],
> [   26.657407] [drm:drm_lastclose], driver lastclose completed
> [   26.657413] [drm:drm_lastclose], lastclose completed
> [   26.963807] [drm:drm_stub_open],
> [   26.963811] [drm:drm_open_helper], pid =3D 1576, minor =3D 0
> [   26.963816] [drm:radeon_driver_open],
> [   26.963820] [drm:drm_addmap_core], offset =3D 0x00000000, size > 0x000=
10000, type =3D 2
> [   26.963855] [drm:drm_addmap_core], 65536 16 a000000203700000
> [   26.963860] [drm:drm_addmap_core], offset =3D 0xd0000000, size > 0x080=
00000, type =3D 0
> [   26.963866] [drm:drm_setup],
> [   26.963885] [drm:drm_ioctl], pid=1576, cmd=3D0xc0406400, nr=3D0x00, dev
> 0xe200, auth=3D1
> [   26.963892] [drm:drm_ioctl], pid=1576, cmd=3D0xc0406400, nr=3D0x00, dev
> 0xe200, auth=3D1
> [   26.963903] [drm:drm_release], open_count =3D 1
> [   26.963906] [drm:drm_release], pid =3D 1576, device =3D 0xe200, open_c=
ount =3D 1
> [   26.963915] [drm:drm_lastclose],
> [   26.963919] [drm:radeon_do_cleanup_cp],
> [   26.963923] [drm:drm_lastclose], driver lastclose completed
> [   26.963927] [drm:drm_lastclose], lastclose completed
> [   26.963963] [drm:drm_stub_open],
> [   26.963966] [drm:drm_open_helper], pid =3D 1576, minor =3D 0
> [   26.963970] [drm:radeon_driver_open],
> [   26.963974] [drm:drm_addmap_core], offset =3D 0x00000000, size > 0x000=
10000, type =3D 2
> [   26.964005] [drm:drm_addmap_core], 65536 16 a000000203800000
> [   26.964010] [drm:drm_addmap_core], offset =3D 0xd0000000, size > 0x080=
00000, type =3D 0
> [   26.964016] [drm:drm_setup],
> [   26.964029] [drm:drm_ioctl], pid=1576, cmd=3D0xc0406400, nr=3D0x00, dev
> 0xe200, auth=3D1
> [   26.964036] [drm:drm_ioctl], pid=1576, cmd=3D0xc0406400, nr=3D0x00, dev
> 0xe200, auth=3D1
> [   26.964044] [drm:drm_release], open_count =3D 1
> [   26.964048] [drm:drm_release], pid =3D 1576, device =3D 0xe200, open_c=
ount =3D 1
> [   26.964056] [drm:drm_lastclose],
> [   26.964060] [drm:radeon_do_cleanup_cp],
> [   26.964063] [drm:drm_lastclose], driver lastclose completed
> [   26.964067] [drm:drm_lastclose], lastclose completed
> [   26.964095] [drm:drm_stub_open],
> [   26.964098] [drm:drm_open_helper], pid =3D 1576, minor =3D 0
> [   26.964102] [drm:radeon_driver_open],
> [   26.964106] [drm:drm_addmap_core], offset =3D 0x00000000, size > 0x000=
10000, type =3D 2
> [   26.964136] [drm:drm_addmap_core], 65536 16 a000000203900000
> [   26.964141] [drm:drm_addmap_core], offset =3D 0xd0000000, size > 0x080=
00000, type =3D 0
> [   26.964147] [drm:drm_setup],
> [   26.964167] [drm:drm_ioctl], pid=1576, cmd=3D0xc0106407, nr=3D0x07, dev
> 0xe200, auth=3D1
> [   26.964175] [drm:drm_ioctl], pid=1576, cmd=3D0xc0106401, nr=3D0x01, dev
> 0xe200, auth=3D1
> [   26.964181] [drm:drm_ioctl], pid=1576, cmd=3D0xc0106401, nr=3D0x01, dev
> 0xe200, auth=3D1
> [   26.964199] [drm:drm_ioctl], pid=1576, cmd=3D0xc0106407, nr=3D0x07, dev
> 0xe200, auth=3D1
> [   26.964217] [drm:drm_ioctl], pid=1576, cmd=3D0xc0286415, nr=3D0x15, dev
> 0xe200, auth=3D1
> [   26.964223] [drm:drm_addmap_core], offset =3D 0x00000000, size > 0x000=
10000, type =3D 2
> [   26.964241] [drm:drm_mmap_locked], start =3D 0x200000000d500000, end
> =3D 0x200000000d510000, page offset =3D 0x3dc0
> [   26.964247] [drm:drm_mmap_locked] *ERROR* Could not find map
> [   26.964271] [drm:drm_ioctl], pid=1576, cmd=3D0x4028641b, nr=3D0x1b, dev
> 0xe200, auth=3D1
> [   26.964277] [drm:drm_ioctl], ret =3D ffffffea
> [   26.964291] [drm:drm_release], open_count =3D 1
> [   26.964294] [drm:drm_release], pid =3D 1576, device =3D 0xe200, open_c=
ount =3D 1
> [   26.964302] [drm:drm_lastclose],
> [   26.964307] [drm:radeon_do_cleanup_cp],
> [   26.964310] [drm:drm_lastclose], driver lastclose completed
> [   26.964314] [drm:drm_lastclose], lastclose completed
>=20
> =C9meric
>=20


