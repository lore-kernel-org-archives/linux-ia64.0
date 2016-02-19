From: Michal Hocko <mhocko@kernel.org>
Date: Fri, 19 Feb 2016 12:15:09 +0000
Subject: Re: [RFC 0/12] introduce down_write_killable for rw_semaphore
Message-Id: <20160219121509.GD12690@dhcp22.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1454444369-2146-1-git-send-email-mhocko@kernel.org>
In-Reply-To: <1454444369-2146-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org

Are there any fundamenta lobjections to the patchset? I plan to resubmit
next week with the changes from the feedback along with the mmap_sem
down_write_killable usage.

On Tue 02-02-16 21:19:17, Michal Hocko wrote:
> Hi,
> the following patchset implements a killable variant of write lock for
> rw_semaphore. My usecase is to turn as many mmap_sem write users to use
> a killable variant which will be helpful for the oom_reaper [1] to
> asynchronously tear down the oom victim address space which requires
> mmap_sem for read. This will reduce a likelihood of OOM livelocks caused
> by oom victim being stuck on a lock or other resource which prevents it
> to reach its exit path and release the memory. I haven't implemented
> the killable variant of the read lock because I do not have any usecase
> for this API.
> 
> The patchset is organized as follows.
> - Patch 1 is a trivial cleanup
> - Patch 2, I belive, shouldn't introduce any functional changes as per
>   Documentation/memory-barriers.txt.
> - Patch 3 is the preparatory work and necessary infrastructure for
>   down_write_killable. It implements generic __down_write_killable
>   and prepares the write lock slow path to bail out earlier when told so
> - Patch 4-9 are implementing arch specific __down_write_killable. One
>   patch per architecture. I haven't even tried to compile test anything but
>   sparch which uses CONFIG_RWSEM_GENERIC_SPINLOCK in allnoconfig.
>   Those shold be mostly trivial.
> - One exception is x86 which replaces the current implementation of
>   __down_write with the generic one to make easier to read and get rid
>   of one level of indirection to the slow path. More on that in patch 10.
>   I do not have any problems to drop patch 10 and rework 11 to the current
>   inline asm but I think the easier code would be better.
> - finally patch 11 implements down_write_killable and ties everything
>   together. I am not really an expert on lockdep so I hope I got it right.
> 
> Many of arch specific patches are basically same and I can squash them
> into one patch if this is preferred but I thought that one patch per
> arch is preferable.
> 
> My patch to change mmap_sem write users to killable form is not part
> of the series because it is not finished yet but I guess it is not
> really necessary for the RFC. The API is used in the same way as
> mutex_lock_killable.
> 
> I have tested on x86 with OOM situations with high mmap_sem contention
> (basically many parallel page faults racing with many parallel mmap/munmap
> tight loops) so the waiters for the write locks are routinely interrupted
> by SIGKILL.
> 
> Patches should apply cleanly on both Linus and next tree.
> 
> Any feedback is highly appreciated.
> ---
> [1] http://lkml.kernel.org/r/1452094975-551-1-git-send-email-mhocko@kernel.org

-- 
Michal Hocko
SUSE Labs
