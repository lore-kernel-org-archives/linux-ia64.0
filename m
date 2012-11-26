From: Joerg Roedel <joro@8bytes.org>
Date: Mon, 26 Nov 2012 11:20:58 +0000
Subject: Re: [PATCH 0/9] dma_debug: add debug_dma_mapping_error support to architectures that support DMA_DEB
Message-Id: <20121126112058.GF25742@8bytes.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1353706142.5270.93.camel@lorien2> <50B34B0F.3080204@samsung.com>
In-Reply-To: <50B34B0F.3080204@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

On Mon, Nov 26, 2012 at 11:57:19AM +0100, Marek Szyprowski wrote:
> I've took all the patches to the next-dma-debug branch in my tree, I sorry
> that You have to wait so long for it. My branch is based on Joerg's
> dma-debug branch and I've included it for testing in linux-next branch.
> 
> Joerg: would You mind if I handle pushing the whole branch to v3.8
> via my kernel tree? Those changes should be kept close together to
> avoid build breaks for bisecting.

I'll apply the patches to my tree soon enough. But before that I'll wait
a little bit longer to give the arch maintainers the chance to add the
missing Acked-bys.


	Joerg


