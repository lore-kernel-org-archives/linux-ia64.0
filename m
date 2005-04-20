From: Christoph Lameter <clameter@engr.sgi.com>
Date: Wed, 20 Apr 2005 17:25:19 +0000
Subject: spin unlock using nta store
Message-Id: <Pine.LNX.4.58.0504201010480.15127@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here is a patch that uses a nontemporal store for spin unlock. A
nontemporal store will not update the LRU setting for the cacheline. The
cacheline with the lock may therefore be evicted faster from the cpu
caches. Doing so may be useful since it increases the chance that the
exclusive cache line has been evicted when another cpu is trying to
acquire the lock.

The time between dropping and reacquiring a lock on the same cpu is
typically very small so I think that the danger of the cacheline being
evicted is negligible for that case.

Here are some performance stats that show a slight improvement by 1.3%.
However this is in the range of possible fluctuationso of the test.
I would appreciate it if others could try to do their own tests with this
patch.

Two Tests were run using a page fault microbenchmark repeatedly allocating
4 GB. The numbers for allocpage, faultime and prezeropage were obtained by
putting probes recording ITC values into the page fault handler.

The first test does not do concurrent faulting and verifies that the
lock acquisition by the same cpu does not suffer. The second test does
concurrent lock acquisition for the page table lock from 8 cpus to show
the benefit from the early eviction of the cacheline.

Someday I need to run this with more cpus.

Regular 2.6.12-rc2 kernel:

Single thread:

 Gb Rep Thr CLine  User      System   Wall  flt/cpu/s fault/wsec
  4  3    1   1    0.19s     12.25s  12.04s 63156.302  63154.267

ALL
AllocPages               786996 (+ 32) 10.6s(342ns/13.5us/242.4us) 12.9gb(16.4kb/16.4kb/32.8kb)
FaultTime                786775 (+122) 11.2s(251ns/14.3us/243.7us)
PrepZeroPage             786910 (+ 25) 9.9s(516ns/12.6us/239.1us) 12.9gb(16.4kb/16.4kb/16.4kb)

8 threads:

 Gb Rep Thr CLine  User      System   Wall  flt/cpu/s fault/wsec
  4  3    8   1    0.20s     26.37s   4.07s 29589.433 164540.272

ALL
AllocPages               787092 (+ 41) 12.1s(354ns/15.4us/99.6ms) 12.9gb(16.4kb/16.4kb/32.8kb)
FaultTime                786825 (+132) 22.7s(251ns/28.8us/99.6ms)
PrepZeroPage             786984 (+ 33) 10.9s(670ns/13.8us/99.6ms) 12.9gb(16.4kb/16.4kb/16.4kb)

with this patch

single thread:

 Gb Rep Thr CLine  User      System   Wall  flt/cpu/s fault/wsec
  4  3    1   1    0.19s     12.27s  12.04s 63077.153  63076.966

ALL
AllocPages               787000 (+ 34) 10.6s(350ns/13.5us/321.10us) 12.9gb(16.4kb/16.4kb/32.8kb)
FaultTime                786775 (+123) 11.2s(249ns/14.3us/324.5us)
PrepZeroPage             786911 (+ 25) 9.9s(512ns/12.6us/320.2us) 12.9gb(16.4kb/16.4kb/16.4kb)

No effect for the single threaded case

8 threads:

 Gb Rep Thr CLine  User      System   Wall  flt/cpu/s fault/wsec
  4  3    8   1    0.18s     25.84s   4.06s 30209.925 169239.970

ALL
AllocPages               787093 (+ 39) 12.1s(350ns/15.4us/99.6ms) 12.9gb(16.4kb/16.4kb/32.8kb)
FaultTime                786823 (+133) 22.3s(255ns/28.4us/99.6ms)
PrepZeroPage             786988 (+ 29) 10.9s(751ns/13.8us/99.6ms) 12.9gb(16.4kb/16.4kb/16.4kb)
CPU0

A 1.3 % performance gain

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.11/include/asm-ia64/spinlock.h
=================================--- linux-2.6.11.orig/include/asm-ia64/spinlock.h	2005-04-06 19:13:54.000000000 -0700
+++ linux-2.6.11/include/asm-ia64/spinlock.h	2005-04-07 15:09:28.000000000 -0700
@@ -93,7 +93,15 @@ _raw_spin_lock_flags (spinlock_t *lock,
 # endif /* CONFIG_MCKINLEY */
 #endif
 }
+
 #define _raw_spin_lock(lock) _raw_spin_lock_flags(lock, 0)
+
+/* Unlock by doing an ordered store and releasing the cacheline with nta */
+static inline void _raw_spin_unlock(spinlock_t *x) {
+	barrier();
+	asm volatile ("st4.rel.nta [%0] = r0\n\t" :: "r"(x));
+}
+
 #else /* !ASM_SUPPORTED */
 #define _raw_spin_lock_flags(lock, flags) _raw_spin_lock(lock)
 # define _raw_spin_lock(x)								\
@@ -109,10 +117,10 @@ do {											\
 		} while (ia64_spinlock_val);						\
 	}										\
 } while (0)
+#define _raw_spin_unlock(x)	do { barrier(); ((spinlock_t *) x)->lock = 0; } while (0)
 #endif /* !ASM_SUPPORTED */

 #define spin_is_locked(x)	((x)->lock != 0)
-#define _raw_spin_unlock(x)	do { barrier(); ((spinlock_t *) x)->lock = 0; } while (0)
 #define _raw_spin_trylock(x)	(cmpxchg_acq(&(x)->lock, 0, 1) = 0)
 #define spin_unlock_wait(x)	do { barrier(); } while ((x)->lock)

