From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 11 Feb 2019 09:36:01 +0000
Subject: Re: [PATCH] locking/rwsem: Remove arch specific rwsem files
Message-Id: <20190211093601.GT32511@hirez.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1549850450-10171-1-git-send-email-longman@redhat.com>
In-Reply-To: <1549850450-10171-1-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Waiman Long <longman@redhat.com>
Cc: linux-arch@vger.kernel.org, linux-xtensa@linux-xtensa.org, Davidlohr Bueso <dave@stgolabs.net>, linux-ia64@vger.kernel.org, Tim Chen <tim.c.chen@linux.intel.com>, Arnd Bergmann <arnd@arndb.de>, linux-sh@vger.kernel.org, linux-hexagon@vger.kernel.org, x86@kernel.org, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, linux-alpha@vger.kernel.org, sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linuxppc-dev@lists.ozlabs.org, Andrew Morton <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org

On Sun, Feb 10, 2019 at 09:00:50PM -0500, Waiman Long wrote:
> diff --git a/kernel/locking/rwsem.h b/kernel/locking/rwsem.h
> index bad2bca..067e265 100644
> --- a/kernel/locking/rwsem.h
> +++ b/kernel/locking/rwsem.h
> @@ -32,6 +32,26 @@
>  # define DEBUG_RWSEMS_WARN_ON(c)
>  #endif
>  
> +/*
> + * R/W semaphores originally for PPC using the stuff in lib/rwsem.c.
> + * Adapted largely from include/asm-i386/rwsem.h
> + * by Paul Mackerras <paulus@samba.org>.
> + */
> +
> +/*
> + * the semaphore definition
> + */
> +#ifdef CONFIG_64BIT
> +# define RWSEM_ACTIVE_MASK		0xffffffffL
> +#else
> +# define RWSEM_ACTIVE_MASK		0x0000ffffL
> +#endif
> +
> +#define RWSEM_ACTIVE_BIAS		0x00000001L
> +#define RWSEM_WAITING_BIAS		(-RWSEM_ACTIVE_MASK-1)
> +#define RWSEM_ACTIVE_READ_BIAS		RWSEM_ACTIVE_BIAS
> +#define RWSEM_ACTIVE_WRITE_BIAS		(RWSEM_WAITING_BIAS + RWSEM_ACTIVE_BIAS)
> +
>  #ifdef CONFIG_RWSEM_SPIN_ON_OWNER
>  /*
>   * All writes to owner are protected by WRITE_ONCE() to make sure that
> @@ -132,3 +152,113 @@ static inline void rwsem_clear_reader_owned(struct rw_semaphore *sem)
>  {
>  }
>  #endif
> +
> +#ifdef CONFIG_RWSEM_XCHGADD_ALGORITHM
> +/*
> + * lock for reading
> + */
> +static inline void __down_read(struct rw_semaphore *sem)
> +{
> +	if (unlikely(atomic_long_inc_return_acquire(&sem->count) <= 0))
> +		rwsem_down_read_failed(sem);
> +}
> +
> +static inline int __down_read_killable(struct rw_semaphore *sem)
> +{
> +	if (unlikely(atomic_long_inc_return_acquire(&sem->count) <= 0)) {
> +		if (IS_ERR(rwsem_down_read_failed_killable(sem)))
> +			return -EINTR;
> +	}
> +
> +	return 0;
> +}
> +
> +static inline int __down_read_trylock(struct rw_semaphore *sem)
> +{
> +	long tmp;
> +
> +	while ((tmp = atomic_long_read(&sem->count)) >= 0) {
> +		if (tmp = atomic_long_cmpxchg_acquire(&sem->count, tmp,
> +				   tmp + RWSEM_ACTIVE_READ_BIAS)) {
> +			return 1;

That really wants to be:

		if (atomic_long_try_cmpxchg_acquire(&sem->count, &tmp,
						    tmp + RWSEM_ACTIVE_READ_BIAS))

> +		}
> +	}
> +	return 0;
> +}
> +
> +/*
> + * lock for writing
> + */
> +static inline void __down_write(struct rw_semaphore *sem)
> +{
> +	long tmp;
> +
> +	tmp = atomic_long_add_return_acquire(RWSEM_ACTIVE_WRITE_BIAS,
> +					     &sem->count);
> +	if (unlikely(tmp != RWSEM_ACTIVE_WRITE_BIAS))
> +		rwsem_down_write_failed(sem);
> +}
> +
> +static inline int __down_write_killable(struct rw_semaphore *sem)
> +{
> +	long tmp;
> +
> +	tmp = atomic_long_add_return_acquire(RWSEM_ACTIVE_WRITE_BIAS,
> +					     &sem->count);
> +	if (unlikely(tmp != RWSEM_ACTIVE_WRITE_BIAS))
> +		if (IS_ERR(rwsem_down_write_failed_killable(sem)))
> +			return -EINTR;
> +	return 0;
> +}
> +
> +static inline int __down_write_trylock(struct rw_semaphore *sem)
> +{
> +	long tmp;

	tmp = RWSEM_UNLOCKED_VALUE;

> +
> +	tmp = atomic_long_cmpxchg_acquire(&sem->count, RWSEM_UNLOCKED_VALUE,
> +		      RWSEM_ACTIVE_WRITE_BIAS);
> +	return tmp = RWSEM_UNLOCKED_VALUE;

	return atomic_long_try_cmpxchg_acquire(&sem->count, &tmp,
					       RWSEM_ACTIVE_WRITE_BIAS);

> +}
> +
> +/*
> + * unlock after reading
> + */
> +static inline void __up_read(struct rw_semaphore *sem)
> +{
> +	long tmp;
> +
> +	tmp = atomic_long_dec_return_release(&sem->count);
> +	if (unlikely(tmp < -1 && (tmp & RWSEM_ACTIVE_MASK) = 0))
> +		rwsem_wake(sem);
> +}
> +
> +/*
> + * unlock after writing
> + */
> +static inline void __up_write(struct rw_semaphore *sem)
> +{
> +	if (unlikely(atomic_long_sub_return_release(RWSEM_ACTIVE_WRITE_BIAS,
> +						    &sem->count) < 0))
> +		rwsem_wake(sem);
> +}
> +
> +/*
> + * downgrade write lock to read lock
> + */
> +static inline void __downgrade_write(struct rw_semaphore *sem)
> +{
> +	long tmp;
> +
> +	/*
> +	 * When downgrading from exclusive to shared ownership,
> +	 * anything inside the write-locked region cannot leak
> +	 * into the read side. In contrast, anything in the
> +	 * read-locked region is ok to be re-ordered into the
> +	 * write side. As such, rely on RELEASE semantics.
> +	 */
> +	tmp = atomic_long_add_return_release(-RWSEM_WAITING_BIAS, &sem->count);
> +	if (tmp < 0)
> +		rwsem_downgrade_wake(sem);
> +}
> +
> +#endif /* CONFIG_RWSEM_XCHGADD_ALGORITHM */
