From: Steven Rostedt <rostedt@goodmis.org>
Date: Thu, 28 Mar 2019 23:05:16 +0000
Subject: [RFC][PATCH 4/4 v2] syscalls: Remove start and number from syscall_set_arguments() args
Message-Id: <20190329032253.429310275@goodmis.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190328230512.486297455@goodmis.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: linux-ia64@vger.kernel.org, "Gustavo A. R. Silva" <gustavo@embeddedor.com>, Peter Zijlstra <peterz@infradead.org>, Dominik Brodowski <linux@dominikbrodowski.net>, "Dmitry V. Levin" <ldv@altlinux.org>, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, linux-riscv@lists.infradead.org, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, linux-c6x-dev@linux-c6x.org, linux-sh@vger.kernel.org, linux-hexagon@vger.kernel.org, x86@kernel.org, linux-snps-arc@lists.infradead.org, Dave Martin <dave.martin@arm.com>, uclinux-h8-devel@lists.sourceforge.jp, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Roland McGrath <roland@hack.frob.com>, linux-um@lists.infradead.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linu>

From: "Steven Rostedt (VMware)" <rostedt@goodmis.org>

After removing the start and count arguments of syscall_get_arguments() it
seems reasonable to remove them from syscall_set_arguments(). Note, as of
today, there are no users of syscall_set_arguments(). But we are told that
there will be soon. But for now, at least make it consistent with
syscall_get_arguments().

Link: http://lkml.kernel.org/r/20190327222014.GA32540@altlinux.org

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
Signed-off-by: Steven Rostedt (VMware) <rostedt@goodmis.org>
---
 arch/arm/include/asm/syscall.h        | 22 ++-------
 arch/arm64/include/asm/syscall.h      | 22 ++-------
 arch/c6x/include/asm/syscall.h        | 38 +++------------
 arch/csky/include/asm/syscall.h       | 13 ++---
 arch/ia64/include/asm/syscall.h       | 10 ++--
 arch/ia64/kernel/ptrace.c             |  7 ++-
 arch/microblaze/include/asm/syscall.h |  4 +-
 arch/nds32/include/asm/syscall.h      | 29 ++---------
 arch/nios2/include/asm/syscall.h      | 42 +++-------------
 arch/openrisc/include/asm/syscall.h   |  6 +--
 arch/powerpc/include/asm/syscall.h    |  7 +--
 arch/riscv/include/asm/syscall.h      | 12 ++---
 arch/s390/include/asm/syscall.h       | 11 ++---
 arch/sh/include/asm/syscall_32.h      | 21 +++-----
 arch/sh/include/asm/syscall_64.h      |  4 +-
 arch/sparc/include/asm/syscall.h      |  7 ++-
 arch/um/include/asm/syscall-generic.h | 39 +++------------
 arch/x86/include/asm/syscall.h        | 69 +++++++--------------------
 arch/xtensa/include/asm/syscall.h     | 17 ++-----
 include/asm-generic/syscall.h         | 10 +---
 20 files changed, 88 insertions(+), 302 deletions(-)

