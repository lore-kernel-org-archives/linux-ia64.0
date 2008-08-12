From: Simon Horman <horms@verge.net.au>
Date: Tue, 12 Aug 2008 23:21:22 +0000
Subject: Re: [patch] IA64: make rsvd_region and num_rsvd_regions static
Message-Id: <20080812232121.GC11363@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080805095739.GA12078@verge.net.au> <57C9024A16AD2D4C97DC78E552063EA30844AEFB@orsmsx505.amr.corp.intel.com>
In-Reply-To: <57C9024A16AD2D4C97DC78E552063EA30844AEFB@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, Aug 12, 2008 at 01:47:37PM -0700, Luck, Tony wrote:
> > rsvd_region and num_rsvd_regions are only accessed in
> > arch/ia64/kernel/setup.c, so they should be static.
> 
> Are you looking at -mm or linux-next?  In my tree I see:

Whatever I was looking at, I was wrong. Sorry for the noise.

> arch/ia64/mm/contig.c:  for (i = 0; i < num_rsvd_regions; i++) {
> arch/ia64/mm/contig.c:          range_end   = min(end, rsvd_region[i].start & PAGE_MASK);
> arch/ia64/mm/contig.c:          free_start = PAGE_ALIGN(rsvd_region[i].end);
