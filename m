From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Wed, 12 Nov 2008 01:40:18 +0000
Subject: Re: [Q] Why does dma_alloc_coherent() of ia64 GFP_DMA?
Message-Id: <20081112104048C.fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0811101600490.32282@quilx.com>
	<20081111145418P.fujita.tomonori@lab.ntt.co.jp>
	<Pine.LNX.4.64.0811111431440.26610@quilx.com>
In-Reply-To: <Pine.LNX.4.64.0811111431440.26610@quilx.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: cl@linux-foundation.org
Cc: fujita.tomonori@lab.ntt.co.jp, y-goto@jp.fujitsu.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, joerg.roedel@amd.com

On Tue, 11 Nov 2008 14:32:46 -0600 (CST)
Christoph Lameter <cl@linux-foundation.org> wrote:

> On Tue, 11 Nov 2008, FUJITA Tomonori wrote:
> 
> > Is it because it does some kinda address translation
> > (provider->dma_map_consistent) later? The zone flag is meaningless if
> > you do sorta address translation (e.g. hardware IOMMU like VT-d).
> 
> Yes it can do address translation. Therefore a < 4G address can show up at
> any 64 bit address. So no need for a special DMA zone. The same is true
> for more x86_64 platforms that have an IOMMU.

Yes, with address translation hardware such as IOMMU, the zone is
meaningless. The IOMMU drivers ignore the zone flag
(e.g. intel_alloc_coherent).

But the GFP_DMA in IA64's platform_dma_alloc_coherent() is still
necessary for swiotlb with devices that don't have DMA_64BIT_MASK
coherent_dma_mask. They need a < 4G address.

This is exactly what x86 and x86_64 do, dma_alloc_coherent in
arch/x86/include/asm/dma-mapping.h. It sets GFP_DMA and GFP_DMA32 for
swiotlb and pci-nommu.c when necessary.
