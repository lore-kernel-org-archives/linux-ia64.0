From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Wed, 05 Aug 2020 21:27:51 +0000
Subject: Re: Regression in 543cea9a - was: Re: Kernel problem on rx2800 i2
Message-Id: <771032ae-76dc-a2c3-2e1f-9904b09720f3@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1d62aadd-67b6-da13-53cc-4b5213de8937@physik.fu-berlin.de>
In-Reply-To: <1d62aadd-67b6-da13-53cc-4b5213de8937@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On 8/5/20 10:27 PM, Jessica Clarke wrote:
> My guess is dev_to_node gave NUMA_NO_NODE for a random PCI device. Try:
>=20
>     int nid =3D dev_to_node(dev);
>     if (nid >=3D 0)
>         nid =3D local_memory_node(nid);
>=20
> and then pass nid to alloc_pages_node instead.

I tried:

diff --git a/kernel/dma/direct.c b/kernel/dma/direct.c
index 1d2f147f737d..3efa759bbb3e 100644
--- a/kernel/dma/direct.c
+++ b/kernel/dma/direct.c
@@ -85,8 +85,13 @@ void *dma_direct_alloc(struct device *dev, size_t size, =
dma_addr_t *dma_handle,
                        page =3D NULL;
                }
        }
+
+       int nid =3D dev_to_node(dev);
+       if (nid >=3D 0)
+               nid =3D local_memory_node(nid);
+
        if (!page)
