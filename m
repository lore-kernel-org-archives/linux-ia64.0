From: =?ISO-8859-1?Q?=C9meric_Maschino?= <emeric.maschino@gmail.com>
Date: Wed, 13 Jan 2010 07:15:00 +0000
Subject: Re: [drm:drm_mmap_locked] *ERROR* Could not find map: Could this be
Message-Id: <d72eeaf61001122315u7c28b46dve35623d84745d9c4@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <d72eeaf61001041440s58b51b9j58e62af378b55224@mail.gmail.com>
In-Reply-To: <d72eeaf61001041440s58b51b9j58e62af378b55224@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

2010/1/11 Bjorn Helgaas <bjorn.helgaas@hp.com>:
> Right? =A0I'm a bit confused because that should have been what you were
> testing here: http://marc.info/?l=3Dlinux-ia64&m=126290536216298&w=3D2,
> unless you applied the patch by hand and made a mistake.

I've probably incorrectly applied your patches without restarting from
the original file at each attempt. Anyway, it's fine now, thanks.

> I'm afraid I won't be much help with the DRM issue below. =A0I think
> you'll have better luck with the dri-devel people now. =A0If this is
> a regression and you can identify an old working kernel, that might
> help.

I've performed regression tests. The problem appears with kernel
2.6.30. Last working kernel is 2.6.29.6. I'm not a kernel developer,
but could this be due to this commit
http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3Dcomm=
itdiff;h=955b12def42e83287c1bdb1411d99451753c1391?

Please find below the output of the dmesg command (to have the drm:
messages recorded) of the failing kernel 2.6.30:

[   13.514844] Linux agpgart interface v0.103
[   13.621903] agpgart: HP ZX1 IOC: IOPDIR shared with sba_iommu
[   13.622262]  <NULL>: AGP aperture is 512M @ 0x60000000
[   13.622297] agpgart: Detected HP ZX1 HWP0003 AGP chipset
(ioc=FEd01000, lba=FEd28000)
<snip>
[   19.646054] pci 0000:80:00.0: PCI INT A -> GSI 60 (level, low) -> IRQ 60
[   25.955964] [drm] Initialized drm 1.1.0 20060810
[   25.990291] [drm:drm_init]
[   25.990371] [drm:drm_get_dev]
[   25.990629] [drm:drm_get_minor]
[   25.990754] [drm:drm_get_minor] new minor assigned 0
[   25.990926] [drm:drm_addmap_core] offset =3D 0xd8030000, size 0x00010000=
, type =3D 1
[   25.990937] [drm:radeon_driver_load] AGP card detected
[   25.990941] [drm] Initialized radeon 1.30.0 20080528 for
0000:80:00.0 on minor 0
[   25.992136] [drm:drm_stub_open]
[   25.992141] [drm:drm_open_helper] pid =3D 1774, minor =3D 0
[   25.992145] [drm:radeon_driver_open]
[   25.992150] [drm:drm_addmap_core] offset =3D 0x00000000, size 0x00010000=
, type =3D 2
[   25.992173] [drm:drm_addmap_core] 65536 16 a000000202eb8000
[   25.992178] [drm:drm_addmap_core] offset =3D 0xd0000000, size 0x08000000=
, type =3D 0
[   25.992190] [drm:drm_setup]
[   25.992241] [drm:drm_ioctl] pid=1774, cmd=3D0xc0106407, nr=3D0x07, dev
0xe200, auth=3D1
[   25.992254] [drm:drm_ioctl] pid=1774, cmd=3D0xc0106401, nr=3D0x01, dev
0xe200, auth=3D1
[   25.992262] [drm:drm_ioctl] pid=1774, cmd=3D0xc0106401, nr=3D0x01, dev
0xe200, auth=3D1
[   25.992300] [drm:drm_ioctl] pid=1774, cmd=3D0xc0406400, nr=3D0x00, dev
0xe200, auth=3D1
[   25.992307] [drm:drm_ioctl] pid=1774, cmd=3D0xc0406400, nr=3D0x00, dev
0xe200, auth=3D1
[   25.992393] [drm:drm_release] open_count =3D 1
[   25.992397] [drm:drm_release] pid =3D 1774, device =3D 0xe200, open_coun=
t =3D 1
[   25.992408] [drm:drm_lastclose]
[   25.992413] [drm:radeon_do_cleanup_cp]
[   25.992416] [drm:drm_lastclose] driver lastclose completed
[   25.992421] [drm:drm_lastclose] lastclose completed
[   26.302448] [drm:drm_stub_open]
[   26.302452] [drm:drm_open_helper] pid =3D 1774, minor =3D 0
[   26.302455] [drm:radeon_driver_open]
[   26.302460] [drm:drm_addmap_core] offset =3D 0x00000000, size 0x00010000=
, type =3D 2
[   26.302484] [drm:drm_addmap_core] 65536 16 a000000202ed0000
[   26.302488] [drm:drm_addmap_core] offset =3D 0xd0000000, size 0x08000000=
, type =3D 0
[   26.302493] [drm:drm_setup]
[   26.302512] [drm:drm_ioctl] pid=1774, cmd=3D0xc0406400, nr=3D0x00, dev
0xe200, auth=3D1
[   26.302519] [drm:drm_ioctl] pid=1774, cmd=3D0xc0406400, nr=3D0x00, dev
0xe200, auth=3D1
[   26.302528] [drm:drm_release] open_count =3D 1
[   26.302531] [drm:drm_release] pid =3D 1774, device =3D 0xe200, open_coun=
t =3D 1
[   26.302538] [drm:drm_lastclose]
[   26.302542] [drm:radeon_do_cleanup_cp]
[   26.302545] [drm:drm_lastclose] driver lastclose completed
[   26.302548] [drm:drm_lastclose] lastclose completed
[   26.302583] [drm:drm_stub_open]
[   26.302586] [drm:drm_open_helper] pid =3D 1774, minor =3D 0
[   26.302589] [drm:radeon_driver_open]
[   26.302593] [drm:drm_addmap_core] offset =3D 0x00000000, size 0x00010000=
, type =3D 2
[   26.302613] [drm:drm_addmap_core] 65536 16 a000000202ee8000
[   26.302617] [drm:drm_addmap_core] offset =3D 0xd0000000, size 0x08000000=
, type =3D 0
[   26.302621] [drm:drm_setup]
[   26.302636] [drm:drm_ioctl] pid=1774, cmd=3D0xc0406400, nr=3D0x00, dev
0xe200, auth=3D1
[   26.302642] [drm:drm_ioctl] pid=1774, cmd=3D0xc0406400, nr=3D0x00, dev
0xe200, auth=3D1
[   26.302648] [drm:drm_release] open_count =3D 1
[   26.302652] [drm:drm_release] pid =3D 1774, device =3D 0xe200, open_coun=
t =3D 1
[   26.302658] [drm:drm_lastclose]
[   26.302662] [drm:radeon_do_cleanup_cp]
[   26.302665] [drm:drm_lastclose] driver lastclose completed
[   26.302668] [drm:drm_lastclose] lastclose completed
[   26.302695] [drm:drm_stub_open]
[   26.302698] [drm:drm_open_helper] pid =3D 1774, minor =3D 0
[   26.302702] [drm:radeon_driver_open]
[   26.302706] [drm:drm_addmap_core] offset =3D 0x00000000, size 0x00010000=
, type =3D 2
[   26.302726] [drm:drm_addmap_core] 65536 16 a000000202f00000
[   26.302730] [drm:drm_addmap_core] offset =3D 0xd0000000, size 0x08000000=
, type =3D 0
[   26.302735] [drm:drm_setup]
[   26.302756] [drm:drm_ioctl] pid=1774, cmd=3D0xc0106407, nr=3D0x07, dev
0xe200, auth=3D1
[   26.302763] [drm:drm_ioctl] pid=1774, cmd=3D0xc0106401, nr=3D0x01, dev
0xe200, auth=3D1
[   26.302768] [drm:drm_ioctl] pid=1774, cmd=3D0xc0106401, nr=3D0x01, dev
0xe200, auth=3D1
[   26.302786] [drm:drm_ioctl] pid=1774, cmd=3D0xc0106407, nr=3D0x07, dev
0xe200, auth=3D1
[   26.302803] [drm:drm_ioctl] pid=1774, cmd=3D0xc0286415, nr=3D0x15, dev
0xe200, auth=3D1
[   26.302808] [drm:drm_addmap_core] offset =3D 0x00000000, size 0x00010000=
, type =3D 2
[   26.302825] [drm:drm_mmap_locked] start =3D 0x200000000d500000, end 0x20=
0000000d510000, page offset =3D 0x3dc0
[   26.302829] [drm:drm_mmap_locked] *ERROR* Could not find map
[   26.302854] [drm:drm_ioctl] pid=1774, cmd=3D0x4028641b, nr=3D0x1b, dev
0xe200, auth=3D1
[   26.302858] [drm:drm_ioctl] ret =3D ffffffea
[   26.302871] [drm:drm_release] open_count =3D 1
[   26.302874] [drm:drm_release] pid =3D 1774, device =3D 0xe200, open_coun=
t =3D 1
[   26.302881] [drm:drm_lastclose]
[   26.302885] [drm:radeon_do_cleanup_cp]
[   26.302887] [drm:drm_lastclose] driver lastclose completed
[   26.302891] [drm:drm_lastclose] lastclose completed

