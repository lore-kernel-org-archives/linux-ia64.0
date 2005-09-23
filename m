From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 23 Sep 2005 18:27:26 +0000
Subject: RE: [patch 2.6.13 0/6] swiotlb maintenance and x86_64 dma_sync_single_range_for_{cpu,device}
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F04795ED2@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <09122005104847.30871@bilbo.tuxdriver.com>
In-Reply-To: <09122005104847.30871@bilbo.tuxdriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "John W. Linville" <linville@tuxdriver.com>, Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, discuss@x86-64.org, linux-ia64@vger.kernel.org, ak@suse.de, "Mallick, Asit K" <asit.k.mallick@intel.com>

>> It should just go away once the GFP_DMA32 code is merged.
>
>Is that the plan?  I suppose it makes sense.
>
>So, move it to driver/pci/swiotlb.c?  Or just leave it where it is?
>
>Either way, I'll redo the other patches to reflect the correct
>location.

I don't have a good (or in fact any) understanding of the impact
of GFP_DMA32 on ia64.  People tell me it will all be good, but I'd
like to hear from someone running it.

If it is good, and if it is coming soon, then there is no point
moving swiotlb.  But I don't know the answers to either of those
questions.

-Tony
