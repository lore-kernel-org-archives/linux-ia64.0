From: Frank Scheiner <frank.scheiner@web.de>
Date: Tue, 25 Jun 2019 08:16:22 +0000
Subject: Re: Regression in 543cea9a - was: Re: Kernel problem on rx2800 i2
Message-Id: <cce09bfe-0179-4ce7-4488-09c66b968628@web.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1d62aadd-67b6-da13-53cc-4b5213de8937@physik.fu-berlin.de>
In-Reply-To: <1d62aadd-67b6-da13-53cc-4b5213de8937@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: linux-ia64@vger.kernel.org

On 6/25/19 09:26, Frank Scheiner wrote:
> On 6/25/19 08:59, Christoph Hellwig wrote:
>> On Tue, Jun 25, 2019 at 08:54:11AM +0200, John Paul Adrian Glaubitz
>> wrote:
>>> Okay, thanks. I'll whip up a patch for Frank to test.
>>
>> The one below should do it, but from looking at the ia64 zone
>> initialization I'm not sure this will be the culprit.
>>
>> diff --git a/kernel/dma/direct.c b/kernel/dma/direct.c
>> index 2c2772e9702a..3e802f4580b3 100644
>> --- a/kernel/dma/direct.c
>> +++ b/kernel/dma/direct.c
>> @@ -82,9 +82,7 @@ static gfp_t __dma_direct_optimal_gfp_mask(struct
>> device *dev, u64 dma_mask,
>>        */
>>       if (*phys_mask <= DMA_BIT_MASK(ARCH_ZONE_DMA_BITS))
>>           return GFP_DMA;
>> -    if (*phys_mask <= DMA_BIT_MASK(32))
>> -        return GFP_DMA32;
>> -    return 0;
>> +    return GFP_DMA32;
>>   }
>>   static bool dma_coherent_ok(struct device *dev, phys_addr_t phys,
>> size_t size)
>>
>
> Ok, will apply that to the most recent non-rc kernel source and give it
> a try. Should take about 45 mins or so.

Looks like this patch is not enough or not related, a kernel v5.1.15
with that patch applied yields the following:

