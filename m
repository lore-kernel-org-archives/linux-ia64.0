From: Zou Nan hai <nanhai.zou@intel.com>
Date: Mon, 12 Dec 2005 06:16:29 +0000
Subject: Re: [patch 2.6.15-rc5] Define an ia64 version of __raw_read_trylock
Message-Id: <1134368188.3560.11.camel@linux-znh>
List-Id: <linux-ia64.vger.kernel.org>
References: <17916.1134185068@ocs3.ocs.com.au>
In-Reply-To: <17916.1134185068@ocs3.ocs.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, 2005-12-10 at 11:24, Keith Owens wrote:
> IA64 is using the generic version of __raw_read_trylock, which always
> waits for the lock to be free instead of returning when the lock is in
> use.  Define an ia64 version of __raw_read_trylock which behaves
> correctly, and drop the generic one.
> 
> Signed-off-by: Keith Owens <kaos@sgi.com>
> 
> Index: linux/include/asm-ia64/spinlock.h
> =================================> --- linux.orig/include/asm-ia64/spinlock.h      2005-12-09
> 14:44:56.883252331 +1100
> +++ linux/include/asm-ia64/spinlock.h   2005-12-10 14:20:44.459423430
> +1100
> @@ -201,6 +201,16 @@ static inline void __raw_write_unlock(ra
>  
>  #endif /* !ASM_SUPPORTED */
>  
> -#define __raw_read_trylock(lock) generic__raw_read_trylock(lock)
> +static inline int __raw_read_trylock(raw_rwlock_t *x)
> +{
> +       union {
> +               raw_rwlock_t lock;
> +               __u32 word;
> +       } old, new;
> +       old.lock = new.lock = *x;
> +       old.lock.write_lock = new.lock.write_lock = 0;
> +       ++new.lock.read_counter;
> +       return (u32)ia64_cmpxchg4_acq((__u32 *)(x), new.word,
> old.word) = old.word;
> +}
>  
>  #endif /*  _ASM_IA64_SPINLOCK_H */
> 

   How about using fetchadd4.acq 1 in trylock and rollback by fetchadd4.rel -1 if lock failed, 
just like how __raw_read_lock does?
   That should emit fewer code and give no extra memory foot print I think.

Zou Nan hai

