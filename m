From: Yasunori Goto <y-goto@jp.fujitsu.com>
Date: Tue, 03 Feb 2009 01:52:03 +0000
Subject: Re: [PATCH -tip 1/3] IA64: fix swiotlb alloc_coherent for non DMA_64BIT_MASK devices
Message-Id: <20090203104439.8ADF.E1E9C6FF@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090130184210.4A8E.E1E9C6FF@jp.fujitsu.com> <20090203082825J.fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <20090203082825J.fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, mingo@elte.hu
Cc: tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

> On Fri, 30 Jan 2009 20:24:13 +0900
> Yasunori Goto <y-goto@jp.fujitsu.com> wrote:
> 
> > > > swiotlb_dma_ops is set by pci_swiotlb_init().
> > > > However, it seems to be not called when CONFIG_IA64_DIG/Generic configuration.
> > > 
> > > You are talking about setting dma_ops to swiotlb_dma_ops?
> > > 
> > > I think that swiotlb_dma_init() also sets dma_ops to swiotlb_dma_ops.
> > 
> > Certainly.
> > I overlooked the 7th patch of your unifying dma_ops patch set.
> > ia64_swiotlb_alloc_coherent was called when I tested again.
> > I'm sorry.
> > 
> > However, GFP_DMA is still always on in ia64_swiotlb_alloc_coherent()
> > regardless of the value of dev->coherent_dma_mask.
> > 
> > After following patch applied, GFP_DMA is set correctly by your patch.
> > Am I still overlooking other your patch?
> 
> No, you are not. We need the following change. Somehow I thought that
> I already made this change.
> 
> Can you resend this to Ingo with the proper description and
> Signed-off-by (you can add my Acked-by if you like)?

Sure!
Ingo-san. Could you apply the following patch?

Bye.

-----

Because dma_alloc_coherent() always required DMA zone even if DMA is
NOT necessary, FUJITA Tomonori posted a patch to fix it.

http://marc.info/?l=linux-ia64&m3314730923356&w=2

However, this fix needs one more patch to fix completely.
I tested and confirmed dma_alloc_coherent() returns 
correct zone after applied following patch.


Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>
Acked-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 arch/ia64/include/asm/dma-mapping.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: dma_fix_test/arch/ia64/include/asm/dma-mapping.h
=================================--- dma_fix_test.orig/arch/ia64/include/asm/dma-mapping.h	2009-01-30 19:36:33.000000000 +0900
+++ dma_fix_test/arch/ia64/include/asm/dma-mapping.h	2009-01-30 20:20:06.000000000 +0900
@@ -71,7 +71,7 @@ static inline void *dma_alloc_coherent(s
 				       dma_addr_t *daddr, gfp_t gfp)
 {
 	struct dma_mapping_ops *ops = platform_dma_get_ops(dev);
-	return ops->alloc_coherent(dev, size, daddr, gfp | GFP_DMA);
+	return ops->alloc_coherent(dev, size, daddr, gfp);
 }
 
 static inline void dma_free_coherent(struct device *dev, size_t size,


-- 
Yasunori Goto 


