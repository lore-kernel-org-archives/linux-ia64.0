From: Christoph Hellwig <hch@lst.de>
Date: Sat, 08 Dec 2018 16:50:58 +0000
Subject: Re: [RFC] avoid indirect calls for DMA direct mappings v2
Message-Id: <20181208165058.GA14874@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181207190720.18517-1-hch@lst.de> <20181208170648.296fb8a1@redhat.com>
In-Reply-To: <20181208170648.296fb8a1@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Tariq Toukan <tariqt@mellanox.com>, Ilias Apalodimas <ilias.apalodimas@linaro.org>, Toke =?iso-8859-1?Q?H=F8iland-J=F8rgensen?= <toke@toke.dk>, Robin Murphy <robin.murphy@arm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Keith Busch <keith.busch@intel.com>, Jonathan Derrick <jonathan.derrick@intel.com>, linux-pci@vger.kernel.org, linux-ia64@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org

On Sat, Dec 08, 2018 at 05:06:48PM +0100, Jesper Dangaard Brouer wrote:
> You can add my:
>  Tested-by: Jesper Dangaard Brouer <brouer@redhat.com>
> or
>  Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>
> 
> I'm very happy that you work on this.  And I've done micro-benchmark
> testing of the patchset (and branch dma-direct-calls), which I've made
> avail here:
>  https://github.com/xdp-project/xdp-project/blob/master/areas/dma/dma01_test_hellwig_direct_dma.org
> 
> My XDP performance is back, minus the BPF-indirect call, and
> net_rx_action napi->poll, and net_device->ndo_xdp_xmit calls.  I
> verified that manually disabling retpoline for these remaining netstack
> retpoline-calls restore the performance full (well minus 1.5 nanosec).

Thanks a lot for all the testing (and the initial report).  I'd love to
still gets this in for 4.21 if we can, but for that I'd need a lot
more folks to carefull review it, especially the swiotlb and ia64 bits.
So if we don't get that early next week I feel we might have to punt
it to the next merge window.
