From: Andi Kleen <ak@suse.de>
Date: Mon, 26 Sep 2005 07:01:48 +0000
Subject: Re: [patch 2.6.13 0/6] swiotlb maintenance and x86_64 dma_sync_single_range_for_{cpu,device}
Message-Id: <200509260901.48972.ak@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F04795ED2@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F04795ED2@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: "John W. Linville" <linville@tuxdriver.com>, Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, discuss@x86-64.org, linux-ia64@vger.kernel.org, "Mallick, Asit K" <asit.k.mallick@intel.com>

On Friday 23 September 2005 20:27, Luck, Tony wrote:
> >> It should just go away once the GFP_DMA32 code is merged.
> >
> >Is that the plan?  I suppose it makes sense.
> >
> >So, move it to driver/pci/swiotlb.c?  Or just leave it where it is?
> >
> >Either way, I'll redo the other patches to reflect the correct
> >location.
>
> I don't have a good (or in fact any) understanding of the impact
> of GFP_DMA32 on ia64.  People tell me it will all be good, but I'd
> like to hear from someone running it.

It shouldn't change anything for IA64. GFP_DMA32 just becomes
an alias for your GFP_DMA.  On advantage is that drivers can
be now source level compatible between x86-64 and ia64 
for this (although they should be really using pci_alloc_consistent()
instead) 

> If it is good, and if it is coming soon, then there is no point
> moving swiotlb.  But I don't know the answers to either of those
> questions.

swiotlb is still needed even with GFP_DMA32. Just move it.
2.6.15 won't have it also.

-Andi

