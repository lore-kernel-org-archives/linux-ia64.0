From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 29 Jul 2003 22:26:05 +0000
Subject: RE: [PATCH] (2.4.x bk) efi_memmap_walk_uc
Message-Id: <marc-linux-ia64-105951767518735@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105883467032028@msgid-missing>
In-Reply-To: <marc-linux-ia64-105883467032028@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> On Tue, Jul 29, 2003 at 02:34:53PM -0700, Luck, Tony wrote:
> > Initially the UC allocator should be really, really basic.  Perhaps
> > just handing out pages, and without any "free" code to complicate it
> > (MCA code should only need to allocate an alternate min_state area
> > for each cpu to handle returning to a different context from the one
> > that was running when the fault was reported).
> 
> Page granularity would be fine here.  I'm not sure anything more
> complex would be required any time soon if ever.
> 
> We could like to be able to allocate from or near to a given node in
> NUMA configurations.  When allocating pages for MINSTATE areas you can
> then have that code try to allocate memory on the same node as the
> appropriate CPU.

We can do that ... but i hope that MCA error recovery isn't a common
enough path that allocating min_state from the correct node ever shows
up on anyone's performance radar!

> How about something like:
> 
>     void* ia64_alloc_uc_page(int nodeid);
>     void ia64_free_us_page(void*);
> 
> as a starting point (for non-NUMA the nodeid won't be interesting of
> course).

Looks ok.  Is the return value from alloc a physical address or a
region 6 virtual address?  I don't think that I care, so you can
pick whatever works best for fetchop (and if I later do care, then it's
my own fault for not planning ahead :-)

> Ideally freeing memory shouldn't be that hard and for fetchop
> certainly would be desirable.  We could probably get by with a naive
> bitmap allocator per-node or even one of wli's alternative bootmem
> allocator suggestions (massaged to suit).

Last wli alternative bootmem allocator that I looked at looked like
overkill for this (it had all sorts of balanced trees for fast insert
and delete).  Is fetchop likely to alloc/free a lot (i.e.
is performance of alloc/free critical)?  A simple list of <base,length>
pairs (or maybe <node,base,length> triples??) would work (unless you
are expecting hundreds of blocks of uncacheable memory, and a high
alloc/free rate.

-Tony
