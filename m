From: Ingo Molnar <mingo@elte.hu>
Date: Fri, 29 Jul 2005 09:45:19 +0000
Subject: Re: Add prefetch switch stack hook in scheduler function
Message-Id: <20050729094519.GA12975@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050729070447.GA3032@elte.hu> <200507290722.j6T7Mig07477@unix-os.sc.intel.com> <20050729082826.GA6144@elte.hu> <20050729100257.A10345@flint.arm.linux.org.uk>
In-Reply-To: <20050729100257.A10345@flint.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russell King <rmk+lkml@arm.linux.org.uk>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, Keith Owens <kaos@ocs.com.au>, David.Mosberger@acm.org, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org


* Russell King <rmk+lkml@arm.linux.org.uk> wrote:

> On Fri, Jul 29, 2005 at 10:28:26AM +0200, Ingo Molnar wrote:
> > @@ -2872,10 +2878,10 @@ go_idle:
> >  	/*
> >  	 * Prefetch (at least) a cacheline below the current
> >  	 * kernel stack (in expectation of any new task touching
> > -	 * the stack at least minimally), and a cacheline above
> > -	 * the stack:
> > +	 * the stack at least minimally), and at least a cacheline
> > +	 * above the stack:
> >  	 */
> > -	prefetch_range(kernel_stack(next) - MIN_KERNEL_STACK_FOOTPRINT,
> > +	prefetch_range(kernel_stack(next) - L1_CACHE_BYTES,
> >  		       MIN_KERNEL_STACK_FOOTPRINT + L1_CACHE_BYTES);
> 
> This needs to ensure that we don't prefetch outside the page of the 
> kernel stack - otherwise we risk weird problems on architectures which 
> support prefetching but not DMA cache coherency.

ok, agreed. Since kernel_stack(next) defaults to 'next', we go below 
that structure which has unknown coherency attributes. I guess the 
easiest solution would be to default kernel_stack(next) to '(void *)next 
+ L1_CACHE_BYTES'? That way the default prefetching would happen for the 
[next...next+2*L1_BYTES] range.

	Ingo
