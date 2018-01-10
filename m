From: Christoph Hellwig <hch@lst.de>
Date: Wed, 10 Jan 2018 07:59:54 +0000
Subject: consolidate direct dma mapping V3
Message-Id: <20180110080027.13879-1-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, x86@kernel.org, Konrad Rzeszutek Wilk <konrad@darnok.org>, linux-snps-arc@lists.infradead.org, linux-m68k@lists.linux-m68k.org, patches@groups.riscv.org, linux-metag@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Michal Simek <monstr@monstr.eu>, linux-parisc@vger.kernel.org, linux-cris-kernel@axis.com, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

Almost every architecture supports a direct dma mapping implementation,
where no iommu is used and the device dma address is a 1:1 mapping to
the physical address or has a simple linear offset.  Currently the
code for this implementation is most duplicated over the architectures,
and the duplicated again in the swiotlb code, and then duplicated again
for special cases like the x86 memory encryption DMA ops.

This series takes the existing very simple dma-noop dma mapping
implementation, enhances it with all the x86 features and quirks, and
creates a common set of architecture hooks for it and the swiotlb code.

It then switches a number of architectures to this generic
direct map implemention.

Note that for now this only handles architectures that do cache coherent
DMA, but a similar consolidation for non-coherent architectures is in the
work for later merge windows.

A git tree is also available:

   git://git.infradead.org/users/hch/misc.git dma-direct.3

Gitweb:

   http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/dma-direct.3

Changes since V1:
 - fixed a few patch description typos
 - fixed a few printk formats
 - fixed an off by one in dma_coherent_ok
 - add a few Reviewed-by/Acked-by tags.
 - moved the swiotlb consolidation to a new series
 - dropped a few patches for now to not overwhelem the x86
   maintainers.  They will be resubmitted in the next merge window
