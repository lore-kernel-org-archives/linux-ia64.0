From: Jesper Nilsson <jesper.nilsson@axis.com>
Date: Tue, 09 Jan 2018 15:54:54 +0000
Subject: Re: [PATCH 22/67] dma-mapping: clear harmful GFP_* flags in common code
Message-Id: <20180109155454.GO32368@axis.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171229081911.2802-1-hch@lst.de>
 <20171229081911.2802-23-hch@lst.de>
In-Reply-To: <20171229081911.2802-23-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, x86@kernel.org, linux-snps-arc@lists.infradead.org, adi-buildroot-devel@lists.sourceforge.net, linux-m68k@lists.linux-m68k.org, patches@groups.riscv.org, linux-metag@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Michal Simek <monstr@monstr.eu>, linux-parisc@vger.kernel.org, linux-cris-kernel@axis.com, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Fri, Dec 29, 2017 at 09:18:26AM +0100, Christoph Hellwig wrote:
> Life the code from x86 so that we behave consistently.  In the future we
> should probably warn if any of these is set.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Acked-by: Jesper Nilsson <jesper.nilsson@axis.com>

> ---
>  arch/cris/arch-v32/drivers/pci/dma.c      | 3 ---

/^JN - Jesper Nilsson
-- 
               Jesper Nilsson -- jesper.nilsson@axis.com
