From: Ingo Molnar <mingo@elte.hu>
Date: Tue, 20 Oct 2009 06:15:57 +0000
Subject: Re: Commit 34d76c41 causes linker errors on ia64 with NR_CPUS=4096
Message-Id: <20091020061557.GE8550@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <4ADB967A.4080707@suse.com> <alpine.LRH.2.00.0910200356340.20992@twin.jikos.cz> <alpine.LRH.2.00.0910200651510.20992@twin.jikos.cz>
In-Reply-To: <alpine.LRH.2.00.0910200651510.20992@twin.jikos.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jiri Kosina <jkosina@suse.cz>
Cc: Jeff Mahoney <jeffm@suse.com>, Peter Zijlstra <peterz@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org


* Jiri Kosina <jkosina@suse.cz> wrote:

> On Tue, 20 Oct 2009, Jiri Kosina wrote:
> 
> > > Commit 34d76c41 introduced the update_shares_data percpu, but it ends up
> > > causing problems on large ia64 machines. Specifically, ia64 is limited
> > > to 64k in percpu vars and with NR_CPUS@96, that ends up being 32k by
> > > itself. It ends up causing link errors since that is how ia64 enforces
> > > the 64k limit.
> > > 
> > > I can take a deeper look at finding a workable solution but thought I'd
> > > mention it in case you had ideas already.
> > 
> > I am adding some IA64 CCs, as the failure is solely caused by the ia64 
> > percpu implementation/pagefault handler optimization which requires the 
> > .percpu section area not be larger than 64k, which blows up with 34d76c41 
> > and NR_CPUS high enoufh (due to introduction of percpu array being 
> > size-dependent on NR_CPUS).
> 
> How about this one? (untested)
> 
> 
> 
> From: Jiri Kosina <jkosina@suse.cz>
> Subject: sched: move rq_weight data array out of .percpu
> 
> Commit 34d76c41 introduced percpu array update_shares_data, size of which 
> being proportional to NR_CPUS. Unfortunately this blows up ia64 for large 
> NR_CPUS configuration, as ia64 allows only 64k for .percpu section.
> 
> Fix this by allocating this array dynamically and keep only pointer to it 
> percpu.
> 
> Signed-off-by: Jiri Kosina <jkosina@suse.cz>
> --- 
>  kernel/sched.c |   15 +++++++--------
>  1 files changed, 7 insertions(+), 8 deletions(-)

Seems like an IA64 bug to me. It's _very_ easy to get more than 64K of 
percpu data - i'm wondering why IA64 only triggered it now? Sure 
lockdep/lockstat must have triggered it before.

	Ingo
