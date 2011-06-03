From: Eric Paris <eparis@redhat.com>
Date: Fri, 03 Jun 2011 22:04:51 +0000
Subject: [PATCH -v2] Audit: push audit success and retcode into arch ptrace.h
Message-Id: <20110603220451.23134.47368.stgit@paris.rdu.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: tony.luck@intel.com, fenghua.yu@intel.com, monstr@monstr.eu, ralf@linux-mips.org, benh@kernel.crashing.org, paulus@samba.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, linux390@de.ibm.com, lethal@linux-sh.org, davem@davemloft.net, jdike@addtoit.com, richard@nod.at, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, viro@zeniv.linux.org.uk, eparis@redhat.com, oleg@redhat.com, akpm@linux-foundation.org, linux-ia64@vger.kernel.org, microblaze-uclinux@itee.uq.edu.au, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net

The audit system previously expected arches calling to audit_syscall_exit to
supply as arguments if the syscall was a success and what the return code was.
Audit also provides a helper AUDITSC_RESULT which was supposed to simplify things
by converting from negative retcodes to an audit internal magic value stating
success or failure.  This helper was wrong and could indicate that a valid
pointer returned to userspace was a failed syscall.  The fix is to fix the
layering foolishness.  We now pass audit_syscall_exit a struct pt_reg and it
in turns calls back into arch code to collect the return value and to
determine if the syscall was a success or failure.  We also define a generic
is_syscall_success() macro which determines success/failure based on if the
value is < -MAX_ERRNO.  This works for arches like x86 which do not use a
separate mechanism to indicate syscall failure.

In arch/sh/kernel/ptrace_64.c I see that we were using regs[9] in the old
audit code as the return value.  But the ptrace_64.h code defined the macro
regs_return_value() as regs[3].  I have no idea which one is correct, but this
patch now uses the regs_return_value() function, so it now uses regs[3].

We make both the is_syscall_success() and regs_return_value() static inlines
instead of macros.  The reason is because the audit function must take a void*
for the regs.  (uml calls theirs struct uml_pt_regs instead of just struct
pt_regs so audit_syscall_exit can't take a struct pt_regs).  Since the audit
function takes a void* we need to use static inlines to cast it back to the
arch correct structure to dereference it.

The other major change is that on some arches, like ia64, we change
regs_return_value() to give us the negative value on syscall failure.  The
only other user of this macro, kretprobe_example.c, won't notice and it makes
the value signed consistently for the audit functions across all archs.

Signed-off-by: Eric Paris <eparis@redhat.com>
Acked-by: Acked-by: H. Peter Anvin <hpa@zytor.com> [for x86 portion]
---

 arch/ia64/include/asm/ptrace.h            |   13 ++++++++++++-
 arch/ia64/kernel/ptrace.c                 |    9 +--------
 arch/microblaze/include/asm/ptrace.h      |    5 +++++
 arch/microblaze/kernel/ptrace.c           |    3 +--
 arch/mips/include/asm/ptrace.h            |   14 +++++++++++++-
 arch/mips/kernel/ptrace.c                 |    4 +---
 arch/powerpc/include/asm/ptrace.h         |   10 +++++++++-
 arch/powerpc/kernel/ptrace.c              |    4 +---
 arch/s390/include/asm/ptrace.h            |    6 +++++-
 arch/s390/kernel/ptrace.c                 |    4 +---
 arch/sh/include/asm/ptrace_32.h           |    5 ++++-
 arch/sh/include/asm/ptrace_64.h           |    5 ++++-
 arch/sh/kernel/ptrace_32.c                |    4 +---
 arch/sh/kernel/ptrace_64.c                |    4 +---
 arch/sparc/include/asm/ptrace.h           |   10 +++++++++-
 arch/sparc/kernel/ptrace_64.c             |   11 +----------
 arch/um/kernel/ptrace.c                   |    4 ++--
 arch/um/sys-i386/shared/sysdep/ptrace.h   |    4 ++++
 arch/um/sys-x86_64/shared/sysdep/ptrace.h |    4 ++++
 arch/x86/ia32/ia32entry.S                 |   10 +++++-----
 arch/x86/kernel/entry_32.S                |    8 ++++----
 arch/x86/kernel/entry_64.S                |   10 +++++-----
 arch/x86/kernel/ptrace.c                  |    3 +--
 arch/x86/kernel/vm86_32.c                 |    4 ++--
 include/linux/audit.h                     |   22 ++++++++++++++--------
 include/linux/ptrace.h                    |   10 ++++++++++
 kernel/auditsc.c                          |   16 ++++++++++++----
 27 files changed, 132 insertions(+), 74 deletions(-)

diff --git a/arch/ia64/include/asm/ptrace.h b/arch/ia64/include/asm/ptrace.h
index 7ae9c3f..801ee1a 100644
--- a/arch/ia64/include/asm/ptrace.h
+++ b/arch/ia64/include/asm/ptrace.h
@@ -246,7 +246,18 @@ static inline unsigned long user_stack_pointer(struct pt_regs *regs)
 	return regs->ar_bspstore;
 }
 
