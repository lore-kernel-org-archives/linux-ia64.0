From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 12 Aug 2008 20:47:37 +0000
Subject: RE: [patch] IA64: make rsvd_region and num_rsvd_regions static
Message-Id: <57C9024A16AD2D4C97DC78E552063EA30844AEFB@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080805095739.GA12078@verge.net.au>
In-Reply-To: <20080805095739.GA12078@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

> rsvd_region and num_rsvd_regions are only accessed in
> arch/ia64/kernel/setup.c, so they should be static.

Are you looking at -mm or linux-next?  In my tree I see:

arch/ia64/mm/contig.c:  for (i = 0; i < num_rsvd_regions; i++) {
arch/ia64/mm/contig.c:          range_end   = min(end, rsvd_region[i].start & PAGE_MASK);
arch/ia64/mm/contig.c:          free_start = PAGE_ALIGN(rsvd_region[i].end);

-Tony
