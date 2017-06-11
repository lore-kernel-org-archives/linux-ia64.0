From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Date: Sun, 11 Jun 2017 02:36:44 +0000
Subject: Re: [PATCH 07/44] xen-swiotlb: consolidate xen_swiotlb_dma_ops
Message-Id: <20170611023644.GE30966@char.us.oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170608132609.32662-1-hch@lst.de>
 <20170608132609.32662-8-hch@lst.de>
In-Reply-To: <20170608132609.32662-8-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: linux-mips@linux-mips.org, linux-samsung-soc@vger.kernel.org, linux-ia64@vger.kernel.org, linux-c6x-dev@linux-c6x.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-xtensa@linux-xtensa.org, x86@kernel.org, linux-tegra@vger.kernel.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, dmaengine@vger.kernel.org, iommu@lists.linux-foundation.org, openrisc@lists.librecores.org, netdev@vger.kernel.org, sparclinux@vger.kernel.org, xen-devel@lists.xenproject.org, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org

On Thu, Jun 08, 2017 at 03:25:32PM +0200, Christoph Hellwig wrote:
> ARM and x86 had duplicated versions of the dma_ops structure, the
> only difference is that x86 hasn't wired up the set_dma_mask,
> mmap, and get_sgtable ops yet.  On x86 all of them are identical
> to the generic version, so they aren't needed but harmless.
> 
> All the symbols used only for xen_swiotlb_dma_ops can now be marked
> static as well.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  arch/arm/xen/mm.c              | 17 --------
>  arch/x86/xen/pci-swiotlb-xen.c | 14 -------
>  drivers/xen/swiotlb-xen.c      | 93 ++++++++++++++++++++++--------------------
>  include/xen/swiotlb-xen.h      | 62 +---------------------------
>  4 files changed, 49 insertions(+), 137 deletions(-)

Yeeey!

Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
