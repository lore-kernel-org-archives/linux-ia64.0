From: Robin Murphy <robin.murphy@arm.com>
Date: Mon, 09 Jul 2018 14:53:50 +0000
Subject: Re: [RFC PATCH 1/2] dma-mapping: Clean up dma_set_*mask() hooks
Message-Id: <3ce04634-a467-ec6b-7b90-6cd916d9b532@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <55ac9550c311f056dcfeed9b2c8265375f17b155.1530726467.git.robin.murphy@arm.com>
 <20180705193738.GB28905@lst.de>
 <33175bb1-d198-a9fd-ff37-e8c4132f47f8@arm.com>
 <20180708150708.GA14418@lst.de>
In-Reply-To: <20180708150708.GA14418@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: m.szyprowski@samsung.com, iommu@lists.linux-foundation.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On 08/07/18 16:07, Christoph Hellwig wrote:
> On Fri, Jul 06, 2018 at 03:20:34PM +0100, Robin Murphy wrote:
>>> What are you trying to do?  I really don't want to see more users of
>>> the hooks as they are are a horribly bad idea.
>>
>> I really need to fix the ongoing problem we have where, due to funky
>> integrations, devices suffer some downstream addressing limit (described by
>> DT dma-ranges or ACPI IORT/_DMA) which we carefully set up in
>> dma_configure(), but then just gets lost when the driver probes and
>> innocently calls dma_set_mask() with something wider. I think it's
>> effectively the generalised case of the VIA 32-bit quirk, if I understand
>> that one correctly.
> 
> I'd much rather fix this in generic code.  How funky are your limitations?
> In fact when I did the 32-bit quirk (which will also be used by a Xiling
> PCIe root port usable on a lot of architectures) I did initially consider
> adding a bus_dma_mask or similar to struct device, but opted for the
> most simple implementation for now.  I'd be happy to chanfe this.
> 
> Especially these days where busses and IP blocks are generally not tied
> to a specific cpu instruction set I really believe that having any
> more architecture code than absolutely required is a bad idea.

Oh, for sure, the generic fix would be the longer-term goal, this was 
just an expedient compromise because I want to get *something* landed 
for 4.19. Since in practice this is predominantly affecting arm64, doing 
the arch-specific fix to appease affected customers then working to 
generalise it afterwards seemed to carry the lowest risk.

That said, I think I can see a relatively safe and clean alternative 
approach based on converting dma_32bit_limit to a mask, so I'll spin 
some patches around that idea ASAP to continue the discussion.

>> The approach that seemed to me to be safest is largely based on the one
>> proposed in a thread from ages ago[1]; namely to make dma_configure()
>> better at distinguishing firmware-specified masks from bus defaults,
>> capture the firmware mask in dev->archdata during arch_setup_dma_ops(),
>> then use the custom set_mask routines to ensure any subsequent updates
>> never exceed that. It doesn't seem possible to make this work robustly
>> without storing *some* additional per-device data, and for that archdata is
>> a lesser evil than struct device itself. Plus even though it's not actually
>> an arch-specific issue it feels like there's such a risk of breaking other
>> platforms that I'm reticent to even try handling it entirely in generic
>> code.
> 
> My plan for a few merge windows from now is that dma_mask and
> coherent_mask are 100% in device control and dma_set_mask will never
> fail.  It will be up to the dma ops to make sure things are addressible.

It's entirely possible to plug an old PCI soundcard via a bridge adapter 
into a modern board where the card's 24-bit DMA mask reaches nothing but 
the SoC's boot flash, and no IOMMU is available (e.g. some of the 
smaller NXP Layercape stuff); I still think there should be an error in 
such rare cases when DMA is utterly impossible, but otherwise I agree it 
would be much nicer for drivers to just provide their preferred mask and 
let the ops massage it as necessary.

Robin.
