From: Michal Hocko <mhocko@kernel.org>
Date: Thu, 07 Apr 2016 15:12:20 +0000
Subject: [PATCH 0/11] introduce down_write_killable for rw_semaphore v3
Message-Id: <1460041951-22347-1-git-send-email-mhocko@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1456750705-7141-1-git-send-email-mhocko@kernel.org>
In-Reply-To: <1456750705-7141-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Michal Hocko <mhocko@suse.com>

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

The previous version of this series was posted [1]. I have dropped patches 7-9
based on Davidlohr Bueso feedback because he pointed out that sh and extensa
can use the generic implementation. Further investigation has shown the same
is true for sparc. While those patches were removed 3 new ones were added for
same archs to use the generic implementation. Other than that there were no
functional changes since the last version.

The patchset is organized as follows.
- Patch 1 is a trivial cleanup
- Patch 2, I belive, shouldn't introduce any functional changes as per
  Documentation/memory-barriers.txt.
- Patches 3-5 are moving xtensa, sh and sparc to generic implementation
- Patch 6 is the preparatory work and necessary infrastructure for
  down_write_killable. It implements generic __down_write_killable
  and prepares the write lock slow path to bail out earlier when told so
- Patch 7-10 are implementing arch specific __down_write_killable. One
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
---
[1] http://lkml.kernel.org/r/1459508695-14915-1-git-send-email-mhocko@kernel.org

