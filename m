From: Christoph Lameter <clameter@sgi.com>
Date: Tue, 22 Feb 2005 23:31:20 +0000
Subject: NUMA aware spinlocks
Message-Id: <Pine.LNX.4.58.0502221518270.29685@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I found an article on HBO locks at
http://www.it.uu.se/research/group/uart/publications/radovic_2003_feb

For these locks the numa id is stored in the lock instead of a 1. This
allows the task acquiring the lock to see which node holds the lock.
Then it is possible to do a numa aware backoff: If we are on the same
node we have  small retry cycles if we are on a remote node we wait
longer. This should reduce the contention via the NUMAlink.

HBO locks also try to avoid multiple tasks attempting to acquire off
node locks by storing the lock address locally and then spining if another
task attempts to acquire the same off node lock.

The tests that I have done show 40-50% improvement for 32 CPUs and
somewhat less improvement for 16 threads.
However, the patch is not yet sufficiently optimized. Thus the
performance in general is reduced. I am not sure that this is worth
pursuing. It certainly would improve the high contention cases but
these may be rare.

2.6.10-rc2-bk12:
 Gb Rep Threads   User      System     Wall flt/cpu/s fault/wsec
  1  10    1    0.107s      6.444s   6.055s100028.084 100006.622
  1  10    2    0.121s      9.048s   4.082s 71468.414 135904.412
  1  10    4    0.129s     10.185s   3.011s 63531.985 210146.600
  1  10    8    0.232s     26.476s   4.018s 24537.050 156718.301
  1  10   16    1.402s     71.620s   5.088s  8974.768 111436.635
  1  10   32    6.312s    274.848s  10.053s  2330.904  62183.378
  1  10   58   12.961s    653.238s  13.042s   983.728  48812.035
 Gb Rep Threads   User      System     Wall flt/cpu/s fault/wsec
  4  10    1    0.519s     40.553s  41.007s 63823.516  63813.514
  4  10    2    0.454s     33.343s  17.096s 77562.289 145917.159
  4  10    4    0.465s     41.730s  12.058s 62124.864 208372.119
  4  10    8    0.632s    108.604s  16.088s 23997.651 155297.118
  4  10   16    0.962s    326.489s  23.074s  8005.563 110416.502
  4  10   32    8.197s   1133.558s  40.036s  2295.973  64946.127
  4  10   58   26.833s   3001.826s  57.084s   865.545  45316.260

2.6.11-rc4-bk5 with hbo spinlock patch:
 Gb Rep Thr CLine  User      System   Wall  flt/cpu/s fault/wsec
  1  3    1   1    0.04s      1.96s   2.00s 98160.195  98126.347
  1  3    2   1    0.03s      2.51s   1.03s 76930.301 144277.192
  1  3    4   1    0.04s      3.77s   1.01s 51582.503 174739.420
  1  3    8   1    0.04s      7.48s   1.01s 26142.904 167696.120
  1  3   16   1    0.10s     16.03s   1.04s 12180.198 138266.715
  1  3   32   1    1.26s     50.50s   2.01s  3797.180  89925.762
  1  3   60   1    3.70s    133.81s   3.01s  1429.602  61935.525
 Gb Rep Thr CLine  User      System   Wall  flt/cpu/s fault/wsec
  4  3    1   1    0.16s      7.88s   8.00s 97660.212  97631.616
  4  3    2   1    0.17s     10.60s   5.07s 72924.572 135828.507
  4  3    4   1    0.15s     15.46s   4.04s 50325.335 175242.666
  4  3    8   1    0.26s     31.49s   4.07s 24762.645 167098.092
  4  3   16   1    0.23s     76.05s   5.07s 10309.368 137585.847
  4  3   32   1    1.35s    227.34s   8.04s  3438.672  93218.225
  4  3   60   1    3.72s    708.38s  13.06s  1104.377  57502.822

Patch against 2.6.11-rc4-bk5:

Index: linux-2.6.10/include/asm-ia64/spinlock.h
=================================--- linux-2.6.10.orig/include/asm-ia64/spinlock.h	2005-02-17 18:47:00.000000000 -0800
+++ linux-2.6.10/include/asm-ia64/spinlock.h	2005-02-22 10:31:22.000000000 -0800
@@ -11,7 +11,7 @@

 #include <linux/compiler.h>
 #include <linux/kernel.h>
