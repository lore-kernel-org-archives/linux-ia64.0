From: Prarit Bhargava <prarit@redhat.com>
Date: Thu, 15 Feb 2007 13:46:31 +0000
Subject: Re: [Fedora-ia64-list] [PATCH] ide controller quirk to correct	badBAR
Message-Id: <45D46437.2060308@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <45D1DE90.9080709@redhat.com>
In-Reply-To: <45D1DE90.9080709@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



Zhang, Yanmin wrote:
> On Tue, 2007-02-13 at 10:37 -0800, Luck, Tony wrote:
>   
>>> +	pci_read_config_byte(dev, PCI_CLASS_PROG, &tmp8);
>>> +	mask = (1 << 2) | (1 << 0);
>>> +	if ((tmp8 & mask) = mask)
>>>       
>> Are there no symbolic defines for these bits?
>>     
> No.
>
>   
>>   If there are, then
>> use them.  If not, then does it really help readability to assemble
>> the bits by hand?  Why not just use:
>>
>> 	if ((tmp8 & 5) = 5)
>>     
> Ok, I will change it.
>
>   
>> -Tony
>>
>> P.S.   The BIOS per se isn't to blame here.  If you dump pci space
>> from the EFI prompt (use "pci 0 1f 1") you'll see that the BIOS really
>> hasn't initialized the BARs at all.Perhaps some stuff in ACPI sets
>> them up (wrongly)?
>>     

Oops.  I have a bad habit of usering BIOS/ & ACPI interchangeably .. 
sorry for the confusion.

> I checked the BARs under EFI prompt. BAR 5 is 0 which looks like not
> initialized by BIOS. But my opinion is BIOS really initiates BAR 5 as
> 0, or it should change it to non-zero but it doesn't.
> Function pci_read_bases reads all 6 bars from the device configuraton
> space and initiates dev->resource[]. When a BAR=0, if the sz (size) is not zero,
> the resource[].start will be set to 0 and resource[].end will be set to
> sz. resource[].flag is IORESOURCE_MEM. Such data is realy the same thing
> we could see under /sys/devices/_bus_/_deviceid_/resource after kernel boot.
>
> That behavior is also consistent with what Alan replied on linux-ide maillist.
>
>   


IIRC, the case that Alan was talking about was a case where the powerpc 
arch had devices that required start =0, not this case where the ACPI 
table info is inocorrect. 

P.

> Below is the new patch. Thank Tony.
>
> ---
>
> If ide controllers are at legacy mode, only the 4th BAR
> is needed, so some BIOS initiate other BAR with incorrect
> value. ata/ata_piix calls pci_enable_device on the ide
> controller, which will check BAR resources. If the BAR
> resource values are incorrect, pci_enable_device will fail,
> and ata/ata_piix couldn't attach the ide controller.
>
> Below patch against 2.6.20 creates a quirk to correct the
> bad BAR resources for a special ide controller which is
> popular on tiger-4.
>
> Signed-off-by: Zhang Yanmin <yanmin.zhang@intel.com>
>
> ---
>
> --- linux-2.6.20/arch/ia64/kernel/quirks.c	1969-12-31 19:00:00.000000000 -0500
> +++ linux-2.6.20_fix/arch/ia64/kernel/quirks.c	2007-02-13 13:56:34.000000000 -0500
> @@ -0,0 +1,45 @@
> +/*
> + * This file contains work-arounds for ia64 platform bugs.
> + */
> +#include <linux/pci.h>
> +
> +/*
> + * quirk_intel_ide_controller: If an ide/ata controller is
> + * at legacy mode, BIOS might initiates BAR(bar 0~3 and 5)
> + * with incorrect value. This quirk will reset the incorrect
> + * value to 0.
> + */
> +static void __devinit quirk_intel_ide_controller(struct pci_dev *dev)
> +{
> +	unsigned int pos;
> +	struct resource *res;
> +	int fixed = 0;
> +	u8 tmp8;
> +
> +	if ((dev->class >> 8) != PCI_CLASS_STORAGE_IDE)
> +		return;
> +
> +	/* TODO: What if one channel is in native mode ... */
> +	pci_read_config_byte(dev, PCI_CLASS_PROG, &tmp8);
> +	if ((tmp8 & 5) = 5)
> +		return;
> +
> +	for( pos = 0; pos < 6; pos ++ ) {
> +		res = &dev->resource[pos];
> +		if (!(res->flags & (IORESOURCE_IO | IORESOURCE_MEM)))
> +			continue;
> +
> +		if (!res->start && res->end) {
> +			res->start = res->end = 0;
> +			res->flags = 0;
> +			fixed = 1;
> +		}
> +	}
> +	if (fixed)
> +		printk(KERN_WARNING
> +			"PCI device %s: BIOS resource configuration fixed.\n",
> +			pci_name(dev));
> +}
> +
> +DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_INTEL_82801DB_11, quirk_intel_ide_controller);
> +
> --- linux-2.6.20/arch/ia64/kernel/Makefile	2007-02-08 02:13:41.000000000 -0500
> +++ linux-2.6.20_fix/arch/ia64/kernel/Makefile	2007-02-12 09:49:39.000000000 -0500
> @@ -33,6 +33,7 @@ obj-$(CONFIG_CRASH_DUMP)	+= crash_dump.o
>  obj-$(CONFIG_IA64_UNCACHED_ALLOCATOR)	+= uncached.o
>  obj-$(CONFIG_AUDIT)		+= audit.o
>  obj-$(CONFIG_PCI_MSI)		+= msi_ia64.o
> +obj-$(CONFIG_PCI)		+= quirks.o
>  mca_recovery-y			+= mca_drv.o mca_drv_asm.o
>  
>  obj-$(CONFIG_IA64_ESI)		+= esi.o
>
> --
> Fedora-ia64-list mailing list
> Fedora-ia64-list@redhat.com
> https://www.redhat.com/mailman/listinfo/fedora-ia64-list
>
>   
