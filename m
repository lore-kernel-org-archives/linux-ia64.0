From: "Yu, Fenghua" <fenghua.yu@intel.com>
Date: Thu, 02 Oct 2008 17:46:04 +0000
Subject: RE: [PATCH 2/2]Add Variable Page Size and IA64 Support in Intel
Message-Id: <A6AD88C3F2289247BE726C37303E1EB88408AA3E@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081001165750.GA21272@linux-os.sc.intel.com>
 <200810020951.08408.bjorn.helgaas@hp.com>
In-Reply-To: <200810020951.08408.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Jesse Barnes <jbarnes@virtuousgeek.org>, David Woodhouse <dwmw2@infradead.org>, Ingo Molnar <mingo@elte.hu>, Avi Kivity <avi@redhat.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

>> --- a/arch/ia64/include/asm/cacheflush.h
>> +++ b/arch/ia64/include/asm/cacheflush.h
>> @@ -34,6 +34,8 @@ do {                                                \
>>  #define flush_dcache_mmap_unlock(mapping)    do { } while (0)
>>
>>  extern void flush_icache_range (unsigned long start, unsigned long end);
>> +extern void clflush_cache_range(void *addr, int size);
>
>This patch adds clflush_cache_range(), but it's not used anywhere.
Clflush_cache_range() is used in __iommu_flush_cache() in include/linux/intel-iommu.h.

>If you do need it, it'd be nice if the arguments were the same types
>as for flush_icache_range(), and if there were a comment describing
>why it is necessary for VT-d.  And maybe the name could be more like
>the other cache flushing functions.
Since clflush_cache_range(start, size) is defined in x86, I just want to keep the same definition. So this patch set won't change __iommu_flush_cache(). Otherwise, the patch set will have #ifdef CONFIG_IA64 in __iommu_flush_cache() which is not desired.

Does this make sense?

>> +#ifdef CONFIG_PCI
>> +/* Many VIA bridges seem to corrupt data for DAC. Disable it here */
>> +
>> +static __devinit void via_no_dac(struct pci_dev *dev)
>> +{
>> +     if ((dev->class >> 8) = PCI_CLASS_BRIDGE_PCI && forbid_dac = 0) {
>> +             printk(KERN_INFO "PCI: VIA PCI bridge detected. Disabling DAC.\n");

>Please use dev_info() here.  I see you just copied this from x86, but
>we should fix x86, too.  Or better, since this doesn't appear to be
>arch-specific, maybe this should be moved to drivers/pci/quirks.c
>alongside all the other VIA quirks.

I'll move this to drivers/pci/quirks.c and use dev_info().

>> +             forbid_dac = 1;
>
>Shouldn't forbid_dac be a per-device or at least a per-bridge
>property rather than a global?
This patch set is mainly for IA64 porting purpose. I will use the same forbid dac code as x86-64 and will send a follow-up patch to deal with forbid dac.

>> +     }
>> +}
>> +DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_VIA, PCI_ANY_ID, via_no_dac);
>> +#endif
>> +/* Must execute after PCI subsystem */
>> +fs_initcall(pci_iommu_init);
>> +
>> +struct dma_mapping_ops *dma_ops;
>> +EXPORT_SYMBOL(dma_ops);
>> +
>> +int iommu_dma_supported(struct device *dev, u64 mask)
>> +{
>> +     struct dma_mapping_ops *ops = get_dma_ops(dev);
>> +
>> +#ifdef CONFIG_PCI
>> +     if (mask > 0xffffffff && forbid_dac > 0) {
>> +             dev_info(dev, "PCI: Disallowing DAC for device\n");
>
>The "PCI: " should be removed since dev_info() will add the driver
>name and device ID.
Will change this.

Bjorn


--
To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
