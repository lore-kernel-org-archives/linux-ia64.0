From: Waiman Long <Waiman.Long@hpe.com>
Date: Thu, 18 Aug 2016 21:11:02 +0000
Subject: [RFC PATCH-tip v4 00/10] locking/rwsem: Enable reader optimistic spinning
Message-Id: <1471554672-38662-1-git-send-email-Waiman.Long@hpe.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Jason Low <jason.low2@hp.com>, Dave Chinner <david@fromorbit.com>, Jonathan Corbet <corbet@lwn.net>, Scott J Norton <scott.norton@hpe.com>, Douglas Hatch <doug.hatch@hpe.com>, Waiman Long <Waiman.Long@hpe.com>

v3->v4:
 - Rebased to the latest tip tree due to changes to rwsem-xadd.c.
 - Update the OSQ patch to fix race condition.

v2->v3:
 - Used smp_acquire__after_ctrl_dep() to provide acquire barrier.
 - Added the following new patches:
   1) make rwsem_spin_on_owner() return a tristate value.
   2) reactivate reader spinning when there is a large number of
      favorable writer-on-writer spinnings.
   3) move all the rwsem macros in arch-specific rwsem.h files
      into a common asm-generic/rwsem_types.h file.
   4) add a boot parameter to specify the reader spinning threshold.
 - Updated some of the patches as suggested by PeterZ and adjusted
   some of the reader spinning parameters.

v1->v2:
 - Fixed a 0day build error.
 - Added a new patch 1 to make osq_lock() a proper acquire memory
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
from reader optimistic spinning. It will maintain reader spinning as
long as no less than 80% of the spins are successful.

Patch 1 updates the osq_lock() function to make it a proper acquire
memory barrier.

Patch 2 reduces the length of the blocking window after a read locking
attempt where writer lock stealing is disabled because of the active
read lock. It can improve rwsem performance for contended lock. It is
independent of the rest of the patchset.

Patch 3 modifies rwsem_spin_on_owner() to return a tri-state value
that can be used in later patch.

Patch 4 puts in place the autotuning mechanism to check if reader
optimistic spinning should be used or not.

Patch 5 moves down the rwsem_down_read_failed() function for later
patches.

Patch 6 moves the macro definitions in various arch-specific rwsem.h
header files into a commont asm-generic/rwsem_types.h file.

Patch 7 changes RWSEM_WAITING_BIAS to simpify reader trylock code.

Patch 8 enables readers to do optimistic spinning.

Patch 9 allows reactivation of reader spinning when a lot of
writer-on-writer spins are successful.

Patch 10 adds a new boot parameter to change the reader spinning
threshold which can be system specific.

Waiman Long (10):
  locking/osq: Make lock/unlock proper acquire/release barrier
  locking/rwsem: Stop active read lock ASAP
  locking/rwsem: Make rwsem_spin_on_owner() return a tri-state value
  locking/rwsem: Enable count-based spinning on reader
  locking/rwsem: move down rwsem_down_read_failed function
  locking/rwsem: Move common rwsem macros to asm-generic/rwsem_types.h
  locking/rwsem: Change RWSEM_WAITING_BIAS for better disambiguation
  locking/rwsem: Enable spinning readers
  locking/rwsem: Enable reactivation of reader spinning
  locking/rwsem: Add a boot parameter to reader spinning threshold

 Documentation/kernel-parameters.txt |    3 +
 arch/alpha/include/asm/rwsem.h      |   11 +-
 arch/ia64/include/asm/rwsem.h       |    9 +-
 arch/s390/include/asm/rwsem.h       |    9 +-
 arch/x86/include/asm/rwsem.h        |   22 +---
 include/asm-generic/rwsem.h         |   20 +--
 include/asm-generic/rwsem_types.h   |   28 ++++
 include/linux/rwsem.h               |   23 +++-
 kernel/locking/osq_lock.c           |   24 ++-
 kernel/locking/rwsem-xadd.c         |  296 ++++++++++++++++++++++++++---------
 10 files changed, 308 insertions(+), 137 deletions(-)
 create mode 100644 include/asm-generic/rwsem_types.h

