From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 14 Feb 2005 19:12:54 +0000
Subject: RE: [rfc] generic allocator and mspec driver
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02E64A4F@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16897.9640.160896.31584@jaguar.mkp.net>
In-Reply-To: <16897.9640.160896.31584@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Anyway, it seems that lcrash at least only accesses the memory using
>read() and write()? which means it is relatively easy to using a
>struct page flag to do uncached vs cached access on the fly. mmap on
>the other hand would be a bit of a nightmare as it would require a
>custom fault handler that would know when to go cached and when not
>to.
>
>How would you feel about using PG_arch_1 for this on ia64?

Is ia64 the only architecture that has uncached vs. cached access
issues?  If so, the PG_arch_1 might have to be the solution, but
surely others have cache coherence problems too if there are mixed
cacheable and uncacheable access to the same memory?  In which case
a new generic bit would be more appropriate.

A few weeks back there was also some discussion about allocating
one or more bits to mark bad pages (those containing ECC errors)
as "do not touch".

-Tony
