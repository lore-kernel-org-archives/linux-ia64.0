From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 02 Aug 2007 03:40:55 +0000
Subject: Re: ia64 mmu_gather question
Message-Id: <1186026055.5495.585.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

CC'ing linux-ia64@vger.kernel.org. For those who haven't followed, this
is a discussion I'm having about the rework of mmu_gather I'm in, to
making sure I do the right thing as far as ia64 is concerned.

> I suspect I just wanted to use something stable, so I wouldn't have to
> check tlb->nr.  It looks like tlb->nr can be 0 or ~0 when nothing gets
> shot down, so I probably just didn't want to check for those
> conditions.  Maybe it'd be better to just check tlb->start_addr and if
> it's something other than ~0UL, go ahead and use tlb->start_addr and
> tlb->end_addr.
> 
> While looking over the code, it looks to me like tlb->need_flush never
> gets initialized (cleared to 0).  On the other hand, tlb->start_addr
> gets initialized with ~0UL both in tlb_gather_mmu() and
> ia64_tlb_flush_mmu().  Am I missing something?

tlb->nr is initialised in tlb_gather_mmu(). The ~0 trick is the "fast"
mode used when non-SMP.

Thing is, the start/end arguments passed to tlb_finish_mmu() tend to
cover more than really necessary. And you end up with your own
start_addr/end_addr tracking pretty much useless, since you re-do a
whole range flush at the end.

However, I think that you do need to do that because of a subtle issue
with the virtual mapping of the page tables themselves.

Basically, the generic freeing code first flushes all VMA's and thus all
PTEs, and then does a second pass with the page table pages themselves.

The problem is that if you get a racy access, you can end up with
somebody walking down a PGD/PUD/PMD all the way to a PTE page before
hitting the empty PTE and taking a fault. That means that even after the
pages have been unmapped (where the TLB flush will have flushes the TLB
entries for the virtual page tables), something can still bring in the
TLB translations for the page tables themselves, at least until the
PGD/PUD/PMD entries themselves have been cleared, which happens later.

I think the proper way to handle that is in fact to separate the
tracking of invalidated PTEs (flushes of user translations) from the
tracking of freed page tables (flushes of page table pages). The later
can be done by keeping a separate pair of start/end and by adding the
virtual address argument to tlb_free_pte(), which I intend to do.

So unless you see something wrong with that approach, I'll produce and
will try to test a patch doing just that.

In addition, however, I do have a question. I haven't tracked every bit
of MM code in ia64 land yet and I'm wondering how are the page table
translations faulted in ? via a SW miss handler ? Or some HW handler ?
Is there some locking ?

Because there's another possible issue that I can see: You aren't using
delayed batching nor anything like that to actually free the page
tables. __pte_free_tlb() & friends just directly do the freeing. Which
means those page can be given away to somebody else pretty much right
away.

However, what if that races with some other thread walking those page
tables ? I may very well be missing a bit here, but since we have 
that specific race on ppc64, I was wondering if you had it too...

Typically something like that: Thread A is unmapping/destroying page
tables and thread B is trying to access the area that is being freed at
the same time. The PTE have already been cleared and the TLB flushed,
but the page tables themselves haven't yet. We have A now in
free_pgtables(), freeing a PTE page.

	A					B
	gets into free_pte_range()		reads PMD entry			
	write 0 to the PMD entry
	frees PTE page
						reads PTE from PTE page

As you can see above, thread B can try to read a PTE from a freed PTE page
which may in fact already be filled with unrelated PTEs. I think this
doesn't happen on x86 due to some HW tricks with the tablewalk.

On ppc64 we fix that by deferring page table freeing using RCU. That
involves an allocation, so if that allocation fails, we fallback to
sending an IPI to all CPUs to make sure they're all out of whatever
TLB or hash miss handler may have been caching the old entry before
we free the page.

So I wonder if you have that problem too. If you do, an option is to
use the batch to also free the page table pages, but that's a bit of
a problem with the quicklists, or to use something aking to ppc64 use
of RCU which I may generalize.

Cheers,
Ben.

