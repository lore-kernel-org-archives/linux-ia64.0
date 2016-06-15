From: Waiman Long <waiman.long@hpe.com>
Date: Wed, 15 Jun 2016 19:28:03 +0000
Subject: Re: [RFC PATCH-tip v2 3/6] locking/rwsem: Enable count-based spinning on reader
Message-Id: <5761AC43.5080707@hpe.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1465944489-43440-1-git-send-email-Waiman.Long@hpe.com> <1465944489-43440-4-git-send-email-Waiman.Long@hpe.com> <20160615173830.GR30921@twins.programming.kicks-ass.net>
In-Reply-To: <20160615173830.GR30921@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Jason Low <jason.low2@hp.com>, Dave Chinner <david@fromorbit.com>, Scott J Norton <scott.norton@hpe.com>, Douglas Hatch <doug.hatch@hpe.com>

On 06/15/2016 01:38 PM, Peter Zijlstra wrote:
> On Tue, Jun 14, 2016 at 06:48:06PM -0400, Waiman Long wrote:
>>   static bool rwsem_optimistic_spin(struct rw_semaphore *sem)
>>   {
>> -	bool taken = false;
>> +	bool taken = false, can_spin;
> I would place the variables without assignment first.

Sure, easy change.

>
>> +	int loopcnt;
>>
>>   	preempt_disable();
>>
>> @@ -409,6 +412,8 @@ static bool rwsem_optimistic_spin(struct rw_semaphore *sem)
>>   	if (!osq_lock(&sem->osq))
>>   		goto done;
>>
>> +	loopcnt = sem->rspin_enabled ? RWSEM_RSPIN_THRESHOLD : 0;
>> +
>>   	/*
>>   	 * Optimistically spin on the owner field and attempt to acquire the
>>   	 * lock whenever the owner changes. Spinning will be stopped when:
>> @@ -416,7 +421,7 @@ static bool rwsem_optimistic_spin(struct rw_semaphore *sem)
>>   	 *  2) readers own the lock as we can't determine if they are
>>   	 *     actively running or not.
>>   	 */
>> -	while (rwsem_spin_on_owner(sem)) {
>> +	while ((can_spin = rwsem_spin_on_owner(sem)) || loopcnt) {
>>   		/*
>>   		 * Try to acquire the lock
>>   		 */
>> @@ -425,13 +430,16 @@ static bool rwsem_optimistic_spin(struct rw_semaphore *sem)
>>   			break;
>>   		}
>>
>> +		if (!can_spin&&  loopcnt)
>> +			loopcnt--;
> This seems to suggest 'can_spin' is a bad name, because if we cannot
> spin, we do in fact spin anyway?
>
> Maybe call it write_spin or something, which makes it clear that if its
> not a write spin we'll do a read spin?

I am fine with the write_spin name.

>
> Also, isn't this the wrong level to do loopcnt at?
> rwsem_spin_on_owner() can have spend any amount of cycles spinning. So
> you're not counting loops of similar unit.

The loopcnt does not include time spinning on writer. It will be 
decremented only if the lock is owned by reader (can_spin = false). I 
will clarify that with additional comments.

>> +	/*
>> +	 * Was owner a reader?
>> +	 */
>> +	if (rwsem_owner_is_reader(sem->owner)) {
>> +		/*
>> +		 * Update rspin_enabled for reader spinning
> full stop and newline?

Sure.

>
>> +		 * Increment by 1 if successfully&  decrement by 8 if
>> +		 * unsuccessful.
> This is bloody obvious from the code, explain why, not what the code
> does.

Will clarify the comment.

>>                                 The decrement amount is kind of arbitrary
>> +		 * and can be adjusted if necessary.
>> +		 */
>> +		if (taken&&  (sem->rspin_enabled<  RWSEM_RSPIN_ENABLED_MAX))
>> +			sem->rspin_enabled++;
>> +		else if (!taken)
>> +			sem->rspin_enabled = (sem->rspin_enabled>= 8)
>> +					   ? sem->rspin_enabled - 8 : 0;
> This is unreadable and against coding style.

I will fix the coding style problem.

Cheers,
Longman
