From: Frank Scheiner <frank.scheiner@web.de>
Date: Tue, 25 Jun 2019 15:52:34 +0000
Subject: Re: Regression in 543cea9a - was: Re: Kernel problem on rx2800 i2
Message-Id: <80470803-d475-815a-c95a-f9961fde5d97@web.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1d62aadd-67b6-da13-53cc-4b5213de8937@physik.fu-berlin.de>
In-Reply-To: <1d62aadd-67b6-da13-53cc-4b5213de8937@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



On 6/25/19 16:40, Christoph Hellwig wrote:
> Please try this patch instead of the previous one:
>
> diff --git a/kernel/dma/direct.c b/kernel/dma/direct.c
> index 2c2772e9702a..3516a543450e 100644
> --- a/kernel/dma/direct.c
> +++ b/kernel/dma/direct.c
> @@ -118,9 +118,10 @@ struct page *__dma_direct_alloc_pages(struct device *dev, size_t size,
>   			page = NULL;
>   		}
>   	}
> -	if (!page)
> -		page = alloc_pages_node(dev_to_node(dev), gfp, page_order);
> -
> +	if (!page) {
> +		page = alloc_pages_node(local_memory_node(dev_to_node(dev)),
> +					gfp, page_order);
> +	}
>   	if (page && !dma_coherent_ok(dev, page_to_phys(page), size)) {
>   		__free_pages(page, page_order);
>   		page = NULL;
>

Took me a while as I lost two tries, because of two problems after which
the machine was no longer responsible, once during recompilation of the
changed files and once during installation of kernel modules.

This is what I saw, not sure if it is related to the changes or the
newer kernel version, but I can't remember seeing such messages before:

```
## 1st problem:

BUG: Bad page state in process kworker/u33:1  pfn:36304b
bad because of flags: 0x800(arch_1)

## 2nd problem:

BUG: Bad page state in process kworker/u32:5  pfn:3630f7
bad because of flags: 0x800(arch_1)
```

Using the v4.19.37 with the reverts mentioned in the initial mail I was
able to create the new kernel, install the kernel modules and build the
initramfs.

Using the third patch the resulting kernel sadly panics again:
```
Linux version 5.1.15-dirty (root@rx2800-i2) (gcc version 7.3.0 (Gentoo
7.3.0-r3 p1.4)) #3 SMP Tue Jun 25 17:41:55 CEST 2019
EFI v2.10 by HP:
efi:  SALsystab=0xdfdd63a18  ACPI 2.0=0x3d3c4014  HCDP=0xdffff8798
SMBIOS=0x3d368000
booting generic kernel on platform dig
PCDP: v3 at 0xdffff8798
earlycon: uart8250 at I/O port 0x4000 (options '115200n8')
printk: bootconsole [uart8250] enabled
ACPI: Early table checksum verification disabled
ACPI: RSDP 0x000000003D3C4014 000024 (v02 HP    )
ACPI: XSDT 0x000000003D3C4580 000124 (v01 HP     RX2800-2 00000001
01000013)
[...]
Trying to unpack rootfs image as initramfs...
[...]
Detecting Adaptec I2O RAID controllers...
ahci 0000:00:1f.2: AHCI 0001.0200 32 slots 6 ports 3 Gbps 0x3f impl SATA
mode
ahci 0000:00:1f.2: flags: 64bit ncq sntf pm led clo pio slum part ccc ems
Unable to handle kernel NULL pointer dereference (address 0000000000001688)
swapper/0[1]: Oops 11012296146944 [1]
Modules linked in:

CPU: 0 PID: 1 Comm: swapper/0 Not tainted 5.1.15-dirty #3
Hardware name: hp Integrity rx2800 i2, BIOS 01.93 09/12/2012
psr : 00001210084a6010 ifs : 8000000000000207 ip  : [<a00000010017e591>]
    Not tainted (5.1.15-dirty)
ip is at local_memory_node+0x51/0xd0
unat: 0000000000000000 pfs : 0000000000000814 rsc : 0000000000000003
rnat: 4905ad66a46b1a31 bsps: 6330dc59462bf692 pr  : 000000000001aa55
ldrs: 0000000000000000 ccv : 000000038df5dd8b fpsr: 0009804c8a70433f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a00000010010ea70 b6  : a00000010003a740 b7  : a0000001007fe9b0
f6  : 1003e00000000000164ff f7  : 1000fb27f800000000000
f8  : 1003e0000000000003480 f9  : 1003e000000000000000f
f10 : 1003e0000000000000400 f11 : 1003e0000000000003c00
r1  : a0000001015a9e80 r2  : e000000001519980 r3  : e000000001519988
r8  : 0000000000000008 r9  : e000000001519990 r10 : 0000000000000000
r11 : 0000000000001688 r12 : e000000d8339fd50 r13 : e000000d83398000
r14 : fffffffffffc04b8 r15 : 0000000000000000 r16 : ffffffffffffffff
r17 : ffffffffffffffff r18 : 0000000000ffffff r19 : e000000d80010180
r20 : fffffffffffd01b0 r21 : 0000000000000010 r22 : e0000000011101b0
r23 : 0000000000000001 r24 : e0000000011101bc r25 : 0000000000000001
r26 : 000000000000006c r27 : e000000d846679d0 r28 : e000000d846679c0
r29 : 0000000000000370 r30 : 0000000000000000 r31 : 0000000000000081

Call Trace:
  [<a000000100013820>] show_stack+0x40/0x90
                                 sp=e000000d8339f9a0 bsp=e000000d83399750
  [<a0000001000141a0>] show_regs+0x930/0x940
                                 sp=e000000d8339fb70 bsp=e000000d833996e0
  [<a0000001000245e0>] die+0x1a0/0x2f0
                                 sp=e000000d8339fb70 bsp=e000000d833996a0
  [<a00000010004bab0>] ia64_do_page_fault+0x7e0/0x9e0
                                 sp=e000000d8339fb70 bsp=e000000d83399610
  [<a00000010000c580>] ia64_leave_kernel+0x0/0x270
                                 sp=e000000d8339fb80 bsp=e000000d83399610
  [<a00000010017e590>] local_memory_node+0x50/0xd0
                                 sp=e000000d8339fd50 bsp=e000000d833995d0
  [<a00000010010ea70>] __dma_direct_alloc_pages+0x150/0x340
                                 sp=e000000d8339fd50 bsp=e000000d83399550
  [<a00000010010ec90>] dma_direct_alloc_pages+0x30/0x170
                                 sp=e000000d8339fd50 bsp=e000000d83399510
  [<a00000010003a790>] arch_dma_alloc+0x30/0x50
                                 sp=e000000d8339fd50 bsp=e000000d833994d0
  [<a00000010010ef30>] dma_direct_alloc+0x60/0xa0
                                 sp=e000000d8339fd50 bsp=e000000d83399490
  [<a00000010010c570>] dma_alloc_attrs+0x150/0x1e0
                                 sp=e000000d8339fd50 bsp=e000000d83399440
  [<a00000010010c670>] dmam_alloc_attrs+0x70/0x100
                                 sp=e000000d8339fd50 bsp=e000000d833993e8
  [<a0000001009a9bb0>] ahci_port_start+0x2e0/0x4a0
                                 sp=e000000d8339fd50 bsp=e000000d833993a0
  [<a000000100969480>] ata_host_start+0x300/0x460
                                 sp=e000000d8339fd60 bsp=e000000d83399340
  [<a0000001009758c0>] ata_host_activate+0x20/0x280
                                 sp=e000000d8339fd60 bsp=e000000d833992e0
  [<a0000001009aa090>] ahci_host_activate+0x320/0x330
                                 sp=e000000d8339fd60 bsp=e000000d83399270
  [<a0000001009a3430>] ahci_init_one+0x1a70/0x1e10
                                 sp=e000000d8339fd60 bsp=e000000d833991b8
  [<a0000001006df4d0>] local_pci_probe+0x90/0x140
                                 sp=e000000d8339fdc0 bsp=e000000d83399178
  [<a0000001006e09f0>] pci_device_probe+0x2f0/0x310
                                 sp=e000000d8339fdc0 bsp=e000000d83399140
  [<a00000010083a3a0>] really_probe+0x4a0/0x6b0
                                 sp=e000000d8339fde0 bsp=e000000d833990d8
  [<a00000010083aa60>] driver_probe_device+0x1e0/0x1f0
                                 sp=e000000d8339fde0 bsp=e000000d833990a0
  [<a00000010083af00>] device_driver_attach+0xb0/0x100
                                 sp=e000000d8339fde0 bsp=e000000d83399070
  [<a00000010083b130>] __driver_attach+0x1e0/0x1f0
                                 sp=e000000d8339fde0 bsp=e000000d83399040
  [<a0000001008363f0>] bus_for_each_dev+0xd0/0x130
                                 sp=e000000d8339fde0 bsp=e000000d83399000
  [<a0000001008394b0>] driver_attach+0x40/0x60
                                 sp=e000000d8339fdf0 bsp=e000000d83398fd8
  [<a000000100838880>] bus_add_driver+0x3b0/0x450
                                 sp=e000000d8339fdf0 bsp=e000000d83398f88
  [<a00000010083c090>] driver_register+0x220/0x2b0
                                 sp=e000000d8339fdf0 bsp=e000000d83398f60
  [<a0000001006deb50>] __pci_register_driver+0xa0/0xc0
                                 sp=e000000d8339fdf0 bsp=e000000d83398f30
  [<a0000001011442d0>] ahci_pci_driver_init+0x50/0x70
                                 sp=e000000d8339fdf0 bsp=e000000d83398f18
  [<a00000010000a7d0>] do_one_initcall+0x100/0x2c0
                                 sp=e000000d8339fdf0 bsp=e000000d83398ee0
  [<a0000001010f9cc0>] kernel_init_freeable+0x410/0x470
                                 sp=e000000d8339fe30 bsp=e000000d83398e78
  [<a000000100ddd680>] kernel_init+0x20/0x280
                                 sp=e000000d8339fe30 bsp=e000000d83398e58
  [<a00000010000c370>] call_payload+0x50/0x80
                                 sp=e000000d8339fe30 bsp=e000000d83398e40
Disabling lock debugging due to kernel taint
Kernel panic - not syncing: Attempted to kill init! exitcode=0x0000000b
---[ end Kernel panic - not syncing: Attempted to kill init!
exitcode=0x0000000b ]---
```

gdb shows the same like the last time for the "new" faulting address:

```
# gdb ./vmlinux
[...]
(gdb) l *(local_memory_node+0x51)
0xa00000010017e591 is in local_memory_node (./include/linux/mmzone.h:993).
988	 */
989	static __always_inline struct zoneref *next_zones_zonelist(struct
zoneref *z,
990						enum zone_type highest_zoneidx,
991						nodemask_t *nodes)
992	{
993		if (likely(!nodes && zonelist_zone_idx(z) <= highest_zoneidx))
994			return z;
995		return __next_zones_zonelist(z, highest_zoneidx, nodes);
996	}
997
```

Cheers,
Frank
