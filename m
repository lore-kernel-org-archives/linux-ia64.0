From: Christoph Hellwig <hch@lst.de>
Date: Fri, 16 Jul 2021 06:29:28 +0000
Subject: Re: [PATCH v1 01/16] dma-mapping: Allow map_sg() ops to return negative error codes
Message-Id: <20210716062928.GA13345@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210715164544.6827-1-logang@deltatee.com> <20210715164544.6827-2-logang@deltatee.com>
In-Reply-To: <20210715164544.6827-2-logang@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Logan Gunthorpe <logang@deltatee.com>
Cc: linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, iommu@lists.linux-foundation.org, linux-parisc@vger.kernel.org, xen-devel@lists.xenproject.org, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>, Stephen Bates <sbates@raithlin.com>, Martin Oliveira <martin.oliveira@eideticom.com>

On Thu, Jul 15, 2021 at 10:45:29AM -0600, Logan Gunthorpe wrote:
> +	 * dma_map_sgtable() will return the error code returned and convert
> +	 * a zero return (for legacy implementations) into -EINVAL.
> +	 *
> +	 * dma_map_sg() will always return zero on any negative or zero
> +	 * return to satisfy its own calling convention.
>  	 */

I don't think this belongs here.

> +EXPORT_SYMBOL(dma_map_sgtable);

EXPORT_SYMBOL_GPL, please.
