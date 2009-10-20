From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 20 Oct 2009 09:21:14 +0000
Subject: Re: Commit 34d76c41 causes linker errors on ia64 with NR_CPUS=4096
Message-Id: <1256030474.17774.36.camel@laptop>
List-Id: <linux-ia64.vger.kernel.org>
References: <4ADB967A.4080707@suse.com>
	 <alpine.LRH.2.00.0910200356340.20992@twin.jikos.cz>
	 <alpine.LRH.2.00.0910200651510.20992@twin.jikos.cz>
	 <20091020061557.GE8550@elte.hu>
In-Reply-To: <20091020061557.GE8550@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>
Cc: Jiri Kosina <jkosina@suse.cz>, Jeff Mahoney <jeffm@suse.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

On Tue, 2009-10-20 at 08:15 +0200, Ingo Molnar wrote:
> 
> Seems like an IA64 bug to me. It's _very_ easy to get more than 64K of 
> percpu data - i'm wondering why IA64 only triggered it now? Sure 
> lockdep/lockstat must have triggered it before.

I seem to remember people wanting to make lockstat data dynamically
allocated because of this.

But then, I'm not sure ia64 actually has lockdep support.

