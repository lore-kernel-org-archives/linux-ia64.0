From: Jiri Slaby <jslaby@suse.cz>
Date: Thu, 31 Mar 2016 07:55:54 +0000
Subject: [PATCH v2 3/4] exit_thread: accept a task parameter to be exited
Message-Id: <1459410955-5422-3-git-send-email-jslaby@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1459410955-5422-1-git-send-email-jslaby@suse.cz>
In-Reply-To: <1459410955-5422-1-git-send-email-jslaby@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

We need to call exit_thread from copy_process in a fail path.  So make
it accept task_struct as a parameter.

[v2]
* s390: exit_thread_runtime_instr doesn't make sense to be called for
  non-current tasks.
* arm: fix the comment in vfp_thread_copy
* change 'me' to 'tsk' for task_struct
* now we can change only archs that actually have exit_thread

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: Russell King <linux@arm.linux.org.uk>
Cc: Haavard Skinnemoen <hskinnemoen@gmail.com>
Cc: Hans-Christian Egtvedt <egtvedt@samfundet.no>
Cc: Mikael Starvik <starvik@axis.com>
Cc: Jesper Nilsson <jesper.nilsson@axis.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: James Hogan <james.hogan@imgtec.com>
Cc: David Howells <dhowells@redhat.com>
Cc: Koichi Yasutake <yasutake.koichi@jp.panasonic.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
Cc: Rich Felker <dalias@libc.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Chris Metcalf <cmetcalf@mellanox.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org
Cc: Chris Zankel <chris@zankel.net>
Cc: Max Filippov <jcmvbkbc@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-cris-kernel@axis.com
Cc: linux-ia64@vger.kernel.org
Cc: linux-metag@vger.kernel.org
Cc: linux-am33-list@redhat.com
Cc: linux-s390@vger.kernel.org
Cc: linux-sh@vger.kernel.org
Cc: sparclinux@vger.kernel.org
Cc: linux-xtensa@linux-xtensa.org
---
 arch/arm/kernel/process.c           |  4 ++--
 arch/arm/vfp/vfpmodule.c            |  4 ----
 arch/avr32/kernel/process.c         |  4 ++--
 arch/cris/arch-v32/kernel/process.c |  4 ++--
 arch/ia64/kernel/perfmon.c          |  4 ++--
 arch/ia64/kernel/process.c          | 14 +++++++-------
 arch/metag/kernel/process.c         |  6 +++---
 arch/mn10300/kernel/process.c       |  4 ++--
 arch/s390/kernel/process.c          |  5 +++--
 arch/sh/kernel/process_64.c         |  4 ++--
 arch/sparc/kernel/process_32.c      | 12 ++++++------
 arch/sparc/kernel/process_64.c      |  4 ++--
 arch/tile/kernel/process.c          |  4 ++--
 arch/x86/kernel/process.c           |  5 ++---
 arch/xtensa/kernel/process.c        |  4 ++--
 include/linux/sched.h               |  4 ++--
 kernel/exit.c                       |  2 +-
 17 files changed, 42 insertions(+), 46 deletions(-)

diff --git a/arch/arm/kernel/process.c b/arch/arm/kernel/process.c
index 4adfb46e3ee9..a647d6642f3e 100644
--- a/arch/arm/kernel/process.c
+++ b/arch/arm/kernel/process.c
@@ -193,9 +193,9 @@ EXPORT_SYMBOL_GPL(thread_notify_head);
 /*
  * Free current thread data structures etc..
  */
-void exit_thread(void)
+void exit_thread(struct task_struct *tsk)
 {
-	thread_notify(THREAD_NOTIFY_EXIT, current_thread_info());
+	thread_notify(THREAD_NOTIFY_EXIT, task_thread_info(tsk));
 }
 
 void flush_thread(void)
