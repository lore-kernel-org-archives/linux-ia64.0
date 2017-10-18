From: Waiman Long <longman@redhat.com>
Date: Wed, 18 Oct 2017 18:30:16 +0000
Subject: [PATCH-tip v7 00/15] locking/rwsem: Rework rwsem-xadd & enable new rwsem features
Message-Id: <1508351431-22375-1-git-send-email-longman@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Dave Chinner <david@fromorbit.com>, Waiman Long <longman@redhat.com>

v6->v7:
 - Remove reader lock stealing patch and add other patches to improve
   fairness to writers.
 - Remove rwsem_wake() optimization, but eliminate duplicated wakeup
   call to the same waiting writer.
 - Enable waiting writer to optimisticially spin on the lock.
 - Reader wakeup will now wake up all readers in the queue.

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
v6: https://lkml.org/lkml/2017/10/11/722

This patchset revamps the current rwsem-xadd implmentation to make
it saner and easier to work with. This patchset also implements the
following 2 new features:

 1) Waiter lock handoff
 2) Reader optimistic spinning

With these changes, performance on workloads with a mix of readers
and writers will improve substantially. Now rwsem will become
more balance in term of preference for readers or writers.

Because of the fact that multiple readers can share the same lock,
there is a natural preference for readers when measuring in term of
locking throughput as more readers are likely to get into the locking
fast path than the writers. For those that enter the locking slowpath,
the ratio of readers and writers processed are usually around the 1-4
range when equal number of reader and writer threads are available.
The actual raio depends on the load and can vary somewhat from run
to run.

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

Patch 9 modifies rwsem_spin_on_owner() to return a tri-state value
that can be used in later patch.

Patch 10 enables writers to optimistically spin on reader-owned lock
using a fixed iteration count.

Patch 11 removes the rwsem_wake() optimization due to its effectiveness
has been reduced recently.

Patch 12 eliminates redundant wakeup calls to the same waiter by
multiple wakers.

Patch 13 improves fairness to writers by disabling reader spinning
when writers cannot spin on readers or there is a time stamp mismatch.

Patch 14 makes recently waken-up waiting writer to set the handoff
bit and optimistically spin for the lock instead of sleeping again
and wait for wakeup.  This makes rwsem favor writer from the wakeup
perspective.

Patch 15 makes reader wakeup to wake up all the readers in the wait
queue instead of just the ones in the front. This reduces the writer
preference of the previous 2 patches.

In term of rwsem performance, a rwsem microbenchmark and fio randrw
test with a xfs filesystem on a ramdisk were used to verify the
performance changes due to these patches. Both tests were run on a
2-socket, 40-core Gold 6148 system. The rwsem microbenchmark (1:1
reader/writer ratio) has short critical section while the fio randrw
test has long critical section (4k read/write).

