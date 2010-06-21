From: =?ISO-8859-1?Q?=C9meric_Maschino?= <emeric.maschino@gmail.com>
Date: Mon, 21 Jun 2010 15:02:01 +0000
Subject: Kernel and/or KMS r300 initialization problem?
Message-Id: <AANLkTikHS13ma_AJmIyWoEB8PfDiPQ7zhOaPqxERRWg5@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hello,

Debian "Squeeze" Testing just switched from UMS to KMS r300
initialization on my system. As some may remember, DRI wasn't
available with UMS initialization due to a commit during the kernel
2.6.30 development cycle (all the story there:
http://marc.info/?l=3Dlinux-ia64&m=126382946814671&w=3D2). Now with KMS
initialization, glxinfo happily reports that DRI is enabled, but I
frankly doubt about this. Indeed, I'm recording some confusing
error/warning messages (e.g. [TTM] AGP Bind memory failed., [TTM]
Couldn't bind backend. and [drm] Forcing AGP to PCI mode) and a crash
in dmesg:

<snip>

[    1.592189] Linux agpgart interface v0.103
[    1.689791] agpgart: HP ZX1 IOC: IOPDIR shared with sba_iommu
[    1.690069]  <NULL>: AGP aperture is 512M @ 0x60000000
[    1.690709] agpgart: Detected HP ZX1 HWP0003 AGP chipset
(ioc=FEd01000, lba=FEd28000)

<snip>

[   12.316104] [drm] Initialized drm 1.1.0 20060810
[   12.820544] [drm] radeon kernel modesetting enabled.
[   12.820971] GSI 60 (level, low) -> CPU 1 (0x0100) vector 59
[   12.821007] radeon 0000:80:00.0: PCI INT A -> GSI 60 (level, low) -> IRQ=
 59
[   12.824501] [drm] radeon: Initializing kernel modesetting.
[   12.824644] [drm] register mmio base: 0xD8030000
[   12.824677] [drm] register mmio size: 65536
[   12.825683] [drm] GPU reset succeed (RBBM_STATUS=3D0x00000140)
[   12.825792] [drm] Generation 1 PCI interface in multifunction mode
[   12.825827] [drm] Limiting VRAM to one aperture
[   12.828018] radeon 0000:80:00.0: putting AGP V2 device into 2x mode
[   12.828333] [drm] radeon: VRAM 128M
[   12.828365] [drm] radeon: VRAM from 0x00000000 to 0x07FFFFFF
[   12.828399] [drm] radeon: GTT 512M
[   12.828430] [drm] radeon: GTT from 0x60000000 to 0x7FFFFFFF
[   12.828499] [drm] radeon: irq initialized.
[   12.828532] [drm] Detected VRAM RAM=128M, BAR=128M
[   12.828565] [drm] RAM width 256bits DDR
[   12.828663] [TTM] Zone  kernel: Available graphics memory: 3113968 kiB.
[   12.828698] [TTM] Zone   dma32: Available graphics memory: 2097152 kiB.
[   12.828758] [drm] radeon: 128M of VRAM memory ready
[   12.828791] [drm] radeon: 512M of GTT memory ready.
[   12.829076] [drm] radeon: 2 quad pipes, 1 Z pipes initialized.
[   12.829122] [drm] radeon: cp idle (0x10000C00)
[   12.829185] [drm] Loading R300 Microcode
[   12.829218] platform radeon_cp.0: firmware: requesting radeon/R300_cp.bin
[   13.110794] Architecture has no drm_cache.c support
[   13.110833] ------------[ cut here ]------------
[   13.110890] WARNING: at
/build/buildd-linux-2.6_2.6.32-15-ia64-Eoa90L/linux-2.6-2.6.32/debian/build=
/source_ia64_none/drivers/gpu/drm/drm_cache.c:96
drm_clflush_pages+0x70/0xc0 [drm]()
[   13.110958] Hardware name: workstation zx6000
[   13.110993] Modules linked in: snd_timer snd_hwdep snd_mpu401_uart
snd_rawmidi snd_seq_device radeon(+) ttm snd drm_kms_helper soundcore
drm i2c_algo_bit fm801_gp gameport i2c_core evdev tpm_tis tpm tpm_bios
ext4 mbcache jbd2 crc16 sd_mod crc_t10dif usbhid hid sg sr_mod cdrom
ata_generic mptspi mptscsih ohci_hcd tg3 pata_cmd64x ehci_hcd e100
mptbase scsi_transport_spi libphy libata mii usbcore nls_base scsi_mod
[last unloaded: scsi_wait_scan]
[   13.111923]
[   13.111924] Call Trace:
[   13.111990]  [<a000000100016370>] show_stack+0x50/0xa0
[   13.111992]                                 sp=E00000408211fbd0
bsp=E0000040821195a8
[   13.112080]  [<a000000100717c10>] dump_stack+0x30/0x50
[   13.112081]                                 sp=E00000408211fda0
bsp=E000004082119590
[   13.112167]  [<a0000001000a5000>] warn_slowpath_common+0xc0/0x120
[   13.112169]                                 sp=E00000408211fda0
bsp=E000004082119558
[   13.112252]  [<a0000001000a5090>] warn_slowpath_null+0x30/0x60
[   13.112254]                                 sp=E00000408211fda0
bsp=E000004082119530
[   13.112343]  [<a0000002027b6fd0>] drm_clflush_pages+0x70/0xc0 [drm]
[   13.112345]                                 sp=E00000408211fda0
bsp=E000004082119510
[   13.112435]  [<a00000020291e810>] ttm_tt_set_caching+0xb0/0x140 [ttm]
[   13.112436]                                 sp=E00000408211fda0
bsp=E0000040821194e8
[   13.112523]  [<a00000020291fb30>]
ttm_tt_set_placement_caching+0x50/0x80 [ttm]
[   13.112525]                                 sp=E00000408211fda0
bsp=E0000040821194c0
[   13.112621]  [<a000000202921eb0>] ttm_bo_handle_move_mem+0x2b0/0x7c0 [tt=
m]
[   13.112623]                                 sp=E00000408211fda0
bsp=E000004082119458
[   13.112711]  [<a000000202926340>] ttm_bo_move_buffer+0x1c0/0x2a0 [ttm]
[   13.112713]                                 sp=E00000408211fda0
bsp=E000004082119410
[   13.112800]  [<a000000202926720>] ttm_bo_validate+0x300/0x3c0 [ttm]
[   13.112802]                                 sp=E00000408211fdd0
bsp=E0000040821193c8
[   13.112889]  [<a000000202927100>] ttm_bo_init+0x920/0xc40 [ttm]
[   13.112890]                                 sp=E00000408211fdd0
bsp=E000004082119360
[   13.113052]  [<a000000202bbfec0>] radeon_bo_create+0x160/0x2c0 [radeon]
[   13.113054]                                 sp=E00000408211fde0
bsp=E0000040821192f8
[   13.113171]  [<a000000202be7990>] radeon_ring_init+0x70/0x3a0 [radeon]
[   13.113173]                                 sp=E00000408211fe00
bsp=E0000040821192c0
[   13.113288]  [<a000000202c03d50>] r100_cp_init+0xcf0/0x1640 [radeon]
[   13.113290]                                 sp=E00000408211fe00
bsp=E000004082119278
[   13.113405]  [<a000000202c16d20>] r300_startup+0x240/0x400 [radeon]
[   13.113407]                                 sp=E00000408211fe00
bsp=E000004082119250
[   13.113519]  [<a000000202c17900>] r300_init+0x520/0x6a0 [radeon]
[   13.113521]                                 sp=E00000408211fe00
bsp=E000004082119218
[   13.113630]  [<a000000202b944f0>] radeon_device_init+0x5f0/0x840 [radeon]
[   13.113632]                                 sp=E00000408211fe00
bsp=E0000040821191d0
[   13.113743]  [<a000000202b96410>] radeon_driver_load_kms+0x190/0x300 [ra=
deon]
[   13.113745]                                 sp=E00000408211fe00
bsp=E000004082119198
[   13.113837]  [<a0000002027c6220>] drm_get_dev+0x6a0/0x8e0 [drm]
[   13.113838]                                 sp=E00000408211fe00
bsp=E000004082119150
[   13.113949]  [<a000000202c8e020>] radeon_pci_probe+0x30/0x4b30 [radeon]
[   13.113951]                                 sp=E00000408211fe00
bsp=E000004082119128
[   13.114041]  [<a0000001003c8630>] local_pci_probe+0x70/0xa0
[   13.114043]                                 sp=E00000408211fe00
bsp=E000004082119108
[   13.114127]  [<a0000001003c8e90>] pci_device_probe+0x1d0/0x2a0
[   13.114129]                                 sp=E00000408211fe00
bsp=E0000040821190d8
[   13.114217]  [<a00000010051e870>] driver_probe_device+0x1b0/0x340
[   13.114218]                                 sp=E00000408211fe20
bsp=E0000040821190a0
[   13.114302]  [<a00000010051eae0>] __driver_attach+0xe0/0x140
[   13.114304]                                 sp=E00000408211fe20
bsp=E000004082119070
[   13.114388]  [<a00000010051d440>] bus_for_each_dev+0xa0/0x140
[   13.114390]                                 sp=E00000408211fe20
bsp=E000004082119038
[   13.114473]  [<a00000010051e460>] driver_attach+0x40/0x60
[   13.114475]                                 sp=E00000408211fe30
bsp=E000004082119018
[   13.114558]  [<a00000010051c300>] bus_add_driver+0x180/0x520
[   13.114559]                                 sp=E00000408211fe30
bsp=E000004082118fc8
[   13.114650]  [<a00000010051f2e0>] driver_register+0x260/0x400
[   13.114652]                                 sp=E00000408211fe30
bsp=E000004082118f80
[   13.114736]  [<a0000001003c9450>] __pci_register_driver+0x90/0x1a0
[   13.114738]                                 sp=E00000408211fe30
bsp=E000004082118f48
[   13.114827]  [<a0000002027b9ed0>] drm_init+0xd0/0x240 [drm]
[   13.114829]                                 sp=E00000408211fe30
bsp=E000004082118ee0
[   13.114939]  [<a000000202cd8220>] radeon_init+0x220/0x2a0 [radeon]
[   13.114941]                                 sp=E00000408211fe30
bsp=E000004082118ea8
[   13.115026]  [<a00000010000a960>] do_one_initcall+0xe0/0x360
[   13.115028]                                 sp=E00000408211fe30
bsp=E000004082118e68
[   13.115117]  [<a000000100108dc0>] sys_init_module+0x1e0/0x4c0
[   13.115118]                                 sp=E00000408211fe30
bsp=E000004082118de8
[   13.115204]  [<a00000010000c6c0>] ia64_ret_from_syscall+0x0/0x20
[   13.115206]                                 sp=E00000408211fe30
bsp=E000004082118de8
[   13.115291]  [<a000000000010720>] ia64_ivt+0xffffffff00010720/0x400
[   13.115293]                                 sp=E000004082120000
bsp=E000004082118de8
[   13.115372] ---[ end trace 78c133eca7d73457 ]---
[   13.115407] [TTM] AGP Bind memory failed.
[   13.115439] [TTM] Couldn't bind backend.
[   13.115500] radeon 0000:80:00.0: object_init failed for (1048576, 0x0000=
0002)
[   13.115536] radeon 0000:80:00.0: (-22) ring create failed
[   13.115571] radeon 0000:80:00.0: failled initializing CP (-22).
[   13.115606] radeon 0000:80:00.0: Disabling GPU acceleration
[   13.115643] [drm] radeon: cp finalized
[   13.115893] [drm] GPU reset succeed (RBBM_STATUS=3D0x00000140)
[   13.115929] [drm] radeon: cp finalized
[   13.116010] [TTM] Zone  kernel: Used memory at exit: 0 kiB.
[   13.116048] [TTM] Zone   dma32: Used memory at exit: 0 kiB.
[   13.116084] [drm] radeon: ttm finalized
[   13.116117] [drm] Forcing AGP to PCI mode
[   13.117120] [drm] GPU reset succeed (RBBM_STATUS=3D0x00000140)
[   13.117224] [drm] Generation 1 PCI interface in multifunction mode
[   13.117259] [drm] Limiting VRAM to one aperture
[   13.117293] [drm] radeon: VRAM 128M
[   13.117324] [drm] radeon: VRAM from 0x00000000 to 0x07FFFFFF
[   13.117965] [drm] radeon: GTT 512M
[   13.117996] [drm] radeon: GTT from 0x20000000 to 0x3FFFFFFF
[   13.118045] [drm] radeon: irq initialized.
[   13.118091] [drm] Detected VRAM RAM=128M, BAR=128M
[   13.118124] [drm] RAM width 256bits DDR
[   13.118385] [TTM] Zone  kernel: Available graphics memory: 3113968 kiB.
[   13.118421] [TTM] Zone   dma32: Available graphics memory: 2097152 kiB.
[   13.118468] [drm] radeon: 128M of VRAM memory ready
[   13.119150] [drm] radeon: 512M of GTT memory ready.
[   13.119185] [drm] GART: num cpu pages 32768, num gpu pages 131072
[   13.119946] [drm] radeon: 2 quad pipes, 1 Z pipes initialized.
[   13.119986] [drm] radeon: cp idle (0x10000C00)
[   13.120133] [drm] radeon: ring at 0x0000000020000000
[   13.120196] [drm] ring test succeeded in 1 usecs
[   13.120294] [drm] radeon: ib pool ready.
[   13.120435] [drm] ib test succeeded in 0 usecs
[   13.120503] [drm] DFP table revision: 4
[   13.120800] [drm] No TV DAC info found in BIOS
[   13.120836] [drm] External TMDS Table revision: 2
[   13.121126] [drm] Radeon Display Connectors
[   13.121158] [drm] Connector 0:
[   13.121189] [drm]   DVI-I
[   13.121219] [drm]   HPD1
[   13.121250] [drm]   DDC: 0x60 0x60 0x60 0x60 0x60 0x60 0x60 0x60
[   13.121285] [drm]   Encoders:
[   13.121316] [drm]     CRT1: INTERNAL_DAC1
[   13.121348] [drm]     DFP1: INTERNAL_TMDS1
[   13.121380] [drm] Connector 1:
[   13.121410] [drm]   DVI-I
[   13.121440] [drm]   HPD2
[   13.121471] [drm]   DDC: 0x64 0x64 0x64 0x64 0x64 0x64 0x64 0x64
[   13.121505] [drm]   Encoders:
[   13.121536] [drm]     CRT2: INTERNAL_DAC2
[   13.121568] [drm]     DFP2: INTERNAL_DVO1
[   13.198981] Linux video capture interface: v2.00
[   13.390968] GSI 38 (level, low) -> CPU 0 (0x0000) vector 60
[   13.391065] FM801 0000:40:01.0: PCI INT A -> GSI 38 (level, low) -> IRQ =
60
[   13.997998] [drm] fb mappable at 0xD0040000
[   13.998032] [drm] vram apper at 0xD0000000
[   13.998064] [drm] size 7680000
[   13.998095] [drm] fb depth is 24
[   13.998125] [drm]    pitch is 6400
[   14.238227] Console: switching to colour frame buffer device 200x75
[   14.427460] fb0: radeondrmfb frame buffer device
[   14.427463] registered panic notifier
[   14.427472] [drm] Initialized radeon 2.0.0 20080528 for
0000:80:00.0 on minor 0

This is with current Debian "Squeeze" Testing kernel 2.6.32, but I'm
getting similar results with a freshly recompiled 2.6.34 kernel.

First, is this kernel related (in short, am I in the right mailing-list)?

Then, if kernel related, it's noteworthy that the hp_agp.ko module is
no more loaded into memory (although it's still listed in /etc/modules
and from the dmesg log above, agpgart seems to correctly identify HP
ZX1 HWP0003 AGP chipset), whereas UMS was loading it. Is this
expected?

Regards,

     Emeric
