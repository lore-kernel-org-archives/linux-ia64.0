From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 13 Oct 2004 20:23:58 +0000
Subject: RE: [RFC] Convert pgtable cache to slab
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F022BFCBF@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1zn2qtpyo.fsf@wilson.mkp.net>
In-Reply-To: <yq1zn2qtpyo.fsf@wilson.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Tony> I don't see the code for this postponement in this patch.
>
>It's there.  End of the mm/init.c hunk.

Ok, I see it now ... the perils of reading the patch rather than
applying it and looking at the code that you end up with.  I see
that ia32_mem_init() got dragged along too.

This is pretty messy in terms of code legibility.  I think that
the right thing to do is get zero_cache (or whatever we call it)
initialized way, way early ... so we don't have these ugly code
paths where gate pages are being setup in pgtable_cache_init()!

Think you can sell LKML on a generic change to initialize this
cache in mm/slab.c???  It might not be too hard, this patch started
out on PPC, other architectures might also be able to to the same
thing for their page tables (as well as potential other uses in
generic code ... of course concrete examples would be way better
than my handwaving about how nice this might be).

-Tony
