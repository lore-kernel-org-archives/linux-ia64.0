From: Marek Szyprowski <m.szyprowski@samsung.com>
Date: Tue, 28 Sep 2021 10:11:33 +0000
Subject: Re: [PATCH] iommu/dma: Tidy up Kconfig selects
Message-Id: <e88879bf-cd4e-1018-da50-6f0a1dda4784@samsung.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <9ba6f2e8568a3ff6a94fade66668d99705433c44.1631536879.git.robin.murphy@arm.com>
        <CGME20210928093051eucas1p2fc69dc7b8dff175901ac2b00be6c33c7@eucas1p2.samsung.com>
        <YVLgw1nfEf7U13Mh@8bytes.org>
In-Reply-To: <YVLgw1nfEf7U13Mh@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joerg Roedel <joro@8bytes.org>, Robin Murphy <robin.murphy@arm.com>
Cc: will@kernel.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, x86@kernel.org, linux-ia64@vger.kernel.org

On 28.09.2021 11:30, Joerg Roedel wrote:
> On Mon, Sep 13, 2021 at 01:41:19PM +0100, Robin Murphy wrote:
>> Now that the dust has settled on converting all the x86 drivers to
>> iommu-dma, we can punt the Kconfig selection to arch code where it
>> was always intended to be.
> Can we select IOMMU_DMA under IOMMU_SUPPORT instead? The only drivers
> not using IOMMU_DMA are the arm32 ones, afaics.
>
> If we could get rid of the arm32 exception, the IOMMU_DMA symbol could
> also go away entirely and we handle it under IOMMU_SUPPORT instead. But
> that is something for the future :)

Maybe it would be a good motivation to get back to 
https://lore.kernel.org/linux-iommu/cover.1597931875.git.robin.murphy@arm.com/ 
:)

Best regards
-- 
Marek Szyprowski, PhD
Samsung R&D Institute Poland
