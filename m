From: Michal Hocko <mhocko@kernel.org>
Date: Fri, 01 Apr 2016 11:04:44 +0000
Subject: [PATCH 0/11] introduce down_write_killable for rw_semaphore v2
Message-Id: <1459508695-14915-1-git-send-email-mhocko@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1456750705-7141-1-git-send-email-mhocko@kernel.org>
In-Reply-To: <1456750705-7141-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org

Hi,
the following patchset implements a killable variant of write lock
for rw_semaphore. My usecase is to turn as many mmap_sem write users
to use a killable variant which will be helpful for the oom_reaper
merged in 4.6-rc1 (aac453635549 ("mm, oom: introduce oom reaper")) to
asynchronously tear down the oom victim address space which requires
mmap_sem for read. This will reduce a likelihood of OOM livelocks caused
by oom victim being stuck on a lock or other resource which prevents it
to reach its exit path and release the memory. I haven't implemented the
killable variant of the read lock because I do not have any usecase for
this API.

The previous version of this series was posted [1] and the only change
since than was the rebase on top of 4.5 (with a clean merge to 4.6-rc1) and
Patch3 was updated to only check for fatal signals when the caller would
block - aka trylock will get the lock even when signals are pending to
be in sync with mutex implementation as per Peter Zijlstra.

The patchset is organized as follows.
- Patch 1 is a trivial cleanup
- Patch 2, I belive, shouldn't introduce any functional changes as per
  Documentation/memory-barriers.txt.
- Patch 3 is the preparatory work and necessary infrastructure for
  down_write_killable. It implements generic __down_write_killable
  and prepares the write lock slow path to bail out earlier when told so
- Patch 4-1 are implementing arch specific __down_write_killable. One
  patch per architecture.
- finally patch 11 implements down_write_killable and ties everything
  together. I am not really an expert on lockdep so I hope I got it right.

Follow up patches to change mmap_sem write users to killable form is not
part of the series because that will be routed via mmotm tree later on.

I have tested on x86 with OOM situations with high mmap_sem contention
(basically many parallel page faults racing with many parallel mmap/munmap
tight loops) so the waiters for the write locks are routinely interrupted
by SIGKILL.

Thanks!

Shortlog says:
Michal Hocko (11):
      locking, rwsem: get rid of __down_write_nested
      locking, rwsem: drop explicit memory barriers
      locking, rwsem: introduce basis for down_write_killable
      alpha, rwsem: provide __down_write_killable
      ia64, rwsem: provide __down_write_killable
      s390, rwsem: provide __down_write_killable
      sh, rwsem: provide __down_write_killable
      sparc, rwsem: provide __down_write_killable
      xtensa, rwsem: provide __down_write_killable
      x86, rwsem: provide __down_write_killable
      locking, rwsem: provide down_write_killable

And diffstat:
 arch/alpha/include/asm/rwsem.h  | 18 ++++++++++++++++--
 arch/ia64/include/asm/rwsem.h   | 22 ++++++++++++++++++---
 arch/s390/include/asm/rwsem.h   | 18 ++++++++++++++----
 arch/sh/include/asm/rwsem.h     | 32 +++++++++++++++----------------
 arch/sparc/include/asm/rwsem.h  | 14 +++++++++++---
 arch/x86/include/asm/rwsem.h    | 42 +++++++++++++++++++++++++----------------
 arch/x86/lib/rwsem.S            |  8 ++++++++
 arch/xtensa/include/asm/rwsem.h | 27 ++++++++++++++------------
 include/asm-generic/rwsem.h     | 13 ++++++++++---
 include/linux/lockdep.h         | 15 +++++++++++++++
 include/linux/rwsem-spinlock.h  |  2 +-
 include/linux/rwsem.h           |  3 +++
 kernel/locking/rwsem-spinlock.c | 19 ++++++++++++++++---
 kernel/locking/rwsem-xadd.c     | 31 ++++++++++++++++++++++++------
 kernel/locking/rwsem.c          | 19 +++++++++++++++++++
 15 files changed, 213 insertions(+), 70 deletions(-)

---
[1] http://lkml.kernel.org/r/1456750705-7141-1-git-send-email-mhocko@kernel.org