-#define regs_return_value(regs) ((regs)->r8)
+static inline int is_syscall_success(struct pt_regs *regs)
+{
+	return regs->r10 != -1;
+}
+
+static inline long regs_return_value(struct pt_regs *regs)
+{
+	if (is_syscall_success(regs))
+		return regs->r8;
+	else
+		return -regs->r8;
+}
 
 /* Conserve space in histogram by encoding slot bits in address
  * bits 2 and 3 rather than bits 0 and 1.
diff --git a/arch/ia64/kernel/ptrace.c b/arch/ia64/kernel/ptrace.c
index 8848f43..2c15408 100644
--- a/arch/ia64/kernel/ptrace.c
+++ b/arch/ia64/kernel/ptrace.c
@@ -1268,14 +1268,7 @@ syscall_trace_leave (long arg0, long arg1, long arg2, long arg3,
 {
 	int step;
 
-	if (unlikely(current->audit_context)) {
-		int success = AUDITSC_RESULT(regs.r10);
-		long result = regs.r8;
-
-		if (success != AUDITSC_SUCCESS)
-			result = -result;
-		audit_syscall_exit(success, result);
-	}
+	audit_syscall_exit(&regs);
 
 	step = test_thread_flag(TIF_SINGLESTEP);
 	if (step || test_thread_flag(TIF_SYSCALL_TRACE))
diff --git a/arch/microblaze/include/asm/ptrace.h b/arch/microblaze/include/asm/ptrace.h
index d9b6630..bec1c74 100644
--- a/arch/microblaze/include/asm/ptrace.h
+++ b/arch/microblaze/include/asm/ptrace.h
@@ -61,6 +61,11 @@ struct pt_regs {
 #define instruction_pointer(regs)	((regs)->pc)
 #define profile_pc(regs)		instruction_pointer(regs)
 
+static inline long regs_return_value(struct pt_regs *regs)
+{
+	return regs->r3;
+}
+
 void show_regs(struct pt_regs *);
 
 #else /* __KERNEL__ */
