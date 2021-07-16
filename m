From: Christoph Hellwig <hch@lst.de>
Date: Fri, 16 Jul 2021 06:33:32 +0000
Subject: Re: [PATCH v1 16/16] dma-mapping: Disallow .map_sg operations from returning zero on error
Message-Id: <20210716063332.GD13345@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210715164544.6827-1-logang@deltatee.com> <20210715164544.6827-17-logang@deltatee.com>
In-Reply-To: <20210715164544.6827-17-logang@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Logan Gunthorpe <logang@deltatee.com>
Cc: linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, iommu@lists.linux-foundation.org, linux-parisc@vger.kernel.org, xen-devel@lists.xenproject.org, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>, Stephen Bates <sbates@raithlin.com>, Martin Oliveira <martin.oliveira@eideticom.com>

On Thu, Jul 15, 2021 at 10:45:44AM -0600, Logan Gunthorpe wrote:
> @@ -194,6 +194,8 @@ static int __dma_map_sg_attrs(struct device *dev, struct scatterlist *sg,
>  	else
>  		ents = ops->map_sg(dev, sg, nents, dir, attrs);
>  
> +	WARN_ON_ONCE(ents = 0);

Turns this into a negative error code while we're at it, just to keep
the callers sane?
