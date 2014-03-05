From: Richard Guy Briggs <rgb@redhat.com>
Date: Wed, 05 Mar 2014 21:27:06 +0000
Subject: [PATCH 5/6][RFC] audit: drop args from syscall_get_arch() interface
Message-Id: <46abd0fd000ac83cf5c4344cdfe1e349a09cb565.1393974970.git.rgb@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1393974970.git.rgb@redhat.com>
In-Reply-To: <cover.1393974970.git.rgb@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-audit@redhat.com, linux-kernel@vger.kernel.org
Cc: Richard Guy Briggs <rgb@redhat.com>, eparis@redhat.com, sgrubb@redhat.com, oleg@redhat.com, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-ia64@vger.kernel.org, microblaze-uclinux@itee.uq.edu.au, linux-mips@linux-mips.org, linux@openrisc.net, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, linux-arch@vger.kernel.org

Since all callers of syscall_get_arch() call with task "current" and none of
the arch-dependent functions use the "regs" parameter (which could just as
easily be found with task_pt_regs()), delete both parameters.

Signed-off-by: Richard Guy Briggs <rgb@redhat.com>

---
 arch/arm/include/asm/syscall.h        |    3 +--
 arch/ia64/include/asm/syscall.h       |    3 +--
 arch/microblaze/include/asm/syscall.h |    3 +--
 arch/mips/include/asm/syscall.h       |    8 +-------
 arch/openrisc/include/asm/syscall.h   |    3 +--
 arch/parisc/include/asm/syscall.h     |    3 +--
 arch/powerpc/include/asm/syscall.h    |    3 +--
 arch/s390/include/asm/syscall.h       |    5 ++---
 arch/sh/include/asm/syscall.h         |    3 +--
 arch/sparc/include/asm/syscall.h      |    3 +--
 arch/x86/include/asm/syscall.h        |    8 +++-----
 include/asm-generic/syscall.h         |    6 ++----
 include/linux/audit.h                 |    2 +-
 kernel/auditsc.c                      |    5 ++---
 kernel/seccomp.c                      |    4 ++--
 15 files changed, 21 insertions(+), 41 deletions(-)

diff --git a/arch/arm/include/asm/syscall.h b/arch/arm/include/asm/syscall.h
index a749123..4651f69 100644
--- a/arch/arm/include/asm/syscall.h
+++ b/arch/arm/include/asm/syscall.h
@@ -103,8 +103,7 @@ static inline void syscall_set_arguments(struct task_struct *task,
 	memcpy(&regs->ARM_r0 + i, args, n * sizeof(args[0]));
 }
 
