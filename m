From: Waiman Long <waiman.long@hpe.com>
Date: Wed, 15 Jun 2016 19:01:19 +0000
Subject: Re: [RFC PATCH-tip v2 1/6] locking/osq: Make lock/unlock proper acquire/release barrier
Message-Id: <5761A5FF.5070703@hpe.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1465944489-43440-1-git-send-email-Waiman.Long@hpe.com> <1465944489-43440-2-git-send-email-Waiman.Long@hpe.com> <20160615080446.GA28443@insomnia>
In-Reply-To: <20160615080446.GA28443@insomnia>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Boqun Feng <boqun.feng@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Jason Low <jason.low2@hp.com>, Dave Chinner <david@fromorbit.com>, Scott J Norton <scott.norton@hpe.com>, Douglas Hatch <doug.hatch@hpe.com>

On 06/15/2016 04:04 AM, Boqun Feng wrote:
> Hi Waiman,
>
> On Tue, Jun 14, 2016 at 06:48:04PM -0400, Waiman Long wrote:
>> The osq_lock() and osq_unlock() function may not provide the necessary
>> acquire and release barrier in some cases. This patch makes sure
>> that the proper barriers are provided when osq_lock() is successful
>> or when osq_unlock() is called.
>>
>> Signed-off-by: Waiman Long<Waiman.Long@hpe.com>
>> ---
>>   kernel/locking/osq_lock.c |    4 ++--
>>   1 files changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/kernel/locking/osq_lock.c b/kernel/locking/osq_lock.c
>> index 05a3785..7dd4ee5 100644
>> --- a/kernel/locking/osq_lock.c
>> +++ b/kernel/locking/osq_lock.c
>> @@ -115,7 +115,7 @@ bool osq_lock(struct optimistic_spin_queue *lock)
>>   	 * cmpxchg in an attempt to undo our queueing.
>>   	 */
>>
>> -	while (!READ_ONCE(node->locked)) {
>> +	while (!smp_load_acquire(&node->locked)) {
>>   		/*
>>   		 * If we need to reschedule bail... so we can block.
>>   		 */
>> @@ -198,7 +198,7 @@ void osq_unlock(struct optimistic_spin_queue *lock)
>>   	 * Second most likely case.
>>   	 */
>>   	node = this_cpu_ptr(&osq_node);
>> -	next = xchg(&node->next, NULL);
>> +	next = xchg_release(&node->next, NULL);
>>   	if (next) {
>>   		WRITE_ONCE(next->locked, 1);
> So we still use WRITE_ONCE() rather than smp_store_release() here?
>
> Though, IIUC, This is fine for all the archs but ARM64, because there
> will always be a xchg_release()/xchg() before the WRITE_ONCE(), which
> carries a necessary barrier to upgrade WRITE_ONCE() to a RELEASE.
>
> Not sure whether it's a problem on ARM64, but I think we certainly need
> to add some comments here, if we count on this trick.
>
> Am I missing something or misunderstanding you here?
>
> Regards,
> Boqun

The change on the unlock side is more for documentation purpose than is 
actually needed. As you had said, the xchg() call has provided the 
necessary memory barrier. Using the _release variant, however, may have 
some performance benefit in some architectures.

BTW, osq_lock/osq_unlock aren't general purpose locking primitives. So 
there is some leeways on how fancy we want on the lock and unlock sides.

Cheers,
Longman
