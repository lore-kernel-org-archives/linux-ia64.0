From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Tue, 01 May 2007 11:52:50 +0000
Subject: Re: Fw: [PATCH] ia64: race flushing icache in do_no_page path
Message-Id: <46372A12.9080802@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200704281817.l3SIHu0P001764@smtp.corp.google.com>
In-Reply-To: <200704281817.l3SIHu0P001764@smtp.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rohit Seth <rohitseth@google.com>
Cc: 'Hugh Dickins' <hugh@veritas.com>, 'Mike Stroyan' <mike.stroyan@hp.com>, 'Andrew Morton' <akpm@linux-foundation.org>, "'Luck, Tony'" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Rohit Seth wrote:

>>and 
>>it's only interested when it's executable i.e. "lazy_mmu_prot_update"
>>is a name concealing some overdesign.
> 
> 
> You are right that ia64 is only interested in whne the execute permissions
> kick in (and FWIW ia64 used to use update_mmu_cache API to do what it is now
> doing lazy_mmu_prot_update).  Though the idea was to design an API that any
> arch can use to know when ever there is change in protections on a mapping.

What I think what we should do is audit flush_icache_page coverage, and
convert ia64 to use that (because it needs this to happen _before_ the
pte is set).

All we should need to do is add a pte argument to flush_icache, and it
should be possible to do what ia64 wants, and we can remove
lazy_mmu_prot_update (or at least rename it to something like
flush_icache_page_chprot and move it to the normal flush_icache_page
position above set_pte if not all architectures want their
flush_icache_page called at protection change time).

-- 
SUSE Labs, Novell Inc.
