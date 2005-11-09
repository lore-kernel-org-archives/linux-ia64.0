From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 09 Nov 2005 18:39:53 +0000
Subject: RE: [RFC] 4-level page table directories.
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F04EAD7CF@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051027041709.GA13193@attica.americas.sgi.com>
In-Reply-To: <20051027041709.GA13193@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Have we all agreed by now that the performance hit is relatively minor
>(unmeasurable for most cases due to it being less than the noise of the
>samples) from 4-level page tables?  Do I need to do any more performance
>measurements?

The transaction processing benchmark hit, although small isn't minor.
Ken has had to fight for every 0.1% increment ... so setting him back
by 0.2% with a patch that is only needed for some very large systems
(>3192cpus according to your October 28th post) is a tough thing to do.

Once you've worked out the remaining kinks in the patch so that
64K page (and 4GB hugetlb page) work, I can take it with the
configuration option (with the default set to 3-level).  I realize
that is only of marginal use, as you have the issue of getting
OSDs to ship with a kernel configured this way, and getting ISVs
to qualify their applications to run on this configuration.  But
don't you already have that issue with persuading them to ship
with CONFIG_NR_CPUS384?  Surely there are a whole boatload of
tuneables and patches needed to get this sized system up and running?
4-level pagetables are just one piece of the puzzle.

-Tony
