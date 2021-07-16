From: Robin Murphy <robin.murphy@arm.com>
Date: Fri, 16 Jul 2021 12:19:23 +0000
Subject: Re: [PATCH v1 16/16] dma-mapping: Disallow .map_sg operations from returning zero on error
Message-Id: <21b7f2f1-ccac-4567-6933-a258dcad7099@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210715164544.6827-1-logang@deltatee.com>
 <20210715164544.6827-17-logang@deltatee.com> <20210716063332.GD13345@lst.de>
In-Reply-To: <20210716063332.GD13345@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>, Logan Gunthorpe <logang@deltatee.com>
Cc: linux-s390@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, Martin Oliveira <martin.oliveira@eideticom.com>, linux-mips@vger.kernel.org, linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org, linux-alpha@vger.kernel.org, sparclinux@vger.kernel.org, xen-devel@lists.xenproject.org, Stephen Bates <sbates@raithlin.com>, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org

On 2021-07-16 07:33, Christoph Hellwig wrote:
> On Thu, Jul 15, 2021 at 10:45:44AM -0600, Logan Gunthorpe wrote:
>> @@ -194,6 +194,8 @@ static int __dma_map_sg_attrs(struct device *dev, struct scatterlist *sg,
>>   	else
>>   		ents = ops->map_sg(dev, sg, nents, dir, attrs);
>>   
>> +	WARN_ON_ONCE(ents = 0);
> 
> Turns this into a negative error code while we're at it, just to keep
> the callers sane?

Right, by this point returning the 0 would pass through 
dma_map_sg_attrs() OK, but AFAICS dma_map_sgtable() would now get 
confused and return success but with sgt->nents = 0. Coercing it to an 
error code (which dma_map_sg_attrs() would then just change right back) 
seems sensible for the sake of easy robustness.

Robin.
