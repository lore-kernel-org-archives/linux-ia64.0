From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 18 Oct 2004 19:03:04 +0000
Subject: RE: [PATCH] General purpose zeroed page slab
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0236348B@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1oej5s0po.fsf@wilson.mkp.net>
In-Reply-To: <yq1oej5s0po.fsf@wilson.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>, "Martin K. Petersen" <mkp@wildopensource.com>
Cc: Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, akpm@osdl.org

>It's probably worth doing this with a static cachep in slab.c and only
>exposing a get_zeroed_page() / free_zeroed_page() interface, with the
>latter doing the memset to 0.  I disagree with Andi over the dumbness
>of zeroing the whole page.  That makes it cache-hot, which is what you
>want from a page you allocate from slab.

We started this discussion with the plan of using this interface to
allocate/free page tables at all levels in the page table hierarchy
(rather than maintain a special purpose "quicklist" allocator for each
level).  This is a somewhat specialized usage in that we know that we
have a completely zeroed page when we free ... so we really don't
want the overhead of zeroing it again.  There is also somewhat limited
benefit to the cache hotness argument here as most page tables (especially
higher-order ones) are used very sparsely.

That said, the idea to expose this slab only through a specific API
should calm fears about accidental mis-use (with people freeing a page
that isn't all zeroes).

-Tony
