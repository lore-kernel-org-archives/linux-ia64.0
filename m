From: "John W. Linville" <linville@tuxdriver.com>
Date: Tue, 27 Sep 2005 00:14:29 +0000
Subject: Re: [patch 2.6.14-rc2 0/5] swiotlb maintenance and x86_64 dma_sync_single_range_for_{cpu,device}
Message-Id: <20050927001427.GC5640@tuxdriver.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F047E9021@scsmsx401.amr.corp.intel.com> <20050926224603.GD16113@esmail.cup.hp.com>
In-Reply-To: <20050926224603.GD16113@esmail.cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Grant Grundler <iod00d@hp.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Matthew Wilcox <matthew@wil.cx>, linux-kernel@vger.kernel.org, discuss@x86-64.org, linux-ia64@vger.kernel.org, linux-pci@atrey.karlin.mff.cuni.cz, ak@suse.de, "Mallick, Asit K" <asit.k.mallick@intel.com>, gregkh@suse.de

On Mon, Sep 26, 2005 at 03:46:03PM -0700, Grant Grundler wrote:

> But since swiotlb complies with DMA-API interface and is not related
> to any particular type of bus, I'd rather it go into lib/ instead of
> drivers/pci.

OK...I read Tony's patch post to imply that he is consenting to lib/ as
the location as well.  Tony, please speak-up if that is not the case.

If everyone agrees, I'll re-collect the patches moving everything to
lib/ (plus the one I forgot to repost) and Tony's patch and repost.

So, who is the proper committer for this?  Tony?  Or should I send
them directly to Andrew?

Thanks,

John
-- 
John W. Linville
linville@tuxdriver.com