-static inline int syscall_get_arch(struct task_struct *task,
-				   struct pt_regs *regs)
+static inline int syscall_get_arch(void)
 {
 	/* ARM tasks don't change audit architectures on the fly. */
 	return AUDIT_ARCH_ARM;
diff --git a/arch/ia64/include/asm/syscall.h b/arch/ia64/include/asm/syscall.h
index 9c82767..1ae443a 100644
--- a/arch/ia64/include/asm/syscall.h
+++ b/arch/ia64/include/asm/syscall.h
@@ -81,8 +81,7 @@ static inline void syscall_set_arguments(struct task_struct *task,
 	ia64_syscall_get_set_arguments(task, regs, i, n, args, 1);
 }
 
-static inline int syscall_get_arch(struct task_struct *tsk,
-				   struct pt_regs *regs)
+static inline int syscall_get_arch(void)
 {
 	return AUDIT_ARCH_IA64;
 }
diff --git a/arch/microblaze/include/asm/syscall.h b/arch/microblaze/include/asm/syscall.h
index e1acf8a..5292281 100644
--- a/arch/microblaze/include/asm/syscall.h
+++ b/arch/microblaze/include/asm/syscall.h
@@ -100,8 +100,7 @@ static inline void syscall_set_arguments(struct task_struct *task,
 asmlinkage long do_syscall_trace_enter(struct pt_regs *regs);
 asmlinkage void do_syscall_trace_leave(struct pt_regs *regs);
 
-static inline int syscall_get_arch(struct tast_struct *tsk,
-				   struct pt_regs *regs)
+static inline int syscall_get_arch(void)
 {
 	return AUDIT_ARCH_MICROBLAZE;
 }
diff --git a/arch/mips/include/asm/syscall.h b/arch/mips/include/asm/syscall.h
index a8234f2..992b6ab 100644
--- a/arch/mips/include/asm/syscall.h
+++ b/arch/mips/include/asm/syscall.h
@@ -101,7 +101,7 @@ extern const unsigned long sys_call_table[];
 extern const unsigned long sys32_call_table[];
 extern const unsigned long sysn32_call_table[];
 
-static inline int __syscall_get_arch(void)
+static inline int syscall_get_arch(void)
 {
 	int arch = AUDIT_ARCH_MIPS;
 #ifdef CONFIG_64BIT
@@ -113,10 +113,4 @@ static inline int __syscall_get_arch(void)
 	return arch;
 }
 
-static inline int syscall_get_arch(struct task_struct *task,
-				   struct pt_regs *regs)
-{
-	return __syscall_get_arch();
-}
-
 #endif	/* __ASM_MIPS_SYSCALL_H */
diff --git a/arch/openrisc/include/asm/syscall.h b/arch/openrisc/include/asm/syscall.h
index 2bbe0e9..e598095 100644
--- a/arch/openrisc/include/asm/syscall.h
+++ b/arch/openrisc/include/asm/syscall.h
@@ -72,8 +72,7 @@ syscall_set_arguments(struct task_struct *task, struct pt_regs *regs,
 	memcpy(&regs->gpr[3 + i], args, n * sizeof(args[0]));
 }
 
-static inline int syscall_get_arch(struct task_struct *tsk,
-				   struct pt_regs *regs)
+static inline int syscall_get_arch(void)
 {
 	return AUDIT_ARCH_OPENRISC;
 }
diff --git a/arch/parisc/include/asm/syscall.h b/arch/parisc/include/asm/syscall.h
index 2bf23b1..87cc53d 100644
--- a/arch/parisc/include/asm/syscall.h
+++ b/arch/parisc/include/asm/syscall.h
@@ -39,8 +39,7 @@ static inline void syscall_get_arguments(struct task_struct *tsk,
 	}
 }
 
-static inline int syscall_get_arch(struct task_struct *tsk,
-				   struct pt_regs *regs)
+static inline int syscall_get_arch(void)
 {
 	int arch = AUDIT_ARCH_PARISC;
 #ifdef CONFIG_64BIT
diff --git a/arch/powerpc/include/asm/syscall.h b/arch/powerpc/include/asm/syscall.h
index 36bd9ef..616705b 100644
--- a/arch/powerpc/include/asm/syscall.h
+++ b/arch/powerpc/include/asm/syscall.h
@@ -88,8 +88,7 @@ static inline void syscall_set_arguments(struct task_struct *task,
 	memcpy(&regs->gpr[3 + i], args, n * sizeof(args[0]));
 }
 
-static inline int syscall_get_arch(struct task_struct *tsk,
-				   struct pt_regs *regs)
+static inline int syscall_get_arch(void)
 {
 	int arch = AUDIT_ARCH_PPC;
 
diff --git a/arch/s390/include/asm/syscall.h b/arch/s390/include/asm/syscall.h
index 79d1805..32cd7f7 100644
--- a/arch/s390/include/asm/syscall.h
+++ b/arch/s390/include/asm/syscall.h
@@ -89,11 +89,10 @@ static inline void syscall_set_arguments(struct task_struct *task,
 		regs->orig_gpr2 = args[0];
 }
 
-static inline int syscall_get_arch(struct task_struct *task,
-				   struct pt_regs *regs)
+static inline int syscall_get_arch(void)
 {
 #ifdef CONFIG_COMPAT
-	if (test_tsk_thread_flag(task, TIF_31BIT))
+	if (test_thread_flag(TIF_31BIT))
 		return AUDIT_ARCH_S390;
 #endif
 	return sizeof(long) = 8 ? AUDIT_ARCH_S390X : AUDIT_ARCH_S390;
diff --git a/arch/sh/include/asm/syscall.h b/arch/sh/include/asm/syscall.h
index 33e60e0..aac9800 100644
--- a/arch/sh/include/asm/syscall.h
+++ b/arch/sh/include/asm/syscall.h
@@ -11,8 +11,7 @@ extern const unsigned long sys_call_table[];
 
 # include <uapi/linux/audit.h>
 
-static inline int syscall_get_arch(struct task_struct *tsk,
-				   struct pt_regs *regs)
+static inline int syscall_get_arch(void)
 {
 	int arch = AUDIT_ARCH_SH;
 
diff --git a/arch/sparc/include/asm/syscall.h b/arch/sparc/include/asm/syscall.h
index eddc60e..82b5b96 100644
--- a/arch/sparc/include/asm/syscall.h
+++ b/arch/sparc/include/asm/syscall.h
@@ -125,8 +125,7 @@ static inline void syscall_set_arguments(struct task_struct *task,
 		regs->u_regs[UREG_I0 + i + j] = args[j];
 }
 
-static inline int syscall_get_arch(struct task_struct *tsk,
-				   struct pt_regs *regs)
+static inline int syscall_get_arch(void)
 {
 	return test_thread_flag(TIF_32BIT) ? AUDIT_ARCH_SPARC
 					   : AUDIT_ARCH_SPARC64;
diff --git a/arch/x86/include/asm/syscall.h b/arch/x86/include/asm/syscall.h
index c98e0ec..d6a756a 100644
--- a/arch/x86/include/asm/syscall.h
+++ b/arch/x86/include/asm/syscall.h
@@ -91,8 +91,7 @@ static inline void syscall_set_arguments(struct task_struct *task,
 	memcpy(&regs->bx + i, args, n * sizeof(args[0]));
 }
 
-static inline int syscall_get_arch(struct task_struct *task,
-				   struct pt_regs *regs)
+static inline int syscall_get_arch(void)
 {
 	return AUDIT_ARCH_I386;
 }
@@ -221,8 +220,7 @@ static inline void syscall_set_arguments(struct task_struct *task,
 		}
 }
 
-static inline int syscall_get_arch(struct task_struct *task,
-				   struct pt_regs *regs)
+static inline int syscall_get_arch(void)
 {
 #ifdef CONFIG_IA32_EMULATION
 	/*
@@ -234,7 +232,7 @@ static inline int syscall_get_arch(struct task_struct *task,
 	 *
 	 * x32 tasks should be considered AUDIT_ARCH_X86_64.
 	 */
-	if (task_thread_info(task)->status & TS_COMPAT)
+	if (task_thread_info(current)->status & TS_COMPAT)
 		return AUDIT_ARCH_I386;
 #endif
 	/* Both x32 and x86_64 are considered "64-bit". */
diff --git a/include/asm-generic/syscall.h b/include/asm-generic/syscall.h
index 5b09392..0c938a4 100644
--- a/include/asm-generic/syscall.h
+++ b/include/asm-generic/syscall.h
@@ -144,16 +144,14 @@ void syscall_set_arguments(struct task_struct *task, struct pt_regs *regs,
 
 /**
  * syscall_get_arch - return the AUDIT_ARCH for the current system call
- * @task:	task of interest, must be in system call entry tracing
- * @regs:	task_pt_regs() of @task
  *
  * Returns the AUDIT_ARCH_* based on the system call convention in use.
  *
- * It's only valid to call this when @task is stopped on entry to a system
+ * It's only valid to call this when current is stopped on entry to a system
  * call, due to %TIF_SYSCALL_TRACE, %TIF_SYSCALL_AUDIT, or %TIF_SECCOMP.
  *
  * Architectures which permit CONFIG_HAVE_ARCH_SECCOMP_FILTER must
  * provide an implementation of this.
  */
-int syscall_get_arch(struct task_struct *task, struct pt_regs *regs);
+int syscall_get_arch(void);
 #endif	/* _ASM_SYSCALL_H */
diff --git a/include/linux/audit.h b/include/linux/audit.h
index 0e63eb1..ee452f1 100644
--- a/include/linux/audit.h
+++ b/include/linux/audit.h
@@ -133,7 +133,7 @@ static inline void audit_syscall_entry(int major, unsigned long a0,
 				       unsigned long a3)
 {
 	if (unlikely(current->audit_context))
-		__audit_syscall_entry(syscall_get_arch(current, NULL), major, a0, a1, a2, a3);
+		__audit_syscall_entry(syscall_get_arch(), major, a0, a1, a2, a3);
 }
 static inline void audit_syscall_exit(void *pt_regs)
 {
diff --git a/kernel/auditsc.c b/kernel/auditsc.c
index 0c9fe06..565f7b7 100644
--- a/kernel/auditsc.c
+++ b/kernel/auditsc.c
@@ -1461,7 +1461,7 @@ void __audit_syscall_entry(int arch, int major,
 	if (!audit_enabled)
 		return;
 
-	context->arch	    = syscall_get_arch(current, NULL);
+	context->arch	    = syscall_get_arch();
 	context->major      = major;
 	context->argv[0]    = a1;
 	context->argv[1]    = a2;
@@ -2416,8 +2416,7 @@ void __audit_seccomp(unsigned long syscall, long signr, int code)
 		return;
 	audit_log_task(ab);
 	audit_log_format(ab, " sig=%ld", signr);
-	audit_log_format(ab, " arch=%x",
-			 syscall_get_arch(current, task_pt_regs(current)));
+	audit_log_format(ab, " arch=%x", syscall_get_arch());
 	audit_log_format(ab, " syscall=%ld", syscall);
 	audit_log_format(ab, " compat=%d", is_compat_task());
 	audit_log_format(ab, " ip=0x%lx", KSTK_EIP(current));
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index b7a1004..eda2da3 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -95,7 +95,7 @@ u32 seccomp_bpf_load(int off)
 	if (off = BPF_DATA(nr))
 		return syscall_get_nr(current, regs);
 	if (off = BPF_DATA(arch))
-		return syscall_get_arch(current, regs);
+		return syscall_get_arch();
 	if (off >= BPF_DATA(args[0]) && off < BPF_DATA(args[6])) {
 		unsigned long value;
 		int arg = (off - BPF_DATA(args[0])) / sizeof(u64);
@@ -351,7 +351,7 @@ static void seccomp_send_sigsys(int syscall, int reason)
 	info.si_code = SYS_SECCOMP;
 	info.si_call_addr = (void __user *)KSTK_EIP(current);
 	info.si_errno = reason;
-	info.si_arch = syscall_get_arch(current, task_pt_regs(current));
+	info.si_arch = syscall_get_arch();
 	info.si_syscall = syscall;
 	force_sig_info(SIGSYS, &info, current);
 }
-- 
1.7.1

