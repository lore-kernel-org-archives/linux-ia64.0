From: Matthew Wilcox <matthew@wil.cx>
Date: Tue, 21 Aug 2007 20:16:32 +0000
Subject: Re: [PATCH 2/3] dma: override "dma_flags_set_dmaflush" for sn-ia64
Message-Id: <20070821201631.GF9163@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070818002746.GU1813@sgi.com> <46C94FD5.6000006@sgi.com> <20070821193522.GD5592@sgi.com>
In-Reply-To: <20070821193522.GD5592@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akepner@sgi.com
Cc: Jes Sorensen <jes@sgi.com>, linux-kernel <linux-kernel@vger.kernel.org>, rdreier@cisco.com, linux-ia64 <linux-ia64@vger.kernel.org>

On Tue, Aug 21, 2007 at 12:35:22PM -0700, akepner@sgi.com wrote:
> +int
> +dma_flags_set_dmaflush(int dir)
> +
> +Amend dir (one of the enum dma_data_direction values), with a platform-
> +specific "dmaflush" attribute. Unless the platform supports "posted DMA" 
> +this is a no-op. 
> +
> +On platforms that support posted DMA, dma_flags_set_dmaflush() causes 
> +device writes to the associated memory region to flush in-flight DMA. 
> +This can be important, for example, when (DMA) writes to the memory 
> +region indicate that DMA of data is complete. If DMA of data and DMA of 
> +the completion indication race, as they can do when the platform supports 
> +posted DMA, then the completion indication may arrive in host memory 
> +ahead of some data.

So, let me try to understand ... your hardware allows writes from the
device to pass other writes from the device?  Doesn't that violate the
PCI spec?  I'm thinking about this (page 43 of PCI 2.3):

  Posted memory writes moving in the same direction through a bridge
  will complete on the destination bus in the same order they complete
  on the originating bus. Even if a single burst on the originating bus
  is terminated with Disconnect on the destination bus so that it is
  broken into multiple transactions, those transactions must not allow
  the data phases to complete on the destination bus in any order other
  than their order on the originating bus.

> +To prevent this, you might map the memory region used for completion 
> +indications as follows:
> +
> +	int count, flags = dma_flags_set_dmaflush(DMA_BIDIRECTIONAL);
> +	.....
> +	count = dma_map_sg(dev, sglist, nents, flags);

So any device driver used on your hardware has to add a call to this new
function, or it'll see data corruption?  Not acceptable, IMO.

If this is a performance optimisation, then by all means add a function
drivers can call to say "it's OK, I know about this brokenness, and I
don't depend on it", but safety first.

-- 
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
