From: Christoph Hellwig <hch@lst.de>
Date: Wed, 22 Aug 2018 07:04:07 +0000
Subject: Re: [PATCH 17/20] powerpc/dma-swiotlb: use generic swiotlb_dma_ops
Message-Id: <20180822070406.GE19284@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180730163824.10064-1-hch@lst.de>
 <20180730163824.10064-18-hch@lst.de>
 <556a4302d13b1caafb223112c4de43d959146215.camel@kernel.crashing.org>
 <777010cd04645b55aa4197eddcc880f010f0ef6d.camel@kernel.crashing.org>
In-Reply-To: <777010cd04645b55aa4197eddcc880f010f0ef6d.camel@kernel.crashing.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Christoph Hellwig <hch@lst.de>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Robin Murphy <robin.murphy@arm.com>, linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-ia64@vger.kernel.org

On Thu, Aug 09, 2018 at 11:57:53AM +1000, Benjamin Herrenschmidt wrote:
> Note: We will still need to implement some custom variant of this
> for our secure VMs ... 
> 
> Basically we'll need to use the existing bounce bufferring as-is but
> the condition will be different, it won't be whether the address is
> below a certain limit, it will be *always*.

The conditions are in the dma_capable() helper that the architecture
can override (and which powerpc already does override).
