From: Christoph Hellwig <hch@lst.de>
Date: Wed, 10 Jan 2018 15:35:17 +0000
Subject: Re: [PATCH 08/22] swiotlb: wire up ->dma_supported in swiotlb_dma_ops
Message-Id: <20180110153517.GF17790@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180110080932.14157-1-hch@lst.de> <20180110080932.14157-9-hch@lst.de> <7a058876-08fc-7323-7cb3-fe85116e2ea8@arm.com>
In-Reply-To: <7a058876-08fc-7323-7cb3-fe85116e2ea8@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Robin Murphy <robin.murphy@arm.com>
Cc: Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org, linux-arch@vger.kernel.org, linux-mips@linux-mips.org, Michal Simek <monstr@monstr.eu>, linux-ia64@vger.kernel.org, Christian =?iso-8859-1?Q?K=F6nig?= <ckoenig.leichtzumerken@gmail.com>, x86@kernel.org, linux-kernel@vger.kernel.org, Konrad Rzeszutek Wilk <konrad@darnok.org>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org

On Wed, Jan 10, 2018 at 12:16:15PM +0000, Robin Murphy wrote:
> On 10/01/18 08:09, Christoph Hellwig wrote:
>> To properly reject too small DMA masks based on the addressability of the
>> bounce buffer.
>
> I reckon this is self-evident enough that it should simply be squashed into 
> the previous patch.

x86 didn't wire it up before, so I want a clear blaimpoint for this
change instead of mixing it up.
