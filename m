From: Grant Grundler <iod00d@hp.com>
Date: Fri, 23 Sep 2005 21:38:51 +0000
Subject: Re: [patch 2.6.13 0/6] swiotlb maintenance and x86_64 dma_sync_single_range_for_{cpu,device}
Message-Id: <20050923213851.GA6242@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F04795ED2@scsmsx401.amr.corp.intel.com> <20050923185021.GC6576@tuxdriver.com>
In-Reply-To: <20050923185021.GC6576@tuxdriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>, Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, discuss@x86-64.org, linux-ia64@vger.kernel.org, ak@suse.de, "Mallick, Asit K" <asit.k.mallick@intel.com>

On Fri, Sep 23, 2005 at 02:50:23PM -0400, John W. Linville wrote:
> On Fri, Sep 23, 2005 at 11:27:26AM -0700, Luck, Tony wrote:
> > >> It should just go away once the GFP_DMA32 code is merged.
> > >
> > >Is that the plan?  I suppose it makes sense.
> 
> > I don't have a good (or in fact any) understanding of the impact
> > of GFP_DMA32 on ia64.  People tell me it will all be good, but I'd
> > like to hear from someone running it.
>  
> All the patches I saw were for x86_64.  So, the impact on ia64 should
> be minimal... :-)

impact to arch/ia64 might be minimal. My understanding was
all the drivers that support 32-bit devices would need tweaks
to use GFP_DMA32 flag.  Is this still the plan?
	http://www.ussg.iu.edu/hypermail/linux/kernel/9901.3/0323.html

Most of what I've read in Andi's patch otherwise makes sense:
	http://lwn.net/Articles/152337/

But I didn't see Andi suggest that swiotlb should go completely away.

thanks,
grant
