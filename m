From: Michal Hocko <mhocko@kernel.org>
Date: Wed, 09 Mar 2016 14:41:41 +0000
Subject: Re: [RFC 0/12] introduce down_write_killable for rw_semaphore
Message-Id: <20160309144140.GJ27018@dhcp22.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1454444369-2146-1-git-send-email-mhocko@kernel.org>
 <20160309121850.GA14915@gmail.com>
 <20160309125641.GH27018@dhcp22.suse.cz>
 <20160309131710.GB7978@gmail.com>
 <20160309132855.GI27018@dhcp22.suse.cz>
 <20160309134339.GA20911@gmail.com>
In-Reply-To: <20160309134339.GA20911@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Wed 09-03-16 14:43:39, Ingo Molnar wrote:
> 
> * Michal Hocko <mhocko@kernel.org> wrote:
> 
> > On Wed 09-03-16 14:17:10, Ingo Molnar wrote:
> > > 
> > > * Michal Hocko <mhocko@kernel.org> wrote:
> > > 
> > > > >  [...] this is a follow up work for oom_reaper [1]. As the async OOM killing 
> > > > >  depends on oom_sem for read we would really appreciate if a holder for write 
> > > > >  stood in the way. This patchset is changing many of down_write calls to be 
> > > > >  killable to help those cases when the writer is blocked and waiting for 
> > > > >  readers to release the lock and so help __oom_reap_task to process the oom 
> > > > >  victim.
> > > > > 
> > > > > there seems to be a misunderstanding: if a writer is blocked waiting for 
> > > > > readers then no new readers are allowed - the writer will get its turn the 
> > > > > moment all existing readers drop the lock.
> > > > 
> > > > Readers might be blocked e.g. on the memory allocation which cannot proceed due 
> > > > to OOM. Such a reader might be operating on a remote mm.
> > > 
> > > Doing complex allocations with the mm locked looks fragile no matter what: we 
> > > should add debugging code that warns if allocations are done with a remote mm 
> > > locked. (it should be trivial)
> > 
> > No matter how fragile is that it is not something non-existent. Just
> > have a look at use_mm for example. We definitely do not want to warn
> > about those, right?
> 
> Sure we care about eliminating fragility, and usage does not seem to be widespread 
> at all:

This was just an example. We have others. khugepaged which tries to
create THP in the background or proc per pid files handlers might hold
the lock while allocating and who knows what else.
 
>  triton:~/tip> git grep -w use_mm
> 
>  drivers/staging/rdma/hfi1/user_sdma.c:          use_mm(req->pq->user_mm);
>  drivers/usb/gadget/function/f_fs.c:             use_mm(io_data->mm);
>  drivers/usb/gadget/legacy/inode.c:      use_mm(mm);
>  drivers/vhost/vhost.c:  use_mm(dev->mm);
> 
> I think we also want to keep our general flexibility wrt. eventually turning the 
> mmap_sem into a spinlock ...

Many places which are holding mmap_sem are sleepable right (e.g. doing
GFP_KERNEL allocation) now and I am not really sure we can change all of
them to not be.
 
> > > > I am not against interruptible variant as well but I suspect that some paths 
> > > > are not expected to return EINTR. I haven't checked them for this but 
> > > > killable is sufficient for the problem I am trying to solve. That problem is 
> > > > real while latencies do not seem to be that eminent.
> > > 
> > > If they don't expect EINTR then they sure don't expect SIGKILL either!
> > 
> > Why? Each syscall already is killable as the task might be killed by the OOM 
> > killer.
> 
> Not all syscalls are interruptible - for example sys_sync() isn't:

I guess we are talking past each other. What I meant was that while
all syscalls are allowed to not return to the userspace because the
task might get killed but not all of them accept to get interrupted by
a signal and return with EINTR. None of the man page of mmap, mremap,
mlock, mprotect list EINTR as a possibility so I would be really afraid
of returning an unexpected error code.

> SYSCALL_DEFINE0(sync)
> {
>         int nowait = 0, wait = 1;
> 
>         wakeup_flusher_threads(0, WB_REASON_SYNC);
>         iterate_supers(sync_inodes_one_sb, NULL);
>         iterate_supers(sync_fs_one_sb, &nowait);
>         iterate_supers(sync_fs_one_sb, &wait);
>         iterate_bdevs(fdatawrite_one_bdev, NULL);
>         iterate_bdevs(fdatawait_one_bdev, NULL);
>         if (unlikely(laptop_mode))
>                 laptop_sync_completion();
>         return 0;
> }
> 
> > > There's a (very) low number of system calls that are not interruptible, but 
> > > the vast majority is.
> > 
> > That might be true. I just fail to see how this is related to the
> > particular problem I am trying to solve. As I've said those callsites
> > which cause problems with latencies can be later converted to
> > interruptible waiting trivially.
> 
> So my problem as I see it is the following: you are adding a rare API to an 
> already complex locking interface,

I have mimicked an API which we already have for mutex. Sure it is not
used much yet but I guess other callsites might benefit from using it
as well. I haven't explored that because I am trying to focus on the
OOM problem currently. I have tried hard to not complicate the core
locking code just because of the new API. If you have any concerns there
I am willing to look at it.

> further complicating already complicated MM code paths in various
> ways. Only to help a case that is a third type of rare:  OOM-kill.

Seeing OOM livelocks resp. deadlocks is not something unseen. We
have seen some reports in the past. The matter of fact is that it
is easy for an unprivileged user to lock up the system completely
currently (OOM killer tries to kill a task which is blocked on a
lock - e.g. i_mutex - which is held by another process which loops
inside the memory allocator). This issue has been discussed a lot
recently (e.g. LWN coverage of the discussion at LSFMM last year
https://lwn.net/Articles/627419/). That is the reason why I am trying to
make the OOM handling more reliable (by introducing a reliable async oom
reclaim aka oom_reaper_) and that sounds like a sufficient justification
to me.

Does this make more sense now?

> 
> That's a surefire whack-a-mole nest of bugs, if I've ever seen one.
> 
> What I am suggesting instead is a slight modification of the
> concept: to re-phrase the problem set and think in broader terms
> of interruptability: make certain MM operations, especially ones
> which tend to hinder OOM-kill latencies, more interruptible - which
> implicitly also makes them more OOM-killable.

Yeah, I have understood your suggestion and I see it as a more generic
approach as well but my counter argument was that some syscalls might be
unexpected to return EINTR. My quick check of memory management syscalls
shown that EINTR is not described as a potential error code. Or am I
missing something here and you are suggesting ERESTARTNOINTR return path
from down_write_interruptible?

Thanks
-- 
Michal Hocko
SUSE Labs
