From: Joerg Roedel <joro@8bytes.org>
Date: Tue, 28 Sep 2021 09:30:43 +0000
Subject: Re: [PATCH] iommu/dma: Tidy up Kconfig selects
Message-Id: <YVLgw1nfEf7U13Mh@8bytes.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <9ba6f2e8568a3ff6a94fade66668d99705433c44.1631536879.git.robin.murphy@arm.com>
In-Reply-To: <9ba6f2e8568a3ff6a94fade66668d99705433c44.1631536879.git.robin.murphy@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Robin Murphy <robin.murphy@arm.com>
Cc: will@kernel.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, x86@kernel.org, linux-ia64@vger.kernel.org

On Mon, Sep 13, 2021 at 01:41:19PM +0100, Robin Murphy wrote:
> Now that the dust has settled on converting all the x86 drivers to
> iommu-dma, we can punt the Kconfig selection to arch code where it
> was always intended to be.

Can we select IOMMU_DMA under IOMMU_SUPPORT instead? The only drivers
not using IOMMU_DMA are the arm32 ones, afaics.

If we could get rid of the arm32 exception, the IOMMU_DMA symbol could
also go away entirely and we handle it under IOMMU_SUPPORT instead. But
that is something for the future :)

Regards,

	Joerg
