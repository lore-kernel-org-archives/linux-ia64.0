From: Waiman Long <waiman.long@hpe.com>
Date: Fri, 19 Aug 2016 16:21:57 +0000
Subject: Re: [RFC PATCH-tip v4 07/10] locking/rwsem: Change RWSEM_WAITING_BIAS for better disambiguation
Message-Id: <57B73225.7020303@hpe.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1471554672-38662-1-git-send-email-Waiman.Long@hpe.com> <1471554672-38662-8-git-send-email-Waiman.Long@hpe.com> <CANRm+CzfQFHDZDdBc+WxSkFPaE6x=b+PGBeEnnAqgmjDi=1DDA@mail.gmail.com>
In-Reply-To: <CANRm+CzfQFHDZDdBc+WxSkFPaE6x=b+PGBeEnnAqgmjDi=1DDA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wanpeng Li <kernellwp@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390 <linux-s390@vger.kernel.org>, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Jason Low <jason.low2@hp.com>, Dave Chinner <david@fromorbit.com>, Jonathan Corbet <corbet@lwn.net>, Scott J Norton <scott.norton@hpe.com>, Douglas Hatch <doug.hatch@hpe.com>

On 08/19/2016 01:57 AM, Wanpeng Li wrote:
> 2016-08-19 5:11 GMT+08:00 Waiman Long<Waiman.Long@hpe.com>:
>> When the count value is in between 0 and RWSEM_WAITING_BIAS, there
>> are 2 possibilities.
>> Either a writer is present and there is no waiter
> count = 0xffff0001
>
>> or there are waiters and readers. There is no easy way to
> count = 0xffff000X
>
> However, RWSEM_WAITING_BIAS is equal to 0xffff0000, so both these two
> cases are beyond RWSEM_WAITING_BIAS, right?
>
> Regards,
> Wanpeng Li

Perhaps I should make it clear that I am talking from a signed quantity 
point of view (it is an atomic_long_t). So

     RWSEM_WAITING_BIAS < RWSEM_ACTIVE_WRITE_BIAS < 0

Hope this clarify your question.

Cheers,
Longman
