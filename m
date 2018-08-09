From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 09 Aug 2018 00:01:16 +0000
Subject: Re: [PATCH 08/20] powerpc/dma: remove the unused dma_nommu_ops export
Message-Id: <f7daffa5481ab82f345aa5bf9f63f40caa068456.camel@kernel.crashing.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180730163824.10064-1-hch@lst.de>
 <20180730163824.10064-9-hch@lst.de> <20180731121625.GA29793@lst.de>
In-Reply-To: <20180731121625.GA29793@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-ia64@vger.kernel.org, Robin Murphy <robin.murphy@arm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On Tue, 2018-07-31 at 14:16 +0200, Christoph Hellwig wrote:
> It turns out cxl actually uses it.  So for now skip this patch,
> although random code in drivers messing with dma ops will need to
> be sorted out sooner or later.

CXL devices are "special", they bypass the classic iommu in favor of
allowing the device to operate using the main processor page tables
using an MMU context (so basically the device can use userspace
addresses directly), akin to ATS.

I think the code currently uses the nommu ops as a way to do a simple
kernel mapping for kernel drivers using CXL (not userspace stuff)
though.

Ben.


