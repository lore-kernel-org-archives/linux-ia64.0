From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Date: Tue, 02 Jun 2009 09:18:19 +0000
Subject: Re: [PATCH 01/11] ia64: introduce arch-specific dma-mapping
Message-Id: <1243934299.8488.31.camel@zakaz.uk.xensource.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1243870383-12954-1-git-send-email-ian.campbell@citrix.com>
	 <1243870383-12954-2-git-send-email-ian.campbell@citrix.com>
	 <20090602130830A.fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <20090602130830A.fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mingo@elte.hu" <mingo@elte.hu>, "jeremy@goop.org" <jeremy@goop.org>, "tony.luck@intel.com" <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

On Tue, 2009-06-02 at 00:08 -0400, FUJITA Tomonori wrote:
> dma_map_range is a really confusing name. We have dma_map_single and
> dma_map_sg, they are the DMA mapping API.
> dma_map_range sounds like the DMA mapping API but it isn't.

Yes, it's not such a good name. I wonder what would be better? 

Perhaps dma_range_mapped? The return value indicates whether the range
is mapped or not so this makes some sense. It also makes it clearer that
this function is not intended to actually perform the mapping if it does
not exist.

> As I said,
> Xen dom0 needs to implement something like xen_map_sg, xen_map_single,
> etc, which uses some of swiotlb functions internally. Then we don't
> need functions like the above.

xen_map_sg would be literally identical to swiotlb_map_sg in every way
apart from the additional phys<->dma address translations. Similarly for
the other swiotlb interfaces. The phys<->dma address translation is also
required for the PowerPC architecture so duplicating all that code just
for Xen doesn't really solve the problem.

Ian.

