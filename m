From: Michal Hocko <mhocko@kernel.org>
Date: Mon, 29 Feb 2016 12:58:14 +0000
Subject: [PATCH 0/11] introduce down_write_killable for rw_semaphore
Message-Id: <1456750705-7141-1-git-send-email-mhocko@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org

Hi,
I have posted this series [1] and there didn't seem to be any
fundamental objections except for x86 maintainers who preferred the asm
__down_write implementation which I have reworked for this series. Apart
from that I have refreshed on top of the current linux-next and fixed
one unused variable warning which happened to trigger a compilation
failure on ppc.

The following patchset implements a killable variant of write lock for
rw_semaphore. My usecase is to turn as many mmap_sem write users to use
a killable variant which will be helpful for the oom_reaper [2] to
asynchronously tear down the oom victim address space which requires
mmap_sem for read. This will reduce a likelihood of OOM livelocks caused
by oom victim being stuck on a lock or other resource which prevents it
to reach its exit path and release the memory. I haven't implemented
the killable variant of the read lock because I do not have any usecase
for this API.

The patchset is organized as follows.
- Patch 1 is a trivial cleanup
- Patch 2, I belive, shouldn't introduce any functional changes as per
  Documentation/memory-barriers.txt.
- Patch 3 is the preparatory work and necessary infrastructure for
  down_write_killable. It implements generic __down_write_killable
  and prepares the write lock slow path to bail out earlier when told so
- Patch 4-1- are implementing arch specific __down_write_killable. One
  patch per architecture.
- finally patch 11 implements down_write_killable and ties everything
  together. I am not really an expert on lockdep so I hope I got it right.

Many of arch specific patches are basically same and I can squash them
into one patch if this is preferred but I thought that one patch per
arch is preferable.

My patch to change mmap_sem write users to killable form is not part of
the series because it is a larger change and I would like to prevent
from spamming people too much. I will post the series shortly.

I have tested on x86 with OOM situations with high mmap_sem contention
(basically many parallel page faults racing with many parallel mmap/munmap
tight loops) so the waiters for the write locks are routinely interrupted
by SIGKILL.

Patches should apply cleanly on both Linus and next tree.

[1] http://lkml.kernel.org/r/1454444369-2146-1-git-send-email-mhocko@kernel.org
[2] http://lkml.kernel.org/r/1452094975-551-1-git-send-email-mhocko@kernel.org

Any feedback is highly appreciated.
