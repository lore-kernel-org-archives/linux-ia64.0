From: Waiman Long <waiman.long@hpe.com>
Date: Wed, 05 Oct 2016 12:19:22 +0000
Subject: Re: [RFC PATCH-tip v4 01/10] locking/osq: Make lock/unlock proper acquire/release barrier
Message-Id: <57F4EFCA.6050503@hpe.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1471554672-38662-1-git-send-email-Waiman.Long@hpe.com> <1471554672-38662-2-git-send-email-Waiman.Long@hpe.com> <20161004190601.GD24086@linux-80c1.suse>
In-Reply-To: <20161004190601.GD24086@linux-80c1.suse>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, Jason Low <jason.low2@hp.com>, Dave Chinner <david@fromorbit.com>, Jonathan Corbet <corbet@lwn.net>, Scott J Norton <scott.norton@hpe.com>, Douglas Hatch <doug.hatch@hpe.com>

On 10/04/2016 03:06 PM, Davidlohr Bueso wrote:
> On Thu, 18 Aug 2016, Waiman Long wrote:
>
>> The osq_lock() and osq_unlock() function may not provide the necessary
>> acquire and release barrier in some cases. This patch makes sure
>> that the proper barriers are provided when osq_lock() is successful
>> or when osq_unlock() is called.
>
> But why do we need these guarantees given that osq is only used 
> internally
> for lock owner spinning situations? Leaking out of the critical region 
> will
> obviously be bad if using it as a full lock, but, as is, this can only 
> hurt
> performance of two of the most popular locks in the kernel -- although 
> yes,
> using smp_acquire__after_ctrl_dep is nicer for polling.

First of all, it is not obvious from the name osq_lock() that it is not 
an acquire barrier in some cases. We either need to clearly document it 
or has a variant name that indicate that, e.g. osq_lock_relaxed, for 
example.

Secondly, if we look at the use cases of osq_lock(), the additional 
latency (for non-x86 archs) only matters if the master lock is 
immediately available for acquisition after osq_lock() return. 
Otherwise, it will be hidden in the spinning loop for that master lock. 
So yes, there may be a slight performance hit in some cases, but 
certainly not always.

> If you need tighter osq for rwsems, could it be refactored such that 
> mutexes
> do not take a hit?
>

Yes, we can certainly do that like splitting into 2 variants, one with 
acquire barrier guarantee and one without.

>>
>> Suggested-by: Peter Zijlstra (Intel) <peterz@infradead.org>
>> Signed-off-by: Waiman Long <Waiman.Long@hpe.com>
>> ---
>> kernel/locking/osq_lock.c |   24 ++++++++++++++++++------
>> 1 files changed, 18 insertions(+), 6 deletions(-)
>>
>> diff --git a/kernel/locking/osq_lock.c b/kernel/locking/osq_lock.c
>> index 05a3785..3da0b97 100644
>> --- a/kernel/locking/osq_lock.c
>> +++ b/kernel/locking/osq_lock.c
>> @@ -124,6 +124,11 @@ bool osq_lock(struct optimistic_spin_queue *lock)
>>
>>         cpu_relax_lowlatency();
>>     }
>> +    /*
>> +     * Add an acquire memory barrier for pairing with the release 
>> barrier
>> +     * in unlock.
>> +     */
>> +    smp_acquire__after_ctrl_dep();
>>     return true;
>>
>> unqueue:
>> @@ -198,13 +203,20 @@ void osq_unlock(struct optimistic_spin_queue 
>> *lock)
>>      * Second most likely case.
>>      */
>>     node = this_cpu_ptr(&osq_node);
>> -    next = xchg(&node->next, NULL);
>> -    if (next) {
>> -        WRITE_ONCE(next->locked, 1);
>> +    next = xchg_relaxed(&node->next, NULL);
>> +    if (next)
>> +        goto unlock;
>> +
>> +    next = osq_wait_next(lock, node, NULL);
>> +    if (unlikely(!next)) {
>> +        /*
>> +         * In the unlikely event that the OSQ is empty, we need to
>> +         * provide a proper release barrier.
>> +         */
>> +        smp_mb();
>>         return;
>>     }
>>
>> -    next = osq_wait_next(lock, node, NULL);
>> -    if (next)
>> -        WRITE_ONCE(next->locked, 1);
>> +unlock:
>> +    smp_store_release(&next->locked, 1);
>> }
>
> As well as for the smp_acquire__after_ctrl_dep comment you have above, 
> this also
> obviously pairs with the osq_lock's smp_load_acquire while backing out 
> (unqueueing,
> step A). Given the above, for this case we might also just rely on 
> READ_ONCE(node->locked),
> if we get the conditional wrong and miss the node becoming locked, all 
> we do is another
> iteration, and while there is a cmpxchg() there, it is mitigated with 
> the ccas thingy.

Similar to osq_lock(), the current osq_unlock() does not have a release 
barrier guarantee. I think splitting into 2 variants - osq_unlock, 
osq_unlock_relaxed will help.

Cheers,
Longman
