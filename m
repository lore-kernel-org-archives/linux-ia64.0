From: Waiman Long <Waiman.Long@hpe.com>
Date: Tue, 14 Jun 2016 22:48:03 +0000
Subject: [RFC PATCH-tip v2 0/6] locking/rwsem: Enable reader optimistic spinning
Message-Id: <1465944489-43440-1-git-send-email-Waiman.Long@hpe.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Jason Low <jason.low2@hp.com>, Dave Chinner <david@fromorbit.com>, Scott J Norton <scott.norton@hpe.com>, Douglas Hatch <doug.hatch@hpe.com>, Waiman Long <Waiman.Long@hpe.com>

v1->v2:
 - Fixed a 0day build error.
 - Add a new patch 1 to make osq_lock() a proper acquire memory
   barrier.
 - Replaced the explicit enabling of reader spinning by an autotuning
   mechanism that disable reader spinning for those rwsems that may
   not benefit from reader spinning.
 - Remove the last xfs patch as it is no longer necessary.

This patchset enables more aggressive optimistic spinning on
both readers and writers waiting on a writer or reader owned
lock. Spinning on writer is done by looking at the on_cpu flag of the
lock owner. Spinning on readers, on the other hand, is count-based as
there is no easy way to figure out if all the readers are running. The
spinner will stop spinning once the count goes to 0. Because of that,
spinning on readers may hurt performance in some cases.

An autotuning mechanism is used to determine if a rwsem can benefit
from reader optimistic spinning.

Patch 1 updates the osq_lock() function to make it a proper acquire
memory barrier.

Patch 2 reduces the length of the blocking window after a read locking
attempt where writer lock stealing is disabled because of the active
read lock. It can improve rwsem performance for contended lock. It is
independent of the rest of the patchset.

Patch 3 puts in place the autotuning mechanism to check if reader
optimistic spinning should be used or not.

Patch 4 moves down the rwsem_down_read_failed() function for later
patches.

Patch 5 changes RWSEM_WAITING_BIAS to simpify reader trylock code.

Patch 6 enables readers to do optimistic spinning.

Waiman Long (6):
  locking/osq: Make lock/unlock proper acquire/release barrier
  locking/rwsem: Stop active read lock ASAP
  locking/rwsem: Enable count-based spinning on reader
  locking/rwsem: move down rwsem_down_read_failed function
  locking/rwsem: Change RWSEM_WAITING_BIAS for better disambiguation
  locking/rwsem: Enable spinning readers

 arch/alpha/include/asm/rwsem.h |    7 +-
 arch/ia64/include/asm/rwsem.h  |    6 +-
 arch/s390/include/asm/rwsem.h  |    6 +-
 arch/x86/include/asm/rwsem.h   |   13 ++-
 include/asm-generic/rwsem.h    |    9 +-
 include/linux/rwsem.h          |   19 +++-
 kernel/locking/osq_lock.c      |    4 +-
 kernel/locking/rwsem-xadd.c    |  238 ++++++++++++++++++++++++++++------------
 8 files changed, 209 insertions(+), 93 deletions(-)

