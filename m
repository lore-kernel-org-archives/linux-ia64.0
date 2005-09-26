From: "John W. Linville" <linville@tuxdriver.com>
Date: Mon, 26 Sep 2005 21:54:50 +0000
Subject: Re: [patch 2.6.14-rc2 0/5] swiotlb maintenance and x86_64 dma_sync_single_range_for_{cpu,device}
Message-Id: <20050926215447.GB5640@tuxdriver.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F04795ED2@scsmsx401.amr.corp.intel.com> <09262005170119.15628@bilbo.tuxdriver.com> <20050926213326.GF1459@parisc-linux.org>
In-Reply-To: <20050926213326.GF1459@parisc-linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: linux-kernel@vger.kernel.org, discuss@x86-64.org, linux-ia64@vger.kernel.org, linux-pci@atrey.karlin.mff.cuni.cz, ak@suse.de, tony.luck@intel.com, Asit.K.Mallick@intel.com, gregkh@suse.de

On Mon, Sep 26, 2005 at 03:33:26PM -0600, Matthew Wilcox wrote:
> On Mon, Sep 26, 2005 at 05:01:19PM -0400, John W. Linville wrote:
> > In this round, the new location for swiotlb is driver/pci/swiotlb.c.
> > This is the result of discussions on lkml pointing-out that swiotlb is
> > closely related to PCI.
> 
> Uh?  It implements DMA services, which aren't limited to PCI at all.
> Despite the file including <linux.pci.h> and <asm/pci.h> (which should
> probably both be removed), there's not a single PCI-related function in
> this file.  You originally moved it to lib/ which made much more sense.

Well, now, this is a quandry isn't it...  Actually, I'm inclined to
agree with you.

Tony, et al., care to restate your reasoning for moving it under
drivers/pci?

John
-- 
John W. Linville
linville@tuxdriver.com
