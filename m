From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Date: Sun, 11 Jun 2017 02:37:26 +0000
Subject: Re: [PATCH 08/44] xen-swiotlb: implement ->mapping_error
Message-Id: <20170611023726.GF30966@char.us.oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170608132609.32662-1-hch@lst.de>
 <20170608132609.32662-9-hch@lst.de>
In-Reply-To: <20170608132609.32662-9-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: linux-mips@linux-mips.org, linux-samsung-soc@vger.kernel.org, linux-ia64@vger.kernel.org, linux-c6x-dev@linux-c6x.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-xtensa@linux-xtensa.org, x86@kernel.org, linux-tegra@vger.kernel.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, dmaengine@vger.kernel.org, iommu@lists.linux-foundation.org, openrisc@lists.librecores.org, netdev@vger.kernel.org, sparclinux@vger.kernel.org, xen-devel@lists.xenproject.org, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org

On Thu, Jun 08, 2017 at 03:25:33PM +0200, Christoph Hellwig wrote:
> DMA_ERROR_CODE is going to go away, so don't rely on it.

Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
