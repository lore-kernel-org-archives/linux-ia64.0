From: Christoph Hellwig <hch@lst.de>
Date: Fri, 11 Sep 2020 07:15:19 +0000
Subject: Re: [PATCH 11/12] dma-mapping: move dma_common_{mmap,get_sgtable} out of mapping.c
Message-Id: <20200911071519.GF22394@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200908164758.3177341-1-hch@lst.de> <20200908164758.3177341-12-hch@lst.de> <88bae26e-d5f4-7a00-a88a-b69194d519a4@arm.com>
In-Reply-To: <88bae26e-d5f4-7a00-a88a-b69194d519a4@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Robin Murphy <robin.murphy@arm.com>
Cc: Christoph Hellwig <hch@lst.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, iommu@lists.linux-foundation.org, Tomasz Figa <tfiga@chromium.org>, Joerg Roedel <joro@8bytes.org>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org

On Thu, Sep 10, 2020 at 02:34:18PM +0100, Robin Murphy wrote:
> On 2020-09-08 17:47, Christoph Hellwig wrote:
>> Add a new file that contains helpera for misc DMA ops, which is only
>
> The Latin plural of the singular "helperum", I guess? :P

I've switched it to helpers, that might be easier to understand :)
