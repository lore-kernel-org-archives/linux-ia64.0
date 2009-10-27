From: Tejun Heo <tj@kernel.org>
Date: Tue, 27 Oct 2009 12:55:27 +0000
Subject: Re: [PATCH 1/2] percpu: allow pcpu_alloc() to be called with IRQs
Message-Id: <4AE6EDBF.7040905@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <alpine.LSU.2.00.0910271328340.19847@wotan.suse.de>
In-Reply-To: <alpine.LSU.2.00.0910271328340.19847@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jiri Kosina <jkosina@suse.cz>
Cc: Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, Jeff Mahoney <jeffm@suse.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

Jiri Kosina wrote:
> pcpu_alloc() and pcpu_extend_area_map() perform a series of
> spin_lock_irq()/spin_unlock_irq() calls, which make them unsafe
> with respect to being called from contexts which have IRQs off.
> 
> This patch converts the code to perform save/restore of flags instead,
> making pcpu_alloc() (or __alloc_percpu() respectively) to be called
> from early kernel startup stage, where IRQs are off.
> 
> This is needed for proper initialization of per-cpu rq_weight data from
> sched_init().
> 
> Signed-off-by: Jiri Kosina <jkosina@suse.cz>

Acked-by: Tejun Heo <tj@kernel.org>

I'll wait for response on the series and push it through percpu#fixes
tomorrow if there's no objection.

Thanks.

-- 
tejun
