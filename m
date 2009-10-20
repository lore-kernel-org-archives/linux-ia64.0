From: Ingo Molnar <mingo@elte.hu>
Date: Tue, 20 Oct 2009 13:43:08 +0000
Subject: Re: Commit 34d76c41 causes linker errors on ia64 with NR_CPUS=4096
Message-Id: <20091020134308.GA3930@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <4ADB967A.4080707@suse.com> <alpine.LRH.2.00.0910200356340.20992@twin.jikos.cz> <alpine.LRH.2.00.0910200651510.20992@twin.jikos.cz> <20091020061557.GE8550@elte.hu> <alpine.LSU.2.00.0910200820500.8582@wotan.suse.de> <20091020063555.GJ8550@elte.hu> <4ADDB640.4020707@suse.com>
In-Reply-To: <4ADDB640.4020707@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jeff Mahoney <jeffm@suse.com>
Cc: Jiri Kosina <jkosina@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>


* Jeff Mahoney <jeffm@suse.com> wrote:

> On 10/20/2009 02:35 AM, Ingo Molnar wrote:
> > 
> > * Jiri Kosina <jkosina@suse.cz> wrote:
> > 
> >> On Tue, 20 Oct 2009, Ingo Molnar wrote:
> >>
> >>>> Commit 34d76c41 introduced percpu array update_shares_data, size of which 
> >>>> being proportional to NR_CPUS. Unfortunately this blows up ia64 for large 
> >>>> NR_CPUS configuration, as ia64 allows only 64k for .percpu section.
> >>>>
> >>>> Fix this by allocating this array dynamically and keep only pointer to it 
> >>>> percpu.
> >>>>
> >>>> Signed-off-by: Jiri Kosina <jkosina@suse.cz>
> >>>> --- 
> >>>>  kernel/sched.c |   15 +++++++--------
> >>>>  1 files changed, 7 insertions(+), 8 deletions(-)
> >>>
> >>> Seems like an IA64 bug to me. 
> >>
> >> IA64 guys actually use that as some kind of optimization for fast 
> >> access to the percpu data in their pagefault handler, as far as I 
> >> know.
> > 
> > Still looks like a bug if it causes a breakage (linker error) on IA64, 
> > and if the 'fix' (i'd call it a workaround) causes a (small but nonzero) 
> > performance regression on other architectures.
> 
> The linker error isn't a bug, it's enforcement. The ia64 linker script 
> explicitly rewinds the location pointer back to the start of 
> .data.percpu + 64k to start the .data section to cause the error if 
> .data.percpu is larger than 64k.

Since every other SMP architecture manages to support more than 64K of 
pecpu data, this is clearly an ugly, self-inflicted limitation of IA64 
that has now escallated into a link failure.

Now, 34d76c41 could certainly be improved in a way that works around the 
IA64 problem too: we can allocate the data dynamically as long as the 
proper percpu allocator is used (not kmalloc as in the patch in this 
thread). But arguing that the current IA64 64K limit behavior is 
anything but very broken is rather shortsighted.

IA64 should be fixed really - we can get past the 64K of percpu data 
limit anytime we add a few more pages of per-cpu data to the kernel - 
the scheduler just happened to be the one to cross it this time.

The scheduler change in 34d76c41 has been done two months ago and has 
been upstream for a month, so this compaint is rather late and at 
minimum a certain degree of honesty about the situation is warranted.

Saying that all static percpu data must be below 64K, which will only be 
noticed once IA64 gets its testing act together months after it's been 
created is silly. If you want to enforce such a limit make it testable 
in a _timely_ fashion. Or fix the limit really.

	Ingo
