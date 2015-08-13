From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Date: Thu, 13 Aug 2015 15:25:05 +0000
Subject: Re: [PATCH 5/5] dma-mapping: consolidate dma_set_mask
Message-Id: <20150813152505.GR7557@n2100.arm.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <1439478248-15183-1-git-send-email-hch@lst.de>
 <1439478248-15183-6-git-send-email-hch@lst.de>
In-Reply-To: <1439478248-15183-6-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: akpm@linux-foundation.org, arnd@arndb.de, catalin.marinas@arm.com, will.deacon@arm.com, ysato@users.sourceforge.jp, monstr@monstr.eu, jonas@southpole.se, cmetcalf@ezchip.com, gxt@mprc.pku.edu.cn, x86@kernel.org, linux-alpha@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Aug 13, 2015 at 05:04:08PM +0200, Christoph Hellwig wrote:
> diff --git a/arch/arm/common/dmabounce.c b/arch/arm/common/dmabounce.c
> index 1143c4d..260f52a 100644
> --- a/arch/arm/common/dmabounce.c
> +++ b/arch/arm/common/dmabounce.c
> @@ -440,14 +440,6 @@ static void dmabounce_sync_for_device(struct device *dev,
>  	arm_dma_ops.sync_single_for_device(dev, handle, size, dir);
>  }
>  
> -static int dmabounce_set_mask(struct device *dev, u64 dma_mask)
> -{
> -	if (dev->archdata.dmabounce)
> -		return 0;
> -
> -	return arm_dma_ops.set_dma_mask(dev, dma_mask);

Are you sure about this?  A user of dmabounce gets to request any mask
with the original code (even though it was never written back... which
is a separate bug.)  After this, it seems that this will get limited
by the dma_supported() check.  As this old code is about bouncing any
buffer into DMA-able memory, it doesn't care about the DMA mask.

-- 
FTTC broadband for 0.8mile line: currently at 10.5Mbps down 400kbps up
according to speedtest.net.
