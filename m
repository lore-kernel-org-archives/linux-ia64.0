From: Christoph Hellwig <hch@lst.de>
Date: Tue, 31 Jul 2018 12:16:25 +0000
Subject: Re: [PATCH 08/20] powerpc/dma: remove the unused dma_nommu_ops export
Message-Id: <20180731121625.GA29793@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180730163824.10064-1-hch@lst.de>
 <20180730163824.10064-9-hch@lst.de>
In-Reply-To: <20180730163824.10064-9-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-ia64@vger.kernel.org, Robin Murphy <robin.murphy@arm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

It turns out cxl actually uses it.  So for now skip this patch,
although random code in drivers messing with dma ops will need to
be sorted out sooner or later.
