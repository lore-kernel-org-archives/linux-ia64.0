From: Richard Guy Briggs <rgb@redhat.com>
Date: Wed, 05 Mar 2014 21:27:05 +0000
Subject: [PATCH 4/6][RFC] audit: drop arch from audit_syscall_entry() interface
Message-Id: <9f2b0caedfee3018ab84d8bbe6e691bb40519d94.1393974970.git.rgb@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1393974970.git.rgb@redhat.com>
In-Reply-To: <cover.1393974970.git.rgb@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-audit@redhat.com, linux-kernel@vger.kernel.org
Cc: Richard Guy Briggs <rgb@redhat.com>, eparis@redhat.com, sgrubb@redhat.com, oleg@redhat.com, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-ia64@vger.kernel.org, microblaze-uclinux@itee.uq.edu.au, linux-mips@linux-mips.org, linux@openrisc.net, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, linux-arch@vger.kernel.org

Make audit_syscall_entry() ignore the arch parameter passed to it and call
syscall_get_arch() locally.

Remove arch from the audit_syscall_entry() parameter list.

Signed-off-by: Richard Guy Briggs <rgb@redhat.com>

---
 arch/arm/kernel/ptrace.c        |    2 +-
 arch/ia64/kernel/ptrace.c       |    2 +-
 arch/microblaze/kernel/ptrace.c |    2 +-
 arch/mips/kernel/ptrace.c       |    3 +--
 arch/openrisc/kernel/ptrace.c   |    2 +-
 arch/parisc/kernel/ptrace.c     |    5 ++---
 arch/powerpc/kernel/ptrace.c    |    6 ++----
 arch/s390/kernel/ptrace.c       |    4 +---
 arch/sh/kernel/ptrace_32.c      |   13 +------------
 arch/sh/kernel/ptrace_64.c      |   16 +---------------
 arch/sparc/kernel/ptrace_64.c   |    5 +----
 arch/um/kernel/ptrace.c         |    3 +--
 arch/x86/kernel/ptrace.c        |    6 ++----
 arch/xtensa/kernel/ptrace.c     |    2 +-
 include/linux/audit.h           |    8 +++++---
 15 files changed, 22 insertions(+), 57 deletions(-)

diff --git a/arch/arm/kernel/ptrace.c b/arch/arm/kernel/ptrace.c
index 0dd3b79..24664f5 100644
--- a/arch/arm/kernel/ptrace.c
+++ b/arch/arm/kernel/ptrace.c
@@ -943,7 +943,7 @@ asmlinkage int syscall_trace_enter(struct pt_regs *regs, int scno)
 	if (test_thread_flag(TIF_SYSCALL_TRACEPOINT))
 		trace_sys_enter(regs, scno);
 
