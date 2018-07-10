From: Christoph Hellwig <hch@lst.de>
Date: Tue, 10 Jul 2018 11:44:43 +0000
Subject: Re: [RFC PATCH 1/2] dma-mapping: Clean up dma_set_*mask() hooks
Message-Id: <20180710114443.GC32688@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <55ac9550c311f056dcfeed9b2c8265375f17b155.1530726467.git.robin.murphy@arm.com>
 <20180705193738.GB28905@lst.de>
 <33175bb1-d198-a9fd-ff37-e8c4132f47f8@arm.com>
 <20180708150708.GA14418@lst.de>
 <3ce04634-a467-ec6b-7b90-6cd916d9b532@arm.com>
In-Reply-To: <3ce04634-a467-ec6b-7b90-6cd916d9b532@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Robin Murphy <robin.murphy@arm.com>
Cc: Christoph Hellwig <hch@lst.de>, m.szyprowski@samsung.com, iommu@lists.linux-foundation.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Mon, Jul 09, 2018 at 03:53:50PM +0100, Robin Murphy wrote:
> Oh, for sure, the generic fix would be the longer-term goal, this was just 
> an expedient compromise because I want to get *something* landed for 4.19. 
> Since in practice this is predominantly affecting arm64, doing the 
> arch-specific fix to appease affected customers then working to generalise 
> it afterwards seemed to carry the lowest risk.
>
> That said, I think I can see a relatively safe and clean alternative 
> approach based on converting dma_32bit_limit to a mask, so I'll spin some 
> patches around that idea ASAP to continue the discussion.

Great!  I really want to sort out this area as soon as possible, and
introducing more arch specific code isn't really helping with that.  In
fact my whole drive to consolidate code is based on the fact that
I want to fix issues like this in one code base instead of 20 slightly
different ones.

FYI, this is the Xilinx/RISC-V use case for the 32-bit limit,
which I'll need to respin a bit based on linux-pci feedback:

http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/xilinx-dma-32

> It's entirely possible to plug an old PCI soundcard via a bridge adapter 
> into a modern board where the card's 24-bit DMA mask reaches nothing but 
> the SoC's boot flash, and no IOMMU is available (e.g. some of the smaller 
> NXP Layercape stuff); I still think there should be an error in such rare 
> cases when DMA is utterly impossible, but otherwise I agree it would be 
> much nicer for drivers to just provide their preferred mask and let the ops 
> massage it as necessary.

Ok, I guess we need still need to keep the return value for that.
