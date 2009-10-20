From: Jiri Kosina <jkosina@suse.cz>
Date: Tue, 20 Oct 2009 07:17:05 +0000
Subject: Re: Commit 34d76c41 causes linker errors on ia64 with NR_CPUS=4096
Message-Id: <alpine.LSU.2.00.0910200915510.8582@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <4ADB967A.4080707@suse.com> <alpine.LRH.2.00.0910200356340.20992@twin.jikos.cz> <alpine.LRH.2.00.0910200651510.20992@twin.jikos.cz> <20091020061557.GE8550@elte.hu> <alpine.LSU.2.00.0910200820500.8582@wotan.suse.de> <20091020063555.GJ8550@elte.hu>
 <4ADD62CD.3080208@kernel.org>
In-Reply-To: <4ADD62CD.3080208@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tejun Heo <tj@kernel.org>
Cc: Ingo Molnar <mingo@elte.hu>, Jeff Mahoney <jeffm@suse.com>, Peter Zijlstra <peterz@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

On Tue, 20 Oct 2009, Tejun Heo wrote:

> Extending the first chunk size shouldn't be difficult on ia64 but other 
> than this, there still is a lot of room left with the current 64k limit, 
> so I think we should be safe for a while.  BTW, I also am curious how 
> lockdep has been coping with the limit.

There is no lockdep on ia64, and we don't have such restriction on .percpu 
section on any other architecture which supports lockdep, right?

-- 
Jiri Kosina
SUSE Labs, Novell Inc.
