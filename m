From: Tejun Heo <tj@kernel.org>
Date: Tue, 20 Oct 2009 07:12:13 +0000
Subject: Re: Commit 34d76c41 causes linker errors on ia64 with NR_CPUS=4096
Message-Id: <4ADD62CD.3080208@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <4ADB967A.4080707@suse.com> <alpine.LRH.2.00.0910200356340.20992@twin.jikos.cz> <alpine.LRH.2.00.0910200651510.20992@twin.jikos.cz> <20091020061557.GE8550@elte.hu> <alpine.LSU.2.00.0910200820500.8582@wotan.suse.de> <20091020063555.GJ8550@elte.hu>
In-Reply-To: <20091020063555.GJ8550@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>
Cc: Jiri Kosina <jkosina@suse.cz>, Jeff Mahoney <jeffm@suse.com>, Peter Zijlstra <peterz@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

Hello,

Ingo Molnar wrote:
> Still looks like a bug if it causes a breakage (linker error) on IA64, 

In a sense, yes.

> and if the 'fix' (i'd call it a workaround) causes a (small but nonzero) 
> performance regression on other architectures.

Yeah, by small amount but also reduces memory usage quite a bit.  For
this case, I think dynamic allocation is actually the right thing to
do.

Extending the first chunk size shouldn't be difficult on ia64 but
other than this, there still is a lot of room left with the current
64k limit, so I think we should be safe for a while.  BTW, I also am
curious how lockdep has been coping with the limit.

Thanks.

-- 
tejun
