From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Mon, 17 Nov 2008 08:47:51 +0000
Subject: Re: [PATCH] swiotlb: use coherent_dma_mask in alloc_coherent
Message-Id: <20081117174828U.fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081117162445C.fujita.tomonori@lab.ntt.co.jp>
	<20081117081526.GA24603@elte.hu>
In-Reply-To: <20081117081526.GA24603@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mingo@elte.hu
Cc: fujita.tomonori@lab.ntt.co.jp, tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, joerg.roedel@amd.com, akpm@linux-foundation.org

On Mon, 17 Nov 2008 09:15:26 +0100
Ingo Molnar <mingo@elte.hu> wrote:

> 
> * FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp> wrote:
> 
> > This patch fixes swiotlb to use dev->coherent_dma_mask in 
> > alloc_coherent. Currently, swiotlb uses dev->dma_mask in 
> > alloc_coherent but alloc_coherent is supposed to use 
> > coherent_dma_mask. It could break drivers that uses smaller 
> > coherent_dma_mask than dma_mask (though the current code works for 
> > the majority that use the same mask for coherent_dma_mask and 
> > dma_mask).
> > 
> > Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
> > ---
> >  lib/swiotlb.c |   10 +++++++---
> >  1 files changed, 7 insertions(+), 3 deletions(-)
> 
> Applied it with the changelog below to tip/core/urgent, thanks!
> 
> I also flagged it for v2.6.28 inclusion. This bug was caused by the 
> removal of the GFP_DMA hack in swiotlb_alloc_coherent() in this cycle. 
> I havent seen it actually reported anywhere - have you perhaps?Or have 
> you found this via code review?

This wasn't introduced by the removal of the GFP_DMA hack. It has been
for ages, I think.

I knew this issue but I thought that it's harmless and let it
alone. But Grant Grundler said that there are some devices are
troubled by this:

http://marc.info/?l=linux-kernel&m2379585203173&w=2

I fixed VT-d about this (bb9e6d65078da2f38cfe1067cfd31a896ca867c0) but
somehow I forgot about swiotlb.

I think that it would be fine to push this to 2.6.29 since seems that
nobody hits this. But it's also fine to push it for 2.6.28 since it's
theoretically a bug fix and pretty trivial.


> Do we know roughly the range of devices/systems where there's a real 
> address range that cannot be DMA-ed to coherently, and an estimation 
> about how frequently they would be affected by this bug?

I think that if a driver hits this bug, it's likely that an user sees
kinda data corruption right after loading the driver.
