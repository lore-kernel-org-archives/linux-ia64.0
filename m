From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Tue, 01 May 2007 11:47:55 +0000
Subject: Re: Fw: [PATCH] ia64: race flushing icache in do_no_page path
Message-Id: <463728EB.8030308@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200704281830.l3SIUqOo004230@smtp.corp.google.com>
In-Reply-To: <200704281830.l3SIUqOo004230@smtp.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rohit Seth <rohitseth@google.com>
Cc: 'Hugh Dickins' <hugh@veritas.com>, 'Mike Stroyan' <mike.stroyan@hp.com>, 'Andrew Morton' <akpm@linux-foundation.org>, "'Luck, Tony'" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Rohit Seth wrote:
> Hi Nick, 
> 
> -----Original Message-----
> From: Nick Piggin [mailto:nickpiggin@yahoo.com.au] 
> Sent: Friday, April 27, 2007 11:03 PM
> To: Hugh Dickins
> Cc: rohitseth@google.com; Mike Stroyan; Andrew Morton; Luck, Tony;
> linux-ia64@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: Re: Fw: [PATCH] ia64: race flushing icache in do_no_page path
> 
> Hugh Dickins wrote:
> 
>>On Sat, 28 Apr 2007, Nick Piggin wrote:
>>
>>
>>>OIC, you need a virtual address to evict the icache, so you can't 
>>>flush at flush_dcache time? Or does ia64 have an instruction to flush 
>>>the whole icache? (it would be worth testing, to see how much 
>>>performance suffers).
>>
>>
>>I'm puzzled by that remark: the ia64 flush_icache_range always has a 
>>virtual address, it uses the kernel virtual address; it takes no 
>>interest in whether there's a user virtual address.
> 
> 
>>I _think_ what it is doing is actually flushing dcache lines dirtied 
>>via the kernel virtual address (yes, I think flush_icache
>>in lazy_mmu_prot_update is actually just flushing the dcache, but 
>>I could be wrong? [*]).
> 
> 
> It is invalidating any entries (containing same physical address) in both I
> and D caches.  Any dirty lines in D cache are written back to memory before
> getting invalidated (ofcourse).

OK. (should it be issuing both fc and fc.i to be robust in case a
new implementation doesn't flush the dcache with fc.i?)


>>There are supposedly no icache lines at that point[**]:
> 
> 
> For this bug to trigger there has to be a (stale) entry in icache containing
> the old contents of a page that just got updated by kernel as explicit
> copying of data (DMAs are coherent on ia64, meaning if a device were to
> write to memory then architecture guarnatees that both I and D caches are
> invalidated).

So if we have a dirty dcache line for a given physical address,
it will _always_ be the case that a subsequent icache load will
find that dirty data?

... thanks for bearing with me ;)

-- 
SUSE Labs, Novell Inc.
