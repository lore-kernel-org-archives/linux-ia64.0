From: Rohit Seth <rohitseth@google.com>
Date: Sat, 28 Apr 2007 01:31:03 +0000
Subject: Re: Fw: [PATCH] ia64: race flushing icache in do_no_page path
Message-Id: <1177723863.13482.379.camel@galaxy.corp.google.com>
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
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Mike Stroyan <mike.stroyan@hp.com>, Andrew Morton <akpm@linux-foundation.org>, "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, 2007-04-27 at 15:18 +0100, Hugh Dickins wrote:
> I presume Mike and Anil are correct, that it needs to be done before
> putting pte into page table, not left until after: but as you've
> guessed, that needs to be done everywhere, not just in the two
> places so far identified.
> 

That sounds about right.  Before installing new mapping, kernel should
ensure there are no stale contents in caches or TLB.
lazy_mmu_prot_update needs to be called whenever the permissions on pte
(about to) change.  So if remapping is causing change in protection then
lazy_mmu_prot_update needs to be called.  

> When it was discussed last year (in connection with Peter's page
> cleaning patches) it was thought to be a variant of update_mmu_cache()
> (after setting pte), and we added the fremap one to accompany it;
> but now it looks to be a variant of flush_icache_page() (before
> setting pte).
> 
> I believe lazy_mmu_prot_update(pteval) came into existence primarily
> for mprotect's change_pte_range() case.

Yup.

>   If ia64 filled in its
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

Right.  Extra flush_icache_page routines will add cost to archs that
have non-null definition of this routine.  BTW, isn't flush_icache_page
marked for deprecation?

> I believe that was the secondary reason for lazy_mmu_prot_update(),
> perhaps better called ia64_flush_icache_page(): to allow calls to
> be added where ia64 was (mistakenly) thought to want them, without
> needing a protracted audit of how other architectures might be
> impacted.
> 

lazy_mmu_prot_update was added specifically for notifying change in
protection.  So, in a way it is closer to update_mmu_cache (Which is for
change in mappings itself).  Though for ia64 implementation, this ends
up flushing the icaches when needed.

Hopefully my reply is useful.

-rohit

