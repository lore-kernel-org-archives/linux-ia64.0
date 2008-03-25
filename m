From: David Miller <davem@davemloft.net>
Date: Tue, 25 Mar 2008 23:49:27 +0000
Subject: Re: larger default page sizes...
Message-Id: <20080325.164927.249210766.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0803251045510.16206@schroedinger.engr.sgi.com>
	<20080325.162244.61337214.davem@davemloft.net>
	<87tziu5q37.wl%peter@chubb.wattle.id.au>
In-Reply-To: <87tziu5q37.wl%peter@chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: peterc@gelato.unsw.edu.au
Cc: clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, torvalds@linux-foundation.org, ianw@gelato.unsw.edu.au

From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Wed, 26 Mar 2008 10:41:32 +1100

> It's actually harder than it looks.  Ian Wienand just finished his
> Master's project in this area, so we have *lots* of data.  The main
> issue is that, at least on Itanium, you have to turn off the hardware
> page table walker for hugepages if you want to mix superpages and
> standard pages in the same region. (The long format VHPT isn't the
> panacea we'd like it to be because the hash function it uses depends
> on the page size).  This means that although you have fewer TLB misses
> with larger pages, the cost of those TLB misses is three to four times
> higher than with the standard pages.

If the hugepage is more than 3 to 4 times larger than the base
page size, which it almost certainly is, it's still an enormous
win.

> Other architectures (where the page size isn't tied into the hash
> function, so the hardware walked can be used for superpages) will have
> different tradeoffs.

Right, admittedly this is just a (one of many) strange IA64 quirk.
