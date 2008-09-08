From: Ingo Molnar <mingo@elte.hu>
Date: Mon, 08 Sep 2008 13:52:56 +0000
Subject: Re: [PATCH 0/5] fix exhaustion of ZONE_DMA with swiotlb (in x86
Message-Id: <20080908135256.GE11993@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <1220865014-1169-1-git-send-email-fujita.tomonori@lab.ntt.co.jp> <20080908120017.GI3189@amd.com>
In-Reply-To: <20080908120017.GI3189@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joerg Roedel <joerg.roedel@amd.com>, tony.luck@intel.com
Cc: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, linux-kernel@vger.kernel.org, mingo@redhat.com, linux-ia64@vger.kernel.org, iommu@lists.linux-foundation.org


* Joerg Roedel <joerg.roedel@amd.com> wrote:

> On Mon, Sep 08, 2008 at 06:10:09PM +0900, FUJITA Tomonori wrote:
> > This patchset (against tip/master) fixes the problem that swiotlb
> > exhausts ZONE_DMA:
> > 
> > http://lkml.org/lkml/2008/8/31/16
> > 
> > The root problem is that swiotlb_alloc_coherent always use ZONE_DMA,
> > which is fine for IA64 but not for x86_64.
> > 
> > This patchset makes the callers set up the gfp flags so that
> > swiotlb_alloc_coherent can stop playing with the gfp flags.
> > 
> > I think that it would be better to remove the allocation code in
> > swiotlb_alloc_coherent theoretically (what swiotlb should do is taking
> > care of the swiotlb memory. And swiotlb_alloc_coherent is not useful
> > since we use it only when we can't allocate memory reachable by the
> > device or we are in out of memory). But that code works for both x86
> > and IA64 so it's not so bad, I guess.
> > 
> > #1 is for IA64, #2-4 for x86, and #5 is for swiotlb.
> 
> Cool :-)
> 
> This is much better than our last two tries to solve this problem. 
> Doing no gfp handling at all in swiotlb_alloc_coherent is a nice and 
> clean solution.

i've applied Fujita's patches to tip/x86/iommu:

 68e91d6: swiotlb: remove GFP_DMA hack in swiotlb_alloc_coherent
 823e7e8: x86: dma_alloc_coherent sets gfp flags properly
 8a53ad6: x86: fix nommu_alloc_coherent allocation with NULL device argument
 de9f521: x86: move pci-nommu's dma_mask check to common code
 3a80b6a: ia64: dma_alloc_coherent always use GFP_DMA

Tony, do you have any problem with us carrying the ia64 commit above 
(3a80b6a, also attached below) in tip/x86/iommu tree? It's really small 
and straightforward.

	Ingo

----------------->
From 3a80b6aa271eb08a3da1a04b5cbdcdc19d4a5ae0 Mon Sep 17 00:00:00 2001
From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Mon, 8 Sep 2008 18:10:10 +0900
Subject: [PATCH] ia64: dma_alloc_coherent always use GFP_DMA

This patch makes dma_alloc_coherent use GFP_DMA at all times. This is
necessary for swiotlb, which requires the callers to set up the gfp
flags properly.

swiotlb_alloc_coherent tries to allocate pages with the gfp flags. If
the allocated memory isn't fit for dev->coherent_dma_mask,
swiotlb_alloc_coherent reserves some of the swiotlb memory area, which
is precious resource. So the callers need to set up the gfp flags
properly.

This patch means that other IA64 IOMMUs' dma_alloc_coherent also use
GFP_DMA. These IOMMUs (e.g. SBA IOMMU) don't need GFP_DMA since they
can map a memory to any address. But IA64's GFP_DMA is large,
generally drivers allocate small memory with dma_alloc_coherent only
at startup. So I chose the simplest way to set up the gfp flags for
swiotlb.

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Acked-by: Joerg Roedel <joerg.roedel@amd.com>
Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 arch/ia64/include/asm/dma-mapping.h |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/include/asm/dma-mapping.h b/arch/ia64/include/asm/dma-mapping.h
index 9f0df9b..06ff1ba 100644
--- a/arch/ia64/include/asm/dma-mapping.h
+++ b/arch/ia64/include/asm/dma-mapping.h
@@ -8,7 +8,9 @@
 #include <asm/machvec.h>
 #include <linux/scatterlist.h>
 
-#define dma_alloc_coherent	platform_dma_alloc_coherent
+#define dma_alloc_coherent(dev, size, handle, gfp)	\
+	platform_dma_alloc_coherent(dev, size, handle, (gfp) | GFP_DMA)
+
 /* coherent mem. is cheap */
 static inline void *
 dma_alloc_noncoherent(struct device *dev, size_t size, dma_addr_t *dma_handle,
