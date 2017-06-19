From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Mon, 19 Jun 2017 18:02:00 +0000
Subject: [PATCH 0/7] rwsem: Implement down_read_killable()
Message-Id: <149789463636.9059.16943955939303454611.stgit@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, avagin@virtuozzo.com, peterz@infradead.org, heiko.carstens@de.ibm.com, hpa@zytor.com, gorcunov@virtuozzo.com, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org, mingo@redhat.com, mattst88@gmail.com, fenghua.yu@intel.com, arnd@arndb.de, ktkhai@virtuozzo.com, ink@jurassic.park.msu.ru, tglx@linutronix.de, rth@twiddle.net, tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, schwidefsky@de.ibm.com, davem@davemloft.net

This series implements killable version of down_read()
similar to already existing down_write_killable() function.
Patches [1-2/7] add arch-independent low-level primitives
for the both rwsem types.

Patches [3-6/7] add arch-dependent primitives for
the architectures, that use rwsem-xadd implementation.
The assembly code was modified in x86 case only, the rest
of architectures does not need such change.

I tested the series in x86 (which uses RWSEM_XCHGADD_ALGORITHM
config option), and also the RWSEM_GENERIC_SPINLOCK case,
which were manually written in Kconfig. alpha, ia64 and s390
are compile-tested only, but I believe, their changes are
pretty easy. Please, people, who work with them, take your
look at the corresponding patches.

***

Where this came from. Cycle of creation/destroying net
namespace is slow at the moment as it's made under net_mutex.
During cleanup_net(), the mutex is held the whole time,
while RCU is synchronizing. This takes a lot of time,
especially when RCU is preemptible, and at this time
the creation of new net namespaces is blocked. But
this moment may be optimized by using small locks
in pernet callbacks, where they are need, and by
converting net_mutex into rw semaphore. In cleanup_net()
it's only need to prevent from registration/unregistration
of pernet_subsys and pernet_devices, which actions
can't be missed by unhashed dead net namespace.
down_read guarantees that, and it's lite-weight.

Using the rwsem improves the create/destroy cycle performance
on my development kernel much:

$time for i in {1..10000}; do unshare -n -- bash -c exit; done

MUTEX:
real 1m13,372s
user 0m9,278s
sys 0m17.181s

RWSEM:
real 0m17,482s
user 0m3,791s
sys 0m13,723s

Of course, it's just an example, and it's a generic use
function. It may be used in other places.

---

Kirill Tkhai (7):
      rwsem-spinlock: Add killable versions of __down_read()
      rwsem-spinlock: Add killable versions of rwsem_down_read_failed()
      alpha: Add __down_read_killable()
      ia64: Add __down_read_killable()
      s390: Add __down_read_killable()
      x86: Add __down_read_killable()
      rwsem: Add down_read_killable()


 arch/alpha/include/asm/rwsem.h  |   18 ++++++++++++++++--
 arch/ia64/include/asm/rwsem.h   |   22 +++++++++++++++++++---
 arch/s390/include/asm/rwsem.h   |   18 ++++++++++++++++--
 arch/x86/include/asm/rwsem.h    |   37 +++++++++++++++++++++++++++----------
 arch/x86/lib/rwsem.S            |   12 ++++++++++++
 include/asm-generic/rwsem.h     |    8 ++++++++
 include/linux/rwsem-spinlock.h  |    1 +
 include/linux/rwsem.h           |    2 ++
 kernel/locking/rwsem-spinlock.c |   37 ++++++++++++++++++++++++++++---------
 kernel/locking/rwsem-xadd.c     |   33 ++++++++++++++++++++++++++++++---
 kernel/locking/rwsem.c          |   16 ++++++++++++++++
 11 files changed, 175 insertions(+), 29 deletions(-)

--
Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
