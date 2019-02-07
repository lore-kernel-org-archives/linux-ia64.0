From: Waiman Long <longman@redhat.com>
Date: Thu, 07 Feb 2019 19:07:04 +0000
Subject: [PATCH-tip 00/22] locking/rwsem: Rework rwsem-xadd & enable new rwsem features
Message-Id: <1549566446-27967-1-git-send-email-longman@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Davidlohr Bueso <dave@stgolabs.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>, Waiman Long <longman@redhat.com>

This patchset revamps the current rwsem-xadd implementation to make
it saner and easier to work with. This patchset removes all the
architecture specific assembly code and uses generic C code for all
architectures. This eases maintenance and enables us to enhance the
code more easily.

This patchset also implements the following 3 new features:

 1) Waiter lock handoff
 2) Reader optimistic spinning
 3) Store write-lock owner in the atomic count (x86-64 only)

Waiter lock handoff is similar to the mechanism currently in the mutex
code. This ensures that lock starvation won't happen.

Reader optimistic spinning enables readers to acquire the lock more
quickly.  So workloads that use a mix of readers and writers should
see an increase in performance.

Finally, storing the write-lock owner into the count will allow
optimistic spinners to get to the lock holder's task structure more
quickly and eliminating the timing gap where the write lock is acquired
but the owner isn't known yet. This is important for RT tasks where
spinning on a lock with an unknown owner is not allowed.

Because of the fact that multiple readers can share the same lock,
there is a natural preference for readers when measuring in term of
locking throughput as more readers are likely to get into the locking
fast path than the writers. With waiter lock handoff, we are not going
to starve the writers.

Patches 1-2 reworks the qspinlock_stat code to make it generic (lock
event counting) so that it can be used by all architectures and all
locking code.

Patch 3 reloctes the rwsem_down_read_failed() and associated functions
to below the optimistic spinning functions.

Patch 4 eliminates all architecture specific code and use generic C
code for all.

Patch 5 moves code that manages the owner field closer to the rwsem
lock fast path as it is not needed by the rwsem-spinlock code.

Patch 6 renames rwsem.h to rwsem-xadd.h as it is now specific to
rwsem-xadd.c only.

Patch 7 hides the internal rwsem-xadd functions from the public.

Patch 8 moves the DEBUG_RWSEMS_WARN_ON checks from rwsem.c to
kernel/locking/rwsem-xadd.h and adds some new ones.

Patch 9 enhances the DEBUG_RWSEMS_WARN_ON macro to print out rwsem
internal states that can be useful for debugging purpose.

Patch 10 enables lock event countings in the rwsem code.

Patch 11 implements a new rwsem locking scheme similar to what qrwlock
is current doing. Write lock is done by atomic_cmpxchg() while read
lock is still being done by atomic_add().

Patch 12 implments lock handoff to prevent lock starvation.

Patch 13 removes rwsem_wake() wakeup optimization as it doesn't work
with lock handoff.

Patch 14 adds some new rwsem owner access helper functions.

Patch 15 merges the write-lock owner task pointer into the count.
Only 64-bit count has enough space to provide a reasonable number of bits
for reader count. ARM64 seems to have problem with the current encoding
scheme. So this owner merging is currently limited to x86-64 only.

Patch 16 eliminates redundant computation of the merged owner-count.

Patch 17 reduces the chance of missed optimistic spinning opportunity
because of some race conditions.

Patch 18 makes rwsem_spin_on_owner() returns a tri-state value.

Patch 19 enables reader to spin on a writer-owned rwsem.

Patch 20 enables lock waiters to spin on a reader-owned rwsem with
limited number of tries.

Patch 21 makes reader wakeup to wake all the readers in the wait queue
instead of just those in the front.

Patch 22 disallows RT tasks to spin on a rwsem with unknown owner.

In term of performance, eliminating architecture specific assembly code
and using generic code doesn't seem to have any impact on performance.

Supporting lock handoff does have a minor performance impact on highly
contended rwsem, but it is a price worth paying for preventing lock
starvation.

Reader optimistic spinning is generally good for performance. Of course,
there will be some corner cases where performance may suffer.

