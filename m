From: "John W. Linville" <linville@tuxdriver.com>
Date: Mon, 12 Sep 2005 19:51:12 +0000
Subject: Re: [patch 2.6.13 4/6] swiotlb: support syncing DMA_BIDIRECTIONAL mappings
Message-Id: <20050912195110.GC19644@tuxdriver.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <09122005104851.31056@bilbo.tuxdriver.com> <09122005104851.31120@bilbo.tuxdriver.com> <20050912185120.GD21820@esmail.cup.hp.com>
In-Reply-To: <20050912185120.GD21820@esmail.cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Grant Grundler <iod00d@hp.com>
Cc: linux-kernel@vger.kernel.org, discuss@x86-64.org, linux-ia64@vger.kernel.org, ak@suse.de, tony.luck@intel.com, Asit.K.Mallick@intel.com

On Mon, Sep 12, 2005 at 11:51:20AM -0700, Grant Grundler wrote:
> On Mon, Sep 12, 2005 at 10:48:51AM -0400, John W. Linville wrote:

> > +	case SYNC_FOR_DEVICE:
> > +		if (likely(dir = DMA_TO_DEVICE || dir = DMA_BIDIRECTIONAL))
> > +			memcpy(dma_addr, buffer, size);
> > +		else if (dir != DMA_FROM_DEVICE && dir != DMA_NONE)
> > +			BUG();
> > +		break;
> > +	default:

> Isn't "DMA_NONE" expected to generate a warning or panic?

True enough...I'll follow-up w/ an additive patch to account for that.
As you pointed-out, the higher-level functions in swiotlb filter that
out anyway, so this really isn't a big issue.

John
-- 
John W. Linville
linville@tuxdriver.com
