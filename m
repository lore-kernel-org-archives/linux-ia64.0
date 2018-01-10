From: Christoph Hellwig <hch@lst.de>
Date: Wed, 10 Jan 2018 15:22:15 +0000
Subject: Re: [PATCH 11/33] dma-mapping: move swiotlb arch helpers to a new header
Message-Id: <20180110152215.GA17790@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180110080027.13879-1-hch@lst.de> <20180110080027.13879-12-hch@lst.de> <b2bd6f4b-a932-5251-517b-83bbccfe7c53@arm.com>
In-Reply-To: <b2bd6f4b-a932-5251-517b-83bbccfe7c53@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Vladimir Murzin <vladimir.murzin@arm.com>
Cc: Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, x86@kernel.org, Konrad Rzeszutek Wilk <konrad@darnok.org>, linux-snps-arc@lists.infradead.org, linux-m68k@lists.linux-m68k.org, patches@groups.riscv.org, linux-metag@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Michal Simek <monstr@monstr.eu>, linux-parisc@vger.kernel.org, linux-cris-kernel@axis.com, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Wed, Jan 10, 2018 at 09:31:45AM +0000, Vladimir Murzin wrote:
> I know it is copy&paste, but it seems it has off by one error and it should be
> 
> return addr + size - 1 <= *dev->dma_mask;

I've added a new patch to fix the mips dma_capable() definition,
thanks.
