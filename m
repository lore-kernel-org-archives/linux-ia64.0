From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Date: Thu, 08 Jun 2017 16:23:11 +0000
Subject: Re: [PATCH 19/44] s390: implement ->mapping_error
Message-Id: <20170608182311.05cced9e@thinkpad>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170608132609.32662-1-hch@lst.de>
        <20170608132609.32662-20-hch@lst.de>
In-Reply-To: <20170608132609.32662-20-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: x86@kernel.org, linux-arm-kernel@lists.infradead.org, xen-devel@lists.xenproject.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, openrisc@lists.librecores.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, dmaengine@vger.kernel.org, linux-tegra@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu,  8 Jun 2017 15:25:44 +0200
Christoph Hellwig <hch@lst.de> wrote:

> s390 can also use noop_dma_ops, and while that currently does not return
> errors it will so in the future.  Implementing the mapping_error method
> is the proper way to have per-ops error conditions.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Acked-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>

