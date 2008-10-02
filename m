From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 02 Oct 2008 15:51:07 +0000
Subject: Re: [PATCH 2/2]Add Variable Page Size and IA64 Support in Intel IOMMU: IA64 Specific Part
Message-Id: <200810020951.08408.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081001165750.GA21272@linux-os.sc.intel.com>
In-Reply-To: <20081001165750.GA21272@linux-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Fenghua Yu <fenghua.yu@intel.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Jesse Barnes <jbarnes@virtuousgeek.org>, David Woodhouse <dwmw2@infradead.org>, Ingo Molnar <mingo@elte.hu>, Avi Kivity <avi@redhat.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

On Wednesday 01 October 2008 10:57:50 am Fenghua Yu wrote:
> --- a/arch/ia64/include/asm/cacheflush.h
> +++ b/arch/ia64/include/asm/cacheflush.h
> @@ -34,6 +34,8 @@ do {						\
>  #define flush_dcache_mmap_unlock(mapping)	do { } while (0)
>  
>  extern void flush_icache_range (unsigned long start, unsigned long end);
> +extern void clflush_cache_range(void *addr, int size);

This patch adds clflush_cache_range(), but it's not used anywhere.

If you do need it, it'd be nice if the arguments were the same types
as for flush_icache_range(), and if there were a comment describing
why it is necessary for VT-d.  And maybe the name could be more like
the other cache flushing functions.

> +#ifdef CONFIG_PCI
> +/* Many VIA bridges seem to corrupt data for DAC. Disable it here */
> +
> +static __devinit void via_no_dac(struct pci_dev *dev)
> +{
> +	if ((dev->class >> 8) = PCI_CLASS_BRIDGE_PCI && forbid_dac = 0) {
> +		printk(KERN_INFO "PCI: VIA PCI bridge detected. Disabling DAC.\n");

Please use dev_info() here.  I see you just copied this from x86, but
we should fix x86, too.  Or better, since this doesn't appear to be
arch-specific, maybe this should be moved to drivers/pci/quirks.c
alongside all the other VIA quirks.

> +		forbid_dac = 1;

Shouldn't forbid_dac be a per-device or at least a per-bridge
property rather than a global?

> +	}
> +}
> +DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_VIA, PCI_ANY_ID, via_no_dac);
> +#endif
> +/* Must execute after PCI subsystem */
> +fs_initcall(pci_iommu_init);
> +
> +struct dma_mapping_ops *dma_ops;
> +EXPORT_SYMBOL(dma_ops);
> +
> +int iommu_dma_supported(struct device *dev, u64 mask)
> +{
> +	struct dma_mapping_ops *ops = get_dma_ops(dev);
> +
> +#ifdef CONFIG_PCI
> +	if (mask > 0xffffffff && forbid_dac > 0) {
> +		dev_info(dev, "PCI: Disallowing DAC for device\n");

The "PCI: " should be removed since dev_info() will add the driver
name and device ID.

Bjorn


