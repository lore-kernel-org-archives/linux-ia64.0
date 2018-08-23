From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 23 Aug 2018 05:24:48 +0000
Subject: Re: [PATCH 01/20] kernel/dma/direct: take DMA offset into account in dma_direct_supported
Message-Id: <e074e74017742a60607c8ce7f78281dc8fdbcdc7.camel@kernel.crashing.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180730163824.10064-1-hch@lst.de>
 <20180730163824.10064-2-hch@lst.de>
 <74068e4d2135ecad8645048ed97b1114891ccace.camel@kernel.crashing.org>
 <20180822065359.GB19284@lst.de>
 <079a961eaf548644250719df83930d3d72e34cac.camel@kernel.crashing.org>
 <20180823052403.GA14388@lst.de>
In-Reply-To: <20180823052403.GA14388@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Robin Murphy <robin.murphy@arm.com>, linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-ia64@vger.kernel.org

On Thu, 2018-08-23 at 07:24 +0200, Christoph Hellwig wrote:
> > Well, iommus can have bypass regions, which we also use for
> > performance, so we do at dma_set_mask() time "swap" the ops around, and
> > in that case, we do want to check the mask against the actual top of
> > memory...
> 
> That is a bit of a powerpc special case (we also had one other arch
> doing that, but it got removed in the great purge, can't rember which
> one right now).  Everyone else has one set of ops, and they just switch
> to the direct mapping inside the iommu ops.

We more or less do that too in some of ours these days bcs of the whole
coherent_mask vs mask where a given device might need either depending
on the type of mapping.

Ben.
