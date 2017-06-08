From: David Miller <davem@davemloft.net>
Date: Thu, 08 Jun 2017 14:24:05 +0000
Subject: Re: [PATCH 28/44] sparc: remove arch specific dma_supported implementations
Message-Id: <20170608.102405.746234218675861415.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170608132609.32662-1-hch@lst.de>
 <20170608132609.32662-29-hch@lst.de>
In-Reply-To: <20170608132609.32662-29-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hch@lst.de
Cc: linux-mips@linux-mips.org, linux-samsung-soc@vger.kernel.org, linux-ia64@vger.kernel.org, linux-c6x-dev@linux-c6x.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-xtensa@linux-xtensa.org, x86@kernel.org, linux-tegra@vger.kernel.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, dmaengine@vger.kernel.org, iommu@lists.linux-foundation.org, openrisc@lists.librecores.org, netdev@vger.kernel.org, sparclinux@vger.kernel.org, xen-devel@lists.xenproject.org, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org

From: Christoph Hellwig <hch@lst.de>
Date: Thu,  8 Jun 2017 15:25:53 +0200

> Usually dma_supported decisions are done by the dma_map_ops instance.
> Switch sparc to that model by providing a ->dma_supported instance for
> sbus that always returns false, and implementations tailored to the sun4u
> and sun4v cases for sparc64, and leave it unimplemented for PCI on
> sparc32, which means always supported.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Acked-by: David S. Miller <davem@davemloft.net>
