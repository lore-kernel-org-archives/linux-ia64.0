From: Robin Holt <holt@sgi.com>
Date: Sat, 12 Sep 2009 07:59:53 +0000
Subject: Re: [RFC] Convert ia64 spinlocks to use "tickets"
Message-Id: <20090912075953.GA8934@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4aa9e16649286264@agluck-desktop.sc.intel.com>
In-Reply-To: <4aa9e16649286264@agluck-desktop.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Sep 10, 2009 at 10:34:30PM -0700, Luck, Tony wrote:
...
> -static inline void
> -__raw_spin_lock_flags (raw_spinlock_t *lock, unsigned long flags)
> +static __always_inline void __ticket_spin_lock(raw_spinlock_t *lock)
>  {
> -	register volatile unsigned int *ptr asm ("r31") = &lock->lock;
> -
> -#if (__GNUC__ = 3 && __GNUC_MINOR__ < 3)
> -# ifdef CONFIG_ITANIUM
> -	/* don't use brl on Itanium... */
> -	asm volatile ("{\n\t"
> -		      "  mov ar.ccv = r0\n\t"
> -		      "  mov r28 = ip\n\t"
> -		      "  mov r30 = 1;;\n\t"
> -		      "}\n\t"
> -		      "cmpxchg4.acq r30 = [%1], r30, ar.ccv\n\t"
> -		      "movl r29 = ia64_spinlock_contention_pre3_4;;\n\t"
...
> -		      "(p14) brl.call.spnt.many b6=ia64_spinlock_contention;;"

Have you done any testing where the spin with interrupts disabled was
problematic?

I know we have had ages of problems with these, but I don't recall
any specific instances right now (keep in mind it is 3:00 AM when I am
finally getting to look at this).

Thanks,
Robin
