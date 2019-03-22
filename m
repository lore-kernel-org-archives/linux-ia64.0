From: Waiman Long <longman@redhat.com>
Date: Fri, 22 Mar 2019 17:23:55 +0000
Subject: Re: [PATCH v5 1/3] locking/rwsem: Remove arch specific rwsem files
Message-Id: <15530d24-51fd-579d-2b1a-2ca98487f63f@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190322143008.21313-1-longman@redhat.com>
 <20190322143008.21313-2-longman@redhat.com>
 <CAHk-=wikkO-1f1=FEOEzkSnaDg3yJLP=4Vd59UCuLBztFd0KOw@mail.gmail.com>
In-Reply-To: <CAHk-=wikkO-1f1=FEOEzkSnaDg3yJLP=4Vd59UCuLBztFd0KOw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "linux-alpha@vger.kernel.org" <linux-arm-kernel@lists.infradead.org>, linux-c6x-dev@linux-c6x.org, uclinux-h8-devel@lists.sourceforge.jp, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k <linux-m68k@lists.linux-m68k.org>, linux-mips@vger.kernel.org, nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, Linux-sh list <linux-sh@vger.kernel.org>, sparclinux@vg

On 03/22/2019 01:01 PM, Linus Torvalds wrote:
> On Fri, Mar 22, 2019 at 7:30 AM Waiman Long <longman@redhat.com> wrote:
>>  19 files changed, 133 insertions(+), 930 deletions(-)
> Lovely. And it all looks sane to me.
>
> So ack.
>
> The only comment I have is about __down_read_trylock(), which probably
> isn't critical enough to actually care about, but:
>
>> +static inline int __down_read_trylock(struct rw_semaphore *sem)
>> +{
>> +       long tmp;
>> +
>> +       while ((tmp = atomic_long_read(&sem->count)) >= 0) {
>> +               if (tmp = atomic_long_cmpxchg_acquire(&sem->count, tmp,
>> +                                  tmp + RWSEM_ACTIVE_READ_BIAS)) {
>> +                       return 1;
>> +               }
>> +       }
>> +       return 0;
>> +}
> So this seems to
>
>  (a) read the line early (the whole cacheline in shared state issue)
>
>  (b) read the line again unnecessarily in the while loop
>
> Now, (a) might be explained by "well, maybe we do trylock even with
> existing readers", although I continue to think that the case we
> should optimize for is simply the uncontended one, where we don't even
> have multiple readers.
>
> But (b) just seems silly.
>
> So I wonder if it shouldn't just be
>
>         long tmp = 0;
>
>         do {
>                 long new = atomic_long_cmpxchg_acquire(&sem->count, tmp,
>                         tmp + RWSEM_ACTIVE_READ_BIAS);
>                 if (likely(new = tmp))
>                         return 1;
>                tmp = new;
>         } while (tmp >= 0);
>         return 0;
>
> which would seem simpler and solve both issues. Hmm?
>
> But honestly, I didn't check what our uses of down_read_trylock() look
> like. We have more of them than I expected, and I _think_ the normal
> case is the "nobody else holds the lock", but that's just a gut
> feeling.
>
> Some of them _might_ be performance-critical. There's the one on
> mmap_sem in the fault handling path, for example. And yes, I'd expect
> the normal case to very much be "no other readers or writers" for that
> one.
>
> NOTE! The above code snippet is absolutely untested, and might be
> completely wrong. Take it as a "something like this" rather than
> anything else.
>
>                    Linus

As you have noticed already, this patch is just for moving code around
without changing it. I optimize __down_read_trylock() in patch 3.

Cheers,
Longman
