From: Andreas Larsson <andreas@gaisler.com>
Date: Mon, 12 Jun 2017 08:06:26 +0000
Subject: Re: [PATCH 27/44] sparc: remove leon_dma_ops
Message-Id: <593E4B82.70306@gaisler.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170608132609.32662-1-hch@lst.de> <20170608132609.32662-28-hch@lst.de>
In-Reply-To: <20170608132609.32662-28-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>, x86@kernel.org, linux-arm-kernel@lists.infradead.org, xen-devel@lists.xenproject.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, openrisc@lists.librecores.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, dmaengine@vger.kernel.org, linux-tegra@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org, netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org

On 2017-06-08 15:25, Christoph Hellwig wrote:
> We can just use pci32_dma_ops.
>
> Btw, given that leon is 32-bit and appears to be PCI based, do even need
> the special case for it in get_arch_dma_ops at all?

Hi!

Yes, it is needed. LEON systems are AMBA bus based. The common case here 
is DMA over AMBA buses. Some LEON systems have PCI bridges, but in 
general CONFIG_PCI is not a given.

-- 
Andreas Larsson
Software Engineer
Cobham Gaisler
