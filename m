From: Richard Guy Briggs <rgb@redhat.com>
Date: Wed, 05 Mar 2014 21:27:07 +0000
Subject: [PATCH 6/6][RFC] audit: drop arch from __audit_syscall_entry() interface
Message-Id: <fdcaea27c06177b1d5a23b08e42c5e68bbdc8e76.1393974970.git.rgb@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1393974970.git.rgb@redhat.com>
In-Reply-To: <cover.1393974970.git.rgb@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-audit@redhat.com, linux-kernel@vger.kernel.org
Cc: Richard Guy Briggs <rgb@redhat.com>, eparis@redhat.com, sgrubb@redhat.com, oleg@redhat.com, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-ia64@vger.kernel.org, microblaze-uclinux@itee.uq.edu.au, linux-mips@linux-mips.org, linux@openrisc.net, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, linux-arch@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, rostedt@goodmis.org, peterz@infradead.org

Since arch is found locally in __audit_syscall_entry(), there is no need to
pass it in as a parameter.  Delete it from the parameter list.

x86* was the only arch to call __audit_syscall_entry() directly and did so from
assembly code.

Signed-off-by: Richard Guy Briggs <rgb@redhat.com>

---
Can I get some constructive scrutiny from the x86 asm guys here?  It has been a
long time since I've played with x86 assembly code (and never x86_64).  I've
done automated build/regression tests on i686 and x86_64, and I've done manual
tests on an x86_64 virtual machine and everything appears to work fine.  Thanks!

 arch/x86/ia32/ia32entry.S  |   12 ++++++------
 arch/x86/kernel/entry_32.S |   11 +++++------
 arch/x86/kernel/entry_64.S |   11 +++++------
 include/linux/audit.h      |    7 ++-----
 kernel/auditsc.c           |    2 +-
 5 files changed, 19 insertions(+), 24 deletions(-)

diff --git a/arch/x86/ia32/ia32entry.S b/arch/x86/ia32/ia32entry.S
index 4299eb0..f5bdd28 100644
--- a/arch/x86/ia32/ia32entry.S
+++ b/arch/x86/ia32/ia32entry.S
@@ -186,12 +186,12 @@ sysexit_from_sys_call:
 
 #ifdef CONFIG_AUDITSYSCALL
 	.macro auditsys_entry_common
-	movl %esi,%r9d			/* 6th arg: 4th syscall arg */
-	movl %edx,%r8d			/* 5th arg: 3rd syscall arg */
-	/* (already in %ecx)		   4th arg: 2nd syscall arg */
-	movl %ebx,%edx			/* 3rd arg: 1st syscall arg */
-	movl %eax,%esi			/* 2nd arg: syscall number */
-	movl $AUDIT_ARCH_I386,%edi	/* 1st arg: audit arch */
+	movl %esi,%r8d			/* 5th arg: 4th syscall arg */
+	movl %ecx,%r9d			/*swap with edx*/
+	movl %edx,%ecx			/* 4th arg: 3rd syscall arg */
+	movl %r9d,%edx			/* 3rd arg: 2nd syscall arg */
+	movl %ebx,%esi			/* 2nd arg: 1st syscall arg */
+	movl %eax,%edi			/* 1st arg: syscall number */
 	call __audit_syscall_entry
 	movl RAX-ARGOFFSET(%rsp),%eax	/* reload syscall number */
 	cmpq $(IA32_NR_syscalls-1),%rax
diff --git a/arch/x86/kernel/entry_32.S b/arch/x86/kernel/entry_32.S
index a2a4f46..078053e 100644
--- a/arch/x86/kernel/entry_32.S
+++ b/arch/x86/kernel/entry_32.S
@@ -456,12 +456,11 @@ sysenter_audit:
 	jnz syscall_trace_entry
 	addl $4,%esp
 	CFI_ADJUST_CFA_OFFSET -4
