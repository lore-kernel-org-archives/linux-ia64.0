From: Tejun Heo <tj@kernel.org>
Date: Tue, 20 Oct 2009 13:58:20 +0000
Subject: Re: Commit 34d76c41 causes linker errors on ia64 with NR_CPUS=4096
Message-Id: <4ADDC1FC.8010903@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <4ADB967A.4080707@suse.com> <alpine.LRH.2.00.0910200356340.20992@twin.jikos.cz> <alpine.LRH.2.00.0910200651510.20992@twin.jikos.cz> <20091020061557.GE8550@elte.hu> <alpine.LSU.2.00.0910200820500.8582@wotan.suse.de> <20091020063555.GJ8550@elte.hu> <4ADDB640.4020707@suse.com> <20091020134308.GA3930@elte.hu> <4ADDC1C6.9090305@kernel.org>
In-Reply-To: <4ADDC1C6.9090305@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>
Cc: Jeff Mahoney <jeffm@suse.com>, Jiri Kosina <jkosina@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>

Of course I forgot to actually cc.  Cc'ing and quoting whole body.
Sorry.

Tejun Heo wrote:
> Ingo Molnar wrote:
>> IA64 should be fixed really - we can get past the 64K of percpu data 
>> limit anytime we add a few more pages of per-cpu data to the kernel - 
>> the scheduler just happened to be the one to cross it this time.
> 
> Christoph (cc'd hi!) was talking about re-purposing one of reserved
> generic registers (for current or something, I don't remember the
> details) for percpu base and just getting the original one via percpu
> access.  With that we should be able to lift the limitation without
> much performance penalty.
> 
>> Saying that all static percpu data must be below 64K, which will only be 
>> noticed once IA64 gets its testing act together months after it's been 
>> created is silly. If you want to enforce such a limit make it testable 
>> in a _timely_ fashion. Or fix the limit really.
> 
> Yeah, the problem probably was that it only pushes the perpcu area
> very slightly over the limit depending on configuration so it's not
> too surprising that it didn't get reported for some time.  Also, the
> linker script thing is a sanity check which is intentionally put there
> to trigger when this happens so that it can be found out clearly
> during build time.
> 
> In the long term, it will be a good idea to lift that restriction.
> That said, I really don't think we should be adding NR_CPUS sized
> array to percpu area either.  Things like that quickly become very
> scary with N*1024 cpu configurations.


-- 
tejun
