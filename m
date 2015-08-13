From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Date: Thu, 13 Aug 2015 15:20:40 +0000
Subject: Re: [PATCH 2/5] dma-mapping: consolidate dma_{alloc,free}_noncoherent
Message-Id: <20150813152040.GQ7557@n2100.arm.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <1439478248-15183-1-git-send-email-hch@lst.de>
 <1439478248-15183-3-git-send-email-hch@lst.de>
In-Reply-To: <1439478248-15183-3-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: akpm@linux-foundation.org, arnd@arndb.de, catalin.marinas@arm.com, will.deacon@arm.com, ysato@users.sourceforge.jp, monstr@monstr.eu, jonas@southpole.se, cmetcalf@ezchip.com, gxt@mprc.pku.edu.cn, x86@kernel.org, linux-alpha@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Aug 13, 2015 at 05:04:05PM +0200, Christoph Hellwig wrote:
> diff --git a/arch/arm/include/asm/dma-mapping.h b/arch/arm/include/asm/dma-mapping.h
> index 2ae3424..ab521d5 100644
> --- a/arch/arm/include/asm/dma-mapping.h
> +++ b/arch/arm/include/asm/dma-mapping.h
> @@ -175,21 +175,6 @@ static inline int dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
>  	return dma_addr = DMA_ERROR_CODE;
>  }
>  
> -/*
> - * Dummy noncoherent implementation.  We don't provide a dma_cache_sync
> - * function so drivers using this API are highlighted with build warnings.
> - */

I'd like a similar comment to remain after this patch explaining that we
don't support non-coherent allocations and that it'll be highlighted by
the lack of dma_cache_sync, otherwise I'm sure we'll start to get patches
to add the thing.

-- 
FTTC broadband for 0.8mile line: currently at 10.5Mbps down 400kbps up
according to speedtest.net.
