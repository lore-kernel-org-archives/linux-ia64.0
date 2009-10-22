From: Jiri Kosina <jkosina@suse.cz>
Date: Thu, 22 Oct 2009 14:49:04 +0000
Subject: RE: Commit 34d76c41 causes linker errors on ia64 with NR_CPUS=4096
Message-Id: <alpine.LSU.2.00.0910221640430.8582@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <4ADB967A.4080707@suse.com> <alpine.LRH.2.00.0910200356340.20992@twin.jikos.cz> <alpine.LRH.2.00.0910200651510.20992@twin.jikos.cz> <4ADD48D1.1040701@kernel.org> <alpine.LSU.2.00.0910200756300.8582@wotan.suse.de> <4ADD54D4.70808@kernel.org>
 <4ADD5530.3050107@kernel.org> <alpine.LSU.2.00.0910200826220.8582@wotan.suse.de> <4ADDC69A.5000701@suse.com> <4ADDCDED.6060706@suse.com> <20091021061109.GA27195@elte.hu> <4ADF2691.7070304@kernel.org>
 <57C9024A16AD2D4C97DC78E552063EA3E337CF79@orsmsx505.amr.corp.intel.com>
In-Reply-To: <57C9024A16AD2D4C97DC78E552063EA3E337CF79@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@elte.hu>, Jeff Mahoney <jeffm@suse.com>, Peter Zijlstra <peterz@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Yu, Fenghua" <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

On Wed, 21 Oct 2009, Luck, Tony wrote:

> But ... the architecturally supported page sizes go up by powers of 4, 
> so next choice from 64K is 256K then 1M, 4M, etc.  This is also requires 
> an edit of source code and re-compile.  We could easily make it a config 
> option ... but that is still inconvenient.
> 
> The bloat introduced by adding percpu variables is multiplied by NR_CPUS 
> ... and in my case that is 4096.  It is easy to just shrug this off and 
> say that such big systems have plenty of memory anyway, but the case 
> that led to this issue (adding a percpu object that included a [NR_CPUS] 
> array) shows that, IMHO, people are do not care enough about the bloat.
> 
> I suspect that if I just increase the percpu area to 256K or 1M, I'll 
> see this same issue when someone adds:
> 
> struct foo {
>        char buf[NR_CPUS][PAGE_SIZE];
> };
> DECLARE_PER_CPU(struct foo, bar);
> 
> which needs 4k * 64k = 256M of per-cpu space ... i.e. 1T total.
> 
> If such code is going to be deemed acceptable, then we do need
> to move away from the ia64 TLB mapped percpu area.

Well, I must say I slightly agree that my gut feeling is that we should 
try to avoid arrays which size depends on NR_CPUS as much as possible.

Now, what to do for 2.6.32? We definitely need some kind of fix for this, 
otherwise the Altix guys would kill us.

Tony, is the change that will eventually have to be made to ia64 pagefault 
handler too intrusive for -rc6, and should we rather go with my workaround 
instead, and try to find something proper for 2.6.33?

Pure revert of 34d76c41 isn't possible as well, as it fixes a real bug.

-- 
Jiri Kosina
SUSE Labs, Novell Inc.
