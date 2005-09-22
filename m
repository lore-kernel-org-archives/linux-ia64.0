From: Christoph Hellwig <hch@infradead.org>
Date: Thu, 22 Sep 2005 20:41:55 +0000
Subject: Re: [patch 2.6.13 0/6] swiotlb maintenance and x86_64 dma_sync_single_range_for_{cpu,device}
Message-Id: <20050922204155.GA5400@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F0475A8B6@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F0475A8B6@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: "John W. Linville" <linville@tuxdriver.com>, linux-kernel@vger.kernel.org, discuss@x86-64.org, linux-ia64@vger.kernel.org, ak@suse.de, "Mallick, Asit K" <asit.k.mallick@intel.com>

On Thu, Sep 22, 2005 at 01:37:46PM -0700, Luck, Tony wrote:
> >Conduct some maintenance of the swiotlb code:
> >
> >	-- Move the code from arch/ia64/lib to lib
> 
> I agree that this code needs to move up out of arch/ia64, it is messy
> that x86_64 needs to reach over and grab this from arch/ia64.
> 
> But is "lib" really the right place for it to move to?  Perhaps
> a more logical place might be "drivers/pci/swiotlb/" since this
> code is tightly coupled to pci?

It should just go away once the GFP_DMA32 code is merged.
