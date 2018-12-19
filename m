From: Christoph Hellwig <hch@lst.de>
Date: Wed, 19 Dec 2018 06:42:06 +0000
Subject: Re: [15/15] dma-mapping: bypass indirect calls for dma-direct
Message-Id: <20181219064206.GA27018@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181207190720.18517-16-hch@lst.de> <2e779fa7-dc9f-7ed8-252a-5d20c5deca9c@collabora.com> <92096de9-7183-dbe8-2169-0143190591fa@arm.com>
In-Reply-To: <92096de9-7183-dbe8-2169-0143190591fa@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Robin Murphy <robin.murphy@arm.com>
Cc: Guillaume Tucker <guillaume.tucker@collabora.com>, Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Tariq Toukan <tariqt@mellanox.com>, Ilias Apalodimas <ilias.apalodimas@linaro.org>, Toke =?iso-8859-1?Q?H=F8iland-J=F8rgensen?= <toke@toke.dk>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Keith Busch <keith.busch@intel.com>, Jonathan Derrick <jonathan.derrick@intel.com>, linux-pci@vger.kernel.org, linux-ia64@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, ezequiel Garcia <ezequiel@collabora.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Tue, Dec 18, 2018 at 08:42:46PM +0000, Robin Murphy wrote:
>> [   16.046084] rk_iommu ff8f3f00.iommu: DMA map error for DT
>
> Yup, with this patch as-is, anything which isn't behind an IOMMU will be 
> erroneously banned from DMA entirely - see here:
>
> https://lore.kernel.org/lkml/20181214142435.GA18448@lst.de/

FYI, I'm still waiting for a review on that..
