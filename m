From: Peter Zijlstra <peterz@infradead.org>
Date: Thu, 07 Feb 2019 19:48:28 +0000
Subject: Re: [PATCH-tip 04/22] locking/rwsem: Remove arch specific rwsem files
Message-Id: <20190207194828.GC32534@hirez.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1549566446-27967-1-git-send-email-longman@redhat.com>
 <1549566446-27967-5-git-send-email-longman@redhat.com>
 <20190207193656.GF32511@hirez.programming.kicks-ass.net>
In-Reply-To: <20190207193656.GF32511@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Waiman Long <longman@redhat.com>
Cc: linux-arch@vger.kernel.org, linux-xtensa@linux-xtensa.org, Davidlohr Bueso <dave@stgolabs.net>, linux-ia64@vger.kernel.org, Tim Chen <tim.c.chen@linux.intel.com>, Arnd Bergmann <arnd@arndb.de>, linux-sh@vger.kernel.org, linux-hexagon@vger.kernel.org, x86@kernel.org, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, linux-alpha@vger.kernel.org, sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linuxppc-dev@lists.ozlabs.org, Andrew Morton <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org

On Thu, Feb 07, 2019 at 08:36:56PM +0100, Peter Zijlstra wrote:
> On Thu, Feb 07, 2019 at 02:07:08PM -0500, Waiman Long wrote:
> 
> > +static inline int __down_read_trylock(struct rw_semaphore *sem)
> > +{
> > +	long tmp;
> > +
> > +	while ((tmp = atomic_long_read(&sem->count)) >= 0) {
> > +		if (tmp = atomic_long_cmpxchg_acquire(&sem->count, tmp,
> > +				   tmp + RWSEM_ACTIVE_READ_BIAS)) {
> > +			return 1;
> > +		}
> > +	}
> 
> Nah, you're supposed to write that like:
> 
> 	for (;;) {
> 		val = atomic_long_cond_read_relaxed(&sem->count, VAL < 0);
> 		if (atomic_long_try_cmpxchg_acquire(&sem->count, &val,
> 						    val + RWSEM_ACTIVE_READ_BIAS))
> 			break;
> 	}

N/m that's not in fact the same...

> > +	return 0;
> > +}
> 
> 
> Anyway, yuck, you're keeping all that BIAS nonsense :/ I was so hoping
> for a rwsem implementation without that impenetrable crap.
