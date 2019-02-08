From: Waiman Long <longman@redhat.com>
Date: Fri, 08 Feb 2019 20:31:18 +0000
Subject: Re: [PATCH-tip 00/22] locking/rwsem: Rework rwsem-xadd & enable new rwsem features
Message-Id: <d7476dfb-1653-747b-b865-5597ba5fc1c1@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1549566446-27967-1-git-send-email-longman@redhat.com>
 <CAHk-=wjfyrFBjifzmgMVrkrvEePEPaBTDq7D=f2i5kD2E=SqRQ@mail.gmail.com>
In-Reply-To: <CAHk-=wjfyrFBjifzmgMVrkrvEePEPaBTDq7D=f2i5kD2E=SqRQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, Linux-sh list <linux-sh@vger.kernel.org>, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch <linux-arch@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Davidlohr Bueso <dave@stgolabs.net>, Andrew Morton <akpm@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>

On 02/08/2019 02:50 PM, Linus Torvalds wrote:
> On Thu, Feb 7, 2019 at 11:08 AM Waiman Long <longman@redhat.com> wrote:
>> This patchset revamps the current rwsem-xadd implementation to make
>> it saner and easier to work with. This patchset removes all the
>> architecture specific assembly code and uses generic C code for all
>> architectures. This eases maintenance and enables us to enhance the
>> code more easily.
>>
>> This patchset also implements the following 3 new features:
>>
>>  1) Waiter lock handoff
>>  2) Reader optimistic spinning
>>  3) Store write-lock owner in the atomic count (x86-64 only)
> The patches are kind of hard to read, with most of them just doing
> prep-work that doesn't necessarily matter to the big picture.
>
> What I'd really like to see is
>
>  (a) an overview of the new locking logic

The new locking logic is similar to qrwlock (see patch 11). Cmpxchg is
used to acquire the write lock, while xadd is still used for read lock.
Some of the bits in the count are also reserved for special purpose like
has waiter or lock handoff. Patch 15 tries to compress the write-lock
owner task pointer and put it into the count field for x86-64 at the
expense of less bits available for reader count. I have sent out an
additional patch this morning to make sure that the reader count won't
overflow.

In term of performance, there isn't much change with respect to
read-lock performance. For write-lock, I saw a slight drop in some
cases, but nothing significant. The merging of owner task pointer into
the count field does impose a slightly bigger drop than I would have
liked which I am going to look into a bit more.

>
>  (b) what's the new fastpath case

The only change in the fastpath is the use of cmpxchg for writer lock.

>
>  (c) some performance numbers

There are performance data at patches 11, 12, 15, 19, 20, 21. There was
performance data for patch 4 as well for eliminating the arch specific
file. Apparently, I might have deleted it accidentally. Anyway, no
noticeable performance difference was observed when switching to use
generic C code for x86, ppc and ARM64.

The major gain in performance is due to reader optimistic spinning
patches. The microbenchmark that I used shown an order of magnitude of
performance improvement for mixed reader-writer workloads. Of course, we
will see less performance gain with real world benchmarks.

I am planning to run more performance test and post the data sometimes
next week. Davidlohr is also going to run some of his rwsem performance
test on this patchset.

>
> to explain the changes from a "this is the point of the whole
> exercise" standpoint.
>
> And yes, I realize that the lock handoff and optimistic spinning is a
> big deal, since I've seen the same regression numbers that presumably
> caused this effort to be resurrected. So it's not that I don't find
> this intriguing and worthwhile, it's literally that I'd like a summary
> not so much of the individual patches, but of the new model.
>
> Please?

Maybe I should break this patchset into a few smaller ones to make it
easier to review. Any suggestion is welcome.

Cheers,
Longman
