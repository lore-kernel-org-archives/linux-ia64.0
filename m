From: Robin Murphy <robin.murphy@arm.com>
Date: Wed, 10 Jan 2018 17:23:08 +0000
Subject: Re: [PATCH 08/22] swiotlb: wire up ->dma_supported in swiotlb_dma_ops
Message-Id: <5b14af5b-e6e9-17c5-d433-f50ccb466f90@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180110080932.14157-1-hch@lst.de>
 <20180110080932.14157-9-hch@lst.de>
 <7a058876-08fc-7323-7cb3-fe85116e2ea8@arm.com>
 <20180110153517.GF17790@lst.de>
In-Reply-To: <20180110153517.GF17790@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: iommu@lists.linux-foundation.org, linux-arch@vger.kernel.org, linux-mips@linux-mips.org, Michal Simek <monstr@monstr.eu>, linux-ia64@vger.kernel.org, =?UTF-8?Q?Christian_K=c3=b6nig?= <ckoenig.leichtzumerken@gmail.com>, x86@kernel.org, linux-kernel@vger.kernel.org, Konrad Rzeszutek Wilk <konrad@darnok.org>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org

On 10/01/18 15:35, Christoph Hellwig wrote:
> On Wed, Jan 10, 2018 at 12:16:15PM +0000, Robin Murphy wrote:
>> On 10/01/18 08:09, Christoph Hellwig wrote:
>>> To properly reject too small DMA masks based on the addressability of the
>>> bounce buffer.
>>
>> I reckon this is self-evident enough that it should simply be squashed into
>> the previous patch.
> 
> x86 didn't wire it up before, so I want a clear blaimpoint for this
> change instead of mixing it up.
That almost makes sense, if x86 were using this generic swiotlb_dma_ops 
already. AFAICS it's only ia64, unicore and tile who end up using it, 
and they all had swiotlb_dma_supported hooked up to begin with. Am I 
missing something?

If regressions are going to happen, they'll surely point at whichever 
commit pulls the ops into the relevant arch code - there doesn't seem to 
be a great deal of value in having a piecemeal history of said ops 
*before* that point.

Robin.
