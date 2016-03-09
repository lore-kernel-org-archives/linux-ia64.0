From: Michal Hocko <mhocko@kernel.org>
Date: Wed, 09 Mar 2016 12:56:41 +0000
Subject: Re: [RFC 0/12] introduce down_write_killable for rw_semaphore
Message-Id: <20160309125641.GH27018@dhcp22.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1454444369-2146-1-git-send-email-mhocko@kernel.org>
 <20160309121850.GA14915@gmail.com>
In-Reply-To: <20160309121850.GA14915@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Wed 09-03-16 13:18:50, Ingo Molnar wrote:
> 
> * Michal Hocko <mhocko@kernel.org> wrote:
> 
> > Hi,
> >
> > the following patchset implements a killable variant of write lock for 
> > rw_semaphore. My usecase is to turn as many mmap_sem write users to use a 
> > killable variant which will be helpful for the oom_reaper [1] to asynchronously 
> > tear down the oom victim address space which requires mmap_sem for read. This 
> > will reduce a likelihood of OOM livelocks caused by oom victim being stuck on a 
> > lock or other resource which prevents it to reach its exit path and release the 
> > memory. [...]
> 
> So I'm a tiny bit concerned about this arguments.
> 
> AFAICS killability here just makes existing system calls more interruptible - 
> right?

see below

> In that sense that's not really a livelock scenario: it just takes shorter 
> time for resources to be released.
> 
> If a livelock is possible (where resources are never released) then I'd like to 
> see a specific example of such a livelock.
> 
> You have the other patch-set:
> 
>    [PATCH 0/18] change mmap_sem taken for write killable
> 
> that makes use of down_write_killable(), and there you argue:
> 
>  [...] this is a follow up work for oom_reaper [1]. As the async OOM killing 
>  depends on oom_sem for read we would really appreciate if a holder for write 
>  stood in the way. This patchset is changing many of down_write calls to be 
>  killable to help those cases when the writer is blocked and waiting for readers 
>  to release the lock and so help __oom_reap_task to process the oom victim.
> 
> there seems to be a misunderstanding: if a writer is blocked waiting for readers 
> then no new readers are allowed - the writer will get its turn the moment all 
> existing readers drop the lock.

Readers might be blocked e.g. on the memory allocation which cannot
proceed due to OOM. Such a reader might be operating on a remote mm.

> So there's no livelock scenario - it's "only" about latencies.

Latency is certainly one aspect of it as well because the sooner the
mmap_sem gets released for other readers to sooner the oom_reaper can
tear down the victims address space and release the memory and free up
some memory so that we do not have to wait for the victim to exit.

> And once we realize that it's about latencies (assuming I'm right!), not about 
> correctness per se, I'm wondering whether it would be a good idea to introduce 
> down_write_interruptible(), instead of down_write_killable().

I am not against interruptible variant as well but I suspect that some
paths are not expected to return EINTR. I haven't checked them for this
but killable is sufficient for the problem I am trying to solve. That
problem is real while latencies do not seem to be that eminent.

down_write_interruptible will be trivial to do on top.

-- 
Michal Hocko
SUSE Labs
