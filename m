From: Waiman Long <Waiman.Long@hpe.com>
Date: Tue, 14 Jun 2016 18:12:33 +0000
Subject: [RFC PATCH-tip 0/6] locking/rwsem: Enable reader optimistic spinning
Message-Id: <1465927959-39719-1-git-send-email-Waiman.Long@hpe.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, xfs@oss.sgi.com, Davidlohr Bueso <dave@stgolabs.net>, Jason Low <jason.low2@hp.com>, Dave Chinner <david@fromorbit.com>, Scott J Norton <scott.norton@hpe.com>, Douglas Hatch <doug.hatch@hpe.com>, Waiman Long <Waiman.Long@hpe.com>

This patchset adds an option to enable more aggressive optimistic
spinning on both readers and writers waiting on a writer or reader
owned lock. Spinning on writer is done by looking at the on_cpu
flag of the lock owner. Spinning on readers, on the other hand, is
count-based as there is no easy way to figure out if all the readers
are running. The spinner will stop spinning once the count goes to
0. Because of that, spinning on readers may hurt performance in some
cases. So this feature is optional and has to explicitly enabled for
those rwsems where the readers are unlikely to go to sleep.

Patch 1 reduces the length of the blocking window after a read locking
attempt where writer lock stealing is disabled because of the active
read lock. It can improve rwsem performance for contended lock. It is
independent of the rest of the patchset.

Patches 2-5 lays the groundwork for enabling reader optimistic spinning.

Patch 6 enables reader optimistic spinning in XFS for inodes that
comes from a DAX-enabled mount point on top of persistent memory as
the CPUs can do I/O directly without waiting or sleeping.

Waiman Long (6):
  locking/rwsem: Stop active read lock ASAP
  locking/rwsem: Enable optional count-based spinning on reader
  locking/rwsem: move down rwsem_down_read_failed function
  locking/rwsem: Change RWSEM_WAITING_BIAS for better disambiguation
  locking/rwsem: Enable spinning readers
  xfs: Enable reader optimistic spinning for DAX inodes

 arch/alpha/include/asm/rwsem.h |    7 +-
 arch/ia64/include/asm/rwsem.h  |    6 +-
 arch/s390/include/asm/rwsem.h  |    6 +-
 arch/x86/include/asm/rwsem.h   |   13 ++-
 fs/xfs/xfs_icache.c            |    9 ++
 include/asm-generic/rwsem.h    |    9 +-
 include/linux/rwsem.h          |   21 ++++-
 kernel/locking/rwsem-xadd.c    |  212 ++++++++++++++++++++++++++--------------
 8 files changed, 192 insertions(+), 91 deletions(-)