The following tables show the performance of a rwsem microbenchmark
running on a 2-socket 36-core 72-thread x86-64 system. The
microbenchmark had 18 writer threads and 18 reader readers running on
a patched 4.14 based kernel for 10s under different critical section
loads (# of pause instructions).

           	       Reader 		 	    Writer
  CS Load	  Locking Ops/Thread	       Locking Ops/Thread
  -------	  ------------------	       ------------------
     1	    2,079,544/2,284,896/2,457,118   713,537/914,695/1,166,480
    10	    2,239,922/3,126,189/4,076,386   249,201/415,814/  612,465
    50	    1,826,276/2,163,704/2,842,305    72,111/198,479/  359,692
   100      1,587,516/1,899,778/2,256,065    14,586/251,545/  654,608
 1us sleep      8,034/    8,267/    8,555    57,555/ 64,190/   70,046

           	     Reader 		 	  Writer
  CS Load     Slowpath Locking Ops	   Slowpath Locking Ops
  -------     --------------------	   --------------------
     1	  	  3,987,189			3,992,714
    10	  	  1,460,878			1,463,589
    50	  	    609,273			  610,224
   100	  	    202,764			  201,770
 1us sleep	    148,805			1,155,410

The first table shows the minimum, average and maximum number of
locking operations done within the 10s period per locking thread. The
second table show the total number of reader and writer locking
operations that were done in the slowpath.

Looking at the first table, it was obvious that the readers are
preferred over the writers for non-sleeping loads.  Because of the
fact that multiple readers can share the same lock, readers have much
higher chance of acquring the lock via the fastpath.  This is a natural
preference for readers when measuring in term of locking throughput.

When considering what was happening within the slowpath, the number
of reader and writer operations processed in the slowpath were about
the same.  From the slowpath's perspective, it has equal preference
for readers and writers for non-sleeping loads.  For sleeping loads,
however, writers are more preferred.

The table below compares the the mean per-threads writer locking
operations done with equal number of reader and writer threads versus
an all writers configuration.

                 All Writers	    Half Writers
  CS Load    Locking Ops/Thread  Locking Ops/Thread	% Change
  -------    ------------------  ------------------	--------
     1	  	 1,183,273	     914,695		 -22.7%
    10	  	 1,035,676	     415,814		 -59.9%
    50	           577,067	     198,479		 -65.6%
   100    	   392,179	     251,545		 -35.9%
 1us sleep	    35,823	      64,190		 +79.2%

The corresponding rwsem microbenchmark performance on an unpatched
kernel were:

           	     Reader 		      Writer
  CS Load	Locking Ops/Thread	 Locking Ops/Thread
  -------	------------------	 ------------------
     1	    	9,521/9,521/9,522	9,534/397,336/710,196
    10	    	8,045/8,046/8,046	8,047/209,955/489,798
    50	    	7,730/7,730/7,731	7,730/172,723/347,213
   100      	5,037/5,038/5,039	5,037/163,691/694,101
 1us sleep        230/  231/  232	  230/ 97,288/822,645

                 All Writers	    Half Writers
  CS Load    Locking Ops/Thread  Locking Ops/Thread	% Change
  -------    ------------------  ------------------	--------
     1	  	 1,135,832	     397,336		 -65.0%
    10	  	   989,950	     209,955		 -78.8%
    50	           593,352	     172,723		 -70.9%
   100    	   369,227	     163,691		 -55.7%
 1us sleep	    49,437	      97,288		 +96.8%

All the performance numbers were worse than the patched kernel with
the exception of 1us sleep load writer performance. That comes with
greater variances as shown by the difference between the minimum and
maximum numbers.

The corresponding all writers numbers for the patched and unpatched
kernels were 32,743/35,823/38,697 and 9,378/49,437/137,200
respectively.  The patched kernel was more fair and hence suffered
some of performance loss.

Running a 36-thread fio randrw test on a ramdisk formatted with an
xfs filesystem, the aggregated bandwidth of the patched and unpatched
kernels were 2787 MB/s and 297 MB/s respectively. This is a difference
of about 10X.

Waiman Long (15):
  locking/rwsem: relocate rwsem_down_read_failed()
  locking/rwsem: Implement a new locking scheme
  locking/rwsem: Move owner setting code from rwsem.c to rwsem-xadd.h
  locking/rwsem: Remove kernel/locking/rwsem.h
  locking/rwsem: Move rwsem internal function declarations to
    rwsem-xadd.h
  locking/rwsem: Remove arch specific rwsem files
  locking/rwsem: Implement lock handoff to prevent lock starvation
  locking/rwsem: Enable readers spinning on writer
  locking/rwsem: Make rwsem_spin_on_owner() return a tri-state value
  locking/rwsem: Enable count-based spinning on reader
  locking/rwsem: Remove rwsem_wake spinlock optimization
  locking/rwsem: Eliminate redundant writer wakeup calls
  locking/rwsem: Improve fairness to writers
  locking/rwsem: Make waiting writer to optimistically spin for the lock
  locking/rwsem: Wake up all readers in wait queue

 arch/alpha/include/asm/rwsem.h  | 210 -------------
 arch/arm/include/asm/Kbuild     |   1 -
 arch/arm64/include/asm/Kbuild   |   1 -
 arch/hexagon/include/asm/Kbuild |   1 -
 arch/ia64/include/asm/rwsem.h   | 171 -----------
 arch/powerpc/include/asm/Kbuild |   1 -
 arch/s390/include/asm/rwsem.h   | 225 --------------
 arch/sh/include/asm/Kbuild      |   1 -
 arch/sparc/include/asm/Kbuild   |   1 -
 arch/x86/include/asm/rwsem.h    | 236 ---------------
 arch/x86/lib/Makefile           |   1 -
 arch/x86/lib/rwsem.S            | 156 ----------
 arch/xtensa/include/asm/Kbuild  |   1 -
 include/asm-generic/rwsem.h     | 139 ---------
 include/linux/rwsem.h           |  19 +-
 kernel/locking/percpu-rwsem.c   |   4 +
 kernel/locking/rwsem-xadd.c     | 644 +++++++++++++++++++++++-----------------
 kernel/locking/rwsem-xadd.h     | 284 ++++++++++++++++++
 kernel/locking/rwsem.c          |  21 +-
 kernel/locking/rwsem.h          |  68 -----
 20 files changed, 674 insertions(+), 1511 deletions(-)
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

