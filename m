From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Wed, 08 Jun 2005 09:15:33 +0000
Subject: Fix floating-point preemption problem
Message-Id: <200506080915.j589FXFm013110@mail08.syd.optusnet.com.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


There've been reports of problems with CONFIG_PREEMPT=y and the high
floating point partition.  This is caused by the possibility of
preemption and rescheduling on a different processor while saving or
restioirng the high partition.

	The only places where the FPU state is touched are in ptrace,  
in switch_to(), and where handling a floating-point exception. In
switch_to() preemption is off.  So it's only in trap.c and ptrace.c
that we need to prevent preemption.

Here is a patch that adds commentary to make the conditions clear, and
adds appropriate preempt_{en,dis}able() calls to make it so.
In trap.c I use preempt_enable_no_resched(), as we're about to return
to user space where the preemption flag will be checked anyway.

Signed-off-by: Peter Chubb <peterc@gelato.unsw.edu.au>

 arch/ia64/kernel/ptrace.c    |    6 ++++++
 arch/ia64/kernel/traps.c     |   11 ++++++++++-
 include/asm-ia64/processor.h |   10 ++++++++--
 3 files changed, 24 insertions(+), 3 deletions(-)

Index: linux-2.6-import/arch/ia64/kernel/ptrace.c
=================================- --- linux-2.6-import.orig/arch/ia64/kernel/ptrace.c	2005-06-08 10:40:41.857862761 +1000
+++ linux-2.6-import/arch/ia64/kernel/ptrace.c	2005-06-08 10:40:46.902740583 +1000
@@ -635,11 +635,17 @@
 {
 	struct ia64_psr *psr = ia64_psr(ia64_task_regs(task));
 
+	/*
+	 * Prevent migrating this task while
+	 * we're fiddling with the FPU state
+	 */
+	preempt_disable();
 	if (ia64_is_local_fpu_owner(task) && psr->mfh) {
 		psr->mfh = 0;
 		task->thread.flags |= IA64_THREAD_FPH_VALID;
 		ia64_save_fpu(&task->thread.fph[0]);
 	}
+	preempt_enable();
 }
 
 /*
Index: linux-2.6-import/arch/ia64/kernel/traps.c
=================================- --- linux-2.6-import.orig/arch/ia64/kernel/traps.c	2005-06-08 10:40:41.859815869 +1000
+++ linux-2.6-import/arch/ia64/kernel/traps.c	2005-06-08 10:40:46.903717137 +1000
@@ -202,13 +202,21 @@
 
 	/* first, grant user-level access to fph partition: */
 	psr->dfh = 0;
+
+	/*
+	 * Make sure that no other task gets in on this processor
+	 * while we're claiming the FPU
+	 */
+	preempt_disable();
 #ifndef CONFIG_SMP
 	{
 		struct task_struct *fpu_owner
 			= (struct task_struct *)ia64_get_kr(IA64_KR_FPU_OWNER);
 
- -		if (ia64_is_local_fpu_owner(current))
+		if (ia64_is_local_fpu_owner(current)) {
+			preempt_enable_no_resched();
 			return;
+		}
 
 		if (fpu_owner)
 			ia64_flush_fph(fpu_owner);
@@ -226,6 +234,7 @@
 		 */
 		psr->mfh = 1;
 	}
+	preempt_enable_no_resched();
 }
 
 static inline int
Index: linux-2.6-import/include/asm-ia64/processor.h
=================================- --- linux-2.6-import.orig/include/asm-ia64/processor.h	2005-06-08 10:40:41.861768977 +1000
+++ linux-2.6-import/include/asm-ia64/processor.h	2005-06-08 10:42:19.836500389 +1000
@@ -403,7 +403,10 @@
  * task_struct at this point.
  */
 
- -/* Return TRUE if task T owns the fph partition of the CPU we're running on. */
+/*
+ * Return TRUE if task T owns the fph partition of the CPU we're running on.
+ * Must be called from code that has preemption disabled.
+ */
 #define ia64_is_local_fpu_owner(t)								\
 ({												\
 	struct task_struct *__ia64_islfo_task = (t);						\
@@ -411,7 +414,10 @@
 	 && __ia64_islfo_task = (struct task_struct *) ia64_get_kr(IA64_KR_FPU_OWNER));	\
 })
 
- -/* Mark task T as owning the fph partition of the CPU we're running on. */
+/*
+ * Mark task T as owning the fph partition of the CPU we're running on.
+ * Must be called from code that has preemption disabled.
+ */
 #define ia64_set_local_fpu_owner(t) do {						\
 	struct task_struct *__ia64_slfo_task = (t);					\
 	__ia64_slfo_task->thread.last_fph_cpu = smp_processor_id();			\


---End encapsulation

