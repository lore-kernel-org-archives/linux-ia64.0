From: Waiman Long <waiman.long@hpe.com>
Date: Thu, 06 Oct 2016 19:30:15 +0000
Subject: Re: [RFC PATCH-tip v4 01/10] locking/osq: Make lock/unlock proper acquire/release barrier
Message-Id: <57F6A647.3010207@hpe.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1471554672-38662-1-git-send-email-Waiman.Long@hpe.com> <1471554672-38662-2-git-send-email-Waiman.Long@hpe.com> <20161004190601.GD24086@linux-80c1.suse> <57F4EFCA.6050503@hpe.com> <57F5181F.60202@hpe.com> <20161006054747.GB29373@linux-80c1.suse>
In-Reply-To: <20161006054747.GB29373@linux-80c1.suse>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, Jason Low <jason.low2@hp.com>, Dave Chinner <david@fromorbit.com>, Jonathan Corbet <corbet@lwn.net>, Scott J Norton <scott.norton@hpe.com>, Douglas Hatch <doug.hatch@hpe.com>

On 10/06/2016 01:47 AM, Davidlohr Bueso wrote:
> On Wed, 05 Oct 2016, Waiman Long wrote:
>
>> diff --git a/kernel/locking/osq_lock.c b/kernel/locking/osq_lock.c
>> index 05a3785..1e6823a 100644
>> --- a/kernel/locking/osq_lock.c
>> +++ b/kernel/locking/osq_lock.c
>> @@ -12,6 +12,23 @@
>>  */
>> static DEFINE_PER_CPU_SHARED_ALIGNED(struct optimistic_spin_node, 
>> osq_node);
>>
>> +enum mbtype {
>> +    acquire,
>> +    release,
>> +    relaxed,
>> +};
>
> No, please.
>
>> +
>> +static __always_inline int
>> +_atomic_cmpxchg_(const enum mbtype barrier, atomic_t *v, int old, 
>> int new)
>> +{
>> +    if (barrier = acquire)
>> +        return atomic_cmpxchg_acquire(v, old, new);
>> +    else if (barrier = release)
>> +        return atomic_cmpxchg_release(v, old, new);
>> +    else
>> +        return atomic_cmpxchg_relaxed(v, old, new);
>> +}
>
> Things like the above are icky. How about something like below? I'm not
> crazy about it, but there are other similar macros, ie lockref. We still
> provide the osq_lock/unlock to imply acquire/release and the new _relaxed
> flavor, as I agree that should be the correct naming
>
> While I have not touched osq_wait_next(), the following are impacted:
>
> - node->locked is now completely without ordering for _relaxed() 
> (currently
> its under smp_load_acquire, which does not match and the race is harmless
> to begin with as we just iterate again. For the acquire flavor, it is 
> always
> formed with ctr dep + smp_rmb().
>
> - If osq_lock() fails we never guarantee any ordering.
>
> What do you think?
>
> Thanks,
> Davidlohr

Yes, I am OK with your change. However, I need some additional changes 
in osq_wait_next() as well. Either it is changed to use the release 
variants of atomic_cmpxchg and xchg or using macro like what you did 
with osq_lock and osq_unlock. The release variant is needed in the 
osq_lock(). As osq_wait_next() is only invoked in the failure path of 
osq_lock(), the barrier type doesn't really matter.

Cheers,
Longman
