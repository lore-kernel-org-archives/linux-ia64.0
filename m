From: Robin Murphy <robin.murphy@arm.com>
Date: Tue, 20 Jun 2017 13:14:36 +0000
Subject: Re: new dma-mapping tree, was Re: clean up and modularize arch dma_mapping interface V2
Message-Id: <6025d4d4-1975-9598-c16d-26d17d029ec7@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170620124140.GA27163@lst.de>
In-Reply-To: <20170620124140.GA27163@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>, Stephen Rothwell <sfr@canb.auug.org.au>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, linux-arm-kernel@lists.infradead.org, xen-devel@lists.xenproject.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, openrisc@lists.librecores.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, dmaengine@vger.kernel.org, linux-tegra@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org, netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org

Hi Christoph,

On 20/06/17 13:41, Christoph Hellwig wrote:
> On Fri, Jun 16, 2017 at 08:10:15PM +0200, Christoph Hellwig wrote:
>> I plan to create a new dma-mapping tree to collect all this work.
>> Any volunteers for co-maintainers, especially from the iommu gang?
> 
> Ok, I've created the new tree:
> 
>    git://git.infradead.org/users/hch/dma-mapping.git for-next
> 
> Gitweb:
> 
>    http://git.infradead.org/users/hch/dma-mapping.git/shortlog/refs/heads/for-next
> 
> And below is the patch to add the MAINTAINERS entry, additions welcome.

I'm happy to be a reviewer, since I've been working in this area for
some time, particularly with the dma-iommu code and arm64 DMA ops.

Robin.

> Stephen, can you add this to linux-next?
> 
> ---
> From 335979c41912e6c101a20b719862b2d837370df1 Mon Sep 17 00:00:00 2001
> From: Christoph Hellwig <hch@lst.de>
> Date: Tue, 20 Jun 2017 11:17:30 +0200
> Subject: MAINTAINERS: add entry for dma mapping helpers
> 
> This code has been spread between getting in through arch trees, the iommu
> tree, -mm and the drivers tree.  There will be a lot of work in this area,
> including consolidating various arch implementations into more common
> code, so ensure we have a proper git tree that facilitates cooperation with
> the architecture maintainers.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  MAINTAINERS | 13 +++++++++++++
>  1 file changed, 13 insertions(+)
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 09b5ab6a8a5c..56859d53a424 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -2595,6 +2595,19 @@ S:	Maintained
>  F:	net/bluetooth/
>  F:	include/net/bluetooth/
>  
> +DMA MAPPING HELPERS
> +M:	Christoph Hellwig <hch@lst.de>
> +L:	linux-kernel@vger.kernel.org
> +T:	git git://git.infradead.org/users/hch/dma-mapping.git
> +W:	http://git.infradead.org/users/hch/dma-mapping.git
> +S:	Supported
> +F:	lib/dma-debug.c
> +F:	lib/dma-noop.c
> +F:	lib/dma-virt.c
> +F:	drivers/base/dma-mapping.c
> +F:	drivers/base/dma-coherent.c
> +F:	include/linux/dma-mapping.h
> +
>  BONDING DRIVER
>  M:	Jay Vosburgh <j.vosburgh@gmail.com>
>  M:	Veaceslav Falico <vfalico@gmail.com>
> 

