From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 08 May 2002 19:21:27 +0000
Subject: RE: [Linux-ia64] new kernel patch (relative to 2.4.18)
Message-Id: <marc-linux-ia64-105590701905555@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905293@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905293@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 8 May 2002 11:25:08 -0700 , "Luck, Tony" <tony.luck@intel.com> said:

  Tony> David Mosberger wrote:
  >> If you look at the patch, you'll also see that I started merging
  >> the "mem_map in virtual memory" patch (CONFIG_VIRTUAL_MEM_MAP),
  >> which is currently needed on zx1 platforms with >1GB of memory.
  >> However, the merge isn't complete and the new code isn't working
  >> yet.

  Tony> When I started working on a new discontigmem patch for ia64,
  Tony> Kanoj Sarcar dissuaded me from a virtual mem_map with a lot of
  Tony> fast handwaving on the cost of TLB faults to access page
  Tony> structures.  He stated (and I agreed) that there wasn't much
  Tony> reason to expect good locality of reference to page structs
  Tony> ... so this could have a measurable impact.  Sadly, neither of
  Tony> us actually made any measurements to back up this belief.

  Tony> Have you looked at the possible performance effect of this
  Tony> change?

The person who wrote this code (John Marvin) did look into this and
for the test he looked at (which included lmbench and kernel
compilation), couldn't find a noticable performance difference.

Nevertheless, I'm not completely comfortable with this approach.  The
reason is that (a) it's not completely general (there could be machine
configurations where the mem_map is so large that it would exceed the
mappable space in region 5) and (b) increasing the TLB pressure is
just about the last thing I want to do (I'm not just worried about the
cost of accessing mem_map per se, but about thrashing the TLB and
kicking out more useful translations).

On the other hand, the virtual mem_map implementation has a compelling
simplicity to it and is more general than most everything else I have
seen so far.

  Tony> Would the discontigmem patch meet the needs of the zx1
  Tony> platform?

The patches I have seen so far always assume that you *know* where the
holes are.  That just doesn't cut it.  DIG makes absolutely no
guarantees about the physical memory layout and we need a kernel that
can work on all (reasonable) DIG machines.

There have been discussions on this topic on the lkml recently and
different solutions have been proposed.  I don't really care too much
which solution is used in the end as long as it is able to accommodate
arbitrary physical layouts and has no dramatic performance impact.
For now, the virtual mem-map approach is working (modulo my merging
goofs) and it should be interesting to compare it to other approaches.

	--david

