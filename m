From: "David Mosberger-Tang" <dmosberger@gmail.com>
Date: Fri, 27 Apr 2007 17:02:43 +0000
Subject: Re: Fw: [PATCH] ia64: race flushing icache in do_no_page path
Message-Id: <ed5aea430704271002i8d44a09o895bee2063954858@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070425205548.fd51b301.akpm@linux-foundation.org>
	 <46305A8D.2080003@yahoo.com.au> <20070426173544.GA30744@ldl.fc.hp.com>
	 <4631E49C.2030501@yahoo.com.au>
	 <Pine.LNX.4.64.0704271437570.14794@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0704271437570.14794@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Mike Stroyan <mike.stroyan@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Rohit Seth <rohitseth@google.com>, "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

My book has a fairly detailed discussion of how these operations were
supposed to work and what the reasoning behind them was.
Unfortunately, I don't have time to really participate this discussion
at the moment, but I hope somebody else has access to the book and
would (re-)read it for some background (not to claim that it got
everything right 100% but to ensure that earlier mistakes are not
repeated...).

  --david

On 4/27/07, Hugh Dickins <hugh@veritas.com> wrote:
> On Fri, 27 Apr 2007, Nick Piggin wrote:
> >
> > But that's because of ia64's cache coherency implementation. I don't really
> > follow the documentation to know whether it should be one way or the other,
> > but surely it should be done either before or after the set_pte_at, not both.
> >
> > Anyway, how about fremap or mprotect, for example?
> > ...
> >
> > OK, I'm still not sure that I understand why lazy_mmu_prot_update should be
> > used rather than flush_icache_page (in concept, not ia64 implementation).
> > Sure, flush_icache_page isn't given the pte, but let's assume we can change
> > that.
>
> You're asking lots of good questions.  I wish the ia64 people would
> know the answers, but from the length of time the "lazy_mmu_prot_update"
> stuff took to get into the tree, and the length of time it's taken to be
> found defective, I suspect they don't, and we'll have to guess for them.
>
> Some guesses I'm working with...
>
> I presume Mike and Anil are correct, that it needs to be done before
> putting pte into page table, not left until after: but as you've
> guessed, that needs to be done everywhere, not just in the two
> places so far identified.
>
> When it was discussed last year (in connection with Peter's page
> cleaning patches) it was thought to be a variant of update_mmu_cache()
> (after setting pte), and we added the fremap one to accompany it;
> but now it looks to be a variant of flush_icache_page() (before
> setting pte).
>
> I believe lazy_mmu_prot_update(pteval) came into existence primarily
> for mprotect's change_pte_range() case.  If ia64 filled in its
> flush_icache_page(vma, page), that could have been used there
> (checking 'vm_flags & VM_EXEC' instead of pte_exec): but that would
> involve a relatively expensive(?) pte_page() in a place which doesn't
> need to know the struct page for other cases.
>
> Well, not pte_page(), it needs to be vm_normal_page() doesn't it?
> and ia64's current lazy_mmu_prot_update is unsafe when !pfn_valid.
>
> Some flush_icache_pages are already in place, others are not: do
> we need to add some?  But those architectures which have a non-empty
> flush_icache_page seem to have survived without the additional calls
> - so they might be unnecessarily slowed down by additional calls.
>
> I believe that was the secondary reason for lazy_mmu_prot_update(),
> perhaps better called ia64_flush_icache_page(): to allow calls to
> be added where ia64 was (mistakenly) thought to want them, without
> needing a protracted audit of how other architectures might be
> impacted.
>
> But I'm still trying to make sense of it.
>
> Hugh
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


-- 
Mosberger Consulting LLC, http://www.mosberger-consulting.com/
