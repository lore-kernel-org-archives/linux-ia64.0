From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 28 Oct 2005 17:56:40 +0000
Subject: RE: ia64 get_mmu_context patch
Message-Id: <200510281756.j9SHueg23170@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200510271728.j9RHScS0002221922@kitche.zk3.dec.com>
In-Reply-To: <200510271728.j9RHScS0002221922@kitche.zk3.dec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Peter Keilty wrote on Friday, October 28, 2005 7:50 AM
> The original code did use full range,

Yes or no, first call to wrap_mmu_context occurs at
ia64_ctx.next equals 2^15 (32768), then second call occurs
at 2097152.  First one is needlessly too early.  One can say
it uses full range.  But the real thing I'm after is number
of ctx_id allocation in between global tlb flush.  Kernel
did a global flush before entire 2M ctx_id is used.  That
is not a "full range" (as in use up all ctx_id before a
global tlb flush).


> but once wrapping
> occurred yes ranging was used by setting limit. The ranging
> did go out to the the max_limit on follow on calls, but the
> range size could small Causing more calls to wrap_mmu_context.

Exactly, ia64_ctx.next can only increment, while ia64_ctx.limit
will move down.  The code is effectively find_next_hole(), which
isn't equivalent to find_largest_hole().  It could have a
pathological worst case that you call wrap_mmu_context with only
one ctx_id allocation.  Worse, since next and limit pair can not
cross a wrap around point, when next approach the end of the ctx_id
space, the range it find is much smaller at that instance (though
that should only occur once every 2M ctx id allocation).


> > Was the lock contention because of much more frequent 
> > wrap_mmu_context?
> 
> Indirectly, The real reason was the time used to task_list walking 
> derefencing pointers (tens of thousands of processes) trying to find 
> a unused rid. 

What is the average number of ctx_id allocation between
wrap_mmu_context call?  That would tell us how efficient the current
find_next_hole() is.

- Ken

