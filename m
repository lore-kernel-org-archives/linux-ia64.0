From: William Lee Irwin III <wli@holomorphy.com>
Date: Thu, 19 Aug 2004 00:01:51 +0000
Subject: Re: page fault fastpath patch v2: fix race conditions, stats for 8,32     and    512 cpu SMP
Message-Id: <20040819000151.GU11200@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <2uexw-1Nn-1@gated-at.bofh.it> <2uCTq-2wa-55@gated-at.bofh.it> <pan.2004.08.18.23.50.13.562750@umich.edu>
In-Reply-To: <pan.2004.08.18.23.50.13.562750@umich.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rajesh Venkatasubramanian <vrajesh@umich.edu>
Cc: Hugh Dickins <hugh@veritas.com>, "David S. Miller" <davem@redhat.com>, raybry@sgi.com, ak@muc.de, benh@kernel.crashing.org, manfred@colorfullife.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

William Lee Irwin III wrote:
>> It also protects against vma tree modifications in mainline, but rmap.c
>> shouldn't need it for vmas anymore, as the vma is rooted to the spot by
>> mapping->i_shared_lock for file pages and anon_vma->lock for anonymous.

On Wed, Aug 18, 2004 at 07:50:21PM -0400, Rajesh Venkatasubramanian wrote:
> If I am reading the code correctly, then without page_table_lock
> in page_referenced_one(), we can race with exit_mmap() and page 
> table pages can be freed under us.

exit_mmap() has removed the vma from ->i_mmap and ->mmap prior to
unmapping the pages, so this should be safe unless that operation
can be caught while it's in progress.


William Lee Irwin III wrote:
>> Fortunately, spare bits aren't strictly necessary, and neither is
>> cmpxchg. A single invalid value can serve in place of a bitflag. When
>> using such an invalid value, just xchg()'ing it and looping when the
>> invalid value is seen should suffice. This holds more generally for all
>> radix trees, not just pagetables, and happily xchg() or emulation
>> thereof is required by core code for all arches.

On Wed, Aug 18, 2004 at 07:50:21PM -0400, Rajesh Venkatasubramanian wrote:
> Good point. 
> Another solution may be to use the unused bytes (->lru or
> ->private) in page table "struct page" as bit_spin_locks. We can 
> use a single bit to protect a small set of ptes (8, 16, or 32).

In general the bitwise operations are more expensive than ordinary
spinlocks, and a separately-allocated spinlock (not necessarily
kmalloc()'d, sitting in struct page also counts, that is, separate from
the pte) introduces another cacheline to be touched where with in-place
locking of the pte only the pte's cacheline is needed.


-- wli
