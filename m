From: Muli Ben-Yehuda <mulix@mulix.org>
Date: Fri, 23 Sep 2005 18:31:45 +0000
Subject: Re: [patch 2.6.13 0/6] swiotlb maintenance and x86_64 dma_sync_single_range_for_{cpu,device}
Message-Id: <20050923183145.GK7243@granada.merseine.nu>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F0475A8B6@scsmsx401.amr.corp.intel.com> <20050922204155.GA5400@infradead.org> <20050923182233.GB6576@tuxdriver.com>
In-Reply-To: <20050923182233.GB6576@tuxdriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>, "Luck, Tony" <tony.luck@intel.com>, linux-kernel@vger.kernel.org, discuss@x86-64.org, linux-ia64@vger.kernel.org, ak@suse.de, "Mallick, Asit K" <asit.k.mallick@intel.com>

On Fri, Sep 23, 2005 at 02:22:35PM -0400, John W. Linville wrote:

> > It should just go away once the GFP_DMA32 code is merged.
> 
> Is that the plan?  I suppose it makes sense.

What about the odd devices that can do less than 32 bit DMA masks on
platforms without IOMMU?
 
> So, move it to driver/pci/swiotlb.c?  Or just leave it where it is?

drivers/pci/swiotlb.c makes sense. Xen has its own swiotlb.c these
days, moving it to drivers/pci/ should make it slightly easier to use
the generic one.

Cheers,
Muli
-- 
Muli Ben-Yehuda
http://www.mulix.org | http://mulix.livejournal.com/

