From: Darren Williams <dsw@gelato.unsw.edu.au>
Date: Fri, 20 Feb 2004 02:55:08 +0000
Subject: Re: 2.6.3 oops ia64 Itanium1 with Silicon Image IDE
Message-Id: <20040220025508.GJ11475@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040220005623.GI11475@cse.unsw.EDU.AU>
In-Reply-To: <20040220005623.GI11475@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi David

I will try the first option of setting

PCI_DMA_BUS_IS_PHYS to 0

and report back. 

I know we must be the only people in the world that
uses these machines, but somebody has to keep the HP
service guys clued up on old technology. The last guy
that payed us a visit though he was in a museum.

Thanks

Darren


On Thu, 19 Feb 2004, David Mosberger wrote:

> >>>>> On Fri, 20 Feb 2004 11:56:23 +1100, Darren Williams <dsw@gelato.unsw.edu.au> said:
> 
>   Darren> We have an Itainum 1 that oopses on boot with a Silicon
>   Darren> Imagae IDE pci controller. I can boot the same image on a
>   Darren> machine with the same setup except for RAM, which is
>   Darren> 1GB. Looking through the archives it seems to be related to
>   Darren> the following:
> 
>   Darren> http://www.ussg.iu.edu/hypermail/linux/kernel/0306.0/1098.html
> 
> Hmmh, trying to remember how this all works...
> 
> PCI_DMA_BUS_IS_PHYS currently returns its value based on
> ia64_max_iommu_merge_mask.  This variable is primarily used to tell
> the block-layer (via BIO_VMERGE_BOUNDARY and then
> BIOVEC_VIRT_MERGEABLE) whether two physically discontiguous buffers
> can be merged via an I/O MMU, such that they appear contiguous from
> the perspective of device DMA.
> 
> Your machine doesn't have a hardware I/O MMU so it's using swiotlb,
> which simulates the effect of a hardware I/O MMU but of course it
> cannot do virtual merging, so it has to leave
> ia64_max_iommu_merge_mask at its default value (~0).  This in turn has
> the effect that PCI_DMA_BUS_IS_PHYS returns 1, which then leads to the
> panic you observed in this fashion:
> 
>  (1) ide_toggle_bounce() finds that there is no hardware I/O MMU
>      (PCI_DMA_BUS_IS_PHYS is 1) and sets the controller's DMA limit to
>      its true physical limit
>  (2) blk_queue_bounce_limit() finds that the controller can't
>      address all physical memory (bounce_pfn < blk_max_low_pfn), and
>  (3) controller can't address up to BLK_BOUNCE_ISA (which is ~0UL on ia64)
> 
> and so it throws up its hands and gives up.
> 
> You could define PCI_DMA_BUS_IS_PHYS as 0, but then you'd get a
> needless amount of bounce-buffering, since memory won't be allocated
> with GFP_DMA.
> 
> Actually, I can't find any uses for ISA_DMA_THRESHOLD anymore, except
> for aha1542.c (which probably doesn't work on ia64 anyhow) and for its
> use in defining BLK_BOUNCE_ISA.  Perhaps we can define
> ISA_DMA_THRESHOLD as 0xffffffff so it matches the 4GB limit implied by
> GFP_DMA.  If the controller can do full 32-bit addressing, this should
> take avoid the BUG_ON() without any ill effects.
> 
> Perhaps someone who understands the disk/block layers better can also
> comment.
> 
> In summary:
> 
>  - You can force PCI_DMA_BUS_IS_PHYS to 0, which is probably the
>    safest since it should work even if there is heavy pressure
>    on memory <= 4GB.
> 
>  - You can try setting ISA_DMA_THRESHOLD to 0xffffffff which should
>    work fine as long as there is free memory <= 4GB.
> 
>  - You could get a controller that can address all physical memory
>    or a machine that has a hardware I/O MMU.
> 
> 	--david
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
--------------------------------------------------
Darren Williams <dsw AT gelato.unsw.edu.au>
Gelato@UNSW <www.gelato.unsw.edu.au>
--------------------------------------------------
