From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 10 Dec 2018 21:51:13 +0000
Subject: Re: [RFC] avoid indirect calls for DMA direct mappings v2
Message-Id: <20181210215113.GA22180@agluck-desk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181207190720.18517-1-hch@lst.de>
In-Reply-To: <20181207190720.18517-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: iommu@lists.linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Tariq Toukan <tariqt@mellanox.com>, Ilias Apalodimas <ilias.apalodimas@linaro.org>, Toke =?iso-8859-1?Q?H=F8iland-J=F8rgensen?= <toke@toke.dk>, Robin Murphy <robin.murphy@arm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Fenghua Yu <fenghua.yu@intel.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Keith Busch <keith.busch@intel.com>, Jonathan Derrick <jonathan.derrick@intel.com>, linux-pci@vger.kernel.org, linux-ia64@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org

On Fri, Dec 07, 2018 at 11:07:05AM -0800, Christoph Hellwig wrote:
> This works is based on the dma-mapping tree, so you probably want to
> want this git tree for testing:
> 
>     git://git.infradead.org/users/hch/misc.git dma-direct-calls.2

Pulled this tree. Got HEAD

	33b9fc015171 ("dma-mapping: bypass indirect calls for dma-direct")

But the ia64 build fails with:

arch/ia64/mm/init.c:75:21: warning: 'enum dma_data_direction' declared inside parameter list [enabled by default]
arch/ia64/mm/init.c:75:21: warning: its scope is only this definition or declaration, which is probably not what you want [enabled by default]
arch/ia64/mm/init.c:75:40: error: parameter 4 ('dir') has incomplete type
arch/ia64/mm/init.c:74:6: error: function declaration isn't a prototype [-Werror=strict-prototypes]
arch/ia64/mm/init.c: In function 'arch_sync_dma_for_cpu':
arch/ia64/mm/init.c:77:2: error: implicit declaration of function '__phys_to_pfn' [-Werror=implicit-function-declaration]

-Tony
