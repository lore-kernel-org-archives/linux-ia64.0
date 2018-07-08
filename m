From: Christoph Hellwig <hch@lst.de>
Date: Sun, 08 Jul 2018 15:07:08 +0000
Subject: Re: [RFC PATCH 1/2] dma-mapping: Clean up dma_set_*mask() hooks
Message-Id: <20180708150708.GA14418@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <55ac9550c311f056dcfeed9b2c8265375f17b155.1530726467.git.robin.murphy@arm.com>
 <20180705193738.GB28905@lst.de>
 <33175bb1-d198-a9fd-ff37-e8c4132f47f8@arm.com>
In-Reply-To: <33175bb1-d198-a9fd-ff37-e8c4132f47f8@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Robin Murphy <robin.murphy@arm.com>
Cc: Christoph Hellwig <hch@lst.de>, m.szyprowski@samsung.com, iommu@lists.linux-foundation.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Fri, Jul 06, 2018 at 03:20:34PM +0100, Robin Murphy wrote:
>> What are you trying to do?  I really don't want to see more users of
>> the hooks as they are are a horribly bad idea.
>
> I really need to fix the ongoing problem we have where, due to funky 
> integrations, devices suffer some downstream addressing limit (described by 
> DT dma-ranges or ACPI IORT/_DMA) which we carefully set up in 
> dma_configure(), but then just gets lost when the driver probes and 
> innocently calls dma_set_mask() with something wider. I think it's 
> effectively the generalised case of the VIA 32-bit quirk, if I understand 
> that one correctly.

I'd much rather fix this in generic code.  How funky are your limitations?
In fact when I did the 32-bit quirk (which will also be used by a Xiling
PCIe root port usable on a lot of architectures) I did initially consider
adding a bus_dma_mask or similar to struct device, but opted for the
most simple implementation for now.  I'd be happy to chanfe this.

Especially these days where busses and IP blocks are generally not tied
to a specific cpu instruction set I really believe that having any
more architecture code than absolutely required is a bad idea.

> The approach that seemed to me to be safest is largely based on the one 
> proposed in a thread from ages ago[1]; namely to make dma_configure() 
> better at distinguishing firmware-specified masks from bus defaults, 
> capture the firmware mask in dev->archdata during arch_setup_dma_ops(), 
> then use the custom set_mask routines to ensure any subsequent updates 
> never exceed that. It doesn't seem possible to make this work robustly 
> without storing *some* additional per-device data, and for that archdata is 
> a lesser evil than struct device itself. Plus even though it's not actually 
> an arch-specific issue it feels like there's such a risk of breaking other 
> platforms that I'm reticent to even try handling it entirely in generic 
> code.

My plan for a few merge windows from now is that dma_mask and
coherent_mask are 100% in device control and dma_set_mask will never
fail.  It will be up to the dma ops to make sure things are addressible.
