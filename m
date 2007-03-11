From: Christoph Lameter <clameter@sgi.com>
Date: Sun, 11 Mar 2007 02:09:23 +0000
Subject: [QUICKLIST 0/6] Arch independent quicklists V1
Message-Id: <20070311020923.19905.49260.sendpatchset@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: ak@suse.com, holt@sgi.com, linux-ia64@vger.kernel.org, Christoph Lameter <clameter@sgi.com>, mpm@selenic.com

This patchset introduces an arch independent framework to handle lists
of recently used page table pages.

Page table pages have the characteristics that they are typically zero
or in a known state when they are freed. This is usually the exactly
same state as needed after allocation. So it makes sense to build a list
of freed page table pages and then consume the pages already in use
first. Those pages have already been initialized correctly (thus no
need to zero them) and are likely already cached in such a way that
the MMU can use them most effectively.

Such an implementation already exits for ia64. If I remember correctly
it was done by Robin Holt. Howver, that implementation did not support
constructors and destructors as needed by i386 / x86_64. It also only
supported a single quicklist. The implementation here has constructor
and destructor support as well as the ability for an arch to specify
how many quicklists are needed.

Quicklists are defined by an arch defining the necessary number
of quicklists in arch/<arch>/Kconfig. F.e. i386 needs two and thus
has 

config NR_QUICK
	int
	default 2

If an arch has requested quicklist support then pages can be allocated
from the quicklist (or from the page allocator if the quicklist is
empty) via:

quicklist_alloc(<quicklist-nr>, <gfpflags>, <constructor>)

Page table pages can be freed using:

quicklist_free(<quicklist-nr>, <destructor>, <page>)

Pages must have a definite state after allocation and before
they are freed. If no constructor is specified then pages
will be zeroed on allocation and must be zeroed before they are
freed.

If a constructor is used then the constructor will establish
a definite page state. F.e. the i386 and x86_64 pgd constructors
establish certain mappings.

Constructors and destructors can also be used to track the pages.
i386 and x86_64 use a list of pgds in order to be able to dynamically
update standard mappings.

6 patches follow this message:

[QUICKLIST 1/6] Extract quicklist implementation from IA64
[QUICKLIST 2/6] i386: quicklist support
[QUICKLIST 3/6] i386: Use standard list manipulators for pgd_list
[QUICKLIST 4/6] x86_64: Single quicklist
[QUICKLIST 5/6] x86_64: Separate quicklist for pgds
[QUICKLIST 6/6] slub: remove special casing for PAGE_SIZE slabs