diff --git a/arch/microblaze/kernel/ptrace.c b/arch/microblaze/kernel/ptrace.c
index 6a8e0cc..9747fa5 100644
--- a/arch/microblaze/kernel/ptrace.c
+++ b/arch/microblaze/kernel/ptrace.c
@@ -159,8 +159,7 @@ asmlinkage void do_syscall_trace_leave(struct pt_regs *regs)
 {
 	int step;
 
-	if (unlikely(current->audit_context))
-		audit_syscall_exit(AUDITSC_RESULT(regs->r3), regs->r3);
+	audit_syscall_exit(regs);
 
 	step = test_thread_flag(TIF_SINGLESTEP);
 	if (step || test_thread_flag(TIF_SYSCALL_TRACE))
diff --git a/arch/mips/include/asm/ptrace.h b/arch/mips/include/asm/ptrace.h
index de39b1f..7d40950 100644
--- a/arch/mips/include/asm/ptrace.h
+++ b/arch/mips/include/asm/ptrace.h
@@ -137,7 +137,19 @@ extern int ptrace_set_watch_regs(struct task_struct *child,
  */
 #define user_mode(regs) (((regs)->cp0_status & KU_MASK) = KU_USER)
 
-#define regs_return_value(_regs) ((_regs)->regs[2])
+static inline int is_syscall_success(struct pt_regs *regs)
+{
+	return !regs->regs[7];
+}
+
+static inline long regs_return_value(struct pt_regs *regs)
+{
+	if (is_syscall_success(regs))
+		return regs->regs[2];
+	else
+		return -regs->regs[2];
+}
+
 #define instruction_pointer(regs) ((regs)->cp0_epc)
 #define profile_pc(regs) instruction_pointer(regs)
 
diff --git a/arch/mips/kernel/ptrace.c b/arch/mips/kernel/ptrace.c
index 4e6ea1f..ab0f196 100644
--- a/arch/mips/kernel/ptrace.c
+++ b/arch/mips/kernel/ptrace.c
@@ -572,9 +572,7 @@ out:
  */
 asmlinkage void syscall_trace_leave(struct pt_regs *regs)
 {
-	if (unlikely(current->audit_context))
-		audit_syscall_exit(AUDITSC_RESULT(regs->regs[7]),
-		                   -regs->regs[2]);
+	audit_syscall_exit(regs);
 
 	if (!(current->ptrace & PT_PTRACED))
 		return;
diff --git a/arch/powerpc/include/asm/ptrace.h b/arch/powerpc/include/asm/ptrace.h
index 48223f9..679aa7b 100644
--- a/arch/powerpc/include/asm/ptrace.h
+++ b/arch/powerpc/include/asm/ptrace.h
@@ -86,7 +86,15 @@ struct pt_regs {
 #define instruction_pointer(regs) ((regs)->nip)
 #define user_stack_pointer(regs) ((regs)->gpr[1])
 #define kernel_stack_pointer(regs) ((regs)->gpr[1])
-#define regs_return_value(regs) ((regs)->gpr[3])
+static inline int is_syscall_success(struct pt_regs *regs)
+{
+	return !(regs->ccr & 0x10000000);
+}
+
+static inline long regs_return_value(struct pt_regs *regs)
+{
+	return regs->gpr[3];
+}
 
 #ifdef CONFIG_SMP
 extern unsigned long profile_pc(struct pt_regs *regs);
diff --git a/arch/powerpc/kernel/ptrace.c b/arch/powerpc/kernel/ptrace.c
index cb22024..d801ab7 100644
--- a/arch/powerpc/kernel/ptrace.c
+++ b/arch/powerpc/kernel/ptrace.c
@@ -1741,9 +1741,7 @@ void do_syscall_trace_leave(struct pt_regs *regs)
 {
 	int step;
 
-	if (unlikely(current->audit_context))
-		audit_syscall_exit((regs->ccr&0x10000000)?AUDITSC_FAILURE:AUDITSC_SUCCESS,
-				   regs->result);
+	audit_syscall_exit(regs);
 
 	if (unlikely(test_thread_flag(TIF_SYSCALL_TRACEPOINT)))
 		trace_sys_exit(regs, regs->result);
diff --git a/arch/s390/include/asm/ptrace.h b/arch/s390/include/asm/ptrace.h
index 9ad628a..df397e8 100644
--- a/arch/s390/include/asm/ptrace.h
+++ b/arch/s390/include/asm/ptrace.h
@@ -544,9 +544,13 @@ extern void show_regs(struct pt_regs * regs);
 #define user_mode(regs) (((regs)->psw.mask & PSW_MASK_PSTATE) != 0)
 #define instruction_pointer(regs) ((regs)->psw.addr & PSW_ADDR_INSN)
 #define user_stack_pointer(regs)((regs)->gprs[15])
-#define regs_return_value(regs)((regs)->gprs[2])
 #define profile_pc(regs) instruction_pointer(regs)
 
+static inline long regs_return_value(struct pt_regs *regs)
+{
+	return regs->gprs[2];
+}
+
 int regs_query_register_offset(const char *name);
 const char *regs_query_register_name(unsigned int offset);
 unsigned long regs_get_register(struct pt_regs *regs, unsigned int offset);
diff --git a/arch/s390/kernel/ptrace.c b/arch/s390/kernel/ptrace.c
index ef86ad2..d4d6fcb 100644
--- a/arch/s390/kernel/ptrace.c
+++ b/arch/s390/kernel/ptrace.c
@@ -753,9 +753,7 @@ asmlinkage long do_syscall_trace_enter(struct pt_regs *regs)
 
 asmlinkage void do_syscall_trace_exit(struct pt_regs *regs)
 {
-	if (unlikely(current->audit_context))
-		audit_syscall_exit(AUDITSC_RESULT(regs->gprs[2]),
-				   regs->gprs[2]);
+	audit_syscall_exit(regs);
 
 	if (unlikely(test_thread_flag(TIF_SYSCALL_TRACEPOINT)))
 		trace_sys_exit(regs, regs->gprs[2]);
diff --git a/arch/sh/include/asm/ptrace_32.h b/arch/sh/include/asm/ptrace_32.h
index 6c2239c..2d3e906 100644
--- a/arch/sh/include/asm/ptrace_32.h
+++ b/arch/sh/include/asm/ptrace_32.h
@@ -76,7 +76,10 @@ struct pt_dspregs {
 #ifdef __KERNEL__
 
 #define MAX_REG_OFFSET		offsetof(struct pt_regs, tra)
-#define regs_return_value(_regs)	((_regs)->regs[0])
+static inline long regs_return_value(struct pt_regs *regs)
+{
+	return regs->regs[0];
+}
 
 #endif /* __KERNEL__ */
 
diff --git a/arch/sh/include/asm/ptrace_64.h b/arch/sh/include/asm/ptrace_64.h
index bf9be77..eb3fcce 100644
--- a/arch/sh/include/asm/ptrace_64.h
+++ b/arch/sh/include/asm/ptrace_64.h
@@ -13,7 +13,10 @@ struct pt_regs {
 #ifdef __KERNEL__
 
 #define MAX_REG_OFFSET		offsetof(struct pt_regs, tregs[7])
-#define regs_return_value(_regs)	((_regs)->regs[3])
+static inline long regs_return_value(struct pt_regs *regs)
+{
+	return regs->regs[3];
+}
 
 #endif /* __KERNEL__ */
 
diff --git a/arch/sh/kernel/ptrace_32.c b/arch/sh/kernel/ptrace_32.c
index 3d7b209..5fce97e 100644
--- a/arch/sh/kernel/ptrace_32.c
+++ b/arch/sh/kernel/ptrace_32.c
@@ -529,9 +529,7 @@ asmlinkage void do_syscall_trace_leave(struct pt_regs *regs)
 {
 	int step;
 
-	if (unlikely(current->audit_context))
-		audit_syscall_exit(AUDITSC_RESULT(regs->regs[0]),
-				   regs->regs[0]);
+	audit_syscall_exit(regs);
 
 	if (unlikely(test_thread_flag(TIF_SYSCALL_TRACEPOINT)))
 		trace_sys_exit(regs, regs->regs[0]);
diff --git a/arch/sh/kernel/ptrace_64.c b/arch/sh/kernel/ptrace_64.c
index c8f9764..ba720d6 100644
--- a/arch/sh/kernel/ptrace_64.c
+++ b/arch/sh/kernel/ptrace_64.c
@@ -548,9 +548,7 @@ asmlinkage void do_syscall_trace_leave(struct pt_regs *regs)
 {
 	int step;
 
-	if (unlikely(current->audit_context))
-		audit_syscall_exit(AUDITSC_RESULT(regs->regs[9]),
-				   regs->regs[9]);
+	audit_syscall_exit(regs);
 
 	if (unlikely(test_thread_flag(TIF_SYSCALL_TRACEPOINT)))
 		trace_sys_exit(regs, regs->regs[9]);
diff --git a/arch/sparc/include/asm/ptrace.h b/arch/sparc/include/asm/ptrace.h
index c7ad3fe..10f98ca 100644
--- a/arch/sparc/include/asm/ptrace.h
+++ b/arch/sparc/include/asm/ptrace.h
@@ -206,7 +206,15 @@ do {	current_thread_info()->syscall_noerror = 1; \
 #define user_mode(regs) (!((regs)->tstate & TSTATE_PRIV))
 #define instruction_pointer(regs) ((regs)->tpc)
 #define user_stack_pointer(regs) ((regs)->u_regs[UREG_FP])
-#define regs_return_value(regs) ((regs)->u_regs[UREG_I0])
+static inline int is_syscall_success(struct pt_regs *regs)
+{
+	return !(regs->tstate & (TSTATE_XCARRY | TSTATE_ICARRY));
+}
+
+static inline long regs_return_value(struct pt_regs *regs)
+{
+	return regs->u_regs[UREG_I0];
+}
 #ifdef CONFIG_SMP
 extern unsigned long profile_pc(struct pt_regs *);
 #else
diff --git a/arch/sparc/kernel/ptrace_64.c b/arch/sparc/kernel/ptrace_64.c
index 96ee50a..c73c8c5 100644
--- a/arch/sparc/kernel/ptrace_64.c
+++ b/arch/sparc/kernel/ptrace_64.c
@@ -1086,17 +1086,8 @@ asmlinkage int syscall_trace_enter(struct pt_regs *regs)
 
 asmlinkage void syscall_trace_leave(struct pt_regs *regs)
 {
-#ifdef CONFIG_AUDITSYSCALL
-	if (unlikely(current->audit_context)) {
-		unsigned long tstate = regs->tstate;
-		int result = AUDITSC_SUCCESS;
+	audit_syscall_exit(regs);
 
-		if (unlikely(tstate & (TSTATE_XCARRY | TSTATE_ICARRY)))
-			result = AUDITSC_FAILURE;
-
-		audit_syscall_exit(result, regs->u_regs[UREG_I0]);
-	}
-#endif
 	if (unlikely(test_thread_flag(TIF_SYSCALL_TRACEPOINT)))
 		trace_sys_exit(regs, regs->u_regs[UREG_G1]);
 
diff --git a/arch/um/kernel/ptrace.c b/arch/um/kernel/ptrace.c
index 701b672..839141d 100644
--- a/arch/um/kernel/ptrace.c
+++ b/arch/um/kernel/ptrace.c
@@ -203,8 +203,8 @@ void syscall_trace(struct uml_pt_regs *regs, int entryexit)
 					    UPT_SYSCALL_ARG2(regs),
 					    UPT_SYSCALL_ARG3(regs),
 					    UPT_SYSCALL_ARG4(regs));
-		else audit_syscall_exit(AUDITSC_RESULT(UPT_SYSCALL_RET(regs)),
-					UPT_SYSCALL_RET(regs));
+		else
+			audit_syscall_exit(regs);
 	}
 
 	/* Fake a debug trap */
diff --git a/arch/um/sys-i386/shared/sysdep/ptrace.h b/arch/um/sys-i386/shared/sysdep/ptrace.h
index d50e62e..54ca089 100644
--- a/arch/um/sys-i386/shared/sysdep/ptrace.h
+++ b/arch/um/sys-i386/shared/sysdep/ptrace.h
@@ -162,6 +162,10 @@ struct syscall_args {
 #define UPT_ORIG_SYSCALL(r) UPT_EAX(r)
 #define UPT_SYSCALL_NR(r) UPT_ORIG_EAX(r)
 #define UPT_SYSCALL_RET(r) UPT_EAX(r)
+static inline long regs_return_value(struct uml_pt_regs *regs)
+{
+	return UPT_SYSCALL_RET(regs);
+}
 
 #define UPT_FAULTINFO(r) (&(r)->faultinfo)
 
diff --git a/arch/um/sys-x86_64/shared/sysdep/ptrace.h b/arch/um/sys-x86_64/shared/sysdep/ptrace.h
index fdba545..0924e20 100644
--- a/arch/um/sys-x86_64/shared/sysdep/ptrace.h
+++ b/arch/um/sys-x86_64/shared/sysdep/ptrace.h
@@ -124,6 +124,10 @@ struct uml_pt_regs {
 #define UPT_EFLAGS(r) REGS_EFLAGS((r)->gp)
 #define UPT_SYSCALL_NR(r) ((r)->syscall)
 #define UPT_SYSCALL_RET(r) UPT_RAX(r)
+static inline long regs_return_value(struct uml_pt_regs *regs)
+{
+	return UPT_SYSCALL_RET(regs);
+}
 
 extern int user_context(unsigned long sp);
 
diff --git a/arch/x86/ia32/ia32entry.S b/arch/x86/ia32/ia32entry.S
index c1870dd..6d1572f 100644
--- a/arch/x86/ia32/ia32entry.S
+++ b/arch/x86/ia32/ia32entry.S
@@ -14,6 +14,7 @@
 #include <asm/segment.h>
 #include <asm/irqflags.h>
 #include <linux/linkage.h>
+#include <linux/err.h>
 
 /* Avoid __ASSEMBLER__'ifying <linux/audit.h> just for this.  */
 #include <linux/elf-em.h>
@@ -210,13 +211,12 @@ sysexit_from_sys_call:
 	TRACE_IRQS_ON
 	sti
 	movl %eax,%esi		/* second arg, syscall return value */
-	cmpl $0,%eax		/* is it < 0? */
-	setl %al		/* 1 if so, 0 if not */
+	cmpl $-MAX_ERRNO,%eax	/* is it an error ? */
+	setbe %al		/* 1 if so, 0 if not */
 	movzbl %al,%edi		/* zero-extend that into %edi */
-	inc %edi /* first arg, 0->1(AUDITSC_SUCCESS), 1->2(AUDITSC_FAILURE) */
-	call audit_syscall_exit
+	call __audit_syscall_exit
 	GET_THREAD_INFO(%r10)
-	movl RAX-ARGOFFSET(%rsp),%eax	/* reload syscall return value */
+	movq RAX-ARGOFFSET(%rsp),%rax	/* reload syscall return value */
 	movl $(_TIF_ALLWORK_MASK & ~_TIF_SYSCALL_AUDIT),%edi
 	cli
 	TRACE_IRQS_OFF
diff --git a/arch/x86/kernel/entry_32.S b/arch/x86/kernel/entry_32.S
index 5c1a919..584112a 100644
--- a/arch/x86/kernel/entry_32.S
+++ b/arch/x86/kernel/entry_32.S
@@ -54,6 +54,7 @@
 #include <asm/ftrace.h>
 #include <asm/irq_vectors.h>
 #include <asm/cpufeature.h>
+#include <linux/err.h>
 
 /* Avoid __ASSEMBLER__'ifying <linux/audit.h> just for this.  */
 #include <linux/elf-em.h>
@@ -465,11 +466,10 @@ sysexit_audit:
 	TRACE_IRQS_ON
 	ENABLE_INTERRUPTS(CLBR_ANY)
 	movl %eax,%edx		/* second arg, syscall return value */
-	cmpl $0,%eax		/* is it < 0? */
-	setl %al		/* 1 if so, 0 if not */
+	cmpl $-MAX_ERRNO,%eax	/* is it an error ? */
+	setbe %al		/* 1 if so, 0 if not */
 	movzbl %al,%eax		/* zero-extend that */
-	inc %eax /* first arg, 0->1(AUDITSC_SUCCESS), 1->2(AUDITSC_FAILURE) */
-	call audit_syscall_exit
+	call __audit_syscall_exit
 	DISABLE_INTERRUPTS(CLBR_ANY)
 	TRACE_IRQS_OFF
 	movl TI_flags(%ebp), %ecx
diff --git a/arch/x86/kernel/entry_64.S b/arch/x86/kernel/entry_64.S
index 8a445a0..b7b1f88 100644
--- a/arch/x86/kernel/entry_64.S
+++ b/arch/x86/kernel/entry_64.S
@@ -53,6 +53,7 @@
 #include <asm/paravirt.h>
 #include <asm/ftrace.h>
 #include <asm/percpu.h>
+#include <linux/err.h>
 
 /* Avoid __ASSEMBLER__'ifying <linux/audit.h> just for this.  */
 #include <linux/elf-em.h>
@@ -564,17 +565,16 @@ auditsys:
 	jmp system_call_fastpath
 
 	/*
-	 * Return fast path for syscall audit.  Call audit_syscall_exit()
+	 * Return fast path for syscall audit.  Call __audit_syscall_exit()
 	 * directly and then jump back to the fast path with TIF_SYSCALL_AUDIT
 	 * masked off.
 	 */
 sysret_audit:
 	movq RAX-ARGOFFSET(%rsp),%rsi	/* second arg, syscall return value */
-	cmpq $0,%rsi		/* is it < 0? */
-	setl %al		/* 1 if so, 0 if not */
+	cmpq $-MAX_ERRNO,%rsi	/* is it < -MAX_ERRNO? */
+	setbe %al		/* 1 if so, 0 if not */
 	movzbl %al,%edi		/* zero-extend that into %edi */
-	inc %edi /* first arg, 0->1(AUDITSC_SUCCESS), 1->2(AUDITSC_FAILURE) */
-	call audit_syscall_exit
+	call __audit_syscall_exit
 	movl $(_TIF_ALLWORK_MASK & ~_TIF_SYSCALL_AUDIT),%edi
 	jmp sysret_check
 #endif	/* CONFIG_AUDITSYSCALL */
diff --git a/arch/x86/kernel/ptrace.c b/arch/x86/kernel/ptrace.c
index 807c2a2..5c6281e 100644
--- a/arch/x86/kernel/ptrace.c
+++ b/arch/x86/kernel/ptrace.c
@@ -1412,8 +1412,7 @@ void syscall_trace_leave(struct pt_regs *regs)
 {
 	bool step;
 
-	if (unlikely(current->audit_context))
-		audit_syscall_exit(AUDITSC_RESULT(regs->ax), regs->ax);
+	audit_syscall_exit(regs);
 
 	if (unlikely(test_thread_flag(TIF_SYSCALL_TRACEPOINT)))
 		trace_sys_exit(regs, regs->ax);
diff --git a/arch/x86/kernel/vm86_32.c b/arch/x86/kernel/vm86_32.c
index 863f875..af17e1c 100644
--- a/arch/x86/kernel/vm86_32.c
+++ b/arch/x86/kernel/vm86_32.c
@@ -335,9 +335,9 @@ static void do_sys_vm86(struct kernel_vm86_struct *info, struct task_struct *tsk
 	if (info->flags & VM86_SCREEN_BITMAP)
 		mark_screen_rdonly(tsk->mm);
 
-	/*call audit_syscall_exit since we do not exit via the normal paths */
+	/*call __audit_syscall_exit since we do not exit via the normal paths */
 	if (unlikely(current->audit_context))
-		audit_syscall_exit(AUDITSC_RESULT(0), 0);
+		__audit_syscall_exit(1, 0);
 
 	__asm__ __volatile__(
 		"movl %0,%%esp\n\t"
diff --git a/include/linux/audit.h b/include/linux/audit.h
index 208efd6..0452dfc 100644
--- a/include/linux/audit.h
+++ b/include/linux/audit.h
@@ -26,6 +26,7 @@
 
 #include <linux/types.h>
 #include <linux/elf-em.h>
+#include <linux/ptrace.h>
 
 /* The netlink messages for the audit system is divided into blocks:
  * 1000 - 1099 are for commanding the audit system
@@ -410,10 +411,6 @@ struct audit_field {
 	void				*lsm_rule;
 };
 
-#define AUDITSC_INVALID 0
-#define AUDITSC_SUCCESS 1
-#define AUDITSC_FAILURE 2
-#define AUDITSC_RESULT(x) ( ((long)(x))<0?AUDITSC_FAILURE:AUDITSC_SUCCESS )
 extern int __init audit_register_class(int class, unsigned *list);
 extern int audit_classify_syscall(int abi, unsigned syscall);
 extern int audit_classify_arch(int arch);
@@ -426,7 +423,7 @@ extern void audit_free(struct task_struct *task);
 extern void audit_syscall_entry(int arch,
 				int major, unsigned long a0, unsigned long a1,
 				unsigned long a2, unsigned long a3);
-extern void audit_syscall_exit(int failed, long return_code);
+extern void __audit_syscall_exit(int ret_success, long ret_value);
 extern void __audit_getname(const char *name);
 extern void audit_putname(const char *name);
 extern void __audit_inode(const char *name, const struct dentry *dentry);
@@ -441,6 +438,15 @@ static inline int audit_dummy_context(void)
 	void *p = current->audit_context;
 	return !p || *(int *)p;
 }
+static inline void audit_syscall_exit(void *pt_regs)
+{
+	if (unlikely(current->audit_context)) {
+		int success = is_syscall_success(pt_regs);
+		int return_code = regs_return_value(pt_regs);
+
+		__audit_syscall_exit(success, return_code);
+	}
+}
 static inline void audit_getname(const char *name)
 {
 	if (unlikely(!audit_dummy_context()))
@@ -560,12 +566,12 @@ static inline void audit_mmap_fd(int fd, int flags)
 
 extern int audit_n_rules;
 extern int audit_signals;
-#else
+#else /* CONFIG_AUDITSYSCALL */
 #define audit_finish_fork(t)
 #define audit_alloc(t) ({ 0; })
 #define audit_free(t) do { ; } while (0)
 #define audit_syscall_entry(ta,a,b,c,d,e) do { ; } while (0)
-#define audit_syscall_exit(f,r) do { ; } while (0)
+#define audit_syscall_exit(r) do { ; } while (0)
 #define audit_dummy_context() 1
 #define audit_getname(n) do { ; } while (0)
 #define audit_putname(n) do { ; } while (0)
@@ -597,7 +603,7 @@ extern int audit_signals;
 #define audit_rng(d, c, l) (0)
 #define audit_n_rules 0
 #define audit_signals 0
-#endif
+#endif /* CONFIG_AUDITSYSCALL */
 
 #ifdef CONFIG_AUDIT
 /* These are defined in audit.c */
diff --git a/include/linux/ptrace.h b/include/linux/ptrace.h
index 9178d5c..29bb846 100644
--- a/include/linux/ptrace.h
+++ b/include/linux/ptrace.h
@@ -98,6 +98,7 @@
 
 #include <linux/compiler.h>		/* For unlikely.  */
 #include <linux/sched.h>		/* For struct task_struct.  */
+#include <linux/err.h>			/* for IS_ERR_VALUE */
 
 
 extern long arch_ptrace(struct task_struct *child, long request,
@@ -223,6 +224,15 @@ static inline void ptrace_release_task(struct task_struct *task)
 #define force_successful_syscall_return() do { } while (0)
 #endif
 
+#ifndef is_syscall_success
+/*
+ * On most systems we can tell if a syscall is a success based on if the retval
+ * is an error value.  On some systems like ia64 and powerpc they have different
+ * indicators of success/failure and must define their own.
+ */
+#define is_syscall_success(regs) (!IS_ERR_VALUE((unsigned long)(regs_return_value(regs))))
+#endif
+
 /*
  * <asm/ptrace.h> should define the following things inside #ifdef __KERNEL__.
  *
diff --git a/kernel/auditsc.c b/kernel/auditsc.c
index 9c61afe..d21a34f 100644
--- a/kernel/auditsc.c
+++ b/kernel/auditsc.c
@@ -70,6 +70,11 @@
 
 #include "audit.h"
 
+/* flags stating the success for a syscall */
+#define AUDITSC_INVALID 0
+#define AUDITSC_SUCCESS 1
+#define AUDITSC_FAILURE 2
+
 /* AUDIT_NAMES is the number of slots we reserve in the audit_context
  * for saving names from getname().  If we get more names we will allocate
  * a name dynamically and also add those to the list anchored by names_list. */
@@ -1737,8 +1742,7 @@ void audit_finish_fork(struct task_struct *child)
 
 /**
  * audit_syscall_exit - deallocate audit context after a system call
- * @valid: success/failure flag
- * @return_code: syscall return value
+ * @pt_regs: syscall registers
  *
  * Tear down after system call.  If the audit context has been marked as
  * auditable (either because of the AUDIT_RECORD_CONTEXT state from
@@ -1746,13 +1750,17 @@ void audit_finish_fork(struct task_struct *child)
  * message), then write out the syscall information.  In call cases,
  * free the names stored from getname().
  */
-void audit_syscall_exit(int valid, long return_code)
+void __audit_syscall_exit(int success, long return_code)
 {
 	struct task_struct *tsk = current;
 	struct audit_context *context;
 
-	context = audit_get_context(tsk, valid, return_code);
+	if (success)
+		success = AUDITSC_SUCCESS;
+	else
+		success = AUDITSC_FAILURE;
 
+	context = audit_get_context(tsk, success, return_code);
 	if (likely(!context))
 		return;
 

