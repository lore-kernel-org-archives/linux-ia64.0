From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 15 Feb 2005 20:25:35 +0000
Subject: RE: [PATCH] Convert pgtable cache to slab
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02EA12E9@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1wtxnprkq.fsf@wilson.mkp.net>
In-Reply-To: <yq1wtxnprkq.fsf@wilson.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>I agree.  What I am asking is if we turn on the 4th level of 
>page tables, does anybody have an objection to 4/16k levels as opposed to 
>3/PAGE_SIZE plus a 4th cleanup to cover the entire address space?

Are there any other big system users now (or coming real soon) for
whom 2**60 (with PAGE_SIZEdk, 2**58 with PAGE_SIZEk) would
be a major pain?

You'd have to do some fancy footwork documenting and enforcing
the PAGE_SIZE vs. PAGE_TABLE_LEVELS interactions (it would be
bad to configure a 4K or 8K pagesize with a 4-level option that
expected to allocate 16K for page tables).

The PAGE_SIZEdk 4/16k case requires you to deal with partial pages
on the quicklists (or in the slab if you go that route).  The slab
code knows how to coalesce and free such sub-pages under memory
pressure (though fragmentation may make it sometimes ineffective).
The quicklist approach doesn't have any easy way to return partial
pages to general use.

-Tony
