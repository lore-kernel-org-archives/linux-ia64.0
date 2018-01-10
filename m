From: Christoph Hellwig <hch@lst.de>
Date: Wed, 10 Jan 2018 15:29:45 +0000
Subject: Re: [PATCH 20/33] dma-mapping: clear harmful GFP_* flags in common code
Message-Id: <20180110152945.GC17790@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180110080027.13879-1-hch@lst.de> <20180110080027.13879-21-hch@lst.de> <27b90341-f9d0-356f-0194-1c7203a3f93e@arm.com>
In-Reply-To: <27b90341-f9d0-356f-0194-1c7203a3f93e@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Robin Murphy <robin.murphy@arm.com>
Cc: Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, x86@kernel.org, Konrad Rzeszutek Wilk <konrad@darnok.org>, linux-snps-arc@lists.infradead.org, linux-m68k@lists.linux-m68k.org, patches@groups.riscv.org, linux-metag@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Michal Simek <monstr@monstr.eu>, linux-parisc@vger.kernel.org, linux-cris-kernel@axis.com, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Wed, Jan 10, 2018 at 11:59:30AM +0000, Robin Murphy wrote:
> Just a note that if we're all happy to enshrine the "allocations are always 
> zeroed" behaviour in the API (I am too, for the record), we should remember 
> to follow up once the dust settles to update the docs and I guess just 
> #define dma_zalloc_coherent dma_alloc_coherent.

And then just remove it.  But yes, another item for the todo list..
