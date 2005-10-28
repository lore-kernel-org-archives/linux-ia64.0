From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 28 Oct 2005 02:54:34 +0000
Subject: RE:  ia64 get_mmu_context patch
Message-Id: <200510280254.j9S2sYg12254@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200510271728.j9RHScS0002221922@kitche.zk3.dec.com>
In-Reply-To: <200510271728.j9RHScS0002221922@kitche.zk3.dec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Peter Keilty wrote on Thursday, October 27, 2005 10:28 AM
> Please find attached IA64 context_id patch and supporting data for your
> Review and consideration.
>  ...
> Lockstat Data:
> There are 4 sets of lockstat data, one each for loads of 40K,
> 30K, 20K and 40K with no fork test. The lockstat data shows
> that as loading increases the lock contention on the task
> lock with wrap_mmu_context and higher utilization of the
> ia64_ctx lock and the ia64_global_tlb_purge lock. 


Current implementation in wrap_mmu_context did not fully utilize
all the rid space at the time of wrap.  It finds first available
free range starting from ia64_ctx.next, presumably much smaller
than max_ctx.

Was the lock contention because of much more frequent wrap_mmu_context?
Ideally, it should only do one wrap when the entire rid space is
exhausted.  Current implementation in wrap_mmu_context is suboptimal
in performance.


>  wrap_mmu_context (struct mm_struct *mm)
>  { ....
> @@ -52,28 +74,23 @@
>  	ia64_ctx.limit = max_ctx + 1;
>  
>  	/*
> -	 * Scan all the task's mm->context and set proper safe range
> +	 * Scan the ia64_ctx bitmap and set proper safe range
>  	 */
> +repeat:
> +	next_ctx = find_next_zero_bit(ia64_ctx.bitmap, ia64_ctx.limit, ia64_ctx.next);
> +	if (next_ctx >= ia64_ctx.limit) {
> +		smp_mb();
> +		ia64_ctx.next = 300;	/* skip daemons */
> +		goto repeat;
> +	}
> +	ia64_ctx.next = next_ctx;

I like the bitmap thing.  But what's up with all this old range
finding code doing here?  You have a full bitmap that tracks used
ctx_id, one more bitmap can be added to track pending flush. Then at
the time of wrap, we can simply xor them to get full reusable rid.
With that, kernel will only wrap when entire rid space is exhausted.
I will post a patch.

- Ken

