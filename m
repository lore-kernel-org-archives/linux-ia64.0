From: Waiman Long <longman@redhat.com>
Date: Thu, 07 Feb 2019 19:43:10 +0000
Subject: Re: [PATCH-tip 04/22] locking/rwsem: Remove arch specific rwsem files
Message-Id: <71019c4b-7e3d-de59-5f49-1f147ecc3458@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1549566446-27967-1-git-send-email-longman@redhat.com>
 <1549566446-27967-5-git-send-email-longman@redhat.com>
 <20190207193656.GF32511@hirez.programming.kicks-ass.net>
In-Reply-To: <20190207193656.GF32511@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Davidlohr Bueso <dave@stgolabs.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>

On 02/07/2019 02:36 PM, Peter Zijlstra wrote:
> On Thu, Feb 07, 2019 at 02:07:08PM -0500, Waiman Long wrote:
>
>> +static inline int __down_read_trylock(struct rw_semaphore *sem)
>> +{
>> +	long tmp;
>> +
>> +	while ((tmp = atomic_long_read(&sem->count)) >= 0) {
>> +		if (tmp = atomic_long_cmpxchg_acquire(&sem->count, tmp,
>> +				   tmp + RWSEM_ACTIVE_READ_BIAS)) {
>> +			return 1;
>> +		}
>> +	}
> Nah, you're supposed to write that like:
>
> 	for (;;) {
> 		val = atomic_long_cond_read_relaxed(&sem->count, VAL < 0);
> 		if (atomic_long_try_cmpxchg_acquire(&sem->count, &val,
> 						    val + RWSEM_ACTIVE_READ_BIAS))
> 			break;
> 	}
>

Ah, you are right. I just took it directly from the current generic
asm.h file and didn't pay much attention to it. I will fix that in the
next iteration.

>> +	return 0;
>> +}
>
> Anyway, yuck, you're keeping all that BIAS nonsense :/ I was so hoping
> for a rwsem implementation without that impenetrable crap.

Well, I am going to take out all the BIAS handling in a later patch.
This one is just for removing the architecture specific files.

I can't change the rwsem count encoding before I take out all the arch
specific files.

Cheers,
Longman
