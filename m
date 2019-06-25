From: Frank Scheiner <frank.scheiner@web.de>
Date: Tue, 25 Jun 2019 11:19:39 +0000
Subject: Re: Regression in 543cea9a - was: Re: Kernel problem on rx2800 i2
Message-Id: <a2ab92b3-e89d-a610-91d1-5ea626be4995@web.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1d62aadd-67b6-da13-53cc-4b5213de8937@physik.fu-berlin.de>
In-Reply-To: <1d62aadd-67b6-da13-53cc-4b5213de8937@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



On 6/25/19 12:47, Christoph Hellwig wrote:
> On Tue, Jun 25, 2019 at 12:46:39PM +0200, Frank Scheiner wrote:
>> Do you suspect a firmware issue? Because the firmware of that machine is
>> actually quite old (the model was retired in 2015):
>
> No, probably something in the Linux ia64-specific code.
>
>>>    	if (!page)
>>> -		page = alloc_pages_node(dev_to_node(dev), gfp, page_order);
>>> +		page = alloc_pages(gfp, page_order);
>>>
>>>    	if (page && !dma_coherent_ok(dev, page_to_phys(page), size)) {
>>>    		__free_pages(page, page_order);
>>>
>>
>> Ok, will try that patch - actually (1) in addition or (2) without the
>> first one?
>
> Instead.

Ok, that looks much better now with the second patch:

```
Linux version 5.1.15-dirty (root@rx2800-i2) (gcc version 7.3.0 (Gentoo
7.3.0-r3 p1.4)) #2 SMP Tue Jun 25 13:11:38 CEST 2019
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
scsi host0: ahci
scsi host1: ahci
scsi host2: ahci
scsi host3: ahci
scsi host4: ahci
scsi host5: ahci
[...]
INIT: version 2.93 booting

    OpenRC 0.41.2 is starting up Gentoo Linux (ia64)
[...]
This is rx2800-i2.[...] (Linux ia64 5.1.15-dirty) 13:23:57

rx2800-i2 login:
```

...even after a second reboot for verification. Great!

I assume this won't affect UMA Itaniums or should I check on one of my
other Integrities if this change breaks the kernel on them?