-
+#include <linux/config.h>
 #include <asm/atomic.h>
 #include <asm/bitops.h>
 #include <asm/intrinsics.h>
@@ -24,10 +24,13 @@ typedef struct {
 #endif
 } spinlock_t;

+/* These definitions do not mean much. Lots of code for IA64 depends on
+ * zeroed memory containing unlocked spinlocks
+ */
 #define SPIN_LOCK_UNLOCKED			(spinlock_t) { 0 }
 #define spin_lock_init(x)			((x)->lock = 0)

-#ifdef ASM_SUPPORTED
+#if defined(ASM_SUPPORTED) & !defined(CONFIG_HBO_LOCKS)
 /*
  * Try to get the lock.  If we fail to get the lock, make a non-standard call to
  * ia64_spinlock_contention().  We do not use a normal call because that would force all
@@ -94,7 +97,31 @@ _raw_spin_lock_flags (spinlock_t *lock,
 #endif
 }
 #define _raw_spin_lock(lock) _raw_spin_lock_flags(lock, 0)
+#error CRAP CRAP
 #else /* !ASM_SUPPORTED */
+
+#ifdef CONFIG_HBO_LOCKS
+
+void hbo_spinlock_contention(__u32 *, unsigned long, unsigned long);
+void hbo_spinlock_wait_remote(__u32 *, unsigned long);
+
+#define _raw_spin_lock_flags(__x, __flags)						\
+do {											\
+	__u32 *ia64_spinlock_ptr = (__u32 *) (__x);					\
+	__u64 ia64_spinlock_val;							\
+							\
+	if (unlikely(system_state = SYSTEM_RUNNING && local_node_data->remote_lock_addr = ia64_spinlock_ptr))		\
+		hbo_spinlock_wait_remote(ia64_spinlock_ptr, __flags);			\
+							\
+	ia64_spinlock_val = ia64_cmpxchg4_acq(ia64_spinlock_ptr, numa_node_id()+ 1, 0);	\
+							\
+	if (unlikely(ia64_spinlock_val))						\
+		hbo_spinlock_contention(ia64_spinlock_ptr, ia64_spinlock_val, __flags);	\
+} while (0)
+
+#define _raw_spin_lock(lock) _raw_spin_lock_flags(lock, 0)
+
+#else
 #define _raw_spin_lock_flags(lock, flags) _raw_spin_lock(lock)
 # define _raw_spin_lock(x)								\
 do {											\
@@ -109,11 +136,16 @@ do {											\
 		} while (ia64_spinlock_val);						\
 	}										\
 } while (0)
+#endif
 #endif /* !ASM_SUPPORTED */

 #define spin_is_locked(x)	((x)->lock != 0)
 #define _raw_spin_unlock(x)	do { barrier(); ((spinlock_t *) x)->lock = 0; } while (0)
+#ifdef CONFIG_HBO_LOCKS
+#define _raw_spin_trylock(x)	(cmpxchg_acq(&(x)->lock, 0, numa_node_id() + 1) = 0)
+#else
 #define _raw_spin_trylock(x)	(cmpxchg_acq(&(x)->lock, 0, 1) = 0)
+#endif
 #define spin_unlock_wait(x)	do { barrier(); } while ((x)->lock)

 typedef struct {
Index: linux-2.6.10/arch/ia64/Kconfig
=================================--- linux-2.6.10.orig/arch/ia64/Kconfig	2005-02-17 18:46:27.000000000 -0800
+++ linux-2.6.10/arch/ia64/Kconfig	2005-02-18 18:38:59.000000000 -0800
@@ -272,6 +272,18 @@ config PREEMPT
           Say Y here if you are building a kernel for a desktop, embedded
           or real-time system.  Say N if you are unsure.

+config HBO_LOCKS
+	bool "HBO Locks"
+	help
+	depends on (SMP && NUMA)
+	default y
+	help
+	  HBO locks reduces contention for spinlocks by saving the node id when the
+	  lock is taken. The cpu waiting on the spinlock can then select an appropriate
+	  backoff algorithm depending on the distance to the node. This also insures that
+	  it is highly likely that another cpu on the same node gets to a spinlock before
+	  remote nodes to avoid too much cacheline bouncing.
+
 config HAVE_DEC_LOCK
 	bool
 	depends on (SMP || PREEMPT)
Index: linux-2.6.10/arch/ia64/mm/numa.c
=================================--- linux-2.6.10.orig/arch/ia64/mm/numa.c	2005-02-17 18:46:28.000000000 -0800
+++ linux-2.6.10/arch/ia64/mm/numa.c	2005-02-22 10:33:10.000000000 -0800
@@ -47,3 +47,81 @@ paddr_to_nid(unsigned long paddr)

 	return (i < num_node_memblks) ? node_memblk[i].nid : (num_node_memblks ? -1 : 0);
 }