-	/* %esi already in 8(%esp)	   6th arg: 4th syscall arg */
-	/* %edx already in 4(%esp)	   5th arg: 3rd syscall arg */
-	/* %ecx already in 0(%esp)	   4th arg: 2nd syscall arg */
-	movl %ebx,%ecx			/* 3rd arg: 1st syscall arg */
-	movl %eax,%edx			/* 2nd arg: syscall number */
-	movl $AUDIT_ARCH_I386,%eax	/* 1st arg: audit arch */
+	movl %esi,4(%esp)		/* 5th arg: 4th syscall arg */
+	movl %edx,(%esp)		/* 4th arg: 3rd syscall arg */
+	/* %ecx already in %ecx		   3rd arg: 2nd syscall arg */
+	movl %ebx,%edx			/* 2nd arg: 1st syscall arg */
+	/* %eax already in %eax		   1st arg: syscall number */
 	call __audit_syscall_entry
 	pushl_cfi %ebx
 	movl PT_EAX(%esp),%eax		/* reload syscall number */
diff --git a/arch/x86/kernel/entry_64.S b/arch/x86/kernel/entry_64.S
index 1e96c36..8292ff7 100644
--- a/arch/x86/kernel/entry_64.S
+++ b/arch/x86/kernel/entry_64.S
@@ -694,12 +694,11 @@ badsys:
 	 * jump back to the normal fast path.
 	 */
 auditsys:
-	movq %r10,%r9			/* 6th arg: 4th syscall arg */
-	movq %rdx,%r8			/* 5th arg: 3rd syscall arg */
-	movq %rsi,%rcx			/* 4th arg: 2nd syscall arg */
-	movq %rdi,%rdx			/* 3rd arg: 1st syscall arg */
-	movq %rax,%rsi			/* 2nd arg: syscall number */
-	movl $AUDIT_ARCH_X86_64,%edi	/* 1st arg: audit arch */
+	movq %r10,%r8			/* 5th arg: 4th syscall arg */
+	movq %rdx,%rcx			/* 4th arg: 3rd syscall arg */
+	movq %rsi,%rdx			/* 3rd arg: 2nd syscall arg */
+	movq %rdi,%rsi			/* 2nd arg: 1st syscall arg */
+	movq %rax,%rdi			/* 1st arg: syscall number */
 	call __audit_syscall_entry
 	LOAD_ARGS 0		/* reload call-clobbered registers */
 	jmp system_call_fastpath
diff --git a/include/linux/audit.h b/include/linux/audit.h
index ee452f1..278bc9d 100644
--- a/include/linux/audit.h
+++ b/include/linux/audit.h
@@ -27,8 +27,6 @@
 #include <linux/ptrace.h>
 #include <uapi/linux/audit.h>
 
-#include <asm/syscall.h>
-
 struct audit_sig_info {
 	uid_t		uid;
 	pid_t		pid;
@@ -100,8 +98,7 @@ extern void audit_log_session_info(struct audit_buffer *ab);
 				/* Public API */
 extern int  audit_alloc(struct task_struct *task);
 extern void __audit_free(struct task_struct *task);
-extern void __audit_syscall_entry(int arch,
-				  int major, unsigned long a0, unsigned long a1,
+extern void __audit_syscall_entry(int major, unsigned long a0, unsigned long a1,
 				  unsigned long a2, unsigned long a3);
 extern void __audit_syscall_exit(int ret_success, long ret_value);
 extern struct filename *__audit_reusename(const __user char *uptr);
@@ -133,7 +130,7 @@ static inline void audit_syscall_entry(int major, unsigned long a0,
 				       unsigned long a3)
 {
 	if (unlikely(current->audit_context))
-		__audit_syscall_entry(syscall_get_arch(), major, a0, a1, a2, a3);
+		__audit_syscall_entry(major, a0, a1, a2, a3);
 }
 static inline void audit_syscall_exit(void *pt_regs)
 {
diff --git a/kernel/auditsc.c b/kernel/auditsc.c
index 565f7b7..a4e4447 100644
--- a/kernel/auditsc.c
+++ b/kernel/auditsc.c
@@ -1445,7 +1445,7 @@ void __audit_free(struct task_struct *tsk)
  * will only be written if another part of the kernel requests that it
  * be written).
  */
-void __audit_syscall_entry(int arch, int major,
+void __audit_syscall_entry(int major,
 			 unsigned long a1, unsigned long a2,
 			 unsigned long a3, unsigned long a4)
 {
-- 
1.7.1