-               page =3D alloc_pages_node(dev_to_node(dev), gfp, page_order=
);
+               page =3D alloc_pages_node(nid, gfp, page_order);
=20
        if (page && !dma_coherent_ok(dev, page_to_phys(page), size)) {
                __free_pages(page, page_order);
root@lenz:/usr/src/linux-stable#

with the same result. That's on 4.19.137. Can try a newer kernel tomorrow.

[    2.319109] Detecting Adaptec I2O RAID controllers...                   =
                                                                           =
                     =20
[    2.351357] HP HPSA Driver (v 3.4.20-125)                               =
                                                                           =
                     =20
[    2.392710] hpsa 0000:02:00.0: Logical aborts not supported             =
                                                                           =
                     =20
[    2.427375] hpsa 0000:02:00.0: HP SSD Smart Path aborts not supported   =
                                                                           =
                     =20
[    2.492710] Unable to handle kernel NULL pointer dereference (address 00=
00000000001688)                                                            =
                     =20
[    2.543228] swapper/0[1]: Oops 11012296146944 [1]                       =
                                                                           =
                     =20
[    2.543228] Modules linked in:                                          =
                                                                           =
                     =20
[    2.543228]                                                             =
                                                                           =
                     =20
[    2.543228] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.19.137-dirty #8 =
                                                                           =
                     =20
[    2.543228] Hardware name: hp Integrity BL870c i4 nPar, BIOS 02.64 03/03=
/2016                                                                      =
                     =20
[    2.543228] psr : 00001210084a6010 ifs : 8000000000000207 ip  : [<a00000=
010019acf1>]    Not tainted (4.19.137-dirty)                               =
                     =20
[    2.543228] ip is at local_memory_node+0x51/0xd0                        =
                                                                           =
                     =20
[    2.543228] unat: 0000000000000000 pfs : 0000000000000793 rsc : 00000000=
00000003                                                                   =
                     =20
[    2.543228] rnat: c00000005805cc60 bsps: 0000000000000000 pr  : a6a6aa95=
6aaa9959                                                                   =
                     =20
[    2.543228] ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c=
8a70433f                                                                   =
                     =20
[    2.543228] csd : 0000000000000000 ssd : 0000000000000000               =
                                                                           =
                     =20
[    2.543228] b0  : a00000010011aad0 b6  : a00000010011c8a0 b7  : a0000001=
0003a5e0                                                                   =
                     =20
[    2.543228] f6  : 10012bffff00000000000 f7  : 1003e00000000000bffff     =
                                                                           =
                     =20
[    2.543228] f8  : 1003e0000000000003f00 f9  : 1003e0000000000000054     =
                                                                           =
                     =20
[    2.543228] f10 : 1003e00000000000000c0 f11 : 1003e0000000000003f00     =
                                                                           =
                     =20
[    2.543228] r1  : a0000001013dd060 r2  : e000000001919980 r3  : e0000000=
01919988                                                                   =
                     =20
[    2.543228] r8  : 0000000000000008 r9  : e000000001919990 r10 : 00000000=
00000000                                                                   =
                     =20
[    2.543228] r11 : 0000000000001688 r12 : e000000f8363fcc0 r13 : e000000f=
83638000                                                                   =
                     =20
[    2.543228] r14 : fffffffffffc04b8 r15 : 00000000ffffffff r16 : 00000000=
00ffffff                                                                   =
                     =20
[    2.543228] r17 : 0000000000000000 r18 : 0000000000000000 r19 : 00000000=
00000000                                                                   =
                     =20
[    2.543228] r20 : fffffffffffcdd50 r21 : 0000000000000010 r22 : e0000000=
0110dd50                                                                   =
                     =20
[    2.543228] r23 : 0000000000000003 r24 : 0000000000480220 r25 : 00000000=
00000028                                                                   =
                     =20
[    2.543228] r26 : 0000000000000800 r27 : 0000000000000c00 r28 : a0000001=
00f1f0e8                                                                   =
                     =20
[    2.543228] r29 : a00000010003a5e0 r30 : a00000010011c8a0 r31 : 00000000=
00000081                                                                   =
                     =20
[    2.543228]                                                             =
                                                                           =
                     =20
[    2.543228] Call Trace:                                                 =
                                                                           =
                     =20
[    2.543228]  [<a000000100013570>] show_stack+0x40/0x90                  =
                                                                           =
                     =20
[    2.543228]                                 sp=E000000f8363f870 bsp=E000=
000f83639838                                                               =
                     =20
[    2.543228]  [<a000000100013f80>] show_regs+0x9c0/0x9f0                 =
                                                                           =
                     =20
[    2.543228]                                 sp=E000000f8363fa40 bsp=E000=
000f836397d0                                                               =
                     =20
[    3.747675] random: crng init done                                      =
                                                                           =
                     =20
[    2.543228]  [<a000000100024530>] die+0x1a0/0x2f0                       =
                                                                           =
                     =20
[    2.543228]                                 sp=E000000f8363fa60 bsp=E000=
000f83639790                                                               =
                     =20
[    2.543228]  [<a00000010004bb80>] ia64_do_page_fault+0x830/0x9d0        =
                                                                           =
                     =20
[    2.543228]                                 sp=E000000f8363fa60 bsp=E000=
000f836396f8                                                               =
                     =20
[    2.543228]  [<a00000010000c460>] ia64_leave_kernel+0x0/0x270           =
                                                                           =
                     =20
[    2.543228]                                 sp=E000000f8363faf0 bsp=E000=
000f836396f8                                                               =
                     =20
[    2.543228]  [<a00000010019acf0>] local_memory_node+0x50/0xd0           =
                                                                           =
                     =20
[    2.543228]                                 sp=E000000f8363fcc0 bsp=E000=
000f836396c0                                                               =
                     =20
[    2.543228]  [<a00000010011aad0>] dma_direct_alloc+0x130/0x2b0          =
                                                                           =
                     =20
[    2.543228]                                 sp=E000000f8363fcc0 bsp=E000=
000f83639648
[    2.543228]  [<a00000010011c8f0>] swiotlb_alloc+0x50/0x2a0
[    2.543228]                                 sp=E000000f8363fcc0 bsp=E000=
000f836395e8
[    2.543228]  [<a0000001007b4580>] hpsa_init_one+0x25f0/0x4670
[    2.543228]                                 sp=E000000f8363fcc0 bsp=E000=
000f83639320
[    2.543228]  [<a00000010056f720>] local_pci_probe+0x90/0x150
[    2.543228]                                 sp=E000000f8363fd40 bsp=E000=
000f836392e0
[    2.543228]  [<a000000100570df0>] pci_device_probe+0x300/0x320
[    2.543228]                                 sp=E000000f8363fd40 bsp=E000=
000f836392a8
[    2.543228]  [<a0000001006c7aa0>] really_probe+0x480/0x680
[    2.543228]                                 sp=E000000f8363fd60 bsp=E000=
000f83639240
[    2.543228]  [<a0000001006c8160>] driver_probe_device+0x1e0/0x1f0
[    2.543228]                                 sp=E000000f8363fd60 bsp=E000=
000f83639208
[    2.543228]  [<a0000001006c8300>] __driver_attach+0x190/0x230
[    2.543228]                                 sp=E000000f8363fd60 bsp=E000=
000f836391d0
[    2.543228]  [<a0000001006c3980>] bus_for_each_dev+0xd0/0x130
[    2.543228]                                 sp=E000000f8363fd60 bsp=E000=
000f83639190
[    2.543228]  [<a0000001006c6bd0>] driver_attach+0x40/0x60
[    2.543228]                                 sp=E000000f8363fd70 bsp=E000=
000f83639170
[    2.543228]  [<a0000001006c60d0>] bus_add_driver+0x400/0x4a0
[    2.543228]                                 sp=E000000f8363fd70 bsp=E000=
000f83639120
[    2.543228]  [<a0000001006c9630>] driver_register+0x220/0x2b0
[    2.543228]                                 sp=E000000f8363fd70 bsp=E000=
000f836390f8
[    2.543228]  [<a00000010056efb0>] __pci_register_driver+0xa0/0xc0
[    2.543228]                                 sp=E000000f8363fd70 bsp=E000=
000f836390c8
[    2.543228]  [<a000000100f930b0>] hpsa_init+0x80/0xc0
[    2.543228]                                 sp=E000000f8363fd70 bsp=E000=
000f836390a0
[    2.543228]  [<a00000010000a6a0>] do_one_initcall+0x100/0x2d0
[    2.543228]                                 sp=E000000f8363fd70 bsp=E000=
000f83639068
[    2.543228]  [<a000000100f49c60>] kernel_init_freeable+0x5c0/0x5d0
[    2.543228]                                 sp=E000000f8363fdb0 bsp=E000=
000f83639000
[    2.543228]  [<a000000100c6a8c0>] kernel_init+0x20/0x280
[    2.543228]                                 sp=E000000f8363fe30 bsp=E000=
000f83638fd8
[    2.543228]  [<a00000010000c250>] call_payload+0x50/0x80
[    2.543228]                                 sp=E000000f8363fe30 bsp=E000=
000f83638fc0
[    2.543228] Disabling lock debugging due to kernel taint
[    5.750115] Kernel panic - not syncing: Attempted to kill init! exitcode=
=3D0x0000000b
[    5.750115]=20
[    5.750115] ---[ end Kernel panic - not syncing: Attempted to kill init!=
 exitcode=3D0x0000000b
[    5.750115]  ]---

--=20
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
