From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 29 Jul 2003 22:47:34 +0000
Subject: RE: [PATCH] (2.4.x bk) efi_memmap_walk_uc
Message-Id: <marc-linux-ia64-105951888419883@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105883467032028@msgid-missing>
In-Reply-To: <marc-linux-ia64-105883467032028@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> That sounds pretty good.  Even a naive bitmap allocator would probably
> work initially.  Might we ever want to allocate 2+ pages?  Forcing all
> allocations to be a single page makes many things easier.

min_state areas for MCA will be smaller than a page ... so *my* use
of this allocator doesn't require multi-page.

You know best whether fetchop() will ever want more than a page.

So far, nobody else has leapt out of the woods to claim any other
uses for UC memory (that's a cue for anyone waiting to jump into this
discussion).

We could plan ahead for hypothetical future multi-page users by
defining a "size" argument to alloc/free, but keep our (your) life
simple for now by only implementing the one-page-at-a-time usage
model.

-Tony
