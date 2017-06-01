From: Waiman Long <longman@redhat.com>
Date: Thu, 01 Jun 2017 17:38:58 +0000
Subject: [PATCH v5 0/9] locking/rwsem: Enable reader optimistic spinning
Message-Id: <1496338747-20398-1-git-send-email-longman@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Dave Chinner <david@fromorbit.com>, Waiman Long <longman@redhat.com>

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

This patchset enables more aggressive optimistic spinning on both
readers and writers waiting on a writer or reader owned lock. Spinning
on writer is done by looking at the on_cpu flag of the lock owner.

Spinning on readers, on the other hand, is count-based as there is no
easy way to figure out if all the readers are running. The spinner
will stop spinning once the count goes to 0. It will then set a bit
in the owner field to indicate that reader spinning is disabled for
the current reader-owned locking session so that subsequent writers
won't continue spinning.

Patch 1 moves down the rwsem_down_read_failed() function for later
patches.

Patch 2 reduces the length of the blocking window after a read locking
attempt where writer lock stealing is disabled because of the active
read lock. It can improve rwsem performance for contended lock.

Patch 3 moves the macro definitions in various arch-specific rwsem.h
header files into a commont asm-generic/rwsem_types.h file.

Patch 4 changes RWSEM_WAITING_BIAS to simpify reader trylock code
that is needed for reader optimistic spinning.

Patch 5 enables reader to spin on writer-owned lock.

Patch 6 uses a new bit in the owner field to indicate that reader
spinning should be disabled for the current reader-owned locking
session. It will be cleared when a writer owns the lock again.

Patch 7 modifies rwsem_spin_on_owner() to return a tri-state value
that can be used in later patch.

Patch 8 enables writers to optimistically spin on reader-owned lock
using a fixed iteration count.

Patch 9 enables reader lock stealing as long as the lock is
reader-owned and reader optimistic spinning isn't disabled.

In term of rwsem performance, a rwsem microbenchmark and fio randrw
test with a xfs filesystem on a ramdisk were used to verify the
performance changes due to these patches. Both tests were run on a
2-socket, 36-core E5-2699 v3 system with turbo-boosting off. The rwsem
microbenchmark (1:1 reader/writer ratio) has short critical section
while the fio randrw test has long critical section (4k read/write).

The following table shows the performance of the rwsem microbenchmark
with different number of patches applied:

  # of Patches	Locking rate	FIO Bandwidth	FIO Bandwidth
    Applied	 36 threads	 36 threads	 16 threads
  ------------	------------	-------------	-------------
	0	 510.1 Mop/s	  785 MB/s	  835 MB/s
	2	 520.1 Mop/s	  789 MB/s	  835 MB/s
	5	1760.2 Mop/s	  281 MB/s	  818 MB/s
	8	5439.0 Mop/s	 1361 MB/s	 1367 MB/s
	9	5440.8 Mop/s	 1324 MB/s	 1356 MB/s

With the readers spinning on writer patch (patch 5), performance
improved with short critical section workload, but degraded with
long critical section workload. This is caused by the fact that 
existing code tends to collect all the readers in the wait queue and
wake all of them up together making them all proceed in parallel. On
the other hand, patch 5 will kind of breaking up the readers into
smaller batches sandwitched among the writers. So we see big drop
with 36 threads, but much smaller drop with 16 threads. Fortunately,
the performance drop was gone once we have the full patchset.

A different fio test with 18 reader threads and 18 writer threads
was also run to see how the rwsem code perfers readers or writers.

  # of Patches	Read Bandwith	Write Bandwidth
  ------------	-------------	---------------
	0	   86 MB/s	  883 MB/s
	2	   86 MB/s	  919 MB/s
	5	  158 MB/s	  393 MB/s
	8	 2830 MB/s	 1404 MB/s (?)
	9	 2903 MB/s	 1367 MB/s (?)

It can be seen that the existing rwsem code perfers writers. With this
patchset, it becomes readers preferring. Please note that for the
last 2 entries, the reader threads exited before the writer threads
and so the write bandwidth were actually inflated.

Waiman Long (9):
  locking/rwsem: relocate rwsem_down_read_failed()
  locking/rwsem: Stop active read lock ASAP
  locking/rwsem: Move common rwsem macros to asm-generic/rwsem_types.h
  locking/rwsem: Change RWSEM_WAITING_BIAS for better disambiguation
  locking/rwsem: Enable readers spinning on writer
  locking/rwsem: Use bit in owner to stop spinning
  locking/rwsem: Make rwsem_spin_on_owner() return a tri-state value
  locking/rwsem: Enable count-based spinning on reader
  locking/rwsem: Enable reader lock stealing

 arch/alpha/include/asm/rwsem.h    |  11 +-
 arch/ia64/include/asm/rwsem.h     |   9 +-
 arch/s390/include/asm/rwsem.h     |   9 +-
 arch/x86/include/asm/rwsem.h      |  22 +--
 include/asm-generic/rwsem.h       |  19 +--
 include/asm-generic/rwsem_types.h |  28 ++++
 kernel/locking/rwsem-xadd.c       | 282 ++++++++++++++++++++++++++++----------
 kernel/locking/rwsem.h            |  66 +++++++--
 8 files changed, 307 insertions(+), 139 deletions(-)
 create mode 100644 include/asm-generic/rwsem_types.h

-- 
1.8.3.1

