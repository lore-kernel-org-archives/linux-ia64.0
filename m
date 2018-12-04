From: Christoph Hellwig <hch@lst.de>
Date: Tue, 04 Dec 2018 16:16:40 +0000
Subject: merge swiotlb support into dma_direct_ops
Message-Id: <20181204161645.8038-1-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>, linux-ia64@vger.kernel.org, iommu@lists.linux-foundation.org, x86@kernel.org, linux-kernel@vger.kernel.org

Hi Konrad and others,

can you review this series?  It merges the swiotlb support into the
DMA direct ops so that we don't have to duplicate the dma mapping logic
in multiple places.

Note that this is based on the dma_mapping_error series for which I'd
still like to collect a few more reviews, so pulling the git tree might
be easiest for testing.

The git tree is available here:

    git://git.infradead.org/users/hch/misc.git swiotlb-merge

Gitweb:

    http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/swiotlb-merge
