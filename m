From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 16 Feb 2005 22:48:03 +0000
Subject: RE: A proposal for fixing the current problems with page tables.
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02EDE732@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050216202041.GB13528@lnx-holt.americas.sgi.com>
In-Reply-To: <20050216202041.GB13528@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Robin Holt wrote:
>I would like to propose the following changes to how page tables are
>used on ia64.
>
>1) pgd, pmd, and pte free should return the zeroed page to the allocator
>for reuse.  Currently, you can read "the allocator" as quicklists.
>I am going to propose slab.

Not too radical ... we already return the zeroed page to the allocator.
Using the slab sounds plausible, and may give extra flexibility, plus
you get the extra features from the slab for free.

>2) Use a zeroed slab for quicklist allocations instead of per cpu
>quicklists.  This makes cache freeing take less drastic measures when
>shrinking the size.  As an example of the issue at hand, on some of
>our larger configurations, the quicklist high water mark ends up being
>more memory than the node contains.

Setting a memory limit based on total system memory, and then allocating
per-node is definitely a bad idea, and will lead to weird cases as you
describe.

>The high water/low water issue is avoided by slabs.

Perhaps better to say that slab already includes code to manage this.

>3) Introduce 4 level page tables.  I am leaning strongly toward doing this
>as 4 16k page tables max (size depending upon system PAGE_SIZE >= 16K).

Must be configurable.  David already pointed out that most users don't need
this, so the overhead of a 4-level table is just a waste of memory and
cpu cycles for "small" systems (the dividing line between small and large
in this context is somewhere in the modest number of terabytes).

If you are going to de-couple the size of page tables from the underlying
page size, then it might be interesting to experiment with other options.
For instance, I think that I'd be happy with 3-level tables sized at 4K
with my 16K pagesize.  That would still give me 41 virtual bits to play
with ... enough for "tiny" systems with only double-digits of gigabytes.

Oops ... for the VHPT to work, the PTE level tables have to be a full
page.  So you can't do 16K at all 4 levels on a 64K page system.  But
sizes of pgd/pud/pmd levels should all be completely under s/w control.
Making these levels all the same size isn't required, but does allow
them to trade freely, so you get one less place for memory to pile up
on free lists.

>4) Make the slab allocations node aware.  The wording is intentionally
>deceptive.  I have not looked at the slab code in quite some time,
>but just a quick think through makes me lean towards having a slab per
>controlling node instead of making the slab code understand nodes.

There have been some efforts in this direction.  Nitin Kamble from
Intel posted some patches a while back.  One of the trickier issues
is working out how to efficiently free an object back to its owning
node when the free is executing on a different node.  To do this you
need to be able to have a fast way to tell which node some memory belongs
to, and you also have to bypass the per-cpu lists in the slab.

Having a slab per node would save you the hair-loss involved with
maing the slab fully node aware, but would have very odd effects when
you allocate from one node, and then free from another.  E.g. your
process starts up on node3, and allocates many pgd/pud/pmd/pte.  Then
for some reason moves to cpu36 on node8 to die.  Your code to free
these tables will notice that they belong to node3, so call kfree()
to put them back on the node3 slab ... but the pages will actually
end up on the percpu list that belongs to cpu36 of that slab.  Where
they will sit for a long, long time (since cpu36 will never try to
allocate a page table from the node3 slab ... it will only ever allocate
from its homenode slab: node8).

>Is this the right direction to proceed?  Are there other issues with page
>tables which I have missed or at the very least glossed over too quickly?

The only missed issue I've seen so far is that the pte level
has to be a full page for the VHPT walker to work.

-Tony
