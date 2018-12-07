From: Christoph Hellwig <hch@lst.de>
Date: Fri, 07 Dec 2018 19:07:05 +0000
Subject: [RFC] avoid indirect calls for DMA direct mappings v2
Message-Id: <20181207190720.18517-1-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Tariq Toukan <tariqt@mellanox.com>, Ilias Apalodimas <ilias.apalodimas@linaro.org>, =?UTF-8?q?Toke=20H=C3=B8iland-J=C3=B8rgensen?= <toke@toke.dk>, Robin Murphy <robin.murphy@arm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Keith Busch <keith.busch@intel.com>, Jonathan Derrick <jonathan.derrick@intel.com>, linux-pci@vger.kernel.org, linux-ia64@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org

Hi all,

a while ago Jesper reported major performance regressions due to the
spectre v2 mitigations in his XDP forwarding workloads.  A large part
of that is due to the DMA mapping API indirect calls.

It turns out that the most common implementation of the DMA API is the
direct mapping case, and now that we have merged almost all duplicate
implementations of that into a single generic one is easily feasily to
direct calls for this fast path.

This series adds consolidate the DMA mapping code by merging the
swiotlb case into the dma direct case, and then treats NULL dma_ops
as an indicator that that we should directly call the direct mapping
case.  This recovers a large part of the retpoline induces XDP slowdown.

This works is based on the dma-mapping tree, so you probably want to
want this git tree for testing:

    git://git.infradead.org/users/hch/misc.git dma-direct-calls.2

Gitweb:

    http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/dma-direct-calls.2

Changes since v1:
 - now also includes all the prep patches relative to the dma-mapping
   for-next tree
 - move various slow path functions out of line
 - use a NULL dma ops as the indicate to use the direct mapping path
 - remove dma_direct_ops now that we always call it without the indirection
 - move the dummy dma ops to common code
 - explicitly st the dummy dma ops for devices that are indicates as not
   DMA capable by firmware
