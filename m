From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 17 Mar 2005 23:25:40 +0000
Subject: RE: Recent fix for pgd_addr_end
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0319B099@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16953.65276.292620.811032@wombat.chubb.wattle.id.au>
In-Reply-To: <16953.65276.292620.811032@wombat.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>(The reason I'm asking all this is that I still see lots of
>
>/home/peterc/kernels/linux-2.5-import/mm/memory.c:105: bad pmd 20000000000acdc8.
>/home/peterc/kernels/linux-2.5-import/mm/memory.c:105: bad pmd ffff004f00000002.
>/home/peterc/kernels/linux-2.5-import/mm/memory.c:105: bad pmd 20000000000acdd0.
>
>messages after booting, even with that change).

Yes, I still have something wrong ... Dave Miller is still pushing
me towards a solution.

-Tony
