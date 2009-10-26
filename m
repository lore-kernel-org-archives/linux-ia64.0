From: Jiri Kosina <jkosina@suse.cz>
Date: Mon, 26 Oct 2009 16:38:07 +0000
Subject: Re: Commit 34d76c41 causes linker errors on ia64 with NR_CPUS=4096
Message-Id: <alpine.LRH.2.00.0910261738020.25075@twin.jikos.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <4ADD54D4.70808@kernel.org> <4ADD5530.3050107@kernel.org> <alpine.LSU.2.00.0910200826220.8582@wotan.suse.de> <4ADDC69A.5000701@suse.com> <4ADDCDED.6060706@suse.com> <20091021061109.GA27195@elte.hu> <4ADF2691.7070304@kernel.org>
 <57C9024A16AD2D4C97DC78E552063EA3E337CF79@orsmsx505.amr.corp.intel.com> <alpine.LSU.2.00.0910221640430.8582@wotan.suse.de> <57C9024A16AD2D4C97DC78E552063EA3E337D94C@orsmsx505.amr.corp.intel.com> <20091023075151.GB10067@elte.hu>
 <alpine.LSU.2.00.0910232127410.9469@wotan.suse.de>
In-Reply-To: <alpine.LSU.2.00.0910232127410.9469@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>
Cc: "Luck, Tony" <tony.luck@intel.com>, Tejun Heo <tj@kernel.org>, Jeff Mahoney <jeffm@suse.com>, Peter Zijlstra <peterz@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Yu, Fenghua" <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

On Fri, 23 Oct 2009, Jiri Kosina wrote:

> > > > Tony, is the change that will eventually have to be made to ia64 
> > > > pagefault handler too intrusive for -rc6, and should we rather go 
> > > > with my workaround instead, and try to find something proper for 
> > > > 2.6.33?
> > > 
> > > Using __alloc_percpu() rather than static declaration looks to be the 
> > > right fix here.  Not a "workaround".
> > 
> > It is a workaround for the IA64 build failure.
> > 
> > It's also an improvement of the scheduler code (we generally try to 
> > eliminate NR_CPUs scaling of allocations) - but code improvements need 
> > to happen much sooner than -rc6/-rc7.
> 
> Unfortunately refactoring the ia4 pagefault handler would require some 
> refactoring in order to eliminate the 64k limitation, as far as I know, 
> which doesn't seem to be feasible for this timeframe either.
> 
> So if I personally have to chose from these two options, I'd prefer my 
> patch for 2.6.32 and it'd be helpful if ia64 people could look into doing 
> something with the 64k limit for 2.6.33.
> 
> Acceptable for everyone? Ingo/Peter, will you merge this asap please, so 
> that we don't miss 2.6.32 with it?

This stil seems unfixed in the relevant trees I have checked ... anyone 
has strong objections to this, which cause the patch to be delayed?

Thanks,

-- 
Jiri Kosina
SUSE Labs, Novell Inc.