+
+#ifdef CONFIG_HBO_LOCKS
+
+static inline void maybe_enable_irq(unsigned long flags)
+{
+	if (flags & IA64_PSR_I_BIT)
+	 	local_irq_enable();
+}
+
+static inline void maybe_disable_irq(unsigned long flags)
+{
+	if (flags & IA64_PSR_I_BIT)
+		local_irq_disable();
+}
+
+void hbo_spinlock_contention(__u32 *lock, unsigned long lockval, unsigned long flags)
+{
+	int node = numa_node_id()+ 1;
+
+	do {
+		int backoff = 100;
+		int cap = 2500;
+		int remote = 0;
+
+		maybe_enable_irq(flags);
+
+		if (lockval != node) {
+			/* remote backoff */
+			backoff = 200;
+			cap = 20000;
+			/*
+			 * Make sure that no other cpu of this node tries
+			 * to acquire the same remote lock.
+			 */
+			if (system_state = SYSTEM_RUNNING) {
+				local_node_data->remote_lock_addr = lock;
+				remote = 1;
+			}
+		}
+
+		do {
+			int i;
+
+			for(i = 0; i < backoff; i++)
+				cpu_relax();
+
+			/* Increase backoff for next cycle */
+			backoff = min(backoff << 1, cap);
+
+			ia64_barrier();
+
+			/* No cmpxchg so that we will not get an exclusive cache line */
+			lockval = *lock;
+
+		} while (lockval);
+
+		maybe_disable_irq(flags);
+
+		/* Lock was unlocked. Now use cmpxchg acquiring an exclusive cache line */
+		lockval = ia64_cmpxchg4_acq(lock, node, 0);
+
+		/* Release eventually spinning other cpus on this node since either the lock has been
+		 * acquired by this cpu or the node holding the lock may have changed.
+		 */
+		if (remote)
+			local_node_data->remote_lock_addr = NULL;
+
+        } while (lockval);
+}
+
+void hbo_spinlock_wait_remote(__u32 *lock, unsigned long flags)
+{
+	maybe_enable_irq(flags);
+	while (local_node_data->remote_lock_addr = lock)
+		cpu_relax();
+	maybe_disable_irq(flags);
+}
+#endif
Index: linux-2.6.10/include/asm-ia64/nodedata.h
=================================--- linux-2.6.10.orig/include/asm-ia64/nodedata.h	2005-02-17 18:47:00.000000000 -0800
+++ linux-2.6.10/include/asm-ia64/nodedata.h	2005-02-18 18:49:48.000000000 -0800
@@ -27,6 +27,7 @@ struct pglist_data;
 struct ia64_node_data {
 	short			active_cpu_count;
 	short			node;
+	__u32 			*remote_lock_addr;	/* active off node spinlock */
 	struct pglist_data	*pg_data_ptrs[MAX_NUMNODES];
 };

Index: linux-2.6.10/Makefile
=================================--- linux-2.6.10.orig/Makefile	2005-02-17 18:47:21.000000000 -0800
+++ linux-2.6.10/Makefile	2005-02-22 11:24:51.000000000 -0800
@@ -1,7 +1,7 @@
 VERSION = 2
 PATCHLEVEL = 6
 SUBLEVEL = 11
-EXTRAVERSION = -rc4-bk5
+EXTRAVERSION = -rc4-bk5-hbo
 NAME=Woozy Numbat

 # *DOCUMENTATION*
