From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 22 Oct 2008 17:24:31 +0000
Subject: Re: [PATCH 1/2] Allow rwlocks to re-enable interrupts
Message-Id: <1224696271.20069.8.camel@twins>
List-Id: <linux-ia64.vger.kernel.org>
References: <1224664414.4430.33.camel@elijah.suse.cz>
	 <1224664476.4430.38.camel@elijah.suse.cz>  <1224665128.15448.4.camel@twins>
	 <1224665899.4430.48.camel@elijah.suse.cz>
In-Reply-To: <1224665899.4430.48.camel@elijah.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Petr Tesarik <ptesarik@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, tee@sgi.com, Ingo Molnar <mingo@elte.hu>

On Wed, 2008-10-22 at 10:58 +0200, Petr Tesarik wrote:
> On Wed, 2008-10-22 at 10:45 +0200, Peter Zijlstra wrote:
> > On Wed, 2008-10-22 at 10:34 +0200, Petr Tesarik wrote:
> > > c b/kernel/spinlock.c
> > > index 29ab207..f769d8a 100644
> > > --- a/kernel/spinlock.c
> > > +++ b/kernel/spinlock.c
> > > @@ -121,7 +121,11 @@ unsigned long __lockfunc _read_lock_irqsave(rwlock_t *lock)
> > >  	local_irq_save(flags);
> > >  	preempt_disable();
> > >  	rwlock_acquire_read(&lock->dep_map, 0, 0, _RET_IP_);
> > > +#ifdef CONFIG_LOCKDEP
> > >  	LOCK_CONTENDED(lock, _raw_read_trylock, _raw_read_lock);
> > > +#else
> > > +	_raw_read_lock_flags(lock, &flags);
> > > +#endif
> > >  	return flags;
> > >  }
> > 
> > That should be CONFIG_LOCK_STAT.
> 
> Ugh. Fine with me, but is CONFIG_LOCKDEP correct in _spin_lock_irqsave,
> or should it also read CONFIG_LOCK_STAT?

Yep.

> > But aside from that, I really don't like this change, I'd rather you'd
> > create a LOCK_CONTENDED_FLAGS() that can deal with this.
> 
> No problem. I could then also use it for _spin_lock_irqsave, if the
> answer to the above question is use CONFIG_LOCK_STAT there as well.

If you create LOCK_CONTEDED_FLAGS() the whole issue goes away nicely.
