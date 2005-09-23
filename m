From: "John W. Linville" <linville@tuxdriver.com>
Date: Fri, 23 Sep 2005 18:50:23 +0000
Subject: Re: [patch 2.6.13 0/6] swiotlb maintenance and x86_64 dma_sync_single_range_for_{cpu,device}
Message-Id: <20050923185021.GC6576@tuxdriver.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F04795ED2@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F04795ED2@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, discuss@x86-64.org, linux-ia64@vger.kernel.org, ak@suse.de, "Mallick, Asit K" <asit.k.mallick@intel.com>

On Fri, Sep 23, 2005 at 11:27:26AM -0700, Luck, Tony wrote:
> >> It should just go away once the GFP_DMA32 code is merged.
> >
> >Is that the plan?  I suppose it makes sense.

> I don't have a good (or in fact any) understanding of the impact
> of GFP_DMA32 on ia64.  People tell me it will all be good, but I'd
> like to hear from someone running it.
 
All the patches I saw were for x86_64.  So, the impact on ia64 should
be minimal... :-)

> If it is good, and if it is coming soon, then there is no point
> moving swiotlb.  But I don't know the answers to either of those
> questions.

The xen guys have an swiotlb implementation, although theres differs
somewhat.  Perhaps if we moved it out from under ia64, the two could
be consolidated?

John
-- 
John W. Linville
linville@tuxdriver.com
