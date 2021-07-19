From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Date: Mon, 19 Jul 2021 20:22:04 +0000
Subject: Re: [PATCH v1 13/16] xen: swiotlb: return error code from xen_swiotlb_map_sg()
Message-Id: <8cccf120-0b4b-4d66-0b96-4114af27a3d1@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210715164544.6827-1-logang@deltatee.com>
 <20210715164544.6827-14-logang@deltatee.com>
In-Reply-To: <20210715164544.6827-14-logang@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Logan Gunthorpe <logang@deltatee.com>, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, iommu@lists.linux-foundation.org, linux-parisc@vger.kernel.org, xen-devel@lists.xenproject.org
Cc: Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>, Stephen Bates <sbates@raithlin.com>, Martin Oliveira <martin.oliveira@eideticom.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Juergen Gross <jgross@suse.com>, Stefano Stabellini <sstabellini@kernel.org>


On 7/15/21 12:45 PM, Logan Gunthorpe wrote:
> From: Martin Oliveira <martin.oliveira@eideticom.com>
>
> The .map_sg() op now expects an error code instead of zero on failure.
>
> xen_swiotlb_map_sg() may only fail if xen_swiotlb_map_page() fails, but
> xen_swiotlb_map_page() only supports returning errors as
> DMA_MAPPING_ERROR. So coalesce all errors into EINVAL.


Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>


