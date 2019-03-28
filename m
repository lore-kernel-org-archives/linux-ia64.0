From: Steven Rostedt <rostedt@goodmis.org>
Date: Thu, 28 Mar 2019 23:05:15 +0000
Subject: [RFC][PATCH 3/4 v2] syscalls: Remove start and number from syscall_get_arguments() args
Message-Id: <20190329032253.266535547@goodmis.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190328230512.486297455@goodmis.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Roland McGrath <roland@hack.frob.com>, Oleg Nesterov <oleg@redhat.com>, linux-arch@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, "Gustavo A. R. Silva" <gustavo@embeddedor.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Dominik Brodowski <linux@dominikbrodowski.net>, Andy Lutomirski <luto@kernel.org>, Kees Cook <keescook@chromium.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Dave Martin <dave.martin@arm.com>, "Dmitry V. Levin" <ldv@altlinux.org>, linux-snps-arc@lists.infradead.org, linux-arm-k

From: "Steven Rostedt (Red Hat)" <rostedt@goodmis.org>

At Linux Plumbers, Andy Lutomirski approached me and pointed out that the
function call syscall_get_arguments() implemented in x86 was horribly
written and not optimized for the standard case of passing in 0 and 6 for
the starting index and the number of system calls to get. When looking at
all the users of this function, I discovered that all instances pass in only
0 and 6 for these arguments. Instead of having this function handle
different cases that are never used, simply rewrite it to return the first 6
arguments of a system call.

This should help out the performance of tracing system calls by ptrace,
ftrace and perf.

Link: http://lkml.kernel.org/r/20161107213233.754809394@goodmis.org

Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Kees Cook <keescook@chromium.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Dominik Brodowski <linux@dominikbrodowski.net>
Cc: Dave Martin <dave.martin@arm.com>
Cc: "Dmitry V. Levin" <ldv@altlinux.org>
Cc: x86@kernel.org
Cc: linux-snps-arc@lists.infradead.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-c6x-dev@linux-c6x.org
Cc: uclinux-h8-devel@lists.sourceforge.jp
Cc: linux-hexagon@vger.kernel.org
Cc: linux-ia64@vger.kernel.org
Cc: linux-mips@vger.kernel.org
Cc: nios2-dev@lists.rocketboards.org
Cc: openrisc@lists.librecores.org
Cc: linux-parisc@vger.kernel.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-riscv@lists.infradead.org
Cc: linux-s390@vger.kernel.org
Cc: linux-sh@vger.kernel.org
Cc: sparclinux@vger.kernel.org
Cc: linux-um@lists.infradead.org
Cc: linux-xtensa@linux-xtensa.org
Cc: linux-arch@vger.kernel.org
Reported-by: Andy Lutomirski <luto@amacapital.net>
Signed-off-by: Steven Rostedt (VMware) <rostedt@goodmis.org>
---
 arch/arc/include/asm/syscall.h        |  7 ++-
 arch/arm/include/asm/syscall.h        | 23 ++-------
 arch/arm64/include/asm/syscall.h      | 22 ++------
 arch/c6x/include/asm/syscall.h        | 41 +++------------
 arch/csky/include/asm/syscall.h       | 13 ++---
 arch/h8300/include/asm/syscall.h      | 34 +++----------
 arch/hexagon/include/asm/syscall.h    |  4 +-
 arch/ia64/include/asm/syscall.h       |  5 +-
 arch/microblaze/include/asm/syscall.h |  4 +-
 arch/mips/include/asm/syscall.h       |  3 +-
 arch/mips/kernel/ptrace.c             |  2 +-
 arch/nds32/include/asm/syscall.h      | 33 +++---------
 arch/nios2/include/asm/syscall.h      | 42 +++------------
 arch/openrisc/include/asm/syscall.h   |  6 +--
 arch/parisc/include/asm/syscall.h     | 30 +++--------
 arch/powerpc/include/asm/syscall.h    |  8 ++-
 arch/riscv/include/asm/syscall.h      | 12 ++---
 arch/s390/include/asm/syscall.h       | 17 ++-----
 arch/sh/include/asm/syscall_32.h      | 26 +++-------
 arch/sh/include/asm/syscall_64.h      |  4 +-
 arch/sparc/include/asm/syscall.h      |  4 +-
 arch/um/include/asm/syscall-generic.h | 39 +++-----------
 arch/x86/include/asm/syscall.h        | 73 +++++++--------------------
 arch/xtensa/include/asm/syscall.h     | 16 ++----
 include/asm-generic/syscall.h         | 11 ++--
 include/trace/events/syscalls.h       |  2 +-
 kernel/seccomp.c                      |  2 +-
 kernel/trace/trace_syscalls.c         |  4 +-
 lib/syscall.c                         |  2 +-
 29 files changed, 113 insertions(+), 376 deletions(-)

