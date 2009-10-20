From: Tejun Heo <tj@kernel.org>
Date: Tue, 20 Oct 2009 05:21:21 +0000
Subject: Re: Commit 34d76c41 causes linker errors on ia64 with NR_CPUS=4096
Message-Id: <4ADD48D1.1040701@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <4ADB967A.4080707@suse.com> <alpine.LRH.2.00.0910200356340.20992@twin.jikos.cz> <alpine.LRH.2.00.0910200651510.20992@twin.jikos.cz>
In-Reply-To: <alpine.LRH.2.00.0910200651510.20992@twin.jikos.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jiri Kosina <jkosina@suse.cz>
Cc: Jeff Mahoney <jeffm@suse.com>, Peter Zijlstra <peterz@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

Hello,

Jiri Kosina wrote:
> How about this one? (untested)
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

If the structure can be dynamically allocated at all, just using
percpu_alloc() to allocate the whole thing should solve it with the
correct numa locality.

Thanks.

-- 
tejun
