From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 19 Oct 2004 04:08:42 +0000
Subject: RE: [PATCH] Convert pgtable cache to slab
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02363886@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1wtxnprkq.fsf@wilson.mkp.net>
In-Reply-To: <yq1wtxnprkq.fsf@wilson.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>I have made setup_gate() an initcall.

Did you build with CONFIG_IA32_SUPPORT=y ... the ia32_mem_init()
call sets up some gate pages too, won't it run into the same issue
that setup_gate() does when called before you've set up the
pgtable_cache()? [Just guessing, I didn't try this either]

>                                         That seemed like the best
>compromise and other archs do this too.  kmem_cache_init() is called
>after mem_init() in init/main.c, so we'd need to introduce another
>stub there to set up the gate page even if we had a general purpose
>slab cache in place.
>
>Comments?

Otherwise this looks pretty good ... but likely to collide with
an almighty thud with Andi Kleen's 4-level page table patch that
is making its way through LKML at the moment.  I'm not sure how
much momentum that patch has built up, or whether it is going to
go live in the -mm tree.

I'm going to hold off on your patch while I see what happens to
the 4-level patch.

-Tony