diff --git a/arch/arc/include/asm/syscall.h b/arch/arc/include/asm/syscall.h
index 29de09804306..c7a4201ed62b 100644
--- a/arch/arc/include/asm/syscall.h
+++ b/arch/arc/include/asm/syscall.h
@@ -55,12 +55,11 @@ syscall_set_return_value(struct task_struct *task, struct pt_regs *regs,
  */
 static inline void
 syscall_get_arguments(struct task_struct *task, struct pt_regs *regs,
-		      unsigned int i, unsigned int n, unsigned long *args)
+		      unsigned long *args)
 {
 	unsigned long *inside_ptregs = &(regs->r0);
-	inside_ptregs -= i;
-
-	BUG_ON((i + n) > 6);
+	unsigned int n = 6;
+	unsigned int i = 0;
 
 	while (n--) {
 		args[i++] = (*inside_ptregs);
diff --git a/arch/arm/include/asm/syscall.h b/arch/arm/include/asm/syscall.h
index 06dea6bce293..db969a2972ae 100644
--- a/arch/arm/include/asm/syscall.h
+++ b/arch/arm/include/asm/syscall.h
@@ -55,29 +55,12 @@ static inline void syscall_set_return_value(struct task_struct *task,
 
 static inline void syscall_get_arguments(struct task_struct *task,
 					 struct pt_regs *regs,
-					 unsigned int i, unsigned int n,
 					 unsigned long *args)
 {
-	if (n = 0)
-		return;
-
-	if (i + n > SYSCALL_MAX_ARGS) {
-		unsigned long *args_bad = args + SYSCALL_MAX_ARGS - i;
-		unsigned int n_bad = n + i - SYSCALL_MAX_ARGS;
-		pr_warn("%s called with max args %d, handling only %d\n",
-			__func__, i + n, SYSCALL_MAX_ARGS);
-		memset(args_bad, 0, n_bad * sizeof(args[0]));
-		n = SYSCALL_MAX_ARGS - i;
-	}
-
-	if (i = 0) {
-		args[0] = regs->ARM_ORIG_r0;
-		args++;
-		i++;
-		n--;
-	}
+	args[0] = regs->ARM_ORIG_r0;
+	args++;
 
-	memcpy(args, &regs->ARM_r0 + i, n * sizeof(args[0]));
+	memcpy(args, &regs->ARM_r0 + 1, 5 * sizeof(args[0]));
 }
 
 static inline void syscall_set_arguments(struct task_struct *task,
diff --git a/arch/arm64/include/asm/syscall.h b/arch/arm64/include/asm/syscall.h
index ad8be16a39c9..55b2dab21023 100644
--- a/arch/arm64/include/asm/syscall.h
+++ b/arch/arm64/include/asm/syscall.h
@@ -65,28 +65,12 @@ static inline void syscall_set_return_value(struct task_struct *task,
 
 static inline void syscall_get_arguments(struct task_struct *task,
 					 struct pt_regs *regs,
-					 unsigned int i, unsigned int n,
 					 unsigned long *args)
 {
-	if (n = 0)
-		return;
-
-	if (i + n > SYSCALL_MAX_ARGS) {
-		unsigned long *args_bad = args + SYSCALL_MAX_ARGS - i;
-		unsigned int n_bad = n + i - SYSCALL_MAX_ARGS;
-		pr_warning("%s called with max args %d, handling only %d\n",
-			   __func__, i + n, SYSCALL_MAX_ARGS);
-		memset(args_bad, 0, n_bad * sizeof(args[0]));
-	}
-
-	if (i = 0) {
-		args[0] = regs->orig_x0;
-		args++;
-		i++;
-		n--;
-	}
+	args[0] = regs->orig_x0;
+	args++;
 
-	memcpy(args, &regs->regs[i], n * sizeof(args[0]));
+	memcpy(args, &regs->regs[1], 5 * sizeof(args[0]));
 }
 
 static inline void syscall_set_arguments(struct task_struct *task,
diff --git a/arch/c6x/include/asm/syscall.h b/arch/c6x/include/asm/syscall.h
index ae2be315ee9c..06db3251926b 100644
--- a/arch/c6x/include/asm/syscall.h
+++ b/arch/c6x/include/asm/syscall.h
@@ -46,40 +46,15 @@ static inline void syscall_set_return_value(struct task_struct *task,
 }
 
 static inline void syscall_get_arguments(struct task_struct *task,
-					 struct pt_regs *regs, unsigned int i,
-					 unsigned int n, unsigned long *args)
+					 struct pt_regs *regs,
+					 unsigned long *args)
 {
-	switch (i) {
-	case 0:
-		if (!n--)
-			break;
-		*args++ = regs->a4;
-	case 1:
-		if (!n--)
-			break;
-		*args++ = regs->b4;
-	case 2:
-		if (!n--)
-			break;
-		*args++ = regs->a6;
-	case 3:
-		if (!n--)
-			break;
-		*args++ = regs->b6;
-	case 4:
-		if (!n--)
-			break;
-		*args++ = regs->a8;
-	case 5:
-		if (!n--)
-			break;
-		*args++ = regs->b8;
-	case 6:
-		if (!n--)
-			break;
-	default:
-		BUG();
-	}
+	*args++ = regs->a4;
+	*args++ = regs->b4;
+	*args++ = regs->a6;
+	*args++ = regs->b6;
+	*args++ = regs->a8;
+	*args   = regs->b8;
 }
 
 static inline void syscall_set_arguments(struct task_struct *task,
diff --git a/arch/csky/include/asm/syscall.h b/arch/csky/include/asm/syscall.h
index d637445737b7..5cc0b8283a69 100644
--- a/arch/csky/include/asm/syscall.h
+++ b/arch/csky/include/asm/syscall.h
@@ -43,16 +43,11 @@ syscall_set_return_value(struct task_struct *task, struct pt_regs *regs,
 
 static inline void
 syscall_get_arguments(struct task_struct *task, struct pt_regs *regs,
-		      unsigned int i, unsigned int n, unsigned long *args)
+		      unsigned long *args)
 {
-	BUG_ON(i + n > 6);
-	if (i = 0) {
-		args[0] = regs->orig_a0;
-		args++;
-		i++;
-		n--;
-	}
-	memcpy(args, &regs->a1 + i * sizeof(regs->a1), n * sizeof(args[0]));
+	args[0] = regs->orig_a0;
+	args++;
+	memcpy(args, &regs->a1 + sizeof(regs->a1), 5 * sizeof(args[0]));
 }
 
 static inline void
diff --git a/arch/h8300/include/asm/syscall.h b/arch/h8300/include/asm/syscall.h
index 924990401237..ddd483c6ca95 100644
--- a/arch/h8300/include/asm/syscall.h
+++ b/arch/h8300/include/asm/syscall.h
@@ -17,34 +17,14 @@ syscall_get_nr(struct task_struct *task, struct pt_regs *regs)
 
 static inline void
 syscall_get_arguments(struct task_struct *task, struct pt_regs *regs,
-		      unsigned int i, unsigned int n, unsigned long *args)
+		      unsigned long *args)
 {
-	BUG_ON(i + n > 6);
-
-	while (n > 0) {
-		switch (i) {
-		case 0:
-			*args++ = regs->er1;
-			break;
-		case 1:
-			*args++ = regs->er2;
-			break;
-		case 2:
-			*args++ = regs->er3;
-			break;
-		case 3:
-			*args++ = regs->er4;
-			break;
-		case 4:
-			*args++ = regs->er5;
-			break;
-		case 5:
-			*args++ = regs->er6;
-			break;
-		}
-		i++;
-		n--;
-	}
+	*args++ = regs->er1;
+	*args++ = regs->er2;
+	*args++ = regs->er3;
+	*args++ = regs->er4;
+	*args++ = regs->er5;
+	*args   = regs->er6;
 }
 
 
diff --git a/arch/hexagon/include/asm/syscall.h b/arch/hexagon/include/asm/syscall.h
index 4af9c7b6f13a..ae3a1e24fabd 100644
--- a/arch/hexagon/include/asm/syscall.h
+++ b/arch/hexagon/include/asm/syscall.h
@@ -37,10 +37,8 @@ static inline long syscall_get_nr(struct task_struct *task,
 
 static inline void syscall_get_arguments(struct task_struct *task,
 					 struct pt_regs *regs,
-					 unsigned int i, unsigned int n,
 					 unsigned long *args)
 {
-	BUG_ON(i + n > 6);
-	memcpy(args, &(&regs->r00)[i], n * sizeof(args[0]));
+	memcpy(args, &(&regs->r00)[0], 6 * sizeof(args[0]));
 }
 #endif
diff --git a/arch/ia64/include/asm/syscall.h b/arch/ia64/include/asm/syscall.h
index 1d0b875fec44..8204c1ff70ce 100644
--- a/arch/ia64/include/asm/syscall.h
+++ b/arch/ia64/include/asm/syscall.h
@@ -63,12 +63,9 @@ extern void ia64_syscall_get_set_arguments(struct task_struct *task,
 	unsigned long *args, int rw);
 static inline void syscall_get_arguments(struct task_struct *task,
 					 struct pt_regs *regs,
-					 unsigned int i, unsigned int n,
 					 unsigned long *args)
 {
-	BUG_ON(i + n > 6);
-
-	ia64_syscall_get_set_arguments(task, regs, i, n, args, 0);
+	ia64_syscall_get_set_arguments(task, regs, 0, 6, args, 0);
 }
 
 static inline void syscall_set_arguments(struct task_struct *task,
diff --git a/arch/microblaze/include/asm/syscall.h b/arch/microblaze/include/asm/syscall.h
index 220decd605a4..4b23e44e5c3c 100644
--- a/arch/microblaze/include/asm/syscall.h
+++ b/arch/microblaze/include/asm/syscall.h
@@ -82,9 +82,11 @@ static inline void microblaze_set_syscall_arg(struct pt_regs *regs,
 
 static inline void syscall_get_arguments(struct task_struct *task,
 					 struct pt_regs *regs,
-					 unsigned int i, unsigned int n,
 					 unsigned long *args)
 {
+	unsigned int i = 0;
+	unsigned int n = 6;
+
 	while (n--)
 		*args++ = microblaze_get_syscall_arg(regs, i++);
 }
diff --git a/arch/mips/include/asm/syscall.h b/arch/mips/include/asm/syscall.h
index 6cf8ffb5367e..a2b4748655df 100644
--- a/arch/mips/include/asm/syscall.h
+++ b/arch/mips/include/asm/syscall.h
@@ -116,9 +116,10 @@ static inline void syscall_set_return_value(struct task_struct *task,
 
 static inline void syscall_get_arguments(struct task_struct *task,
 					 struct pt_regs *regs,
-					 unsigned int i, unsigned int n,
 					 unsigned long *args)
 {
+	unsigned int i = 0;
+	unsigned int n = 6;
 	int ret;
 
 	/* O32 ABI syscall() */
diff --git a/arch/mips/kernel/ptrace.c b/arch/mips/kernel/ptrace.c
index 0057c910bc2f..3a62f80958e1 100644
--- a/arch/mips/kernel/ptrace.c
+++ b/arch/mips/kernel/ptrace.c
@@ -1419,7 +1419,7 @@ asmlinkage long syscall_trace_enter(struct pt_regs *regs, long syscall)
 
 		sd.nr = syscall;
 		sd.arch = syscall_get_arch();
-		syscall_get_arguments(current, regs, 0, 6, args);
+		syscall_get_arguments(current, regs, args);
 		for (i = 0; i < 6; i++)
 			sd.args[i] = args[i];
 		sd.instruction_pointer = KSTK_EIP(current);
diff --git a/arch/nds32/include/asm/syscall.h b/arch/nds32/include/asm/syscall.h
index f7e5e86765fe..89a6ec8731d8 100644
--- a/arch/nds32/include/asm/syscall.h
+++ b/arch/nds32/include/asm/syscall.h
@@ -108,42 +108,21 @@ void syscall_set_return_value(struct task_struct *task, struct pt_regs *regs,
  * syscall_get_arguments - extract system call parameter values
  * @task:	task of interest, must be blocked
  * @regs:	task_pt_regs() of @task
- * @i:		argument index [0,5]
- * @n:		number of arguments; n+i must be [1,6].
  * @args:	array filled with argument values
  *
- * Fetches @n arguments to the system call starting with the @i'th argument
- * (from 0 through 5).  Argument @i is stored in @args[0], and so on.
- * An arch inline version is probably optimal when @i and @n are constants.
+ * Fetches 6 arguments to the system call (from 0 through 5). The first
+ * argument is stored in @args[0], and so on.
  *
  * It's only valid to call this when @task is stopped for tracing on
  * entry to a system call, due to %TIF_SYSCALL_TRACE or %TIF_SYSCALL_AUDIT.
- * It's invalid to call this with @i + @n > 6; we only support system calls
- * taking up to 6 arguments.
  */
 #define SYSCALL_MAX_ARGS 6
 void syscall_get_arguments(struct task_struct *task, struct pt_regs *regs,
-			   unsigned int i, unsigned int n, unsigned long *args)
+			   unsigned long *args)
 {
-	if (n = 0)
-		return;
-	if (i + n > SYSCALL_MAX_ARGS) {
-		unsigned long *args_bad = args + SYSCALL_MAX_ARGS - i;
-		unsigned int n_bad = n + i - SYSCALL_MAX_ARGS;
-		pr_warning("%s called with max args %d, handling only %d\n",
-			   __func__, i + n, SYSCALL_MAX_ARGS);
-		memset(args_bad, 0, n_bad * sizeof(args[0]));
-		memset(args_bad, 0, n_bad * sizeof(args[0]));
-	}
-
-	if (i = 0) {
-		args[0] = regs->orig_r0;
-		args++;
-		i++;
-		n--;
-	}
-
-	memcpy(args, &regs->uregs[0] + i, n * sizeof(args[0]));
+	args[0] = regs->orig_r0;
+	args++;
+	memcpy(args, &regs->uregs[0] + 1, 5 * sizeof(args[0]));
 }
 
 /**
diff --git a/arch/nios2/include/asm/syscall.h b/arch/nios2/include/asm/syscall.h
index 9de220854c4a..792bd449d839 100644
--- a/arch/nios2/include/asm/syscall.h
+++ b/arch/nios2/include/asm/syscall.h
@@ -58,42 +58,14 @@ static inline void syscall_set_return_value(struct task_struct *task,
 }
 
 static inline void syscall_get_arguments(struct task_struct *task,
-	struct pt_regs *regs, unsigned int i, unsigned int n,
-	unsigned long *args)
+	struct pt_regs *regs, unsigned long *args)
 {
-	BUG_ON(i + n > 6);
-
-	switch (i) {
-	case 0:
-		if (!n--)
-			break;
-		*args++ = regs->r4;
-	case 1:
-		if (!n--)
-			break;
-		*args++ = regs->r5;
-	case 2:
-		if (!n--)
-			break;
-		*args++ = regs->r6;
-	case 3:
-		if (!n--)
-			break;
-		*args++ = regs->r7;
-	case 4:
-		if (!n--)
-			break;
-		*args++ = regs->r8;
-	case 5:
-		if (!n--)
-			break;
-		*args++ = regs->r9;
-	case 6:
-		if (!n--)
-			break;
-	default:
-		BUG();
-	}
+	*args++ = regs->r4;
+	*args++ = regs->r5;
+	*args++ = regs->r6;
+	*args++ = regs->r7;
+	*args++ = regs->r8;
+	*args   = regs->r9;
 }
 
 static inline void syscall_set_arguments(struct task_struct *task,
diff --git a/arch/openrisc/include/asm/syscall.h b/arch/openrisc/include/asm/syscall.h
index 2db9f1cf0694..72607860cd55 100644
--- a/arch/openrisc/include/asm/syscall.h
+++ b/arch/openrisc/include/asm/syscall.h
@@ -56,11 +56,9 @@ syscall_set_return_value(struct task_struct *task, struct pt_regs *regs,
 
 static inline void
 syscall_get_arguments(struct task_struct *task, struct pt_regs *regs,
-		      unsigned int i, unsigned int n, unsigned long *args)
+		      unsigned long *args)
 {
-	BUG_ON(i + n > 6);
-
-	memcpy(args, &regs->gpr[3 + i], n * sizeof(args[0]));
+	memcpy(args, &regs->gpr[3], 6 * sizeof(args[0]));
 }
 
 static inline void
diff --git a/arch/parisc/include/asm/syscall.h b/arch/parisc/include/asm/syscall.h
index 8bff1a58c97f..62a6d477fae0 100644
--- a/arch/parisc/include/asm/syscall.h
+++ b/arch/parisc/include/asm/syscall.h
@@ -18,29 +18,15 @@ static inline long syscall_get_nr(struct task_struct *tsk,
 }
 
 static inline void syscall_get_arguments(struct task_struct *tsk,
-					 struct pt_regs *regs, unsigned int i,
-					 unsigned int n, unsigned long *args)
+					 struct pt_regs *regs,
+					 unsigned long *args)
 {
-	BUG_ON(i);
-
-	switch (n) {
-	case 6:
-		args[5] = regs->gr[21];
-	case 5:
-		args[4] = regs->gr[22];
-	case 4:
-		args[3] = regs->gr[23];
-	case 3:
-		args[2] = regs->gr[24];
-	case 2:
-		args[1] = regs->gr[25];
-	case 1:
-		args[0] = regs->gr[26];
-	case 0:
-		break;
-	default:
-		BUG();
-	}
+	args[5] = regs->gr[21];
+	args[4] = regs->gr[22];
+	args[3] = regs->gr[23];
+	args[2] = regs->gr[24];
+	args[1] = regs->gr[25];
+	args[0] = regs->gr[26];
 }
 
 static inline long syscall_get_return_value(struct task_struct *task,
diff --git a/arch/powerpc/include/asm/syscall.h b/arch/powerpc/include/asm/syscall.h
index 1a0e7a8b1c81..5c9b9dc82b7e 100644
--- a/arch/powerpc/include/asm/syscall.h
+++ b/arch/powerpc/include/asm/syscall.h
@@ -65,22 +65,20 @@ static inline void syscall_set_return_value(struct task_struct *task,
 
 static inline void syscall_get_arguments(struct task_struct *task,
 					 struct pt_regs *regs,
-					 unsigned int i, unsigned int n,
 					 unsigned long *args)
 {
 	unsigned long val, mask = -1UL;
-
-	BUG_ON(i + n > 6);
+	unsigned int n = 6;
 
 #ifdef CONFIG_COMPAT
 	if (test_tsk_thread_flag(task, TIF_32BIT))
 		mask = 0xffffffff;
 #endif
 	while (n--) {
-		if (n = 0 && i = 0)
+		if (n = 0)
 			val = regs->orig_gpr3;
 		else
-			val = regs->gpr[3 + i + n];
+			val = regs->gpr[3 + n];
 
 		args[n] = val & mask;
 	}
diff --git a/arch/riscv/include/asm/syscall.h b/arch/riscv/include/asm/syscall.h
index bba3da6ef157..85a31dd0f2ba 100644
--- a/arch/riscv/include/asm/syscall.h
+++ b/arch/riscv/include/asm/syscall.h
@@ -72,17 +72,11 @@ static inline void syscall_set_return_value(struct task_struct *task,
 
 static inline void syscall_get_arguments(struct task_struct *task,
 					 struct pt_regs *regs,
-					 unsigned int i, unsigned int n,
 					 unsigned long *args)
 {
-	BUG_ON(i + n > 6);
-	if (i = 0) {
-		args[0] = regs->orig_a0;
-		args++;
-		i++;
-		n--;
-	}
-	memcpy(args, &regs->a1 + i * sizeof(regs->a1), n * sizeof(args[0]));
+	args[0] = regs->orig_a0;
+	args++;
+	memcpy(args, &regs->a1 + sizeof(regs->a1), 5 * sizeof(args[0]));
 }
 
 static inline void syscall_set_arguments(struct task_struct *task,
diff --git a/arch/s390/include/asm/syscall.h b/arch/s390/include/asm/syscall.h
index 96f9a9151fde..ee0b1f6aa36d 100644
--- a/arch/s390/include/asm/syscall.h
+++ b/arch/s390/include/asm/syscall.h
@@ -56,27 +56,20 @@ static inline void syscall_set_return_value(struct task_struct *task,
 
 static inline void syscall_get_arguments(struct task_struct *task,
 					 struct pt_regs *regs,
-					 unsigned int i, unsigned int n,
 					 unsigned long *args)
 {
 	unsigned long mask = -1UL;
+	unsigned int n = 6;
 
-	/*
-	 * No arguments for this syscall, there's nothing to do.
-	 */
-	if (!n)
-		return;
-
-	BUG_ON(i + n > 6);
 #ifdef CONFIG_COMPAT
 	if (test_tsk_thread_flag(task, TIF_31BIT))
 		mask = 0xffffffff;
 #endif
 	while (n-- > 0)
-		if (i + n > 0)
-			args[n] = regs->gprs[2 + i + n] & mask;
-	if (i = 0)
-		args[0] = regs->orig_gpr2 & mask;
+		if (n > 0)
+			args[n] = regs->gprs[2 + n] & mask;
+
+	args[0] = regs->orig_gpr2 & mask;
 }
 
 static inline void syscall_set_arguments(struct task_struct *task,
diff --git a/arch/sh/include/asm/syscall_32.h b/arch/sh/include/asm/syscall_32.h
index 6e118799831c..2bf1199a0595 100644
--- a/arch/sh/include/asm/syscall_32.h
+++ b/arch/sh/include/asm/syscall_32.h
@@ -48,30 +48,16 @@ static inline void syscall_set_return_value(struct task_struct *task,
 
 static inline void syscall_get_arguments(struct task_struct *task,
 					 struct pt_regs *regs,
-					 unsigned int i, unsigned int n,
 					 unsigned long *args)
 {
-	/*
-	 * Do this simply for now. If we need to start supporting
-	 * fetching arguments from arbitrary indices, this will need some
-	 * extra logic. Presently there are no in-tree users that depend
-	 * on this behaviour.
-	 */
-	BUG_ON(i);
 
 	/* Argument pattern is: R4, R5, R6, R7, R0, R1 */
-	switch (n) {
-	case 6: args[5] = regs->regs[1];
-	case 5: args[4] = regs->regs[0];
-	case 4: args[3] = regs->regs[7];
-	case 3: args[2] = regs->regs[6];
-	case 2: args[1] = regs->regs[5];
-	case 1:	args[0] = regs->regs[4];
-	case 0:
-		break;
-	default:
-		BUG();
-	}
+	args[5] = regs->regs[1];
+	args[4] = regs->regs[0];
+	args[3] = regs->regs[7];
+	args[2] = regs->regs[6];
+	args[1] = regs->regs[5];
+	args[0] = regs->regs[4];
 }
 
 static inline void syscall_set_arguments(struct task_struct *task,
diff --git a/arch/sh/include/asm/syscall_64.h b/arch/sh/include/asm/syscall_64.h
index 43882580c7f9..4e8f6460c703 100644
--- a/arch/sh/include/asm/syscall_64.h
+++ b/arch/sh/include/asm/syscall_64.h
@@ -47,11 +47,9 @@ static inline void syscall_set_return_value(struct task_struct *task,
 
 static inline void syscall_get_arguments(struct task_struct *task,
 					 struct pt_regs *regs,
-					 unsigned int i, unsigned int n,
 					 unsigned long *args)
 {
-	BUG_ON(i + n > 6);
-	memcpy(args, &regs->regs[2 + i], n * sizeof(args[0]));
+	memcpy(args, &regs->regs[2], 6 * sizeof(args[0]));
 }
 
 static inline void syscall_set_arguments(struct task_struct *task,
diff --git a/arch/sparc/include/asm/syscall.h b/arch/sparc/include/asm/syscall.h
index 053989e3f6a6..872dfee852d6 100644
--- a/arch/sparc/include/asm/syscall.h
+++ b/arch/sparc/include/asm/syscall.h
@@ -96,11 +96,11 @@ static inline void syscall_set_return_value(struct task_struct *task,
 
 static inline void syscall_get_arguments(struct task_struct *task,
 					 struct pt_regs *regs,
-					 unsigned int i, unsigned int n,
 					 unsigned long *args)
 {
 	int zero_extend = 0;
 	unsigned int j;
+	unsigned int n = 6;
 
 #ifdef CONFIG_SPARC64
 	if (test_tsk_thread_flag(task, TIF_32BIT))
@@ -108,7 +108,7 @@ static inline void syscall_get_arguments(struct task_struct *task,
 #endif
 
 	for (j = 0; j < n; j++) {
-		unsigned long val = regs->u_regs[UREG_I0 + i + j];
+		unsigned long val = regs->u_regs[UREG_I0 + j];
 
 		if (zero_extend)
 			args[j] = (u32) val;
diff --git a/arch/um/include/asm/syscall-generic.h b/arch/um/include/asm/syscall-generic.h
index 9fb9cf8cd39a..25d00acd1322 100644
--- a/arch/um/include/asm/syscall-generic.h
+++ b/arch/um/include/asm/syscall-generic.h
@@ -53,43 +53,16 @@ static inline void syscall_set_return_value(struct task_struct *task,
 
 static inline void syscall_get_arguments(struct task_struct *task,
 					 struct pt_regs *regs,
-					 unsigned int i, unsigned int n,
 					 unsigned long *args)
 {
 	const struct uml_pt_regs *r = &regs->regs;
 
-	switch (i) {
-	case 0:
-		if (!n--)
-			break;
-		*args++ = UPT_SYSCALL_ARG1(r);
-	case 1:
-		if (!n--)
-			break;
-		*args++ = UPT_SYSCALL_ARG2(r);
-	case 2:
-		if (!n--)
-			break;
-		*args++ = UPT_SYSCALL_ARG3(r);
-	case 3:
-		if (!n--)
-			break;
-		*args++ = UPT_SYSCALL_ARG4(r);
-	case 4:
-		if (!n--)
-			break;
-		*args++ = UPT_SYSCALL_ARG5(r);
-	case 5:
-		if (!n--)
-			break;
-		*args++ = UPT_SYSCALL_ARG6(r);
-	case 6:
-		if (!n--)
-			break;
-	default:
-		BUG();
-		break;
-	}
+	*args++ = UPT_SYSCALL_ARG1(r);
+	*args++ = UPT_SYSCALL_ARG2(r);
+	*args++ = UPT_SYSCALL_ARG3(r);
+	*args++ = UPT_SYSCALL_ARG4(r);
+	*args++ = UPT_SYSCALL_ARG5(r);
+	*args   = UPT_SYSCALL_ARG6(r);
 }
 
 static inline void syscall_set_arguments(struct task_struct *task,
diff --git a/arch/x86/include/asm/syscall.h b/arch/x86/include/asm/syscall.h
index d653139857af..8dbb5c379450 100644
--- a/arch/x86/include/asm/syscall.h
+++ b/arch/x86/include/asm/syscall.h
@@ -91,11 +91,9 @@ static inline void syscall_set_return_value(struct task_struct *task,
 
 static inline void syscall_get_arguments(struct task_struct *task,
 					 struct pt_regs *regs,
-					 unsigned int i, unsigned int n,
 					 unsigned long *args)
 {
-	BUG_ON(i + n > 6);
-	memcpy(args, &regs->bx + i, n * sizeof(args[0]));
+	memcpy(args, &regs->bx, 6 * sizeof(args[0]));
 }
 
 static inline void syscall_set_arguments(struct task_struct *task,
@@ -116,63 +114,26 @@ static inline int syscall_get_arch(void)
 
 static inline void syscall_get_arguments(struct task_struct *task,
 					 struct pt_regs *regs,
-					 unsigned int i, unsigned int n,
 					 unsigned long *args)
 {
 # ifdef CONFIG_IA32_EMULATION
-	if (task->thread_info.status & TS_COMPAT)
-		switch (i) {
-		case 0:
-			if (!n--) break;
-			*args++ = regs->bx;
-		case 1:
-			if (!n--) break;
-			*args++ = regs->cx;
-		case 2:
-			if (!n--) break;
-			*args++ = regs->dx;
-		case 3:
-			if (!n--) break;
-			*args++ = regs->si;
-		case 4:
-			if (!n--) break;
-			*args++ = regs->di;
-		case 5:
-			if (!n--) break;
-			*args++ = regs->bp;
-		case 6:
-			if (!n--) break;
-		default:
-			BUG();
-			break;
-		}
-	else
+	if (task->thread_info.status & TS_COMPAT) {
+		*args++ = regs->bx;
+		*args++ = regs->cx;
+		*args++ = regs->dx;
+		*args++ = regs->si;
+		*args++ = regs->di;
+		*args   = regs->bp;
+	} else
 # endif
-		switch (i) {
-		case 0:
-			if (!n--) break;
-			*args++ = regs->di;
-		case 1:
-			if (!n--) break;
-			*args++ = regs->si;
-		case 2:
-			if (!n--) break;
-			*args++ = regs->dx;
-		case 3:
-			if (!n--) break;
-			*args++ = regs->r10;
-		case 4:
-			if (!n--) break;
-			*args++ = regs->r8;
-		case 5:
-			if (!n--) break;
-			*args++ = regs->r9;
-		case 6:
-			if (!n--) break;
-		default:
-			BUG();
-			break;
-		}
+	{
+		*args++ = regs->di;
+		*args++ = regs->si;
+		*args++ = regs->dx;
+		*args++ = regs->r10;
+		*args++ = regs->r8;
+		*args   = regs->r9;
+	}
 }
 
 static inline void syscall_set_arguments(struct task_struct *task,
diff --git a/arch/xtensa/include/asm/syscall.h b/arch/xtensa/include/asm/syscall.h
index a168bf81c7f4..1504ce9a233a 100644
--- a/arch/xtensa/include/asm/syscall.h
+++ b/arch/xtensa/include/asm/syscall.h
@@ -59,23 +59,13 @@ static inline void syscall_set_return_value(struct task_struct *task,
 
 static inline void syscall_get_arguments(struct task_struct *task,
 					 struct pt_regs *regs,
-					 unsigned int i, unsigned int n,
 					 unsigned long *args)
 {
 	static const unsigned int reg[] = XTENSA_SYSCALL_ARGUMENT_REGS;
-	unsigned int j;
-
-	if (n = 0)
-		return;
-
-	WARN_ON_ONCE(i + n > SYSCALL_MAX_ARGS);
+	unsigned int i;
 
-	for (j = 0; j < n; ++j) {
-		if (i + j < SYSCALL_MAX_ARGS)
-			args[j] = regs->areg[reg[i + j]];
-		else
-			args[j] = 0;
-	}
+	for (i = 0; i < 6; ++i)
+		args[i] = regs->areg[reg[i]];
 }
 
 static inline void syscall_set_arguments(struct task_struct *task,
diff --git a/include/asm-generic/syscall.h b/include/asm-generic/syscall.h
index 0c938a4354f6..269e9412ef42 100644
--- a/include/asm-generic/syscall.h
+++ b/include/asm-generic/syscall.h
@@ -105,21 +105,16 @@ void syscall_set_return_value(struct task_struct *task, struct pt_regs *regs,
  * syscall_get_arguments - extract system call parameter values
  * @task:	task of interest, must be blocked
  * @regs:	task_pt_regs() of @task
- * @i:		argument index [0,5]
- * @n:		number of arguments; n+i must be [1,6].
  * @args:	array filled with argument values
  *
- * Fetches @n arguments to the system call starting with the @i'th argument
- * (from 0 through 5).  Argument @i is stored in @args[0], and so on.
- * An arch inline version is probably optimal when @i and @n are constants.
+ * Fetches 6 arguments to the system call.  First argument is stored in
+*  @args[0], and so on.
  *
  * It's only valid to call this when @task is stopped for tracing on
  * entry to a system call, due to %TIF_SYSCALL_TRACE or %TIF_SYSCALL_AUDIT.
- * It's invalid to call this with @i + @n > 6; we only support system calls
- * taking up to 6 arguments.
  */
 void syscall_get_arguments(struct task_struct *task, struct pt_regs *regs,
-			   unsigned int i, unsigned int n, unsigned long *args);
+			   unsigned long *args);
 
 /**
  * syscall_set_arguments - change system call parameter value
diff --git a/include/trace/events/syscalls.h b/include/trace/events/syscalls.h
index 44a3259ed4a5..b6e0cbc2c71f 100644
--- a/include/trace/events/syscalls.h
+++ b/include/trace/events/syscalls.h
@@ -28,7 +28,7 @@ TRACE_EVENT_FN(sys_enter,
 
 	TP_fast_assign(
 		__entry->id	= id;
-		syscall_get_arguments(current, regs, 0, 6, __entry->args);
+		syscall_get_arguments(current, regs, __entry->args);
 	),
 
 	TP_printk("NR %ld (%lx, %lx, %lx, %lx, %lx, %lx)",
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 54a0347ca812..df27e499956a 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -149,7 +149,7 @@ static void populate_seccomp_data(struct seccomp_data *sd)
 
 	sd->nr = syscall_get_nr(task, regs);
 	sd->arch = syscall_get_arch();
-	syscall_get_arguments(task, regs, 0, 6, args);
+	syscall_get_arguments(task, regs, args);
 	sd->args[0] = args[0];
 	sd->args[1] = args[1];
 	sd->args[2] = args[2];
diff --git a/kernel/trace/trace_syscalls.c b/kernel/trace/trace_syscalls.c
index e9f5bbbad6d9..fa8fbff736d6 100644
--- a/kernel/trace/trace_syscalls.c
+++ b/kernel/trace/trace_syscalls.c
@@ -348,7 +348,7 @@ static void ftrace_syscall_enter(void *data, struct pt_regs *regs, long id)
 
 	entry = ring_buffer_event_data(event);
 	entry->nr = syscall_nr;
-	syscall_get_arguments(current, regs, 0, 6, args);
+	syscall_get_arguments(current, regs, args);
 	memcpy(entry->args, args, sizeof(unsigned long) * sys_data->nb_args);
 
 	event_trigger_unlock_commit(trace_file, buffer, event, entry,
@@ -616,7 +616,7 @@ static void perf_syscall_enter(void *ignore, struct pt_regs *regs, long id)
 		return;
 
 	rec->nr = syscall_nr;
-	syscall_get_arguments(current, regs, 0, 6, args);
+	syscall_get_arguments(current, regs, args);
 	memcpy(&rec->args, args, sizeof(unsigned long) * sys_data->nb_args);
 
 	if ((valid_prog_array &&
diff --git a/lib/syscall.c b/lib/syscall.c
index e8467e17b9a2..fb328e7ccb08 100644
--- a/lib/syscall.c
+++ b/lib/syscall.c
@@ -27,7 +27,7 @@ static int collect_syscall(struct task_struct *target, struct syscall_info *info
 
 	info->data.nr = syscall_get_nr(target, regs);
 	if (info->data.nr != -1L)
-		syscall_get_arguments(target, regs, 0, 6,
+		syscall_get_arguments(target, regs,
 				      (unsigned long *)&info->data.args[0]);
 
 	put_task_stack(target);
-- 
2.20.1

