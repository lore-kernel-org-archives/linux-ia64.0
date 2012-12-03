From: Marek Szyprowski <m.szyprowski@samsung.com>
Date: Mon, 03 Dec 2012 08:51:53 +0000
Subject: Re: [PATCH 0/9] dma_debug: add debug_dma_mapping_error support to architectures that support DMA_DEB
Message-Id: <50BC6829.4060205@samsung.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1353706142.5270.93.camel@lorien2> <50B34B0F.3080204@samsung.com>
 <20121202140644.GP30633@8bytes.org>
In-Reply-To: <20121202140644.GP30633@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org


On 12/2/2012 3:06 PM, Joerg Roedel wrote:
> Hi Marek,
>   
> On Mon, Nov 26, 2012 at 11:57:19AM +0100, Marek Szyprowski wrote:
>
> > I've took all the patches to the next-dma-debug branch in my tree, I sorry
> > that You have to wait so long for it. My branch is based on Joerg's
> > dma-debug branch and I've included it for testing in linux-next branch.
>
> The patches are now two times in next. One version from my tree and one
> from yours. Please remove the version from your tree, the patches should
> go upstream via my dma-debug branch.

Ok, I've removed them from my dma-mapping-next tree. Please add/cherry-pick
the missing patch for ARM architecture, which I've accidentally already
pushed to mainline some time ago and then reverted. See commit
871ae57adc5ed092 (and 697575896670ba).

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center


