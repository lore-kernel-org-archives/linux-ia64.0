From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 06 Apr 2016 09:26:55 +0000
Subject: Re: [PATCH 2/2] sh, rwsem: drop superfluous arch specific implementation
Message-Id: <20160406092655.GP3448@twins.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160404090335.GB10272@dhcp22.suse.cz>
 <1459760800-13477-1-git-send-email-mhocko@kernel.org>
 <1459760800-13477-2-git-send-email-mhocko@kernel.org>
In-Reply-To: <1459760800-13477-2-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michal Hocko <mhocko@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, Michal Hocko <mhocko@suse.com>, ysato@users.sourceforge.jp, dalias@libc.org


+Cc maintainers, linux-sh list is very high signal-to-noise as its been
appropriated for renesas arm parts.

On Mon, Apr 04, 2016 at 11:06:40AM +0200, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> since "locking, rwsem: drop explicit memory barriers" the arch specific
> code is basically same as the the generic one so we can drop the
> superfluous code.
> 
> Suggested-by: Davidlohr Bueso <dave@stgolabs.net>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  arch/sh/include/asm/Kbuild  |   1 +
>  arch/sh/include/asm/rwsem.h | 130 --------------------------------------------
>  2 files changed, 1 insertion(+), 130 deletions(-)
>  delete mode 100644 arch/sh/include/asm/rwsem.h
> 
> diff --git a/arch/sh/include/asm/Kbuild b/arch/sh/include/asm/Kbuild
> index aac452b26aa8..6d866c7a9b74 100644
> --- a/arch/sh/include/asm/Kbuild
> +++ b/arch/sh/include/asm/Kbuild
> @@ -25,6 +25,7 @@ generic-y += percpu.h
>  generic-y += poll.h
>  generic-y += preempt.h
>  generic-y += resource.h
> +generic-y += rwsem.h
>  generic-y += sembuf.h
>  generic-y += serial.h
>  generic-y += shmbuf.h
> diff --git a/arch/sh/include/asm/rwsem.h b/arch/sh/include/asm/rwsem.h
> deleted file mode 100644
> index 8a457b83d2a5..000000000000
> --- a/arch/sh/include/asm/rwsem.h
> +++ /dev/null
> @@ -1,130 +0,0 @@
> -/*
> - * include/asm-sh/rwsem.h: R/W semaphores for SH using the stuff
> - * in lib/rwsem.c.
> - */
> -
> -#ifndef _ASM_SH_RWSEM_H
> -#define _ASM_SH_RWSEM_H
> -
> -#ifndef _LINUX_RWSEM_H
> -#error "please don't include asm/rwsem.h directly, use linux/rwsem.h instead"
> -#endif
> -
> -#ifdef __KERNEL__
> -
> -#define RWSEM_UNLOCKED_VALUE		0x00000000
> -#define RWSEM_ACTIVE_BIAS		0x00000001
> -#define RWSEM_ACTIVE_MASK		0x0000ffff
> -#define RWSEM_WAITING_BIAS		(-0x00010000)
> -#define RWSEM_ACTIVE_READ_BIAS		RWSEM_ACTIVE_BIAS
> -#define RWSEM_ACTIVE_WRITE_BIAS		(RWSEM_WAITING_BIAS + RWSEM_ACTIVE_BIAS)
> -
> -/*
> - * lock for reading
> - */
> -static inline void __down_read(struct rw_semaphore *sem)
> -{
> -	if (atomic_inc_return((atomic_t *)(&sem->count)) <= 0)
> -		rwsem_down_read_failed(sem);
> -}
> -
> -static inline int __down_read_trylock(struct rw_semaphore *sem)
> -{
> -	int tmp;
> -
> -	while ((tmp = sem->count) >= 0) {
> -		if (tmp = cmpxchg(&sem->count, tmp,
> -				   tmp + RWSEM_ACTIVE_READ_BIAS)) {
> -			return 1;
> -		}
> -	}
> -	return 0;
> -}
> -
> -/*
> - * lock for writing
> - */
> -static inline void __down_write(struct rw_semaphore *sem)
> -{
> -	int tmp;
> -
> -	tmp = atomic_add_return(RWSEM_ACTIVE_WRITE_BIAS,
> -				(atomic_t *)(&sem->count));
> -	if (tmp != RWSEM_ACTIVE_WRITE_BIAS)
> -		rwsem_down_write_failed(sem);
> -}
> -
> -static inline int __down_write_killable(struct rw_semaphore *sem)
> -{
> -	int tmp;
> -
> -	tmp = atomic_add_return(RWSEM_ACTIVE_WRITE_BIAS,
> -				(atomic_t *)(&sem->count));
> -	if (tmp != RWSEM_ACTIVE_WRITE_BIAS)
> -		if (IS_ERR(rwsem_down_write_failed_killable(sem)))
> -			return -EINTR;
> -
> -	return 0;
> -}
> -
> -static inline int __down_write_trylock(struct rw_semaphore *sem)
> -{
> -	int tmp;
> -
> -	tmp = cmpxchg(&sem->count, RWSEM_UNLOCKED_VALUE,
> -		      RWSEM_ACTIVE_WRITE_BIAS);
> -	return tmp = RWSEM_UNLOCKED_VALUE;
> -}
> -
> -/*
> - * unlock after reading
> - */
> -static inline void __up_read(struct rw_semaphore *sem)
> -{
> -	int tmp;
> -
> -	tmp = atomic_dec_return((atomic_t *)(&sem->count));
> -	if (tmp < -1 && (tmp & RWSEM_ACTIVE_MASK) = 0)
> -		rwsem_wake(sem);
> -}
> -
> -/*
> - * unlock after writing
> - */
> -static inline void __up_write(struct rw_semaphore *sem)
> -{
> -	if (atomic_sub_return(RWSEM_ACTIVE_WRITE_BIAS,
> -			      (atomic_t *)(&sem->count)) < 0)
> -		rwsem_wake(sem);
> -}
> -
> -/*
> - * implement atomic add functionality
> - */
> -static inline void rwsem_atomic_add(int delta, struct rw_semaphore *sem)
> -{
> -	atomic_add(delta, (atomic_t *)(&sem->count));
> -}
> -
> -/*
> - * downgrade write lock to read lock
> - */
> -static inline void __downgrade_write(struct rw_semaphore *sem)
> -{
> -	int tmp;
> -
> -	tmp = atomic_add_return(-RWSEM_WAITING_BIAS, (atomic_t *)(&sem->count));
> -	if (tmp < 0)
> -		rwsem_downgrade_wake(sem);
> -}
> -
> -/*
> - * implement exchange and add functionality
> - */
> -static inline int rwsem_atomic_update(int delta, struct rw_semaphore *sem)
> -{
> -	return atomic_add_return(delta, (atomic_t *)(&sem->count));
> -}
> -
> -#endif /* __KERNEL__ */
> -#endif /* _ASM_SH_RWSEM_H */
> -- 
> 2.8.0.rc3
> 
