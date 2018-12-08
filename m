From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Sat, 08 Dec 2018 16:06:48 +0000
Subject: Re: [RFC] avoid indirect calls for DMA direct mappings v2
Message-Id: <20181208170648.296fb8a1@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181207190720.18517-1-hch@lst.de>
In-Reply-To: <20181207190720.18517-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: iommu@lists.linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Tariq Toukan <tariqt@mellanox.com>, Ilias Apalodimas <ilias.apalodimas@linaro.org>, Toke =?UTF-8?B?SMO4aWxhbmQtSsO4?= =?UTF-8?B?cmdlbnNlbg==?= <toke@toke.dk>, Robin Murphy <robin.murphy@arm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Keith Busch <keith.busch@intel.com>, Jonathan Derrick <jonathan.derrick@intel.com>, linux-pci@vger.kernel.org, linux-ia64@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, brouer@redhat.com

On Fri,  7 Dec 2018 11:07:05 -0800
Christoph Hellwig <hch@lst.de> wrote:

> Hi all,
> 
> a while ago Jesper reported major performance regressions due to the
> spectre v2 mitigations in his XDP forwarding workloads.  A large part
> of that is due to the DMA mapping API indirect calls.
> 
> It turns out that the most common implementation of the DMA API is the
> direct mapping case, and now that we have merged almost all duplicate
> implementations of that into a single generic one is easily feasily to
> direct calls for this fast path.
> 
> This series adds consolidate the DMA mapping code by merging the
> swiotlb case into the dma direct case, and then treats NULL dma_ops
> as an indicator that that we should directly call the direct mapping
> case.  This recovers a large part of the retpoline induces XDP slowdown.
> 
> This works is based on the dma-mapping tree, so you probably want to
> want this git tree for testing:
> 
>     git://git.infradead.org/users/hch/misc.git dma-direct-calls.2
> 
> Gitweb:
> 
>     http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/dma-direct-calls.2

You can add my:
 Tested-by: Jesper Dangaard Brouer <brouer@redhat.com>
or
 Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

I'm very happy that you work on this.  And I've done micro-benchmark
testing of the patchset (and branch dma-direct-calls), which I've made
avail here:
 https://github.com/xdp-project/xdp-project/blob/master/areas/dma/dma01_test_hellwig_direct_dma.org

My XDP performance is back, minus the BPF-indirect call, and
net_rx_action napi->poll, and net_device->ndo_xdp_xmit calls.  I
verified that manually disabling retpoline for these remaining netstack
retpoline-calls restore the performance full (well minus 1.5 nanosec).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
