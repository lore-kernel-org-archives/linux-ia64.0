From: Christopher Wedgwood <cw@sgi.com>
Date: Tue, 29 Jul 2003 22:35:16 +0000
Subject: Re: [PATCH] (2.4.x bk) efi_memmap_walk_uc
Message-Id: <marc-linux-ia64-105951824119372@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105883467032028@msgid-missing>
In-Reply-To: <marc-linux-ia64-105883467032028@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jul 29, 2003 at 03:26:05PM -0700, Luck, Tony wrote:

> We can do that ... but i hope that MCA error recovery isn't a common
> enough path that allocating min_state from the correct node ever
> shows up on anyone's performance radar!

True.

> Looks ok.  Is the return value from alloc a physical address or a
> region 6 virtual address?

I guess strictly speaking it should be a u64 for pa.  We don't use a
specific type for physical addresses elsewhere do we?

> I don't think that I care, so you can pick whatever works best for
> fetchop (and if I later do care, then it's my own fault for not
> planning ahead :-)

I think we should just define pa since that's the units of the EFI
memory map...  and also define the minimum allocation granularity to
be EFI_PAGE_SIZE for the same reason.

> Last wli alternative bootmem allocator that I looked at looked like
> overkill for this (it had all sorts of balanced trees for fast
> insert and delete).

Heh, that is over kill.  I meant the one before that :)

> Is fetchop likely to alloc/free a lot (i.e.  is performance of
> alloc/free critical)?

I'm not sure how often it will free and/or alloc.  I'm not sure it
should be performance critical though so long as alloc/free work
reliably.

> A simple list of <base,length> pairs (or maybe <node,base,length>
> triples??) would work (unless you are expecting hundreds of blocks
> of uncacheable memory, and a high alloc/free rate.

That sounds pretty good.  Even a naive bitmap allocator would probably
work initially.  Might we ever want to allocate 2+ pages?  Forcing all
allocations to be a single page makes many things easier.


  --cw
