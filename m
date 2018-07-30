From: Christoph Hellwig <hch@lst.de>
Date: Mon, 30 Jul 2018 16:38:04 +0000
Subject: use generic DMA mapping code in powerpc
Message-Id: <20180730163824.10064-1-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Robin Murphy <robin.murphy@arm.com>, linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-ia64@vger.kernel.org

Hi all,

this series switches the powerpc port to use the generic swiotlb
and noncoherent dma ops, and to use more generic code for the
coherent direct mapping, as well as removing dead code.
