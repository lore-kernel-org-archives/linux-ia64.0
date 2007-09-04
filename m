From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Date: Tue, 04 Sep 2007 20:03:56 +0000
Subject: [PATCH] local_t protection (critical section)
Message-Id: <20070904200356.GC8157@Krystal>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070827202203.GB5653@Krystal> <Pine.LNX.4.64.0708271324001.5884@schroedinger.engr.sgi.com> <20070827203913.GA7416@Krystal> <Pine.LNX.4.64.0708271401070.6435@schroedinger.engr.sgi.com> <20070827211003.GA10627@Krystal> <Pine.LNX.4.64.0708271421130.6566@schroedinger.engr.sgi.com> <20070827213845.GB9748@Krystal> <Pine.LNX.4.64.0708271510020.8783@schroedinger.engr.sgi.com> <20070827222715.GA16982@Krystal> <Pine.LNX.4.64.0708271811200.10344@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0708271811200.10344@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: Peter Zijlstra <peterz@infradead.org>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, mingo@redhat.com, linux-ia64@vger.kernel.org

local_t protection (critical section)

Adds local_enter(flags) and local_exit(flags) as primitives to surround critical
sections using local_t types.

On architectures providing fast atomic primitives, this turns into a preempt
disable/enable().
However, on architectures not providing such fast primitives, such as ia64, it
turns into a local irq disable/enable so that we can use *_local primitives that
are non atomic.

This is only the primary work here: made for testing ia64 with cmpxchg_local
(other local_* primitives still use atomic_long_t operations as fallback).

Signed-off-by: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Christoph Lameter <clameter@sgi.com>
---
 include/asm-generic/local.h   |    3 +++
 include/asm-i386/local.h      |    3 +++
 include/asm-ia64/intrinsics.h |   14 ++++++++++++--
 3 files changed, 18 insertions(+), 2 deletions(-)

Index: linux-2.6-lttng/include/asm-generic/local.h
=================================--- linux-2.6-lttng.orig/include/asm-generic/local.h	2007-09-04 15:32:02.000000000 -0400
+++ linux-2.6-lttng/include/asm-generic/local.h	2007-09-04 15:36:41.000000000 -0400
@@ -46,6 +46,9 @@ typedef struct
 #define local_add_unless(l, a, u) atomic_long_add_unless((&(l)->a), (a), (u))
 #define local_inc_not_zero(l) atomic_long_inc_not_zero(&(l)->a)
 
+#define local_enter(flags) local_irq_save(flags)
+#define local_exit(flags) local_irq_restore(flags)
+
 /* Non-atomic variants, ie. preemption disabled and won't be touched
  * in interrupt, etc.  Some archs can optimize this case well. */
 #define __local_inc(l)		local_set((l), local_read(l) + 1)
Index: linux-2.6-lttng/include/asm-i386/local.h
=================================--- linux-2.6-lttng.orig/include/asm-i386/local.h	2007-09-04 15:28:52.000000000 -0400
+++ linux-2.6-lttng/include/asm-i386/local.h	2007-09-04 15:31:54.000000000 -0400
@@ -194,6 +194,9 @@ static __inline__ long local_sub_return(
 })
 #define local_inc_not_zero(l) local_add_unless((l), 1, 0)
 
+#define local_enter(flags) preempt_disable()
+#define local_exit(flags) preempt_enable()
+
 /* On x86, these are no better than the atomic variants. */
 #define __local_inc(l)		local_inc(l)
 #define __local_dec(l)		local_dec(l)
Index: linux-2.6-lttng/include/asm-ia64/intrinsics.h
=================================--- linux-2.6-lttng.orig/include/asm-ia64/intrinsics.h	2007-09-04 15:47:24.000000000 -0400
+++ linux-2.6-lttng/include/asm-ia64/intrinsics.h	2007-09-04 15:49:41.000000000 -0400
@@ -160,8 +160,18 @@ extern long ia64_cmpxchg_called_with_bad
 #define cmpxchg(ptr,o,n)	cmpxchg_acq(ptr,o,n)
 #define cmpxchg64(ptr,o,n)	cmpxchg_acq(ptr,o,n)
 
-#define cmpxchg_local		cmpxchg
-#define cmpxchg64_local		cmpxchg64
+/* Must be executed between local_enter/local_exit. */
+static inline void *cmpxchg_local(void **p, void *old, void *new)
+{
+	unsigned long flags;
+	void *before;
+
+	before = *p;
+	if (likely(before = old))
+		*p = new;
+	return before;
+}
+#define cmpxchg64_local		cmpxchg_local
 
 #ifdef CONFIG_IA64_DEBUG_CMPXCHG
 # define CMPXCHG_BUGCHECK_DECL	int _cmpxchg_bugcheck_count = 128;
-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68