diff --git a/arch/arm/include/asm/syscall.h b/arch/arm/include/asm/syscall.h
index db969a2972ae..080ce70cab12 100644
--- a/arch/arm/include/asm/syscall.h
+++ b/arch/arm/include/asm/syscall.h
@@ -65,26 +65,12 @@ static inline void syscall_get_arguments(struct task_struct *task,
 
 static inline void syscall_set_arguments(struct task_struct *task,
 					 struct pt_regs *regs,
-					 unsigned int i, unsigned int n,
 					 const unsigned long *args)
 {
-	if (n = 0)
-		return;
-
-	if (i + n > SYSCALL_MAX_ARGS) {
-		pr_warn("%s called with max args %d, handling only %d\n",
-			__func__, i + n, SYSCALL_MAX_ARGS);
-		n = SYSCALL_MAX_ARGS - i;
-	}
-
-	if (i = 0) {
-		regs->ARM_ORIG_r0 = args[0];
-		args++;
-		i++;
-		n--;
-	}
-
-	memcpy(&regs->ARM_r0 + i, args, n * sizeof(args[0]));
+	regs->ARM_ORIG_r0 = args[0];
+	args++;
+
+	memcpy(&regs->ARM_r0 + 1, args, 5 * sizeof(args[0]));
 }
 
 static inline int syscall_get_arch(void)
diff --git a/arch/arm64/include/asm/syscall.h b/arch/arm64/include/asm/syscall.h
index 55b2dab21023..a179df3674a1 100644
--- a/arch/arm64/include/asm/syscall.h
+++ b/arch/arm64/include/asm/syscall.h
@@ -75,26 +75,12 @@ static inline void syscall_get_arguments(struct task_struct *task,
 
 static inline void syscall_set_arguments(struct task_struct *task,
 					 struct pt_regs *regs,
-					 unsigned int i, unsigned int n,
 					 const unsigned long *args)
 {
-	if (n = 0)
-		return;
-
-	if (i + n > SYSCALL_MAX_ARGS) {
-		pr_warning("%s called with max args %d, handling only %d\n",
-			   __func__, i + n, SYSCALL_MAX_ARGS);
-		n = SYSCALL_MAX_ARGS - i;
-	}
-
-	if (i = 0) {
-		regs->orig_x0 = args[0];
-		args++;
-		i++;
-		n--;
-	}
-
-	memcpy(&regs->regs[i], args, n * sizeof(args[0]));
+	regs->orig_x0 = args[0];
+	args++;
+
+	memcpy(&regs->regs[1], args, 5 * sizeof(args[0]));
 }
 
 /*
diff --git a/arch/c6x/include/asm/syscall.h b/arch/c6x/include/asm/syscall.h
index 06db3251926b..15ba8599858e 100644
--- a/arch/c6x/include/asm/syscall.h
+++ b/arch/c6x/include/asm/syscall.h
@@ -59,40 +59,14 @@ static inline void syscall_get_arguments(struct task_struct *task,
 
 static inline void syscall_set_arguments(struct task_struct *task,
 					 struct pt_regs *regs,
-					 unsigned int i, unsigned int n,
 					 const unsigned long *args)
 {
-	switch (i) {
-	case 0:
-		if (!n--)
-			break;
-		regs->a4 = *args++;
-	case 1:
-		if (!n--)
-			break;
-		regs->b4 = *args++;
-	case 2:
-		if (!n--)
-			break;
-		regs->a6 = *args++;
-	case 3:
-		if (!n--)
-			break;
-		regs->b6 = *args++;
-	case 4:
-		if (!n--)
-			break;
-		regs->a8 = *args++;
-	case 5:
-		if (!n--)
-			break;
-		regs->a9 = *args++;
-	case 6:
-		if (!n)
-			break;
-	default:
-		BUG();
-	}
+	regs->a4 = *args++;
+	regs->b4 = *args++;
+	regs->a6 = *args++;
+	regs->b6 = *args++;
+	regs->a8 = *args++;
+	regs->a9 = *args;
 }
 
 #endif /* __ASM_C6X_SYSCALLS_H */
diff --git a/arch/csky/include/asm/syscall.h b/arch/csky/include/asm/syscall.h
index 5cc0b8283a69..34c02d6bb973 100644
--- a/arch/csky/include/asm/syscall.h
+++ b/arch/csky/include/asm/syscall.h
@@ -52,16 +52,11 @@ syscall_get_arguments(struct task_struct *task, struct pt_regs *regs,
 
 static inline void
 syscall_set_arguments(struct task_struct *task, struct pt_regs *regs,
-		      unsigned int i, unsigned int n, const unsigned long *args)
+		      const unsigned long *args)
 {
-	BUG_ON(i + n > 6);
-	if (i = 0) {
-		regs->orig_a0 = args[0];
-		args++;
-		i++;
-		n--;
-	}
-	memcpy(&regs->a1 + i * sizeof(regs->a1), args, n * sizeof(regs->a0));
+	regs->orig_a0 = args[0];
+	args++;
+	memcpy(&regs->a1 + sizeof(regs->a1), args, 5 * sizeof(regs->a0));
 }
 
 static inline int
diff --git a/arch/ia64/include/asm/syscall.h b/arch/ia64/include/asm/syscall.h
index 8204c1ff70ce..0d9e7fab4a79 100644
--- a/arch/ia64/include/asm/syscall.h
+++ b/arch/ia64/include/asm/syscall.h
@@ -59,23 +59,19 @@ static inline void syscall_set_return_value(struct task_struct *task,
 }
 
 extern void ia64_syscall_get_set_arguments(struct task_struct *task,
-	struct pt_regs *regs, unsigned int i, unsigned int n,
-	unsigned long *args, int rw);
+	struct pt_regs *regs, unsigned long *args, int rw);
 static inline void syscall_get_arguments(struct task_struct *task,
 					 struct pt_regs *regs,
 					 unsigned long *args)
 {
-	ia64_syscall_get_set_arguments(task, regs, 0, 6, args, 0);
+	ia64_syscall_get_set_arguments(task, regs, args, 0);
 }
 
 static inline void syscall_set_arguments(struct task_struct *task,
 					 struct pt_regs *regs,
-					 unsigned int i, unsigned int n,
 					 unsigned long *args)
 {
-	BUG_ON(i + n > 6);
-
-	ia64_syscall_get_set_arguments(task, regs, i, n, args, 1);
+	ia64_syscall_get_set_arguments(task, regs, args, 1);
 }
 
 static inline int syscall_get_arch(void)
diff --git a/arch/ia64/kernel/ptrace.c b/arch/ia64/kernel/ptrace.c
index 6d50ede0ed69..bf9c24d9ce84 100644
--- a/arch/ia64/kernel/ptrace.c
+++ b/arch/ia64/kernel/ptrace.c
@@ -2179,12 +2179,11 @@ static void syscall_get_set_args_cb(struct unw_frame_info *info, void *data)
 }
 
 void ia64_syscall_get_set_arguments(struct task_struct *task,
-	struct pt_regs *regs, unsigned int i, unsigned int n,
-	unsigned long *args, int rw)
+	struct pt_regs *regs, unsigned long *args, int rw)
 {
 	struct syscall_get_set_args data = {
-		.i = i,
-		.n = n,
+		.i = 0,
+		.n = 6,
 		.args = args,
 		.regs = regs,
 		.rw = rw,
diff --git a/arch/microblaze/include/asm/syscall.h b/arch/microblaze/include/asm/syscall.h
index 4b23e44e5c3c..833d3a53dab3 100644
--- a/arch/microblaze/include/asm/syscall.h
+++ b/arch/microblaze/include/asm/syscall.h
@@ -93,9 +93,11 @@ static inline void syscall_get_arguments(struct task_struct *task,
 
 static inline void syscall_set_arguments(struct task_struct *task,
 					 struct pt_regs *regs,
-					 unsigned int i, unsigned int n,
 					 const unsigned long *args)
 {
+	unsigned int i = 0;
+	unsigned int n = 6;
+
 	while (n--)
 		microblaze_set_syscall_arg(regs, i++, *args++);
 }
diff --git a/arch/nds32/include/asm/syscall.h b/arch/nds32/include/asm/syscall.h
index 89a6ec8731d8..671ebd357496 100644
--- a/arch/nds32/include/asm/syscall.h
+++ b/arch/nds32/include/asm/syscall.h
@@ -129,39 +129,20 @@ void syscall_get_arguments(struct task_struct *task, struct pt_regs *regs,
  * syscall_set_arguments - change system call parameter value
  * @task:	task of interest, must be in system call entry tracing
  * @regs:	task_pt_regs() of @task
- * @i:		argument index [0,5]
- * @n:		number of arguments; n+i must be [1,6].
  * @args:	array of argument values to store
  *
- * Changes @n arguments to the system call starting with the @i'th argument.
- * Argument @i gets value @args[0], and so on.
- * An arch inline version is probably optimal when @i and @n are constants.
+ * Changes 6 arguments to the system call. The first argument gets value
+ * @args[0], and so on.
  *
  * It's only valid to call this when @task is stopped for tracing on
  * entry to a system call, due to %TIF_SYSCALL_TRACE or %TIF_SYSCALL_AUDIT.
- * It's invalid to call this with @i + @n > 6; we only support system calls
- * taking up to 6 arguments.
  */
 void syscall_set_arguments(struct task_struct *task, struct pt_regs *regs,
-			   unsigned int i, unsigned int n,
 			   const unsigned long *args)
 {
-	if (n = 0)
-		return;
-
-	if (i + n > SYSCALL_MAX_ARGS) {
-		pr_warn("%s called with max args %d, handling only %d\n",
-			__func__, i + n, SYSCALL_MAX_ARGS);
-		n = SYSCALL_MAX_ARGS - i;
-	}
-
-	if (i = 0) {
-		regs->orig_r0 = args[0];
-		args++;
-		i++;
-		n--;
-	}
+	regs->orig_r0 = args[0];
+	args++;
 
-	memcpy(&regs->uregs[0] + i, args, n * sizeof(args[0]));
+	memcpy(&regs->uregs[0] + 1, args, 5 * sizeof(args[0]));
 }
 #endif /* _ASM_NDS32_SYSCALL_H */
diff --git a/arch/nios2/include/asm/syscall.h b/arch/nios2/include/asm/syscall.h
index 792bd449d839..d7624ed06efb 100644
--- a/arch/nios2/include/asm/syscall.h
+++ b/arch/nios2/include/asm/syscall.h
@@ -69,42 +69,14 @@ static inline void syscall_get_arguments(struct task_struct *task,
 }
 
 static inline void syscall_set_arguments(struct task_struct *task,
-	struct pt_regs *regs, unsigned int i, unsigned int n,
-	const unsigned long *args)
+	struct pt_regs *regs, const unsigned long *args)
 {
-	BUG_ON(i + n > 6);
-
-	switch (i) {
-	case 0:
-		if (!n--)
-			break;
-		regs->r4 = *args++;
-	case 1:
-		if (!n--)
-			break;
-		regs->r5 = *args++;
-	case 2:
-		if (!n--)
-			break;
-		regs->r6 = *args++;
-	case 3:
-		if (!n--)
-			break;
-		regs->r7 = *args++;
-	case 4:
-		if (!n--)
-			break;
-		regs->r8 = *args++;
-	case 5:
-		if (!n--)
-			break;
-		regs->r9 = *args++;
-	case 6:
-		if (!n)
-			break;
-	default:
-		BUG();
-	}
+	regs->r4 = *args++;
+	regs->r5 = *args++;
+	regs->r6 = *args++;
+	regs->r7 = *args++;
+	regs->r8 = *args++;
+	regs->r9 = *args;
 }
 
 #endif
diff --git a/arch/openrisc/include/asm/syscall.h b/arch/openrisc/include/asm/syscall.h
index 72607860cd55..b4ff07c1baed 100644
--- a/arch/openrisc/include/asm/syscall.h
+++ b/arch/openrisc/include/asm/syscall.h
@@ -63,11 +63,9 @@ syscall_get_arguments(struct task_struct *task, struct pt_regs *regs,
 
 static inline void
 syscall_set_arguments(struct task_struct *task, struct pt_regs *regs,
-		      unsigned int i, unsigned int n, const unsigned long *args)
+		      const unsigned long *args)
 {
-	BUG_ON(i + n > 6);
-
-	memcpy(&regs->gpr[3 + i], args, n * sizeof(args[0]));
+	memcpy(&regs->gpr[3], args, 6 * sizeof(args[0]));
 }
 
 static inline int syscall_get_arch(void)
diff --git a/arch/powerpc/include/asm/syscall.h b/arch/powerpc/include/asm/syscall.h
index 5c9b9dc82b7e..1243045bad2d 100644
--- a/arch/powerpc/include/asm/syscall.h
+++ b/arch/powerpc/include/asm/syscall.h
@@ -86,15 +86,12 @@ static inline void syscall_get_arguments(struct task_struct *task,
 
 static inline void syscall_set_arguments(struct task_struct *task,
 					 struct pt_regs *regs,
-					 unsigned int i, unsigned int n,
 					 const unsigned long *args)
 {
-	BUG_ON(i + n > 6);
-	memcpy(&regs->gpr[3 + i], args, n * sizeof(args[0]));
+	memcpy(&regs->gpr[3], args, 6 * sizeof(args[0]));
 
 	/* Also copy the first argument into orig_gpr3 */
-	if (i = 0 && n > 0)
-		regs->orig_gpr3 = args[0];
+	regs->orig_gpr3 = args[0];
 }
 
 static inline int syscall_get_arch(void)
diff --git a/arch/riscv/include/asm/syscall.h b/arch/riscv/include/asm/syscall.h
index 85a31dd0f2ba..7321644be1cf 100644
--- a/arch/riscv/include/asm/syscall.h
+++ b/arch/riscv/include/asm/syscall.h
@@ -81,17 +81,11 @@ static inline void syscall_get_arguments(struct task_struct *task,
 
 static inline void syscall_set_arguments(struct task_struct *task,
 					 struct pt_regs *regs,
-					 unsigned int i, unsigned int n,
 					 const unsigned long *args)
 {
-	BUG_ON(i + n > 6);
-        if (i = 0) {
-                regs->orig_a0 = args[0];
-                args++;
-                i++;
-                n--;
-        }
-	memcpy(&regs->a1 + i * sizeof(regs->a1), args, n * sizeof(regs->a0));
+	regs->orig_a0 = args[0];
+	args++;
+	memcpy(&regs->a1 + sizeof(regs->a1), args, 5 * sizeof(regs->a0));
 }
 
 static inline int syscall_get_arch(void)
diff --git a/arch/s390/include/asm/syscall.h b/arch/s390/include/asm/syscall.h
index ee0b1f6aa36d..59c3e91f2cdb 100644
--- a/arch/s390/include/asm/syscall.h
+++ b/arch/s390/include/asm/syscall.h
@@ -74,15 +74,14 @@ static inline void syscall_get_arguments(struct task_struct *task,
 
 static inline void syscall_set_arguments(struct task_struct *task,
 					 struct pt_regs *regs,
-					 unsigned int i, unsigned int n,
 					 const unsigned long *args)
 {
-	BUG_ON(i + n > 6);
+	unsigned int n = 6;
+
 	while (n-- > 0)
-		if (i + n > 0)
-			regs->gprs[2 + i + n] = args[n];
-	if (i = 0)
-		regs->orig_gpr2 = args[0];
+		if (n > 0)
+			regs->gprs[2 + n] = args[n];
+	regs->orig_gpr2 = args[0];
 }
 
 static inline int syscall_get_arch(void)
diff --git a/arch/sh/include/asm/syscall_32.h b/arch/sh/include/asm/syscall_32.h
index 2bf1199a0595..8c9d7e5e5dcc 100644
--- a/arch/sh/include/asm/syscall_32.h
+++ b/arch/sh/include/asm/syscall_32.h
@@ -62,23 +62,14 @@ static inline void syscall_get_arguments(struct task_struct *task,
 
 static inline void syscall_set_arguments(struct task_struct *task,
 					 struct pt_regs *regs,
-					 unsigned int i, unsigned int n,
 					 const unsigned long *args)
 {
-	/* Same note as above applies */
-	BUG_ON(i);
-
-	switch (n) {
-	case 6: regs->regs[1] = args[5];
-	case 5: regs->regs[0] = args[4];
-	case 4: regs->regs[7] = args[3];
-	case 3: regs->regs[6] = args[2];
-	case 2: regs->regs[5] = args[1];
-	case 1: regs->regs[4] = args[0];
-		break;
-	default:
-		BUG();
-	}
+	regs->regs[1] = args[5];
+	regs->regs[0] = args[4];
+	regs->regs[7] = args[3];
+	regs->regs[6] = args[2];
+	regs->regs[5] = args[1];
+	regs->regs[4] = args[0];
 }
 
 static inline int syscall_get_arch(void)
diff --git a/arch/sh/include/asm/syscall_64.h b/arch/sh/include/asm/syscall_64.h
index 4e8f6460c703..22fad97da066 100644
--- a/arch/sh/include/asm/syscall_64.h
+++ b/arch/sh/include/asm/syscall_64.h
@@ -54,11 +54,9 @@ static inline void syscall_get_arguments(struct task_struct *task,
 
 static inline void syscall_set_arguments(struct task_struct *task,
 					 struct pt_regs *regs,
-					 unsigned int i, unsigned int n,
 					 const unsigned long *args)
 {
-	BUG_ON(i + n > 6);
-	memcpy(&regs->regs[2 + i], args, n * sizeof(args[0]));
+	memcpy(&regs->regs[2], args, 6 * sizeof(args[0]));
 }
 
 static inline int syscall_get_arch(void)
diff --git a/arch/sparc/include/asm/syscall.h b/arch/sparc/include/asm/syscall.h
index 872dfee852d6..4d075434e816 100644
--- a/arch/sparc/include/asm/syscall.h
+++ b/arch/sparc/include/asm/syscall.h
@@ -119,13 +119,12 @@ static inline void syscall_get_arguments(struct task_struct *task,
 
 static inline void syscall_set_arguments(struct task_struct *task,
 					 struct pt_regs *regs,
-					 unsigned int i, unsigned int n,
 					 const unsigned long *args)
 {
-	unsigned int j;
+	unsigned int i;
 
-	for (j = 0; j < n; j++)
-		regs->u_regs[UREG_I0 + i + j] = args[j];
+	for (i = 0; i < 6; i++)
+		regs->u_regs[UREG_I0 + i] = args[i];
 }
 
 static inline int syscall_get_arch(void)
diff --git a/arch/um/include/asm/syscall-generic.h b/arch/um/include/asm/syscall-generic.h
index 25d00acd1322..98e50c50c12e 100644
--- a/arch/um/include/asm/syscall-generic.h
+++ b/arch/um/include/asm/syscall-generic.h
@@ -67,43 +67,16 @@ static inline void syscall_get_arguments(struct task_struct *task,
 
 static inline void syscall_set_arguments(struct task_struct *task,
 					 struct pt_regs *regs,
-					 unsigned int i, unsigned int n,
 					 const unsigned long *args)
 {
 	struct uml_pt_regs *r = &regs->regs;
 
-	switch (i) {
-	case 0:
-		if (!n--)
-			break;
-		UPT_SYSCALL_ARG1(r) = *args++;
-	case 1:
-		if (!n--)
-			break;
-		UPT_SYSCALL_ARG2(r) = *args++;
-	case 2:
-		if (!n--)
-			break;
-		UPT_SYSCALL_ARG3(r) = *args++;
-	case 3:
-		if (!n--)
-			break;
-		UPT_SYSCALL_ARG4(r) = *args++;
-	case 4:
-		if (!n--)
-			break;
-		UPT_SYSCALL_ARG5(r) = *args++;
-	case 5:
-		if (!n--)
-			break;
-		UPT_SYSCALL_ARG6(r) = *args++;
-	case 6:
-		if (!n--)
-			break;
-	default:
-		BUG();
-		break;
-	}
+	UPT_SYSCALL_ARG1(r) = *args++;
+	UPT_SYSCALL_ARG2(r) = *args++;
+	UPT_SYSCALL_ARG3(r) = *args++;
+	UPT_SYSCALL_ARG4(r) = *args++;
+	UPT_SYSCALL_ARG5(r) = *args++;
+	UPT_SYSCALL_ARG6(r) = *args;
 }
 
 /* See arch/x86/um/asm/syscall.h for syscall_get_arch() definition. */
diff --git a/arch/x86/include/asm/syscall.h b/arch/x86/include/asm/syscall.h
index 8dbb5c379450..4c305471ec33 100644
--- a/arch/x86/include/asm/syscall.h
+++ b/arch/x86/include/asm/syscall.h
@@ -138,63 +138,26 @@ static inline void syscall_get_arguments(struct task_struct *task,
 
 static inline void syscall_set_arguments(struct task_struct *task,
 					 struct pt_regs *regs,
-					 unsigned int i, unsigned int n,
 					 const unsigned long *args)
 {
 # ifdef CONFIG_IA32_EMULATION
-	if (task->thread_info.status & TS_COMPAT)
-		switch (i) {
-		case 0:
-			if (!n--) break;
-			regs->bx = *args++;
-		case 1:
-			if (!n--) break;
-			regs->cx = *args++;
-		case 2:
-			if (!n--) break;
-			regs->dx = *args++;
-		case 3:
-			if (!n--) break;
-			regs->si = *args++;
-		case 4:
-			if (!n--) break;
-			regs->di = *args++;
-		case 5:
-			if (!n--) break;
-			regs->bp = *args++;
-		case 6:
-			if (!n--) break;
-		default:
-			BUG();
-			break;
-		}
-	else
+	if (task->thread_info.status & TS_COMPAT) {
+		regs->bx = *args++;
+		regs->cx = *args++;
+		regs->dx = *args++;
+		regs->si = *args++;
+		regs->di = *args++;
+		regs->bp = *args;
+	} else
 # endif
-		switch (i) {
-		case 0:
-			if (!n--) break;
-			regs->di = *args++;
-		case 1:
-			if (!n--) break;
-			regs->si = *args++;
-		case 2:
-			if (!n--) break;
-			regs->dx = *args++;
-		case 3:
-			if (!n--) break;
-			regs->r10 = *args++;
-		case 4:
-			if (!n--) break;
-			regs->r8 = *args++;
-		case 5:
-			if (!n--) break;
-			regs->r9 = *args++;
-		case 6:
-			if (!n--) break;
-		default:
-			BUG();
-			break;
-		}
+	{
+		regs->di = *args++;
+		regs->si = *args++;
+		regs->dx = *args++;
+		regs->r10 = *args++;
+		regs->r8 = *args++;
+		regs->r9 = *args;
+	}
 }
 
 static inline int syscall_get_arch(void)
diff --git a/arch/xtensa/include/asm/syscall.h b/arch/xtensa/include/asm/syscall.h
index 1504ce9a233a..91dc06d58060 100644
--- a/arch/xtensa/include/asm/syscall.h
+++ b/arch/xtensa/include/asm/syscall.h
@@ -70,24 +70,13 @@ static inline void syscall_get_arguments(struct task_struct *task,
 
 static inline void syscall_set_arguments(struct task_struct *task,
 					 struct pt_regs *regs,
-					 unsigned int i, unsigned int n,
 					 const unsigned long *args)
 {
 	static const unsigned int reg[] = XTENSA_SYSCALL_ARGUMENT_REGS;
-	unsigned int j;
-
-	if (n = 0)
-		return;
-
-	if (WARN_ON_ONCE(i + n > SYSCALL_MAX_ARGS)) {
-		if (i < SYSCALL_MAX_ARGS)
-			n = SYSCALL_MAX_ARGS - i;
-		else
-			return;
-	}
+	unsigned int i;
 
-	for (j = 0; j < n; ++j)
-		regs->areg[reg[i + j]] = args[j];
+	for (i = 0; i < 6; ++i)
+		regs->areg[reg[i]] = args[i];
 }
 
 asmlinkage long xtensa_rt_sigreturn(struct pt_regs*);
diff --git a/include/asm-generic/syscall.h b/include/asm-generic/syscall.h
index 269e9412ef42..b88239e9efe4 100644
--- a/include/asm-generic/syscall.h
+++ b/include/asm-generic/syscall.h
@@ -120,21 +120,15 @@ void syscall_get_arguments(struct task_struct *task, struct pt_regs *regs,
  * syscall_set_arguments - change system call parameter value
  * @task:	task of interest, must be in system call entry tracing
  * @regs:	task_pt_regs() of @task
- * @i:		argument index [0,5]
- * @n:		number of arguments; n+i must be [1,6].
  * @args:	array of argument values to store
  *
- * Changes @n arguments to the system call starting with the @i'th argument.
- * Argument @i gets value @args[0], and so on.
- * An arch inline version is probably optimal when @i and @n are constants.
+ * Changes 6 arguments to the system call.
+ * The first argument gets value @args[0], and so on.
  *
  * It's only valid to call this when @task is stopped for tracing on
  * entry to a system call, due to %TIF_SYSCALL_TRACE or %TIF_SYSCALL_AUDIT.
- * It's invalid to call this with @i + @n > 6; we only support system calls
- * taking up to 6 arguments.
  */
 void syscall_set_arguments(struct task_struct *task, struct pt_regs *regs,
-			   unsigned int i, unsigned int n,
 			   const unsigned long *args);
 
 /**
-- 
2.20.1

