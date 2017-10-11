From: Waiman Long <longman@redhat.com>
Date: Wed, 11 Oct 2017 18:01:51 +0000
Subject: [PATCH v6 00/11] locking/rwsem: Rework rwsem-xadd & enable new rwsem features
Message-Id: <1507744922-15196-1-git-send-email-longman@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Dave Chinner <david@fromorbit.com>, Waiman Long <longman@redhat.com>

v5->v6:
 - Reworked the locking algorithm to make it similar to qrwlock.
 - Removed all the architecture specific code & use only generic code.
 - Added waiter lock handoff and time-based reader lock stealing.

v4->v5:
 - Drop the OSQ patch, the need to increase the size of the rwsem
   structure and the autotuning mechanism.
 - Add an intermediate patch to enable readers spinning on writer.
 - Other miscellaneous changes and optimizations.

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

v4: https://lkml.org/lkml/2016/8/18/1039
v5: https://lkml.org/lkml/2017/6/1/841

This patchset revamps the current rwsem-xadd implmentation to make
it saner and easier to work with. This patchset also implements the
following 3 new features:

 1) Waiter lock handoff
 2) Reader optimistic spinning
 3) Time-based reader lock stealing

With these changes, performance on workloads with a mix of readers
and writers will improve substantially. Now rwsem will also become
reader-preferring instead of writer-preferring, which is usually good
for performance purpose.

This patchset also uses generic code for all architectures, thus
all the architecture specific assembly codes can be removed easing
maintenance.

Patch 1 moves down the rwsem_down_read_failed() function for later
patches.

Patch 2 reworks the rwsem-xadd locking and unlocking codes to use
an algorithm somewhat similar to what qrwlock is doing today. All
the fastpath codes are moved to a new kernel/locking/rwsem-xadd.h
header file.

Patch 3 moves all the owner setting code to the fastpath in the
rwsem-xadd.h file as well.

Patch 4 moves content of kernel/locking/rwsem.h to rwsem-xadd.h and
removes it.

Patch 5 moves rwsem internal functions from include/linux/rwsem.h
to rwsem-xadd.h.

Patch 6 removes all the architecture specific rwsem files.

Patch 7 enables forced lock handoff to the first waiter in the wait
queue when it has waited for too long without acquiring the lock. This
prevents lock starvation and makes rwsem more fair.

Patch 8 enables readers to optimistically spin on a writer owned lock.

Patch 9 enables time-based reader lock stealing, thus making rwsem
reader-preferring instead of writer-preferring.

Patch 10 modifies rwsem_spin_on_owner() to return a tri-state value
that can be used in later patch.

Patch 11 enables writers to optimistically spin on reader-owned lock
using a fixed iteration count.

In term of rwsem performance, a rwsem microbenchmark and fio randrw
test with a xfs filesystem on a ramdisk were used to verify the
performance changes due to these patches. Both tests were run on a
2-socket, 40-core Gold 6148 system. The rwsem microbenchmark (1:1
reader/writer ratio) has short critical section while the fio randrw
test has long critical section (4k read/write).

The following table shows the performance of the rwsem microbenchmark
and fio radrw test with different number of patches applied on 4.14
based kernels:

  # of Patches	Locking Rate	FIO Bandwidth	FIO Bandwidth
    Applied	 40 threads	 32 threads	 16 threads
  ------------	------------	-------------	-------------
	0	  38.7 kop/s	  706 MB/s	  704 MB/s
	7	  38.6 kop/s	  668 MB/s	  663 MB/s
	8	  38.9 kop/s	  704 MB/s	  701 MB/s
	9	  39.1 kop/s	  702 MB/s	  707 MB/s
       11	3218.0 kop/s	 2594 MB/s	 2614 MB/s

So this patchset improves mixed read/write rwsem microbench by 83X
and randrw fio bandwidth by about 3.7X.

With separate reader and writer threads (20 each), the following
table shows the per-thread locking rates (min/mean/max) of the rwsem
microbenchmark with various patch level.

  # of Patches		   Reader 		  Writer
    Applied		Locking Rate		Locking Rate
  ------------		------------		------------
	0	5,155/    5,155/    5,155    5,154/248,852/346,281
	7	5,696/    5,697/    5,698  113,500/215,826/320,872
	8	4,827/    5,047/    5,215    4,826/176,797/284,069
	9     211,276/  509,712/1,134,007    4,894/221,839/246,818
       11     884,513/1,043,989/1,252,533    9,604/ 11,105/ 25,225

It can be seen that rwsem changes from writer-preferring to
reader-preferring.

Waiman Long (11):
  locking/rwsem: relocate rwsem_down_read_failed()
  locking/rwsem: Implement a new locking scheme
  locking/rwsem: Move owner setting code from rwsem.c to rwsem-xadd.h
  locking/rwsem: Remove kernel/locking/rwsem.h
  locking/rwsem: Move rwsem internal function declarations to
    rwsem-xadd.h
  locking/rwsem: Remove arch specific rwsem files
  locking/rwsem: Implement lock handoff to prevent lock starvation
  locking/rwsem: Enable readers spinning on writer
  locking/rwsem: Enable time-based reader lock stealing
  locking/rwsem: Make rwsem_spin_on_owner() return a tri-state value
  locking/rwsem: Enable count-based spinning on reader

 arch/alpha/include/asm/rwsem.h  | 195 --------------
 arch/arm/include/asm/Kbuild     |   1 -
 arch/arm64/include/asm/Kbuild   |   1 -
 arch/hexagon/include/asm/Kbuild |   1 -
 arch/ia64/include/asm/rwsem.h   | 154 ------------
 arch/powerpc/include/asm/Kbuild |   1 -
 arch/s390/include/asm/rwsem.h   | 210 ----------------
 arch/sh/include/asm/Kbuild      |   1 -
 arch/sparc/include/asm/Kbuild   |   1 -
 arch/x86/include/asm/rwsem.h    | 221 ----------------
 arch/x86/lib/Makefile           |   1 -
 arch/x86/lib/rwsem.S            | 144 -----------
 arch/xtensa/include/asm/Kbuild  |   1 -
 include/asm-generic/rwsem.h     | 129 ----------
 include/linux/rwsem.h           |  19 +-
 kernel/locking/percpu-rwsem.c   |   4 +
 kernel/locking/rwsem-xadd.c     | 544 ++++++++++++++++++++++++++--------------
 kernel/locking/rwsem-xadd.h     | 272 ++++++++++++++++++++
 kernel/locking/rwsem.c          |  21 +-
 kernel/locking/rwsem.h          |  68 -----
 20 files changed, 638 insertions(+), 1351 deletions(-)
 delete mode 100644 arch/alpha/include/asm/rwsem.h
 delete mode 100644 arch/ia64/include/asm/rwsem.h
 delete mode 100644 arch/s390/include/asm/rwsem.h
 delete mode 100644 arch/x86/include/asm/rwsem.h
 delete mode 100644 arch/x86/lib/rwsem.S
 delete mode 100644 include/asm-generic/rwsem.h
 create mode 100644 kernel/locking/rwsem-xadd.h
 delete mode 100644 kernel/locking/rwsem.h

-- 
1.8.3.1

