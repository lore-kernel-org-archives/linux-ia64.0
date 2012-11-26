From: Marek Szyprowski <m.szyprowski@samsung.com>
Date: Mon, 26 Nov 2012 10:57:19 +0000
Subject: Re: [PATCH 0/9] dma_debug: add debug_dma_mapping_error support to architectures that support DMA_DEB
Message-Id: <50B34B0F.3080204@samsung.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1353706142.5270.93.camel@lorien2>
In-Reply-To: <1353706142.5270.93.camel@lorien2>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

Hello,

On 11/23/2012 10:29 PM, Shuah Khan wrote:
> An earlier patch added dma mapping error debug feature to dma_debug
> infrastructure. References:
>
> https://lkml.org/lkml/2012/10/8/296
> https://lkml.org/lkml/2012/11/3/219
>
> The following series of patches adds the call to debug_dma_mapping_error() to
> architecture specific dma_mapping_error() interfaces on the following
> architectures that support CONFIG_DMA_API_DEBUG.

I've took all the patches to the next-dma-debug branch in my tree, I sorry
that You have to wait so long for it. My branch is based on Joerg's
dma-debug branch and I've included it for testing in linux-next branch.

Joerg: would You mind if I handle pushing the whole branch to v3.8
via my kernel tree? Those changes should be kept close together to
avoid build breaks for bisecting.

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center