diff --git a/arch/arm/vfp/vfpmodule.c b/arch/arm/vfp/vfpmodule.c
index 2a61e4b04600..73085d3482ed 100644
--- a/arch/arm/vfp/vfpmodule.c
+++ b/arch/arm/vfp/vfpmodule.c
@@ -156,10 +156,6 @@ static void vfp_thread_copy(struct thread_info *thread)
  *   - we could be preempted if tree preempt rcu is enabled, so
  *	it is unsafe to use thread->cpu.
  *  THREAD_NOTIFY_EXIT
- *   - the thread (v) will be running on the local CPU, so
- *	v == current_thread_info()
- *   - thread->cpu is the local CPU number at the time it is accessed,
- *	but may change at any time.
  *   - we could be preempted if tree preempt rcu is enabled, so
  *	it is unsafe to use thread->cpu.
  */
diff --git a/arch/avr32/kernel/process.c b/arch/avr32/kernel/process.c
index 42a53e740a7e..68e5b9dac059 100644
--- a/arch/avr32/kernel/process.c
+++ b/arch/avr32/kernel/process.c
@@ -62,9 +62,9 @@ void machine_restart(char *cmd)
 /*
  * Free current thread data structures etc
  */
-void exit_thread(void)
+void exit_thread(struct task_struct *tsk)
 {
-	ocd_disable(current);
+	ocd_disable(tsk);
 }
 
 void flush_thread(void)
diff --git a/arch/cris/arch-v32/kernel/process.c b/arch/cris/arch-v32/kernel/process.c
index c7ce784a393c..4d1afa9f9fd3 100644
--- a/arch/cris/arch-v32/kernel/process.c
+++ b/arch/cris/arch-v32/kernel/process.c
@@ -33,9 +33,9 @@ void default_idle(void)
  */
 
 extern void deconfigure_bp(long pid);
-void exit_thread(void)
+void exit_thread(struct task_struct *tsk)
 {
-	deconfigure_bp(current->pid);
+	deconfigure_bp(tsk->pid);
 }
 
 /*
diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index 9cd607b06964..2436ad5f92c1 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -4542,8 +4542,8 @@ pfm_context_unload(pfm_context_t *ctx, void *arg, int count, struct pt_regs *reg
 
 
 /*
- * called only from exit_thread(): task = current
- * we come here only if current has a context attached (loaded or masked)
+ * called only from exit_thread()
+ * we come here only if the task has a context attached (loaded or masked)
  */
 void
 pfm_exit_thread(struct task_struct *task)
diff --git a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
index b51514957620..aae6c4dc7ae7 100644
--- a/arch/ia64/kernel/process.c
+++ b/arch/ia64/kernel/process.c
@@ -570,22 +570,22 @@ flush_thread (void)
 }
 
 /*
- * Clean up state associated with current thread.  This is called when
+ * Clean up state associated with a thread.  This is called when
  * the thread calls exit().
  */
 void
-exit_thread (void)
+exit_thread (struct task_struct *tsk)
 {
 
-	ia64_drop_fpu(current);
+	ia64_drop_fpu(tsk);
 #ifdef CONFIG_PERFMON
        /* if needed, stop monitoring and flush state to perfmon context */
-	if (current->thread.pfm_context)
-		pfm_exit_thread(current);
+	if (tsk->thread.pfm_context)
+		pfm_exit_thread(tsk);
 
 	/* free debug register resources */
-	if (current->thread.flags & IA64_THREAD_DBG_VALID)
-		pfm_release_debug_registers(current);
+	if (tsk->thread.flags & IA64_THREAD_DBG_VALID)
+		pfm_release_debug_registers(tsk);
 #endif
 }
 
diff --git a/arch/metag/kernel/process.c b/arch/metag/kernel/process.c
index 7f546183a0f0..35062796edf2 100644
--- a/arch/metag/kernel/process.c
+++ b/arch/metag/kernel/process.c
@@ -345,10 +345,10 @@ void flush_thread(void)
 /*
  * Free current thread data structures etc.
  */