```
Linux version 5.1.15-dirty (root@rx2800-i2) (gcc version 7.3.0 (Gentoo
7.3.0-r3 p1.4)) #1 SMP Tue Jun 25 09:59:06 CEST 2019
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

CPU: 0 PID: 1 Comm: swapper/0 Not tainted 5.1.15-dirty #1
Hardware name: hp Integrity rx2800 i2, BIOS 01.93 09/12/2012
psr : 00001210084a6010 ifs : 8000000000001734 ip  : [<a00000010017b901>]
    Not tainted (5.1.15-dirty)
ip is at __alloc_pages_nodemask+0x281/0x17a0
unat: 0000000000000000 pfs : 0000000000001734 rsc : 0000000000000003
rnat: 00000003d8598c41 bsps: 000000000001003e pr  : 0000000000011269
ldrs: 0000000000000000 ccv : 000000038d5f0ad4 fpsr: 0009804c8a70433f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a00000010017b8c0 b6  : a00000010003a740 b7  : a0000001007fe990
f6  : 1003e0000000000000000 f7  : 1000fb27f800000000000
f8  : 1003e0000000000003480 f9  : 1003e000000000000000f
f10 : 1003e0000000000000400 f11 : 1003e0000000000003c00
r1  : a0000001015a9e80 r2  : a000000101339e94 r3  : 00000000007fffff
r8  : 0000000000001680 r9  : 0000000000002500 r10 : fffffffffffc04b8
r11 : e000000001519980 r12 : e000000d8339fce0 r13 : e000000d83398000
r14 : ffffffffffd90014 r15 : 0000000000000001 r16 : 0000000000000008
r17 : e000000001519990 r18 : 0000000000001680 r19 : 0000000000000000
r20 : 0000000000000000 r21 : 0000000000000000 r22 : 0000000000000000
r23 : 0000000000000000 r24 : ffffffffffd90000 r25 : a000000101339e80
r26 : 0000000000000000 r27 : 0000000000000000 r28 : 0000000000000000
r29 : 0000000000001688 r30 : 0000000000000000 r31 : 0000000000000081

Call Trace:
  [<a000000100013820>] show_stack+0x40/0x90
                                 sp=e000000d8339f930 bsp=e000000d833998c0
  [<a0000001000141a0>] show_regs+0x930/0x940
                                 sp=e000000d8339fb00 bsp=e000000d83399850
  [<a0000001000245e0>] die+0x1a0/0x2f0
                                 sp=e000000d8339fb00 bsp=e000000d83399810
  [<a00000010004bab0>] ia64_do_page_fault+0x7e0/0x9e0
                                 sp=e000000d8339fb00 bsp=e000000d83399778
  [<a00000010000c580>] ia64_leave_kernel+0x0/0x270
                                 sp=e000000d8339fb10 bsp=e000000d83399778
  [<a00000010017b900>] __alloc_pages_nodemask+0x280/0x17a0
                                 sp=e000000d8339fce0 bsp=e000000d833995d0
  [<a00000010010eab0>] __dma_direct_alloc_pages+0x190/0x320
                                 sp=e000000d8339fd50 bsp=e000000d83399550
  [<a00000010010ec70>] dma_direct_alloc_pages+0x30/0x170
                                 sp=e000000d8339fd50 bsp=e000000d83399510
  [<a00000010003a790>] arch_dma_alloc+0x30/0x50
                                 sp=e000000d8339fd50 bsp=e000000d833994d0
  [<a00000010010ef10>] dma_direct_alloc+0x60/0xa0
                                 sp=e000000d8339fd50 bsp=e000000d83399490
  [<a00000010010c570>] dma_alloc_attrs+0x150/0x1e0
                                 sp=e000000d8339fd50 bsp=e000000d83399440
  [<a00000010010c670>] dmam_alloc_attrs+0x70/0x100
                                 sp=e000000d8339fd50 bsp=e000000d833993e8
  [<a0000001009a9b90>] ahci_port_start+0x2e0/0x4a0
                                 sp=e000000d8339fd50 bsp=e000000d833993a0
  [<a000000100969460>] ata_host_start+0x300/0x460
                                 sp=e000000d8339fd60 bsp=e000000d83399340
  [<a0000001009758a0>] ata_host_activate+0x20/0x280
                                 sp=e000000d8339fd60 bsp=e000000d833992e0
  [<a0000001009aa070>] ahci_host_activate+0x320/0x330
                                 sp=e000000d8339fd60 bsp=e000000d83399270
  [<a0000001009a3410>] ahci_init_one+0x1a70/0x1e10
                                 sp=e000000d8339fd60 bsp=e000000d833991b8
  [<a0000001006df4b0>] local_pci_probe+0x90/0x140
                                 sp=e000000d8339fdc0 bsp=e000000d83399178
  [<a0000001006e09d0>] pci_device_probe+0x2f0/0x310
                                 sp=e000000d8339fdc0 bsp=e000000d83399140
  [<a00000010083a380>] really_probe+0x4a0/0x6b0
                                 sp=e000000d8339fde0 bsp=e000000d833990d8
  [<a00000010083aa40>] driver_probe_device+0x1e0/0x1f0
                                 sp=e000000d8339fde0 bsp=e000000d833990a0
  [<a00000010083aee0>] device_driver_attach+0xb0/0x100
                                 sp=e000000d8339fde0 bsp=e000000d83399070
  [<a00000010083b110>] __driver_attach+0x1e0/0x1f0
                                 sp=e000000d8339fde0 bsp=e000000d83399040
  [<a0000001008363d0>] bus_for_each_dev+0xd0/0x130
                                 sp=e000000d8339fde0 bsp=e000000d83399000
  [<a000000100839490>] driver_attach+0x40/0x60
                                 sp=e000000d8339fdf0 bsp=e000000d83398fd8
  [<a000000100838860>] bus_add_driver+0x3b0/0x450
                                 sp=e000000d8339fdf0 bsp=e000000d83398f88
  [<a00000010083c070>] driver_register+0x220/0x2b0
                                 sp=e000000d8339fdf0 bsp=e000000d83398f60
  [<a0000001006deb30>] __pci_register_driver+0xa0/0xc0
                                 sp=e000000d8339fdf0 bsp=e000000d83398f30
  [<a0000001011442d0>] ahci_pci_driver_init+0x50/0x70
                                 sp=e000000d8339fdf0 bsp=e000000d83398f18
  [<a00000010000a7d0>] do_one_initcall+0x100/0x2c0
                                 sp=e000000d8339fdf0 bsp=e000000d83398ee0
  [<a0000001010f9cc0>] kernel_init_freeable+0x410/0x470
                                 sp=e000000d8339fe30 bsp=e000000d83398e78
  [<a000000100ddd660>] kernel_init+0x20/0x280
                                 sp=e000000d8339fe30 bsp=e000000d83398e58
  [<a00000010000c370>] call_payload+0x50/0x80
                                 sp=e000000d8339fe30 bsp=e000000d83398e40
Disabling lock debugging due to kernel taint
Kernel panic - not syncing: Attempted to kill init! exitcode=0x0000000b
---[ end Kernel panic - not syncing: Attempted to kill init!
exitcode=0x0000000b ]---
```

During compilation I noticed the following messages:

```
[...]
   CC      arch/ia64/kernel/dma-mapping.o
In file included from ./include/linux/cpumask.h:12:0,
                  from ./include/linux/rcupdate.h:31,
                  from ./include/linux/rculist.h:11,
                  from ./include/linux/pid.h:5,
                  from ./include/linux/sched.h:14,
                  from kernel/sched/sched.h:5,
                  from kernel/sched/core.c:8:
In function ‘bitmap_zero’,
     inlined from ‘cpumask_clear’ at ./include/linux/cpumask.h:390:2,
     inlined from ‘get_mmu_context’ at
./arch/ia64/include/asm/mmu_context.h:92:3,
     inlined from ‘activate_context’ at
./arch/ia64/include/asm/mmu_context.h:170:11,
     inlined from ‘activate_mm’ at
./arch/ia64/include/asm/mmu_context.h:194:2,
     inlined from ‘idle_task_exit’ at kernel/sched/core.c:5575:3:
./include/linux/bitmap.h:218:2: warning: ‘memset’ writing 8 bytes into a
region of size 0 overflows the destination [-Wstringop-overflow=]
   memset(dst, 0, len);
   ^~~~~~~~~~~~~~~~~~~
[...]
```

...though I can't say if I haven't seen this before, as I didn't check
the whole make output if it exited with 0.

Cheers,
Frank
