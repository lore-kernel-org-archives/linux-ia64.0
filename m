From: Waiman Long <longman@redhat.com>
Date: Wed, 11 Oct 2017 19:05:10 +0000
Subject: Re: [PATCH v6 02/11] locking/rwsem: Implement a new locking scheme
Message-Id: <9a36b0d7-85c3-360e-1092-7c9b8659beeb@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1507744922-15196-1-git-send-email-longman@redhat.com>
 <1507744922-15196-3-git-send-email-longman@redhat.com>
 <20171011184038.pilwo7sjf72nwaxk@hirez.programming.kicks-ass.net>
 <29f33a68-bf01-e0f0-158f-3bae3a680e80@redhat.com>
In-Reply-To: <29f33a68-bf01-e0f0-158f-3bae3a680e80@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Dave Chinner <david@fromorbit.com>

On 10/11/2017 02:58 PM, Waiman Long wrote:
> On 10/11/2017 02:40 PM, Peter Zijlstra wrote:
>> On Wed, Oct 11, 2017 at 02:01:53PM -0400, Waiman Long wrote:
>>> +/*
>>> + * The definition of the atomic counter in the semaphore:
>>> + *
>>> + * Bit  0    - writer locked bit
>>> + * Bit  1    - waiters present bit
>>> + * Bits 2-7  - reserved
>>> + * Bits 8-31 - 24-bit reader count
>>> + *
>>> + * atomic_fetch_add() is used to obtain reader lock, whereas atomic_cmpxchg()
>>> + * will be used to obtain writer lock.
>>> + */
>>> +#define RWSEM_WRITER_LOCKED	0X00000001
>>> +#define RWSEM_FLAG_WAITERS	0X00000002
>>> +#define RWSEM_READER_BIAS	0x00000100
>>> +#define RWSEM_READER_SHIFT	8
>>> +#define RWSEM_READER_MASK	(~((1U << RWSEM_READER_SHIFT) - 1))
>>> +#define RWSEM_LOCK_MASK 	(RWSEM_WRITER_LOCKED|RWSEM_READER_MASK)
>>> +#define RWSEM_READ_FAILED_MASK	(RWSEM_WRITER_LOCKED|RWSEM_FLAG_WAITERS)
>>> +
>>> +#define RWSEM_COUNT_IS_LOCKED(c)	((c) & RWSEM_LOCK_MASK)
>>> +
>>> +/*
>>> + * lock for reading
>>> + */
>>> +static inline void __down_read(struct rw_semaphore *sem)
>>> +{
>>> +	if (unlikely(atomic_fetch_add_acquire(RWSEM_READER_BIAS, &sem->count)
>>> +		     & RWSEM_READ_FAILED_MASK))
>>> +		rwsem_down_read_failed(sem);
>>> +}
>> So I implemented rwsem-mutex (also qrwlock based) that puts
>>
>>   (unsigned long)current | RWSEM_WRITER
>>
>> in the atomic_long_t rw_semaphore::owner field. The down-side is that
>> you can't do fetch_add based __down_read, because that would clobber the
>> pointer. The up-side is that we have a stable owner pointer (which is
>> what I needed for PI like things).
> Without fetch_add for readers, it could lead to reduced performance for
> reader heavy workloads.
>
> Are you trying to do a PI version of rwsem? It can work when the lock is
> writer owned, but not when it is reader owned.

I have actually been thinking about giving priority to RT or DL task by
putting the task in front of the wait queue and assert the lock handoff
bit, for example. There are extra reserved bits left that can be useful
for adding these additional features. That will be later when I am done
with the current patch.

Cheers,
Longman




