From: Christophe Leroy <christophe.leroy@c-s.fr>
Date: Mon, 25 Mar 2019 15:25:24 +0000
Subject: Re: [PATCH v5 3/3] locking/rwsem: Optimize down_read_trylock()
Message-Id: <014279a5-8998-8e03-adb3-c3d611dff171@c-s.fr>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190322143008.21313-1-longman@redhat.com>
 <20190322143008.21313-4-longman@redhat.com>
In-Reply-To: <20190322143008.21313-4-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Waiman Long <longman@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, linux-mips@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, linux-riscv@lists.infradead.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, x86@kernel.org, uclinux-h8-devel@lists.sourceforge.jp, linux-xtensa@linux-xtensa.org, Arnd Bergmann <arnd@arndb.de>, linux-um@lists.infradead.org, linux-m68k@lists.linux-m68k.org, openrisc@lists.librecores.org, Borislav Petkov <bp@alien8.de>, linux-arm-kernel@lists.infradead.org, Tim Chen <tim.c.chen@linux.intel.com>, linux-parisc@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.or

Hi,

Could you share the microbenchmark you are using ?

I'd like to test the series on powerpc.

Thanks
Christophe

Le 22/03/2019 à 15:30, Waiman Long a écrit :
> Modify __down_read_trylock() to optimize for an unlocked rwsem and make
> it generate slightly better code.
> 
> Before this patch, down_read_trylock:
> 
>     0x0000000000000000 <+0>:     callq  0x5 <down_read_trylock+5>
>     0x0000000000000005 <+5>:     jmp    0x18 <down_read_trylock+24>
>     0x0000000000000007 <+7>:     lea    0x1(%rdx),%rcx
>     0x000000000000000b <+11>:    mov    %rdx,%rax
>     0x000000000000000e <+14>:    lock cmpxchg %rcx,(%rdi)
>     0x0000000000000013 <+19>:    cmp    %rax,%rdx
>     0x0000000000000016 <+22>:    je     0x23 <down_read_trylock+35>
>     0x0000000000000018 <+24>:    mov    (%rdi),%rdx
>     0x000000000000001b <+27>:    test   %rdx,%rdx
>     0x000000000000001e <+30>:    jns    0x7 <down_read_trylock+7>
>     0x0000000000000020 <+32>:    xor    %eax,%eax
>     0x0000000000000022 <+34>:    retq
>     0x0000000000000023 <+35>:    mov    %gs:0x0,%rax
>     0x000000000000002c <+44>:    or     $0x3,%rax
>     0x0000000000000030 <+48>:    mov    %rax,0x20(%rdi)
>     0x0000000000000034 <+52>:    mov    $0x1,%eax
>     0x0000000000000039 <+57>:    retq
> 
> After patch, down_read_trylock:
> 
>     0x0000000000000000 <+0>:	callq  0x5 <down_read_trylock+5>
>     0x0000000000000005 <+5>:	xor    %eax,%eax
>     0x0000000000000007 <+7>:	lea    0x1(%rax),%rdx
>     0x000000000000000b <+11>:	lock cmpxchg %rdx,(%rdi)
>     0x0000000000000010 <+16>:	jne    0x29 <down_read_trylock+41>
>     0x0000000000000012 <+18>:	mov    %gs:0x0,%rax
>     0x000000000000001b <+27>:	or     $0x3,%rax
>     0x000000000000001f <+31>:	mov    %rax,0x20(%rdi)
>     0x0000000000000023 <+35>:	mov    $0x1,%eax
>     0x0000000000000028 <+40>:	retq
>     0x0000000000000029 <+41>:	test   %rax,%rax
>     0x000000000000002c <+44>:	jns    0x7 <down_read_trylock+7>
>     0x000000000000002e <+46>:	xor    %eax,%eax
>     0x0000000000000030 <+48>:	retq
> 
> By using a rwsem microbenchmark, the down_read_trylock() rate (with a
> load of 10 to lengthen the lock critical section) on a x86-64 system
> before and after the patch were:
> 
>                   Before Patch    After Patch
>     # of Threads     rlock           rlock
>     ------------     -----           -----
>          1           14,496          14,716
>          2            8,644           8,453
> 	4            6,799           6,983
> 	8            5,664           7,190
> 
> On a ARM64 system, the performance results were:
> 
>                   Before Patch    After Patch
>     # of Threads     rlock           rlock
>     ------------     -----           -----
>          1           23,676          24,488
>          2            7,697           9,502
>          4            4,945           3,440
>          8            2,641           1,603
> 
> For the uncontended case (1 thread), the new down_read_trylock() is a
> little bit faster. For the contended cases, the new down_read_trylock()
> perform pretty well in x86-64, but performance degrades at high
> contention level on ARM64.
> 
> Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Waiman Long <longman@redhat.com>
> ---
>   kernel/locking/rwsem.h | 13 ++++++++-----
>   1 file changed, 8 insertions(+), 5 deletions(-)
> 
> diff --git a/kernel/locking/rwsem.h b/kernel/locking/rwsem.h
> index 45ee00236e03..1f5775aa6a1d 100644
> --- a/kernel/locking/rwsem.h
> +++ b/kernel/locking/rwsem.h
> @@ -174,14 +174,17 @@ static inline int __down_read_killable(struct rw_semaphore *sem)
>   
>   static inline int __down_read_trylock(struct rw_semaphore *sem)
>   {
> -	long tmp;
> +	/*
> +	 * Optimize for the case when the rwsem is not locked at all.
> +	 */
> +	long tmp = RWSEM_UNLOCKED_VALUE;
>   
> -	while ((tmp = atomic_long_read(&sem->count)) >= 0) {
> -		if (tmp = atomic_long_cmpxchg_acquire(&sem->count, tmp,
> -				   tmp + RWSEM_ACTIVE_READ_BIAS)) {
> +	do {
> +		if (atomic_long_try_cmpxchg_acquire(&sem->count, &tmp,
> +					tmp + RWSEM_ACTIVE_READ_BIAS)) {
>   			return 1;
>   		}
> -	}
> +	} while (tmp >= 0);
>   	return 0;
>   }
>   
> 