-void exit_thread(void)
+void exit_thread(struct task_struct *tsk)
 {
-	clear_fpu(&current->thread);
-	clear_dsp(&current->thread);
+	clear_fpu(&tsk->thread);
+	clear_dsp(&tsk->thread);
 }
 
 /* TODO: figure out how to unwind the kernel stack here to figure out
diff --git a/arch/mn10300/kernel/process.c b/arch/mn10300/kernel/process.c
index 74a96ccf7451..cbede4e88dee 100644
--- a/arch/mn10300/kernel/process.c
+++ b/arch/mn10300/kernel/process.c
@@ -103,9 +103,9 @@ void show_regs(struct pt_regs *regs)
 /*
  * free current thread data structures etc..
  */
-void exit_thread(void)
+void exit_thread(struct task_struct *tsk)
 {
-	exit_fpu(current);
+	exit_fpu(tsk);
 }
 
 void flush_thread(void)
diff --git a/arch/s390/kernel/process.c b/arch/s390/kernel/process.c
index 2bba7df4ac51..f8e79824e284 100644
--- a/arch/s390/kernel/process.c
+++ b/arch/s390/kernel/process.c
@@ -70,9 +70,10 @@ extern void kernel_thread_starter(void);
 /*
  * Free current thread data structures etc..
  */
-void exit_thread(void)
+void exit_thread(struct task_struct *tsk)
 {
-	exit_thread_runtime_instr();
+	if (tsk = current)
+		exit_thread_runtime_instr();
 }
 
 void flush_thread(void)
diff --git a/arch/sh/kernel/process_64.c b/arch/sh/kernel/process_64.c
index e2062e643341..bfd3855fe120 100644
--- a/arch/sh/kernel/process_64.c
+++ b/arch/sh/kernel/process_64.c
@@ -288,7 +288,7 @@ void show_regs(struct pt_regs *regs)
 /*
  * Free current thread data structures etc..
  */