And by contrast, here's the output of the working 2.6.29.6 kernel:

[   14.702815] Linux agpgart interface v0.103
[   14.816300] agpgart: HP ZX1 IOC: IOPDIR shared with sba_iommu
[   14.816653]  : AGP aperture is 512M @ 0x60000000
[   14.816687] agpgart: Detected HP ZX1 HWP0003 AGP chipset
(ioc=FEd01000, lba=FEd28000)
<snip>
[   20.592635] pci 0000:80:00.0: PCI INT A -> GSI 60 (level, low) -> IRQ 60
[   26.873849] [drm] Initialized drm 1.1.0 20060810
[   26.901139] [drm:drm_init]
[   26.901213] [drm:drm_get_dev]
[   26.901471] [drm:drm_get_minor]
[   26.901585] [drm:drm_get_minor] new minor assigned 0
[   26.901757] [drm:drm_addmap_core] offset =3D 0xd8030000, size 0x00010000=
, type =3D 1
[   26.901765] [drm:radeon_driver_load] AGP card detected
[   26.901768] [drm] Initialized radeon 1.29.0 20080528 on minor 0
[   26.902633] [drm:drm_stub_open]
[   26.902637] [drm:drm_open_helper] pid =3D 1843, minor =3D 0
[   26.902641] [drm:radeon_driver_open]
[   26.902645] [drm:drm_addmap_core] offset =3D 0x00000000, size 0x00010000=
, type =3D 2
[   26.902669] [drm:drm_addmap_core] 65536 16 a000000202f20000
[   26.902674] [drm:drm_addmap_core] offset =3D 0xd0000000, size 0x08000000=
, type =3D 0
[   26.902678] [drm:drm_setup]
[   26.902721] [drm:drm_ioctl] pid=1843, cmd=3D0xc0106407, nr=3D0x07, dev
0xe200, auth=3D1
[   26.902732] [drm:drm_ioctl] pid=1843, cmd=3D0xc0106401, nr=3D0x01, dev
0xe200, auth=3D1
[   26.902739] [drm:drm_ioctl] pid=1843, cmd=3D0xc0106401, nr=3D0x01, dev
0xe200, auth=3D1
[   26.902772] [drm:drm_ioctl] pid=1843, cmd=3D0xc0406400, nr=3D0x00, dev
0xe200, auth=3D1
[   26.902778] [drm:drm_ioctl] pid=1843, cmd=3D0xc0406400, nr=3D0x00, dev
0xe200, auth=3D1
[   26.902862] [drm:drm_release] open_count =3D 1
[   26.902865] [drm:drm_release] pid =3D 1843, device =3D 0xe200, open_coun=
t =3D 1
[   26.902875] [drm:drm_lastclose]
[   26.902880] [drm:radeon_do_cleanup_cp]
[   26.902882] [drm:drm_lastclose] driver lastclose completed
[   26.902887] [drm:drm_lastclose] lastclose completed
[   27.208991] [drm:drm_stub_open]
[   27.208994] [drm:drm_open_helper] pid =3D 1843, minor =3D 0
[   27.208996] [drm:radeon_driver_open]
[   27.209000] [drm:drm_addmap_core] offset =3D 0x00000000, size 0x00010000=
, type =3D 2
[   27.209025] [drm:drm_addmap_core] 65536 16 a000000202f38000
[   27.209029] [drm:drm_addmap_core] offset =3D 0xd0000000, size 0x08000000=
, type =3D 0
[   27.209033] [drm:drm_setup]
[   27.209051] [drm:drm_ioctl] pid=1843, cmd=3D0xc0406400, nr=3D0x00, dev
0xe200, auth=3D1
[   27.209057] [drm:drm_ioctl] pid=1843, cmd=3D0xc0406400, nr=3D0x00, dev
0xe200, auth=3D1
[   27.209066] [drm:drm_release] open_count =3D 1
[   27.209069] [drm:drm_release] pid =3D 1843, device =3D 0xe200, open_coun=
t =3D 1
[   27.209075] [drm:drm_lastclose]
[   27.209079] [drm:radeon_do_cleanup_cp]
[   27.209081] [drm:drm_lastclose] driver lastclose completed
[   27.209084] [drm:drm_lastclose] lastclose completed
[   27.209118] [drm:drm_stub_open]
[   27.209121] [drm:drm_open_helper] pid =3D 1843, minor =3D 0
[   27.209123] [drm:radeon_driver_open]
[   27.209127] [drm:drm_addmap_core] offset =3D 0x00000000, size 0x00010000=
, type =3D 2
[   27.209147] [drm:drm_addmap_core] 65536 16 a000000202f50000
[   27.209151] [drm:drm_addmap_core] offset =3D 0xd0000000, size 0x08000000=
, type =3D 0
[   27.209158] [drm:drm_setup]
[   27.209171] [drm:drm_ioctl] pid=1843, cmd=3D0xc0406400, nr=3D0x00, dev
0xe200, auth=3D1
[   27.209177] [drm:drm_ioctl] pid=1843, cmd=3D0xc0406400, nr=3D0x00, dev
0xe200, auth=3D1
[   27.209183] [drm:drm_release] open_count =3D 1
[   27.209186] [drm:drm_release] pid =3D 1843, device =3D 0xe200, open_coun=
t =3D 1
[   27.209192] [drm:drm_lastclose]
[   27.209195] [drm:radeon_do_cleanup_cp]
[   27.209197] [drm:drm_lastclose] driver lastclose completed
[   27.209201] [drm:drm_lastclose] lastclose completed
[   27.209227] [drm:drm_stub_open]
[   27.209229] [drm:drm_open_helper] pid =3D 1843, minor =3D 0
[   27.209232] [drm:radeon_driver_open]
[   27.209235] [drm:drm_addmap_core] offset =3D 0x00000000, size 0x00010000=
, type =3D 2
[   27.209254] [drm:drm_addmap_core] 65536 16 a000000202f68000
[   27.209258] [drm:drm_addmap_core] offset =3D 0xd0000000, size 0x08000000=
, type =3D 0
[   27.209262] [drm:drm_setup]
[   27.209282] [drm:drm_ioctl] pid=1843, cmd=3D0xc0106407, nr=3D0x07, dev
0xe200, auth=3D1
[   27.209288] [drm:drm_ioctl] pid=1843, cmd=3D0xc0106401, nr=3D0x01, dev
0xe200, auth=3D1
[   27.209293] [drm:drm_ioctl] pid=1843, cmd=3D0xc0106401, nr=3D0x01, dev
0xe200, auth=3D1
[   27.209310] [drm:drm_ioctl] pid=1843, cmd=3D0xc0106407, nr=3D0x07, dev
0xe200, auth=3D1
[   27.209327] [drm:drm_ioctl] pid=1843, cmd=3D0xc0286415, nr=3D0x15, dev
0xe200, auth=3D1
[   27.209331] [drm:drm_addmap_core] offset =3D 0x00000000, size 0x00010000=
, type =3D 2
[   27.209347] [drm:drm_mmap_locked] start =3D 0x200000000d500000, end 0x20=
0000000d510000, page offset =3D 0x8ffb
[   27.209352] [drm:drm_vm_open_locked] 0x200000000d500000,0x00010000
[   27.209361] [drm:drm_do_vm_shm_fault] shm_fault 0x0
[   27.209366] [drm:drm_do_vm_shm_fault] shm_fault 0x4000
[   27.209374] [drm:drm_do_vm_shm_fault] shm_fault 0x8000
[   27.209379] [drm:drm_do_vm_shm_fault] shm_fault 0xc000
[   27.209410] [drm:drm_ioctl] pid=1843, cmd=3D0xc0286415, nr=3D0x15, dev
0xe200, auth=3D1
[   27.209414] [drm:drm_addmap_core] offset =3D 0xd0000000, size 0x08000000=
, type =3D 0
[   27.209432] [drm:drm_ioctl] pid=1843, cmd=3D0xc0106426, nr=3D0x26, dev
0xe200, auth=3D1
[   27.209438] [drm:drm_ioctl] pid=1843, cmd=3D0xc0106426, nr=3D0x26, dev
0xe200, auth=3D1
[   27.209475] [drm:drm_ioctl] pid=1843, cmd=3D0xc0086420, nr=3D0x20, dev
0xe200, auth=3D1
[   27.209486] [drm:drm_addctx] 1
[   27.209495] [drm:drm_ioctl] pid=1843, cmd=3D0x40086422, nr=3D0x22, dev
0xe200, auth=3D1
[   27.209515] [drm:drm_ioctl] pid=1843, cmd=3D0x4008642a, nr=3D0x2a, dev
0xe200, auth=3D1
[   27.209519] [drm:drm_lock] 1 (pid 1843) requests lock (0x00000000),
flags =3D 0x00000000
[   27.209523] [drm:drm_lock] 1 has lock
[   27.209545] [drm:drm_fasync] fd =3D 7, device =3D 0xe200
[   27.209574] [drm:drm_ioctl] pid=1843, cmd=3D0x6430, nr=3D0x30, dev 0xe20=
0, auth=3D1
[   27.209583] [drm:drm_ioctl] pid=1843, cmd=3D0x80386433, nr=3D0x33, dev
0xe200, auth=3D1
[   27.209592] [drm:drm_ioctl] pid=1843, cmd=3D0x80386433, nr=3D0x33, dev
0xe200, auth=3D1
[   27.209599] [drm:drm_ioctl] pid=1843, cmd=3D0x80386433, nr=3D0x33, dev
0xe200, auth=3D1
[   27.209631] [drm:drm_ioctl] pid=1843, cmd=3D0x40086432, nr=3D0x32, dev
0xe200, auth=3D1
[   27.211781] pci 0000:80:00.0: putting AGP V2 device into 2x mode
[   27.212072] [drm:drm_ioctl] pid=1843, cmd=3D0xc0206434, nr=3D0x34, dev
0xe200, auth=3D1
[   27.230746] [drm:drm_ioctl] pid=1843, cmd=3D0x40106436, nr=3D0x36, dev
0xe200, auth=3D1
[   27.230819] [drm:drm_agp_bind] base =3D 0x60000000 entry->bound =3D 0x60=
000000
[   27.230826] [drm:drm_ioctl] pid=1843, cmd=3D0xc0286415, nr=3D0x15, dev
0xe200, auth=3D1
[   27.230830] [drm:drm_addmap_core] offset =3D 0x00000000, size 0x00104000=
, type =3D 3
[   27.230834] [drm:drm_addmap_core] AGP offset =3D 0x60000000, size =3D 0x=
00104000
[   27.230853] [drm:drm_mmap_locked] start =3D 0x200000000d600000, end 0x20=
0000000d704000, page offset =3D 0x18000
[   27.230858] [drm:drm_vm_open_locked] 0x200000000d600000,0x00104000
[   27.230872] [drm:drm_ioctl] pid=1843, cmd=3D0xc0286415, nr=3D0x15, dev
0xe200, auth=3D1
[   27.230876] [drm:drm_addmap_core] offset =3D 0x00104000, size 0x00004000=
, type =3D 3
[   27.230879] [drm:drm_addmap_core] AGP offset =3D 0x60104000, size =3D 0x=
00004000
[   27.230893] [drm:drm_mmap_locked] start =3D 0x200000000d800000, end 0x20=
0000000d804000, page offset =3D 0x18041
[   27.230897] [drm:drm_vm_open_locked] 0x200000000d800000,0x00004000
[   27.230910] [drm:drm_ioctl] pid=1843, cmd=3D0xc0286415, nr=3D0x15, dev
0xe200, auth=3D1
[   27.230914] [drm:drm_addmap_core] offset =3D 0x00108000, size 0x00200000=
, type =3D 3
[   27.230917] [drm:drm_addmap_core] AGP offset =3D 0x60108000, size =3D 0x=
00200000
[   27.230931] [drm:drm_mmap_locked] start =3D 0x200000000d900000, end 0x20=
0000000db00000, page offset =3D 0x18042
[   27.230935] [drm:drm_vm_open_locked] 0x200000000d900000,0x00200000
[   27.230948] [drm:drm_ioctl] pid=1843, cmd=3D0xc0286415, nr=3D0x15, dev
0xe200, auth=3D1
[   27.230952] [drm:drm_addmap_core] offset =3D 0x00308000, size 0x01c80000=
, type =3D 3
[   27.230955] [drm:drm_addmap_core] AGP offset =3D 0x60308000, size =3D 0x=
01c80000
[   27.230969] [drm:drm_mmap_locked] start =3D 0x200000000db00000, end 0x20=
0000000f780000, page offset =3D 0x180c2
[   27.230973] [drm:drm_vm_open_locked] 0x200000000db00000,0x01c80000
[   27.230989] [drm:drm_ioctl] pid=1843, cmd=3D0x80386433, nr=3D0x33, dev
0xe200, auth=3D1
[   27.230994] [drm:drm_ioctl] pid=1843, cmd=3D0xc0286415, nr=3D0x15, dev
0xe200, auth=3D1
[   27.230998] [drm:drm_addmap_core] offset =3D 0xd8030000, size 0x00010000=
, type =3D 1
[   27.231036] [drm:drm_ioctl] pid=1843, cmd=3D0x40106459, nr=3D0x59, dev
0xe200, auth=3D1
[   27.452149] [drm:drm_ioctl] pid=1843, cmd=3D0x40786440, nr=3D0x40, dev
0xe200, auth=3D1
[   27.452163] [drm:radeon_do_init_cp]
[   27.452224] [drm] Setting GART location based on new memory map
[   27.452228] [drm:radeon_do_init_cp] dev_priv->gart_size 33554432
[   27.452230] [drm:radeon_do_init_cp] dev_priv->gart_vm_start 0x60000000
[   27.452233] [drm:radeon_do_init_cp] dev_priv->gart_buffers_offset 0x6010=
8000
[   27.452238] [drm:radeon_cp_load_microcode]
[   27.452243] [drm] Loading R300 Microcode
[   27.452301] [drm:radeon_do_engine_reset]
[   27.452308] [drm] Num pipes: 2
[   27.452314] [drm:radeon_do_cp_reset]
[   27.452318] [drm] writeback test succeeded in 1 usecs
[   27.452336] [drm:drm_ioctl] pid=1843, cmd=3D0xc0206416, nr=3D0x16, dev
0xe200, auth=3D1
[   27.452340] [drm:drm_addbufs_agp] count:      32
[   27.452342] [drm:drm_addbufs_agp] order:      16
[   27.452344] [drm:drm_addbufs_agp] size:       65536
[   27.452347] [drm:drm_addbufs_agp] agp_offset: 60108000
[   27.452349] [drm:drm_addbufs_agp] alignment:  65536
[   27.452351] [drm:drm_addbufs_agp] page_order: 2
[   27.452353] [drm:drm_addbufs_agp] total:      65536
[   27.452358] [drm:drm_addbufs_agp] buffer 0 @ 0000000060108000
[   27.452361] [drm:drm_addbufs_agp] buffer 1 @ 0000000060118000
[   27.452364] [drm:drm_addbufs_agp] buffer 2 @ 0000000060128000
[   27.452366] [drm:drm_addbufs_agp] buffer 3 @ 0000000060138000
[   27.452369] [drm:drm_addbufs_agp] buffer 4 @ 0000000060148000
[   27.452372] [drm:drm_addbufs_agp] buffer 5 @ 0000000060158000
[   27.452375] [drm:drm_addbufs_agp] buffer 6 @ 0000000060168000
[   27.452377] [drm:drm_addbufs_agp] buffer 7 @ 0000000060178000
[   27.452380] [drm:drm_addbufs_agp] buffer 8 @ 0000000060188000
[   27.452383] [drm:drm_addbufs_agp] buffer 9 @ 0000000060198000
[   27.452385] [drm:drm_addbufs_agp] buffer 10 @ 00000000601a8000
[   27.452388] [drm:drm_addbufs_agp] buffer 11 @ 00000000601b8000
[   27.452392] [drm:drm_addbufs_agp] buffer 12 @ 00000000601c8000
[   27.452395] [drm:drm_addbufs_agp] buffer 13 @ 00000000601d8000
[   27.452398] [drm:drm_addbufs_agp] buffer 14 @ 00000000601e8000
[   27.452400] [drm:drm_addbufs_agp] buffer 15 @ 00000000601f8000
[   27.452403] [drm:drm_addbufs_agp] buffer 16 @ 0000000060208000
[   27.452406] [drm:drm_addbufs_agp] buffer 17 @ 0000000060218000
[   27.452409] [drm:drm_addbufs_agp] buffer 18 @ 0000000060228000
[   27.452411] [drm:drm_addbufs_agp] buffer 19 @ 0000000060238000
[   27.452414] [drm:drm_addbufs_agp] buffer 20 @ 0000000060248000
[   27.452417] [drm:drm_addbufs_agp] buffer 21 @ 0000000060258000
[   27.452419] [drm:drm_addbufs_agp] buffer 22 @ 0000000060268000
[   27.452422] [drm:drm_addbufs_agp] buffer 23 @ 0000000060278000
[   27.452425] [drm:drm_addbufs_agp] buffer 24 @ 0000000060288000
[   27.452428] [drm:drm_addbufs_agp] buffer 25 @ 0000000060298000
[   27.452430] [drm:drm_addbufs_agp] buffer 26 @ 00000000602a8000
[   27.452433] [drm:drm_addbufs_agp] buffer 27 @ 00000000602b8000
[   27.452436] [drm:drm_addbufs_agp] buffer 28 @ 00000000602c8000
[   27.452438] [drm:drm_addbufs_agp] buffer 29 @ 00000000602d8000
[   27.452441] [drm:drm_addbufs_agp] buffer 30 @ 00000000602e8000
[   27.452444] [drm:drm_addbufs_agp] buffer 31 @ 00000000602f8000
[   27.452446] [drm:drm_addbufs_agp] byte_count: 2097152
[   27.452449] [drm:drm_addbufs_agp] dma->buf_count : 32
[   27.452452] [drm:drm_addbufs_agp] entry->buf_count : 32
[   27.452470] [drm:drm_ioctl] pid=1843, cmd=3D0xc0186419, nr=3D0x19, dev
0xe200, auth=3D1
[   27.452475] [drm:drm_mapbufs] 32 buffers, retcode =3D 0
[   27.452479] [drm:drm_ioctl] pid=1843, cmd=3D0xc0186419, nr=3D0x19, dev
0xe200, auth=3D1
[   27.452485] [drm:drm_mmap_locked] start =3D 0x200000000f800000, end 0x20=
0000000fa00000, page offset =3D 0x18042
[   27.452489] [drm:drm_vm_open_locked] 0x200000000f800000,0x00200000
[   27.452496] [drm:drm_mapbufs] 32 buffers, retcode =3D 0
[   27.452515] [drm:drm_ioctl] pid=1843, cmd=3D0xc0106403, nr=3D0x03, dev
0xe200, auth=3D1
[   27.452519] [drm:drm_irq_by_busid] 128:0:0 =3D> IRQ 60
[   27.452526] [drm:drm_ioctl] pid=1843, cmd=3D0x40086414, nr=3D0x14, dev
0xe200, auth=3D1
[   27.452531] [drm:drm_irq_install] irq`
[   27.452558] [drm:drm_ioctl] pid=1843, cmd=3D0x40086408, nr=3D0x08, dev
0xe200, auth=3D1
[   27.452563] [drm:drm_vblank_get] enabling vblank on crtc 0, ret: 0
[   27.452567] [drm:drm_update_vblank_count] enabling vblank
interrupts on crtc 0, missed 48746
[   27.452572] [drm:drm_ioctl] pid=1843, cmd=3D0x40086408, nr=3D0x08, dev
0xe200, auth=3D1
[   27.452589] [drm:drm_ioctl] pid=1843, cmd=3D0x400c6455, nr=3D0x55, dev
0xe200, auth=3D1
[   27.452606] [drm:drm_ioctl] pid=1843, cmd=3D0x6441, nr=3D0x41, dev 0xe20=
0, auth=3D1
[   27.452609] [drm:radeon_cp_start]
[   27.452611] [drm:radeon_do_cp_start]
[   27.452624] [drm:drm_ioctl] pid=1843, cmd=3D0x40106459, nr=3D0x59, dev
0xe200, auth=3D1
[   27.560123] [drm:drm_ioctl] pid=1843, cmd=3D0x40106459, nr=3D0x59, dev
0xe200, auth=3D1
[   27.560126] [drm:radeon_cp_setparam] color tiling enabled
[   27.560133] [drm:drm_ioctl] pid=1843, cmd=3D0x4004645b, nr=3D0x5b, dev
0xe200, auth=3D1
[   27.560137] [drm:drm_ioctl] ret =3D ffffffea
[   27.560144] [drm:drm_ioctl] pid=1843, cmd=3D0x4004645b, nr=3D0x5b, dev
0xe200, auth=3D1
[   27.560147] [drm:drm_ioctl] ret =3D ffffffea
[   27.560151] [drm:drm_ioctl] pid=1843, cmd=3D0x4004645b, nr=3D0x5b, dev
0xe200, auth=3D1
[   27.560155] [drm:drm_ioctl] ret =3D ffffffea
[   27.560158] [drm:drm_ioctl] pid=1843, cmd=3D0x400c645a, nr=3D0x5a, dev
0xe200, auth=3D1
[   27.560162] [drm:radeon_do_cp_idle]
[   27.560244] [drm:drm_ioctl] pid=1843, cmd=3D0xc0106451, nr=3D0x51, dev
0xe200, auth=3D1
[   27.560248] [drm:radeon_cp_getparam] pid=1843
[   27.709239] [drm:drm_ioctl] pid=1843, cmd=3D0x40086408, nr=3D0x08, dev
0xe200, auth=3D1
[   27.709247] [drm:drm_ioctl] pid=1843, cmd=3D0x40086408, nr=3D0x08, dev
0xe200, auth=3D1
[   27.709251] [drm:drm_vblank_get] enabling vblank on crtc 1, ret: 0
[   27.709255] [drm:drm_update_vblank_count] enabling vblank
interrupts on crtc 1, missed 0
[   27.709264] [drm:drm_ioctl] pid=1843, cmd=3D0x6444, nr=3D0x44, dev 0xe20=
0, auth=3D1
[   27.709268] [drm:radeon_cp_idle]
[   27.709269] [drm:radeon_do_cp_idle]
[   27.709320] [drm:drm_ioctl] pid=1843, cmd=3D0x40086408, nr=3D0x08, dev
0xe200, auth=3D1
[   27.872179] [drm:drm_ioctl] pid=1843, cmd=3D0x40086408, nr=3D0x08, dev
0xe200, auth=3D1
[   27.872234] [drm:drm_ioctl] pid=1843, cmd=3D0x40086408, nr=3D0x08, dev
0xe200, auth=3D1
[   27.943500] [drm:drm_stub_open]
[   27.943503] [drm:drm_open_helper] pid =3D 1843, minor =3D 0
[   27.943507] [drm:radeon_driver_open]
[   27.943520] [drm:drm_ioctl] pid=1843, cmd=3D0xc0406400, nr=3D0x00, dev
0xe200, auth=3D1
[   27.943526] [drm:drm_ioctl] pid=1843, cmd=3D0xc0406400, nr=3D0x00, dev
0xe200, auth=3D1
[   27.943532] [drm:drm_release] open_count =3D 2
[   27.943535] [drm:drm_release] pid =3D 1843, device =3D 0xe200, open_coun=
t =3D 2
[   27.943563] [drm:drm_stub_open]
[   27.943566] [drm:drm_open_helper] pid =3D 1843, minor =3D 0
[   27.943568] [drm:radeon_driver_open]
[   27.943587] [drm:drm_ioctl] pid=1843, cmd=3D0xc0106407, nr=3D0x07, dev
0xe200, auth=3D1
[   27.943590] [drm:drm_ioctl] ret =3D fffffff3
[   27.943594] [drm:drm_ioctl] pid=1843, cmd=3D0xc0106401, nr=3D0x01, dev
0xe200, auth=3D1
[   27.943599] [drm:drm_ioctl] pid=1843, cmd=3D0xc0106401, nr=3D0x01, dev
0xe200, auth=3D1
[   27.943620] [drm:drm_ioctl] pid=1843, cmd=3D0x80046402, nr=3D0x02, dev
0xe200, auth=3D1
[   27.943624] [drm:drm_add_magic] 1
[   27.943626] [drm:drm_getmagic] 1
[   27.943634] [drm:drm_ioctl] pid=1843, cmd=3D0xc0406400, nr=3D0x00, dev
0xe200, auth=3D1
[   27.943639] [drm:drm_ioctl] pid=1843, cmd=3D0xc0406400, nr=3D0x00, dev
0xe200, auth=3D1
[   27.943653] [drm:drm_ioctl] pid=1843, cmd=3D0x40046411, nr=3D0x11, dev
0xe200, auth=3D1
[   27.943656] [drm:drm_authmagic] 1
[   27.943658] [drm:drm_remove_magic] 1
[   27.980598] [drm:drm_mmap_locked] start =3D 0x2000000010100000, end 0x20=
00000018100000, page offset =3D 0x34000
[   27.980704] [drm:drm_mmap_locked]    Type =3D 0; start 0x200000001010000=
0, end =3D 0x2000000018100000, offset =3D 0xd0000000
[   27.980708] [drm:drm_vm_open_locked] 0x2000000010100000,0x08000000
[   27.980714] [drm:drm_mmap_locked] start =3D 0x2000000018100000, end 0x20=
00000018110000, page offset =3D 0x8ffb
[   27.980718] [drm:drm_vm_open_locked] 0x2000000018100000,0x00010000
[   27.999586] [drm:drm_ioctl] pid=1843, cmd=3D0xc0106451, nr=3D0x51, dev
0xe200, auth=3D1
[   27.999590] [drm:radeon_cp_getparam] pid=1843
[   27.999594] [drm:drm_ioctl] pid=1843, cmd=3D0xc0106451, nr=3D0x51, dev
0xe200, auth=3D1
[   27.999597] [drm:radeon_cp_getparam] pid=1843
[   27.999601] [drm:drm_ioctl] pid=1843, cmd=3D0xc0106451, nr=3D0x51, dev
0xe200, auth=3D1
[   27.999604] [drm:radeon_cp_getparam] pid=1843
[   27.999614] [drm:drm_mmap_locked] start =3D 0x2000000018200000, end 0x20=
00000018210000, page offset =3D 0xbffe
[   27.999619] [drm:drm_mmap_locked]    Type =3D 1; start 0x200000001820000=
0, end =3D 0x2000000018210000, offset =3D 0xd8030000
[   27.999623] [drm:drm_vm_open_locked] 0x2000000018200000,0x00010000
[   27.999628] [drm:drm_mmap_locked] start =3D 0x2000000018300000, end 0x20=
00000018304000, page offset =3D 0x18041
[   27.999632] [drm:drm_vm_open_locked] 0x2000000018300000,0x00004000
[   27.999640] [drm:drm_ioctl] pid=1843, cmd=3D0xc0186419, nr=3D0x19, dev
0xe200, auth=3D1
[   27.999643] [drm:drm_mapbufs] 32 buffers, retcode =3D 0
[   27.999648] [drm:drm_ioctl] pid=1843, cmd=3D0xc0186419, nr=3D0x19, dev
0xe200, auth=3D1
[   27.999653] [drm:drm_mmap_locked] start =3D 0x2000000018400000, end 0x20=
00000018600000, page offset =3D 0x18042
[   27.999657] [drm:drm_vm_open_locked] 0x2000000018400000,0x00200000
[   27.999663] [drm:drm_mapbufs] 32 buffers, retcode =3D 0
[   27.999669] [drm:drm_mmap_locked] start =3D 0x2000000018600000, end 0x20=
0000001a280000, page offset =3D 0x180c2
[   27.999673] [drm:drm_vm_open_locked] 0x2000000018600000,0x01c80000
[   27.999678] [drm:drm_ioctl] pid=1843, cmd=3D0xc0106451, nr=3D0x51, dev
0xe200, auth=3D1
[   27.999681] [drm:radeon_cp_getparam] pid=1843
[   27.999687] [drm:drm_ioctl] pid=1843, cmd=3D0xc0106451, nr=3D0x51, dev
0xe200, auth=3D1
[   27.999690] [drm:radeon_cp_getparam] pid=1843
[   27.999697] [drm:drm_ioctl] pid=1843, cmd=3D0x40106459, nr=3D0x59, dev
0xe200, auth=3D1
[   28.001371] [drm:drm_do_vm_shm_fault] shm_fault 0x0
[   28.291803] [drm:drm_ioctl] pid=1843, cmd=3D0xc0406429, nr=3D0x29, dev
0xe200, auth=3D1
[   28.291809] [drm:radeon_freelist_get] done_age =3D -559038737
[   28.291819] [drm:drm_do_vm_fault] baddr =3D 0x60118000 page 0xe000004083=
c64000, offset =3D 0x46, count=3D3
[   28.319244] [drm:drm_vm_open_locked] 0x200000000d500000,0x00010000
[   28.319248] [drm:drm_vm_open_locked] 0x200000000d600000,0x00104000
[   28.319252] [drm:drm_vm_open_locked] 0x200000000d800000,0x00004000
[   28.319256] [drm:drm_vm_open_locked] 0x200000000d900000,0x00200000
[   28.319259] [drm:drm_vm_open_locked] 0x200000000db00000,0x01c80000
[   28.319265] [drm:drm_vm_open_locked] 0x200000000f800000,0x00200000
[   28.319513] [drm:drm_vm_open_locked] 0x2000000010100000,0x08000000
[   28.319517] [drm:drm_vm_open_locked] 0x2000000018100000,0x00010000
[   28.319521] [drm:drm_vm_open_locked] 0x2000000018200000,0x00010000
[   28.319525] [drm:drm_vm_open_locked] 0x2000000018300000,0x00004000
[   28.319528] [drm:drm_vm_open_locked] 0x2000000018400000,0x00200000
[   28.319532] [drm:drm_vm_open_locked] 0x2000000018600000,0x01c80000
[   28.320943] [drm:drm_vm_shm_close] 0x200000000d500000,0x00010000
[   28.320952] [drm:drm_vm_close] 0x200000000d600000,0x00104000
[   28.320955] [drm:drm_vm_close] 0x200000000d800000,0x00004000
[   28.320958] [drm:drm_vm_close] 0x200000000d900000,0x00200000
[   28.320962] [drm:drm_vm_close] 0x200000000db00000,0x01c80000
[   28.320965] [drm:drm_vm_close] 0x200000000f800000,0x00200000
[   28.320969] [drm:drm_vm_close] 0x2000000010100000,0x08000000
[   28.320972] [drm:drm_vm_shm_close] 0x2000000018100000,0x00010000
[   28.320975] [drm:drm_vm_close] 0x2000000018200000,0x00010000
[   28.320978] [drm:drm_vm_close] 0x2000000018300000,0x00004000
[   28.320981] [drm:drm_vm_close] 0x2000000018400000,0x00200000
[   28.320984] [drm:drm_vm_close] 0x2000000018600000,0x01c80000
[   28.598456] [drm:drm_ioctl] pid=1843, cmd=3D0xc010644d, nr=3D0x4d, dev
0xe200, auth=3D1
[   28.598463] [drm:radeon_cp_indirect] idx=3D1 s=3D0 e=96 d=3D1
[   28.598469] [drm:radeon_cp_dispatch_indirect] buf=3D1 s=3D0x0 e=3D0x60
[   28.637978] [drm:drm_vm_open_locked] 0x200000000d500000,0x00010000
[   28.637983] [drm:drm_vm_open_locked] 0x200000000d600000,0x00104000
[   28.637987] [drm:drm_vm_open_locked] 0x200000000d800000,0x00004000
[   28.637990] [drm:drm_vm_open_locked] 0x200000000d900000,0x00200000
[   28.637994] [drm:drm_vm_open_locked] 0x200000000db00000,0x01c80000
[   28.637997] [drm:drm_vm_open_locked] 0x200000000f800000,0x00200000
[   28.638244] [drm:drm_vm_open_locked] 0x2000000010100000,0x08000000
[   28.638248] [drm:drm_vm_open_locked] 0x2000000018100000,0x00010000
[   28.638252] [drm:drm_vm_open_locked] 0x2000000018200000,0x00010000
[   28.638255] [drm:drm_vm_open_locked] 0x2000000018300000,0x00004000
[   28.638259] [drm:drm_vm_open_locked] 0x2000000018400000,0x00200000
[   28.638262] [drm:drm_vm_open_locked] 0x2000000018600000,0x01c80000
[   28.639599] [drm:drm_vm_shm_close] 0x200000000d500000,0x00010000
[   28.639605] [drm:drm_vm_close] 0x200000000d600000,0x00104000
[   28.639608] [drm:drm_vm_close] 0x200000000d800000,0x00004000
[   28.639611] [drm:drm_vm_close] 0x200000000d900000,0x00200000
[   28.639614] [drm:drm_vm_close] 0x200000000db00000,0x01c80000
[   28.639617] [drm:drm_vm_close] 0x200000000f800000,0x00200000
[   28.639624] [drm:drm_vm_close] 0x2000000010100000,0x08000000
[   28.639627] [drm:drm_vm_shm_close] 0x2000000018100000,0x00010000
[   28.639630] [drm:drm_vm_close] 0x2000000018200000,0x00010000
[   28.639633] [drm:drm_vm_close] 0x2000000018300000,0x00004000
[   28.639636] [drm:drm_vm_close] 0x2000000018400000,0x00200000
[   28.639639] [drm:drm_vm_close] 0x2000000018600000,0x01c80000
[   28.721769] [drm:drm_vm_open_locked] 0x200000000d500000,0x00010000
[   28.721773] [drm:drm_vm_open_locked] 0x200000000d600000,0x00104000
[   28.721777] [drm:drm_vm_open_locked] 0x200000000d800000,0x00004000
[   28.721780] [drm:drm_vm_open_locked] 0x200000000d900000,0x00200000
[   28.721784] [drm:drm_vm_open_locked] 0x200000000db00000,0x01c80000
[   28.721788] [drm:drm_vm_open_locked] 0x200000000f800000,0x00200000
[   28.721991] [drm:drm_vm_open_locked] 0x2000000010100000,0x08000000
[   28.721995] [drm:drm_vm_open_locked] 0x2000000018100000,0x00010000
[   28.722000] [drm:drm_vm_open_locked] 0x2000000018200000,0x00010000
[   28.722003] [drm:drm_vm_open_locked] 0x2000000018300000,0x00004000
[   28.722007] [drm:drm_vm_open_locked] 0x2000000018400000,0x00200000
[   28.722011] [drm:drm_vm_open_locked] 0x2000000018600000,0x01c80000
[   28.723272] [drm:drm_vm_shm_close] 0x200000000d500000,0x00010000
[   28.723277] [drm:drm_vm_close] 0x200000000d600000,0x00104000
[   28.723281] [drm:drm_vm_close] 0x200000000d800000,0x00004000
[   28.723284] [drm:drm_vm_close] 0x200000000d900000,0x00200000
[   28.723287] [drm:drm_vm_close] 0x200000000db00000,0x01c80000
[   28.723292] [drm:drm_vm_close] 0x200000000f800000,0x00200000
[   28.723297] [drm:drm_vm_close] 0x2000000010100000,0x08000000
[   28.723300] [drm:drm_vm_shm_close] 0x2000000018100000,0x00010000
[   28.723303] [drm:drm_vm_close] 0x2000000018200000,0x00010000
[   28.723307] [drm:drm_vm_close] 0x2000000018300000,0x00004000
[   28.723310] [drm:drm_vm_close] 0x2000000018400000,0x00200000
[   28.723313] [drm:drm_vm_close] 0x2000000018600000,0x01c80000
[   28.794390] [drm:drm_vm_open_locked] 0x200000000d500000,0x00010000
[   28.794394] [drm:drm_vm_open_locked] 0x200000000d600000,0x00104000
[   28.794398] [drm:drm_vm_open_locked] 0x200000000d800000,0x00004000
[   28.794401] [drm:drm_vm_open_locked] 0x200000000d900000,0x00200000
[   28.794405] [drm:drm_vm_open_locked] 0x200000000db00000,0x01c80000
[   28.794408] [drm:drm_vm_open_locked] 0x200000000f800000,0x00200000
[   28.794655] [drm:drm_vm_open_locked] 0x2000000010100000,0x08000000
[   28.794659] [drm:drm_vm_open_locked] 0x2000000018100000,0x00010000
[   28.794663] [drm:drm_vm_open_locked] 0x2000000018200000,0x00010000
[   28.794666] [drm:drm_vm_open_locked] 0x2000000018300000,0x00004000
[   28.794670] [drm:drm_vm_open_locked] 0x2000000018400000,0x00200000
[   28.794673] [drm:drm_vm_open_locked] 0x2000000018600000,0x01c80000
[   28.796038] [drm:drm_vm_shm_close] 0x200000000d500000,0x00010000
[   28.796045] [drm:drm_vm_close] 0x200000000d600000,0x00104000
[   28.796048] [drm:drm_vm_close] 0x200000000d800000,0x00004000
[   28.796051] [drm:drm_vm_close] 0x200000000d900000,0x00200000
[   28.796054] [drm:drm_vm_close] 0x200000000db00000,0x01c80000
[   28.796058] [drm:drm_vm_close] 0x200000000f800000,0x00200000
[   28.796062] [drm:drm_vm_close] 0x2000000010100000,0x08000000
[   28.796065] [drm:drm_vm_shm_close] 0x2000000018100000,0x00010000
[   28.796068] [drm:drm_vm_close] 0x2000000018200000,0x00010000
[   28.796071] [drm:drm_vm_close] 0x2000000018300000,0x00004000
[   28.796074] [drm:drm_vm_close] 0x2000000018400000,0x00200000
[   28.796077] [drm:drm_vm_close] 0x2000000018600000,0x01c80000
[   28.937822] [drm:drm_ioctl] pid=1843, cmd=3D0x6444, nr=3D0x44, dev 0xe20=
0, auth=3D1
[   28.937826] [drm:radeon_cp_idle]
[   28.937829] [drm:radeon_do_cp_idle]
[   28.938758] [drm:drm_ioctl] pid=1843, cmd=3D0x6444, nr=3D0x44, dev 0xe20=
0, auth=3D1
[   28.938761] [drm:radeon_cp_idle]
[   28.938763] [drm:radeon_do_cp_idle]
[   28.939548] [drm:drm_ioctl] pid=1843, cmd=3D0x6444, nr=3D0x44, dev 0xe20=
0, auth=3D1
[   28.939550] [drm:radeon_cp_idle]
[   28.939552] [drm:radeon_do_cp_idle]
[   29.232847] [drm:drm_ioctl] pid=1843, cmd=3D0x6444, nr=3D0x44, dev 0xe20=
0, auth=3D1
[   29.232854] [drm:radeon_cp_idle]
[   29.232857] [drm:radeon_do_cp_idle]
[   29.233330] [drm:drm_ioctl] pid=1843, cmd=3D0x6444, nr=3D0x44, dev 0xe20=
0, auth=3D1
[   29.233333] [drm:radeon_cp_idle]
[   29.233335] [drm:radeon_do_cp_idle]
[   29.233774] [drm:drm_ioctl] pid=1843, cmd=3D0x6444, nr=3D0x44, dev 0xe20=
0, auth=3D1
[   29.233777] [drm:radeon_cp_idle]
[   29.233778] [drm:radeon_do_cp_idle]
[   29.234217] [drm:drm_ioctl] pid=1843, cmd=3D0x6444, nr=3D0x44, dev 0xe20=
0, auth=3D1
[   29.234220] [drm:radeon_cp_idle]
[   29.234221] [drm:radeon_do_cp_idle]
[   29.320200] [drm:drm_ioctl] pid=1843, cmd=3D0x6444, nr=3D0x44, dev 0xe20=
0, auth=3D1
[   29.320203] [drm:radeon_cp_idle]
[   29.320205] [drm:radeon_do_cp_idle]
[   29.321066] [drm:drm_ioctl] pid=1843, cmd=3D0x6444, nr=3D0x44, dev 0xe20=
0, auth=3D1
[   29.321069] [drm:radeon_cp_idle]
[   29.321070] [drm:radeon_do_cp_idle]
[   29.321497] [drm:drm_ioctl] pid=1843, cmd=3D0x6444, nr=3D0x44, dev 0xe20=
0, auth=3D1
[   29.321499] [drm:radeon_cp_idle]
[   29.321501] [drm:radeon_do_cp_idle]
[   29.321928] [drm:drm_ioctl] pid=1843, cmd=3D0x6444, nr=3D0x44, dev 0xe20=
0, auth=3D1
[   29.321931] [drm:radeon_cp_idle]
[   29.321933] [drm:radeon_do_cp_idle]
[   29.427881] [drm:drm_ioctl] pid=1843, cmd=3D0x6444, nr=3D0x44, dev 0xe20=
0, auth=3D1
[   29.427885] [drm:radeon_cp_idle]
[   29.427886] [drm:radeon_do_cp_idle]
[   29.436593] [drm:drm_ioctl] pid=1843, cmd=3D0xc0406429, nr=3D0x29, dev
0xe200, auth=3D1
[   29.436599] [drm:radeon_freelist_get] done_age =3D 1
[   29.436611] [drm:drm_do_vm_fault] baddr =3D 0x60128000 page 0xe000004083=
c74000, offset =3D 0x4a, count=3D3
[   29.436638] [drm:drm_ioctl] pid=1843, cmd=3D0xc010644d, nr=3D0x4d, dev
0xe200, auth=3D1
[   29.436643] [drm:radeon_cp_indirect] idx=3D2 s=3D0 e=112 d=3D1
[   29.436647] [drm:radeon_cp_dispatch_indirect] buf=3D2 s=3D0x0 e=3D0x70
[   29.860164] [drm:drm_ioctl] pid=1843, cmd=3D0x6444, nr=3D0x44, dev 0xe20=
0, auth=3D1
[   29.860168] [drm:radeon_cp_idle]
[   29.860171] [drm:radeon_do_cp_idle]
[   29.860186] [drm:drm_ioctl] pid=1843, cmd=3D0x40106459, nr=3D0x59, dev
0xe200, auth=3D1
[   29.860203] [drm:drm_ioctl] pid=1843, cmd=3D0x40086442, nr=3D0x42, dev
0xe200, auth=3D1
[   29.860207] [drm:radeon_cp_stop]
[   29.860209] [drm:radeon_do_cp_flush]
[   29.860211] [drm:radeon_do_cp_idle]
[   29.860217] [drm:radeon_do_cp_stop]
[   29.860219] [drm:radeon_do_engine_reset]
[   29.860226] [drm] Num pipes: 2
[   29.860233] [drm:radeon_do_cp_reset]
[   29.860286] [drm:drm_ioctl] pid=1843, cmd=3D0x40086408, nr=3D0x08, dev
0xe200, auth=3D1
[   29.860296] [drm:drm_ioctl] pid=1843, cmd=3D0x40086408, nr=3D0x08, dev
0xe200, auth=3D1
[   30.252112] [drm:drm_ioctl] pid=1843, cmd=3D0x40086408, nr=3D0x08, dev
0xe200, auth=3D1
[   30.252125] [drm:drm_ioctl] pid=1843, cmd=3D0x40086408, nr=3D0x08, dev
0xe200, auth=3D1
[   30.268533] [drm:drm_ioctl] pid=1843, cmd=3D0x40086408, nr=3D0x08, dev
0xe200, auth=3D1
[   30.268539] [drm:drm_ioctl] pid=1843, cmd=3D0x40086408, nr=3D0x08, dev
0xe200, auth=3D1
<...>

I can see that drm version has changed, but that's all I can understand :-(

=C9meric