Merging owner into count does have a minor performance impact. We can
discuss if this is a feature we want to have in the rwsem code.

There are also some performance data scattered in some of the patches.


Waiman Long (22):
  locking/qspinlock_stat: Introduce a generic lockevent counting APIs
  locking/lock_events: Make lock_events available for all archs & other
    locks
  locking/rwsem: Relocate rwsem_down_read_failed()
  locking/rwsem: Remove arch specific rwsem files
  locking/rwsem: Move owner setting code from rwsem.c to rwsem.h
  locking/rwsem: Rename kernel/locking/rwsem.h
  locking/rwsem: Move rwsem internal function declarations to
    rwsem-xadd.h
  locking/rwsem: Add debug check for __down_read*()
  locking/rwsem: Enhance DEBUG_RWSEMS_WARN_ON() macro
  locking/rwsem: Enable lock event counting
  locking/rwsem: Implement a new locking scheme
  locking/rwsem: Implement lock handoff to prevent lock starvation
  locking/rwsem: Remove rwsem_wake() wakeup optimization
  locking/rwsem: Add more rwsem owner access helpers
  locking/rwsem: Merge owner into count on x86-64
  locking/rwsem: Remove redundant computation of writer lock word
  locking/rwsem: Recheck owner if it is not on cpu
  locking/rwsem: Make rwsem_spin_on_owner() return a tri-state value
  locking/rwsem: Enable readers spinning on writer
  locking/rwsem: Enable count-based spinning on reader
  locking/rwsem: Wake up all readers in wait queue
  locking/rwsem: Ensure an RT task will not spin on reader

 MAINTAINERS                         |   1 -
 arch/Kconfig                        |  10 +
 arch/alpha/include/asm/rwsem.h      | 211 -----------
 arch/arm/include/asm/Kbuild         |   1 -
 arch/arm64/include/asm/Kbuild       |   1 -
 arch/hexagon/include/asm/Kbuild     |   1 -
 arch/ia64/include/asm/rwsem.h       | 172 ---------
 arch/powerpc/include/asm/Kbuild     |   1 -
 arch/s390/include/asm/Kbuild        |   1 -
 arch/sh/include/asm/Kbuild          |   1 -
 arch/sparc/include/asm/Kbuild       |   1 -
 arch/x86/Kconfig                    |   8 -
 arch/x86/include/asm/rwsem.h        | 237 -------------
 arch/x86/lib/Makefile               |   1 -
 arch/x86/lib/rwsem.S                | 156 ---------
 arch/xtensa/include/asm/Kbuild      |   1 -
 include/asm-generic/rwsem.h         | 140 --------
 include/linux/rwsem.h               |  11 +-
 kernel/locking/Makefile             |   1 +
 kernel/locking/lock_events.c        | 153 ++++++++
 kernel/locking/lock_events.h        |  55 +++
 kernel/locking/lock_events_list.h   |  71 ++++
 kernel/locking/percpu-rwsem.c       |   4 +
 kernel/locking/qspinlock.c          |   8 +-
 kernel/locking/qspinlock_paravirt.h |  19 +-
 kernel/locking/qspinlock_stat.h     | 242 +++----------
 kernel/locking/rwsem-xadd.c         | 682 +++++++++++++++++++++---------------
 kernel/locking/rwsem-xadd.h         | 436 +++++++++++++++++++++++
 kernel/locking/rwsem.c              |  31 +-
 kernel/locking/rwsem.h              | 134 -------
 30 files changed, 1197 insertions(+), 1594 deletions(-)
 delete mode 100644 arch/alpha/include/asm/rwsem.h
 delete mode 100644 arch/ia64/include/asm/rwsem.h
 delete mode 100644 arch/x86/include/asm/rwsem.h
 delete mode 100644 arch/x86/lib/rwsem.S
 delete mode 100644 include/asm-generic/rwsem.h
 create mode 100644 kernel/locking/lock_events.c
 create mode 100644 kernel/locking/lock_events.h
 create mode 100644 kernel/locking/lock_events_list.h
 create mode 100644 kernel/locking/rwsem-xadd.h
 delete mode 100644 kernel/locking/rwsem.h

-- 
1.8.3.1
