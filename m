From: Christoph Hellwig <hch@lst.de>
Date: Sun, 25 Jul 2021 06:07:47 +0000
Subject: Re: [PATCH v2 01/21] dma-mapping: Allow map_sg() ops to return negative error codes
Message-Id: <20210725060747.GA10852@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210723175008.22410-1-logang@deltatee.com> <20210723175008.22410-2-logang@deltatee.com>
In-Reply-To: <20210723175008.22410-2-logang@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Logan Gunthorpe <logang@deltatee.com>
Cc: linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, iommu@lists.linux-foundation.org, linux-parisc@vger.kernel.org, xen-devel@lists.xenproject.org, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>, Stephen Bates <sbates@raithlin.com>, Martin Oliveira <martin.oliveira@eideticom.com>

> +int dma_map_sgtable(struct device *dev, struct sg_table *sgt,
> +		    enum dma_data_direction dir, unsigned long attrs)
> +{
> +	int nents;
> +
> +	nents = __dma_map_sg_attrs(dev, sgt->sgl, sgt->orig_nents, dir, attrs);
> +	if (nents = 0)
> +		return -EIO;
> +	else if (nents < 0) {
> +		if (WARN_ON_ONCE(nents != -EINVAL && nents != -ENOMEM &&
> +				 nents != -EIO))
> +			return -EIO;

I think this validation of the errnos needs to go into __dma_map_sg_attrs,
so that we catch it for the classic dma_map_sg callers as well.
