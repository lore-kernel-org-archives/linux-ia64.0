From: John Keller <jpk@sgi.com>
Date: Tue, 18 Nov 2008 15:53:04 +0000
Subject: Re: [PATCH] ia64: SN specific version of dma_get_required_mask()
Message-Id: <200811181553.mAIFr5RT057348@fcbayern.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <57C9024A16AD2D4C97DC78E552063EA35C454266@orsmsx505.amr.corp.intel.com> from "Luck, Tony" at Nov 18, 2008 07:35:15 AM
References: <20081117162454.169426.74531.sendpatchset@attica.americas.sgi.com>
In-Reply-To: <20081117162454.169426.74531.sendpatchset@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: John Keller <jpk@sgi.com>, Bernhard Walle <bwalle@suse.de>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

> 
> > This patch addresses a problem on SN Altix systems with < 4GB, where
> > device drivers using the dma_get_required_mask() API would be told
> > to use 32 bit DMA, when 64 bit is more efficient.
> 
> Even if someone did configure an Altix with < 4GB (which seems a very
> unlikely occurance) all of that 4G would be located above 4GB (lowest
> physical address on Altix is something like 384 TB, isn't it?)
> 
> Did we really make some dma mask decisions based on the amount
> of memory rather than its location?  If we do, then perhaps we
> should fix this in a generic place, not in sn2 specific code.
> 
> -Tony
> 

This is the generic routine for all archs and platforms...

drivers/base/platform.c


#ifndef ARCH_HAS_DMA_GET_REQUIRED_MASK
u64 dma_get_required_mask(struct device *dev)
{
        u32 low_totalram = ((max_pfn - 1) << PAGE_SHIFT);
        u32 high_totalram = ((max_pfn - 1) >> (32 - PAGE_SHIFT));
        u64 mask;

        if (!high_totalram) {
                /* convert to mask just covering totalram */
                low_totalram = (1 << (fls(low_totalram) - 1));
                low_totalram += low_totalram - 1;
                mask = low_totalram;
        } else {
                high_totalram = (1 << (fls(high_totalram) - 1));
                high_totalram += high_totalram - 1;
                mask = (((u64)high_totalram) << 32) + 0xffffffff;
        }
        return mask;
}
EXPORT_SYMBOL_GPL(dma_get_required_mask);
#endif


John
----
