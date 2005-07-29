From: Ingo Molnar <mingo@elte.hu>
Date: Fri, 29 Jul 2005 07:04:48 +0000
Subject: Re: Add prefetch switch stack hook in scheduler function
Message-Id: <20050729070447.GA3032@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050728090948.GA24222@elte.hu> <200507281914.j6SJErg31398@unix-os.sc.intel.com>
In-Reply-To: <200507281914.j6SJErg31398@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: Keith Owens <kaos@ocs.com.au>, David.Mosberger@acm.org, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org


* Chen, Kenneth W <kenneth.w.chen@intel.com> wrote:

> > i.e. like the patch below. Boot-tested on x86. x86, x64 and ia64 have a 
> > real kernel_stack() implementation, the other architectures all return 
> > 'next'. (I've also cleaned up a couple of other things in the 
> > prefetch-next area, see the changelog below.)
> > 
> > Ken, would this patch generate a sufficient amount of prefetching on 
> > ia64?
> 
> Sorry, this is not enough.  Switch stack on ia64 is 528 bytes.  We 
> need to prefetch 5 lines.  It probably should use prefetch_range().  

ok, how about the additional patch below? Does this do the trick on 
ia64? It makes complete sense on every architecture to prefetch from 
below the current kernel stack, in the expectation of the next task 
touching the stack. The only difference is that for ia64 the 'expected 
minimum stack footprint' is larger, due to the switch_stack.

	Ingo

-------
enable architectures to define a 'minimum number of kernel stack
bytes touched' - which will be prefetched from the scheduler.

Signed-off-by: Ingo Molnar <mingo@elte.hu>

 include/asm-alpha/mmu_context.h     |    6 ++++++
 include/asm-arm/mmu_context.h       |    6 ++++++
 include/asm-arm26/mmu_context.h     |    6 ++++++
 include/asm-cris/mmu_context.h      |    6 ++++++
 include/asm-frv/mmu_context.h       |    6 ++++++
 include/asm-h8300/mmu_context.h     |    6 ++++++
 include/asm-i386/mmu_context.h      |    6 ++++++
 include/asm-ia64/mmu_context.h      |    6 ++++++
 include/asm-m32r/mmu_context.h      |    6 ++++++
 include/asm-m68k/mmu_context.h      |    6 ++++++
 include/asm-m68knommu/mmu_context.h |    6 ++++++
 include/asm-mips/mmu_context.h      |    6 ++++++
 include/asm-parisc/mmu_context.h    |    6 ++++++
 include/asm-ppc/mmu_context.h       |    6 ++++++
 include/asm-ppc64/mmu_context.h     |    6 ++++++
 include/asm-s390/mmu_context.h      |    6 ++++++
 include/asm-sh/mmu_context.h        |    6 ++++++
 include/asm-sh64/mmu_context.h      |    6 ++++++
 include/asm-sparc/mmu_context.h     |    6 ++++++
 include/asm-sparc64/mmu_context.h   |    6 ++++++
 include/asm-um/mmu_context.h        |    6 ++++++
 include/asm-v850/mmu_context.h      |    6 ++++++
 include/asm-x86_64/mmu_context.h    |    5 +++++
 include/asm-xtensa/mmu_context.h    |    6 ++++++
 kernel/sched.c                      |    9 ++++++++-
 25 files changed, 151 insertions(+), 1 deletion(-)

