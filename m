From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Date: Thu, 23 Aug 2007 09:34:36 +0000
Subject: Re: [BUG] 2.6.23-rc3-mm1 Kernel panic - not syncing: DMA: Memory
Message-Id: <46CD51DC.6030602@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <46CC48FD.4000607@linux.vnet.ibm.com> <20070822091959.aa38fd3e.akpm@linux-foundation.org> <20070822172541.GA8058@bingen.suse.de> <46CC811C.9010600@linux.vnet.ibm.com> <617E1C2C70743745A92448908E030B2A023B2D39@scsmsx411.amr.corp.intel.com> <46CCB79E.7070109@linux.vnet.ibm.com> <617E1C2C70743745A92448908E030B2A023B2F6A@scsmsx411.amr.corp.intel.com> <20070822231111.GD89849@sgi.com> <617E1C2C70743745A92448908E030B2A023B2FD5@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A023B2FD5@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Jeremy Higdon <jeremy@sgi.com>, Andi Kleen <ak@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-ia64@vger.kernel.org

Luck, Tony wrote:
>> The more ioc's you have, the more space you will use.
>>    =20
>
> Default SW IOTLB allocation is 64MB ... how much should we see
> used per ioc?
>
> Kamelesh: You could try increasing the amount of sw iotlb space
> available by booting with a swiotlb=131072 argument (argument
> value is the number of 2K slabs to allocate ... 131072 would
> give you four times as much space as the default allocation).
>
> -Tony
>  =20
boot log after passing boot parameter swiotlb=131072

[    0.000000]     0:    32768 ->   131072
[    0.000000]     0:   262144 ->  1703936
[    0.000000]     1:  4194304 ->  4980736
[    0.000000] Built 2 zonelists in Zone order, mobility grouping on. =20
Total pages: 1563903
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line:=20
BOOT_IMAGE=3Dscsi0:/EFI/debian/boot/vmlinuz-autobench root=3D/dev/sda2=20
console=3Dtty0 console=3DttyS0,115200n8 ro autobench_args: root=3D/dev/sda2=
=20
ABAT:1187857488 profile=3D2 swiotlb=131072
[    0.000000] kernel profiling enabled (shift: 2)
<<snip>>
[   20.408360] mptbase: Initiating ioc2 bringup
[   20.892659] ioc2: LSI53C1030 C0: Capabilities=3D{Initiator}
[   20.902432] DMA: Out of SW-IOMMU space for 263200 bytes at device ?
[   20.908992]
[   20.908993] Call Trace:
[   20.913324]  [<a0000001000144e0>] show_stack+0x80/0xa0
[   20.913327]                                 sp=E00000014322f8f0=20
bsp=E000000143229170
[   20.926764]  [<a000000100014530>] dump_stack+0x30/0x60
[   20.926766]                                 sp=E00000014322fac0=20
bsp=E000000143229158
[   20.940225]  [<a0000001003aaa50>] swiotlb_full+0x50/0x120
[   20.940227]                                 sp=E00000014322fac0=20
bsp=E000000143229120
[   20.953915]  [<a0000001003aac40>] swiotlb_map_single+0x120/0x1c0
[   20.953916]                                 sp=E00000014322fac0=20
bsp=E0000001432290d8
[   20.968223]  [<a0000001003ab630>] swiotlb_alloc_coherent+0x150/0x240
[   20.968226]                                 sp=E00000014322fac0=20
bsp=E000000143229090
[   20.982919]  [<a000000100550860>] PrimeIocFifos+0x4c0/0xb20
[   20.982922]                                 sp=E00000014322fac0=20
bsp=E000000143229010
[   20.996801]  [<a000000100556a80>] mpt_do_ioc_recovery+0xd60/0x28e0
[   20.996803]                                 sp=E00000014322faf0=20
bsp=E000000143228f30
[   21.011292]  [<a00000010055c8f0>] mpt_attach+0x830/0x20e0
[   21.011293]                                 sp=E00000014322fdc0=20
bsp=E000000143228eb0
[   21.025009]  [<a0000001005667b0>] mptspi_probe+0x30/0x720
[   21.025011]                                 sp=E00000014322fdd0=20
bsp=E000000143228e60
[   21.038722]  [<a0000001003bb4b0>] pci_device_probe+0x1f0/0x2c0
[   21.038724]                                 sp=E00000014322fdd0=20
bsp=E000000143228e18
[   21.052887]  [<a00000010048f9e0>] driver_probe_device+0x180/0x400
[   21.052888]                                 sp=E00000014322fdd0=20
bsp=E000000143228dc8
[   21.067276]  [<a00000010048ff20>] __driver_attach+0xc0/0x160
[   21.067277]                                 sp=E00000014322fdd0=20
bsp=E000000143228d90
[   21.081234]  [<a00000010048dd90>] bus_for_each_dev+0xb0/0x120
[   21.081236]                                 sp=E00000014322fdd0=20
bsp=E000000143228d58
[   21.095283]  [<a00000010048f640>] driver_attach+0x40/0x60
[   21.095285]                                 sp=E00000014322fdf0=20
bsp=E000000143228d38
[   21.108983]  [<a00000010048e600>] bus_add_driver+0x120/0x400
[   21.108985]                                 sp=E00000014322fdf0=20
bsp=E000000143228cf8
[   21.122942]  [<a0000001004903c0>] driver_register+0xc0/0x180
[   21.122943]                                 sp=E00000014322fdf0=20
bsp=E000000143228cd8
[   21.136906]  [<a0000001003bb980>] __pci_register_driver+0xc0/0x140
[   21.136908]                                 sp=E00000014322fdf0=20
bsp=E000000143228ca0
[   21.151422]  [<a000000100943920>] mptspi_init+0x180/0x1c0
[   21.151425]                                 sp=E00000014322fe00=20
bsp=E000000143228c70
[   21.166973]  [<a0000001008fc5d0>] kernel_init+0x350/0x840
[   21.166974]                                 sp=E00000014322fe00=20
bsp=E000000143228c10
[   21.180677]  [<a000000100012150>] kernel_thread_helper+0xd0/0x100
[   21.180679]                                 sp=E00000014322fe30=20
bsp=E000000143228be0
[   21.195082]  [<a000000100008dc0>] start_kernel_thread+0x20/0x40
[   21.195084]                                 sp=E00000014322fe30=20
bsp=E000000143228be0
[   21.209297] Kernel panic - not syncing: DMA: Memory would be corrupted

-
Kamalesh Babulal.
