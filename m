From: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Date: Tue, 01 Sep 2020 13:53:04 +0000
Subject: Re: [PATCH 08/28] MIPS: make dma_sync_*_for_cpu a little less overzealous
Message-Id: <20200901135304.GC11944@alpha.franken.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200819065555.1802761-1-hch@lst.de>
 <20200819065555.1802761-9-hch@lst.de>
In-Reply-To: <20200819065555.1802761-9-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: Mauro Carvalho Chehab <mchehab@kernel.org>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Joonyoung Shim <jy0922.shim@samsung.com>, Seung-Woo Kim <sw0312.kim@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Ben Skeggs <bskeggs@redhat.com>, Pawel Osciak <pawel@osciak.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Matt Porter <mporter@kernel.crashing.org>, iommu@lists.linux-foundation.org, Tom Lendacky <thomas.lendacky@amd.com>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linux-samsung-soc@vger.kernel.org, nouveau@lists.freedesktop.org, netdev@vger.kernel.org, linux-nvme@lists.infradead.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org, alsa-devel@alsa-project.org

On Wed, Aug 19, 2020 at 08:55:35AM +0200, Christoph Hellwig wrote:
> When transferring DMA ownership back to the CPU there should never
> be any writeback from the cache, as the buffer was owned by the
> device until now.  Instead it should just be invalidated for the
> mapping directions where the device could have written data.
> Note that the changes rely on the fact that kmap_atomic is stubbed
> out for the !HIGHMEM case to simplify the code a bit.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  arch/mips/mm/dma-noncoherent.c | 44 +++++++++++++++++++++-------------
>  1 file changed, 28 insertions(+), 16 deletions(-)

Acked-by: Thomas Bogendoerfer <tsbogend@alpha.franken.de>

-- 
Crap can work. Given enough thrust pigs will fly, but it's not necessarily a
good idea.                                                [ RFC1925, 2.3 ]