-void exit_thread(void)
+void exit_thread(struct task_struct *tsk)
 {
 	/*
 	 * See arch/sparc/kernel/process.c for the precedent for doing
@@ -307,7 +307,7 @@ void exit_thread(void)
 	 * which it would get safely nulled.
 	 */
 #ifdef CONFIG_SH_FPU
-	if (last_task_used_math = current) {
+	if (last_task_used_math = tsk) {
 		last_task_used_math = NULL;
 	}
 #endif
diff --git a/arch/sparc/kernel/process_32.c b/arch/sparc/kernel/process_32.c
index c5113c7ce2fd..b7780a5bef11 100644
--- a/arch/sparc/kernel/process_32.c
+++ b/arch/sparc/kernel/process_32.c
@@ -184,21 +184,21 @@ unsigned long thread_saved_pc(struct task_struct *tsk)
 /*
  * Free current thread data structures etc..
  */
-void exit_thread(void)
+void exit_thread(struct task_struct *tsk)
 {
 #ifndef CONFIG_SMP
-	if(last_task_used_math = current) {
+	if (last_task_used_math = tsk) {
 #else
-	if (test_thread_flag(TIF_USEDFPU)) {
+	if (test_ti_thread_flag(task_thread_info(tsk), TIF_USEDFPU)) {
 #endif
 		/* Keep process from leaving FPU in a bogon state. */
 		put_psr(get_psr() | PSR_EF);
-		fpsave(&current->thread.float_regs[0], &current->thread.fsr,
-		       &current->thread.fpqueue[0], &current->thread.fpqdepth);
+		fpsave(&tsk->thread.float_regs[0], &tsk->thread.fsr,
+		       &tsk->thread.fpqueue[0], &tsk->thread.fpqdepth);
 #ifndef CONFIG_SMP
 		last_task_used_math = NULL;
 #else
-		clear_thread_flag(TIF_USEDFPU);
+		clear_ti_thread_flag(task_thread_info(tsk), TIF_USEDFPU);
 #endif
 	}
 }
diff --git a/arch/sparc/kernel/process_64.c b/arch/sparc/kernel/process_64.c
index c16ef1af1843..fa14402b33f9 100644
--- a/arch/sparc/kernel/process_64.c
+++ b/arch/sparc/kernel/process_64.c
@@ -417,9 +417,9 @@ unsigned long thread_saved_pc(struct task_struct *tsk)
 }
 
 /* Free current thread data structures etc.. */
-void exit_thread(void)
+void exit_thread(struct task_struct *tsk)
 {
-	struct thread_info *t = current_thread_info();
+	struct thread_info *t = task_thread_info(tsk);
 
 	if (t->utraps) {
 		if (t->utraps[0] < 2)
diff --git a/arch/tile/kernel/process.c b/arch/tile/kernel/process.c
index b5f30d376ce1..6b705ccc9cc1 100644
--- a/arch/tile/kernel/process.c
+++ b/arch/tile/kernel/process.c
@@ -541,7 +541,7 @@ void flush_thread(void)
 /*
  * Free current thread data structures etc..
  */
-void exit_thread(void)
+void exit_thread(struct task_struct *tsk)
 {
 #ifdef CONFIG_HARDWALL
 	/*
@@ -550,7 +550,7 @@ void exit_thread(void)
 	 * the last reference to a hardwall fd, it would already have
 	 * been released and deactivated at this point.)
 	 */
-	hardwall_deactivate_all(current);
+	hardwall_deactivate_all(tsk);
 #endif
 }
 
diff --git a/arch/x86/kernel/process.c b/arch/x86/kernel/process.c
index 2915d54e9dd5..96becbbb52e0 100644
--- a/arch/x86/kernel/process.c
+++ b/arch/x86/kernel/process.c
@@ -97,10 +97,9 @@ int arch_dup_task_struct(struct task_struct *dst, struct task_struct *src)
 /*
  * Free current thread data structures etc..
  */
-void exit_thread(void)
+void exit_thread(struct task_struct *tsk)
 {
-	struct task_struct *me = current;
-	struct thread_struct *t = &me->thread;
+	struct thread_struct *t = &tsk->thread;
 	unsigned long *bp = t->io_bitmap_ptr;
 	struct fpu *fpu = &t->fpu;
 
diff --git a/arch/xtensa/kernel/process.c b/arch/xtensa/kernel/process.c
index 5bbfed81c97b..e0ded48561db 100644
--- a/arch/xtensa/kernel/process.c
+++ b/arch/xtensa/kernel/process.c
@@ -115,10 +115,10 @@ void arch_cpu_idle(void)
 /*
  * This is called when the thread calls exit().
  */
-void exit_thread(void)
+void exit_thread(struct task_struct *tsk)
 {
 #if XTENSA_HAVE_COPROCESSORS
-	coprocessor_release_all(current_thread_info());
+	coprocessor_release_all(task_thread_info(tsk));
 #endif
 }
 
diff --git a/include/linux/sched.h b/include/linux/sched.h
index de5370802828..14a2f21ed75a 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2648,9 +2648,9 @@ static inline int copy_thread_tls(
 extern void flush_thread(void);
 
 #ifdef CONFIG_HAVE_EXIT_THREAD
-extern void exit_thread(void);
+extern void exit_thread(struct task_struct *tsk);
 #else
-static inline void exit_thread(void)
+static inline void exit_thread(struct task_struct *tsk)
 {
 }
 #endif
diff --git a/kernel/exit.c b/kernel/exit.c
index fd90195667e1..75b34fe835b2 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -746,7 +746,7 @@ void do_exit(long code)
 		disassociate_ctty(1);
 	exit_task_namespaces(tsk);
 	exit_task_work(tsk);
-	exit_thread();
+	exit_thread(tsk);
 
 	/*
 	 * Flush inherited counters to the parent - before the parent
-- 
2.7.4