-	audit_syscall_entry(AUDIT_ARCH_ARM, scno, regs->ARM_r0, regs->ARM_r1,
+	audit_syscall_entry(scno, regs->ARM_r0, regs->ARM_r1,
 			    regs->ARM_r2, regs->ARM_r3);
 
 	return scno;
diff --git a/arch/ia64/kernel/ptrace.c b/arch/ia64/kernel/ptrace.c
index b7a5fff..6f54d51 100644
--- a/arch/ia64/kernel/ptrace.c
+++ b/arch/ia64/kernel/ptrace.c
@@ -1219,7 +1219,7 @@ syscall_trace_enter (long arg0, long arg1, long arg2, long arg3,
 		ia64_sync_krbs();
 
 
-	audit_syscall_entry(AUDIT_ARCH_IA64, regs.r15, arg0, arg1, arg2, arg3);
+	audit_syscall_entry(regs.r15, arg0, arg1, arg2, arg3);
 
 	return 0;
 }
diff --git a/arch/microblaze/kernel/ptrace.c b/arch/microblaze/kernel/ptrace.c
index 39cf508..0abbb2e 100644
--- a/arch/microblaze/kernel/ptrace.c
+++ b/arch/microblaze/kernel/ptrace.c
@@ -147,7 +147,7 @@ asmlinkage long do_syscall_trace_enter(struct pt_regs *regs)
 		 */
 		ret = -1L;
 
-	audit_syscall_entry(EM_MICROBLAZE, regs->r12, regs->r5, regs->r6,
+	audit_syscall_entry(regs->r12, regs->r5, regs->r6,
 			    regs->r7, regs->r8);
 
 	return ret ?: regs->r12;
diff --git a/arch/mips/kernel/ptrace.c b/arch/mips/kernel/ptrace.c
index b52e1d2..f68d75f 100644
--- a/arch/mips/kernel/ptrace.c
+++ b/arch/mips/kernel/ptrace.c
@@ -671,8 +671,7 @@ asmlinkage void syscall_trace_enter(struct pt_regs *regs)
 	if (unlikely(test_thread_flag(TIF_SYSCALL_TRACEPOINT)))
 		trace_sys_enter(regs, regs->regs[2]);
 
-	audit_syscall_entry(__syscall_get_arch(),
-			    regs->regs[2],
+	audit_syscall_entry(regs->regs[2],
 			    regs->regs[4], regs->regs[5],
 			    regs->regs[6], regs->regs[7]);
 }
diff --git a/arch/openrisc/kernel/ptrace.c b/arch/openrisc/kernel/ptrace.c
index 71a2a0c..c19cd19 100644
--- a/arch/openrisc/kernel/ptrace.c
+++ b/arch/openrisc/kernel/ptrace.c
@@ -187,7 +187,7 @@ asmlinkage long do_syscall_trace_enter(struct pt_regs *regs)
 		 */
 		ret = -1L;
 
-	audit_syscall_entry(AUDIT_ARCH_OPENRISC, regs->gpr[11],
+	audit_syscall_entry(regs->gpr[11],
 			    regs->gpr[3], regs->gpr[4],
 			    regs->gpr[5], regs->gpr[6]);
 
diff --git a/arch/parisc/kernel/ptrace.c b/arch/parisc/kernel/ptrace.c
index e842ee2..b2f84e2 100644
--- a/arch/parisc/kernel/ptrace.c
+++ b/arch/parisc/kernel/ptrace.c
@@ -276,13 +276,12 @@ long do_syscall_trace_enter(struct pt_regs *regs)
 
 #ifdef CONFIG_64BIT
 	if (!is_compat_task())
-		audit_syscall_entry(AUDIT_ARCH_PARISC64,
-			regs->gr[20],
+		audit_syscall_entry(regs->gr[20],
 			regs->gr[26], regs->gr[25],
 			regs->gr[24], regs->gr[23]);
 	else
 #endif
-		audit_syscall_entry(AUDIT_ARCH_PARISC,
+		audit_syscall_entry(
 			regs->gr[20] & 0xffffffff,
 			regs->gr[26] & 0xffffffff,
 			regs->gr[25] & 0xffffffff,
diff --git a/arch/powerpc/kernel/ptrace.c b/arch/powerpc/kernel/ptrace.c
index 2e3d2bf..cabc1ca 100644
--- a/arch/powerpc/kernel/ptrace.c
+++ b/arch/powerpc/kernel/ptrace.c
@@ -1788,14 +1788,12 @@ long do_syscall_trace_enter(struct pt_regs *regs)
 
 #ifdef CONFIG_PPC64
 	if (!is_32bit_task())
-		audit_syscall_entry(AUDIT_ARCH_PPC64,
-				    regs->gpr[0],
+		audit_syscall_entry(regs->gpr[0],
 				    regs->gpr[3], regs->gpr[4],
 				    regs->gpr[5], regs->gpr[6]);
 	else
 #endif
-		audit_syscall_entry(AUDIT_ARCH_PPC,
-				    regs->gpr[0],
+		audit_syscall_entry(regs->gpr[0],
 				    regs->gpr[3] & 0xffffffff,
 				    regs->gpr[4] & 0xffffffff,
 				    regs->gpr[5] & 0xffffffff,
diff --git a/arch/s390/kernel/ptrace.c b/arch/s390/kernel/ptrace.c
index e65c91c..2e2e7bb 100644
--- a/arch/s390/kernel/ptrace.c
+++ b/arch/s390/kernel/ptrace.c
@@ -812,9 +812,7 @@ asmlinkage long do_syscall_trace_enter(struct pt_regs *regs)
 	if (unlikely(test_thread_flag(TIF_SYSCALL_TRACEPOINT)))
 		trace_sys_enter(regs, regs->gprs[2]);
 
-	audit_syscall_entry(is_compat_task() ?
-				AUDIT_ARCH_S390 : AUDIT_ARCH_S390X,
-			    regs->gprs[2], regs->orig_gpr2,
+	audit_syscall_entry(regs->gprs[2], regs->orig_gpr2,
 			    regs->gprs[3], regs->gprs[4],
 			    regs->gprs[5]);
 out:
diff --git a/arch/sh/kernel/ptrace_32.c b/arch/sh/kernel/ptrace_32.c
index 668c816..313fb5a 100644
--- a/arch/sh/kernel/ptrace_32.c
+++ b/arch/sh/kernel/ptrace_32.c
@@ -484,17 +484,6 @@ long arch_ptrace(struct task_struct *child, long request,
 	return ret;
 }
 
-static inline int audit_arch(void)
-{
-	int arch = EM_SH;
-
-#ifdef CONFIG_CPU_LITTLE_ENDIAN
-	arch |= __AUDIT_ARCH_LE;
-#endif
-
-	return arch;
-}
-
 asmlinkage long do_syscall_trace_enter(struct pt_regs *regs)
 {
 	long ret = 0;
@@ -513,7 +502,7 @@ asmlinkage long do_syscall_trace_enter(struct pt_regs *regs)
 	if (unlikely(test_thread_flag(TIF_SYSCALL_TRACEPOINT)))
 		trace_sys_enter(regs, regs->regs[0]);
 
-	audit_syscall_entry(audit_arch(), regs->regs[3],
+	audit_syscall_entry(regs->regs[3],
 			    regs->regs[4], regs->regs[5],
 			    regs->regs[6], regs->regs[7]);
 
diff --git a/arch/sh/kernel/ptrace_64.c b/arch/sh/kernel/ptrace_64.c
index af90339..0c58711 100644
--- a/arch/sh/kernel/ptrace_64.c
+++ b/arch/sh/kernel/ptrace_64.c
@@ -504,20 +504,6 @@ asmlinkage int sh64_ptrace(long request, long pid,
 	return sys_ptrace(request, pid, addr, data);
 }
 
-static inline int audit_arch(void)
-{
-	int arch = EM_SH;
-
-#ifdef CONFIG_64BIT
-	arch |= __AUDIT_ARCH_64BIT;
-#endif
-#ifdef CONFIG_CPU_LITTLE_ENDIAN
-	arch |= __AUDIT_ARCH_LE;
-#endif
-
-	return arch;
-}
-
 asmlinkage long long do_syscall_trace_enter(struct pt_regs *regs)
 {
 	long long ret = 0;
@@ -536,7 +522,7 @@ asmlinkage long long do_syscall_trace_enter(struct pt_regs *regs)
 	if (unlikely(test_thread_flag(TIF_SYSCALL_TRACEPOINT)))
 		trace_sys_enter(regs, regs->regs[9]);
 
-	audit_syscall_entry(audit_arch(), regs->regs[1],
+	audit_syscall_entry(regs->regs[1],
 			    regs->regs[2], regs->regs[3],
 			    regs->regs[4], regs->regs[5]);
 
diff --git a/arch/sparc/kernel/ptrace_64.c b/arch/sparc/kernel/ptrace_64.c
index c13c9f2..915d35d 100644
--- a/arch/sparc/kernel/ptrace_64.c
+++ b/arch/sparc/kernel/ptrace_64.c
@@ -1076,10 +1076,7 @@ asmlinkage int syscall_trace_enter(struct pt_regs *regs)
 	if (unlikely(test_thread_flag(TIF_SYSCALL_TRACEPOINT)))
 		trace_sys_enter(regs, regs->u_regs[UREG_G1]);
 
-	audit_syscall_entry((test_thread_flag(TIF_32BIT) ?
-			     AUDIT_ARCH_SPARC :
-			     AUDIT_ARCH_SPARC64),
-			    regs->u_regs[UREG_G1],
+	audit_syscall_entry(regs->u_regs[UREG_G1],
 			    regs->u_regs[UREG_I0],
 			    regs->u_regs[UREG_I1],
 			    regs->u_regs[UREG_I2],
diff --git a/arch/um/kernel/ptrace.c b/arch/um/kernel/ptrace.c
index 694d551..62435ef 100644
--- a/arch/um/kernel/ptrace.c
+++ b/arch/um/kernel/ptrace.c
@@ -165,8 +165,7 @@ static void send_sigtrap(struct task_struct *tsk, struct uml_pt_regs *regs,
  */
 void syscall_trace_enter(struct pt_regs *regs)
 {
-	audit_syscall_entry(HOST_AUDIT_ARCH,
-			    UPT_SYSCALL_NR(&regs->regs),
+	audit_syscall_entry(UPT_SYSCALL_NR(&regs->regs),
 			    UPT_SYSCALL_ARG1(&regs->regs),
 			    UPT_SYSCALL_ARG2(&regs->regs),
 			    UPT_SYSCALL_ARG3(&regs->regs),
diff --git a/arch/x86/kernel/ptrace.c b/arch/x86/kernel/ptrace.c
index 7461f50..7499611 100644
--- a/arch/x86/kernel/ptrace.c
+++ b/arch/x86/kernel/ptrace.c
@@ -1488,14 +1488,12 @@ long syscall_trace_enter(struct pt_regs *regs)
 		trace_sys_enter(regs, regs->orig_ax);
 
 	if (IS_IA32)
-		audit_syscall_entry(AUDIT_ARCH_I386,
-				    regs->orig_ax,
+		audit_syscall_entry(regs->orig_ax,
 				    regs->bx, regs->cx,
 				    regs->dx, regs->si);
 #ifdef CONFIG_X86_64
 	else
-		audit_syscall_entry(AUDIT_ARCH_X86_64,
-				    regs->orig_ax,
+		audit_syscall_entry(regs->orig_ax,
 				    regs->di, regs->si,
 				    regs->dx, regs->r10);
 #endif
diff --git a/arch/xtensa/kernel/ptrace.c b/arch/xtensa/kernel/ptrace.c
index 562fac6..4d54b48 100644
--- a/arch/xtensa/kernel/ptrace.c
+++ b/arch/xtensa/kernel/ptrace.c
@@ -342,7 +342,7 @@ void do_syscall_trace_enter(struct pt_regs *regs)
 		do_syscall_trace();
 
 #if 0
-	audit_syscall_entry(current, AUDIT_ARCH_XTENSA..);
+	audit_syscall_entry(...);
 #endif
 }
 
diff --git a/include/linux/audit.h b/include/linux/audit.h
index aa865a9..0e63eb1 100644
--- a/include/linux/audit.h
+++ b/include/linux/audit.h
@@ -27,6 +27,8 @@
 #include <linux/ptrace.h>
 #include <uapi/linux/audit.h>
 
+#include <asm/syscall.h>
+
 struct audit_sig_info {
 	uid_t		uid;
 	pid_t		pid;
@@ -126,12 +128,12 @@ static inline void audit_free(struct task_struct *task)
 	if (unlikely(task->audit_context))
 		__audit_free(task);
 }
-static inline void audit_syscall_entry(int arch, int major, unsigned long a0,
+static inline void audit_syscall_entry(int major, unsigned long a0,
 				       unsigned long a1, unsigned long a2,
 				       unsigned long a3)
 {
 	if (unlikely(current->audit_context))
-		__audit_syscall_entry(arch, major, a0, a1, a2, a3);
+		__audit_syscall_entry(syscall_get_arch(current, NULL), major, a0, a1, a2, a3);
 }
 static inline void audit_syscall_exit(void *pt_regs)
 {
@@ -307,7 +309,7 @@ static inline int audit_alloc(struct task_struct *task)
 }
 static inline void audit_free(struct task_struct *task)
 { }
-static inline void audit_syscall_entry(int arch, int major, unsigned long a0,
+static inline void audit_syscall_entry(int major, unsigned long a0,
 				       unsigned long a1, unsigned long a2,
 				       unsigned long a3)
 { }
-- 
1.7.1

