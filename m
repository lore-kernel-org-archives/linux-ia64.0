From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 29 Jul 2003 21:34:53 +0000
Subject: RE: [PATCH] (2.4.x bk) efi_memmap_walk_uc
Message-Id: <marc-linux-ia64-105951492415532@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105883467032028@msgid-missing>
In-Reply-To: <marc-linux-ia64-105883467032028@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> > It creates a "node_fetchops" structure for _every_ uncached block of
> > address space?  Will there be problems if that address space/memory
> > is used for other purposes?
> 
> No --- because there are no other users...  the code was almost
> certainly written a long time ago to solve an SN specific purpose and
> has been carried around in the form I presented.
> 
> I fully admit that in a general sense this code isn't workable but I
> think perhaps the concept of some kind of UC allocator might be.  If
> such a thing existed I'm quite sure we would have the fetchop driver
> ported to use it.

I definitely like the idea of a UC allocator that lives below the
level of the fetchop driver that can hand it whatever pieces of
uncacheable memory that it needs.  When MCA eventually gets sophisticated
enough to need to allocate more min_state areas, there will be a second
user ... and I hope that we are too far away from being there.

Initially the UC allocator should be really, really basic.  Perhaps
just handing out pages, and without any "free" code to complicate it
(MCA code should only need to allocate an alternate min_state area for
each cpu to handle returning to a different context from the one that
was running when the fault was reported).

> > I think what we really want here is two bitmasks: one telling us
> > which bits we care about and one telling us what values those bits
> > should be set to.
> 
> Yes.  But does that really make the code more suitable for merging or
> is that merely a small step towards the larger picture?
> 
> > Can you work with Tony on this?  Since he's Mr. MCA (you OK with
> > this title, Tony? ;-) and since we'll have to map the MINSTATE area
> > UC, I think we want to make sure that the interface can handle all
> > of this.
> 
> Sure, I'm happy with that.  I had considered as for UC we could try to
> encourage everyone to have the MINSTATE containing granule to be all
> UC and perhaps for generic kernels compromise on 16MB granules?
> That's a different issue entirely though.

-Tony
