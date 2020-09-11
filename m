From: Christoph Hellwig <hch@lst.de>
Date: Fri, 11 Sep 2020 07:10:09 +0000
Subject: Re: [PATCH 04/12] dma-mapping: fix DMA_OPS dependencies
Message-Id: <20200911071009.GC22394@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200908164758.3177341-1-hch@lst.de> <20200908164758.3177341-5-hch@lst.de> <8404208b-7276-914e-e4da-e65a907a5e9b@gmail.com>
In-Reply-To: <8404208b-7276-914e-e4da-e65a907a5e9b@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sergei Shtylyov <sergei.shtylyov@gmail.com>
Cc: Christoph Hellwig <hch@lst.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, iommu@lists.linux-foundation.org, Tomasz Figa <tfiga@chromium.org>, Joerg Roedel <joro@8bytes.org>, Robin Murphy <robin.murphy@arm.com>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org

On Tue, Sep 08, 2020 at 09:04:17PM +0300, Sergei Shtylyov wrote:
> Hello!
> 
> On 9/8/20 7:47 PM, Christoph Hellwig wrote:
> 
> > Driver that select DMA_OPS need to depend on HAS_DMA support to
> > work.  The vop driver was missing that dependency, so add it, and also
> > add a nother depends in DMA_OPS itself.  That won't fix the issue due
> 
>    Another? :-)

Yes, fixed.
