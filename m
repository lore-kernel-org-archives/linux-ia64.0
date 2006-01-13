From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 13 Jan 2006 22:26:54 +0000
Subject: RE: Bug in ia64 specific down() function??
Message-Id: <200601132226.k0DMQsg04061@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601120138.k0C1cEg03582@unix-os.sc.intel.com>
In-Reply-To: <200601120138.k0C1cEg03582@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Zoltan Menyhart wrote on Friday, January 13, 2006 8:25 AM
> Chen, Kenneth W wrote:
> > The memory order semantics for include/asm-ia64/semaphore.h:down()
> > doesn't look right.  It is using atomic_dec_return, which eventually
> > translate into ia64_fetch_and_add() that uses release semantics.
> > Shouldn't it use acquire semantics?
> 
> What about this one:
> 
> --- linux-2.6.15-test/include/asm-ia64/semaphore.h	2006-01-10 13:54:31.000000000 +0100
> +++ linux-2.6.15-test-down/include/asm-ia64/semaphore.h	2006-01-13 16:16:04.000000000 +0100
> @@ -61,7 +61,7 @@ down (struct semaphore * sem)
>  down (struct semaphore *sem)
>  {
>  	might_sleep();
> -	if (atomic_dec_return(&sem->count) < 0)
> +	if (ia64_fetchadd(-1, &sem->count.counter, acq) < 1)
>  		__down(sem);
>  }
>  
> @@ -75,7 +75,7 @@ down_interruptible (struct semaphore * sem)
>  	int ret = 0;
>  
>  	might_sleep();
> -	if (atomic_dec_return(&sem->count) < 0)
> +	if (ia64_fetchadd(-1, &sem->count.counter, acq) < 1)
>  		ret = __down_interruptible(sem);
>  	return ret;
>  }
> @@ -85,7 +85,7 @@ down_trylock (struct semaphore *sem)
>  {
>  	int ret = 0;
>  
> -	if (atomic_dec_return(&sem->count) < 0)
> +	if (ia64_fetchadd(-1, &sem->count.counter, acq) < 1)
>  		ret = __down_trylock(sem);
>  	return ret;
>  }
> @@ -93,7 +93,7 @@ up (struct semaphore *sem)
>  static inline void
>  up (struct semaphore * sem)
>  {
> -	if (atomic_inc_return(&sem->count) <= 0)
> +	if (ia64_fetchadd(1, &sem->count.counter, rel) <= -1)
>  		__up(sem);
>  }

Yeah, looked OK to me.

- Ken

