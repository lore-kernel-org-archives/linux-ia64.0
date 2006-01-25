From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 25 Jan 2006 02:33:59 +0000
Subject: Optimize task_thread_info()
Message-Id: <200601250234.k0P2Y0g18230@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Kernel scheduler uses thread_info.cpu heavily, task_cpu(p) is use just
about in every hot scheduler functions.  Since thread_info structure
always has constant offset from task_struct, access to member variable
of thread_info can be as simple as adding a constant to task_struct
pointer.  Optimize ia64 task_thread_info() to use constant offset. This
saves a memory indirection whenever thread_info structure is used.

Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>


--- linux-2.6.15/include/asm-ia64/thread_info.h.orig	2006-01-24 17:59:45.909971596 -0800
+++ linux-2.6.15/include/asm-ia64/thread_info.h	2006-01-24 18:31:05.396276697 -0800
@@ -57,9 +57,11 @@ struct thread_info {
 /* how to get the thread information struct from C */
 #define current_thread_info()	((struct thread_info *) ((char *) current + IA64_TASK_SIZE))
 #define alloc_thread_info(tsk)	((struct thread_info *) ((char *) (tsk) + IA64_TASK_SIZE))
+#define task_thread_info(p)	((struct thread_info *) ((char *) (p) + IA64_TASK_SIZE))
 #else
 #define current_thread_info()	((struct thread_info *) 0)
 #define alloc_thread_info(tsk)	((struct thread_info *) 0)
+#define task_thread_info(p)	((struct thread_info *) 0)
 #endif
 #define free_thread_info(ti)	/* nothing */
 
@@ -67,6 +69,18 @@ struct thread_info {
 #define alloc_task_struct()	((task_t *)__get_free_pages(GFP_KERNEL, KERNEL_STACK_SIZE_ORDER))
 #define free_task_struct(tsk)	free_pages((unsigned long) (tsk), KERNEL_STACK_SIZE_ORDER)
 
+#define __HAVE_THREAD_FUNCTIONS
+static inline void setup_thread_stack(struct task_struct *p, struct task_struct *org)
+{
+        *task_thread_info(p) = *task_thread_info(org);
+        task_thread_info(p)->task = p;
+}
+
+static inline unsigned long *end_of_stack(struct task_struct *p)
+{
+	return (unsigned long *) (task_thread_info(p) + 1);
+}
+
 #endif /* !__ASSEMBLY */
 
 /*