Index: linux/include/asm-alpha/mmu_context.h
=================================--- linux.orig/include/asm-alpha/mmu_context.h
+++ linux/include/asm-alpha/mmu_context.h
@@ -259,6 +259,12 @@ enter_lazy_tlb(struct mm_struct *mm, str
 #endif
 
 /*
+ * Minimum number of bytes a new task will touch on the
+ * kernel stack:
+ */
+#define MIN_KERNEL_STACK_FOOTPRINT L1_CACHE_BYTES
+
+/*
  * Returns the current bottom of a task's kernel stack. Used
  * by the scheduler to prefetch it.
  */
Index: linux/include/asm-arm/mmu_context.h
=================================--- linux.orig/include/asm-arm/mmu_context.h
+++ linux/include/asm-arm/mmu_context.h
@@ -94,6 +94,12 @@ switch_mm(struct mm_struct *prev, struct
 #define activate_mm(prev,next)	switch_mm(prev, next, NULL)
 
 /*
+ * Minimum number of bytes a new task will touch on the
+ * kernel stack:
+ */
+#define MIN_KERNEL_STACK_FOOTPRINT L1_CACHE_BYTES
+
+/*
  * Returns the current bottom of a task's kernel stack. Used
  * by the scheduler to prefetch it.
  */
Index: linux/include/asm-arm26/mmu_context.h
=================================--- linux.orig/include/asm-arm26/mmu_context.h
+++ linux/include/asm-arm26/mmu_context.h
@@ -49,6 +49,12 @@ static inline void activate_mm(struct mm
 }
 
 /*
+ * Minimum number of bytes a new task will touch on the
+ * kernel stack:
+ */
+#define MIN_KERNEL_STACK_FOOTPRINT L1_CACHE_BYTES
+
+/*
  * Returns the current bottom of a task's kernel stack. Used
  * by the scheduler to prefetch it.
  */
Index: linux/include/asm-cris/mmu_context.h
=================================--- linux.orig/include/asm-cris/mmu_context.h
+++ linux/include/asm-cris/mmu_context.h
@@ -22,6 +22,12 @@ static inline void enter_lazy_tlb(struct
 }
 
 /*
+ * Minimum number of bytes a new task will touch on the
+ * kernel stack:
+ */
+#define MIN_KERNEL_STACK_FOOTPRINT L1_CACHE_BYTES
+
+/*
  * Returns the current bottom of a task's kernel stack. Used
  * by the scheduler to prefetch it.
  */
Index: linux/include/asm-frv/mmu_context.h
=================================--- linux.orig/include/asm-frv/mmu_context.h
+++ linux/include/asm-frv/mmu_context.h
@@ -48,6 +48,12 @@ do {						\
 } while(0)
 
 /*
+ * Minimum number of bytes a new task will touch on the
+ * kernel stack:
+ */
+#define MIN_KERNEL_STACK_FOOTPRINT L1_CACHE_BYTES
+
+/*
  * Returns the current bottom of a task's kernel stack. Used
  * by the scheduler to prefetch it.
  */
Index: linux/include/asm-h8300/mmu_context.h
=================================--- linux.orig/include/asm-h8300/mmu_context.h
+++ linux/include/asm-h8300/mmu_context.h
@@ -30,6 +30,12 @@ extern inline void activate_mm(struct mm
 }
 
 /*
+ * Minimum number of bytes a new task will touch on the
+ * kernel stack:
+ */
+#define MIN_KERNEL_STACK_FOOTPRINT L1_CACHE_BYTES
+
+/*
  * Returns the current bottom of a task's kernel stack. Used
  * by the scheduler to prefetch it.
  */
Index: linux/include/asm-i386/mmu_context.h
=================================--- linux.orig/include/asm-i386/mmu_context.h
+++ linux/include/asm-i386/mmu_context.h
@@ -69,6 +69,12 @@ static inline void switch_mm(struct mm_s
 #define activate_mm(prev, next) \
 	switch_mm((prev),(next),NULL)
 
+/*
+ * Minimum number of bytes a new task will touch on the
+ * kernel stack:
+ */
+#define MIN_KERNEL_STACK_FOOTPRINT L1_CACHE_BYTES
+
 static inline void * kernel_stack(struct task_struct *task)
 {
 	return (void *) task->thread.esp;
Index: linux/include/asm-ia64/mmu_context.h
=================================--- linux.orig/include/asm-ia64/mmu_context.h
+++ linux/include/asm-ia64/mmu_context.h
@@ -170,6 +170,12 @@ activate_mm (struct mm_struct *prev, str
 #define switch_mm(prev_mm,next_mm,next_task)	activate_mm(prev_mm, next_mm)
 
 /*
+ * Minimum number of bytes a new task will touch on the
+ * kernel stack:
+ */
+#define MIN_KERNEL_STACK_FOOTPRINT IA64_SWITCH_STACK_SIZE
+
+/*
  * Returns the current bottom of a task's kernel stack. Used
  * by the scheduler to prefetch it.
  */
Index: linux/include/asm-m32r/mmu_context.h
=================================--- linux.orig/include/asm-m32r/mmu_context.h
+++ linux/include/asm-m32r/mmu_context.h
@@ -168,6 +168,12 @@ static inline void switch_mm(struct mm_s
 #endif /* __KERNEL__ */
 
 /*
+ * Minimum number of bytes a new task will touch on the
+ * kernel stack:
+ */
+#define MIN_KERNEL_STACK_FOOTPRINT L1_CACHE_BYTES
+
+/*
  * Returns the current bottom of a task's kernel stack. Used
  * by the scheduler to prefetch it.
  */
Index: linux/include/asm-m68k/mmu_context.h
=================================--- linux.orig/include/asm-m68k/mmu_context.h
+++ linux/include/asm-m68k/mmu_context.h
@@ -151,6 +151,12 @@ static inline void activate_mm(struct mm
 }
 
 /*
+ * Minimum number of bytes a new task will touch on the
+ * kernel stack:
+ */
+#define MIN_KERNEL_STACK_FOOTPRINT L1_CACHE_BYTES
+
+/*
  * Returns the current bottom of a task's kernel stack. Used
  * by the scheduler to prefetch it.
  */
Index: linux/include/asm-m68knommu/mmu_context.h
=================================--- linux.orig/include/asm-m68knommu/mmu_context.h
+++ linux/include/asm-m68knommu/mmu_context.h
@@ -31,6 +31,12 @@ extern inline void activate_mm(struct mm
 }
 
 /*
+ * Minimum number of bytes a new task will touch on the
+ * kernel stack:
+ */
+#define MIN_KERNEL_STACK_FOOTPRINT L1_CACHE_BYTES
+
+/*
  * Returns the current bottom of a task's kernel stack. Used
  * by the scheduler to prefetch it.
  */
Index: linux/include/asm-mips/mmu_context.h
=================================--- linux.orig/include/asm-mips/mmu_context.h
+++ linux/include/asm-mips/mmu_context.h
@@ -194,6 +194,12 @@ drop_mmu_context(struct mm_struct *mm, u
 }
 
 /*
+ * Minimum number of bytes a new task will touch on the
+ * kernel stack:
+ */
+#define MIN_KERNEL_STACK_FOOTPRINT L1_CACHE_BYTES
+
+/*
  * Returns the current bottom of a task's kernel stack. Used
  * by the scheduler to prefetch it.
  */
Index: linux/include/asm-parisc/mmu_context.h
=================================--- linux.orig/include/asm-parisc/mmu_context.h
+++ linux/include/asm-parisc/mmu_context.h
@@ -72,6 +72,12 @@ static inline void activate_mm(struct mm
 }
 
 /*
+ * Minimum number of bytes a new task will touch on the
+ * kernel stack:
+ */
+#define MIN_KERNEL_STACK_FOOTPRINT L1_CACHE_BYTES
+
+/*
  * Returns the current bottom of a task's kernel stack. Used
  * by the scheduler to prefetch it.
  */
Index: linux/include/asm-ppc/mmu_context.h
=================================--- linux.orig/include/asm-ppc/mmu_context.h
+++ linux/include/asm-ppc/mmu_context.h
@@ -196,6 +196,12 @@ static inline void switch_mm(struct mm_s
 extern void mmu_context_init(void);
 
 /*
+ * Minimum number of bytes a new task will touch on the
+ * kernel stack:
+ */
+#define MIN_KERNEL_STACK_FOOTPRINT L1_CACHE_BYTES
+
+/*
  * Returns the current bottom of a task's kernel stack. Used
  * by the scheduler to prefetch it.
  */
Index: linux/include/asm-ppc64/mmu_context.h
=================================--- linux.orig/include/asm-ppc64/mmu_context.h
+++ linux/include/asm-ppc64/mmu_context.h
@@ -85,6 +85,12 @@ static inline void activate_mm(struct mm
 }
 
 /*
+ * Minimum number of bytes a new task will touch on the
+ * kernel stack:
+ */
+#define MIN_KERNEL_STACK_FOOTPRINT L1_CACHE_BYTES
+
+/*
  * Returns the current bottom of a task's kernel stack. Used
  * by the scheduler to prefetch it.
  */
Index: linux/include/asm-s390/mmu_context.h
=================================--- linux.orig/include/asm-s390/mmu_context.h
+++ linux/include/asm-s390/mmu_context.h
@@ -52,6 +52,12 @@ extern inline void activate_mm(struct mm
 }
 
 /*
+ * Minimum number of bytes a new task will touch on the
+ * kernel stack:
+ */
+#define MIN_KERNEL_STACK_FOOTPRINT L1_CACHE_BYTES
+
+/*
  * Returns the current bottom of a task's kernel stack. Used
  * by the scheduler to prefetch it.
  */
Index: linux/include/asm-sh/mmu_context.h
=================================--- linux.orig/include/asm-sh/mmu_context.h
+++ linux/include/asm-sh/mmu_context.h
@@ -203,6 +203,12 @@ static inline void disable_mmu(void)
 #endif
 
 /*
+ * Minimum number of bytes a new task will touch on the
+ * kernel stack:
+ */
+#define MIN_KERNEL_STACK_FOOTPRINT L1_CACHE_BYTES
+
+/*
  * Returns the current bottom of a task's kernel stack. Used
  * by the scheduler to prefetch it.
  */
Index: linux/include/asm-sh64/mmu_context.h
=================================--- linux.orig/include/asm-sh64/mmu_context.h
+++ linux/include/asm-sh64/mmu_context.h
@@ -207,6 +207,12 @@ enter_lazy_tlb(struct mm_struct *mm, str
 #endif	/* __ASSEMBLY__ */
 
 /*
+ * Minimum number of bytes a new task will touch on the
+ * kernel stack:
+ */
+#define MIN_KERNEL_STACK_FOOTPRINT L1_CACHE_BYTES
+
+/*
  * Returns the current bottom of a task's kernel stack. Used
  * by the scheduler to prefetch it.
  */
Index: linux/include/asm-sparc/mmu_context.h
=================================--- linux.orig/include/asm-sparc/mmu_context.h
+++ linux/include/asm-sparc/mmu_context.h
@@ -38,6 +38,12 @@ BTFIXUPDEF_CALL(void, switch_mm, struct 
 #endif /* !(__ASSEMBLY__) */
 
 /*
+ * Minimum number of bytes a new task will touch on the
+ * kernel stack:
+ */
+#define MIN_KERNEL_STACK_FOOTPRINT L1_CACHE_BYTES
+
+/*
  * Returns the current bottom of a task's kernel stack. Used
  * by the scheduler to prefetch it.
  */
Index: linux/include/asm-sparc64/mmu_context.h
=================================--- linux.orig/include/asm-sparc64/mmu_context.h
+++ linux/include/asm-sparc64/mmu_context.h
@@ -143,6 +143,12 @@ static inline void activate_mm(struct mm
 #endif /* !(__ASSEMBLY__) */
 
 /*
+ * Minimum number of bytes a new task will touch on the
+ * kernel stack:
+ */
+#define MIN_KERNEL_STACK_FOOTPRINT L1_CACHE_BYTES
+
+/*
  * Returns the current bottom of a task's kernel stack. Used
  * by the scheduler to prefetch it.
  */
Index: linux/include/asm-um/mmu_context.h
=================================--- linux.orig/include/asm-um/mmu_context.h
+++ linux/include/asm-um/mmu_context.h
@@ -67,6 +67,12 @@ static inline void destroy_context(struc
 }
 
 /*
+ * Minimum number of bytes a new task will touch on the
+ * kernel stack:
+ */
+#define MIN_KERNEL_STACK_FOOTPRINT L1_CACHE_BYTES
+
+/*
  * Returns the current bottom of a task's kernel stack. Used
  * by the scheduler to prefetch it.
  */
Index: linux/include/asm-v850/mmu_context.h
=================================--- linux.orig/include/asm-v850/mmu_context.h
+++ linux/include/asm-v850/mmu_context.h
@@ -9,6 +9,12 @@
 #define enter_lazy_tlb(mm,tsk)		((void)0)
 
 /*
+ * Minimum number of bytes a new task will touch on the
+ * kernel stack:
+ */
+#define MIN_KERNEL_STACK_FOOTPRINT L1_CACHE_BYTES
+
+/*
  * Returns the current bottom of a task's kernel stack. Used
  * by the scheduler to prefetch it.
  */
Index: linux/include/asm-x86_64/mmu_context.h
=================================--- linux.orig/include/asm-x86_64/mmu_context.h
+++ linux/include/asm-x86_64/mmu_context.h
@@ -75,6 +75,11 @@ static inline void switch_mm(struct mm_s
 #define activate_mm(prev, next) \
 	switch_mm((prev),(next),NULL)
 
+/*
+ * Minimum number of bytes a new task will touch on the
+ * kernel stack:
+ */
+#define MIN_KERNEL_STACK_FOOTPRINT L1_CACHE_BYTES
 
 /*
  * Returns the current bottom of a task's kernel stack. Used
Index: linux/include/asm-xtensa/mmu_context.h
=================================--- linux.orig/include/asm-xtensa/mmu_context.h
+++ linux/include/asm-xtensa/mmu_context.h
@@ -328,6 +328,12 @@ static inline void enter_lazy_tlb(struct
 }
 
 /*
+ * Minimum number of bytes a new task will touch on the
+ * kernel stack:
+ */
+#define MIN_KERNEL_STACK_FOOTPRINT L1_CACHE_BYTES
+
+/*
  * Returns the current bottom of a task's kernel stack. Used
  * by the scheduler to prefetch it.
  */
Index: linux/kernel/sched.c
=================================--- linux.orig/kernel/sched.c
+++ linux/kernel/sched.c
@@ -2869,7 +2869,14 @@ go_idle:
 	 * its thread_info, its kernel stack and mm:
 	 */
 	prefetch(next->thread_info);
-	prefetch(kernel_stack(next));
+	/*
+	 * Prefetch (at least) a cacheline below the current
+	 * kernel stack (in expectation of any new task touching
+	 * the stack at least minimally), and a cacheline above
+	 * the stack:
+	 */
+	prefetch_range(kernel_stack(next) - MIN_KERNEL_STACK_FOOTPRINT,
+		       MIN_KERNEL_STACK_FOOTPRINT + L1_CACHE_BYTES);
 	prefetch(next->mm);
 
 	if (!rt_task(next) && next->activated > 0) {
