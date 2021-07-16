From: Logan Gunthorpe <logang@deltatee.com>
Date: Fri, 16 Jul 2021 16:17:58 +0000
Subject: Re: [PATCH v1 16/16] dma-mapping: Disallow .map_sg operations from returning zero on error
Message-Id: <82c0f8d8-9050-dcf7-d68d-93691878a6dd@deltatee.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210715164544.6827-1-logang@deltatee.com>
 <20210715164544.6827-17-logang@deltatee.com> <20210716063332.GD13345@lst.de>
In-Reply-To: <20210716063332.GD13345@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, iommu@lists.linux-foundation.org, linux-parisc@vger.kernel.org, xen-devel@lists.xenproject.org, Marek Szyprowski <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>, Stephen Bates <sbates@raithlin.com>, Martin Oliveira <martin.oliveira@eideticom.com>



On 2021-07-16 12:33 a.m., Christoph Hellwig wrote:
> On Thu, Jul 15, 2021 at 10:45:44AM -0600, Logan Gunthorpe wrote:
>> @@ -194,6 +194,8 @@ static int __dma_map_sg_attrs(struct device *dev, struct scatterlist *sg,
>>  	else
>>  		ents = ops->map_sg(dev, sg, nents, dir, attrs);
>>  
>> +	WARN_ON_ONCE(ents = 0);
> 
> Turns this into a negative error code while we're at it, just to keep
> the callers sane?
> 

Sure thing. All the feedback makes sense, we'll fix it up and send a v2
in due course.

Thanks,

Logan
