From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 29 Jan 2004 00:38:39 +0000
Subject: Re: [PATCH] - Improve SN2 TLB flushing algorithms
Message-Id: <16408.22031.116929.993415@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040128205912.GA27401@sgi.com>
In-Reply-To: <20040128205912.GA27401@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jack,

As others pointed out, the CONFIG_NUMA are rather ugly here:

 > @@ -106,6 +107,9 @@
 >  		/* re-check, now that we've got the lock: */
 >  		context = mm->context;
 >  		if (context = 0) {
 > +#ifdef CONFIG_NUMA
 > +			cpus_clear(mm->cpu_vm_mask);
 > +#endif
 >  			if (ia64_ctx.next >= ia64_ctx.limit)
 >  				wrap_mmu_context(mm);
 >  			mm->context = context = ia64_ctx.next++;
 > @@ -170,6 +174,10 @@
 >  	do {
 >  		context = get_mmu_context(mm);
 >  		MMU_TRACE('A', smp_processor_id(), mm, context);
 > +#ifdef CONFIG_NUMA
 > +		if (!cpu_isset(smp_processor_id(), mm->cpu_vm_mask))
 > +			cpu_set(smp_processor_id(), mm->cpu_vm_mask);
 > +#endif
 >  		reload_context(context);
 >  		MMU_TRACE('a', smp_processor_id(), mm, context);
 >  		/* in the unlikely event of a TLB-flush by another thread, redo the load: */

I'd be OK with unconditionally maintaining cpu_vm_mask but only if
cpu_vm_mask falls into the same cache-line as mm->context.  AFAIK,
this _used_ to be the case, but recently some (large) members were
added between "cpu_vm_mask" and "context".  I suspect that's just a
mistake.  Could you float a patch on lkml to fix this?

	--david
