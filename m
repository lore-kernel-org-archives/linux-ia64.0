From: Ingo Molnar <mingo@elte.hu>
Date: Fri, 29 Jul 2005 08:28:26 +0000
Subject: Re: Add prefetch switch stack hook in scheduler function
Message-Id: <20050729082826.GA6144@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050729070447.GA3032@elte.hu> <200507290722.j6T7Mig07477@unix-os.sc.intel.com>
In-Reply-To: <200507290722.j6T7Mig07477@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: Keith Owens <kaos@ocs.com.au>, David.Mosberger@acm.org, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org


* Chen, Kenneth W <kenneth.w.chen@intel.com> wrote:

> On ia64, we have two kernel stacks, one for outgoing task, and one for 
> incoming task.  for outgoing task, we haven't called switch_to() yet. 
> So the switch stack structure for 'current' will be allocated 
> immediately below current 'sp' pointer. For the incoming task, it was 
> fully ctx'ed out previously, so switch stack structure is immediate 
> above kernel_stack(next). It Would be beneficial to prefetch both 
> stacks.

ok, could you apply the two patches below? The first one implements 
prefetchw_range(), the second one makes use of it to prefetch the 
outgoing stack for writes. We can actually do the current task 
prefetching much earlier, because unlike the next task, we know its 
stack pointer right away, so this patch could have some additional 
benefits.

btw., i'm not totally convinced this is needed, because even in a 
context-switch-intense workload (as DB workloads are), i'd expect the 
outgoing task to still have a hot switch-stack, either due to having 
context-switched recently, or due to having done some deeper kernel 
function call recently. The next task will likely be cache-cold, but the 
current task is usually cache-hot. Maybe not cache-hot to a depth of 528 
bytes, but it needs to be measured: it would be nice to benchmark the 
effects of this particular patch in isolation as well, so that we know 
the breakdown.

	Ingo

----
introduce prefetchw_range(addr, len).

Signed-off-by: Ingo Molnar <mingo@elte.hu>

 include/linux/prefetch.h |   39 +++++++++++++++++++++++++++++++++++++++
 1 files changed, 39 insertions(+)

Index: linux-prefetch-task/include/linux/prefetch.h
=================================--- linux-prefetch-task.orig/include/linux/prefetch.h
+++ linux-prefetch-task/include/linux/prefetch.h
@@ -93,4 +93,43 @@ static inline void prefetch_range(void *
 #endif
 }
 
+static inline void prefetchw_range(void *addr, size_t len)
+{
+#ifdef ARCH_HAS_PREFETCH
+	char *cp = addr;
+	char *end = addr + len;
+
+	/*
+	 * Unroll agressively:
+	 */
+	if (len <= PREFETCH_STRIDE)
+		prefetchw(cp);
+	else if (len <= 2*PREFETCH_STRIDE) {
+		prefetchw(cp);
+		prefetchw(cp + PREFETCH_STRIDE);
+	}
+	else if (len <= 3*PREFETCH_STRIDE) {
+		prefetchw(cp);
+		prefetchw(cp + PREFETCH_STRIDE);
+		prefetchw(cp + 2*PREFETCH_STRIDE);
+	}
+	else if (len <= 4*PREFETCH_STRIDE) {
+		prefetchw(cp);
+		prefetchw(cp + PREFETCH_STRIDE);
+		prefetchw(cp + 2*PREFETCH_STRIDE);
+		prefetchw(cp + 3*PREFETCH_STRIDE);
+	}
+	else if (len <= 5*PREFETCH_STRIDE) {
+		prefetchw(cp);
+		prefetchw(cp + PREFETCH_STRIDE);
+		prefetchw(cp + 2*PREFETCH_STRIDE);
+		prefetchw(cp + 3*PREFETCH_STRIDE);
+		prefetchw(cp + 4*PREFETCH_STRIDE);
+	} else
+		for (; cp < end; cp += PREFETCH_STRIDE)
+			prefetchw(cp);
+#endif
+}
+
+
 #endif

-----

prefetch the current kernel stack for writing.

Signed-off-by: Ingo Molnar <mingo@elte.hu>

 kernel/sched.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

Index: linux-prefetch-task/kernel/sched.c
=================================--- linux-prefetch-task.orig/kernel/sched.c
+++ linux-prefetch-task/kernel/sched.c
@@ -2754,6 +2754,12 @@ asmlinkage void __sched schedule(void)
 	int cpu, idx, new_prio;
 
 	/*
+	 * Prefetch the current stack for writing (we use switch_count's
+	 * address to get to the stack pointer):
+	 */
+	prefetchw_range((void *)&switch_count - MIN_KERNEL_STACK_FOOTPRINT,
+		       MIN_KERNEL_STACK_FOOTPRINT + L1_CACHE_BYTES);
+	/*
 	 * Test if we are atomic.  Since do_exit() needs to call into
 	 * schedule() atomically, we ignore that path for now.
 	 * Otherwise, whine if we are scheduling when we should not be.
@@ -2872,10 +2878,10 @@ go_idle:
 	/*
 	 * Prefetch (at least) a cacheline below the current
 	 * kernel stack (in expectation of any new task touching
-	 * the stack at least minimally), and a cacheline above
-	 * the stack:
+	 * the stack at least minimally), and at least a cacheline
+	 * above the stack:
 	 */
-	prefetch_range(kernel_stack(next) - MIN_KERNEL_STACK_FOOTPRINT,
+	prefetch_range(kernel_stack(next) - L1_CACHE_BYTES,
 		       MIN_KERNEL_STACK_FOOTPRINT + L1_CACHE_BYTES);
 	prefetch(next->mm);
 
