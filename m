From: Peter Zijlstra <peterz@infradead.org>
Date: Thu, 27 Nov 2008 15:32:47 +0000
Subject: Re: [PATCH V2 1/3] Factor out #ifdef's from kernel/spinlock.c to
Message-Id: <1227799967.4454.1711.camel@twins>
List-Id: <linux-ia64.vger.kernel.org>
References: <1224777451.11530.52.camel@elijah.suse.cz>
	 <1224777961.11530.64.camel@elijah.suse.cz>
In-Reply-To: <1224777961.11530.64.camel@elijah.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Petr Tesarik <ptesarik@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, tee@sgi.com, Robin Holt <holt@sgi.com>

On Thu, 2008-10-23 at 18:06 +0200, Petr Tesarik wrote:
> The new macro LOCK_CONTENDED_FLAGS expands to the correct implementation
> depending on the config options, so that IRQ's are re-enabled when
> possible, but they remain disabled if CONFIG_LOCKDEP is set.
> 
> Signed-off-by: Petr Tesarik <ptesarik@suse.cz>

Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

Sorry, got lost in the inbox...

> ---
>  include/linux/lockdep.h |   17 +++++++++++++++++
>  kernel/spinlock.c       |   12 ++----------
>  2 files changed, 19 insertions(+), 10 deletions(-)
> 
> diff --git a/include/linux/lockdep.h b/include/linux/lockdep.h
> index 331e5f1..1e6e578 100644
> --- a/include/linux/lockdep.h
> +++ b/include/linux/lockdep.h
> @@ -376,6 +376,23 @@ do
> {                                                               \
>  
>  #endif /* CONFIG_LOCK_STAT */
>  
> +#ifdef CONFIG_LOCKDEP
> +
> +/*
> + * On lockdep we dont want the hand-coded irq-enable of
> + * _raw_*_lock_flags() code, because lockdep assumes
> + * that interrupts are not re-enabled during lock-acquire:
> + */
> +#define LOCK_CONTENDED_FLAGS(_lock, try, lock, lockfl, flags) \
> +       LOCK_CONTENDED((_lock), (try), (lock))
> +
> +#else /* CONFIG_LOCKDEP */
> +
> +#define LOCK_CONTENDED_FLAGS(_lock, try, lock, lockfl, flags) \
> +       lockfl((_lock), (flags))
> +
> +#endif /* CONFIG_LOCKDEP */
> +
>  #if defined(CONFIG_TRACE_IRQFLAGS) && defined(CONFIG_GENERIC_HARDIRQS)
>  extern void early_init_irq_lock_class(void);
>  #else
> diff --git a/kernel/spinlock.c b/kernel/spinlock.c
> index 29ab207..cf41b87 100644
> --- a/kernel/spinlock.c
> +++ b/kernel/spinlock.c
> @@ -299,16 +299,8 @@ unsigned long __lockfunc
> _spin_lock_irqsave_nested(spinlock_t *lock, int subclas
>         local_irq_save(flags);
>         preempt_disable();
>         spin_acquire(&lock->dep_map, subclass, 0, _RET_IP_);
> -       /*
> -        * On lockdep we dont want the hand-coded irq-enable of
> -        * _raw_spin_lock_flags() code, because lockdep assumes
> -        * that interrupts are not re-enabled during lock-acquire:
> -        */
> -#ifdef CONFIG_LOCKDEP
> -       LOCK_CONTENDED(lock, _raw_spin_trylock, _raw_spin_lock);
> -#else
> -       _raw_spin_lock_flags(lock, &flags);
> -#endif
> +       LOCK_CONTENDED_FLAGS(lock, _raw_spin_trylock, _raw_spin_lock,
> +                            _raw_spin_lock_flags, &flags);
>         return flags;
>  }
>  EXPORT_SYMBOL(_spin_lock_irqsave_nested);
> 
> 
