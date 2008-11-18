From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 18 Nov 2008 15:35:15 +0000
Subject: RE: [PATCH] ia64: SN specific version of dma_get_required_mask()
Message-Id: <57C9024A16AD2D4C97DC78E552063EA35C454266@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081117173930.35342b31@hale.suse.de> from "Bernhard Walle" at
 Nov 17, 2008 05:39:30 PM
 <200811181408.mAIE8BHH057134@fcbayern.americas.sgi.com>
In-Reply-To: <200811181408.mAIE8BHH057134@fcbayern.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: John Keller <jpk@sgi.com>, Bernhard Walle <bwalle@suse.de>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

> This patch addresses a problem on SN Altix systems with < 4GB, where
> device drivers using the dma_get_required_mask() API would be told
> to use 32 bit DMA, when 64 bit is more efficient.

Even if someone did configure an Altix with < 4GB (which seems a very
unlikely occurance) all of that 4G would be located above 4GB (lowest
physical address on Altix is something like 384 TB, isn't it?)

Did we really make some dma mask decisions based on the amount
of memory rather than its location?  If we do, then perhaps we
should fix this in a generic place, not in sn2 specific code.

-Tony
