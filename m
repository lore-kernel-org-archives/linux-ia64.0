From: Robin Holt <holt@sgi.com>
Date: Tue, 14 Sep 2004 15:16:29 +0000
Subject: Uncached memory allocator for ia64.
Message-Id: <20040914151629.GA21118@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In an effort to get the SGI Special Memory driver into the kernel,
Christoph Hellwig pointed me at a discussion of a general purpose uncached
memory allocator.  The thread is here:

http://www.gelato.unsw.edu.au/linux-ia64/0307/6218.html

I would like to reopen this discussion to determine the scope of work
that would need to be done.

I would like to start with the general, what are we trying to solve?
I can not think of a single reason aside from the previously discussed
min state area for the kernel to ever need to work with memory uncached.

Assuming there is no reason, can we pare this discussion back to a page
based allocator?  That would be much simpler to work with and would not
need to recombine fragments.

Given a page based allocator, can we just use the code that is in the
fetchop driver?  It does a per-node page based allocation.  Can that
code be renamed to no longer mention mspec?  Where in the tree should
this functionality live?  Would it be acceptable to always work with
physical addresses?

Thanks,
Robin Holt

